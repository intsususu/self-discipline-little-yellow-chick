// HIITData.swift
// 小工具 · 训练计划：HIIT / 有氧 / 敏捷 / 跳跃动作池（数据源 docs/fitness/full-body-mobility.md，41 个）。
// 动作池由 scratchpad/gen_stretch_hiit.py 生成；HIITWorkout 组合在 HIITWorkouts.swift 手工编排。

import SwiftUI

// MARK: - 一个 HIIT 动作

struct HIITMove: Identifiable {
    let id = UUID()
    let name: String
    let nameEn: String
    let kind: String        // 类型：跑步 / 跳绳 / 开合跳 / 高抬腿 / 跳跃 / 登山跑 …
    let difficulty: Int
    let video: String

    init(_ name: String, _ nameEn: String, kind: String, difficulty: Int, video: String) {
        self.name = name
        self.nameEn = nameEn
        self.kind = kind
        self.difficulty = difficulty
        self.video = video
    }
}

enum HIITData {
    static let moves: [HIITMove] = [
        HIITMove("空中蹬车", "Air Bike", kind: "循环机/蹬车", difficulty: 2, video: "Air-Bike.mp4"),
        HIITMove("冲刺跑", "Assault Run", kind: "冲刺/短跑", difficulty: 4, video: "Assault-Run.mp4"),
        HIITMove("跨步开合跳", "Astride Jumps", kind: "开合跳", difficulty: 2, video: "Astride-Jumps.mp4"),
        HIITMove("倒跑", "Backwards Run", kind: "跑步", difficulty: 3, video: "Backwards Run.mp4"),
        HIITMove("交叉开合跳", "Cross Jacks", kind: "开合跳", difficulty: 2, video: "Cross Jacks.mp4"),
        HIITMove("双摇跳绳", "Double Under Jump Rope", kind: "跳绳", difficulty: 4, video: "Double Under Jump Rope.mp4"),
        HIITMove("向前跳", "Forward Hops", kind: "跳跃", difficulty: 2, video: "Forward-Hops.mp4"),
        HIITMove("蛙跳", "Frog Hops", kind: "跳跃", difficulty: 2, video: "Frog Hops.mp4"),
        HIITMove("蛙式跳跃", "Frogger", kind: "跳跃", difficulty: 2, video: "Frogger.mp4"),
        HIITMove("手部单车", "Hands Bike", kind: "循环机/蹬车", difficulty: 1, video: "Hands Bike.mp4"),
        HIITMove("高位跳绳", "High Jump Rope", kind: "跳绳", difficulty: 3, video: "High Jump Rope.mp4"),
        HIITMove("靠墙高抬腿", "High Knee Against Wall", kind: "高抬腿", difficulty: 3, video: "High Knee Against Wall.mp4"),
        HIITMove("高抬腿跳绳", "High Knee Jump Rope", kind: "跳绳", difficulty: 3, video: "High Knee Jump Rope.mp4"),
        HIITMove("高抬腿跑", "High Knee Run", kind: "高抬腿", difficulty: 3, video: "High-Knee-Run.mp4"),
        HIITMove("高抬腿跨步跳", "High Knee Skips", kind: "高抬腿", difficulty: 3, video: "High Knee Skips.mp4"),
        HIITMove("高抬腿冲刺", "High Knee Sprints", kind: "高抬腿", difficulty: 4, video: "High Knee Sprints.mp4"),
        HIITMove("高抬腿转体", "High Knee Twist", kind: "高抬腿", difficulty: 3, video: "High Knee Twist.mp4"),
        HIITMove("高抬腿接后踢腿", "High Knees Butt Kicks", kind: "高抬腿", difficulty: 3, video: "High Knees Butt Kicks.mp4"),
        HIITMove("上斜俯卧撑深度跳", "Incline Push Up Depth Jump", kind: "跳跃", difficulty: 4, video: "Incline Push Up Depth Jump.mp4"),
        HIITMove("开合波比跳", "Jack Burpee", kind: "开合跳", difficulty: 4, video: "Jack Burpee.mp4"),
        HIITMove("开合跳", "Jack Jump", kind: "开合跳", difficulty: 2, video: "Jack Jump.mp4"),
        HIITMove("开合踏步", "Jack Step", kind: "开合跳", difficulty: 2, video: "Jack Step.mp4"),
        HIITMove("箱跳", "Jump Box", kind: "跳跃", difficulty: 4, video: "Jump-Box.mp4"),
        HIITMove("跳绳", "Jump Rope", kind: "跳绳", difficulty: 3, video: "Jump-Rope.mp4"),
        HIITMove("跳跃耸肩", "Jump Shrug", kind: "跳跃", difficulty: 2, video: "Jump-Shrug.mp4"),
        HIITMove("分腿跳", "Jump Split", kind: "跳跃", difficulty: 2, video: "Jump Split.mp4"),
        HIITMove("开合跳", "Jumping Jack", kind: "开合跳", difficulty: 2, video: "Jumping-Jack.mp4"),
        HIITMove("跳跃引体向上", "Jumping Pull Up", kind: "跳跃", difficulty: 2, video: "Jumping Pull Up.mp4"),
        HIITMove("侧向跨跳", "Lateral Bound", kind: "跳跃", difficulty: 2, video: "Lateral Bound.mp4"),
        HIITMove("侧向快速踏步", "Lateral Speed Step", kind: "快速脚步", difficulty: 3, video: "Lateral Speed Step.mp4"),
        HIITMove("低位开合跳", "Low Jacks", kind: "开合跳", difficulty: 2, video: "Low Jacks.mp4"),
        HIITMove("登山跑", "Mountain Climber", kind: "登山跑", difficulty: 3, video: "Mountain-Climber.mp4"),
        HIITMove("快速脚步", "Quick Feet", kind: "快速脚步", difficulty: 3, video: "Quick-Feet.mp4"),
        HIITMove("跑步", "Run", kind: "跑步", difficulty: 3, video: "Run.mp4"),
        HIITMove("跑步机跑步", "Run on Treadmill", kind: "跑步", difficulty: 3, video: "Run-on-Treadmill.mp4"),
        HIITMove("垂直登山跑", "Vertical Mountain Climber", kind: "登山跑", difficulty: 3, video: "Vertical-Mountain-Climber.mp4"),
        HIITMove("步行", "Walking", kind: "步行", difficulty: 1, video: "Walking.mp4"),
        HIITMove("上坡跑步机步行", "Walking on Incline Treadmill", kind: "跑步", difficulty: 2, video: "Walking on Incline Treadmill.mp4"),
        HIITMove("跑步机步行", "Walking on Treadmill", kind: "跑步", difficulty: 2, video: "Walking on Treadmill.mp4"),
        HIITMove("轮式跑", "Wheel Run", kind: "跑步", difficulty: 3, video: "Wheel Run.mp4"),
        HIITMove("冲刺跑", "Wind Sprints", kind: "冲刺/短跑", difficulty: 4, video: "Wind Sprints.mp4"),
    ]

    static func move(_ nameEn: String) -> HIITMove? {
        moves.first { $0.nameEn == nameEn }
    }

    static func search(_ keyword: String) -> [HIITMove] {
        let key = keyword.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !key.isEmpty else { return [] }
        return moves.filter {
            $0.name.lowercased().contains(key)
                || $0.nameEn.lowercased().contains(key)
                || $0.kind.lowercased().contains(key)
        }
    }
}
