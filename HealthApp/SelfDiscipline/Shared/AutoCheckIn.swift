// AutoCheckIn.swift
// 运动「自动打卡」的共享判定与写入逻辑：读 HealthKit 锻炼时长（appleExerciseTime），
// 把当日达标的日子写进共享 CheckInStore。三处共用同一套口径——
//   · App 内「自律打卡」页前台同步；
//   · App 被 HealthKit 后台投递唤醒时同步（AutoCheckInObserver，App 未打开也能更新）；
//   · Widget 时间线刷新时自读同步（不依赖 App 是否运行）。
// 仅本机：只读 HealthKit、只写本机 App Group 存储，无网络。
//
// 共享文件：同时编入主 App 与 Widget extension（两个 target 均勾选）。

import Foundation
import HealthKit

/// 自动运动打卡的口径常量（单一来源，避免 App / Widget 阈值写散）。
enum AutoCheckIn {
    /// 阈值：当日主动运动 ≥ 该分钟数即自动完成「运动」打卡。
    static let thresholdMinutes = 30

    /// 锻炼时长类型；HealthKit 不可用或取不到时为 nil。
    static var exerciseType: HKQuantityType? {
        HKObjectType.quantityType(forIdentifier: .appleExerciseTime)
    }
}

/// 读取近若干天锻炼时长、把达标日批量写入 CheckInStore 的同步器。
/// 值语义、无状态，可在任意线程/上下文创建后 await 调用。
struct AutoCheckInSyncer {
    private let healthStore: HKHealthStore
    private let store: CheckInStore
    private let calendar: Calendar

    init(healthStore: HKHealthStore = HKHealthStore(),
         store: CheckInStore = CheckInStore(),
         calendar: Calendar = SelfDisciplineSchedule.calendar) {
        self.healthStore = healthStore
        self.store = store
        self.calendar = calendar
    }

    /// 同步最近 `daysBack` 天的自动运动打卡。
    /// 返回是否有改动——用于决定是否需要 `WidgetCenter.reloadAllTimelines()`，避免无谓刷新吃预算。
    /// 与现有 App 内逻辑保持一致：只「补打卡」（达标即写入），不会因数据变化反向取消已打的卡。
    @discardableResult
    func sync(daysBack: Int = 30) async -> Bool {
        guard HKHealthStore.isHealthDataAvailable(), let type = AutoCheckIn.exerciseType else { return false }
        let minutesByDay = await dailyExerciseMinutes(type: type, daysBack: daysBack)
        let qualifyingDays = Set(minutesByDay.compactMap { entry -> Date? in
            entry.minutes >= Double(AutoCheckIn.thresholdMinutes) ? calendar.startOfDay(for: entry.day) : nil
        })
        guard !qualifyingDays.isEmpty else { return false }
        return store.set(.exercise, checked: true, on: qualifyingDays)
    }

    /// 按自然日累计的锻炼分钟数（与首页 / 趋势页同口径：appleExerciseTime 求和）。
    private func dailyExerciseMinutes(type: HKQuantityType, daysBack: Int) async -> [(day: Date, minutes: Double)] {
        let end = Date()
        let start = calendar.date(byAdding: .day, value: -daysBack, to: end) ?? end
        let anchor = calendar.startOfDay(for: start)
        var interval = DateComponents()
        interval.day = 1
        return await withCheckedContinuation { continuation in
            let predicate = HKQuery.predicateForSamples(withStart: start, end: end)
            let query = HKStatisticsCollectionQuery(quantityType: type,
                                                    quantitySamplePredicate: predicate,
                                                    options: .cumulativeSum,
                                                    anchorDate: anchor,
                                                    intervalComponents: interval)
            query.initialResultsHandler = { _, result, _ in
                guard let result else {
                    continuation.resume(returning: [])
                    return
                }
                var out: [(day: Date, minutes: Double)] = []
                result.enumerateStatistics(from: start, to: end) { statistics, _ in
                    if let minutes = statistics.sumQuantity()?.doubleValue(for: .minute()) {
                        out.append((statistics.startDate, minutes))
                    }
                }
                continuation.resume(returning: out)
            }
            healthStore.execute(query)
        }
    }
}
