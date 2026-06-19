// WeightViewModel.swift
// 体重页数据加载与派生统计。

import Foundation

@MainActor
final class WeightViewModel: ObservableObject {
    @Published private(set) var samples: [WeightSample] = []
    @Published private(set) var recentRecords: [WeightSample] = []
    @Published private(set) var statistics = WeightStatistics()
    @Published private(set) var isLoading = false

    private var hasLoadedSummary = false

    func loadInitialData(from repository: HealthDataRepository) async {
        guard !hasLoadedSummary else { return }
        hasLoadedSummary = true
        recentRecords = await repository.recentWeightRecords(limit: 5)
        statistics = await repository.weightStatistics()
    }

    func loadSeries(for range: TimeRange, from repository: HealthDataRepository) async {
        isLoading = true
        samples = await repository.weightSeries(range: range)
        isLoading = false
    }
}
