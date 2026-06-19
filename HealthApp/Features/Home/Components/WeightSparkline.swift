// WeightSparkline.swift
// 首页体重 Hero 卡的周趋势小折线（静态，无坐标轴）。

import SwiftUI
import Charts

struct WeightSparkline: View {
    let samples: [WeightSample]

    var body: some View {
        Chart(samples) { sample in
            LineMark(
                x: .value("日期", sample.date),
                y: .value("体重", sample.kg)
            )
            .interpolationMethod(.catmullRom)
            .foregroundStyle(Color.brandBlue)
            .lineStyle(StrokeStyle(lineWidth: 2.5, lineCap: .round))

            AreaMark(
                x: .value("日期", sample.date),
                y: .value("体重", sample.kg)
            )
            .interpolationMethod(.catmullRom)
            .foregroundStyle(
                LinearGradient(
                    colors: [Color.brandBlue.opacity(0.22), Color.brandBlue.opacity(0.0)],
                    startPoint: .top, endPoint: .bottom
                )
            )
        }
        .chartXAxis(.hidden)
        .chartYAxis(.hidden)
        .chartYScale(domain: .automatic(includesZero: false))
        .frame(height: 56)
    }
}
