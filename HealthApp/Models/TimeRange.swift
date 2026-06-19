// TimeRange.swift
// 各页时间范围切换（睡眠/运动按需取子集）。PRD §8.2。

import Foundation

enum TimeRange: String, CaseIterable, Identifiable {
    case week
    case month
    case year
    case all

    var id: String { rawValue }

    var label: String {
        switch self {
        case .week:  return "周"
        case .month: return "月"
        case .year:  return "年"
        case .all:   return "全部"
        }
    }
}
