// TrainingPlanView.swift
// 小工具 · 训练计划：四个部位的动作图解参考页。
// 见 docs/训练计划设计.md。本期只做本地图鉴，不做训练记录/计时/打卡。

import SwiftUI

struct TrainingPlanView: View {
    @State private var selectedPartIndex = 0

    private let parts = TrainingPlanData.parts
    private static let topAnchor = "trainingPlanTop"

    private var selectedPart: TrainingPart? {
        guard !parts.isEmpty else { return nil }
        return parts[min(selectedPartIndex, parts.count - 1)]
    }

    var body: some View {
        VStack(spacing: 0) {
            partTabs
                .padding(.top, 8)
                .padding(.bottom, 8)

            if let selectedPart {
                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(spacing: 12) {
                            Color.clear
                                .frame(height: 0)
                                .id(Self.topAnchor)

                            TrainingPartOverviewCard(
                                part: selectedPart,
                                accent: accent(for: selectedPartIndex),
                                symbolName: overviewSymbol(for: selectedPart.name),
                                imageCaption: overviewCaption(for: selectedPart.name)
                            )

                            ForEach(selectedPart.exercises) { exercise in
                                ExerciseCard(
                                    exercise: exercise,
                                    accent: accent(for: selectedPartIndex)
                                )
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 16)
                    }
                    .gesture(pageSwipeGesture)
                    .onChange(of: selectedPartIndex) { _, _ in
                        withAnimation(.easeInOut(duration: 0.2)) {
                            proxy.scrollTo(Self.topAnchor, anchor: .top)
                        }
                    }
                }
            } else {
                emptyState
            }

            disclaimer
        }
        .background(Color.appBg.ignoresSafeArea())
        .navigationTitle("训练计划")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - 部位切换

    private var partTabs: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(Array(parts.enumerated()), id: \.element.id) { index, part in
                    pill(
                        title: part.name,
                        selected: index == selectedPartIndex,
                        selectedColor: .brandBlue
                    ) {
                        guard index != selectedPartIndex else { return }
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedPartIndex = index
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
        }
    }

    private func pill(title: String, selected: Bool, selectedColor: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(selected ? .white : .textSecondary)
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .background(selected ? selectedColor : Color.cardBg)
                .clipShape(Capsule())
                .overlay(
                    Capsule().stroke(Color.hairline, lineWidth: selected ? 0 : 1)
                )
        }
        .buttonStyle(.plain)
    }

    private var pageSwipeGesture: some Gesture {
        DragGesture(minimumDistance: 28)
            .onEnded { value in
                let horizontal = value.translation.width
                let vertical = value.translation.height
                guard abs(horizontal) > abs(vertical), abs(horizontal) > 48 else { return }

                if horizontal < 0 {
                    moveToPart(offset: 1)
                } else {
                    moveToPart(offset: -1)
                }
            }
    }

    private func moveToPart(offset: Int) {
        let next = selectedPartIndex + offset
        guard parts.indices.contains(next) else { return }
        withAnimation(.easeInOut(duration: 0.2)) {
            selectedPartIndex = next
        }
    }

    // MARK: - 状态 / 页脚

    private var emptyState: some View {
        VStack(spacing: 10) {
            Image(systemName: "figure.strengthtraining.traditional")
                .font(.system(size: 36, weight: .light))
                .foregroundColor(.textMuted)
            Text("暂无训练内容")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.textPrimary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

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
                Rectangle()
                    .fill(Color.hairline)
                    .frame(height: 1)
            }
    }

    private func accent(for index: Int) -> Color {
        switch index {
        case 1: return .successGreen
        case 2: return .exerciseOrange
        case 3: return .sleepIndigo
        default: return .brandBlue
        }
    }

    private func overviewSymbol(for partName: String) -> String {
        switch partName {
        case "练腿": return "figure.run"
        case "练肩": return "figure.strengthtraining.traditional"
        default: return "figure.strengthtraining.traditional"
        }
    }

    private func overviewCaption(for partName: String) -> String {
        switch partName {
        case "练背": return "人体背面发力图"
        case "练胸": return "人体正面发力图"
        case "练腿", "练肩": return "人体正/背面发力图"
        default: return "整体肌肉发力图"
        }
    }
}

// MARK: - 部位概览

private struct TrainingPartOverviewCard: View {
    let part: TrainingPart
    let accent: Color
    let symbolName: String
    let imageCaption: String

    var body: some View {
        CardView {
            VStack(alignment: .leading, spacing: 12) {
                header
                muscleTags
                TrainingIllustrationView(
                    imageName: part.overviewImage,
                    title: imageCaption,
                    subtitle: "素材待补充",
                    systemImage: symbolName,
                    accent: accent,
                    aspectRatio: 16 / 9
                )
                Text(part.intro)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.textSecondary)
                    .lineSpacing(3)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var header: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(part.name)
                .font(.system(size: 22, weight: .heavy))
                .foregroundColor(.textPrimary)
            Spacer()
            Text("\(part.exercises.count) 个动作")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(accent)
                .padding(.horizontal, 9)
                .padding(.vertical, 5)
                .background(accent.opacity(0.12))
                .clipShape(Capsule())
        }
    }

    private var muscleTags: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                ForEach(part.targetMuscles, id: \.self) { muscle in
                    Text(muscle)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(accent)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 5)
                        .background(accent.opacity(0.1))
                        .clipShape(Capsule())
                }
            }
            .padding(.horizontal, 1)
        }
    }
}

#Preview {
    NavigationStack {
        TrainingPlanView()
    }
}
