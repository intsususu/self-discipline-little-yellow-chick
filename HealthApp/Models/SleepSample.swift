// SleepSample.swift
// 睡眠样本（单晚）。PRD §6.1。

import Foundation

struct SleepSample: Identifiable, Equatable {
    let id = UUID()
    let date: Date
    let totalMinutes: Int          // 当晚总时长（分）
    var deepMinutes: Int? = nil    // 深睡
    var coreMinutes: Int? = nil    // 核心
    var remMinutes: Int? = nil     // REM
    var awakeMinutes: Int? = nil   // 清醒
    var efficiency: Double? = nil  // 效率 0–1

    var totalHours: Double { Double(totalMinutes) / 60.0 }
}
