// SleepChart.swift
// 睡眠趋势图：
//   · 周 / 月 —— 每晚「深度 / 核心 / 快速眼动 / 清醒」四阶段堆积面积图，固定窗口横向滑动；
//   · 6 个月 —— 以周平均睡眠时长为单位的趋势折线（参考首页主题色样式）。
// 叠加事件：时间段色带、单日事件菱形，点选后常驻显示详情（与 WeightChart 一致）。

import Charts
import SwiftUI

/// 睡眠页时间范围。映射到数据层 `TimeRange` 取数，自身决定图表呈现方式。
enum SleepRange: String, CaseIterable, Identifiable {
    case week
    case month
    case sixMonths

    var id: String { rawValue }

    var label: String {
        switch self {
        case .week:      return "周"
        case .month:     return "月"
        case .sixMonths: return "6 个月"
        }
    }

    /// 取数范围：6 个月借「年」窗口拉取足量日级历史，再由视图聚合成周平均。
    var dataRange: TimeRange {
        switch self {
        case .week:      return .week
        case .month:     return .month
        case .sixMonths: return .year
        }
    }

    /// 可视窗口宽度（秒）。`nil` 表示不分页，一次展示全部（6 个月周均）。
    var visibleDomainSeconds: TimeInterval? {
        switch self {
        // N 个日级数据点首尾只跨 N - 1 天；按点跨度设置窗口，避免末端多出一个空档。
        case .week:      return 6 * 86_400
        case .month:     return 29 * 86_400
        case .sixMonths: return nil
        }
    }

    var isWeeklyAverage: Bool { self == .sixMonths }
}

struct SleepChart: View {
    /// 周 / 月堆积图数据源（日级，含阶段分解）。
    let dailySamples: [SleepSample]
    /// 6 个月趋势数据源（每点为一周平均睡眠时长，单位小时）。
    let weeklyAverages: [DailyMetric]
    let events: [HealthEvent]
    let showsEvents: Bool
    let range: SleepRange
    /// 可视窗口前沿；随手势更新，并驱动外部事件图例过滤。
    @Binding var scrollPosition: Date
    /// 在图上点选的事件（点击事件区域命中）。
    @Binding var selectedEvent: HealthEvent?

    @State private var selectedDate: Date?

    var body: some View {
        scrollable(
            Group {
                if range.isWeeklyAverage {
                    weeklyChart
                } else {
                    stackedChart
                }
            }
            .chartXSelection(value: $selectedDate)
            .chartXAxis {
                AxisMarks(values: axisStride) { value in
                    AxisGridLine().foregroundStyle(Color.hairline)
                    if let date = value.as(Date.self) {
                        AxisValueLabel(anchor: axisLabelAnchor(for: date)) {
                            Text(axisLabel(for: date))
                                .font(.system(size: 9, weight: .medium))
                                .foregroundColor(.textMuted)
                        }
                    }
                }
            }
            // 去掉默认左右留白；边缘标签通过锚点向绘图区内侧展开。
            .chartXScale(range: .plotDimension(padding: 0))
            .accessibilityLabel(range.isWeeklyAverage ? "周平均睡眠时长趋势" : "每晚睡眠阶段堆积图")
        )
        .onChange(of: selectedDate) { _, newDate in
            // 命中事件即选中并常驻；手势结束或点空白都不清空，只在关闭按钮/关掉开关时隐藏。
            guard showsEvents, let date = newDate, let hit = eventHit(at: date) else { return }
            selectedEvent = hit
        }
    }

    // MARK: - 周 / 月：阶段堆积面积图

    private var stackedChart: some View {
        let domain = stackedYDomain
        return Chart {
            eventBands(domain: domain)

            // 四阶段自下而上手动堆积：半透明渐变填充。
            ForEach(stageBands) { band in
                AreaMark(
                    x: .value("日期", band.date),
                    yStart: .value("下界", band.lower),
                    yEnd: .value("上界", band.upper),
                    series: .value("阶段", band.stage)
                )
                .foregroundStyle(band.gradient)
                .interpolationMethod(.catmullRom)
            }

            // 每段上沿描一条同色实线，强化层次质感。
            ForEach(stageBands) { band in
                LineMark(
                    x: .value("日期", band.date),
                    y: .value("上界", band.upper),
                    series: .value("阶段描边", band.stage)
                )
                .foregroundStyle(band.color.opacity(0.85))
                .lineStyle(StrokeStyle(lineWidth: 1.6, lineCap: .round, lineJoin: .round))
                .interpolationMethod(.catmullRom)
            }

            eventMarkers(domain: domain, yFor: { _ in domain.upperBound * 0.94 })
        }
        .chartLegend(.hidden)
        .chartYScale(domain: domain)
        .chartYAxis { hourAxis(decimals: 0) }
    }

    // MARK: - 6 个月：周平均时长趋势折线

    private var weeklyChart: some View {
        let domain = weeklyYDomain
        return Chart {
            eventBands(domain: domain)

            ForEach(sortedWeekly) { point in
                AreaMark(
                    x: .value("周", point.date),
                    yStart: .value("基线", domain.lowerBound),
                    yEnd: .value("时长", point.value)
                )
                .foregroundStyle(
                    LinearGradient(colors: [.sleepIndigo.opacity(0.24), .sleepIndigo.opacity(0.01)],
                                   startPoint: .top, endPoint: .bottom)
                )
                .interpolationMethod(.catmullRom)

                LineMark(
                    x: .value("周", point.date),
                    y: .value("时长", point.value)
                )
                .foregroundStyle(Color.sleepIndigo)
                .lineStyle(StrokeStyle(lineWidth: 2.6, lineCap: .round, lineJoin: .round))
                .interpolationMethod(.catmullRom)
            }

            if let last = sortedWeekly.last {
                PointMark(x: .value("周", last.date), y: .value("时长", last.value))
                    .foregroundStyle(Color.sleepIndigo)
                    .symbolSize(55)
            }

            eventMarkers(domain: domain, yFor: { nearestWeekly(to: $0) })
        }
        .chartYScale(domain: domain)
        .chartYAxis { hourAxis(decimals: 1) }
    }

    // MARK: - 事件叠加（两种模式共用）

    @ChartContentBuilder
    private func eventBands(domain: ClosedRange<Double>) -> some ChartContent {
        if showsEvents {
            ForEach(visibleEvents.filter(\.isPeriod)) { event in
                RectangleMark(
                    xStart: .value("事件开始", event.startDate),
                    xEnd: .value("事件结束", event.endDate ?? event.startDate),
                    yStart: .value("下界", domain.lowerBound),
                    yEnd: .value("上界", domain.upperBound)
                )
                .foregroundStyle(event.type.backgroundColor.opacity(0.7))
            }
        }
    }

    @ChartContentBuilder
    private func eventMarkers(domain: ClosedRange<Double>, yFor: @escaping (Date) -> Double) -> some ChartContent {
        if showsEvents {
            ForEach(visibleEvents.filter { !$0.isPeriod }) { event in
                PointMark(
                    x: .value("事件日期", event.startDate),
                    y: .value("事件位置", yFor(event.startDate))
                )
                .foregroundStyle(event.type.color)
                .symbol {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(event.type.color)
                        .frame(width: 10, height: 10)
                        .rotationEffect(.degrees(45))
                }
            }

            if let selected = selectedEvent {
                RuleMark(x: .value("选中事件", selected.startDate))
                    .foregroundStyle(selected.type.color.opacity(0.55))
                    .lineStyle(StrokeStyle(lineWidth: 1.5, dash: [4, 3]))
            }
        }
    }

    /// `decimals`：堆积图域跨度大用整点（0/2/4/6/8h），周均趋势域窄用一位小数避免取整重复。
    private func hourAxis(decimals: Int) -> some AxisContent {
        AxisMarks(position: .leading, values: .automatic(desiredCount: 4)) { value in
            AxisGridLine().foregroundStyle(Color.hairline)
            AxisValueLabel {
                if let hours = value.as(Double.self) {
                    Text(String(format: "%.\(decimals)fh", hours))
                        .font(.system(size: 9, weight: .medium))
                        .foregroundColor(.textMuted)
                }
            }
        }
    }

    // MARK: - 数据派生

    private var sortedSamples: [SleepSample] {
        dailySamples.sorted { $0.date < $1.date }
    }

    private var sortedWeekly: [DailyMetric] {
        weeklyAverages.sorted { $0.date < $1.date }
    }

    /// 堆积带：每晚四阶段自下而上的累计区间（小时）+ 配色。
    private var stageBands: [StageBand] {
        sortedSamples.flatMap { sample -> [StageBand] in
            let segments: [(String, Double, Color)] = [
                ("深度睡眠", minutes(sample.deepMinutes), .sleepDeep),
                ("核心睡眠", minutes(sample.coreMinutes), .sleepCore),
                ("快速眼动睡眠", minutes(sample.remMinutes), .sleepREM),
                ("清醒时间", minutes(sample.awakeMinutes), .sleepAwake),
            ]
            var lower = 0.0
            return segments.map { stage, value, color in
                defer { lower += value }
                return StageBand(date: sample.date, stage: stage,
                                 lower: lower, upper: lower + value, color: color)
            }
        }
    }

    private func minutes(_ value: Int?) -> Double { Double(value ?? 0) / 60.0 }

    /// 当前可视窗口区间；6 个月（无窗口）覆盖整段。
    private var visibleWindow: ClosedRange<Date> {
        guard let seconds = range.visibleDomainSeconds else {
            let dates = range.isWeeklyAverage ? sortedWeekly.map(\.date) : sortedSamples.map(\.date)
            let first = dates.first ?? Date()
            return first...max(first, dates.last ?? first)
        }
        return scrollPosition...scrollPosition.addingTimeInterval(seconds)
    }

    /// 堆积图 Y 域：按当前窗口内最高一晚总时长自适应（滑动时纵向重新取景）。
    private var stackedYDomain: ClosedRange<Double> {
        let window = visibleWindow
        let windowSamples = sortedSamples.filter { window.contains($0.date) }
        let base = windowSamples.isEmpty ? sortedSamples : windowSamples
        let maximum = base.map { Double($0.totalMinutes) / 60.0 }.max() ?? 8
        return 0...(maximum * 1.08)
    }

    /// 周均趋势 Y 域：贴合数据上下界并留白。
    private var weeklyYDomain: ClosedRange<Double> {
        let values = sortedWeekly.map(\.value)
        let minimum = values.min() ?? 6
        let maximum = values.max() ?? 8
        let padding = max((maximum - minimum) * 0.2, 0.4)
        return max(minimum - padding, 0)...(maximum + padding)
    }

    /// 落入当前数据时间跨度的事件。
    private var visibleEvents: [HealthEvent] {
        let dates = range.isWeeklyAverage ? sortedWeekly.map(\.date) : sortedSamples.map(\.date)
        guard let first = dates.first, let last = dates.last else { return [] }
        return events.filter { event in
            guard event.type.isSleepRelated else { return false }
            let eventEnd = event.endDate ?? event.startDate
            return event.startDate <= last && eventEnd >= first
        }
    }

    private func nearestWeekly(to date: Date) -> Double {
        sortedWeekly.min {
            abs($0.date.timeIntervalSince(date)) < abs($1.date.timeIntervalSince(date))
        }?.value ?? weeklyYDomain.upperBound
    }

    /// 点选日期映射到事件：优先命中时间段色带，其次就近命中单日事件。
    private func eventHit(at date: Date) -> HealthEvent? {
        if let period = visibleEvents.first(where: { event in
            guard let end = event.endDate else { return false }
            return date >= event.startDate && date <= end
        }) {
            return period
        }
        let span = range.visibleDomainSeconds ?? 26 * 7 * 86_400
        let tolerance = span * 0.12
        let nearest = visibleEvents
            .filter { !$0.isPeriod }
            .min { abs($0.startDate.timeIntervalSince(date)) < abs($1.startDate.timeIntervalSince(date)) }
        if let nearest, abs(nearest.startDate.timeIntervalSince(date)) <= tolerance {
            return nearest
        }
        return nil
    }

    // MARK: - 滚动与坐标轴

    /// 仅周 / 月启用横向滚动与固定窗口；6 个月一次展示完整周均趋势。
    @ViewBuilder
    private func scrollable(_ content: some View) -> some View {
        if let seconds = range.visibleDomainSeconds {
            content
                .chartScrollableAxes(.horizontal)
                .chartXVisibleDomain(length: seconds)
                .chartScrollPosition(x: $scrollPosition)
        } else {
            content
        }
    }

    private var axisStride: AxisMarkValues {
        switch range {
        case .week:      return .stride(by: .day)
        case .month:     return .stride(by: .day, count: 7)
        case .sixMonths: return .stride(by: .month)
        }
    }

    private func axisLabel(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        switch range {
        case .week:      formatter.dateFormat = "EEE"
        case .month:     formatter.dateFormat = "d日"
        case .sixMonths: formatter.dateFormat = "M月"
        }
        return formatter.string(from: date)
    }

    /// 边缘刻度改为向绘图区内侧展开，图形无需再为标签预留空白数据域。
    private func axisLabelAnchor(for date: Date) -> UnitPoint {
        let window = visibleWindow
        let tolerance: TimeInterval = 60
        if abs(date.timeIntervalSince(window.lowerBound)) <= tolerance { return .topLeading }
        if abs(date.timeIntervalSince(window.upperBound)) <= tolerance { return .topTrailing }
        return .top
    }

    private struct StageBand: Identifiable {
        let date: Date
        let stage: String
        let lower: Double
        let upper: Double
        let color: Color

        /// 图表滚动会频繁重算可视窗口；稳定 ID 避免 Swift Charts 将每个阶段误判成新数据。
        var id: ID { ID(date: date, stage: stage) }

        struct ID: Hashable {
            let date: Date
            let stage: String
        }

        var gradient: LinearGradient {
            LinearGradient(colors: [color.opacity(0.62), color.opacity(0.30)],
                           startPoint: .top, endPoint: .bottom)
        }
    }
}
