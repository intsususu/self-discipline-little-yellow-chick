// ProfileView.swift
// T02 占位页。真实内容由 T07 实现（A6，含目标体重编辑）。

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        NavigationStack {
            PlaceholderContent(title: "我的", subtitle: "画像 / 目标体重 / 设置（T07）")
                .navigationTitle("我的")
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button { appState.presentEventEditor() } label: {
                            Image(systemName: "plus")
                        }
                        .tint(.brandBlue)
                    }
                }
        }
    }
}
