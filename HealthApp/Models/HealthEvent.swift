// HealthEvent.swift
// 事件类型与特殊事件模型。PRD §6.1，色板见 §4.2（统一走 Color+Tokens）。

import Foundation
import SwiftUI

enum EventType: String, CaseIterable, Codable {
    case illness
    case injury
    case drink
    case travel
    case other

    var label: String {
        switch self {
        case .illness: return "生病"
        case .injury:  return "损伤"
        case .drink:   return "饮酒"
        case .travel:  return "旅行"
        case .other:   return "其他"
        }
    }

    /// 事件主色（PRD §4.2）。
    var color: Color {
        switch self {
        case .illness: return .eventIllness
        case .injury:  return .eventInjury
        case .drink:   return .eventDrink
        case .travel:  return .eventTravel
        case .other:   return .eventOther
        }
    }

    /// 事件背景色（PRD §4.2）。
    var backgroundColor: Color {
        switch self {
        case .illness: return .eventIllnessBg
        case .injury:  return .eventInjuryBg
        case .drink:   return .eventDrinkBg
        case .travel:  return .eventTravelBg
        case .other:   return .eventOtherBg
        }
    }

    var sfSymbol: String {
        switch self {
        case .illness: return "cross.circle"
        case .injury:  return "bandage"
        case .drink:   return "wineglass"
        case .travel:  return "airplane"
        case .other:   return "star.circle"
        }
    }
}

/// 特殊事件：单日（endDate == nil）或时间段（endDate != nil）。
struct HealthEvent: Identifiable, Codable, Equatable {
    let id: String
    var type: EventType
    var title: String
    var startDate: Date
    var endDate: Date?
    var note: String

    var isPeriod: Bool { endDate != nil }

    // MARK: - 日期解析（"yyyy-MM-dd"）

    static let isoFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.locale = Locale(identifier: "zh_CN")
        return f
    }()

    static func date(_ s: String) -> Date {
        isoFormatter.date(from: s) ?? Date()
    }
}
