// MuscleMapView.swift
// 小工具 · 训练计划：按可点击人体肌群筛选动作。

import SwiftUI

struct MuscleMapView: View {
    @StateObject private var profileStore = ProfileStore()
    @State private var selectedMuscle: MuscleGroup = .upperBack

    private var isFemale: Bool {
        profileStore.profile.gender == .female
    }

    private var exercises: [Exercise] {
        TrainingPlanData.exercises(for: selectedMuscle)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                mapCard
                resultHeader
                resultList
                disclaimer
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 20)
        }
        .background(Color.appBg.ignoresSafeArea())
        .navigationTitle("解剖图选肌群")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var mapCard: some View {
        CardView {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("点身体部位筛选动作")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.textPrimary)
                        Text("当前：\(selectedMuscle.displayName)")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.textSecondary)
                    }
                    Spacer()
                    ExerciseTag(title: "\(exercises.count) 个动作",
                                foreground: .exerciseOrange,
                                background: Color.exerciseOrange.opacity(0.10))
                }

                MuscleBodyView(
                    highlighted: [selectedMuscle],
                    onTap: { muscle in
                        withAnimation(.easeInOut(duration: 0.16)) {
                            selectedMuscle = muscle
                        }
                    },
                    accent: .exerciseOrange,
                    isFemale: isFemale
                )
                .frame(maxWidth: .infinity)
                .frame(height: 320)
            }
        }
    }

    private var resultHeader: some View {
        SectionTitle(title: selectedMuscle.displayName) {
            Text(exercises.isEmpty ? "暂无" : "\(exercises.count) 个")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.textMuted)
        }
    }

    @ViewBuilder
    private var resultList: some View {
        if exercises.isEmpty {
            emptyState
        } else {
            LazyVStack(spacing: 8) {
                ForEach(exercises) { exercise in
                    NavigationLink {
                        ExerciseDetailView(exercise: exercise, isFemale: isFemale)
                    } label: {
                        ExerciseRow(exercise: exercise,
                                    accent: accent(for: exercise.category),
                                    isFemale: isFemale)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "figure.strengthtraining.traditional")
                .font(.system(size: 22, weight: .semibold))
                .foregroundColor(.textMuted)
            Text("该肌群暂无收录动作")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 28)
        .background(Color.cardBg)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.hairline, lineWidth: 1)
        )
    }

    private var disclaimer: some View {
        Text("训练动作仅供参考，请量力而行，必要时在专业指导下进行")
            .font(.system(size: 11, weight: .medium))
            .foregroundColor(.textMuted)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
            .padding(.top, 2)
    }

    private func accent(for category: MuscleCategory) -> Color {
        .exerciseOrange
    }
}

#Preview {
    NavigationStack {
        MuscleMapView()
    }
}
