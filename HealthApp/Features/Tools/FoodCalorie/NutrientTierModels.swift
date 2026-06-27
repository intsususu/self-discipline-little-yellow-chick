// NutrientTierModels.swift
// 小工具 · 营养素红黑榜：三大营养素（蛋白质 / 碳水 / 脂肪）按「夯 / 中 / 拉」分级。
// 卡片以「热量」优先高亮，其后才是蛋白 / GI / 脂肪类型等佐证。
// 固体口径为每 100g（部分标注生/熟/干），饮品按整杯 / 整罐计。
// 数值为常见参考值，非精确营养值。见 docs/prd/食品热量表设计.md（重设计）。

import SwiftUI

// MARK: - 三大营养素

enum MacroType: CaseIterable, Identifiable {
    case protein, carb, fat

    var id: Self { self }

    var title: String {
        switch self {
        case .protein: return "蛋白质"
        case .carb:    return "碳水"
        case .fat:     return "脂肪"
        }
    }

    var emoji: String {
        switch self {
        case .protein: return "🥩"
        case .carb:    return "🍚"
        case .fat:     return "🥑"
        }
    }

    /// 评判维度的一句话说明（夯/拉按什么排）。
    var hint: String {
        switch self {
        case .protein: return "看蛋白质含量，以及脂肪、热量是否够低"
        case .carb:    return "看升糖快慢（GI）与膳食纤维、饱腹感"
        case .fat:     return "看脂肪类型：不饱和脂肪优先，远离反式脂肪"
        }
    }
}

// MARK: - 分级（夯 / 中 / 拉）

enum FoodTier: CaseIterable, Identifiable {
    case hang, mid, la

    var id: Self { self }

    var title: String {
        switch self {
        case .hang: return "夯"
        case .mid:  return "中"
        case .la:   return "拉"
        }
    }

    var emoji: String {
        switch self {
        case .hang: return "🟢"
        case .mid:  return "🟡"
        case .la:   return "🔴"
        }
    }

    /// 语义色，复用 App 既有 token（绿 / 黄 / 橙红）。
    var color: Color {
        switch self {
        case .hang: return .successGreen
        case .mid:  return .warningAmber
        case .la:   return .exerciseOrange
        }
    }

    /// 各营养素下，本档位的小标题。
    func subtitle(for macro: MacroType) -> String {
        switch (macro, self) {
        case (.protein, .hang): return "高蛋白 · 低脂 · 性价比高"
        case (.protein, .mid):  return "蛋白不错，脂肪偏高"
        case (.protein, .la):   return "加工肉 · 高脂高钠"
        case (.carb, .hang):    return "低 GI · 高纤维 · 稳血糖"
        case (.carb, .mid):     return "精制主食，适量为宜"
        case (.carb, .la):      return "高糖 · 高 GI · 空热量"
        case (.fat, .hang):     return "优质不饱和脂肪"
        case (.fat, .mid):      return "可以吃，注意控量"
        case (.fat, .la):       return "饱和 / 反式脂肪"
        }
    }
}

// MARK: - 数据结构

/// 一条「数据佐证」指标，如 蛋白 24g、GI 55、类型 单不饱和。
struct NutrientMetric: Identifiable {
    let id = UUID()
    let label: String
    let value: String

    init(_ label: String, _ value: String) {
        self.label = label
        self.value = value
    }
}

/// 一条食物条目。热量优先高亮；portion 为计量口径（如「100g」「一罐330ml」）。
struct NutrientFood: Identifiable {
    let id = UUID()
    let name: String
    let emoji: String
    let tier: FoodTier
    let portion: String            // 计量口径：100g / 一杯500ml …
    let calorie: Int               // 该口径下的热量（千卡），高亮主指标
    let metrics: [NutrientMetric]  // 次级佐证：蛋白 / GI / 脂肪类型 …
    let note: String?              // 一句话点评

    init(_ name: String, _ emoji: String, _ tier: FoodTier,
         portion: String, calorie: Int,
         _ metrics: [NutrientMetric], note: String? = nil) {
        self.name = name
        self.emoji = emoji
        self.tier = tier
        self.portion = portion
        self.calorie = calorie
        self.metrics = metrics
        self.note = note
    }
}

// MARK: - 内置数据

enum NutrientTierData {
    /// 按营养素取全部条目（含三档）。
    static func foods(for macro: MacroType) -> [NutrientFood] {
        switch macro {
        case .protein: return protein
        case .carb:    return carb
        case .fat:     return fat
        }
    }

    /// 取某营养素某档位的条目，保持录入顺序。
    static func foods(for macro: MacroType, tier: FoodTier) -> [NutrientFood] {
        foods(for: macro).filter { $0.tier == tier }
    }

    /// 蛋白质（每 100g：热量 → 蛋白 / 脂肪）。
    private static let protein: [NutrientFood] = [
        // 🟢 夯
        NutrientFood("鸡胸肉", "🍗", .hang, portion: "100g", calorie: 133,
                     [.init("蛋白", "24g"), .init("脂肪", "2g")],
                     note: "蛋白之王，增肌减脂首选"),
        NutrientFood("鸡蛋（全蛋）", "🥚", .hang, portion: "100g", calorie: 144,
                     [.init("蛋白", "13g"), .init("脂肪", "9g")],
                     note: "氨基酸最接近人体，整蛋更营养"),
        NutrientFood("蛋清", "🥚", .hang, portion: "100g", calorie: 52,
                     [.init("蛋白", "11g"), .init("脂肪", "0.1g")],
                     note: "纯蛋白，几乎零脂"),
        NutrientFood("虾", "🦐", .hang, portion: "100g", calorie: 99,
                     [.init("蛋白", "18g"), .init("脂肪", "1g")],
                     note: "低脂高蛋白，富含锌"),
        NutrientFood("鳕鱼 / 巴沙鱼", "🐟", .hang, portion: "100g", calorie: 88,
                     [.init("蛋白", "18g"), .init("脂肪", "1g")],
                     note: "白肉鱼，脂肪极低"),
        NutrientFood("金枪鱼（水浸）", "🐟", .hang, portion: "100g", calorie: 116,
                     [.init("蛋白", "26g"), .init("脂肪", "1g")],
                     note: "罐头选水浸，别选油浸"),
        NutrientFood("牛腱子", "🥩", .hang, portion: "100g", calorie: 170,
                     [.init("蛋白", "28g"), .init("脂肪", "5g")],
                     note: "瘦红肉，补铁"),
        NutrientFood("瘦牛肉", "🥩", .hang, portion: "100g", calorie: 145,
                     [.init("蛋白", "20g"), .init("脂肪", "7g")],
                     note: "肌酸 + 铁，挑瘦切部位"),
        NutrientFood("无糖希腊酸奶", "🥛", .hang, portion: "100g", calorie: 59,
                     [.init("蛋白", "10g"), .init("脂肪", "0.4g")],
                     note: "蛋白约是普通酸奶 3 倍"),
        NutrientFood("低脂牛奶", "🥛", .hang, portion: "100g", calorie: 42,
                     [.init("蛋白", "3.4g"), .init("脂肪", "1g")],
                     note: "补钙 + 优质蛋白"),
        NutrientFood("乳清蛋白粉", "🥤", .hang, portion: "100g粉", calorie: 380,
                     [.init("蛋白", "80g"), .init("脂肪", "6g")],
                     note: "每勺≈25g 粉、约 95 千卡，吸收快"),

        // 🟡 中
        NutrientFood("三文鱼", "🍣", .mid, portion: "100g", calorie: 208,
                     [.init("蛋白", "20g"), .init("脂肪", "13g")],
                     note: "脂肪偏高，但富含 Omega-3"),
        NutrientFood("鸭胸（去皮）", "🦆", .mid, portion: "100g", calorie: 180,
                     [.init("蛋白", "19g"), .init("脂肪", "11g")],
                     note: "去皮后脂肪可控"),
        NutrientFood("鸡腿肉（去皮）", "🍗", .mid, portion: "100g", calorie: 181,
                     [.init("蛋白", "24g"), .init("脂肪", "9g")],
                     note: "比鸡胸嫩，脂肪稍高"),
        NutrientFood("豆腐", "🧈", .mid, portion: "100g", calorie: 116,
                     [.init("蛋白", "12g"), .init("脂肪", "5g")],
                     note: "植物蛋白，含大豆异黄酮"),
        NutrientFood("豆干", "🟫", .mid, portion: "100g", calorie: 140,
                     [.init("蛋白", "16g"), .init("脂肪", "9g")],
                     note: "蛋白浓缩，但油 / 钠偏高"),
        NutrientFood("毛豆", "🫛", .mid, portion: "100g", calorie: 131,
                     [.init("蛋白", "13g"), .init("脂肪", "5g")],
                     note: "植物蛋白 + 膳食纤维"),

        // 🔴 拉
        NutrientFood("香肠", "🌭", .la, portion: "100g", calorie: 508,
                     [.init("蛋白", "12g"), .init("脂肪", "40g")],
                     note: "脂肪、钠双高"),
        NutrientFood("培根", "🥓", .la, portion: "100g", calorie: 510,
                     [.init("蛋白", "12g"), .init("脂肪", "45g")],
                     note: "饱和脂肪炸弹"),
        NutrientFood("午餐肉", "🥫", .la, portion: "100g", calorie: 330,
                     [.init("蛋白", "10g"), .init("脂肪", "30g")],
                     note: "高钠 + 添加剂"),
        NutrientFood("炸鸡", "🍗", .la, portion: "100g", calorie: 290,
                     [.init("蛋白", "19g"), .init("脂肪", "25g")],
                     note: "裹粉油炸，热量翻倍"),
        NutrientFood("肥牛 / 肥羊", "🥩", .la, portion: "100g", calorie: 330,
                     [.init("蛋白", "14g"), .init("脂肪", "30g")],
                     note: "雪花≈脂肪，涮锅当心"),
    ]

    /// 碳水（每 100g：热量 → GI / 纤维 / 含糖）。
    private static let carb: [NutrientFood] = [
        // 🟢 夯
        NutrientFood("燕麦", "🌾", .hang, portion: "100g·干", calorie: 389,
                     [.init("GI", "55"), .init("纤维", "10g")],
                     note: "β-葡聚糖，饱腹抗饿"),
        NutrientFood("红薯", "🍠", .hang, portion: "100g", calorie: 90,
                     [.init("GI", "54"), .init("纤维", "2.6g")],
                     note: "带皮蒸煮，GI 更低"),
        NutrientFood("紫薯", "🍠", .hang, portion: "100g", calorie: 82,
                     [.init("GI", "54"), .init("纤维", "1.6g")],
                     note: "含花青素，抗氧化"),
        NutrientFood("玉米", "🌽", .hang, portion: "100g", calorie: 112,
                     [.init("GI", "55"), .init("纤维", "2.9g")],
                     note: "粗粮主食，膳食纤维高"),
        NutrientFood("土豆", "🥔", .hang, portion: "100g", calorie: 81,
                     [.init("GI", "66"), .init("纤维", "1.5g")],
                     note: "放凉吃抗性淀粉↑，趁热 GI 偏高"),
        NutrientFood("糙米", "🍚", .hang, portion: "100g·生", calorie: 348,
                     [.init("GI", "56"), .init("纤维", "3.5g")],
                     note: "比白米饭血糖更稳"),
        NutrientFood("全麦面包", "🍞", .hang, portion: "100g", calorie: 250,
                     [.init("GI", "69"), .init("纤维", "7g")],
                     note: "认准「全麦粉」为第一配料"),
        NutrientFood("荞麦面", "🍜", .hang, portion: "100g·干", calorie: 340,
                     [.init("GI", "59"), .init("纤维", "6g")],
                     note: "含芦丁，低 GI 主食"),
        NutrientFood("南瓜", "🎃", .hang, portion: "100g", calorie: 26,
                     [.init("GI", "65"), .init("纤维", "1.1g")],
                     note: "热量极低，少量血糖负荷不高"),

        // 🟡 中
        NutrientFood("白米饭", "🍚", .mid, portion: "100g·熟", calorie: 116,
                     [.init("GI", "83"), .init("纤维", "0.3g")],
                     note: "精制主食，配菜 / 粗粮搭着吃"),
        NutrientFood("面条", "🍜", .mid, portion: "100g·熟", calorie: 110,
                     [.init("GI", "82"), .init("纤维", "1g")],
                     note: "升糖快，加蛋加菜更稳"),
        NutrientFood("馒头", "🍞", .mid, portion: "100g", calorie: 221,
                     [.init("GI", "88"), .init("纤维", "1g")],
                     note: "GI 很高，注意控量"),
        NutrientFood("饺子", "🥟", .mid, portion: "100g", calorie: 250,
                     [.init("GI", "60"), .init("纤维", "1g")],
                     note: "有肉有菜，胜在均衡"),
        NutrientFood("包子", "🥟", .mid, portion: "100g", calorie: 230,
                     [.init("GI", "70"), .init("纤维", "1g")],
                     note: "看馅料，肉馅热量更高"),

        // 🔴 拉
        NutrientFood("蛋糕", "🍰", .la, portion: "100g", calorie: 350,
                     [.init("GI", "67"), .init("含糖", "30g")],
                     note: "糖 + 油，纤维几乎为 0"),
        NutrientFood("奶茶", "🧋", .la, portion: "一杯500ml", calorie: 460,
                     [.init("含糖", "50g"), .init("纤维", "≈0")],
                     note: "一杯糖≈10 块方糖"),
        NutrientFood("可乐", "🥤", .la, portion: "一罐330ml", calorie: 140,
                     [.init("GI", "63"), .init("含糖", "35g")],
                     note: "纯液体糖，无饱腹感"),
        NutrientFood("糖果", "🍬", .la, portion: "100g", calorie: 400,
                     [.init("含糖", "90g"), .init("纤维", "0")],
                     note: "几乎是纯糖"),
        NutrientFood("曲奇", "🍪", .la, portion: "100g", calorie: 546,
                     [.init("含糖", "23g"), .init("脂肪", "25g")],
                     note: "高糖高油双杀"),
        NutrientFood("巧克力", "🍫", .la, portion: "100g", calorie: 550,
                     [.init("含糖", "50g"), .init("脂肪", "32g")],
                     note: "可可虽好，糖 / 油超标"),
        NutrientFood("薯片", "🍟", .la, portion: "100g", calorie: 555,
                     [.init("脂肪", "35g"), .init("钠", "高")],
                     note: "高油高钠，越吃越上头"),
    ]

    /// 脂肪（每 100g：热量 → 脂肪类型）。
    private static let fat: [NutrientFood] = [
        // 🟢 夯
        NutrientFood("牛油果", "🥑", .hang, portion: "100g", calorie: 160,
                     [.init("类型", "单不饱和"), .init("纤维", "7g")],
                     note: "唯一高脂水果，含钾"),
        NutrientFood("杏仁", "🌰", .hang, portion: "100g", calorie: 578,
                     [.init("类型", "单不饱和"), .init("维E", "高")],
                     note: "一小把约 20 粒"),
        NutrientFood("开心果", "🥜", .hang, portion: "100g", calorie: 562,
                     [.init("类型", "单不饱和")],
                     note: "带壳吃更慢，易控量"),
        NutrientFood("核桃", "🌰", .hang, portion: "100g", calorie: 654,
                     [.init("类型", "植物 Omega-3")],
                     note: "多不饱和，每天 2–3 颗"),
        NutrientFood("腰果", "🥜", .hang, portion: "100g", calorie: 553,
                     [.init("类型", "单不饱和")],
                     note: "脂肪略低，仍需适量"),
        NutrientFood("橄榄油", "🫒", .hang, portion: "100g", calorie: 884,
                     [.init("类型", "单不饱和 73%")],
                     note: "凉拌 / 低温，忌高温油炸"),
        NutrientFood("深海鱼脂肪", "🐟", .hang, portion: "100g", calorie: 208,
                     [.init("类型", "Omega-3")],
                     note: "三文鱼 / 沙丁鱼，每周 2–3 次"),

        // 🟡 中
        NutrientFood("花生", "🥜", .mid, portion: "100g", calorie: 567,
                     [.init("类型", "单 + 多不饱和")],
                     note: "性价比高，但易过量"),
        NutrientFood("花生酱", "🥜", .mid, portion: "100g", calorie: 588,
                     [.init("类型", "不饱和为主")],
                     note: "选无额外糖 / 盐版本"),
        NutrientFood("芝麻", "🫘", .mid, portion: "100g", calorie: 536,
                     [.init("类型", "多不饱和"), .init("钙", "高")],
                     note: "钙含量高，但热量密度大"),
        NutrientFood("奶酪", "🧀", .mid, portion: "100g", calorie: 328,
                     [.init("类型", "饱和偏高")],
                     note: "钙 + 蛋白好，钠 / 饱和脂肪要控"),

        // 🔴 拉
        NutrientFood("奶油", "🧈", .la, portion: "100g", calorie: 878,
                     [.init("类型", "饱和脂肪")],
                     note: "饱和脂肪炸弹"),
        NutrientFood("起酥点心", "🥐", .la, portion: "100g", calorie: 500,
                     [.init("类型", "含反式脂肪")],
                     note: "「酥」多半来自起酥油"),
        NutrientFood("人造黄油", "🧈", .la, portion: "100g", calorie: 717,
                     [.init("类型", "反式 / 饱和")],
                     note: "氢化植物油来源"),
    ]
}

// MARK: - 个人代谢估算

/// 结合性别 / 年龄 / 身高 / 体重，估算静息代谢（BMR）与三大营养素每日参考量。
/// BMR 用 Mifflin-St Jeor 公式；营养素按体重系数估算（蛋白 1.6、碳水 4.0、脂肪 1.0 g/kg）。
struct MetabolismEstimate {
    let bmr: Int            // 静息代谢（千卡/天）
    let intake: Int         // 每日摄入参考（三大营养素之和，千卡/天）
    let proteinG: Int       // 蛋白质（g/天）
    let carbG: Int          // 碳水（g/天）
    let fatG: Int           // 脂肪（g/天）
    let summary: String     // 「178cm · 34岁 · 男 · 77kg」

    /// 每 kg 体重的营养素系数。
    static let proteinPerKg = 1.6
    static let carbPerKg    = 4.0
    static let fatPerKg     = 1.0

    init(gender: Gender, age: Int, heightCm: Int, weightKg: Double) {
        let w = weightKg, h = Double(heightCm), a = Double(age)
        let base = 10 * w + 6.25 * h - 5 * a
        let bmrValue: Double
        switch gender {
        case .male:   bmrValue = base + 5
        case .female: bmrValue = base - 161
        case .other:  bmrValue = base - 78   // 取男女公式中点
        }
        bmr = max(0, Int(bmrValue.rounded()))

        let p = w * Self.proteinPerKg
        let c = w * Self.carbPerKg
        let f = w * Self.fatPerKg
        proteinG = Int(p.rounded())
        carbG    = Int(c.rounded())
        fatG     = Int(f.rounded())
        intake   = Int((p * 4 + c * 4 + f * 9).rounded())

        summary = "\(heightCm)cm · \(age)岁 · \(gender.label) · \(Int(weightKg.rounded()))kg"
    }
}
