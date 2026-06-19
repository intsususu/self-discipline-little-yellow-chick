// EventEditorView.swift
// E2 · 添加 / 编辑事件全局弹窗。PRD §5.8 / §4.2。
// event == nil 为新建；否则编辑既有事件（复用 id，保存即原地更新）。

import SwiftUI

struct EventEditorView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.dismiss) private var dismiss

    private let editingEvent: HealthEvent?

    @State private var type: EventType
    @State private var isPeriod: Bool
    @State private var startDate: Date
    @State private var endDate: Date
    @State private var title: String
    @State private var note: String

    init(event: HealthEvent? = nil) {
        self.editingEvent = event
        let defaultDate = HealthEvent.date("2026-06-18")
        _type = State(initialValue: event?.type ?? .illness)
        _isPeriod = State(initialValue: event?.isPeriod ?? false)
        _startDate = State(initialValue: event?.startDate ?? defaultDate)
        _endDate = State(initialValue: event?.endDate ?? event?.startDate ?? defaultDate)
        _title = State(initialValue: event?.title ?? "")
        _note = State(initialValue: event?.note ?? "")
    }

    private var isEditing: Bool { editingEvent != nil }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    typeSection
                    durationSection
                    dateSection
                    titleSection
                    noteSection
                    hintBanner
                }
                .padding(16)
            }
            .background(Color.appBg.ignoresSafeArea())
            .navigationTitle(isEditing ? "编辑事件" : "新建事件")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("取消") { dismiss() }
                        .tint(.brandBlue)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("保存") { save() }
                        .font(.system(size: 15, weight: .bold))
                        .tint(.brandBlue)
                }
            }
        }
        .environment(\.locale, Locale(identifier: "zh-Hans-CN"))
        .environment(\.calendar, Self.localizedCalendar)
    }

    // MARK: - 类型

    private var typeSection: some View {
        fieldGroup(title: "类型") {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())],
                      spacing: 10) {
                ForEach(EventType.allCases, id: \.self) { option in
                    typeChip(option)
                }
            }
        }
    }

    private func typeChip(_ option: EventType) -> some View {
        let selected = option == type
        return Button {
            type = option
        } label: {
            HStack(spacing: 6) {
                Image(systemName: editorSymbol(for: option))
                    .font(.system(size: 13, weight: .semibold))
                Text(editorLabel(for: option))
                    .font(.system(size: 14, weight: .semibold))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .foregroundColor(selected ? .white : option.color)
            .background(selected ? option.color : option.backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(option.color.opacity(selected ? 0 : 0.25), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.15), value: type)
    }

    private func editorLabel(for option: EventType) -> String {
        option == .injury ? "出差" : option.label
    }

    private func editorSymbol(for option: EventType) -> String {
        option == .injury ? "briefcase.fill" : option.sfSymbol
    }

    // MARK: - 持续切换

    private var durationSection: some View {
        fieldGroup(title: "持续时间") {
            Picker("持续时间", selection: $isPeriod) {
                Text("单日").tag(false)
                Text("时间段").tag(true)
            }
            .pickerStyle(.segmented)
        }
    }

    // MARK: - 日期

    private static let localizedCalendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale(identifier: "zh-Hans-CN")
        return calendar
    }()

    private var calendar: Calendar { Self.localizedCalendar }

    private var dateSection: some View {
        fieldGroup(title: isPeriod ? "起止日期" : "日期") {
            VStack(spacing: 0) {
                if isPeriod {
                    compactDatePicker("开始日期", selection: $startDate)
                        .onChange(of: startDate) { newValue in
                            if endDate < newValue { endDate = newValue }
                        }
                    Divider().background(Color.hairline)
                    compactDatePicker("结束日期", selection: $endDate, in: startDate...)
                    Divider().background(Color.hairline)
                    HStack {
                        Text("持续天数")
                        Spacer()
                        Text("共 \(periodDayCount) 天")
                            .fontWeight(.semibold)
                            .foregroundColor(.brandBlue)
                    }
                    .font(.system(size: 14))
                    .foregroundColor(.textSecondary)
                    .padding(.vertical, 10)
                } else {
                    compactDatePicker("选择日期", selection: $startDate)
                        .onChange(of: startDate) { newValue in
                            if endDate < newValue { endDate = newValue }
                        }
                }
            }
        }
    }

    private func compactDatePicker(_ label: String,
                                   selection: Binding<Date>) -> some View {
        DatePicker(selection: selection, displayedComponents: .date) {
            Text(label)
                .font(.system(size: 14))
                .foregroundColor(.textSecondary)
        }
        .datePickerStyle(.compact)
        .tint(.brandBlue)
        .padding(.vertical, 8)
    }

    private func compactDatePicker(_ label: String,
                                   selection: Binding<Date>,
                                   in range: PartialRangeFrom<Date>) -> some View {
        DatePicker(selection: selection, in: range, displayedComponents: .date) {
            Text(label)
                .font(.system(size: 14))
                .foregroundColor(.textSecondary)
        }
        .datePickerStyle(.compact)
        .tint(.brandBlue)
        .padding(.vertical, 8)
    }

    private var periodDayCount: Int {
        let from = calendar.startOfDay(for: startDate)
        let to = calendar.startOfDay(for: endDate)
        return (calendar.dateComponents([.day], from: from, to: to).day ?? 0) + 1
    }

    // MARK: - 标题 / 备注

    private var titleSection: some View {
        fieldGroup(title: "标题（可选）") {
            TextField(editorLabel(for: type), text: $title)
                .font(.system(size: 15))
                .foregroundColor(.textPrimary)
        }
    }

    private var noteSection: some View {
        fieldGroup(title: "备注") {
            TextField("添加描述，例如“感冒发烧，停训”…", text: $note, axis: .vertical)
                .font(.system(size: 15))
                .foregroundColor(.textPrimary)
                .lineLimit(3...6)
        }
    }

    private var hintBanner: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "info.circle.fill")
                .font(.system(size: 13))
                .foregroundColor(.brandBlue)
            Text("记录后会在体重/睡眠/运动图表上标注，帮你解释数据波动。")
                .font(.system(size: 12))
                .foregroundColor(.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.brandBlue.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    // MARK: - 组件

    private func fieldGroup<Content: View>(title: String,
                                           @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 9) {
            Text(title)
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(.textSecondary)
                .padding(.leading, 4)
            CardView { content() }
        }
    }

    // MARK: - 保存

    private func save() {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let event = HealthEvent(
            id: editingEvent?.id ?? UUID().uuidString,
            type: type,
            title: trimmedTitle.isEmpty ? editorLabel(for: type) : trimmedTitle,
            startDate: startDate,
            endDate: isPeriod ? max(endDate, startDate) : nil,
            note: note.trimmingCharacters(in: .whitespacesAndNewlines)
        )
        Task { await appState.saveEvent(event) }
        dismiss()
    }
}
