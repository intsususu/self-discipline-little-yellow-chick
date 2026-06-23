// FoodDetailSheet.swift
// 小工具 · 食品热量表：底部详情弹层。
// 头部 + 主热量 + 常见份量 + 免责声明。本期不含「记一笔到今日饮食」。

import SwiftUI

struct FoodDetailSheet: View {
    let item: FoodItem
    let groupLabel: String

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                header
                calorieBlock
                portionsSection
                Text("热量为常见做法参考值，实际以食材与烹饪方式为准")
                    .font(.system(size: 11))
                    .foregroundColor(.textMuted)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            .padding(20)
        }
        .background(Color.appBg.ignoresSafeArea())
    }

    // MARK: - 头部

    private var header: some View {
        HStack(spacing: 14) {
            Text(item.emoji)
                .font(.system(size: 34))
                .frame(width: 56, height: 56)
                .background(Color.cardBg)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            VStack(alignment: .leading, spacing: 8) {
                Text(item.name)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.textPrimary)
                HStack(spacing: 6) {
                    tag(groupLabel, color: .textSecondary, bg: Color.hairline)
                    tag(item.level.detailLabel, color: item.level.color, bg: item.level.color.opacity(0.12))
                }
            }
            Spacer()
        }
    }

    private func tag(_ text: String, color: Color, bg: Color) -> some View {
        Text(text)
            .font(.system(size: 11, weight: .semibold))
            .foregroundColor(color)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(bg)
            .clipShape(Capsule())
    }

    // MARK: - 主热量

    private var calorieBlock: some View {
        HStack(alignment: .lastTextBaseline) {
            Text("\(item.calorie)")
                .font(.system(size: 44, weight: .heavy))
                .foregroundColor(item.level.color)
            Text("千卡")
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.textSecondary)
            Spacer()
            Text(item.unitLabel)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.textMuted)
        }
        .padding(16)
        .background(Color.cardBg)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.hairline, lineWidth: 1)
        )
    }

    // MARK: - 常见份量

    private var portionsSection: some View {
        VStack(alignment: .leading, spacing: 9) {
            Text("常见份量")
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(.textSecondary)
            CardView(padding: 0) {
                VStack(spacing: 0) {
                    ForEach(Array(item.portions.enumerated()), id: \.element.id) { index, portion in
                        if index > 0 {
                            Divider().background(Color.hairline).padding(.leading, 14)
                        }
                        portionRow(portion)
                    }
                }
            }
        }
    }

    private func portionRow(_ portion: FoodPortion) -> some View {
        HStack(spacing: 10) {
            VStack(alignment: .leading, spacing: 2) {
                Text(portion.label)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.textPrimary)
                if !portion.spec.isEmpty {
                    Text(portion.spec)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.textMuted)
                }
            }
            Spacer()
            Text("\(portion.calorie)")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.textPrimary)
            Text("千卡")
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.textMuted)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
    }
}

#Preview {
    FoodDetailSheet(
        item: FoodItem("可口可乐", "🥤", unit: "每罐", calorie: 140,
                       portions: [FoodPortion(label: "1 罐", spec: "330ml", calorie: 140),
                                  FoodPortion(label: "大瓶", spec: "500ml", calorie: 215)]),
        groupLabel: "常见饮料"
    )
}
