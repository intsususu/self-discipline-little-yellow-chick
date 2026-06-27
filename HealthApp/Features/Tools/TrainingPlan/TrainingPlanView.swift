// TrainingPlanView.swift
// 小工具 · 训练计划：动作库（过渡版）。
// TP01 数据层完成后的最小可用界面：分类切换 + 动作列表，验证新数据。
// 完整界面（搜索/解剖图入口/类型筛选/详情跳转）见 docs/tasks/训练计划重构/TP02、TP03。

import SwiftUI

struct TrainingPlanView: View {
    @State private var selectedCategory: MuscleCategory = .back

    private let categories = MuscleCategory.allCases

    private var exercises: [Exercise] {
        TrainingPlanData.exercises(in: selectedCategory)
    }

    var body: some View {
        VStack(spacing: 0) {
            categoryTabs
                .padding(.vertical, 8)

            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 8) {
                        Color.clear.frame(height: 0).id("top")

                        ForEach(exercises) { exercise in
                            ExerciseCard(exercise: exercise, accent: accent)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                }
                .onChange(of: selectedCategory) { _, _ in
                    withAnimation(.easeInOut(duration: 0.2)) {
                        proxy.scrollTo("top", anchor: .top)
                    }
                }
            }

            disclaimer
        }
        .background(Color.appBg.ignoresSafeArea())
        .navigationTitle("训练计划")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - 分类切换

    private var categoryTabs: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(categories) { category in
                    pill(
                        title: "\(category.displayName) \(TrainingPlanData.exercises(in: category).count)",
                        selected: category == selectedCategory
                    ) {
                        guard category != selectedCategory else { return }
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedCategory = category
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
        }
    }

    private func pill(title: String, selected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(selected ? .white : .textSecondary)
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .background(selected ? Color.brandBlue : Color.cardBg)
                .clipShape(Capsule())
                .overlay(
                    Capsule().stroke(Color.hairline, lineWidth: selected ? 0 : 1)
                )
        }
        .buttonStyle(.plain)
    }

    // MARK: - 页脚

    private var disclaimer: some View {
        Text("训练动作仅供参考，请量力而行，必要时在专业指导下进行")
            .font(.system(size: 11, weight: .medium))
            .foregroundColor(.textMuted)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color.cardBg)
            .overlay(alignment: .top) {
                Rectangle().fill(Color.hairline).frame(height: 1)
            }
    }

    private var accent: Color {
        switch selectedCategory {
        case .back:       return .brandBlue
        case .chest:      return .successGreen
        case .lower:      return .exerciseOrange
        case .shoulders:  return .sleepIndigo
        default:          return .brandBlue
        }
    }
}

#Preview {
    NavigationStack {
        TrainingPlanView()
    }
}
