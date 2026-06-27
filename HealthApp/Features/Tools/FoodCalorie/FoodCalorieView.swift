// FoodCalorieView.swift
// 小工具 · 食品热量表：搜索 + 一级分类 + 二级标签 + 排序 + 列表。
// 见 docs/prd/食品热量表设计.md。纯查询工具，本地内置数据，无入库。

import SwiftUI

struct FoodCalorieView: View {
    @State private var categoryIndex = 0
    @State private var subtabIndex = 0
    @State private var searchText = ""
    @State private var sortMode: FoodSortMode = .default
    @State private var selectedItem: FoodItem?

    private let categories = FoodCalorieData.categories

    private var category: FoodCategory { categories[categoryIndex] }

    /// 当前二级标签（无二级时取第一个）。
    private var subtab: FoodSubtab {
        category.subtabs[min(subtabIndex, category.subtabs.count - 1)]
    }

    /// 当前列表所属分组文案（二级标签名优先，否则一级分类名）。
    private var groupLabel: String {
        subtab.name.isEmpty ? category.name : subtab.name
    }

    /// 经搜索 + 排序后的条目。
    private var visibleItems: [FoodItem] {
        let keyword = searchText.trimmingCharacters(in: .whitespaces)
        let filtered = keyword.isEmpty
            ? subtab.items
            : subtab.items.filter { $0.name.localizedCaseInsensitiveContains(keyword) }
        return sortMode.apply(filtered)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                searchField
                categoryTabs
                if category.hasSubtabs { subtabTabs }
                resultBar
                if visibleItems.isEmpty {
                    emptyState
                } else {
                    foodList
                }
                disclaimer
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 16)
        }
        .background(Color.appBg.ignoresSafeArea())
        .navigationTitle("食品热量表")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $selectedItem) { item in
            FoodDetailSheet(item: item, groupLabel: groupLabel)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
    }

    // MARK: - 搜索框

    private var searchField: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.textMuted)
            TextField("搜索食物名称，如 米饭、苹果、奶茶", text: $searchText)
                .font(.system(size: 14))
                .foregroundColor(.textPrimary)
                .autocorrectionDisabled()
            if !searchText.isEmpty {
                Button { searchText = "" } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 15))
                        .foregroundColor(.textMuted)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 12)
        .frame(height: 42)
        .background(Color.cardBg)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Color.hairline, lineWidth: 1)
        )
    }

    // MARK: - 一级分类

    private var categoryTabs: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(Array(categories.enumerated()), id: \.offset) { index, cat in
                    pill(title: cat.name,
                         selected: index == categoryIndex,
                         selectedColor: .brandBlue) {
                        guard index != categoryIndex else { return }
                        categoryIndex = index
                        subtabIndex = 0          // 切一级分类，二级回到第一项；搜索与排序保留
                    }
                }
            }
            .padding(.horizontal, 2)
        }
    }

    // MARK: - 二级标签

    private var subtabTabs: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                Image(systemName: "tag")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.textMuted)
                ForEach(Array(category.subtabs.enumerated()), id: \.offset) { index, sub in
                    pill(title: sub.name,
                         selected: index == subtabIndex,
                         selectedColor: .textPrimary) {
                        subtabIndex = index
                    }
                }
            }
            .padding(.horizontal, 2)
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

    // MARK: - 结果条（计数 + 排序）

    private var resultBar: some View {
        HStack {
            Text("共 \(visibleItems.count) 种食物")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.textSecondary)
            Spacer()
            Button { sortMode = sortMode.next } label: {
                HStack(spacing: 4) {
                    Image(systemName: "arrow.up.arrow.down")
                        .font(.system(size: 11, weight: .semibold))
                    Text(sortMode.label)
                        .font(.system(size: 12, weight: .semibold))
                }
                .foregroundColor(sortMode == .default ? .textSecondary : .brandBlue)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 2)
    }

    // MARK: - 列表

    private var foodList: some View {
        VStack(spacing: 8) {
            ForEach(visibleItems) { item in
                Button { selectedItem = item } label: {
                    foodRow(item)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func foodRow(_ item: FoodItem) -> some View {
        HStack(spacing: 12) {
            Text(item.emoji)
                .font(.system(size: 22))
                .frame(width: 40, height: 40)
                .background(Color.appBg)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            VStack(alignment: .leading, spacing: 3) {
                Text(item.name)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.textPrimary)
                Text("\(groupLabel) · \(item.unitLabel)")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.textMuted)
            }
            Spacer()
            HStack(spacing: 6) {
                Text("\(item.calorie)")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(item.level.color)
                Text("千卡")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.textMuted)
                Text(item.level.badge)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(item.level.color)
                    .frame(width: 20, height: 20)
                    .background(item.level.color.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color.cardBg)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.hairline, lineWidth: 1)
        )
        .contentShape(Rectangle())
    }

    // MARK: - 空状态

    private var emptyState: some View {
        VStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 34, weight: .light))
                .foregroundColor(.textMuted)
            Text("没有找到「\(searchText)」")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.textPrimary)
            Text("换个关键词，或选择上方分类浏览")
                .font(.system(size: 12))
                .foregroundColor(.textMuted)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 48)
    }

    private var disclaimer: some View {
        Text("热量为常见做法参考值，实际以食材与烹饪方式为准")
            .font(.system(size: 11))
            .foregroundColor(.textMuted)
            .frame(maxWidth: .infinity)
            .padding(.top, 4)
    }
}

#Preview {
    NavigationStack { FoodCalorieView() }
}
