// SelfDisciplineView.swift
// 自律打卡 App 内页面：默认月历视图展示当月每天三项打卡状态，点击日期可编辑历史打卡。
// 数据走共享 CheckInStore（App Group），与 Widget 互通。

import SwiftUI
import WidgetKit

struct SelfDisciplineView: View {
    private let store = CheckInStore()
    private let calendar = SelfDisciplineSchedule.calendar
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 6), count: 7)
    private let autoExerciseThresholdMinutes = 30

    @State private var visibleMonth: Date
    @State private var selectedDay: Date
    @State private var draftStates: [CheckInTask: Bool] = [:]
    @State private var autoExerciseDays: Set<Date> = []
    @State private var recordKeys: Set<CheckInRecordKey> = []
    /// 每次写入后自增以触发重算（CheckInStore 为值类型，无自动发布）。
    @State private var revision = 0
    @Environment(\.scenePhase) private var scenePhase
    @EnvironmentObject private var appState: AppState

    init(now: Date = Date()) {
        let day = SelfDisciplineSchedule.effectiveDay(for: now)
        _selectedDay = State(initialValue: day)
        _visibleMonth = State(initialValue: Self.startOfMonth(for: day))
    }

    private var today: Date {
        _ = revision
        return SelfDisciplineSchedule.effectiveDay(for: Date(), calendar: calendar)
    }

    private var selectedCompletedCount: Int {
        CheckInTask.allCases.filter { draftStates[$0] == true }.count
    }

    private var isSelectedToday: Bool {
        calendar.isDate(selectedDay, inSameDayAs: today)
    }

    private var showsFatigueWarning: Bool {
        SelfDisciplineSchedule.activeTask(at: Date(), calendar: calendar) == .exercise
            && weeklyCount(.exercise, weekContaining: today) > CheckInStore.exerciseFatigueThreshold
    }

    private var monthTitle: String {
        let comps = calendar.dateComponents([.year, .month], from: visibleMonth)
        return "\(comps.year ?? 0)年\(comps.month ?? 1)月"
    }

    private var selectedDayTitle: String {
        isSelectedToday ? "今日打卡" : "\(monthDayText(selectedDay))打卡"
    }

    private var selectedDayMeta: String {
        "\(weekdayText(selectedDay)) · 已完成 \(selectedCompletedCount)/3"
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                summaryCard
                monthCalendarCard
                dayEditorCard
                rulesCard
            }
            .padding(16)
        }
        .background(Color.appBg.ignoresSafeArea())
        .navigationTitle("自律打卡")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: selectToday) {
                    Text("今天")
                        .font(.system(size: 14, weight: .bold))
                }
            }
        }
        .onAppear {
            reloadRecordsAndDraft()
        }
        .task {
            await syncAutoExerciseCheckIns()
        }
        .onChange(of: selectedDay) { _ in
            loadDraft()
        }
        .onChange(of: scenePhase) { phase in
            if phase == .active {
                revision += 1
                loadDraft()
                Task { await syncAutoExerciseCheckIns() }
            }
        }
    }

    // MARK: - 顶部摘要

    private var summaryCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(selectedDayTitle)
                        .font(.system(size: 18, weight: .heavy))
                        .foregroundColor(.textPrimary)
                    Text(selectedDayMeta)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.textSecondary)
                }
                Spacer()
                CheckInProgressRing(completed: selectedCompletedCount, total: CheckInTask.allCases.count)
            }

            if isSelectedToday, showsFatigueWarning {
                Label(SelfDisciplineSnapshot.fatigueMessage, systemImage: "exclamationmark.triangle.fill")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.warningAmber)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 9)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.warningAmber.opacity(0.12), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
            }

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 3), spacing: 8) {
                ForEach(CheckInTask.allCases) { task in
                    let isAuto = isAutoExercise(task, on: selectedDay)
                    CheckInTaskChip(task: task,
                                    isChecked: draftStates[task] == true,
                                    detailText: isAuto ? "自动完成" : nil) {
                        setTask(task, checked: !(draftStates[task] ?? false))
                    }
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(Color.cardBg, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    // MARK: - 月历

    private var monthCalendarCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text(monthTitle)
                    .font(.system(size: 17, weight: .heavy))
                    .foregroundColor(.textPrimary)
                Spacer()
                HStack(spacing: 6) {
                    monthButton(systemName: "chevron.left") { moveMonth(by: -1) }
                    monthButton(systemName: "chevron.right") { moveMonth(by: 1) }
                }
            }

            LazyVGrid(columns: columns, spacing: 6) {
                ForEach(Self.weekdaySymbols, id: \.self) { symbol in
                    Text(symbol)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.textMuted)
                        .frame(maxWidth: .infinity)
                }

                ForEach(monthDays(for: visibleMonth)) { day in
                    CheckInMonthDayCell(
                        date: day.date,
                        isInVisibleMonth: day.isInVisibleMonth,
                        isToday: calendar.isDate(day.date, inSameDayAs: today),
                        isSelected: calendar.isDate(day.date, inSameDayAs: selectedDay),
                        states: states(on: day.date),
                        dayNumber: calendar.component(.day, from: day.date)
                    ) {
                        select(day.date)
                    }
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(Color.cardBg, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private func monthButton(systemName: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 12, weight: .heavy))
                .foregroundColor(.textPrimary)
                .frame(width: 30, height: 30)
                .background(Color.appBg, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    // MARK: - 日期编辑

    private var dayEditorCard: some View {
        VStack(alignment: .leading, spacing: 13) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 3) {
                    Text("\(monthDayText(selectedDay)) · \(weekdayText(selectedDay))")
                        .font(.system(size: 16, weight: .heavy))
                        .foregroundColor(.textPrimary)
                    Text(isSelectedToday ? "今天" : "历史打卡")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.textSecondary)
                }
                Spacer()
                Text("\(selectedCompletedCount)/\(CheckInTask.allCases.count)")
                    .font(.system(size: 12, weight: .heavy))
                    .foregroundColor(selectedCompletedCount == CheckInTask.allCases.count ? .checkInCompletePink : .successGreen)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.successGreen.opacity(0.10), in: Capsule())
            }

            VStack(spacing: 8) {
                ForEach(CheckInTask.allCases) { task in
                    CheckInEditorRow(
                        task: task,
                        detailText: isAutoExercise(task, on: selectedDay) ? "主动运动 ≥30 分钟" : nil,
                        isChecked: Binding(
                            get: { draftStates[task] ?? false },
                            set: { setTask(task, checked: $0) }
                        )
                    )
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(Color.cardBg, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    // MARK: - 规则说明

    private var rulesCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("打卡时段")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.textPrimary)
            ForEach(CheckInTask.allCases) { task in
                HStack(spacing: 8) {
                    Image(systemName: task.iconName)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(task.tint)
                        .frame(width: 18)
                    Text(task.title)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.textPrimary)
                    Spacer()
                    Text(task.windowText)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.textSecondary)
                }
            }
            Text("运动每周超过 5 次，运动时段将提示「注意疲劳管理」。")
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.textMuted)
                .padding(.top, 2)
            Text("当天主动运动时长满 30 分钟，会自动完成「运动」打卡；未记录到运动时也可手动补打卡。")
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.textMuted)
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(Color.cardBg, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    // MARK: - Actions

    private func loadDraft() {
        draftStates = states(on: selectedDay)
    }

    private func reloadRecordsAndDraft(autoDays: Set<Date>? = nil) {
        let keys = Self.recordKeys(from: store.load(), calendar: calendar)
        recordKeys = keys
        draftStates = states(on: selectedDay, using: keys, autoDays: autoDays)
    }

    private func setTask(_ task: CheckInTask, checked: Bool) {
        guard !(task == .exercise && isAutoExercise(task, on: selectedDay) && !checked) else {
            draftStates[task] = true
            return
        }
        guard draftStates[task] != checked else { return }
        draftStates[task] = checked
        let key = CheckInRecordKey(day: normalizedDay(selectedDay), task: task)
        var keys = recordKeys
        if checked {
            keys.insert(key)
        } else {
            keys.remove(key)
        }
        recordKeys = keys
        store.set(task, checked: checked, on: selectedDay)
        revision += 1
        WidgetCenter.shared.reloadAllTimelines()
    }

    private func syncAutoExerciseCheckIns() async {
        let samples = await appState.repository.exerciseMinutesDailyTrend()
        let days = Set(samples.compactMap { sample -> Date? in
            guard sample.value >= Double(autoExerciseThresholdMinutes) else { return nil }
            return normalizedDay(sample.date)
        })
        let changed = store.set(.exercise, checked: true, on: days)
        autoExerciseDays = days
        revision += 1
        reloadRecordsAndDraft(autoDays: days)
        if changed {
            WidgetCenter.shared.reloadAllTimelines()
        }
    }

    private func selectToday() {
        select(today)
    }

    private func select(_ day: Date) {
        let normalized = calendar.startOfDay(for: day)
        selectedDay = normalized
        visibleMonth = Self.startOfMonth(for: normalized)
    }

    private func moveMonth(by value: Int) {
        guard let month = calendar.date(byAdding: .month, value: value, to: visibleMonth) else { return }
        visibleMonth = Self.startOfMonth(for: month)
        selectedDay = visibleMonth
    }

    // MARK: - Date helpers

    private func monthDays(for month: Date) -> [CheckInCalendarDay] {
        let firstDay = Self.startOfMonth(for: month)
        let weekday = calendar.component(.weekday, from: firstDay)
        let offset = (weekday + 5) % 7
        guard let gridStart = calendar.date(byAdding: .day, value: -offset, to: firstDay) else { return [] }

        return (0..<42).compactMap { index in
            guard let date = calendar.date(byAdding: .day, value: index, to: gridStart) else { return nil }
            return CheckInCalendarDay(
                date: calendar.startOfDay(for: date),
                isInVisibleMonth: calendar.isDate(date, equalTo: firstDay, toGranularity: .month)
            )
        }
    }

    private func states(on day: Date,
                        using keys: Set<CheckInRecordKey>? = nil,
                        autoDays: Set<Date>? = nil) -> [CheckInTask: Bool] {
        let dayKey = normalizedDay(day)
        let sourceKeys = keys ?? recordKeys
        let sourceAutoDays = autoDays ?? autoExerciseDays
        return Dictionary(uniqueKeysWithValues: CheckInTask.allCases.map { task in
            let checked = sourceKeys.contains(CheckInRecordKey(day: dayKey, task: task))
                || (task == .exercise && sourceAutoDays.contains(dayKey))
            return (task, checked)
        })
    }

    private func isAutoExercise(_ task: CheckInTask, on day: Date) -> Bool {
        task == .exercise && autoExerciseDays.contains(normalizedDay(day))
    }

    private func weeklyCount(_ task: CheckInTask, weekContaining day: Date) -> Int {
        guard let interval = calendar.dateInterval(of: .weekOfYear, for: day) else { return 0 }
        return recordKeys.filter { key in
            key.task == task && interval.contains(key.day)
        }.count
    }

    private func normalizedDay(_ date: Date) -> Date {
        calendar.startOfDay(for: date)
    }

    private func monthDayText(_ date: Date) -> String {
        let comps = calendar.dateComponents([.month, .day], from: date)
        return "\(comps.month ?? 1)月\(comps.day ?? 1)日"
    }

    private func weekdayText(_ date: Date) -> String {
        Self.weekdayText[calendar.component(.weekday, from: date) - 1]
    }

    private static func startOfMonth(for date: Date) -> Date {
        let calendar = SelfDisciplineSchedule.calendar
        let comps = calendar.dateComponents([.year, .month], from: date)
        return calendar.date(from: comps) ?? calendar.startOfDay(for: date)
    }

    private static func recordKeys(from records: [CheckInRecord],
                                   calendar: Calendar) -> Set<CheckInRecordKey> {
        Set(records.map { CheckInRecordKey(day: calendar.startOfDay(for: $0.day), task: $0.task) })
    }

    private static let weekdaySymbols = ["一", "二", "三", "四", "五", "六", "日"]
    private static let weekdayText = ["周日", "周一", "周二", "周三", "周四", "周五", "周六"]
}

private struct CheckInRecordKey: Hashable {
    let day: Date
    let task: CheckInTask
}

private struct CheckInCalendarDay: Identifiable {
    let date: Date
    let isInVisibleMonth: Bool

    var id: Date { date }
}

private struct CheckInProgressRing: View {
    let completed: Int
    let total: Int

    private var progress: CGFloat {
        guard total > 0 else { return 0 }
        return CGFloat(completed) / CGFloat(total)
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.hairline, lineWidth: 7)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(Color.brandBlue, style: StrokeStyle(lineWidth: 7, lineCap: .round))
                .rotationEffect(.degrees(-90))
            Text("\(completed)/\(total)")
                .font(.system(size: 12, weight: .heavy))
                .foregroundColor(.textPrimary)
        }
        .frame(width: 54, height: 54)
    }
}

private struct CheckInTaskChip: View {
    let task: CheckInTask
    let isChecked: Bool
    var detailText: String?
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 6) {
                Text(task.title)
                    .font(.system(size: 12, weight: .heavy))
                    .foregroundColor(isChecked ? .white : .textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.82)
                Text(detailText ?? (isChecked ? "已完成" : task.windowText))
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(isChecked ? .white.opacity(0.82) : .textSecondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.78)
            }
            .frame(maxWidth: .infinity, minHeight: 52, alignment: .leading)
            .padding(.horizontal, 7)
            .padding(.vertical, 8)
            .background(isChecked ? task.tint : Color.appBg.opacity(0.65),
                        in: RoundedRectangle(cornerRadius: 13, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 13, style: .continuous)
                    .stroke(isChecked ? Color.clear : Color.hairline, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

private struct CheckInMonthDayCell: View {
    let date: Date
    let isInVisibleMonth: Bool
    let isToday: Bool
    let isSelected: Bool
    let states: [CheckInTask: Bool]
    let dayNumber: Int
    let action: () -> Void

    private var completedCount: Int {
        CheckInTask.allCases.filter { states[$0] == true }.count
    }

    private var dayNumberColor: Color {
        if completedCount == CheckInTask.allCases.count {
            return .white
        }
        return completedCount == 0 ? .textSecondary : .textPrimary
    }

    private var cellBackground: Color {
        isToday ? Color.brandBlue.opacity(0.08) : Color.appBg.opacity(0.65)
    }

    private var cellStroke: Color {
        if isSelected {
            return .brandBlue
        }
        return isToday ? Color.brandBlue.opacity(0.35) : .clear
    }

    private var cellStrokeWidth: CGFloat {
        isSelected ? 2 : (isToday ? 1 : 0)
    }

    var body: some View {
        Button(action: action) {
            VStack(spacing: 0) {
                Text("\(dayNumber)")
                    .font(.system(size: 12, weight: .heavy))
                    .foregroundColor(dayNumberColor)
                    .frame(width: 22, height: 21)
                    .background(
                        Group {
                            if completedCount == CheckInTask.allCases.count {
                                RoundedRectangle(cornerRadius: 9, style: .continuous)
                                    .fill(Color.checkInCompletePink)
                            }
                        }
                    )

                Spacer(minLength: 4)

                HStack(spacing: 3) {
                    ForEach(CheckInTask.allCases) { task in
                        Circle()
                            .fill(states[task] == true ? task.tint : task.tint.opacity(0.16))
                            .frame(width: 6, height: 6)
                    }
                }
                .frame(minHeight: 16)
            }
            .padding(.top, 6)
            .padding(.bottom, 5)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(cellBackground, in: RoundedRectangle(cornerRadius: 13, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 13, style: .continuous)
                    .stroke(cellStroke, lineWidth: cellStrokeWidth)
            )
            .opacity(isInVisibleMonth ? 1 : 0.34)
        }
        .buttonStyle(.plain)
    }
}

private struct CheckInEditorRow: View {
    let task: CheckInTask
    var detailText: String?
    @Binding var isChecked: Bool

    var body: some View {
        HStack(spacing: 10) {
            Circle()
                .fill(task.tint)
                .frame(width: 11, height: 11)
            VStack(alignment: .leading, spacing: 2) {
                Text(task.title)
                    .font(.system(size: 13, weight: .heavy))
                    .foregroundColor(.textPrimary)
                Text(detailText ?? task.windowText)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.textSecondary)
            }
            Spacer()
            Toggle("", isOn: $isChecked)
                .labelsHidden()
                .tint(task.tint)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .frame(minHeight: 54)
        .background(Color.appBg, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.hairline, lineWidth: 1)
        )
    }
}

#Preview {
    NavigationStack { SelfDisciplineView() }
        .environmentObject(AppState(repository: MockHealthRepository()))
}
