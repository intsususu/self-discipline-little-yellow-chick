// ExerciseCard.swift
// 小工具 · 训练计划：动作卡片与图片占位。

import SwiftUI
import UIKit

struct ExerciseCard: View {
    let exercise: Exercise
    let accent: Color

    var body: some View {
        CardView {
            VStack(alignment: .leading, spacing: 12) {
                images
                header
                muscleSummary
                Divider().background(Color.hairline)
                keyPoints
            }
        }
    }

    // MARK: - 图片

    private var images: some View {
        HStack(spacing: 8) {
            TrainingIllustrationView(
                imageName: exercise.equipImage,
                title: "器械/动作图",
                subtitle: exercise.name,
                systemImage: "figure.strengthtraining.traditional",
                accent: accent,
                aspectRatio: 4 / 3
            )
            TrainingIllustrationView(
                imageName: exercise.muscleImage,
                title: "肌肉发力图",
                subtitle: exercise.primaryMuscles,
                systemImage: "bolt.heart.fill",
                accent: accent,
                aspectRatio: 4 / 3
            )
        }
    }

    // MARK: - 标题

    private var header: some View {
        HStack(alignment: .top, spacing: 10) {
            VStack(alignment: .leading, spacing: 3) {
                Text(exercise.name)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(.textPrimary)
                Text(exercise.nameEn)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.textMuted)
            }
            Spacer()
            Text(exercise.setsReps)
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(accent)
                .multilineTextAlignment(.trailing)
                .lineLimit(2)
                .minimumScaleFactor(0.75)
                .padding(.horizontal, 8)
                .padding(.vertical, 5)
                .background(accent.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        }
    }

    private var muscleSummary: some View {
        VStack(alignment: .leading, spacing: 6) {
            muscleLine(label: "主", text: exercise.primaryMuscles, color: accent)
            if !exercise.synergistMuscles.isEmpty {
                muscleLine(label: "协同", text: exercise.synergistMuscles, color: .textSecondary)
            }
        }
    }

    private func muscleLine(label: String, text: String, color: Color) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 6) {
            Text(label)
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(color)
                .frame(minWidth: 24)
                .padding(.horizontal, 6)
                .padding(.vertical, 3)
                .background(color.opacity(0.1))
                .clipShape(Capsule())
            Text(text)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    // MARK: - 要点

    private var keyPoints: some View {
        VStack(alignment: .leading, spacing: 7) {
            Text("动作要点")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.textPrimary)

            ForEach(Array(exercise.points.enumerated()), id: \.offset) { _, point in
                HStack(alignment: .top, spacing: 7) {
                    Circle()
                        .fill(accent)
                        .frame(width: 5, height: 5)
                        .padding(.top, 6)
                    Text(point)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }
}

// MARK: - 图片占位

struct TrainingIllustrationView: View {
    let imageName: String
    let title: String
    let subtitle: String
    let systemImage: String
    let accent: Color
    let aspectRatio: CGFloat

    var body: some View {
        ZStack {
            if let image = UIImage(named: imageName) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(8)
            } else {
                placeholder
            }
        }
        .frame(maxWidth: .infinity)
        .aspectRatio(aspectRatio, contentMode: .fit)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(accent.opacity(0.08))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(accent.opacity(0.14), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityLabel(Text("\(title)：\(subtitle)"))
    }

    private var placeholder: some View {
        VStack(spacing: 7) {
            Image(systemName: systemImage)
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(accent)
            Text(title)
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
            Text(subtitle)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.textMuted)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.72)
        }
        .padding(8)
    }
}

#Preview {
    ExerciseCard(
        exercise: TrainingPlanData.parts[0].exercises[0],
        accent: .brandBlue
    )
    .padding()
    .background(Color.appBg)
}
