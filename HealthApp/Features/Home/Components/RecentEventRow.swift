// RecentEventRow.swift
// 近期事件列表行：类型色点 + 标题 + 日期（单日/时间段）。

import SwiftUI

struct RecentEventRow: View {
    let event: HealthEvent

    var body: some View {
        HStack(spacing: 10) {
            Circle()
                .fill(event.type.color)
                .frame(width: 8, height: 8)

            Text(event.title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.textPrimary)
                .lineLimit(1)

            Spacer()

            Text(Self.dateText(for: event))
                .font(.system(size: 13))
                .foregroundColor(.textSecondary)
        }
        .padding(.vertical, 6)
    }

    private static let dayFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "zh_CN")
        f.dateFormat = "M月d日"
        return f
    }()

    private static let endDayFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "zh_CN")
        f.dateFormat = "d日"
        return f
    }()

    static func dateText(for event: HealthEvent) -> String {
        let start = dayFormatter.string(from: event.startDate)
        guard let end = event.endDate else { return start }
        // 跨月（或跨年）的结束日要带上月份，避免「4月26日–2日」丢掉「5月」。
        let sameMonth = Calendar(identifier: .gregorian)
            .isDate(event.startDate, equalTo: end, toGranularity: .month)
        let endText = (sameMonth ? endDayFormatter : dayFormatter).string(from: end)
        return "\(start)–\(endText)"
    }
}
