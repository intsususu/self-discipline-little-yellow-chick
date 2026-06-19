// SleepView.swift
// T02 占位页。真实内容由 T05 实现（A4）。

import SwiftUI

struct SleepView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        NavigationStack {
            PlaceholderContent(title: "睡眠", subtitle: "睡眠时长 / 效率 / 阶段（T05）")
                .navigationTitle("睡眠")
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
