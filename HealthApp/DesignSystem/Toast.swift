// Toast.swift
// 顶部浮层 Toast。由 AppState 驱动（message 非空即显示），约 2.2s 自动隐藏的
// 计时逻辑在 AppState 中（见 showToast(_:)）。

import SwiftUI

private struct ToastView: View {
    let message: String

    var body: some View {
        Text(message)
            .font(.system(size: 14, weight: .semibold))
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color.textPrimary.opacity(0.92))
            .clipShape(Capsule())
            .shadow(color: Color.black.opacity(0.18), radius: 10, y: 4)
            .padding(.top, 8)
    }
}

private struct ToastModifier: ViewModifier {
    let message: String?

    func body(content: Content) -> some View {
        content.overlay(alignment: .top) {
            if let message {
                ToastView(message: message)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .zIndex(1)
            }
        }
        .animation(.easeInOut(duration: 0.25), value: message)
    }
}

extension View {
    /// 顶部 Toast：传入非空文案即显示。
    func toast(message: String?) -> some View {
        modifier(ToastModifier(message: message))
    }
}
