// DailyMetric.swift
// 通用「按日趋势」点：首页睡眠/运动卡的最近 30 日折线复用此类型。

import Foundation

struct DailyMetric: Identifiable, Equatable {
    let id = UUID()
    let date: Date
    let value: Double
}
