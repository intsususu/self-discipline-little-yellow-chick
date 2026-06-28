// HIITWorkouts.swift
// 小工具 · 训练计划：HIIT 按难度分组的组合（顶部「HIIT」tab）+ 组合详情页。
// 动作引用 HIITData 动作池（按英文名）。

import SwiftUI

// MARK: - 难度级别

enum HIITLevel: String, CaseIterable, Identifiable {
    case beginner, intermediate, advanced

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .beginner:     return "入门"
        case .intermediate: return "进阶"
        case .advanced:     return "高阶"
        }
    }

    var subtitle: String {
        switch self {
        case .beginner:     return "低冲击 · 适合初学者起步"
        case .intermediate: return "中等强度 · 持续燃脂"
        case .advanced:     return "高爆发 · 挑战极限心肺"
        }
    }
}

// MARK: - 一组 HIIT 组合

struct HIITWorkout: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let level: HIITLevel
    let rounds: Int          // 循环组数
    let workSec: Int         // 单个动作训练秒数
    let restSec: Int         // 动作间休息秒数
    let moveNames: [String]  // 动作英文名（对应 HIITData）

    var moves: [HIITMove] { moveNames.compactMap { HIITData.move($0) } }

    /// 预计总时长（分钟，含组间休息一并粗算）。
    var totalMinutes: Int {
        let perRound = moveNames.count * (workSec + restSec)
        return max(1, Int((Double(perRound * rounds) / 60.0).rounded()))
    }
}

enum HIITWorkouts {
    static let all: [HIITWorkout] = [
        // MARK: 入门
        HIITWorkout(title: "站立燃脂入门", subtitle: "全程站姿，开合跳带动心率",
                    level: .beginner, rounds: 3, workSec: 30, restSec: 30,
                    moveNames: ["Jumping Jack", "Jack Step", "Astride Jumps", "Low Jacks"]),
        HIITWorkout(title: "低冲击有氧", subtitle: "无跳跃，关节友好",
                    level: .beginner, rounds: 3, workSec: 40, restSec: 20,
                    moveNames: ["Walking on Treadmill", "Air Bike", "Jack Step", "Forward Hops"]),
        // MARK: 进阶
        HIITWorkout(title: "跳绳心肺循环", subtitle: "三种跳绳节奏交替",
                    level: .intermediate, rounds: 4, workSec: 40, restSec: 20,
                    moveNames: ["Jump Rope", "High Knee Jump Rope", "High Jump Rope", "Quick Feet"]),
        HIITWorkout(title: "高抬腿燃脂", subtitle: "下肢主导，持续掉汗",
                    level: .intermediate, rounds: 4, workSec: 30, restSec: 20,
                    moveNames: ["High Knee Run", "Mountain Climber", "High Knee Twist", "Lateral Speed Step"]),
        // MARK: 高阶
        HIITWorkout(title: "爆发力冲刺", subtitle: "波比 + 箱跳，全身爆发",
                    level: .advanced, rounds: 5, workSec: 30, restSec: 30,
                    moveNames: ["Jack Burpee", "Jump Box", "High Knee Sprints", "Wind Sprints"]),
        HIITWorkout(title: "极限心肺挑战", subtitle: "双摇跳绳 + 深度跳，挑战上限",
                    level: .advanced, rounds: 4, workSec: 30, restSec: 30,
                    moveNames: ["Double Under Jump Rope", "Jack Burpee", "Incline Push Up Depth Jump", "Assault Run"]),
    ]

    static func workouts(in level: HIITLevel) -> [HIITWorkout] {
        all.filter { $0.level == level }
    }
}

// MARK: - HIIT 组合详情页

struct HIITWorkoutDetailView: View {
    let workout: HIITWorkout

    @Environment(\.bodyWeightKg) private var weightKg
    @StateObject private var profileStore = ProfileStore()
    private var isFemale: Bool { profileStore.profile.gender == .female }
    private var accent: Color { .exerciseOrange }

    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                headerCard
                moveList
                disclaimer
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 20)
        }
        .background(Color.appBg.ignoresSafeArea())
        .navigationTitle(workout.title)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var headerCard: some View {
        CardView {
            VStack(alignment: .leading, spacing: 12) {
                Text(workout.title)
                    .font(.system(size: 22, weight: .heavy))
                    .foregroundColor(.textPrimary)
                Text(workout.subtitle)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)

                HStack(spacing: 8) {
                    statChip(icon: "flame.fill", text: workout.level.displayName)
                    statChip(icon: "arrow.triangle.2.circlepath", text: "\(workout.rounds) 循环")
                    statChip(icon: "clock.fill", text: "约 \(workout.totalMinutes) 分钟")
                }

                HStack(spacing: 8) {
                    statChip(icon: "bolt.fill", text: "训练 \(workout.workSec)s")
                    statChip(icon: "pause.fill", text: "休息 \(workout.restSec)s")
                    statChip(icon: "list.bullet", text: "\(workout.moves.count) 个动作")
                }

                if weightKg > 0 {
                    kcalBanner
                }
            }
        }
    }

    private var kcalBanner: some View {
        HStack(spacing: 8) {
            Image(systemName: "flame.fill")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(accent)
            VStack(alignment: .leading, spacing: 1) {
                Text("预估消耗 ≈ \(formatKcal(workout.estimatedKcal(weightKg: weightKg))) 千卡")
                    .font(.system(size: 15, weight: .heavy))
                    .foregroundColor(.textPrimary)
                Text("按当前体重 \(Int(weightKg.rounded())) kg 估算，完成全部 \(workout.rounds) 循环")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.textSecondary)
            }
            Spacer(minLength: 0)
        }
        .padding(10)
        .background(accent.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }

    private func statChip(icon: String, text: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon).font(.system(size: 10, weight: .semibold))
            Text(text).font(.system(size: 11, weight: .semibold))
        }
        .foregroundColor(accent)
        .padding(.horizontal, 8)
        .padding(.vertical, 5)
        .background(accent.opacity(0.10))
        .clipShape(Capsule())
    }

    private var moveList: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionTitle(title: "动作循环") {
                Text("× \(workout.rounds) 组")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.textMuted)
            }

            LazyVStack(spacing: 8) {
                ForEach(Array(workout.moves.enumerated()), id: \.element.id) { index, move in
                    NavigationLink {
                        MoveDetailView(move: move)
                    } label: {
                        HStack(spacing: 10) {
                            Text("\(index + 1)")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(accent)
                                .frame(width: 22, height: 22)
                                .background(accent.opacity(0.12))
                                .clipShape(Circle())

                            VStack(alignment: .leading, spacing: 6) {
                                ExerciseRow(hiit: move, accent: accent, isFemale: isFemale)
                                if weightKg > 0 {
                                    HStack(spacing: 5) {
                                        Image(systemName: "flame.fill")
                                            .font(.system(size: 10, weight: .semibold))
                                        Text("\(workout.workSec)s ≈ \(formatKcal(move.estimatedKcal(weightKg: weightKg, seconds: workout.workSec))) 千卡 · 每分钟 \(formatKcal(move.kcalPerMinute(weightKg: weightKg))) 千卡")
                                            .font(.system(size: 12, weight: .semibold))
                                    }
                                    .foregroundColor(accent)
                                    .padding(.leading, 2)
                                }
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var disclaimer: some View {
        Text("HIIT 强度较高，请循序渐进、量力而行，身体不适请立即停止")
            .font(.system(size: 11, weight: .medium))
            .foregroundColor(.textMuted)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
            .padding(.top, 2)
    }
}
