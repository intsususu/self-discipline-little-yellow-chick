// SelfDisciplineSnapshot.swift
// 自律打卡的「当前展示状态」纯数据快照，供 App 卡片与 Widget 共用，保证两端口径一致。
//
// 共享文件：同时编入主 App 与 Widget extension。

import Foundation

/// 某一时刻的自律打卡展示状态。
struct SelfDisciplineSnapshot {
    /// 当前激活时段的任务；非时段为 nil（此时只展示历史，不展示倒计时）。
    let activeTask: CheckInTask?
    /// 激活任务在今日是否已打卡。
    let activeChecked: Bool
    /// 当前是否处于运动时段且本周运动 > 阈值（显示「哥，注意疲劳管理」）。
    let showsFatigueWarning: Bool
    /// 今日（打卡日）已完成任务数。
    let todayCompleted: Int
    /// 今日打卡日（00:00）。
    let today: Date
    /// 本周（周一起）截至当前实际打卡总次数（XX）。
    let weekDone: Int
    /// 本周截至当前理论应打卡总数（YY）= 之前每整天×3 + 今天已开始的时段数。
    let weekExpected: Int

    static let fatigueMessage = "哥，注意疲劳管理"

    /// 由存储与时刻计算当前快照。
    static func make(now: Date = Date(),
                     store: CheckInStore = CheckInStore(),
                     calendar: Calendar = SelfDisciplineSchedule.calendar) -> SelfDisciplineSnapshot {
        let today = SelfDisciplineSchedule.effectiveDay(for: now, calendar: calendar)
        let active = SelfDisciplineSchedule.activeTask(at: now, calendar: calendar)
        let checked = active.map { store.isChecked($0, on: today) } ?? false
        let fatigue = (active == .exercise) && store.shouldWarnFatigue(on: today)

        // 本周累计：XX = 实际打卡总数；YY = 之前整天×3 + 今天已开始的时段数。
        let weekStart = SelfDisciplineSchedule.weekStart(for: today, calendar: calendar)
        let fullDaysBefore = calendar.dateComponents([.day], from: weekStart, to: today).day ?? 0
        let base = calendar.startOfDay(for: today)
        let todayStarted = CheckInTask.allCases.filter { task in
            now >= base.addingTimeInterval(TimeInterval(task.window.start * 60))
        }.count
        let weekExpected = fullDaysBefore * 3 + todayStarted
        let weekDone = CheckInTask.allCases.reduce(0) { $0 + store.weeklyCount($1, weekContaining: today) }

        return SelfDisciplineSnapshot(
            activeTask: active,
            activeChecked: checked,
            showsFatigueWarning: fatigue,
            todayCompleted: store.completedCount(on: today),
            today: today,
            weekDone: weekDone,
            weekExpected: weekExpected
        )
    }
}
