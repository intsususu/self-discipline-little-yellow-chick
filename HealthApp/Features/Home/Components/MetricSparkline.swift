// MetricSparkline.swift
// 首页 hero 卡通用的「按日趋势」小折线（静态，无坐标轴）。指定主题色复用。

import SwiftUI
import Charts

struct MetricSparkline: View {
    let points: [DailyMetric]
    var color: Color = .brandBlue
    var height: CGFloat = 44

    var body: some View {
        Chart(points) { point in
            LineMark(
                x: .value("日期", point.date),
                y: .value("数值", point.value)
            )
            .interpolationMethod(.catmullRom)
            .foregroundStyle(color)
            .lineStyle(StrokeStyle(lineWidth: 2.5, lineCap: .round))

            AreaMark(
                x: .value("日期", point.date),
                yStart: .value("趋势基线", yDomain.lowerBound),
                yEnd: .value("数值", point.value)
            )
            .interpolationMethod(.catmullRom)
            .foregroundStyle(
                LinearGradient(
                    colors: [color.opacity(0.22), color.opacity(0.0)],
                    startPoint: .top, endPoint: .bottom
                )
            )
        }
        .chartXAxis(.hidden)
        .chartYAxis(.hidden)
        .chartYScale(domain: yDomain)
        .frame(height: height)
    }

    /// 按当前窗口自适应刻度，同时保留最少 0.5 单位的上下留白。
    private var yDomain: ClosedRange<Double> {
        guard let minimum = points.map(\.value).min(),
              let maximum = points.map(\.value).max() else {
            return 0...1
        }
        let padding = max((maximum - minimum) * 0.15, 0.5)
        return (minimum - padding)...(maximum + padding)
    }
}
