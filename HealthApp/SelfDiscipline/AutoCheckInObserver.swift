// AutoCheckInObserver.swift
// HealthKit 后台投递：监听锻炼时长 / 训练数据更新，在 App 未打开时由系统唤醒进程，
// 自动完成「运动」打卡并刷新桌面小组件——解决「运动结束后不打开 App、桌面组件不更新」。
//
// 受 iOS 后台执行限制，非临床数据投递频率系统上限约每小时一次；workout 类型由 Apple Watch
// 推送时往往更快（数分钟内）。做不到秒级即时（那是系统天花板，任何 App 都一样）。
//
// 仅真机生效：模拟器为纯 Mock 数据源，不连接真实 HealthKit。
// 仅编入主 App target（依赖 WidgetCenter 主动 reload；不进 Widget extension）。

import Foundation
import HealthKit
import WidgetKit

final class AutoCheckInObserver {
    static let shared = AutoCheckInObserver()

    private let healthStore = HKHealthStore()
    private let syncer: AutoCheckInSyncer
    private var started = false

    private init() {
        syncer = AutoCheckInSyncer(healthStore: healthStore)
    }

    /// 注册观察查询并开启后台投递。重复调用安全（仅首次生效）。
    /// 须在 HealthKit 授权完成后调用：未授权时投递不会触发，授权后系统才开始唤醒。
    /// 每次 App 启动都应调用——HKObserverQuery 需在进程内重新 execute 才能收到通知；
    /// enableBackgroundDelivery 的登记本身跨启动持久，重复开启幂等。
    func start() {
        guard !started, HKHealthStore.isHealthDataAvailable() else { return }
        started = true

        var types: [HKSampleType] = [HKObjectType.workoutType()]
        if let exercise = AutoCheckIn.exerciseType {
            types.append(exercise)
        }

        for type in types {
            let query = HKObserverQuery(sampleType: type, predicate: nil) { [weak self] _, completionHandler, error in
                guard error == nil, let self else {
                    completionHandler()
                    return
                }
                // 后台唤醒窗口很短：同步达标日并按需 reload 组件，完成后务必回调，否则系统会按背压降频。
                Task {
                    let changed = await self.syncer.sync()
                    if changed {
                        WidgetCenter.shared.reloadAllTimelines()
                    }
                    completionHandler()
                }
            }
            healthStore.execute(query)
            // workout 允许更快投递；exerciseTime 系统会自动降到约每小时。统一请求 immediate 取各自最快档。
            healthStore.enableBackgroundDelivery(for: type, frequency: .immediate) { _, _ in }
        }
    }
}
