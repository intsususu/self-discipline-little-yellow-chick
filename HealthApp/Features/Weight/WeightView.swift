// WeightView.swift
// T02 占位页。真实内容由 T04 实现（A2 / E3）。

import SwiftUI

struct WeightView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        NavigationStack {
            PlaceholderContent(title: "体重", subtitle: "体重趋势与事件叠加（T04）")
                .navigationTitle("体重")
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
