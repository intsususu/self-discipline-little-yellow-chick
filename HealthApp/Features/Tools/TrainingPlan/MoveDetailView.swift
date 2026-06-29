// MoveDetailView.swift
// 小工具 · 训练计划：拉伸 / HIIT 单个动作详情（无解剖图，复用力量详情的视频卡风格）。

import SwiftUI

struct MoveDetailView: View {
    let name: String
    let nameEn: String
    let video: String
    let difficulty: Int
    let metaPairs: [(String, String)]   // 目标 / 类型 等
    let points: [String]                // 动作要点
    let hiitMove: HIITMove?             // 非空时展示热量预估

    @Environment(\.bodyWeightKg) private var weightKg
    @StateObject private var profileStore = ProfileStore()
    private var isFemale: Bool { profileStore.profile.gender == .female }
    private var accent: Color { .exerciseOrange }

    init(name: String, nameEn: String, video: String, difficulty: Int,
         metaPairs: [(String, String)], points: [String] = [], hiitMove: HIITMove? = nil) {
        self.name = name
        self.nameEn = nameEn
        self.video = video
        self.difficulty = difficulty
        self.metaPairs = metaPairs
        self.points = points
        self.hiitMove = hiitMove
    }

    init(stretch: StretchMove) {
        self.init(name: stretch.name, nameEn: stretch.nameEn, video: stretch.video,
                  difficulty: stretch.difficulty,
                  metaPairs: [("部位", stretch.part.displayName), ("目标", stretch.target), ("类型", stretch.kind)],
                  points: stretch.points)
    }

    init(move: HIITMove) {
        self.init(name: move.name, nameEn: move.nameEn, video: move.video,
                  difficulty: move.difficulty,
                  metaPairs: [("类型", move.kind)],
                  points: move.points,
                  hiitMove: move)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                videoCard
                titleCard
                if !points.isEmpty {
                    pointsCard
                }
                if let move = hiitMove, weightKg > 0 {
                    kcalCard(move)
                }
                disclaimer
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 20)
        }
        .background(Color.appBg.ignoresSafeArea())
        .navigationTitle(name)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var videoCard: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.textPrimary)

            VStack(spacing: 10) {
                Image(systemName: video.isEmpty ? "video.slash" : "play.circle.fill")
                    .font(.system(size: 42, weight: .semibold))
                    .foregroundColor(.white)

                Text(video.isEmpty ? "演示视频待补充" : "\(isFemale ? "女版" : "男版")演示视频占位")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)

                if !video.isEmpty {
                    Text("素材到位后自动替换为视频播放")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.white.opacity(0.65))
                }
            }
            .padding(18)
        }
        .aspectRatio(16.0 / 10.0, contentMode: .fit)
        .shadow(color: Color.black.opacity(0.10), radius: 12, x: 0, y: 4)
    }

    private var titleCard: some View {
        CardView {
            VStack(alignment: .leading, spacing: 13) {
                HStack(alignment: .top, spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(name)
                            .font(.system(size: 22, weight: .heavy))
                            .foregroundColor(.textPrimary)
                            .fixedSize(horizontal: false, vertical: true)
                        Text(nameEn)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.textMuted)
                    }
                    Spacer(minLength: 0)
                    DifficultyBadge(level: difficulty)
                }

                VStack(alignment: .leading, spacing: 8) {
                    ForEach(metaPairs, id: \.0) { pair in
                        HStack(alignment: .top, spacing: 8) {
                            Text(pair.0)
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.textSecondary)
                                .frame(width: 36, alignment: .leading)
                            Text(pair.1)
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.textPrimary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
            }
        }
    }

    private var pointsCard: some View {
        CardView {
            VStack(alignment: .leading, spacing: 12) {
                Text("动作要点")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.textPrimary)

                VStack(alignment: .leading, spacing: 8) {
                    ForEach(points, id: \.self) { point in
                        HStack(alignment: .top, spacing: 8) {
                            Circle()
                                .fill(accent)
                                .frame(width: 5, height: 5)
                                .padding(.top, 7)
                            Text(point)
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.textSecondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
            }
        }
    }

    private func kcalCard(_ move: HIITMove) -> some View {
        CardView {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("热量预估")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.textPrimary)
                    Spacer()
                    ExerciseTag(title: "体重 \(Int(weightKg.rounded())) kg",
                                foreground: accent, background: accent.opacity(0.10))
                }

                HStack(spacing: 10) {
                    kcalStat(value: formatKcal(move.kcalPerMinute(weightKg: weightKg)), unit: "千卡/分钟")
                    kcalStat(value: formatKcal(move.estimatedKcal(weightKg: weightKg, seconds: 600)), unit: "千卡/10分钟")
                }

                Text("按当前体重与动作强度（MET \(String(format: "%.1f", move.met))）估算，实际消耗因人而异")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.textMuted)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private func kcalStat(value: String, unit: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(value)
                .font(.system(size: 22, weight: .heavy))
                .foregroundColor(accent)
            Text(unit)
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(accent.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private var disclaimer: some View {
        Text("动作仅供参考，请量力而行，必要时在专业指导下进行")
            .font(.system(size: 11, weight: .medium))
            .foregroundColor(.textMuted)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
            .padding(.top, 2)
    }
}
