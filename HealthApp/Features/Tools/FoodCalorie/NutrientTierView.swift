// NutrientTierView.swift
// 小工具 · 营养素红黑榜：三大营养素（蛋白质 / 碳水 / 脂肪）从「夯」到「拉」分级速查。
// 纯查询工具，本地内置数据。见 docs/prd/食品热量表设计.md（重设计）。

import SwiftUI

struct NutrientTierView: View {
    @EnvironmentObject private var appState: AppState
    @StateObject private var profileStore = ProfileStore()
    @State private var macro: MacroType = .protein
    @State private var currentWeight: Double?

    private let tiers = FoodTier.allCases

    /// 体重：优先用最近称重，缺失时回退目标体重，保证卡片始终有值可估。
    private var weightKg: Double {
        currentWeight ?? appState.goalWeight
    }

    private var metabolism: MetabolismEstimate {
        let p = profileStore.profile
        return MetabolismEstimate(gender: p.gender, age: p.age, heightCm: p.heightCm, weightKg: weightKg)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                metabolismCard
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
        .task {
            let samples = await appState.repository.weightSeries(range: .week)
            currentWeight = samples.last?.kg
        }
    }

    // MARK: - 个人代谢估算卡片

    private var metabolismCard: some View {
        let est = metabolism
        return VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline) {
                Text("个人代谢估算")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.textPrimary)
                Spacer()
                Text(est.summary)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.textMuted)
            }

            HStack(spacing: 10) {
                metabStat(title: "静息代谢 BMR", value: "\(est.bmr)", unit: "千卡/天", tint: .brandBlue)
                metabStat(title: "每日摄入参考", value: "\(est.intake)", unit: "千卡/天", tint: .exerciseOrange)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("每日三大营养素建议")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.textSecondary)
                HStack(spacing: 8) {
                    macroNeed("🥩", "蛋白质", est.proteinG, .brandBlue)
                    macroNeed("🍚", "碳水", est.carbG, .warningAmber)
                    macroNeed("🥑", "脂肪", est.fatG, .successGreen)
                }
            }

            Text("按体重估算（蛋白 1.6 · 碳水 4 · 脂肪 1 g/kg），实际随减脂/增肌目标与活动量调整。")
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.textMuted)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.cardBg)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.hairline, lineWidth: 1)
        )
    }

    private func metabStat(title: String, value: String, unit: String, tint: Color) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(title)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.textMuted)
            HStack(alignment: .firstTextBaseline, spacing: 3) {
                Text(value)
                    .font(.system(size: 22, weight: .heavy))
                    .foregroundColor(tint)
                Text(unit)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(.textMuted)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(tint.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private func macroNeed(_ emoji: String, _ name: String, _ grams: Int, _ tint: Color) -> some View {
        VStack(spacing: 3) {
            Text("\(emoji) \(name)")
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.textSecondary)
            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text("\(grams)")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(tint)
                Text("g")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(.textMuted)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 9)
        .background(Color.appBg)
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
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
                HStack(spacing: 5) {
                    Text(food.name)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.textPrimary)
                    Text("· \(food.portion)")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.textMuted)
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

    /// 数据佐证小胶囊：热量优先高亮（档位色），其后为蛋白 / GI / 脂肪类型等中性次级指标。
    private func metricChips(_ food: NutrientFood) -> some View {
        HStack(spacing: 6) {
            calorieChip(food)
            ForEach(food.metrics) { metric in
                chip(metric)
            }
        }
    }

    /// 热量主胶囊：档位色高亮，数字略大，置于首位。
    private func calorieChip(_ food: NutrientFood) -> some View {
        let tint = food.tier.color
        return HStack(spacing: 3) {
            Text("热量")
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(tint.opacity(0.85))
            Text("\(food.calorie)")
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(tint)
            Text("千卡")
                .font(.system(size: 9, weight: .medium))
                .foregroundColor(tint.opacity(0.85))
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(tint.opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: 7, style: .continuous))
    }

    /// 次级佐证胶囊：中性配色。
    private func chip(_ metric: NutrientMetric) -> some View {
        HStack(spacing: 3) {
            Text(metric.label)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.textMuted)
            Text(metric.value)
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.textSecondary)
        }
        .padding(.horizontal, 7)
        .padding(.vertical, 4)
        .background(Color.appBg)
        .clipShape(RoundedRectangle(cornerRadius: 7, style: .continuous))
    }

    // MARK: - 免责声明

    private var disclaimer: some View {
        Text("固体为每 100g、饮品按整杯 / 整罐的常见参考值；热量受食材与做法影响，仅供横向对比，GI 受品种与烹饪影响。")
            .font(.system(size: 11))
            .foregroundColor(.textMuted)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
            .padding(.top, 4)
    }
}

#if DEBUG
#Preview {
    NavigationStack { NutrientTierView() }
        .environmentObject(AppState(repository: MockHealthRepository()))
}
#endif
