// HIITCalorie.swift
// 小工具 · 训练计划：HIIT 热量预估。基于 MET 公式 kcal = MET × 体重(kg) × 时长(小时)，
// 体重取「体重」记录最新值，缺失时按身高以 BMI 22 估算（参考用户身高体重）。

import SwiftUI

// MARK: - 当前体重（环境值，自顶向下注入）

private struct BodyWeightKey: EnvironmentKey {
    static let defaultValue: Double = 0   // 0 表示未知
}

extension EnvironmentValues {
    /// 当前用户体重（kg）。0 表示尚未取到。
    var bodyWeightKg: Double {
        get { self[BodyWeightKey.self] }
        set { self[BodyWeightKey.self] = newValue }
    }
}

enum BodyWeight {
    /// 体重缺失时按身高估算（BMI 22）。
    static func estimate(heightCm: Int) -> Double {
        let h = Double(heightCm) / 100.0
        return (22.0 * h * h).rounded()
    }
}

// MARK: - MET / 热量

extension HIITMove {
    /// 该动作的 MET 值（代谢当量）。以难度为主，按动作类型微调。
    var met: Double {
        let base: Double
        switch difficulty {
        case 1:  base = 3.5
        case 2:  base = 6.0
        case 3:  base = 9.0
        default: base = 12.0   // 4+
        }
        switch kind {
        case "步行":        return 3.5
        case "循环机/蹬车": return min(base, 7.0)
        case "跳绳":        return max(base, 11.0)
        case "冲刺/短跑":   return max(base, 13.5)
        default:            return base
        }
    }

    /// 指定时长（秒）下的预估消耗（千卡）。体重无效时返回 0。
    func estimatedKcal(weightKg: Double, seconds: Int) -> Double {
        guard weightKg > 0, seconds > 0 else { return 0 }
        return met * weightKg * (Double(seconds) / 3600.0)
    }

    /// 每分钟预估消耗（千卡），用于单动作详情。
    func kcalPerMinute(weightKg: Double) -> Double {
        estimatedKcal(weightKg: weightKg, seconds: 60)
    }
}

extension HIITWorkout {
    /// 整组（含 rounds 与组间休息）的预估消耗（千卡）。休息按 MET 1.5 计。
    func estimatedKcal(weightKg: Double) -> Double {
        guard weightKg > 0 else { return 0 }
        let workSeconds = Double(workSec) / 3600.0
        let restSeconds = Double(restSec) / 3600.0
        let perRound = moves.reduce(0.0) { sum, move in
            sum + move.met * weightKg * workSeconds + 1.5 * weightKg * restSeconds
        }
        return perRound * Double(rounds)
    }
}

/// 千卡格式化：< 10 保留 1 位，其余取整。
func formatKcal(_ value: Double) -> String {
    guard value > 0 else { return "—" }
    return value < 10 ? String(format: "%.1f", value) : "\(Int(value.rounded()))"
}
