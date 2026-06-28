// TrainingSearchView.swift
// 小工具 · 训练计划：搜索页（右上角搜索按钮进入）。文字搜索 + 点身体部位筛选。

import SwiftUI

struct TrainingSearchView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var profileStore = ProfileStore()

    @State private var searchText = ""
    @State private var selectedMuscle: MuscleGroup?

    private var isFemale: Bool { profileStore.profile.gender == .female }
    private var accent: Color { .exerciseOrange }

    private var keyword: String {
        searchText.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    private var isSearching: Bool { !keyword.isEmpty }

    private var strengthResults: [Exercise] {
        if isSearching { return TrainingPlanData.search(keyword) }
        if let muscle = selectedMuscle { return TrainingPlanData.exercises(for: muscle) }
        return []
    }
    private var stretchResults: [StretchMove] {
        isSearching ? StretchData.search(keyword) : []
    }
    private var hiitResults: [HIITMove] {
        isSearching ? HIITData.search(keyword) : []
    }

    private var totalCount: Int {
        strengthResults.count + stretchResults.count + hiitResults.count
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 14) {
                    searchField

                    if !isSearching {
                        bodyMapCard
                    }

                    if isSearching || selectedMuscle != nil {
                        resultSections
                    } else {
                        hintCard
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 24)
            }
            .background(Color.appBg.ignoresSafeArea())
            .navigationTitle("搜索动作")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("完成") { dismiss() }
                        .font(.system(size: 15, weight: .semibold))
                }
            }
        }
    }

    private var searchField: some View {
        HStack(spacing: 9) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.textMuted)

            TextField("搜索动作 / English", text: $searchText)
                .font(.system(size: 14, weight: .medium))
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)

            if !searchText.isEmpty {
                Button {
                    searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.textMuted)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color.cardBg)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Color.hairline, lineWidth: 1)
        )
    }

    private var bodyMapCard: some View {
        CardView {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("点身体部位筛选动作")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.textPrimary)
                        Text(selectedMuscle.map { "当前：\($0.displayName)" } ?? "轻点正面 / 背面肌群")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.textSecondary)
                    }
                    Spacer()
                    if let muscle = selectedMuscle {
                        ExerciseTag(title: "\(TrainingPlanData.exercises(for: muscle).count) 个动作",
                                    foreground: accent, background: accent.opacity(0.10))
                    }
                }

                MuscleBodyView(
                    highlighted: selectedMuscle.map { [$0] } ?? [],
                    onTap: { muscle in
                        withAnimation(.easeInOut(duration: 0.16)) {
                            selectedMuscle = (selectedMuscle == muscle) ? nil : muscle
                        }
                    },
                    accent: accent,
                    isFemale: isFemale
                )
                .frame(maxWidth: .infinity)
                .frame(height: 320)
            }
        }
    }

    private var hintCard: some View {
        VStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 22, weight: .semibold))
                .foregroundColor(.textMuted)
            Text("输入关键词，或点上方人体部位")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 28)
    }

    @ViewBuilder
    private var resultSections: some View {
        if totalCount == 0 {
            VStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(.textMuted)
                Text("没有匹配的动作")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.textSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 28)
            .background(Color.cardBg)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(Color.hairline, lineWidth: 1))
        } else {
            if !strengthResults.isEmpty {
                section(title: "力量训练", count: strengthResults.count) {
                    ForEach(strengthResults) { exercise in
                        NavigationLink {
                            ExerciseDetailView(exercise: exercise, isFemale: isFemale)
                        } label: {
                            ExerciseRow(exercise: exercise, accent: accent, isFemale: isFemale)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            if !stretchResults.isEmpty {
                section(title: "拉伸", count: stretchResults.count) {
                    ForEach(stretchResults) { move in
                        NavigationLink {
                            MoveDetailView(stretch: move)
                        } label: {
                            ExerciseRow(stretch: move, accent: accent, isFemale: isFemale)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            if !hiitResults.isEmpty {
                section(title: "HIIT", count: hiitResults.count) {
                    ForEach(hiitResults) { move in
                        NavigationLink {
                            MoveDetailView(move: move)
                        } label: {
                            ExerciseRow(hiit: move, accent: accent, isFemale: isFemale)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func section<Content: View>(title: String, count: Int, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionTitle(title: title) {
                Text("\(count) 个")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.textMuted)
            }
            LazyVStack(spacing: 8) { content() }
        }
    }
}

#Preview {
    TrainingSearchView()
}
