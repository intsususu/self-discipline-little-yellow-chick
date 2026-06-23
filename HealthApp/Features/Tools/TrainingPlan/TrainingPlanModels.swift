// TrainingPlanModels.swift
// 小工具 · 训练计划：数据模型 + 内置内容（练背/练胸/练腿/练肩）。
// 见 docs/训练计划设计.md。图片素材未就位，先用灰底占位（图片资源名先留字段，便于后续接入）。

import SwiftUI

/// 一个训练动作。
struct Exercise: Identifiable {
    let id = UUID()
    let name: String
    let nameEn: String
    let primaryMuscles: String       // 主练
    let synergistMuscles: String     // 协同（可空）
    let equipImage: String           // 器械/动作图资源名（占位期暂不使用）
    let muscleImage: String          // 肌肉发力图资源名（占位期暂不使用）
    let points: [String]             // 要点 bullet
    let setsReps: String             // 「3–4 组 × 10–12 次」

    init(_ name: String, _ nameEn: String,
         primary: String, synergist: String = "",
         equip: String, muscle: String,
         points: [String], setsReps: String) {
        self.name = name
        self.nameEn = nameEn
        self.primaryMuscles = primary
        self.synergistMuscles = synergist
        self.equipImage = equip
        self.muscleImage = muscle
        self.points = points
        self.setsReps = setsReps
    }
}

/// 一个训练部位（一页）。
struct TrainingPart: Identifiable {
    let id = UUID()
    let name: String
    let targetMuscles: [String]      // 目标肌群标签
    let intro: String                // 一句话简介
    let overviewImage: String        // 概览发力图资源名（占位期暂不使用）
    let exercises: [Exercise]
}

// MARK: - 内置内容

enum TrainingPlanData {
    static let parts: [TrainingPart] = [
        // MARK: 练背
        TrainingPart(
            name: "练背",
            targetMuscles: ["背阔肌", "斜方肌", "菱形肌", "大圆肌", "竖脊肌"],
            intro: "背部是上肢「拉」的主力，练好背能改善体态，强化引体与硬拉表现。",
            overviewImage: "back_overview_muscle",
            exercises: [
                Exercise("高位下拉", "Lat Pulldown",
                         primary: "背阔肌", synergist: "肱二头肌、三角肌后束",
                         equip: "back_lat_pulldown_equip", muscle: "back_lat_pulldown_muscle",
                         points: ["沉肩、后缩下沉肩胛", "肘部下沉带动，拉至上胸", "顶峰收缩，不耸肩借力"],
                         setsReps: "3–4 组 × 10–12 次"),
                Exercise("坐姿划船", "Seated Cable Row",
                         primary: "中背、菱形肌、背阔肌", synergist: "肱二头肌",
                         equip: "back_seated_row_equip", muscle: "back_seated_row_muscle",
                         points: ["挺胸收腹，背部挺直", "肩胛后夹，肘贴身后拉", "不靠腰部前后甩动"],
                         setsReps: "3–4 组 × 10–12 次"),
                Exercise("杠铃俯身划船", "Barbell Row",
                         primary: "背阔肌、斜方肌中下部", synergist: "竖脊肌、肱二头肌",
                         equip: "back_barbell_row_equip", muscle: "back_barbell_row_muscle",
                         points: ["屈髋上身约 45°，核心收紧", "杠铃拉向下腹", "背部全程挺直，不弓背"],
                         setsReps: "3–4 组 × 8–10 次"),
                Exercise("引体向上", "Pull-up",
                         primary: "背阔肌", synergist: "肱二头肌、大圆肌",
                         equip: "back_pullup_equip", muscle: "back_pullup_muscle",
                         points: ["肩胛先下沉再发力", "拉到下巴过杠", "控制离心慢放"],
                         setsReps: "3–4 组 × 力竭"),
                Exercise("硬拉", "Deadlift",
                         primary: "竖脊肌、整体后链", synergist: "臀大肌、腘绳肌",
                         equip: "back_deadlift_equip", muscle: "back_deadlift_muscle",
                         points: ["杠铃贴近小腿", "髋膝同步发力", "背部中立，杠贴身上提"],
                         setsReps: "3–4 组 × 5–8 次"),
            ]
        ),
        // MARK: 练胸
        TrainingPart(
            name: "练胸",
            targetMuscles: ["胸大肌上束", "胸大肌中部", "胸大肌下束", "三角肌前束"],
            intro: "胸部是上肢「推」的主力，注意上中下束均衡刺激。",
            overviewImage: "chest_overview_muscle",
            exercises: [
                Exercise("杠铃卧推", "Barbell Bench Press",
                         primary: "胸大肌中部", synergist: "三角肌前束、肱三头肌",
                         equip: "chest_bench_press_equip", muscle: "chest_bench_press_muscle",
                         points: ["肩胛后缩下沉稳定", "杠铃下落至乳线，肘约 45°", "脚踩稳，不耸肩"],
                         setsReps: "3–4 组 × 8–10 次"),
                Exercise("上斜哑铃卧推", "Incline Dumbbell Press",
                         primary: "胸大肌上束", synergist: "三角肌前束",
                         equip: "chest_incline_db_equip", muscle: "chest_incline_db_muscle",
                         points: ["椅背 30–45°", "下放至胸侧，顶端微内夹", "全程不耸肩"],
                         setsReps: "3–4 组 × 10–12 次"),
                Exercise("坐姿推胸器", "Chest Press Machine",
                         primary: "胸大肌", synergist: "肱三头肌",
                         equip: "chest_press_machine_equip", muscle: "chest_press_machine_muscle",
                         points: ["背贴靠垫，握把与胸齐", "推到接近直臂", "控制回放"],
                         setsReps: "3 组 × 12 次"),
                Exercise("蝴蝶机夹胸", "Pec Deck Fly",
                         primary: "胸大肌内侧", synergist: "",
                         equip: "chest_pec_deck_equip", muscle: "chest_pec_deck_muscle",
                         points: ["微屈肘固定", "走弧线内夹，顶峰挤压", "离心慢放"],
                         setsReps: "3 组 × 12–15 次"),
                Exercise("双杠臂屈伸", "Chest Dips",
                         primary: "胸大肌下束", synergist: "肱三头肌",
                         equip: "chest_dips_equip", muscle: "chest_dips_muscle",
                         points: ["身体前倾", "下放至肩略低于肘", "不耸肩，控制幅度"],
                         setsReps: "3 组 × 力竭"),
            ]
        ),
        // MARK: 练腿
        TrainingPart(
            name: "练腿",
            targetMuscles: ["股四头肌", "臀大肌", "腘绳肌", "内收肌", "小腿"],
            intro: "腿是全身最大肌群，练腿提升整体力量、代谢与运动表现。",
            overviewImage: "legs_overview_muscle",
            exercises: [
                Exercise("杠铃深蹲", "Barbell Squat",
                         primary: "股四头肌、臀大肌", synergist: "腘绳肌、核心",
                         equip: "legs_squat_equip", muscle: "legs_squat_muscle",
                         points: ["核心收紧，膝与脚尖同向", "下蹲至大腿平行或更低", "脚跟发力站起，膝不内扣"],
                         setsReps: "3–4 组 × 8–10 次"),
                Exercise("腿举", "Leg Press",
                         primary: "股四头肌、臀大肌", synergist: "腘绳肌",
                         equip: "legs_leg_press_equip", muscle: "legs_leg_press_muscle",
                         points: ["脚放踏板中部", "膝盖不锁死", "下放至约 90°，不塌腰"],
                         setsReps: "3–4 组 × 10–12 次"),
                Exercise("腿屈伸", "Leg Extension",
                         primary: "股四头肌（孤立）", synergist: "",
                         equip: "legs_leg_extension_equip", muscle: "legs_leg_extension_muscle",
                         points: ["转轴对齐膝关节", "顶端伸直挤压", "慢放，不甩腿"],
                         setsReps: "3 组 × 12–15 次"),
                Exercise("腿弯举", "Leg Curl",
                         primary: "腘绳肌", synergist: "",
                         equip: "legs_leg_curl_equip", muscle: "legs_leg_curl_muscle",
                         points: ["髋部贴垫", "收缩到底", "离心控制，不拱腰借力"],
                         setsReps: "3 组 × 12–15 次"),
                Exercise("罗马尼亚硬拉", "Romanian Deadlift",
                         primary: "腘绳肌、臀大肌", synergist: "竖脊肌",
                         equip: "legs_rdl_equip", muscle: "legs_rdl_muscle",
                         points: ["屈髋后送", "杠铃贴腿下滑", "背中立，感受腘绳拉伸"],
                         setsReps: "3 组 × 10 次"),
                Exercise("站姿提踵", "Calf Raise",
                         primary: "小腿（腓肠肌）", synergist: "比目鱼肌",
                         equip: "legs_calf_raise_equip", muscle: "legs_calf_raise_muscle",
                         points: ["全幅度起落", "顶端停顿", "慢速离心"],
                         setsReps: "3 组 × 15–20 次"),
            ]
        ),
        // MARK: 练肩
        TrainingPart(
            name: "练肩",
            targetMuscles: ["三角肌前束", "三角肌中束", "三角肌后束", "斜方肌"],
            intro: "肩部三角肌分前中后束，均衡发展能撑起整体上肢线条。",
            overviewImage: "shoulder_overview_muscle",
            exercises: [
                Exercise("哑铃肩上推举", "Overhead Press",
                         primary: "三角肌前束、中束", synergist: "肱三头肌、斜方肌",
                         equip: "shoulder_overhead_press_equip", muscle: "shoulder_overhead_press_muscle",
                         points: ["核心收紧", "推过头顶，不过度后仰", "控制下放"],
                         setsReps: "3–4 组 × 8–12 次"),
                Exercise("哑铃侧平举", "Lateral Raise",
                         primary: "三角肌中束", synergist: "",
                         equip: "shoulder_lateral_raise_equip", muscle: "shoulder_lateral_raise_muscle",
                         points: ["小重量慢控", "肘略高于腕", "起到肩高，慢放不借力"],
                         setsReps: "3–4 组 × 12–15 次"),
                Exercise("俯身飞鸟", "Rear Delt Fly",
                         primary: "三角肌后束", synergist: "菱形肌",
                         equip: "shoulder_rear_delt_equip", muscle: "shoulder_rear_delt_muscle",
                         points: ["微屈肘固定", "走弧线，孤立后束", "肩胛勿过度后缩"],
                         setsReps: "3 组 × 15 次"),
                Exercise("坐姿推肩机", "Shoulder Press Machine",
                         primary: "三角肌整体", synergist: "肱三头肌",
                         equip: "shoulder_press_machine_equip", muscle: "shoulder_press_machine_muscle",
                         points: ["背贴靠垫，握把与肩齐", "推到接近直臂", "不耸肩"],
                         setsReps: "3 组 × 10–12 次"),
                Exercise("面拉", "Face Pull",
                         primary: "三角肌后束、外旋肌", synergist: "斜方肌中下部",
                         equip: "shoulder_face_pull_equip", muscle: "shoulder_face_pull_muscle",
                         points: ["绳索高位", "拉向面部并外旋", "注重收缩感"],
                         setsReps: "3 组 × 15 次"),
            ]
        ),
    ]
}
