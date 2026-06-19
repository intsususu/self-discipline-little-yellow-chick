// HealthDataRepository.swift
// 数据源协议（PRD §9.1）。视图层只依赖本协议，便于 Mock ↔ HealthKit 切换。

import Foundation

protocol HealthDataRepository: AnyObject {
    func weightSeries(range: TimeRange) async -> [WeightSample]
    func sleepSeries(range: TimeRange) async -> [SleepSample]
    func exerciseSeries(range: TimeRange) async -> [ExerciseSample]
    func events() async -> [HealthEvent]
    func saveEvent(_ event: HealthEvent) async
}
