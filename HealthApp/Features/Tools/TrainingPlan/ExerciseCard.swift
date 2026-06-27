// ExerciseCard.swift
// 小工具 · 训练计划：动作列表项（过渡版，基于新动作库模型）。
// 完整卡片/详情在 TP02/TP03 重做；此处先提供可编译的精简行，验证 TP01 数据层。

import SwiftUI
import UIKit

/// 动作列表行：缩略占位 + 中文名/英文名 + 主练肌群/类型/难度。
struct ExerciseCard: View {
    let exercise: Exercise
    let accent: Color

    var body: some View {
        HStack(spacing: 11) {
            thumbnail
            VStack(alignment: .leading, spacing: 3) {
                Text(exercise.name)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.textPrimary)
                Text(exercise.nameEn)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.textMuted)
                tags
            }
            Spacer(minLength: 0)
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.cardBg)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Color.hairline, lineWidth: 1)
        )
    }

    private var thumbnail: some View {
        RoundedRectangle(cornerRadius: 9, style: .continuous)
            .fill(accent.opacity(0.10))
            .frame(width: 50, height: 50)
            .overlay(
                Image(systemName: exercise.hasVideo ? "play.fill" : "figure.strengthtraining.traditional")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(accent)
            )
    }

    private var tags: some View {
        HStack(spacing: 5) {
            if let primary = exercise.primaryMuscles.first {
                tag(primary)
            }
            tag(exercise.type)
            DifficultyDots(level: exercise.difficulty)
        }
        .padding(.top, 4)
    }

    private func tag(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 10, weight: .medium))
            .foregroundColor(.textSecondary)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(
                RoundedRectangle(cornerRadius: 5, style: .continuous)
                    .fill(Color.appBg)
            )
    }
}

/// 难度圆点：实心 ×level + 空心 ×(5-level)，压缩到 1–5。
struct DifficultyDots: View {
    let level: Int

    var body: some View {
        let n = min(max(level, 1), 5)
        HStack(spacing: 2) {
            ForEach(0..<5, id: \.self) { i in
                Circle()
                    .fill(i < n ? Color.exerciseOrange : Color.exerciseOrange.opacity(0.22))
                    .frame(width: 4.5, height: 4.5)
            }
        }
        .accessibilityLabel(Text("难度 \(n)/5"))
    }
}

// MARK: - 图片占位（保留供 TP03 详情页复用）

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
    ExerciseCard(exercise: TrainingPlanData.exercises[0], accent: .brandBlue)
        .padding()
        .background(Color.appBg)
}
