// SleepView.swift
// 睡眠时长、效率、阶段分解与事件影响。PRD §5.3。

import SwiftUI

struct SleepView: View {
    @EnvironmentObject private var appState: AppState
    @State private var selectedRange: SleepRange = .week
    @State private var dailySamples: [SleepSample] = []
    @State private var isLoading = false
    @State private var showsEvents = true
    /// 趋势图可视窗口前沿（leading edge）；随手势更新，驱动事件图例过滤。
    @State private var scrollPosition = Date()
    /// 在图上点选的事件；非空且事件开关打开时，图下方展示其详情。
    @State private var selectedEvent: HealthEvent?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 14) {
                    rangePicker
                    trendChartCard
                    eventDetailCard
                    summaryCard
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .animation(.easeInOut(duration: 0.2), value: selectedEvent)
            }
            .background(Color.appBg.ignoresSafeArea())
            .toolbar(.hidden, for: .navigationBar)
            .task(id: selectedRange) {
                selectedEvent = nil
                await loadSamples()
                resetScrollToLatest()
            }
            .onChange(of: showsEvents) { isOn in
                if !isOn { selectedEvent = nil }
            }
        }
    }

    private var rangePicker: some View {
        Picker("时间范围", selection: $selectedRange) {
            ForEach(SleepRange.allCases) { range in
                Text(range.label).tag(range)
            }
        }
        .pickerStyle(.segmented)
        .tint(.sleepIndigo)
        .accessibilityLabel("睡眠时间范围")
    }

    // MARK: - 近 14 天平均指标卡片

    private var summaryCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionTitle("近 14 天平均")

            longMetricCard(title: "平均每晚睡眠",
                           value: avgHoursText, unit: "小时",
                           detail: "近 14 晚平均时长",
                           color: .sleepIndigo,
                           prominent: true)
            longMetricCard(title: "深度睡眠",
                           value: "\(avgDeepMinutes)", unit: "分钟",
                           detail: "占比约 \(deepShareText)",
                           color: .sleepDeep)
            longMetricCard(title: "清醒",
                           value: "\(avgAwakeMinutes)", unit: "分钟",
                           detail: "约 \(Self.avgAwakeCount) 次/晚",
                           color: .sleepAwake)
            longMetricCard(title: "入睡时间",
                           value: Self.avgBedtime, unit: "",
                           detail: "平均上床",
                           color: .sleepCore)
            longMetricCard(title: "起床时间",
                           value: Self.avgWakeTime, unit: "",
                           detail: "平均醒来",
                           color: .sleepREM)
        }
    }

    private func longMetricCard(title: String,
                                value: String,
                                unit: String,
                                detail: String,
                                color: Color,
                                prominent: Bool = false) -> some View {
        CardView(background: color.opacity(0.06), padding: 14) {
            HStack(spacing: 14) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: prominent ? 14 : 13, weight: .semibold))
                        .foregroundColor(.textPrimary)
                    Text(detail)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.textSecondary)
                }
                Spacer(minLength: 12)
                HStack(alignment: .firstTextBaseline, spacing: 3) {
                    Text(value)
                        .font(.system(size: prominent ? 30 : 24, weight: .heavy))
                        .foregroundColor(color)
                    if !unit.isEmpty {
                        Text(unit)
                            .font(.system(size: prominent ? 13 : 11, weight: .semibold))
                            .foregroundColor(color.opacity(0.82))
                    }
                }
                .lineLimit(1)
                .minimumScaleFactor(0.75)
            }
        }
    }

    // MARK: - 近 14 天派生指标

    /// 最近 14 晚样本。
    private var last14: [SleepSample] { Array(dailySamples.suffix(14)) }

    /// 平均每晚睡眠时长（小时，保留 1 位）。
    private var avgTotalHours: Double {
        guard !last14.isEmpty else { return 0 }
        return last14.map(\.totalHours).reduce(0, +) / Double(last14.count)
    }

    private var avgHoursText: String { String(format: "%.1f", avgTotalHours) }

    /// 平均深度睡眠时长（分钟，四舍五入）。
    private var avgDeepMinutes: Int { averageMinutes(\.deepMinutes) }

    /// 平均清醒时长（分钟，四舍五入）。
    private var avgAwakeMinutes: Int { averageMinutes(\.awakeMinutes) }

    private func averageMinutes(_ keyPath: KeyPath<SleepSample, Int?>) -> Int {
        let values = last14.compactMap { $0[keyPath: keyPath] }
        guard !values.isEmpty else { return 0 }
        return Int((Double(values.reduce(0, +)) / Double(values.count)).rounded())
    }

    /// 深睡占总睡眠的比例文案。
    private var deepShareText: String {
        let totalMinutes = avgTotalHours * 60
        guard totalMinutes > 0 else { return "—" }
        return "\(Int((Double(avgDeepMinutes) / totalMinutes * 100).rounded()))%"
    }

    // 数据模型未记录上床/起床时刻与夜醒次数，沿用高保真原型的代表值（参见 hybrid 派生策略）。
    private static let avgAwakeCount = 8
    private static let avgBedtime = "23:42"
    private static let avgWakeTime = "06:58"

    // MARK: - 趋势图卡片

    private var trendChartCard: some View {
        CardView(background: .sleepCardBg) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("睡眠趋势")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.textPrimary)
                    Spacer()
                    Toggle(isOn: $showsEvents) {
                        Text("事件")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.textSecondary)
                            .padding(.vertical, 6)
                            .padding(.trailing, 4)
                            .contentShape(Rectangle())
                    }
                    .tint(.sleepIndigo)
                    .fixedSize()
                    .accessibilityLabel("在图上显示事件")
                }

                if isLoading && dailySamples.isEmpty {
                    ProgressView().frame(maxWidth: .infinity, minHeight: 210)
                } else if dailySamples.isEmpty {
                    Text("暂无睡眠数据")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.textSecondary)
                        .frame(maxWidth: .infinity, minHeight: 210)
                } else {
                    SleepChart(dailySamples: dailySamples,
                               weeklyAverages: weeklyAverages,
                               events: appState.events,
                               showsEvents: showsEvents,
                               range: selectedRange,
                               scrollPosition: $scrollPosition,
                               selectedEvent: $selectedEvent)
                        .frame(height: 210)
                        .animation(.easeInOut(duration: 0.25), value: selectedRange)
                        .animation(.easeInOut(duration: 0.2), value: showsEvents)
                }

                legend
            }
        }
    }

    @ViewBuilder
    private var legend: some View {
        if selectedRange.isWeeklyAverage {
            HStack(spacing: 14) {
                lineLegend(color: .sleepIndigo, title: "周平均时长")
                if showsEvents { eventLegend }
            }
        } else if showsEvents {
            // 阶段标签已并入图形本身，底部仅保留事件图例。
            eventLegend
        }
    }

    private func lineLegend(color: Color, title: String) -> some View {
        HStack(spacing: 5) {
            Rectangle()
                .fill(color)
                .frame(width: 16, height: 2)
            Text(title)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.textSecondary)
        }
    }

    @ViewBuilder
    private var eventLegend: some View {
        let types = windowEventTypes
        if !types.isEmpty {
            HStack(spacing: 9) {
                ForEach(types, id: \.self) { type in
                    HStack(spacing: 3) {
                        RoundedRectangle(cornerRadius: 1)
                            .fill(type.color)
                            .frame(width: 7, height: 7)
                            .rotationEffect(.degrees(45))
                        Text(legendTitle(for: type))
                            .font(.system(size: 9, weight: .medium))
                            .foregroundColor(.textSecondary)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    /// 事件详情：仅当事件开关打开、且在图上点选了某个事件时展示。
    @ViewBuilder
    private var eventDetailCard: some View {
        if showsEvents, let event = selectedEvent {
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: event.type.sfSymbol)
                    .foregroundColor(event.type.color)
                    .padding(.top, 1)
                VStack(alignment: .leading, spacing: 3) {
                    Text("\(Self.eventDateText(for: event)) · \(event.title)")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.textPrimary)
                    if !event.note.isEmpty {
                        Text(event.note)
                            .font(.system(size: 12))
                            .foregroundColor(.textSecondary)
                    }
                }
                Spacer(minLength: 0)
                Button {
                    selectedEvent = nil
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(event.type.color.opacity(0.45))
                }
                .buttonStyle(.plain)
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(event.type.backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(event.type.color.opacity(0.22), lineWidth: 1)
            )
            .transition(.opacity.combined(with: .move(edge: .top)))
        }
    }

    // MARK: - 派生数据

    /// 由日级序列聚合成周平均睡眠时长（最近 26 周），供「6 个月」趋势使用。
    private var weeklyAverages: [DailyMetric] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: dailySamples) { sample -> Date in
            calendar.dateInterval(of: .weekOfYear, for: sample.date)?.start ?? sample.date
        }
        let weeks = grouped.map { weekStart, samples -> DailyMetric in
            let average = samples.map(\.totalHours).reduce(0, +) / Double(samples.count)
            return DailyMetric(date: weekStart, value: (average * 10).rounded() / 10)
        }
        .sorted { $0.date < $1.date }
        return Array(weeks.suffix(26))
    }

    /// 仅当前可视窗口内出现过的睡眠关联事件类型，按枚举顺序排列。
    private var windowEventTypes: [EventType] {
        let window = visibleWindow
        let present = Set(
            appState.events
                .filter { event in
                    guard event.type.isSleepRelated else { return false }
                    let end = event.endDate ?? event.startDate
                    return event.startDate <= window.upperBound && end >= window.lowerBound
                }
                .map(\.type)
        )
        return EventType.allCases.filter { present.contains($0) }
    }

    /// 当前趋势图可视窗口区间。「6 个月」无固定窗口，返回周均序列整段区间。
    private var visibleWindow: ClosedRange<Date> {
        guard let seconds = selectedRange.visibleDomainSeconds else {
            let dates = weeklyAverages.map(\.date)
            let first = dates.first ?? Date()
            return first...(dates.last ?? first)
        }
        return scrollPosition...scrollPosition.addingTimeInterval(seconds)
    }

    private func legendTitle(for type: EventType) -> String {
        switch type {
        case .injury, .travel: return "\(type.label)(段)"
        default: return type.label
        }
    }

    /// 切换范围或重载后，把窗口对齐到最新一段（右端贴齐最后样本）。
    private func resetScrollToLatest() {
        guard let last = dailySamples.map(\.date).max(),
              let seconds = selectedRange.visibleDomainSeconds else { return }
        scrollPosition = last.addingTimeInterval(-seconds)
    }

    private static let eventDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "M月d日"
        return formatter
    }()

    private static func eventDateText(for event: HealthEvent) -> String {
        let start = eventDateFormatter.string(from: event.startDate)
        guard let endDate = event.endDate else { return start }
        return "\(start)–\(eventDateFormatter.string(from: endDate))"
    }

    private func loadSamples() async {
        isLoading = true
        dailySamples = await appState.repository.sleepSeries(range: selectedRange.dataRange)
        isLoading = false
    }
}
