// ExerciseView.swift
// T02 占位页。真实内容由 T06 实现（A5）。

import SwiftUI

struct ExerciseView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        NavigationStack {
            PlaceholderContent(title: "运动", subtitle: "消耗 / 时长 / 心率 / 类型（T06）")
                .navigationTitle("运动")
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
