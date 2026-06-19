// EventEditorPlaceholderView.swift
// T02 占位 sheet。真实记录表单（E2）由 T08 实现，并打通全局＋入口与图表叠加。

import SwiftUI

struct EventEditorPlaceholderView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBg.ignoresSafeArea()
                VStack(spacing: 10) {
                    Image(systemName: "square.and.pencil")
                        .font(.system(size: 36))
                        .foregroundColor(.textMuted)
                    Text("事件记录开发中")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.textPrimary)
                    Text("记录功能将在后续版本上线（T08）")
                        .font(.system(size: 13))
                        .foregroundColor(.textSecondary)
                }
            }
            .navigationTitle("新建事件")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("取消") { dismiss() }
                        .tint(.brandBlue)
                }
            }
        }
    }
}
