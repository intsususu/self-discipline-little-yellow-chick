// NutrientTierModels.swift
// 小工具 · 营养素红黑榜：三大营养素（蛋白质 / 碳水 / 脂肪）按「夯 / 中 / 拉」分级。
// 数据为每 100g 常见参考值（另有标注者除外），用于横向对比，非精确营养值。
// 见 docs/食品热量表设计.md（重设计）。

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

/// 一条「数据佐证」指标，如 蛋白 31g、GI 55、类型 单不饱和。
struct NutrientMetric: Identifiable {
    let id = UUID()
    let label: String
    let value: String

    init(_ label: String, _ value: String) {
        self.label = label
        self.value = value
    }
}

/// 一条食物条目（含分级与佐证指标）。
struct NutrientFood: Identifiable {
    let id = UUID()
    let name: String
    let emoji: String
    let tier: FoodTier
    let metrics: [NutrientMetric]  // 第一个为「主指标」，高亮显示
    let note: String?              // 一句话点评

    init(_ name: String, _ emoji: String, _ tier: FoodTier,
         _ metrics: [NutrientMetric], note: String? = nil) {
        self.name = name
        self.emoji = emoji
        self.tier = tier
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

    /// 蛋白质（每 100g：蛋白 / 脂肪 / 热量）。
    private static let protein: [NutrientFood] = [
        // 🟢 夯
        NutrientFood("鸡胸肉", "🍗", .hang,
                     [.init("蛋白", "24g"), .init("脂肪", "2g"), .init("热量", "133")],
                     note: "蛋白之王，增肌减脂首选"),
        NutrientFood("鸡蛋（全蛋）", "🥚", .hang,
                     [.init("蛋白", "13g"), .init("脂肪", "9g"), .init("热量", "144")],
                     note: "氨基酸最接近人体，整蛋更营养"),
        NutrientFood("蛋清", "🥚", .hang,
                     [.init("蛋白", "11g"), .init("脂肪", "0.1g"), .init("热量", "52")],
                     note: "纯蛋白，几乎零脂"),
        NutrientFood("虾", "🦐", .hang,
                     [.init("蛋白", "18g"), .init("脂肪", "1g"), .init("热量", "99")],
                     note: "低脂高蛋白，富含锌"),
        NutrientFood("鳕鱼 / 巴沙鱼", "🐟", .hang,
                     [.init("蛋白", "18g"), .init("脂肪", "1g"), .init("热量", "88")],
                     note: "白肉鱼，脂肪极低"),
        NutrientFood("金枪鱼（水浸）", "🐟", .hang,
                     [.init("蛋白", "26g"), .init("脂肪", "1g"), .init("热量", "116")],
                     note: "罐头选水浸，别选油浸"),
        NutrientFood("牛腱子", "🥩", .hang,
                     [.init("蛋白", "28g"), .init("脂肪", "5g"), .init("热量", "170")],
                     note: "瘦红肉，补铁"),
        NutrientFood("瘦牛肉", "🥩", .hang,
                     [.init("蛋白", "20g"), .init("脂肪", "7g"), .init("热量", "145")],
                     note: "肌酸 + 铁，挑瘦切部位"),
        NutrientFood("无糖希腊酸奶", "🥛", .hang,
                     [.init("蛋白", "10g"), .init("脂肪", "0.4g"), .init("热量", "59")],
                     note: "蛋白约是普通酸奶 3 倍"),
        NutrientFood("低脂牛奶", "🥛", .hang,
                     [.init("蛋白", "3.4g"), .init("脂肪", "1g"), .init("热量", "42")],
                     note: "补钙 + 优质蛋白"),
        NutrientFood("乳清蛋白粉", "🥤", .hang,
                     [.init("蛋白", "80g"), .init("脂肪", "6g"), .init("热量", "380")],
                     note: "每勺≈25g 蛋白，吸收快"),

        // 🟡 中
        NutrientFood("三文鱼", "🍣", .mid,
                     [.init("蛋白", "20g"), .init("脂肪", "13g"), .init("热量", "208")],
                     note: "脂肪偏高，但富含 Omega-3"),
        NutrientFood("鸭胸（去皮）", "🦆", .mid,
                     [.init("蛋白", "19g"), .init("脂肪", "11g"), .init("热量", "180")],
                     note: "去皮后脂肪可控"),
        NutrientFood("鸡腿肉（去皮）", "🍗", .mid,
                     [.init("蛋白", "24g"), .init("脂肪", "9g"), .init("热量", "181")],
                     note: "比鸡胸嫩，脂肪稍高"),
        NutrientFood("豆腐", "🧈", .mid,
                     [.init("蛋白", "12g"), .init("脂肪", "5g"), .init("热量", "116")],
                     note: "植物蛋白，含大豆异黄酮"),
        NutrientFood("豆干", "🟫", .mid,
                     [.init("蛋白", "16g"), .init("脂肪", "9g"), .init("热量", "140")],
                     note: "蛋白浓缩，但油/钠偏高"),
        NutrientFood("毛豆", "🫛", .mid,
                     [.init("蛋白", "13g"), .init("脂肪", "5g"), .init("热量", "131")],
                     note: "植物蛋白 + 膳食纤维"),

        // 🔴 拉
        NutrientFood("香肠", "🌭", .la,
                     [.init("蛋白", "12g"), .init("脂肪", "40g"), .init("热量", "508")],
                     note: "脂肪、钠双高"),
        NutrientFood("培根", "🥓", .la,
                     [.init("蛋白", "12g"), .init("脂肪", "45g"), .init("热量", "510")],
                     note: "饱和脂肪炸弹"),
        NutrientFood("午餐肉", "🥫", .la,
                     [.init("蛋白", "10g"), .init("脂肪", "30g"), .init("热量", "330")],
                     note: "高钠 + 添加剂"),
        NutrientFood("炸鸡", "🍗", .la,
                     [.init("蛋白", "19g"), .init("脂肪", "25g"), .init("热量", "290")],
                     note: "裹粉油炸，热量翻倍"),
        NutrientFood("肥牛 / 肥羊", "🥩", .la,
                     [.init("蛋白", "14g"), .init("脂肪", "30g"), .init("热量", "330")],
                     note: "雪花≈脂肪，涮锅当心"),
        NutrientFood("加工肉制品", "🍖", .la,
                     [.init("钠", "很高"), .init("添加剂", "多"), .init("加工", "深")],
                     note: "火腿肠等，WHO 列为 2A 类，少吃"),
    ]

    /// 碳水（每 100g：GI 升糖指数 / 膳食纤维 / 热量）。
    private static let carb: [NutrientFood] = [
        // 🟢 夯
        NutrientFood("燕麦", "🌾", .hang,
                     [.init("GI", "55"), .init("纤维", "10g"), .init("热量", "389")],
                     note: "β-葡聚糖，饱腹抗饿"),
        NutrientFood("红薯", "🍠", .hang,
                     [.init("GI", "54"), .init("纤维", "2.6g"), .init("热量", "90")],
                     note: "带皮蒸煮，GI 更低"),
        NutrientFood("紫薯", "🍠", .hang,
                     [.init("GI", "54"), .init("纤维", "1.6g"), .init("热量", "82")],
                     note: "含花青素，抗氧化"),
        NutrientFood("玉米", "🌽", .hang,
                     [.init("GI", "55"), .init("纤维", "2.9g"), .init("热量", "112")],
                     note: "粗粮主食，膳食纤维高"),
        NutrientFood("土豆", "🥔", .hang,
                     [.init("GI", "66"), .init("纤维", "1.5g"), .init("热量", "81")],
                     note: "放凉吃抗性淀粉↑，趁热 GI 偏高"),
        NutrientFood("糙米", "🍚", .hang,
                     [.init("GI", "56"), .init("纤维", "3.5g"), .init("热量", "348")],
                     note: "比白米饭血糖更稳"),
        NutrientFood("全麦面包", "🍞", .hang,
                     [.init("GI", "69"), .init("纤维", "7g"), .init("热量", "250")],
                     note: "认准「全麦粉」为第一配料"),
        NutrientFood("荞麦面", "🍜", .hang,
                     [.init("GI", "59"), .init("纤维", "6g"), .init("热量", "340")],
                     note: "含芦丁，低 GI 主食"),
        NutrientFood("南瓜", "🎃", .hang,
                     [.init("GI", "65"), .init("纤维", "1.1g"), .init("热量", "26")],
                     note: "热量极低，少量血糖负荷不高"),

        // 🟡 中
        NutrientFood("白米饭", "🍚", .mid,
                     [.init("GI", "83"), .init("纤维", "0.3g"), .init("热量", "116")],
                     note: "精制主食，配菜 / 粗粮搭着吃"),
        NutrientFood("面条", "🍜", .mid,
                     [.init("GI", "82"), .init("纤维", "1g"), .init("热量", "110")],
                     note: "升糖快，加蛋加菜更稳"),
        NutrientFood("馒头", "🍞", .mid,
                     [.init("GI", "88"), .init("纤维", "1g"), .init("热量", "221")],
                     note: "GI 很高，注意控量"),
        NutrientFood("饺子", "🥟", .mid,
                     [.init("GI", "60"), .init("纤维", "1g"), .init("热量", "250")],
                     note: "有肉有菜，胜在均衡"),
        NutrientFood("包子", "🥟", .mid,
                     [.init("GI", "70"), .init("纤维", "1g"), .init("热量", "230")],
                     note: "看馅料，肉馅热量更高"),

        // 🔴 拉
        NutrientFood("蛋糕", "🍰", .la,
                     [.init("GI", "67"), .init("纤维", "≈0"), .init("热量", "350")],
                     note: "糖 + 油，纤维几乎为 0"),
        NutrientFood("奶茶", "🧋", .la,
                     [.init("含糖", "50g+"), .init("热量", "390"), .init("纤维", "≈0")],
                     note: "一杯糖≈10 块方糖"),
        NutrientFood("可乐", "🥤", .la,
                     [.init("含糖", "11g/100ml"), .init("GI", "63"), .init("热量", "43")],
                     note: "纯液体糖，无饱腹感"),
        NutrientFood("糖果", "🍬", .la,
                     [.init("含糖", "90g+"), .init("热量", "400"), .init("纤维", "0")],
                     note: "几乎是纯糖"),
        NutrientFood("曲奇", "🍪", .la,
                     [.init("GI", "高"), .init("热量", "546"), .init("纤维", "低")],
                     note: "高糖高油双杀"),
        NutrientFood("巧克力", "🍫", .la,
                     [.init("含糖", "高"), .init("热量", "550"), .init("脂肪", "高")],
                     note: "可可虽好，糖 / 油超标"),
        NutrientFood("薯片", "🍟", .la,
                     [.init("热量", "555"), .init("脂肪", "高"), .init("钠", "高")],
                     note: "高油高钠，越吃越上头"),
    ]

    /// 脂肪（主要脂肪类型 / 热量 / 附加亮点）。
    private static let fat: [NutrientFood] = [
        // 🟢 夯
        NutrientFood("牛油果", "🥑", .hang,
                     [.init("类型", "单不饱和"), .init("纤维", "7g"), .init("热量", "160")],
                     note: "唯一高脂水果，含钾"),
        NutrientFood("杏仁", "🌰", .hang,
                     [.init("类型", "单不饱和"), .init("维E", "高"), .init("热量", "578")],
                     note: "一小把约 20 粒"),
        NutrientFood("开心果", "🥜", .hang,
                     [.init("类型", "单不饱和"), .init("热量", "562")],
                     note: "带壳吃更慢，易控量"),
        NutrientFood("核桃", "🌰", .hang,
                     [.init("类型", "植物 Omega-3"), .init("热量", "654")],
                     note: "多不饱和，每天 2–3 颗"),
        NutrientFood("腰果", "🥜", .hang,
                     [.init("类型", "单不饱和"), .init("热量", "553")],
                     note: "脂肪略低，仍需适量"),
        NutrientFood("橄榄油", "🫒", .hang,
                     [.init("单不饱和", "73%"), .init("热量", "884")],
                     note: "凉拌 / 低温，忌高温油炸"),
        NutrientFood("深海鱼脂肪", "🐟", .hang,
                     [.init("类型", "Omega-3"), .init("热量", "208")],
                     note: "三文鱼 / 沙丁鱼，每周 2–3 次"),

        // 🟡 中
        NutrientFood("花生", "🥜", .mid,
                     [.init("类型", "单 + 多不饱和"), .init("热量", "567")],
                     note: "性价比高，但易过量"),
        NutrientFood("花生酱", "🥜", .mid,
                     [.init("类型", "不饱和为主"), .init("热量", "588")],
                     note: "选无额外糖 / 盐版本"),
        NutrientFood("芝麻", "🫘", .mid,
                     [.init("钙", "高"), .init("热量", "536")],
                     note: "钙含量高，但热量密度大"),
        NutrientFood("奶酪", "🧀", .mid,
                     [.init("类型", "饱和偏高"), .init("热量", "328")],
                     note: "钙 + 蛋白好，钠 / 饱和脂肪要控"),

        // 🔴 拉
        NutrientFood("奶油", "🧈", .la,
                     [.init("类型", "饱和脂肪"), .init("热量", "878")],
                     note: "饱和脂肪炸弹"),
        NutrientFood("起酥点心", "🥐", .la,
                     [.init("类型", "含反式脂肪"), .init("热量", "500")],
                     note: "「酥」多半来自起酥油"),
        NutrientFood("人造黄油", "🧈", .la,
                     [.init("类型", "反式 / 饱和"), .init("热量", "717")],
                     note: "氢化植物油来源"),
        NutrientFood("油炸食品", "🍟", .la,
                     [.init("类型", "高温油"), .init("热量", "高")],
                     note: "反复用油，氧化 + 反式"),
        NutrientFood("反式脂肪食品", "🚫", .la,
                     [.init("类型", "反式脂肪"), .init("摄入", "趋零")],
                     note: "WHO 建议摄入量尽量为 0"),
    ]
}
