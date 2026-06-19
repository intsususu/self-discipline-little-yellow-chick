// HealthDataRepository.swift
// 数据源协议（PRD §9.1）。视图层只依赖本协议，便于 Mock ↔ HealthKit 切换。

import Foundation

protocol HealthDataRepository: AnyObject {
    /// 请求数据源所需授权。Mock 为空操作，HealthKit 只申请读取权限。
    func requestAuthorization() async throws
    /// 首页指标卡当日数：当日睡眠时长 + 健身环锻炼分钟/活动热量及其目标。
    func homeRingMetrics() async -> HomeRingMetrics
    /// 首页睡眠卡：最近 30 日每日睡眠时长（小时）趋势。
    func sleepDurationTrend() async -> [DailyMetric]
    /// 首页运动卡：最近 30 日每日活动热量（千卡）趋势。
    func activeEnergyTrend() async -> [DailyMetric]
    func weightSeries(range: TimeRange) async -> [WeightSample]
    /// 最近 N 条体重测量原始记录（按日期降序）。
    func recentWeightRecords(limit: Int) async -> [WeightSample]
    /// 体重统计：当前 / 今年极值 / 历史极值 / 累计减少。
    func weightStatistics() async -> WeightStatistics
    func sleepSeries(range: TimeRange) async -> [SleepSample]
    func exerciseSeries(range: TimeRange) async -> [ExerciseSample]
    func events() async -> [HealthEvent]
    func saveEvent(_ event: HealthEvent) async
    func deleteEvent(_ event: HealthEvent) async
}
