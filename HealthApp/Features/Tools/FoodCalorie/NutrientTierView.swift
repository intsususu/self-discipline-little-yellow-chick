// NutrientTierView.swift
// 小工具 · 营养素红黑榜：三大营养素（蛋白质 / 碳水 / 脂肪）从「夯」到「拉」分级速查。
// 纯查询工具，本地内置数据。见 docs/食品热量表设计.md（重设计）。

import SwiftUI

struct NutrientTierView: View {
    @State private var macro: MacroType = .protein

    private let tiers = FoodTier.allCases

    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                macroTabs
                hintCard
                ForEach(tiers) { tier in
                    tierSection(tier)
                }
                disclaimer
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 20)
        }
        .background(Color.appBg.ignoresSafeArea())
        .navigationTitle("营养素红黑榜")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - 营养素 Tab

    private var macroTabs: some View {
        HStack(spacing: 8) {
            ForEach(MacroType.allCases) { type in
                Button {
                    guard type != macro else { return }
                    withAnimation(.easeInOut(duration: 0.18)) { macro = type }
                } label: {
                    HStack(spacing: 5) {
                        Text(type.emoji).font(.system(size: 14))
                        Text(type.title).font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundColor(type == macro ? .white : .textSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 9)
                    .background(type == macro ? Color.brandBlue : Color.cardBg)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(Color.hairline, lineWidth: type == macro ? 0 : 1)
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - 维度说明

    private var hintCard: some View {
        HStack(spacing: 8) {
            Image(systemName: "scalemass")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.brandBlue)
            Text("怎么排：\(macro.hint)")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color.brandBlue.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    // MARK: - 单档分组

    private func tierSection(_ tier: FoodTier) -> some View {
        let foods = NutrientTierData.foods(for: macro, tier: tier)
        return VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Text(tier.emoji).font(.system(size: 15))
                Text(tier.title)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(tier.color)
                Text(tier.subtitle(for: macro))
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.textMuted)
                Spacer(minLength: 0)
                Text("\(foods.count) 种")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.textMuted)
            }
            .padding(.horizontal, 2)

            VStack(spacing: 8) {
                ForEach(foods) { food in
                    foodCard(food)
                }
            }
        }
    }

    // MARK: - 食物卡片

    private func foodCard(_ food: NutrientFood) -> some View {
        HStack(spacing: 12) {
            Text(food.emoji)
                .font(.system(size: 22))
                .frame(width: 40, height: 40)
                .background(food.tier.color.opacity(0.10))
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

            VStack(alignment: .leading, spacing: 7) {
                HStack(spacing: 6) {
                    Text(food.name)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.textPrimary)
                    Circle()
                        .fill(food.tier.color)
                        .frame(width: 6, height: 6)
                }
                metricChips(food)
                if let note = food.note {
                    Text(note)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.textMuted)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 11)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.cardBg)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.hairline, lineWidth: 1)
        )
    }

    /// 数据佐证小胶囊：首项用档位色高亮，其余中性。
    private func metricChips(_ food: NutrientFood) -> some View {
        HStack(spacing: 6) {
            ForEach(Array(food.metrics.enumerated()), id: \.element.id) { index, metric in
                chip(metric, emphasized: index == 0, tint: food.tier.color)
            }
        }
    }

    private func chip(_ metric: NutrientMetric, emphasized: Bool, tint: Color) -> some View {
        HStack(spacing: 3) {
            Text(metric.label)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(emphasized ? tint.opacity(0.85) : .textMuted)
            Text(metric.value)
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(emphasized ? tint : .textSecondary)
        }
        .padding(.horizontal, 7)
        .padding(.vertical, 4)
        .background(emphasized ? tint.opacity(0.12) : Color.appBg)
        .clipShape(RoundedRectangle(cornerRadius: 7, style: .continuous))
    }

    // MARK: - 免责声明

    private var disclaimer: some View {
        Text("数值为每 100g 常见参考值（另有标注者除外），用于横向对比，非精确营养值；GI 受品种与烹饪影响。")
            .font(.system(size: 11))
            .foregroundColor(.textMuted)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
            .padding(.top, 4)
    }
}

#Preview {
    NavigationStack { NutrientTierView() }
}
