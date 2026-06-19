// HealthApp.swift
// @main 入口。注入全局 AppState（内含 MockHealthRepository，协议类型，便于 T09 替换）。

import SwiftUI

@main
struct HealthApp: App {
    // 切换到 HealthKit 时只需替换这里的仓库实现（T09）。
    @StateObject private var appState = AppState(repository: MockHealthRepository())

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(appState)
                .task { await appState.loadInitialData() }
        }
    }
}
