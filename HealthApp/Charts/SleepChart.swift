// SleepChart.swift
// 睡眠时长柱状图，叠加旅行区间与饮酒事件。

import Charts
import SwiftUI

struct SleepChart: View {
    let samples: [SleepSample]
    let events: [HealthEvent]

    private var sortedSamples: [SleepSample] {
        samples.sorted { $0.date < $1.date }
    }

    private var travelEvents: [HealthEvent] {
        events.filter { $0.type == .travel && $0.isPeriod }
    }

    private var drinkEvents: [HealthEvent] {
        events.filter { $0.type == .drink && !$0.isPeriod }
    }

    var body: some View {
        Chart {
            ForEach(travelEvents) { event in
                RectangleMark(
                    xStart: .value("旅行开始", event.startDate),
                    xEnd: .value("旅行结束", event.endDate ?? event.startDate),
                    yStart: .value("下界", 0),
                    yEnd: .value("上界", 9)
                )
                .foregroundStyle(Color.eventTravelBg.opacity(0.8))
            }

            ForEach(sortedSamples) { sample in
                BarMark(
                    x: .value("日期", sample.date),
                    y: .value("小时", sample.totalHours)
                )
                .foregroundStyle(isTravelDate(sample.date) ? Color.sleepIndigo.opacity(0.48) : Color.sleepIndigo)
                .cornerRadius(4)
            }

            ForEach(drinkEvents) { event in
                PointMark(
                    x: .value("饮酒日期", event.startDate),
                    y: .value("睡眠时长", nearestHours(to: event.startDate) + 0.35)
                )
                .foregroundStyle(Color.eventDrink)
                .symbol {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.eventDrink)
                        .frame(width: 9, height: 9)
                        .rotationEffect(.degrees(45))
                }
            }
        }
        .chartYScale(domain: 0...9)
        .chartYAxis {
            AxisMarks(position: .leading, values: [0, 3, 6, 9]) { value in
                AxisGridLine().foregroundStyle(Color.hairline)
                AxisValueLabel {
                    if let hours = value.as(Int.self) {
                        Text("\(hours)h")
                            .font(.system(size: 9, weight: .medium))
                            .foregroundColor(.textMuted)
                    }
                }
            }
        }
        .chartXAxis {
            AxisMarks(values: .automatic(desiredCount: min(sortedSamples.count, 7))) { value in
                AxisValueLabel(format: .dateTime.day())
                    .font(.system(size: 9, weight: .medium))
                    .foregroundStyle(Color.textMuted)
            }
        }
        .accessibilityLabel("每晚睡眠时长")
    }

    private func isTravelDate(_ date: Date) -> Bool {
        travelEvents.contains { event in
            date >= event.startDate && date <= (event.endDate ?? event.startDate)
        }
    }

    private func nearestHours(to date: Date) -> Double {
        sortedSamples.min {
            abs($0.date.timeIntervalSince(date)) < abs($1.date.timeIntervalSince(date))
        }?.totalHours ?? 0
    }
}
