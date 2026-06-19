// PlaceholderContent.swift
// T02 占位页通用内容。各数据 Tab 真实内容在 T03–T07 各自范围内填充。

import SwiftUI

struct PlaceholderContent: View {
    let title: String
    let subtitle: String

    var body: some View {
        ZStack {
            Color.appBg.ignoresSafeArea()
            VStack(spacing: 8) {
                Text(title)
                    .font(.system(size: 22, weight: .heavy))
                    .foregroundColor(.textPrimary)
                Text(subtitle)
                    .font(.system(size: 14))
                    .foregroundColor(.textSecondary)
            }
        }
    }
}
