// SplashView.swift
// 程序启动页：首页数据加载完成前，按星期全屏展示对应品牌图。
// 由 HealthApp.swift 依据 AppState.isInitialLoadComplete 叠加在内容之上。

import SwiftUI

struct SplashView: View {
    private let imageName: String

    init(date: Date = Date(), calendar: Calendar = .current) {
        let weekday = calendar.component(.weekday, from: date)
        imageName = Self.imageNamesByWeekday[weekday] ?? "FitnessSplashBlue"
    }

    // Calendar weekday: 周日为 1，周一为 2，依次至周六为 7。
    private static let imageNamesByWeekday = [
        1: "FitnessSplashWhite",
        2: "FitnessSplashBlue",
        3: "FitnessSplashGreen",
        4: "FitnessSplashYellow",
        5: "FitnessSplashRed",
        6: "FitnessSplashPurple",
        7: "FitnessSplashBlack"
    ]

    var body: some View {
        ZStack {
            Color.appBg
                .ignoresSafeArea()

            Image(imageName)
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .accessibilityHidden(true)

            VStack {
                Spacer()
                ProgressView()
                    .progressViewStyle(.circular)
                    .tint(.brandBlue)
                    .padding(.bottom, 48)
            }
        }
    }
}

#Preview {
    SplashView()
}
