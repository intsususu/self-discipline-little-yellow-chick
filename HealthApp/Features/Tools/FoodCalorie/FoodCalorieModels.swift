// FoodCalorieModels.swift
// 小工具 · 食品热量表：数据模型 + 内置参考数据。
// 见 docs/prd/食品热量表设计.md。热量为常见做法/常见品牌的公开参考值，非精确营养值。

import SwiftUI

// MARK: - 热量等级

/// 按「当前展示份量」的热量划分：低 <100、中 100–299、高 ≥300（千卡）。
enum CalorieLevel {
    case low, medium, high

    static func from(_ calorie: Int) -> CalorieLevel {
        switch calorie {
        case ..<100: return .low
        case 100..<300: return .medium
        default: return .high
        }
    }

    /// 列表徽标短文案。
    var badge: String {
        switch self {
        case .low: return "低"
        case .medium: return "中"
        case .high: return "高"
        }
    }

    /// 详情页标签文案。
    var detailLabel: String {
        switch self {
        case .low: return "低热量"
        case .medium: return "中热量"
        case .high: return "高热量"
        }
    }

    /// 语义色：绿 / 黄 / 橙红，复用 App 既有 token。
    var color: Color {
        switch self {
        case .low: return .successGreen
        case .medium: return .warningAmber
        case .high: return .exerciseOrange
        }
    }
}

// MARK: - 数据结构

/// 一种常见份量及其热量，如「1 罐 / 330ml → 140 千卡」。
struct FoodPortion: Identifiable {
    let id = UUID()
    let label: String     // 「1 罐」「大瓶」
    let spec: String      // 「330ml」「约150g」，可空
    let calorie: Int
}

/// 一条食物条目。
struct FoodItem: Identifiable {
    let id = UUID()
    let name: String
    let emoji: String
    let unitLabel: String          // 默认计量单位，如「每碗」「每罐」「每100克」
    let calorie: Int               // 默认份量热量（千卡）
    let portions: [FoodPortion]    // 常见份量（≥1 条）

    var level: CalorieLevel { .from(calorie) }

    init(_ name: String, _ emoji: String, unit: String, calorie: Int, portions: [FoodPortion]? = nil) {
        self.name = name
        self.emoji = emoji
        self.unitLabel = unit
        self.calorie = calorie
        self.portions = portions ?? [FoodPortion(label: unit, spec: "", calorie: calorie)]
    }
}

/// 二级标签（品牌 / 子类）。name 为空表示该一级分类无二级标签。
struct FoodSubtab: Identifiable {
    let id = UUID()
    let name: String
    let items: [FoodItem]
}

/// 一级分类。
struct FoodCategory: Identifiable {
    let id = UUID()
    let name: String
    let subtabs: [FoodSubtab]

    /// 是否展示二级标签行。
    var hasSubtabs: Bool {
        subtabs.count > 1 || !(subtabs.first?.name.isEmpty ?? true)
    }
}

// MARK: - 排序

enum FoodSortMode: CaseIterable {
    case `default`, caloriesDesc, caloriesAsc

    var label: String {
        switch self {
        case .default: return "默认排序"
        case .caloriesDesc: return "热量高→低"
        case .caloriesAsc: return "热量低→高"
        }
    }

    var next: FoodSortMode {
        switch self {
        case .default: return .caloriesDesc
        case .caloriesDesc: return .caloriesAsc
        case .caloriesAsc: return .default
        }
    }

    func apply(_ items: [FoodItem]) -> [FoodItem] {
        switch self {
        case .default: return items
        case .caloriesDesc: return items.sorted { $0.calorie > $1.calorie }
        case .caloriesAsc: return items.sorted { $0.calorie < $1.calorie }
        }
    }
}

// MARK: - 内置数据

enum FoodCalorieData {
    static let categories: [FoodCategory] = [
        FoodCategory(name: "主食", subtabs: [
            FoodSubtab(name: "", items: [
                FoodItem("米饭", "🍚", unit: "每碗", calorie: 175,
                         portions: [FoodPortion(label: "1 碗", spec: "约150g", calorie: 175),
                                    FoodPortion(label: "1 小碗", spec: "约100g", calorie: 116)]),
                FoodItem("馒头", "🥟", unit: "每个", calorie: 220),
                FoodItem("白粥", "🥣", unit: "每碗", calorie: 140),
                FoodItem("面条", "🍜", unit: "每碗", calorie: 275),
                FoodItem("肉包", "🥟", unit: "每个", calorie: 230),
                FoodItem("水饺", "🥟", unit: "每10个", calorie: 250),
                FoodItem("全麦面包", "🍞", unit: "每片", calorie: 86),
                FoodItem("蒸红薯", "🍠", unit: "每个", calorie: 172),
                FoodItem("玉米", "🌽", unit: "每根", calorie: 224),
                FoodItem("燕麦片", "🥣", unit: "每份", calorie: 147),
            ])
        ]),

        FoodCategory(name: "快餐", subtabs: [
            FoodSubtab(name: "肯德基", items: [
                FoodItem("吮指原味鸡", "🍗", unit: "每块", calorie: 250),
                FoodItem("香辣鸡腿堡", "🍔", unit: "每个", calorie: 540),
                FoodItem("劲脆鸡腿堡", "🍔", unit: "每个", calorie: 590),
                FoodItem("上校鸡块", "🍗", unit: "每5块", calorie: 275),
                FoodItem("鸡米花", "🍗", unit: "大份", calorie: 390),
                FoodItem("大薯条", "🍟", unit: "大份", calorie: 421),
                FoodItem("中薯条", "🍟", unit: "中份", calorie: 343),
            ]),
            FoodSubtab(name: "麦当劳", items: [
                FoodItem("汉堡包", "🍔", unit: "每个", calorie: 260),
                FoodItem("吉士汉堡", "🍔", unit: "每个", calorie: 310),
                FoodItem("巨无霸", "🍔", unit: "每个", calorie: 500),
                FoodItem("麦辣鸡腿堡", "🍔", unit: "每个", calorie: 570),
                FoodItem("麦香鱼", "🍔", unit: "每个", calorie: 340),
                FoodItem("麦辣鸡翅", "🍗", unit: "每2只", calorie: 240),
                FoodItem("中薯条", "🍟", unit: "中份", calorie: 350),
            ]),
            FoodSubtab(name: "必胜客", items: [
                FoodItem("超级至尊比萨", "🍕", unit: "每片", calorie: 240),
                FoodItem("田园风光比萨", "🍕", unit: "每片", calorie: 210),
                FoodItem("香辣鸡翅", "🍗", unit: "每只", calorie: 110),
                FoodItem("意式肉酱面", "🍝", unit: "每份", calorie: 480),
            ]),
        ]),

        FoodCategory(name: "水果零食", subtabs: [
            FoodSubtab(name: "水果", items: [
                FoodItem("西瓜", "🍉", unit: "每100g", calorie: 25),
                FoodItem("草莓", "🍓", unit: "每100g", calorie: 32),
                FoodItem("橙子", "🍊", unit: "每100g", calorie: 47),
                FoodItem("桃子", "🍑", unit: "每100g", calorie: 48),
                FoodItem("梨", "🍐", unit: "每100g", calorie: 51),
                FoodItem("苹果", "🍎", unit: "每100g", calorie: 52),
                FoodItem("葡萄", "🍇", unit: "每100g", calorie: 54),
                FoodItem("芒果", "🥭", unit: "每100g", calorie: 60),
                FoodItem("香蕉", "🍌", unit: "每100g", calorie: 91),
                FoodItem("牛油果", "🥑", unit: "每100g", calorie: 160),
            ]),
            FoodSubtab(name: "干果", items: [
                FoodItem("红枣（干）", "🌰", unit: "每100g", calorie: 317),
                FoodItem("葡萄干", "🍇", unit: "每100g", calorie: 341),
                FoodItem("腰果", "🥜", unit: "每100g", calorie: 553),
                FoodItem("开心果", "🥜", unit: "每100g", calorie: 562),
                FoodItem("花生", "🥜", unit: "每100g", calorie: 567),
                FoodItem("杏仁", "🌰", unit: "每100g", calorie: 578),
                FoodItem("核桃", "🌰", unit: "每100g", calorie: 654,
                         portions: [FoodPortion(label: "每100g", spec: "", calorie: 654),
                                    FoodPortion(label: "一小把", spec: "约25g", calorie: 164)]),
                FoodItem("夏威夷果", "🌰", unit: "每100g", calorie: 718),
            ]),
            FoodSubtab(name: "零食", items: [
                FoodItem("沙琪玛", "🍬", unit: "每块", calorie: 200),
                FoodItem("苏打饼干", "🍪", unit: "每100g", calorie: 408),
                FoodItem("辣条", "🌶️", unit: "每100g", calorie: 480),
                FoodItem("曲奇饼干", "🍪", unit: "每100g", calorie: 546),
                FoodItem("巧克力", "🍫", unit: "每100g", calorie: 550),
                FoodItem("薯片", "🍟", unit: "每100g", calorie: 555),
                FoodItem("锅巴", "🍘", unit: "每100g", calorie: 564),
            ]),
        ]),

        FoodCategory(name: "饮料", subtabs: [
            FoodSubtab(name: "常见饮料", items: [
                FoodItem("矿泉水", "💧", unit: "每瓶", calorie: 0),
                FoodItem("无糖可乐", "🥤", unit: "每罐", calorie: 1),
                FoodItem("豆浆", "🥛", unit: "每杯", calorie: 93),
                FoodItem("冰红茶", "🧃", unit: "每瓶", calorie: 110),
                FoodItem("红牛", "⚡", unit: "每罐", calorie: 113),
                FoodItem("鲜橙汁", "🧃", unit: "每杯", calorie: 113),
                FoodItem("雪碧", "🥤", unit: "每罐", calorie: 130),
                FoodItem("牛奶", "🥛", unit: "每盒", calorie: 135),
                FoodItem("可口可乐", "🥤", unit: "每罐", calorie: 140,
                         portions: [FoodPortion(label: "1 罐", spec: "330ml", calorie: 140),
                                    FoodPortion(label: "大瓶", spec: "500ml", calorie: 215)]),
                FoodItem("酸奶", "🥛", unit: "每杯", calorie: 145),
                FoodItem("啤酒", "🍺", unit: "每瓶", calorie: 215),
                FoodItem("珍珠奶茶", "🧋", unit: "每杯", calorie: 390),
            ]),
            FoodSubtab(name: "星巴克", items: [
                FoodItem("美式咖啡", "☕", unit: "每中杯", calorie: 15),
                FoodItem("拿铁", "☕", unit: "每中杯", calorie: 240),
                FoodItem("焦糖玛奇朵", "☕", unit: "每中杯", calorie: 290),
                FoodItem("抹茶星冰乐", "🥤", unit: "每中杯", calorie: 420),
            ]),
            FoodSubtab(name: "瑞幸", items: [
                FoodItem("椰云精萃美式", "☕", unit: "每杯", calorie: 80),
                FoodItem("冰拿铁", "☕", unit: "每杯", calorie: 150),
                FoodItem("生椰拿铁", "🥥", unit: "每杯", calorie: 180),
                FoodItem("厚乳拿铁", "☕", unit: "每杯", calorie: 230),
            ]),
            FoodSubtab(name: "Manner", items: [
                FoodItem("美式", "☕", unit: "每杯", calorie: 10),
                FoodItem("拿铁", "☕", unit: "每杯", calorie: 160),
                FoodItem("桂花拿铁", "☕", unit: "每杯", calorie: 220),
            ]),
            FoodSubtab(name: "库迪", items: [
                FoodItem("美式", "☕", unit: "每杯", calorie: 15),
                FoodItem("拿铁", "☕", unit: "每杯", calorie: 170),
                FoodItem("生椰拿铁", "🥥", unit: "每杯", calorie: 200),
            ]),
        ]),
    ]
}
