// HomeViewModel.swift
// 首页派生指标（混合策略）：体重 current/weeklyDelta 由周序列计算；
// 累计、睡眠、运动 hero 数取自 HomeMetricContract（数据契约常量）。

import SwiftUI

@MainActor
final class HomeViewModel: ObservableObject {
    @Published private(set) var weeklyWeights: [WeightSample] = []
    @Published private(set) var stats: WeightStats?

    func load(from repository: HealthDataRepository) async {
        let weekly = await repository.weightSeries(range: .week)
        weeklyWeights = weekly
        stats = Self.makeStats(from: weekly)
    }

    /// 体重统计：当前 = 末点；本周 = 末点 − 次末点；累计 = 契约常量。
    static func makeStats(from weekly: [WeightSample]) -> WeightStats? {
        guard let last = weekly.last else { return nil }
        let current = last.kg.rounded(toPlaces: 1)
        let weeklyDelta: Double = weekly.count >= 2
            ? (last.kg - weekly[weekly.count - 2].kg).rounded(toPlaces: 1)
            : 0
        return WeightStats(current: current,
                           weeklyDelta: weeklyDelta,
                           cumulativeChange: HomeMetricContract.cumulativeWeightChange)
    }

    /// Hero 卡周趋势 sparkline 取尾段（近 8 周）。
    var sparkline: [WeightSample] { Array(weeklyWeights.suffix(8)) }

    // MARK: - 圆环指标（契约值）
    var sleepHours: Double { HomeMetricContract.avgSleepHours }
    var exerciseMinutes: Int { HomeMetricContract.dailyExerciseMinutes }
    var exerciseKcal: Int { HomeMetricContract.dailyExerciseKcal }
}
