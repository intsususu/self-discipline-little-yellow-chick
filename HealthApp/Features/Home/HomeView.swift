// HomeView.swift
// Tab1 总览仪表盘（A1）。PRD §5.1。替换 T02 占位。

import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var appState: AppState
    @StateObject private var vm = HomeViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                topBar
                heroCard
                ringsCard
                insightCard
                recentEventsCard
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .background(Color.appBg.ignoresSafeArea())
        .task { await vm.load(from: appState.repository) }
    }

    // MARK: - 顶部栏

    private var topBar: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 2) {
                Text(Self.dateFormatter.string(from: Date()))
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.textSecondary)
                Text("\(Self.greeting)，今天")
                    .font(.system(size: 22, weight: .heavy))
                    .foregroundColor(.textPrimary)
            }
            Spacer()
            PillButton(title: "记事件", systemImage: "plus") {
                appState.presentEventEditor()
            }
        }
    }

    // MARK: - 体重 Hero 卡

    private var heroCard: some View {
        Button {
            appState.selectedTab = .weight
        } label: {
            CardView(background: .weightCardBg) {
                VStack(alignment: .leading, spacing: 12) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("当前体重")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.textSecondary)
                            HStack(alignment: .firstTextBaseline, spacing: 4) {
                                Text(Self.weightString(vm.stats?.current))
                                    .font(.system(size: 40, weight: .black))
                                    .foregroundColor(.brandBlue)
                                Text("kg")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.brandBlue.opacity(0.7))
                            }
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("本周 \(Self.deltaString(vm.stats?.weeklyDelta))")
                            Text("累计 \(Self.signedString(vm.stats?.cumulativeChange))")
                        }
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.successGreen)
                    }

                    WeightSparkline(samples: vm.sparkline)

                    HStack {
                        Text(goalText)
                            .font(.system(size: 13))
                            .foregroundColor(.textSecondary)
                        Spacer()
                        Text("查看趋势 ›")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.brandBlue)
                    }
                }
            }
        }
        .buttonStyle(.plain)
    }

    private var goalText: String {
        let goal = Int(appState.goalWeight.rounded())
        let dist = vm.stats?.distance(to: appState.goalWeight)
        return "距目标 \(goal)kg · 还差 \(Self.weightString(dist))kg"
    }

    // MARK: - 3 圆环指标卡

    private var ringsCard: some View {
        CardView {
            HStack(spacing: 0) {
                RingMetric(value: String(format: "%.1f", vm.sleepHours), unit: "h",
                           label: "睡眠", progress: vm.sleepHours / 8.0, color: .sleepIndigo)
                RingMetric(value: "\(vm.exerciseMinutes)", unit: "m",
                           label: "运动", progress: Double(vm.exerciseMinutes) / 90.0, color: .successGreen)
                RingMetric(value: "\(vm.exerciseKcal)", unit: "千卡",
                           label: "卡路里", progress: Double(vm.exerciseKcal) / 600.0, color: .exerciseOrange)
            }
        }
    }

    // MARK: - 关联洞察卡（虚线框）

    private var insightCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("本周亮点")
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(.textPrimary)
            Text("体重连续 4 周下降，运动负荷与睡眠时长同步走高 👍")
                .font(.system(size: 13))
                .foregroundColor(.textPrimary)
            Text("感冒发烧那周运动暂停，体重回升 0.6kg，恢复训练后已回落。")
                .font(.system(size: 13))
                .foregroundColor(.textSecondary)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.brandBlue.opacity(0.04))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(Color.brandBlue.opacity(0.4),
                              style: StrokeStyle(lineWidth: 1.5, dash: [5, 4]))
        )
    }

    // MARK: - 近期事件卡

    private var recentEventsCard: some View {
        CardView {
            VStack(alignment: .leading, spacing: 4) {
                SectionTitle(title: "近期事件") {
                    PillButton(title: "记录", systemImage: "plus", filled: false) {
                        appState.presentEventEditor()
                    }
                }
                .padding(.bottom, 4)

                if appState.events.isEmpty {
                    Text("暂无事件，点「记录」添加")
                        .font(.system(size: 13))
                        .foregroundColor(.textSecondary)
                        .padding(.vertical, 8)
                } else {
                    ForEach(Array(appState.events.prefix(4))) { event in
                        RecentEventRow(event: event)
                        if event.id != appState.events.prefix(4).last?.id {
                            Divider().background(Color.hairline)
                        }
                    }
                }
            }
        }
    }

    // MARK: - 格式化

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "zh_CN")
        f.dateFormat = "M月d日 EEEE"
        return f
    }()

    private static var greeting: String {
        switch Calendar.current.component(.hour, from: Date()) {
        case 0..<6:   return "夜深了"
        case 6..<12:  return "早上好"
        case 12..<14: return "中午好"
        case 14..<18: return "下午好"
        default:      return "晚上好"
        }
    }

    private static func weightString(_ value: Double?) -> String {
        guard let value else { return "--" }
        return String(format: "%.1f", value)
    }

    /// 本周变化：下降显示 ↓abs，上升显示 ↑abs。
    private static func deltaString(_ value: Double?) -> String {
        guard let value else { return "--" }
        let arrow = value <= 0 ? "↓" : "↑"
        return "\(arrow)\(String(format: "%.1f", abs(value)))"
    }

    /// 带符号显示，如 -13.9。
    private static func signedString(_ value: Double?) -> String {
        guard let value else { return "--" }
        return String(format: "%.1f", value)
    }
}
