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
    let points: [String]    // 动作要点

    init(_ name: String, _ nameEn: String, kind: String, difficulty: Int, video: String,
         points: [String] = []) {
        self.name = name
        self.nameEn = nameEn
        self.kind = kind
        self.difficulty = difficulty
        self.video = video
        self.points = points
    }
}

enum HIITData {
    static let moves: [HIITMove] = [
        HIITMove("空中蹬车", "Air Bike", kind: "循环机/蹬车", difficulty: 2, video: "Air-Bike.mp4", points: ["坐稳握把，手脚协调蹬动", "核心稳定、背不晃", "按节奏调整阻力与速度"]),
        HIITMove("冲刺跑", "Assault Run", kind: "冲刺/短跑", difficulty: 4, video: "Assault-Run.mp4", points: ["全力冲刺、手臂大幅摆动", "前脚掌着地、步频快", "充分热身、量力进行"]),
        HIITMove("跨步开合跳", "Astride Jumps", kind: "开合跳", difficulty: 2, video: "Astride-Jumps.mp4", points: ["前后跨步同时摆臂", "前脚掌轻落缓冲", "保持节奏与呼吸"]),
        HIITMove("倒跑", "Backwards Run", kind: "跑步", difficulty: 3, video: "Backwards Run.mp4", points: ["向后小步慢跑、注意身后", "前脚掌着地缓冲", "选空旷安全场地"]),
        HIITMove("交叉开合跳", "Cross Jacks", kind: "开合跳", difficulty: 2, video: "Cross Jacks.mp4", points: ["开合跳基础上手脚在身前交叉", "落地轻、屈膝缓冲", "核心收紧"]),
        HIITMove("双摇跳绳", "Double Under Jump Rope", kind: "跳绳", difficulty: 4, video: "Double Under Jump Rope.mp4", points: ["一跳绳过两圈、手腕快速摇动", "起跳略高、身体绷直", "高阶动作，循序渐进"]),
        HIITMove("向前跳", "Forward Hops", kind: "跳跃", difficulty: 2, video: "Forward-Hops.mp4", points: ["双脚并拢连续向前跳", "屈膝缓冲、落地轻", "核心收紧保持平衡"]),
        HIITMove("蛙跳", "Frog Hops", kind: "跳跃", difficulty: 2, video: "Frog Hops.mp4", points: ["深蹲后向前爆发跳出", "落地屈髋屈膝缓冲", "量力进行、护膝"]),
        HIITMove("蛙式跳跃", "Frogger", kind: "跳跃", difficulty: 2, video: "Frogger.mp4", points: ["俯撑姿双脚跳向手外侧再跳回", "保持核心稳定", "节奏均匀"]),
        HIITMove("手部单车", "Hands Bike", kind: "循环机/蹬车", difficulty: 1, video: "Hands Bike.mp4", points: ["坐稳摇动手柄、上肢发力", "背挺直不晃", "按节奏调整"]),
        HIITMove("高位跳绳", "High Jump Rope", kind: "跳绳", difficulty: 3, video: "High Jump Rope.mp4", points: ["原地跳绳、起跳略高", "前脚掌着地缓冲", "手腕摇绳、肩放松"]),
        HIITMove("靠墙高抬腿", "High Knee Against Wall", kind: "高抬腿", difficulty: 3, video: "High Knee Against Wall.mp4", points: ["双手扶墙、身体前倾", "交替快速高抬膝至髋高", "核心收紧、步频快"]),
        HIITMove("高抬腿跳绳", "High Knee Jump Rope", kind: "跳绳", difficulty: 3, video: "High Knee Jump Rope.mp4", points: ["跳绳同时交替高抬膝", "前脚掌着地、节奏快", "上身稳定"]),
        HIITMove("高抬腿跑", "High Knee Run", kind: "高抬腿", difficulty: 3, video: "High-Knee-Run.mp4", points: ["原地交替高抬膝至髋高", "摆臂配合、前脚掌着地", "核心收紧、步频快"]),
        HIITMove("高抬腿跨步跳", "High Knee Skips", kind: "高抬腿", difficulty: 3, video: "High Knee Skips.mp4", points: ["跨步跳同时抬膝", "摆臂协调、落地缓冲", "保持节奏"]),
        HIITMove("高抬腿冲刺", "High Knee Sprints", kind: "高抬腿", difficulty: 4, video: "High Knee Sprints.mp4", points: ["全力高抬腿快速冲刺", "步频极快、摆臂有力", "量力进行"]),
        HIITMove("高抬腿转体", "High Knee Twist", kind: "高抬腿", difficulty: 3, video: "High Knee Twist.mp4", points: ["高抬膝同时上身向对侧转", "肘膝靠拢挤压腹斜肌", "核心收紧"]),
        HIITMove("高抬腿接后踢腿", "High Knees Butt Kicks", kind: "高抬腿", difficulty: 3, video: "High Knees Butt Kicks.mp4", points: ["高抬膝与后踢脚跟交替", "前脚掌着地、节奏快", "上身稳定"]),
        HIITMove("上斜俯卧撑深度跳", "Incline Push Up Depth Jump", kind: "跳跃", difficulty: 4, video: "Incline Push Up Depth Jump.mp4", points: ["手撑高处做俯卧撑后爆发推离", "落地缓冲再连续", "高阶动作、量力进行"]),
        HIITMove("开合波比跳", "Jack Burpee", kind: "开合跳", difficulty: 4, video: "Jack Burpee.mp4", points: ["下蹲撑地、后撤成俯撑", "起跳时加开合跳", "落地缓冲、全程核心收紧"]),
        HIITMove("开合跳", "Jack Jump", kind: "开合跳", difficulty: 2, video: "Jack Jump.mp4", points: ["跳起同时双脚开合、双手过头", "前脚掌轻落缓冲", "保持节奏与呼吸"]),
        HIITMove("开合踏步", "Jack Step", kind: "开合跳", difficulty: 2, video: "Jack Step.mp4", points: ["低冲击版开合：踏步替代跳", "手臂同步开合", "适合热身/初学"]),
        HIITMove("箱跳", "Jump Box", kind: "跳跃", difficulty: 4, video: "Jump-Box.mp4", points: ["屈髋摆臂爆发跳上箱", "全脚掌稳落、屈膝缓冲", "稳步下箱、量力选高度"]),
        HIITMove("跳绳", "Jump Rope", kind: "跳绳", difficulty: 3, video: "Jump-Rope.mp4", points: ["手腕摇绳、前脚掌轻跳", "起跳幅度小、肩放松", "保持均匀节奏"]),
        HIITMove("跳跃耸肩", "Jump Shrug", kind: "跳跃", difficulty: 2, video: "Jump-Shrug.mp4", points: ["屈髋下沉后爆发伸髋耸肩起跳", "落地缓冲", "靠髋与斜方爆发"]),
        HIITMove("分腿跳", "Jump Split", kind: "跳跃", difficulty: 2, video: "Jump Split.mp4", points: ["弓步姿、跳起空中换腿", "落地屈膝缓冲、躯干直立", "保持平衡"]),
        HIITMove("开合跳", "Jumping Jack", kind: "开合跳", difficulty: 2, video: "Jumping-Jack.mp4", points: ["跳起双脚开合、双手过头拍合", "前脚掌着地缓冲", "节奏均匀、呼吸顺畅"]),
        HIITMove("跳跃引体向上", "Jumping Pull Up", kind: "跳跃", difficulty: 2, video: "Jumping Pull Up.mp4", points: ["借腿蹬地跳起辅助拉起过杠", "控制下放", "适合引体进阶过渡"]),
        HIITMove("侧向跨跳", "Lateral Bound", kind: "跳跃", difficulty: 2, video: "Lateral Bound.mp4", points: ["单腿侧蹬跨向另一侧", "对侧腿屈膝稳落缓冲", "左右交替练爆发"]),
        HIITMove("侧向快速踏步", "Lateral Speed Step", kind: "快速脚步", difficulty: 3, video: "Lateral Speed Step.mp4", points: ["低位侧向快速移动脚步", "重心压低、核心收紧", "节奏快而稳"]),
        HIITMove("低位开合跳", "Low Jacks", kind: "开合跳", difficulty: 2, video: "Low Jacks.mp4", points: ["半蹲位做开合跳", "重心压低、落地轻", "持续刺激下肢"]),
        HIITMove("登山跑", "Mountain Climber", kind: "登山跑", difficulty: 3, video: "Mountain-Climber.mp4", points: ["俯撑姿交替快速收膝向胸", "髋不抬高、核心收紧", "节奏快、保持平板"]),
        HIITMove("快速脚步", "Quick Feet", kind: "快速脚步", difficulty: 3, video: "Quick-Feet.mp4", points: ["重心压低、前脚掌快速原地踏动", "上身略前倾、摆臂", "步频越快越好"]),
        HIITMove("跑步", "Run", kind: "跑步", difficulty: 3, video: "Run.mp4", points: ["上身放松、摆臂自然", "前/中脚掌着地缓冲", "呼吸均匀、循序渐进"]),
        HIITMove("跑步机跑步", "Run on Treadmill", kind: "跑步", difficulty: 3, video: "Run-on-Treadmill.mp4", points: ["居中跑、目视前方", "前/中脚掌着地", "按需调速度坡度、充分热身"]),
        HIITMove("垂直登山跑", "Vertical Mountain Climber", kind: "登山跑", difficulty: 3, video: "Vertical-Mountain-Climber.mp4", points: ["俯撑姿垂直方向快速提膝", "核心收紧、髋稳定", "节奏快"]),
        HIITMove("步行", "Walking", kind: "步行", difficulty: 1, video: "Walking.mp4", points: ["挺胸抬头、自然摆臂", "脚跟到脚尖滚动着地", "保持均匀步频"]),
        HIITMove("上坡跑步机步行", "Walking on Incline Treadmill", kind: "跑步", difficulty: 2, video: "Walking on Incline Treadmill.mp4", points: ["设坡度、挺胸快走", "不抓扶手、自然摆臂", "前掌发力蹬地"]),
        HIITMove("跑步机步行", "Walking on Treadmill", kind: "跑步", difficulty: 2, video: "Walking on Treadmill.mp4", points: ["居中行走、目视前方", "自然摆臂、脚跟先着地", "按需调速度"]),
        HIITMove("轮式跑", "Wheel Run", kind: "跑步", difficulty: 3, video: "Wheel Run.mp4", points: ["借器械做轮转式跑动", "核心收紧、节奏稳定", "量力进行"]),
        HIITMove("冲刺跑", "Wind Sprints", kind: "冲刺/短跑", difficulty: 4, video: "Wind Sprints.mp4", points: ["短距全力冲刺、间歇恢复", "前脚掌着地、摆臂有力", "充分热身防拉伤"]),
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
