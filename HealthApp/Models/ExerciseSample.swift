// ExerciseSample.swift
// 运动样本（按月聚合或按次）。PRD §6.1。

import Foundation

struct ExerciseSample: Identifiable, Equatable {
    let id = UUID()
    let label: String    // 月份/日期标签，如 "1月"
    let kcal: Double      // 消耗千卡
    var avgHR: Double?    // 平均心率
    var minutes: Int?     // 时长
}
