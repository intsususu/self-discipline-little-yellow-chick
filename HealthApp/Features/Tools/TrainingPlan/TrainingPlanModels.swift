// TrainingPlanModels.swift
// 小工具 · 训练计划：动作库数据模型 + 内置内容（7 类共 92 个动作）。
// 数据源 docs/fitness/index.md，由 scratchpad/gen_exercises.py 解析生成（见 docs/tasks/训练计划重构/TP01-数据层.md）。
// 视频字段为占位（仓库暂无 mp4），素材到位后接入；演示性别按个人资料自动匹配（见 TP02/TP03）。

import SwiftUI
import UIKit

// MARK: - 顶部三大类

enum TrainingMode: String, CaseIterable, Identifiable {
    case strength, stretch, hiit

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .strength: return "力量训练"
        case .stretch:  return "拉伸"
        case .hiit:     return "HIIT"
        }
    }
}

// MARK: - 训练分类（7 类）

enum MuscleCategory: String, CaseIterable, Identifiable {
    case core, chest, back, shoulders, arms, lower

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .core:       return "核心"
        case .chest:      return "胸"
        case .back:       return "背"
        case .shoulders:  return "肩"
        case .arms:       return "手臂"
        case .lower:      return "腿"
        }
    }
}

// MARK: - 肌群（用于解剖图高亮 / 按肌群筛选）
// rawValue 即 slug，对齐 react-native-body-highlighter（MIT），便于 TP04 复用其人体 path。

enum MuscleGroup: String, CaseIterable, Identifiable {
    case abs
    case obliques
    case chest
    case biceps
    case triceps
    case forearm
    case frontDeltoids = "front-deltoids"
    case deltoids
    case rearDeltoids = "rear-deltoids"
    case trapezius
    case upperBack = "upper-back"
    case lowerBack = "lower-back"
    case quadriceps
    case hamstring
    case gluteal
    case calves
    case adductor
    case abductors
    case neck

    var id: String { rawValue }
    var slug: String { rawValue }

    var displayName: String {
        switch self {
        case .abs:           return "腹肌"
        case .obliques:      return "腹斜肌"
        case .chest:         return "胸大肌"
        case .biceps:        return "肱二头肌"
        case .triceps:       return "肱三头肌"
        case .forearm:       return "前臂"
        case .frontDeltoids: return "三角肌前束"
        case .deltoids:      return "三角肌中束"
        case .rearDeltoids:  return "三角肌后束"
        case .trapezius:     return "斜方肌"
        case .upperBack:     return "背阔肌"
        case .lowerBack:     return "下背"
        case .quadriceps:    return "股四头肌"
        case .hamstring:     return "腘绳肌"
        case .gluteal:       return "臀大肌"
        case .calves:        return "小腿"
        case .adductor:      return "内收肌"
        case .abductors:     return "外展肌"
        case .neck:          return "颈部"
        }
    }
}

// MARK: - 一个训练动作

struct Exercise: Identifiable {
    let id = UUID()
    let name: String                 // 中文名
    let nameEn: String               // 英文名
    let category: MuscleCategory     // 所属训练分类
    let primaryMuscles: [String]     // 主练肌群（展示用中文，首项为主）
    let muscleGroups: [MuscleGroup]  // 解剖图高亮 / 筛选用，主练在前
    let type: String                 // 动作类型（如「卧推/胸推」「下拉」）
    let difficulty: Int              // 难度 1–5
    let maleVideo: String            // 男版演示视频文件名（占位期可空）
    let femaleVideo: String          // 女版演示视频文件名（占位期可空）
    let image: String                // 演示图（Assets 资源名，默认与英文名一致）
    let points: [String]             // 动作要点（index.md 无，暂空，详情页降级）
    let setsReps: String             // 建议组数 × 次数（暂空）

    init(_ name: String, _ nameEn: String, category: MuscleCategory,
         primaryMuscles: [String], muscleGroups: [MuscleGroup],
         type: String, difficulty: Int,
         maleVideo: String, femaleVideo: String,
         image: String? = nil,
         points: [String] = [], setsReps: String = "") {
        self.name = name
        self.nameEn = nameEn
        self.category = category
        self.primaryMuscles = primaryMuscles
        self.muscleGroups = muscleGroups
        self.type = type
        self.difficulty = difficulty
        self.maleVideo = maleVideo
        self.femaleVideo = femaleVideo
        self.image = image ?? nameEn
        self.points = points
        self.setsReps = setsReps
    }

    /// 是否有演示图（Assets 中存在同名资源）。
    var hasImage: Bool { UIImage(named: image) != nil }

    /// 按性别取演示视频文件名（女版优先用 female，其余用 male）。占位期可能为空。
    func video(female: Bool) -> String {
        female ? femaleVideo : maleVideo
    }

    var hasVideo: Bool { !maleVideo.isEmpty || !femaleVideo.isEmpty }
}

// MARK: - 查询接口（供 TP02 主页 / TP04 解剖图调用）

extension TrainingPlanData {
    /// 某分类下的全部动作（保持内置顺序）。
    static func exercises(in category: MuscleCategory) -> [Exercise] {
        exercises.filter { $0.category == category }
    }

    /// 练某肌群的全部动作。
    static func exercises(for muscle: MuscleGroup) -> [Exercise] {
        exercises.filter { $0.muscleGroups.contains(muscle) }
    }

    /// 关键词搜索：匹配中文名 / 英文名 / 主练肌群 / 类型（忽略大小写）。
    static func search(_ keyword: String) -> [Exercise] {
        let key = keyword.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !key.isEmpty else { return [] }
        return exercises.filter { ex in
            ex.name.lowercased().contains(key)
                || ex.nameEn.lowercased().contains(key)
                || ex.type.lowercased().contains(key)
                || ex.primaryMuscles.contains { $0.lowercased().contains(key) }
        }
    }

    /// 按英文名精确查找动作（供训练计划预设引用）。
    static func exercise(_ nameEn: String) -> Exercise? {
        exercises.first { $0.nameEn == nameEn }
    }

    /// 某分类下出现的动作类型（按首次出现顺序去重），供类型筛选 chips 使用。
    static func types(in category: MuscleCategory) -> [String] {
        var seen = Set<String>()
        var result: [String] = []
        for ex in exercises(in: category) where seen.insert(ex.type).inserted {
            result.append(ex.type)
        }
        return result
    }
}

// MARK: - 内置内容（76 个，对齐 docs/fitness/力量训练.md：核心16/胸13/背13/肩13/手臂9/腿12）
// 演示图取自 docs/fitness/strength-tranning-images，已导入 Assets（资源名 = 英文名）。

enum TrainingPlanData {
    static let exercises: [Exercise] = [
        // MARK: core (16)
        Exercise("罗马椅举腿", "Captains Chair Leg Raise", category: .core,
                 primaryMuscles: ["腹直肌", "髂腰肌"], muscleGroups: [.abs],
                 type: "举腿/屈髋", difficulty: 2,
                 maleVideo: "Captains Chair Leg Raise.mp4", femaleVideo: "Captains Chair Leg Raise.mp4",
                 points: ["背部贴紧靠垫，前臂稳定支撑身体", "呼气收腹卷骨盆带动抬腿，而非甩腿借惯性", "顶峰略停，吸气缓慢下放，全程不晃动"]),
        Exercise("死虫式", "Dead Bug", category: .core,
                 primaryMuscles: ["腹横肌", "腹直肌"], muscleGroups: [.abs],
                 type: "举腿/屈髋", difficulty: 1,
                 maleVideo: "Dead-Bug.mp4", femaleVideo: "Dead-Bug.mp4",
                 points: ["仰卧，下背贴紧地面不留缝隙", "对侧手脚同时缓慢伸出，呼气收紧核心", "全程腰背不拱起，缓慢有控制地交替"]),
        Exercise("悬垂举腿", "Hanging Leg Raise", category: .core,
                 primaryMuscles: ["腹直肌", "髂腰肌"], muscleGroups: [.abs],
                 type: "举腿/屈髋", difficulty: 3,
                 maleVideo: "Hanging Leg Raise.mp4", femaleVideo: "Hanging Leg Raise.mp4",
                 points: ["正握悬垂，肩胛下沉别耸肩", "收腹卷骨盆把腿抬到水平以上，避免身体摆荡", "下放时控制节奏，保持躯干不晃"]),
        Exercise("仰卧举腿", "Lying Leg Raise", category: .core,
                 primaryMuscles: ["腹直肌", "髂腰肌"], muscleGroups: [.abs],
                 type: "举腿/屈髋", difficulty: 2,
                 maleVideo: "Lying-Leg-Raise.mp4", femaleVideo: "Lying-Leg-Raise.mp4",
                 points: ["仰卧，双手压地或垫于臀下稳定骨盆", "下背贴地，靠腹部发力抬腿", "下放至接近地面即止，不让腰拱起"]),
        Exercise("卷腹起身", "Curl up", category: .core,
                 primaryMuscles: ["腹直肌"], muscleGroups: [.abs],
                 type: "卷腹", difficulty: 1,
                 maleVideo: "Curl-up.mp4", femaleVideo: "Curl-up.mp4",
                 points: ["仰卧屈膝，下巴微收不夹紧", "呼气用腹部把肩胛卷离地面，腰仍贴地", "顶端略停，缓慢还原，避免用脖子发力"]),
        Exercise("下斜卷腹", "Decline Crunch", category: .core,
                 primaryMuscles: ["腹直肌"], muscleGroups: [.abs],
                 type: "卷腹", difficulty: 2,
                 maleVideo: "Decline-Crunch.mp4", femaleVideo: "Decline-Crunch.mp4",
                 points: ["双脚固定于下斜板，双手轻扶头别拉颈", "呼气卷腹抬起上背，下背贴板", "缓慢下放控制离心，不靠惯性弹起"]),
        Exercise("反向卷腹", "Reverse Crunch", category: .core,
                 primaryMuscles: ["腹直肌"], muscleGroups: [.abs],
                 type: "卷腹", difficulty: 2,
                 maleVideo: "Reverse-Crunch.mp4", femaleVideo: "Reverse-Crunch.mp4",
                 points: ["仰卧，双手贴地稳定身体", "收腹把膝盖向胸口卷、臀部离地", "缓慢回放，避免双腿下落惯性带动"]),
        Exercise("抱膝卷腹", "Tuck Crunch", category: .core,
                 primaryMuscles: ["腹直肌"], muscleGroups: [.abs],
                 type: "卷腹", difficulty: 1,
                 maleVideo: "Tuck-Crunch.mp4", femaleVideo: "Tuck-Crunch.mp4",
                 points: ["仰卧，上身与屈膝同时向中间收拢", "呼气收紧腹部，肩胛与臀微离地", "动作小而集中，缓慢还原"]),
        Exercise("转体卷腹", "Twisting Crunch", category: .core,
                 primaryMuscles: ["腹内外斜肌"], muscleGroups: [.obliques],
                 type: "卷腹", difficulty: 2,
                 maleVideo: "Twisting-Crunch.mp4", femaleVideo: "Twisting-Crunch.mp4",
                 points: ["仰卧屈膝，单手轻扶头", "卷起时肩部转向对侧膝盖，挤压腹斜肌", "缓慢还原，左右交替不甩颈"]),
        Exercise("V 字卷腹", "V Up", category: .core,
                 primaryMuscles: ["腹直肌"], muscleGroups: [.abs],
                 type: "卷腹", difficulty: 3,
                 maleVideo: "V-Up.mp4", femaleVideo: "V-Up.mp4",
                 points: ["仰卧伸直手脚，腰腹收紧", "同时抬起上身与双腿，手触脚尖呈 V 形", "缓慢下放，下背不猛砸地面"]),
        Exercise("正面平板支撑", "Front Plank", category: .core,
                 primaryMuscles: ["腹横肌", "腹直肌"], muscleGroups: [.abs],
                 type: "平板支撑", difficulty: 2,
                 maleVideo: "Front-Plank.mp4", femaleVideo: "Front-Plank.mp4",
                 points: ["前臂与脚尖支撑，肘在肩正下方", "收紧核心与臀，头—背—臀—腿成一条直线", "不塌腰不翘臀，均匀呼吸保持"]),
        Exercise("侧向侧平板支撑", "Lateral Side Plank", category: .core,
                 primaryMuscles: ["腹内外斜肌"], muscleGroups: [.obliques],
                 type: "平板支撑", difficulty: 2,
                 maleVideo: "Lateral-Side-Plank.mp4", femaleVideo: "Lateral-Side-Plank.mp4",
                 points: ["侧卧单肘支撑，肘在肩正下方", "髋部抬起使身体成直线，收紧腹斜肌", "骨盆不前后旋转，两侧均衡训练"]),
        Exercise("俄罗斯转体", "Russian Twist", category: .core,
                 primaryMuscles: ["腹内外斜肌"], muscleGroups: [.obliques],
                 type: "转体/抗旋", difficulty: 2,
                 maleVideo: "Russian-Twist.mp4", femaleVideo: "Russian-Twist.mp4",
                 points: ["坐姿屈膝，上身后倾约 45° 并保持腰背挺直", "核心收紧，左右转体带动手或负重触地两侧", "靠躯干旋转发力，而非只甩手臂"]),
        Exercise("肩部轻触", "Shoulder Tap", category: .core,
                 primaryMuscles: ["腹直肌"], muscleGroups: [.abs],
                 type: "肩触/支撑", difficulty: 2,
                 maleVideo: "Shoulder-Tap.mp4", femaleVideo: "Shoulder-Tap.mp4",
                 points: ["平板支撑姿势，双脚略宽增稳", "交替抬手轻拍对侧肩，髋部尽量不左右晃", "全程收紧核心，节奏平稳"]),
        Exercise("地面 L 坐支撑", "L-sit on Floor", category: .core,
                 primaryMuscles: ["核心稳定肌群", "肩胛稳定肌群"], muscleGroups: [.abs, .upperBack],
                 type: "坐姿支撑(L/V-sit)", difficulty: 4,
                 maleVideo: "L-sit on Floor.mp4", femaleVideo: "L-sit on Floor.mp4",
                 points: ["坐地双手撑地、肩胛下压把身体撑离地面", "收腹伸直双腿抬至与地面平行成 L 形", "脚尖勾起，量力保持数秒再下放"]),
        Exercise("壶铃仰卧起坐", "Kettlebell Sit Up", category: .core,
                 primaryMuscles: ["腹直肌"], muscleGroups: [.abs],
                 type: "仰卧起坐", difficulty: 3,
                 maleVideo: "Kettlebell Sit Up.mp4", femaleVideo: "Kettlebell Sit Up.mp4",
                 points: ["仰卧屈膝，双手于胸前或头顶持壶铃", "呼气收腹坐起，背部逐节离地", "缓慢躺回控制离心，避免靠惯性弹起"]),
        // MARK: chest (13)
        Exercise("胸部臂屈伸", "Chest Dip", category: .chest,
                 primaryMuscles: ["胸大肌"], muscleGroups: [.chest],
                 type: "臂屈伸(Dip)", difficulty: 4,
                 maleVideo: "Chest Dip.mp4", femaleVideo: "Chest Dip.mp4",
                 points: ["双杠支撑，身体略前倾以更多刺激胸肌", "屈肘下沉至肩略低于肘，感受胸部拉伸", "推起时不锁死肘关节，肩胛保持下沉稳定"]),
        Exercise("肱三头肌臂屈伸", "Triceps Dip", category: .chest,
                 primaryMuscles: ["肱三头肌"], muscleGroups: [.triceps],
                 type: "臂屈伸(Dip)", difficulty: 4,
                 maleVideo: "Triceps-Dip.mp4", femaleVideo: "Triceps-Dip.mp4",
                 points: ["双杠支撑，躯干尽量竖直以集中三头", "屈肘下沉，肘贴近身体不外展", "推起至接近伸直，顶端挤压三头"]),
        Exercise("杠铃卧推", "Barbell Bench Press", category: .chest,
                 primaryMuscles: ["胸大肌"], muscleGroups: [.chest],
                 type: "卧推/胸推", difficulty: 3,
                 maleVideo: "", femaleVideo: "",
                 points: ["肩胛后收下沉、挺胸，脚踩实地面", "杠铃下放至中胸，前臂保持垂直", "推起杠路略向肩上方，不锁死、不弹胸"]),
        Exercise("哑铃卧推", "Dumbbell Bench Press", category: .chest,
                 primaryMuscles: ["胸大肌"], muscleGroups: [.chest],
                 type: "卧推/胸推", difficulty: 3,
                 maleVideo: "Dumbbell-Bench-Press.mp4", femaleVideo: "Dumbbell-Bench-Press.mp4",
                 points: ["挺胸收肩胛，哑铃位于中胸两侧", "下放至胸部高度感受拉伸，手腕中立", "推起时哑铃向中间靠拢，顶端不互碰"]),
        Exercise("哑铃上斜卧推", "Dumbbell Incline Bench Press", category: .chest,
                 primaryMuscles: ["胸大肌"], muscleGroups: [.chest],
                 type: "卧推/胸推", difficulty: 3,
                 maleVideo: "Dumbbell-Incline-Bench-Press.mp4", femaleVideo: "Dumbbell-Incline-Bench-Press.mp4",
                 points: ["靠背调至 30–45°，挺胸收肩胛", "哑铃下放至上胸，肘略低于肩", "沿略向内弧线推起，集中上胸发力"]),
        Exercise("器械胸推", "Lever Chest Press", category: .chest,
                 primaryMuscles: ["胸大肌"], muscleGroups: [.chest],
                 type: "卧推/胸推", difficulty: 2,
                 maleVideo: "Lever Chest Press.mp4", femaleVideo: "Lever Chest Press.mp4",
                 points: ["调整座椅使把手与胸部中段齐平", "肩胛后收贴垫，推出时不耸肩", "回放至胸部有拉伸感，全程控制节奏"]),
        Exercise("壶铃推起", "Kettlebell Press Up", category: .chest,
                 primaryMuscles: ["胸大肌"], muscleGroups: [.chest],
                 type: "卧推/胸推", difficulty: 3,
                 maleVideo: "Kettlebell Press Up.mp4", femaleVideo: "Kettlebell Press Up.mp4",
                 points: ["仰卧或卧推姿，双手握壶铃于胸侧", "肩胛收紧，垂直向上推起壶铃", "下放控制，保持手腕中立稳定"]),
        Exercise("绳索交叉夹胸", "Cable Crossover", category: .chest,
                 primaryMuscles: ["胸大肌"], muscleGroups: [.chest],
                 type: "飞鸟/夹胸", difficulty: 2,
                 maleVideo: "Cable Crossover.mp4", femaleVideo: "Cable Crossover.mp4",
                 points: ["身体略前倾，肘微屈固定角度", "靠胸部发力把把手向身体中线汇拢", "顶端挤压略停，缓慢还原控制拉伸"]),
        Exercise("哑铃飞鸟", "Dumbbell Fly", category: .chest,
                 primaryMuscles: ["胸大肌"], muscleGroups: [.chest],
                 type: "飞鸟/夹胸", difficulty: 3,
                 maleVideo: "Dumbbell-Fly.mp4", femaleVideo: "Dumbbell-Fly.mp4",
                 points: ["平躺挺胸，肘保持微屈固定", "沿大弧线下放至胸部有拉伸，不过低伤肩", "想象抱大树合拢，靠胸发力而非手臂"]),
        Exercise("器械蝴蝶机夹胸", "Lever Pec Deck Fly", category: .chest,
                 primaryMuscles: ["胸大肌"], muscleGroups: [.chest],
                 type: "飞鸟/夹胸", difficulty: 2,
                 maleVideo: "Lever Pec Deck Fly.mp4", femaleVideo: "Lever Pec Deck Fly.mp4",
                 points: ["调座椅使把手与肩同高，背贴靠垫", "肘略屈，靠胸部把把手向中间合拢", "顶峰挤压略停，缓慢还原感受拉伸"]),
        Exercise("钻石俯卧撑", "Diamond Push Up", category: .chest,
                 primaryMuscles: ["胸大肌"], muscleGroups: [.chest],
                 type: "俯卧撑", difficulty: 3,
                 maleVideo: "Diamond Push Up.mp4", femaleVideo: "Diamond Push Up.mp4",
                 points: ["双手在胸下并拢成菱形，核心收紧成直线", "屈肘下放，肘贴近身体两侧", "推起至接近伸直，集中刺激三头与内侧胸"]),
        Exercise("俯卧撑", "Push Ups", category: .chest,
                 primaryMuscles: ["胸大肌"], muscleGroups: [.chest],
                 type: "俯卧撑", difficulty: 2,
                 maleVideo: "Push Ups.mp4", femaleVideo: "Push Ups.mp4",
                 points: ["手略宽于肩，头—背—臀—腿成一条直线", "屈肘下放至胸接近地面，肘约 45° 外展", "推起时收紧核心与臀，不塌腰不翘臀"]),
        Exercise("宽距俯卧撑", "Wide Hand Push Up", category: .chest,
                 primaryMuscles: ["胸大肌"], muscleGroups: [.chest],
                 type: "俯卧撑", difficulty: 2,
                 maleVideo: "Wide-Hand-Push-Up.mp4", femaleVideo: "Wide-Hand-Push-Up.mp4",
                 points: ["双手明显宽于肩，身体保持一条直线", "屈肘下放，更多拉伸刺激胸部外侧", "推起时不耸肩，核心始终收紧"]),
        // MARK: back (13)
        Exercise("辅助引体向上", "Assisted Pull Up", category: .back,
                 primaryMuscles: ["背阔肌"], muscleGroups: [.upperBack],
                 type: "引体向上", difficulty: 2,
                 maleVideo: "Assisted-Pull-Up.mp4", femaleVideo: "Assisted-Pull-Up.mp4",
                 points: ["膝/脚踩辅助垫，肩胛先下沉再发力", "背阔肌带动把身体拉起至下巴过杠", "缓慢下放至手臂接近伸直，感受背部拉伸"]),
        Exercise("反手引体向上", "Chin Up", category: .back,
                 primaryMuscles: ["背阔肌"], muscleGroups: [.upperBack],
                 type: "引体向上", difficulty: 4,
                 maleVideo: "Chin Up.mp4", femaleVideo: "Chin Up.mp4",
                 points: ["反握略窄于肩，肩胛下沉启动", "拉起时挺胸、肘向下后收，下巴过杠", "缓慢下放控制，避免摆荡借力"]),
        Exercise("引体向上", "Pull Up", category: .back,
                 primaryMuscles: ["背阔肌"], muscleGroups: [.upperBack],
                 type: "引体向上", difficulty: 4,
                 maleVideo: "Pull-Up.mp4", femaleVideo: "Pull-Up.mp4",
                 points: ["正握略宽于肩，先沉肩胛别耸肩", "背阔发力拉起至下巴过杠，挺胸收肘", "下放至手臂接近伸直，全程不甩动"]),
        Exercise("杠铃俯身划船", "Barbell Bent Over Row", category: .back,
                 primaryMuscles: ["背阔肌", "菱形肌"], muscleGroups: [.upperBack],
                 type: "划船", difficulty: 3,
                 maleVideo: "Barbell-Bent-Over-Row.mp4", femaleVideo: "Barbell-Bent-Over-Row.mp4",
                 points: ["屈髋俯身约 45°，背部挺直、收紧核心", "杠铃拉向下腹，肘贴身、肩胛后收", "缓慢下放，避免用腰起伏借力"]),
        Exercise("绳索坐姿划船", "Cable Seated Row", category: .back,
                 primaryMuscles: ["背阔肌", "菱形肌"], muscleGroups: [.upperBack],
                 type: "划船", difficulty: 2,
                 maleVideo: "Cable Seated Row.mp4", femaleVideo: "Cable Seated Row.mp4",
                 points: ["挺胸坐直，膝微屈，肩胛先后收", "把手拉向腹部，肘贴身向后", "还原时控制，不让肩被拉成含胸"]),
        Exercise("哑铃俯身划船", "Dumbbell Bent Over Row", category: .back,
                 primaryMuscles: ["背阔肌", "菱形肌"], muscleGroups: [.upperBack],
                 type: "划船", difficulty: 3,
                 maleVideo: "Dumbbell-Bent-Over-Row.mp4", femaleVideo: "Dumbbell-Bent-Over-Row.mp4",
                 points: ["屈髋俯身，背挺直，哑铃自然下垂", "肘贴身把哑铃拉向髋侧，肩胛后收", "顶端挤压背部，缓慢下放控制离心"]),
        Exercise("反向划船", "Inverted Row", category: .back,
                 primaryMuscles: ["背阔肌", "菱形肌"], muscleGroups: [.upperBack],
                 type: "划船", difficulty: 3,
                 maleVideo: "Inverted Row.mp4", femaleVideo: "Inverted Row.mp4",
                 points: ["握杠身体悬于杠下，绷直成一条线", "肩胛后收把胸口拉向横杠", "全程收紧核心臀部，缓慢下放"]),
        Exercise("器械坐姿划船", "Lever Seated Row", category: .back,
                 primaryMuscles: ["背阔肌", "菱形肌"], muscleGroups: [.upperBack],
                 type: "划船", difficulty: 2,
                 maleVideo: "Lever Seated Row.mp4", femaleVideo: "Lever Seated Row.mp4",
                 points: ["胸靠垫坐稳，肩胛先后收启动", "把手拉向身体，肘向后贴身", "缓慢还原，保持挺胸不含背"]),
        Exercise("壶铃俯身划船", "Kettlebell Bent Over Row", category: .back,
                 primaryMuscles: ["背阔肌", "菱形肌"], muscleGroups: [.upperBack],
                 type: "划船", difficulty: 3,
                 maleVideo: "Kettlebell Bent Over Row.mp4", femaleVideo: "Kettlebell Bent Over Row.mp4",
                 points: ["屈髋俯身背挺直，壶铃垂于体侧", "肘贴身把壶铃拉向髋部，肩胛后收", "缓慢下放，腰背始终稳定"]),
        Exercise("壶铃双臂划船", "Kettlebell Two Arm Row", category: .back,
                 primaryMuscles: ["背阔肌", "菱形肌"], muscleGroups: [.upperBack],
                 type: "划船", difficulty: 3,
                 maleVideo: "Kettlebell Two Arm Row.mp4", femaleVideo: "Kettlebell Two Arm Row.mp4",
                 points: ["屈髋俯身，双手各握一壶铃", "同时拉向髋侧，挤压肩胛", "控制下放，避免耸肩或塌腰"]),
        Exercise("绳索下拉", "Cable Pulldown", category: .back,
                 primaryMuscles: ["背阔肌"], muscleGroups: [.upperBack],
                 type: "下拉", difficulty: 2,
                 maleVideo: "Cable Pulldown.mp4", femaleVideo: "Cable Pulldown.mp4",
                 points: ["坐稳固定大腿，正握略宽于肩", "肩胛下沉，把杆拉向上胸、挺胸", "缓慢回放至手臂伸直，感受背阔拉伸"]),
        Exercise("绳索宽握背阔肌下拉", "Cable Wide Grip Lat Pulldown", category: .back,
                 primaryMuscles: ["背阔肌"], muscleGroups: [.upperBack],
                 type: "下拉", difficulty: 2,
                 maleVideo: "Cable Wide Grip Lat Pulldown.mp4", femaleVideo: "Cable Wide Grip Lat Pulldown.mp4",
                 points: ["宽握，肩胛先下沉别靠手臂硬拉", "把杆拉向锁骨上胸，肘向下后", "控制还原，全程挺胸不后仰借力"]),
        Exercise("背伸", "Hyperextension", category: .back,
                 primaryMuscles: ["竖脊肌"], muscleGroups: [.lowerBack],
                 type: "背部伸展", difficulty: 2,
                 maleVideo: "Hyperextension.mp4", femaleVideo: "Hyperextension.mp4",
                 points: ["髋部卡在垫上，身体下俯", "臀与下背发力抬起至与身体成直线", "不过度后仰，缓慢下放控制"]),
        // MARK: shoulders (13)
        Exercise("绳索前平举", "Cable Front Raise", category: .shoulders,
                 primaryMuscles: ["三角肌前束"], muscleGroups: [.frontDeltoids],
                 type: "前平举", difficulty: 2,
                 maleVideo: "Cable Front Raise.mp4", femaleVideo: "Cable Front Raise.mp4",
                 points: ["绳索在体侧/身后，肘微屈固定", "前束发力把把手抬至与肩同高", "缓慢下放控制，避免身体后仰借力"]),
        Exercise("哑铃前平举", "Dumbbell Front Raise", category: .shoulders,
                 primaryMuscles: ["三角肌前束"], muscleGroups: [.frontDeltoids],
                 type: "前平举", difficulty: 2,
                 maleVideo: "Dumbbell Front Raise.mp4", femaleVideo: "Dumbbell Front Raise.mp4",
                 points: ["自然站立，哑铃置于大腿前", "肘微屈把哑铃抬至与肩同高即可", "缓慢下放，不甩动、不耸肩"]),
        Exercise("绳索侧平举", "Cable Lateral Raise", category: .shoulders,
                 primaryMuscles: ["三角肌中束"], muscleGroups: [.deltoids],
                 type: "侧平举", difficulty: 2,
                 maleVideo: "Cable Lateral Raise.mp4", femaleVideo: "Cable Lateral Raise.mp4",
                 points: ["侧身站于绳索旁，肘略屈", "中束发力把手向侧抬至与肩平", "小拇指略高，缓慢下放控制离心"]),
        Exercise("哑铃侧平举", "Dumbbell Lateral Raise", category: .shoulders,
                 primaryMuscles: ["三角肌中束"], muscleGroups: [.deltoids],
                 type: "侧平举", difficulty: 2,
                 maleVideo: "Dumbbell Lateral Raise.mp4", femaleVideo: "Dumbbell Lateral Raise.mp4",
                 points: ["微屈肘，哑铃置于体侧", "靠中束把哑铃向两侧抬至与肩平", "想象倒水手势，不耸肩不甩动借力"]),
        Exercise("绳索肩推", "Cable Shoulder Press", category: .shoulders,
                 primaryMuscles: ["三角肌前束", "三角肌中束"], muscleGroups: [.frontDeltoids, .deltoids],
                 type: "肩上推举", difficulty: 2,
                 maleVideo: "Cable Shoulder Press.mp4", femaleVideo: "Cable Shoulder Press.mp4",
                 points: ["坐/站稳，把手起于肩高", "垂直向上推起至接近伸直不锁死", "控制下放至肩高，核心收紧不塌腰"]),
        Exercise("哑铃阿诺德推举", "Dumbbell Arnold Press", category: .shoulders,
                 primaryMuscles: ["三角肌前束", "三角肌中束"], muscleGroups: [.frontDeltoids, .deltoids],
                 type: "肩上推举", difficulty: 3,
                 maleVideo: "Dumbbell Arnold Press.mp4", femaleVideo: "Dumbbell Arnold Press.mp4",
                 points: ["起始掌心朝己置于胸前", "上推同时旋转前臂使掌心朝前", "顶端不锁死，下放反向旋转还原"]),
        Exercise("哑铃坐姿肩推", "Dumbbell Seated Shoulder Press", category: .shoulders,
                 primaryMuscles: ["三角肌前束", "三角肌中束"], muscleGroups: [.frontDeltoids, .deltoids],
                 type: "肩上推举", difficulty: 3,
                 maleVideo: "Dumbbell Seated Shoulder Press.mp4", femaleVideo: "Dumbbell Seated Shoulder Press.mp4",
                 points: ["坐姿背贴靠垫，哑铃位于耳侧", "垂直向上推至接近伸直，不耸肩", "下放至肘略低于肩，控制节奏"]),
        Exercise("壶铃斜向推举", "Kettlebell Angled Press", category: .shoulders,
                 primaryMuscles: ["三角肌前束", "三角肌中束"], muscleGroups: [.frontDeltoids, .deltoids],
                 type: "肩上推举", difficulty: 3,
                 maleVideo: "Kettlebell Angled Press.mp4", femaleVideo: "Kettlebell Angled Press.mp4",
                 points: ["壶铃架于前臂，手腕中立稳定", "沿略斜向上推起至手臂伸直", "控制下放至肩部，核心保持收紧"]),
        Exercise("绳索直立划船", "Cable Upright Row", category: .shoulders,
                 primaryMuscles: ["三角肌中束", "斜方肌上束"], muscleGroups: [.deltoids, .trapezius],
                 type: "直立划船", difficulty: 3,
                 maleVideo: "Cable Upright Row.mp4", femaleVideo: "Cable Upright Row.mp4",
                 points: ["握把略窄于肩，自然下垂", "肘领先向上提拉至上臂与肩平", "肘不超过肩高以护肩，缓慢下放"]),
        Exercise("杠铃耸肩", "Barbell Shrug", category: .shoulders,
                 primaryMuscles: ["斜方肌上束"], muscleGroups: [.trapezius],
                 type: "耸肩", difficulty: 2,
                 maleVideo: "Barbell-Shrug.mp4", femaleVideo: "Barbell-Shrug.mp4",
                 points: ["自然握杠垂于体前，挺胸", "斜方肌发力把肩向耳朵方向耸起", "顶端略停，缓慢放下，不绕肩"]),
        Exercise("俯卧 Y 字上举", "Prone Y Raise", category: .shoulders,
                 primaryMuscles: ["三角肌后束", "斜方肌中下束"], muscleGroups: [.rearDeltoids, .trapezius],
                 type: "反向飞鸟/上举", difficulty: 2,
                 maleVideo: "Prone Y Raise.mp4", femaleVideo: "Prone Y Raise.mp4",
                 points: ["俯卧，双臂前伸成 Y 字，拇指朝上", "后束与中下斜方发力把手臂抬离地面", "顶端略停，缓慢下放，不耸肩"]),
        Exercise("杠铃后三角划船", "Barbell Rear Delt Row", category: .shoulders,
                 primaryMuscles: ["三角肌后束", "斜方肌中下束"], muscleGroups: [.rearDeltoids, .trapezius],
                 type: "划船", difficulty: 3,
                 maleVideo: "Barbell-Rear-Delt-Row.mp4", femaleVideo: "Barbell-Rear-Delt-Row.mp4",
                 points: ["屈髋俯身，宽握杠铃", "肘外展把杠拉向上腹，刺激后束", "肩胛后收略停，缓慢下放控制"]),
        Exercise("阻力带外旋", "Resistance Band External Rotation", category: .shoulders,
                 primaryMuscles: ["肩袖肌群"], muscleGroups: [.deltoids],
                 type: "肩外旋/内收", difficulty: 1,
                 maleVideo: "Resistance Band External Rotation.mp4", femaleVideo: "Resistance Band External Rotation.mp4",
                 points: ["大臂贴身、屈肘 90°，前臂向内起始", "保持肘贴身，前臂向外旋转拉开弹力带", "缓慢回收控制，动作小而精准"]),
        // MARK: arms (9)
        Exercise("杠铃弯举", "Barbell Curl", category: .arms,
                 primaryMuscles: ["肱二头肌"], muscleGroups: [.biceps],
                 type: "二头弯举", difficulty: 2,
                 maleVideo: "Barbell-Curl.mp4", femaleVideo: "Barbell-Curl.mp4",
                 points: ["大臂贴身固定，掌心向上握杠", "靠二头把杠弯举至顶峰挤压", "缓慢下放至手臂接近伸直，不甩腰借力"]),
        Exercise("绳索锤式弯举", "Cable Hammer Curl", category: .arms,
                 primaryMuscles: ["肱二头肌"], muscleGroups: [.biceps],
                 type: "二头弯举", difficulty: 2,
                 maleVideo: "Cable Hammer Curl.mp4", femaleVideo: "Cable Hammer Curl.mp4",
                 points: ["用绳柄中立握，大臂贴身", "锤式弯举至顶端，强化肱肌与前臂", "缓慢下放控制，肘不前后移动"]),
        Exercise("哑铃二头弯举", "Dumbbell Biceps Curl", category: .arms,
                 primaryMuscles: ["肱二头肌"], muscleGroups: [.biceps],
                 type: "二头弯举", difficulty: 2,
                 maleVideo: "Dumbbell-Biceps-Curl.mp4", femaleVideo: "Dumbbell-Biceps-Curl.mp4",
                 points: ["大臂贴身，掌心向前", "弯举至顶峰可略外旋加强收缩", "缓慢下放，全程不借身体晃动"]),
        Exercise("哑铃坐姿锤式弯举", "Dumbbell Seated Hammer Curl", category: .arms,
                 primaryMuscles: ["肱二头肌"], muscleGroups: [.biceps],
                 type: "二头弯举", difficulty: 2,
                 maleVideo: "Dumbbell-Seated-Hammer-Curl.mp4", femaleVideo: "Dumbbell-Seated-Hammer-Curl.mp4",
                 points: ["坐姿大臂贴身，中立握（拇指朝上）", "锤式弯举至顶端略停", "缓慢下放，肘固定不晃"]),
        Exercise("EZ 杠铃牧师凳弯举", "EZ Barbell Preacher Curl", category: .arms,
                 primaryMuscles: ["肱二头肌"], muscleGroups: [.biceps],
                 type: "二头弯举", difficulty: 2,
                 maleVideo: "Ez Barbell Preacher Curl.mp4", femaleVideo: "Ez Barbell Preacher Curl.mp4",
                 points: ["大臂完全贴牧师凳斜面", "弯举至顶峰挤压二头", "缓慢下放至接近伸直但不完全锁死"]),
        Exercise("壶铃二头弯举", "Kettlebell Biceps Curl", category: .arms,
                 primaryMuscles: ["肱二头肌"], muscleGroups: [.biceps],
                 type: "二头弯举", difficulty: 2,
                 maleVideo: "Kettlebell Biceps Curl.mp4", femaleVideo: "Kettlebell Biceps Curl.mp4",
                 points: ["大臂贴身，握把使壶铃垂于手背侧", "弯举至顶端，控制壶铃不晃动", "缓慢下放，保持肘部固定"]),
        Exercise("EZ 杠铃仰卧肱三头肌伸展", "EZ Barbell Lying Triceps Extension", category: .arms,
                 primaryMuscles: ["肱三头肌"], muscleGroups: [.triceps],
                 type: "三头下压/伸展", difficulty: 3,
                 maleVideo: "EZ Barbell Lying Triceps Extension.mp4", femaleVideo: "EZ Barbell Lying Triceps Extension.mp4",
                 points: ["仰卧持 EZ 杠，大臂垂直固定", "仅屈肘把杠下放至额后", "靠三头伸直手臂，大臂始终不动"]),
        Exercise("肱三头肌下压", "Triceps Press", category: .arms,
                 primaryMuscles: ["肱三头肌"], muscleGroups: [.triceps],
                 type: "三头下压/伸展", difficulty: 2,
                 maleVideo: "Triceps Press.mp4", femaleVideo: "Triceps Press.mp4",
                 points: ["大臂贴身固定，肩胛下沉", "肘为唯一活动点把把手下压至伸直", "顶端挤压三头，缓慢回放不耸肩"]),
        Exercise("地面肱三头肌臂屈伸", "Triceps Dips Floor", category: .arms,
                 primaryMuscles: ["肱三头肌"], muscleGroups: [.triceps],
                 type: "臂屈伸(Dip)", difficulty: 3,
                 maleVideo: "Triceps-Dips-Floor.mp4", femaleVideo: "Triceps-Dips-Floor.mp4",
                 points: ["坐地屈膝，双手撑于臀后、指尖朝前", "屈肘把臀下沉，肘向后不外八", "靠三头推起，控制节奏"]),
        // MARK: lower (12)
        Exercise("徒手深蹲", "Air Squat", category: .lower,
                 primaryMuscles: ["股四头肌", "臀大肌"], muscleGroups: [.quadriceps, .gluteal],
                 type: "深蹲", difficulty: 1,
                 maleVideo: "Air-Squat.mp4", femaleVideo: "Air-Squat.mp4",
                 points: ["双脚略宽于肩，脚尖略外展", "屈髋屈膝下蹲至大腿接近平行，膝对脚尖", "脚跟踩实蹬地起身，挺胸不弓背"]),
        Exercise("杠铃深蹲", "Barbell Back Squat", category: .lower,
                 primaryMuscles: ["股四头肌", "臀大肌"], muscleGroups: [.quadriceps, .gluteal],
                 type: "深蹲", difficulty: 4,
                 maleVideo: "", femaleVideo: "",
                 points: ["杠置于斜方肌上，核心收紧、挺胸", "屈髋屈膝下蹲至大腿平行，膝随脚尖方向", "脚跟发力蹬起，膝不内扣、不弓腰"]),
        Exercise("哑铃高脚杯深蹲", "Dumbbell Goblet Squat", category: .lower,
                 primaryMuscles: ["股四头肌", "臀大肌"], muscleGroups: [.quadriceps, .gluteal],
                 type: "深蹲", difficulty: 2,
                 maleVideo: "Dumbbell Goblet Squat.mp4", femaleVideo: "Dumbbell Goblet Squat.mp4",
                 points: ["双手捧哑铃于胸前，挺胸收核心", "下蹲至大腿平行，肘可轻碰膝内侧", "脚跟蹬地起身，全程背部挺直"]),
        Exercise("壶铃甲板深蹲", "Kettlebell Deck Squat", category: .lower,
                 primaryMuscles: ["股四头肌", "臀大肌"], muscleGroups: [.quadriceps, .gluteal],
                 type: "深蹲", difficulty: 3,
                 maleVideo: "Kettlebell Deck Squat.mp4", femaleVideo: "Kettlebell Deck Squat.mp4",
                 points: ["持壶铃于胸前，后滚至背部再借势前滚", "前滚顺势站起进入深蹲位", "护住颈背、核心收紧控制节奏"]),
        Exercise("杠铃罗马尼亚硬拉", "Barbell Romanian Deadlift", category: .lower,
                 primaryMuscles: ["臀大肌", "腘绳肌"], muscleGroups: [.gluteal, .hamstring],
                 type: "硬拉/髋铰链", difficulty: 4,
                 maleVideo: "", femaleVideo: "",
                 points: ["微屈膝固定，杠贴腿、挺胸沉肩", "屈髋送臀向后，杠沿腿下放至腘绳肌拉伸", "靠伸髋夹臀起身，背始终挺直不弓"]),
        Exercise("杠铃直腿硬拉", "Barbell Straight Leg Deadlift", category: .lower,
                 primaryMuscles: ["臀大肌", "腘绳肌"], muscleGroups: [.gluteal, .hamstring],
                 type: "硬拉/髋铰链", difficulty: 4,
                 maleVideo: "Barbell-Straight-Leg-Deadlift.mp4", femaleVideo: "Barbell-Straight-Leg-Deadlift.mp4",
                 points: ["膝几乎伸直，挺胸收紧背部", "屈髋送臀，杠贴腿下放感受腘绳肌拉伸", "量力而行，背不弓、靠伸髋起身"]),
        Exercise("哑铃罗马尼亚硬拉", "Dumbbell Romanian Deadlift", category: .lower,
                 primaryMuscles: ["臀大肌", "腘绳肌"], muscleGroups: [.gluteal, .hamstring],
                 type: "硬拉/髋铰链", difficulty: 3,
                 maleVideo: "Dumbbell Romanian Deadlift.mp4", femaleVideo: "Dumbbell Romanian Deadlift.mp4",
                 points: ["微屈膝，哑铃贴腿前侧，挺胸", "送臀向后屈髋下放至腘绳肌明显拉伸", "夹臀伸髋起身，全程背挺直"]),
        Exercise("臀桥", "Butt Bridge", category: .lower,
                 primaryMuscles: ["臀大肌"], muscleGroups: [.gluteal],
                 type: "臀桥/臀推", difficulty: 1,
                 maleVideo: "Butt-Bridge.mp4", femaleVideo: "Butt-Bridge.mp4",
                 points: ["仰卧屈膝，脚跟靠近臀部", "夹臀伸髋把骨盆顶起成直线", "顶端挤压臀部略停，缓慢下放"]),
        Exercise("臀推", "Hip Thrusts", category: .lower,
                 primaryMuscles: ["臀大肌"], muscleGroups: [.gluteal],
                 type: "臀桥/臀推", difficulty: 2,
                 maleVideo: "Hip-Thrusts.mp4", femaleVideo: "Hip-Thrusts.mp4",
                 points: ["上背靠凳，杠/重物置于髋部", "夹臀伸髋顶起至躯干与大腿成直线", "顶端挤压臀部，下放控制不塌腰"]),
        Exercise("哑铃弓步", "Dumbbell Lunge", category: .lower,
                 primaryMuscles: ["股四头肌", "臀大肌"], muscleGroups: [.quadriceps, .gluteal],
                 type: "弓步", difficulty: 2,
                 maleVideo: "Dumbbell Lunge.mp4", femaleVideo: "Dumbbell Lunge.mp4",
                 points: ["双手持哑铃，向前或原地跨步下蹲", "前膝对脚尖、后膝接近地面，躯干直立", "前脚跟发力蹬起，保持平衡"]),
        Exercise("前弓步", "Forward Lunge", category: .lower,
                 primaryMuscles: ["股四头肌", "臀大肌"], muscleGroups: [.quadriceps, .gluteal],
                 type: "弓步", difficulty: 2,
                 maleVideo: "Forward-Lunge.mp4", femaleVideo: "Forward-Lunge.mp4",
                 points: ["向前跨一步下蹲，前膝不过度超过脚尖", "后膝下沉接近地面，上身挺直", "前脚跟蹬地收回，左右交替"]),
        Exercise("腿屈伸", "Leg Extension", category: .lower,
                 primaryMuscles: ["股四头肌"], muscleGroups: [.quadriceps],
                 type: "腿屈伸", difficulty: 1,
                 maleVideo: "", femaleVideo: "",
                 points: ["调靠垫使膝对准转轴，脚踝抵挡板", "股四头发力伸膝至接近伸直，顶端略停", "缓慢回放控制离心，不甩腿"]),
    ]
}
