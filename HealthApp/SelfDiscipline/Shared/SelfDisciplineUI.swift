// SelfDisciplineUI.swift
// 自律打卡的共享 SwiftUI 小组件：任务配色 + 打卡点网格（贡献图风格）。
// App 卡片与桌面 Widget 共用，保证视觉一致。颜色一律走 Color+Tokens（AGENTS §6）。
//
// 共享文件：同时编入主 App 与 Widget extension（Color+Tokens.swift 亦需勾选两端）。

import SwiftUI

extension CheckInTask {
    /// 任务主色（复用既有 token，不散写 hex）。
    var tint: Color {
        switch self {
        case .exercise:  return .exerciseOrange
        case .noSnack:   return .weightGreen
        case .readSleep: return .sleepIndigo
        }
    }
}

/// 打卡点网格：每个任务一行，按日期升序显示是否打卡。
struct CheckInDotGrid: View {
    let rows: [(task: CheckInTask, marks: [Bool])]
    var dotSize: CGFloat = 9
    var spacing: CGFloat = 3
    var showsRowIcon: Bool = true

    var body: some View {
        VStack(alignment: .leading, spacing: spacing) {
            ForEach(rows, id: \.task.id) { row in
                HStack(spacing: spacing) {
                    if showsRowIcon {
                        Image(systemName: row.task.iconName)
                            .font(.system(size: dotSize, weight: .bold))
                            .foregroundColor(row.task.tint)
                            .frame(width: dotSize + 4, alignment: .leading)
                    }
                    ForEach(Array(row.marks.enumerated()), id: \.offset) { _, marked in
                        RoundedRectangle(cornerRadius: dotSize * 0.3, style: .continuous)
                            .fill(marked ? row.task.tint : row.task.tint.opacity(0.12))
                            .frame(width: dotSize, height: dotSize)
                    }
                }
            }
        }
    }
}
