// StretchData.swift
// 小工具 · 训练计划：拉伸 / 瑜伽 / 活动度动作库（数据源 docs/fitness/stretching.md，94 个）。
// 由 scratchpad/gen_stretch_hiit.py 生成，勿手改。

import SwiftUI

// MARK: - 拉伸部位（顶部「拉伸」tab 按此分组）

enum StretchPart: String, CaseIterable, Identifiable {
    case neck, shoulder, chest, back, arm, core, hip, leg, fullBody

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .neck:     return "颈部"
        case .shoulder: return "肩部"
        case .chest:    return "胸部"
        case .back:     return "背部"
        case .arm:      return "手臂"
        case .core:     return "腹部核心"
        case .hip:      return "髋部"
        case .leg:      return "腿部"
        case .fullBody: return "全身综合"
        }
    }
}

// MARK: - 一个拉伸动作

struct StretchMove: Identifiable {
    let id = UUID()
    let name: String
    let nameEn: String
    let part: StretchPart
    let target: String      // 目标肌群（展示用）
    let kind: String        // 类型：拉伸 / 瑜伽体式 / 绕环 / 放松筋膜 / 肩胛关节活动
    let difficulty: Int
    let video: String

    init(_ name: String, _ nameEn: String, part: StretchPart, target: String,
         kind: String, difficulty: Int, video: String) {
        self.name = name
        self.nameEn = nameEn
        self.part = part
        self.target = target
        self.kind = kind
        self.difficulty = difficulty
        self.video = video
    }
}

enum StretchData {
    static let moves: [StretchMove] = [
        StretchMove("腹部拉伸", "Abdominal Stretch", part: .core, target: "腹部肌群", kind: "拉伸", difficulty: 1, video: "Abdominal-Stretch.mp4"),
        StretchMove("过头胸部拉伸", "Above Head Chest Stretch", part: .chest, target: "胸大肌", kind: "拉伸", difficulty: 1, video: "Above-Head-Chest-Stretch.mp4"),
        StretchMove("内收肌拉伸", "Adductor Stretch", part: .leg, target: "内收肌群", kind: "拉伸", difficulty: 1, video: "Adductor-Stretch.mp4"),
        StretchMove("踝关节绕环", "Ankle Circles", part: .fullBody, target: "目标拉伸肌群", kind: "绕环", difficulty: 1, video: "Ankle-Circles.mp4"),
        StretchMove("手臂绕环", "Arm Circles", part: .fullBody, target: "目标拉伸肌群", kind: "绕环", difficulty: 1, video: "Arm-Circles.mp4"),
        StretchMove("举臂旋转肌拉伸", "Arm Up Rotator Stretch", part: .shoulder, target: "肩部肌群", kind: "拉伸", difficulty: 1, video: "Arm-Up-Rotator-Stretch.mp4"),
        StretchMove("辅助仰卧腘绳肌拉伸", "Assisted Lying Hamstring Stretch", part: .leg, target: "腘绳肌", kind: "拉伸", difficulty: 1, video: "Assisted-Lying-Hamstring-Stretch.mp4"),
        StretchMove("背部放松", "Back Relaxation", part: .back, target: "背部肌群", kind: "放松/筋膜", difficulty: 1, video: "Back-Relaxation.mp4"),
        StretchMove("背部拉伸", "Back Stretch", part: .back, target: "背部肌群", kind: "拉伸", difficulty: 1, video: "Back-Stretch.mp4"),
        StretchMove("头后胸部拉伸", "Behind Head Chest Stretch", part: .chest, target: "胸大肌", kind: "拉伸", difficulty: 1, video: "Behind Head Chest Stretch.mp4"),
        StretchMove("屈臂胸部拉伸", "Bent Arm Chest Stretch", part: .chest, target: "胸大肌", kind: "拉伸", difficulty: 1, video: "Bent Arm Chest Stretch.mp4"),
        StretchMove("船式拉伸", "Boat Stretch", part: .fullBody, target: "目标拉伸肌群", kind: "拉伸", difficulty: 2, video: "Boat-Stretch.mp4"),
        StretchMove("骆驼式", "Camel Pose", part: .fullBody, target: "目标拉伸肌群", kind: "瑜伽体式", difficulty: 3, video: "Camel Pose.mp4"),
        StretchMove("猫牛式拉伸", "Cat Cow Stretch", part: .fullBody, target: "目标拉伸肌群", kind: "拉伸", difficulty: 2, video: "Cat-Cow-Stretch.mp4"),
        StretchMove("胸部和肩前侧拉伸", "Chest and Front of Shoulder Stretch", part: .chest, target: "胸大肌、肩部肌群", kind: "拉伸", difficulty: 1, video: "Chest and Front of Shoulder Stretch.mp4"),
        StretchMove("低头颈部拉伸", "Chin to Chest Stretch", part: .neck, target: "颈部肌群", kind: "拉伸", difficulty: 1, video: "Chin to Chest Stretch.mp4"),
        StretchMove("眼镜蛇式", "Cobra Yoga Pose", part: .fullBody, target: "目标拉伸肌群", kind: "瑜伽体式", difficulty: 2, video: "Cobra Yoga Pose.mp4"),
        StretchMove("下犬式", "Downward Facing Dog", part: .fullBody, target: "目标拉伸肌群", kind: "瑜伽体式", difficulty: 2, video: "Downward-Facing-Dog.mp4"),
        StretchMove("肘部屈肌拉伸", "Elbow Flexor Stretch", part: .arm, target: "前臂与手臂肌群", kind: "拉伸", difficulty: 1, video: "Elbow Flexor Stretch.mp4"),
        StretchMove("肘外展旋转肌拉伸", "Elbow Out Rotator Stretch", part: .shoulder, target: "肩部肌群、前臂与手臂肌群", kind: "拉伸", difficulty: 1, video: "Elbow Out Rotator Stretch.mp4"),
        StretchMove("双肘后拉伸展", "Elbows Back Stretch", part: .back, target: "背部肌群、前臂与手臂肌群", kind: "拉伸", difficulty: 1, video: "Elbows Back Stretch.mp4"),
        StretchMove("健身球背部拉伸", "Exercise Ball Back Stretch", part: .back, target: "背部肌群", kind: "拉伸", difficulty: 1, video: "Exercise-Ball-Back-Stretch.mp4"),
        StretchMove("健身球髋屈肌拉伸", "Exercise Ball Hip Flexor Stretch", part: .hip, target: "髋部肌群", kind: "拉伸", difficulty: 1, video: "Exercise Ball Hip Flexor Stretch.mp4"),
        StretchMove("健身球背阔肌拉伸", "Exercise Ball Lat Stretch", part: .back, target: "背阔肌", kind: "拉伸", difficulty: 1, video: "Exercise Ball Lat Stretch.mp4"),
        StretchMove("肩外旋拉伸", "External Shoulder Rotation Stretch", part: .shoulder, target: "肩部肌群", kind: "拉伸", difficulty: 1, video: "External Shoulder Rotation Stretch.mp4"),
        StretchMove("手指伸展拉伸", "Finger Extension Stretch", part: .arm, target: "前臂与手臂肌群", kind: "拉伸", difficulty: 1, video: "Finger Extension Stretch.mp4"),
        StretchMove("手指伸肌拉伸", "Finger Extensor Stretch", part: .arm, target: "前臂与手臂肌群", kind: "拉伸", difficulty: 1, video: "Finger Extensor Stretch.mp4"),
        StretchMove("手指屈肌拉伸", "Finger Flexor Stretch", part: .arm, target: "前臂与手臂肌群", kind: "拉伸", difficulty: 1, video: "Finger Flexor Stretch.mp4"),
        StretchMove("手指拉伸", "Finger Stretch", part: .arm, target: "前臂与手臂肌群", kind: "拉伸", difficulty: 1, video: "Finger Stretch.mp4"),
        StretchMove("鱼式", "Fish Pose Matsyasana", part: .fullBody, target: "目标拉伸肌群", kind: "瑜伽体式", difficulty: 2, video: "Fish-Pose-Matsyasana.mp4"),
        StretchMove("固定杆背部拉伸", "Fixed Bar Back Stretch", part: .back, target: "背部肌群", kind: "拉伸", difficulty: 1, video: "Fixed Bar Back Stretch.mp4"),
        StretchMove("前臂旋前肌拉伸", "Forearm Pronator Stretch", part: .arm, target: "前臂与手臂肌群", kind: "拉伸", difficulty: 1, video: "Forearm Pronator Stretch.mp4"),
        StretchMove("前臂墙面滑动", "Forearm Wall Slide", part: .arm, target: "前臂与手臂肌群", kind: "放松/筋膜", difficulty: 1, video: "Forearm Wall Slide.mp4"),
        StretchMove("颈部前屈拉伸", "Forward Flexion Neck Stretch", part: .neck, target: "颈部肌群", kind: "拉伸", difficulty: 1, video: "Forward Flexion Neck Stretch.mp4"),
        StretchMove("前侧腘绳肌拉伸", "Front Hamstring Stretch", part: .leg, target: "腘绳肌", kind: "拉伸", difficulty: 1, video: "Front Hamstring Stretch.mp4"),
        StretchMove("全莲花式", "Full Lotus Yoga Pose", part: .fullBody, target: "目标拉伸肌群", kind: "瑜伽体式", difficulty: 3, video: "Full Lotus Yoga Pose.mp4"),
        StretchMove("全蹲灵活性练习", "Full Squat Mobility", part: .fullBody, target: "目标拉伸肌群", kind: "瑜伽体式", difficulty: 2, video: "Full-Squat-Mobility.mp4"),
        StretchMove("花环式", "Garland Pose Malasana", part: .fullBody, target: "目标拉伸肌群", kind: "瑜伽体式", difficulty: 2, video: "Garland-Pose-Malasana.mp4"),
        StretchMove("半月式", "Half Moon Pose Ardha Chandrasana", part: .fullBody, target: "目标拉伸肌群", kind: "瑜伽体式", difficulty: 3, video: "Half Moon Pose Ardha Chandrasana.mp4"),
        StretchMove("腘绳肌拉伸", "Hamstring Stretch", part: .leg, target: "腘绳肌", kind: "拉伸", difficulty: 1, video: "Hamstring-Stretch.mp4"),
        StretchMove("快乐婴儿式", "Happy Baby Pose", part: .fullBody, target: "目标拉伸肌群", kind: "瑜伽体式", difficulty: 2, video: "Happy-Baby-Pose.mp4"),
        StretchMove("英雄式", "Hero Pose Virasana", part: .fullBody, target: "目标拉伸肌群", kind: "瑜伽体式", difficulty: 2, video: "Hero Pose Virasana.mp4"),
        StretchMove("髋部绕环拉伸", "Hip Circles Stretch", part: .hip, target: "髋部肌群", kind: "拉伸", difficulty: 1, video: "Hip Circles Stretch.mp4"),
        StretchMove("髋伸展拉伸", "Hip Extension Stretch", part: .hip, target: "髋部肌群", kind: "拉伸", difficulty: 1, video: "Hip Extension Stretch.mp4"),
        StretchMove("髋外旋肌拉伸", "Hip External Rotator Stretch", part: .hip, target: "髋部肌群", kind: "拉伸", difficulty: 1, video: "Hip External Rotator Stretch.mp4"),
        StretchMove("后脚抬高髋屈肌拉伸", "Hip Flexor Stretch Rear Foot Elevated", part: .hip, target: "髋部肌群", kind: "拉伸", difficulty: 1, video: "Hip Flexor Stretch Rear Foot Elevated.mp4"),
        StretchMove("进阶髋屈肌和股四头肌拉伸", "Intermediate Hip Flexor And Quad Stretch", part: .leg, target: "股四头肌、髋部肌群", kind: "拉伸", difficulty: 1, video: "Intermediate-Hip-Flexor-And-Quad-Stretch.mp4"),
        StretchMove("肩内旋拉伸", "Internal Shoulder Rotation Stretch", part: .shoulder, target: "肩部肌群", kind: "拉伸", difficulty: 1, video: "Internal Shoulder Rotation Stretch.mp4"),
        StretchMove("十字拉伸", "Iron Cross Stretch", part: .fullBody, target: "目标拉伸肌群", kind: "拉伸", difficulty: 1, video: "Iron-Cross-Stretch.mp4"),
        StretchMove("跪姿背部旋转拉伸", "Kneeling Back Rotation Stretch", part: .back, target: "背部肌群", kind: "拉伸", difficulty: 1, video: "Kneeling Back Rotation Stretch.mp4"),
        StretchMove("跪姿胸部拉伸", "Kneeling Chest Stretch", part: .chest, target: "胸大肌", kind: "拉伸", difficulty: 1, video: "Kneeling Chest Stretch.mp4"),
        StretchMove("跪姿背阔肌拉伸", "Kneeling Lat Stretch", part: .back, target: "背阔肌", kind: "拉伸", difficulty: 1, video: "Kneeling Lat Stretch.mp4"),
        StretchMove("跪姿长凳背阔肌拉伸", "Kneeling Lat Stretch on Bench", part: .back, target: "背阔肌", kind: "拉伸", difficulty: 1, video: "Kneeling Lat Stretch on Bench.mp4"),
        StretchMove("仰卧小腿拉伸", "Lying Calf Stretch", part: .leg, target: "小腿肌群", kind: "拉伸", difficulty: 1, video: "Lying Calf Stretch.mp4"),
        StretchMove("仰卧下背部拉伸", "Lying Lower Back Stretch", part: .back, target: "背部肌群", kind: "拉伸", difficulty: 1, video: "Lying Lower Back Stretch.mp4"),
        StretchMove("中背部拉伸", "Middle Back Stretch", part: .back, target: "背部肌群", kind: "拉伸", difficulty: 1, video: "Middle-Back-Stretch.mp4"),
        StretchMove("俯卧颈桥", "Neck Bridge Prone", part: .neck, target: "颈部肌群", kind: "放松/筋膜", difficulty: 1, video: "Neck-Bridge-Prone.mp4"),
        StretchMove("颈部绕环拉伸", "Neck Circle Stretch", part: .neck, target: "颈部肌群", kind: "拉伸", difficulty: 1, video: "Neck-Circle-Stretch.mp4"),
        StretchMove("颈部伸展拉伸", "Neck Extension Stretch", part: .neck, target: "颈部肌群", kind: "拉伸", difficulty: 1, video: "Neck-Extension-Stretch.mp4"),
        StretchMove("颈伸肌拉伸", "Neck Extensor Stretch", part: .neck, target: "颈部肌群", kind: "拉伸", difficulty: 1, video: "Neck-Extensor-Stretch.mp4"),
        StretchMove("颈屈肌拉伸", "Neck Flexor Stretch", part: .neck, target: "颈部肌群", kind: "拉伸", difficulty: 1, video: "Neck-Flexor-Stretch.mp4"),
        StretchMove("颈部侧向拉伸", "Neck Side Stretch", part: .neck, target: "颈部肌群", kind: "拉伸", difficulty: 1, video: "Neck-Side-Stretch.mp4"),
        StretchMove("单臂靠墙拉伸", "One Arm Against Wall", part: .fullBody, target: "目标拉伸肌群", kind: "拉伸", difficulty: 1, video: "One Arm Against Wall.mp4"),
        StretchMove("单臂背阔肌拉伸", "One Arm Lat Stretch", part: .back, target: "背阔肌", kind: "拉伸", difficulty: 1, video: "One-Arm-Lat-Stretch.mp4"),
        StretchMove("开书式拉伸", "Open Book Stretch", part: .fullBody, target: "目标拉伸肌群", kind: "拉伸", difficulty: 2, video: "Open-Book-Stretch.mp4"),
        StretchMove("过头肱三头肌拉伸", "Overhead Triceps Stretch", part: .arm, target: "前臂与手臂肌群", kind: "拉伸", difficulty: 1, video: "Overhead-Triceps-Stretch.mp4"),
        StretchMove("腓骨肌拉伸", "Peroneals Stretch", part: .leg, target: "小腿肌群", kind: "拉伸", difficulty: 1, video: "Peroneals Stretch.mp4"),
        StretchMove("犁式", "Plow Yoga Pose", part: .fullBody, target: "目标拉伸肌群", kind: "瑜伽体式", difficulty: 3, video: "Plow Yoga Pose.mp4"),
        StretchMove("胫骨后肌拉伸", "Posterior Tibialis Stretch", part: .leg, target: "小腿肌群", kind: "拉伸", difficulty: 1, video: "Posterior Tibialis Stretch.mp4"),
        StretchMove("PVC 管外旋", "PVC External Rotation", part: .fullBody, target: "目标拉伸肌群", kind: "肩胛/关节活动", difficulty: 1, video: "Pvc External Rotation.mp4"),
        StretchMove("PVC 管前架位拉伸", "PVC Front Rack Stretch", part: .fullBody, target: "目标拉伸肌群", kind: "拉伸", difficulty: 1, video: "Pvc Front Rack Stretch.mp4"),
        StretchMove("股四头肌拉伸", "Quadriceps Stretch", part: .leg, target: "股四头肌", kind: "拉伸", difficulty: 1, video: "Quadriceps-Stretch.mp4"),
        StretchMove("上举肩部拉伸", "Reaching Up Shoulder Stretch", part: .shoulder, target: "肩部肌群", kind: "拉伸", difficulty: 1, video: "Reaching Up Shoulder Stretch.mp4"),
        StretchMove("前伸上背部拉伸", "Reaching Upper Back Stretch", part: .back, target: "背部肌群", kind: "拉伸", difficulty: 1, video: "Reaching Upper Back Stretch.mp4"),
        StretchMove("背部滚动拉伸", "Roll Back Stretch", part: .back, target: "背部肌群", kind: "拉伸", difficulty: 1, video: "Roll Back Stretch.mp4"),
        StretchMove("上背部滚压", "Roll Upper Back", part: .back, target: "背部肌群", kind: "放松/筋膜", difficulty: 1, video: "Roll Upper Back.mp4"),
        StretchMove("腹部旋转拉伸", "Rotating Stomach Stretch", part: .core, target: "腹部肌群", kind: "拉伸", difficulty: 1, video: "Rotating Stomach Stretch.mp4"),
        StretchMove("肩胛上提下压", "Scapula Elevation Depression", part: .fullBody, target: "目标拉伸肌群", kind: "肩胛/关节活动", difficulty: 1, video: "Scapula Elevation Depression.mp4"),
        StretchMove("肩胛后缩前伸", "Scapula Retraction Protraction", part: .fullBody, target: "目标拉伸肌群", kind: "肩胛/关节活动", difficulty: 1, video: "Scapula Retraction Protraction.mp4"),
        StretchMove("坐姿脊柱扭转", "Seated Spinal Twist", part: .fullBody, target: "目标拉伸肌群", kind: "瑜伽体式", difficulty: 2, video: "Seated-Spinal-Twist.mp4"),
        StretchMove("单侧直腿拉伸", "Single Straight Leg Stretch", part: .fullBody, target: "目标拉伸肌群", kind: "拉伸", difficulty: 1, video: "Single Straight Leg Stretch.mp4"),
        StretchMove("狮身人面式", "Sphinx", part: .fullBody, target: "目标拉伸肌群", kind: "瑜伽体式", difficulty: 2, video: "Sphinx.mp4"),
        StretchMove("脊柱前屈拉伸", "Spine Stretch Forward", part: .back, target: "背部肌群", kind: "拉伸", difficulty: 1, video: "Spine Stretch Forward.mp4"),
        StretchMove("拇指拉伸", "Thumb Stretch", part: .arm, target: "前臂与手臂肌群", kind: "拉伸", difficulty: 1, video: "Thumb Stretch.mp4"),
        StretchMove("按摩棒前臂放松", "Tiger Tail Forearm", part: .arm, target: "前臂与手臂肌群", kind: "放松/筋膜", difficulty: 1, video: "Tiger Tail Forearm.mp4"),
        StretchMove("按摩棒颈部放松", "Tiger Tail Neck", part: .neck, target: "颈部肌群", kind: "放松/筋膜", difficulty: 1, video: "Tiger Tail Neck.mp4"),
        StretchMove("树式", "Tree Pose Vrksasana", part: .fullBody, target: "目标拉伸肌群", kind: "瑜伽体式", difficulty: 2, video: "Tree Pose Vrksasana.mp4"),
        StretchMove("三角式", "Triangle Pose Trikonasana", part: .fullBody, target: "目标拉伸肌群", kind: "瑜伽体式", difficulty: 2, video: "Triangle Pose Trikonasana.mp4"),
        StretchMove("肱三头肌拉伸", "Triceps Stretch", part: .arm, target: "前臂与手臂肌群", kind: "拉伸", difficulty: 1, video: "Triceps Stretch.mp4"),
        StretchMove("上背部拉伸", "Upper Back Stretch", part: .back, target: "背部肌群", kind: "拉伸", difficulty: 1, video: "Upper-Back-Stretch.mp4"),
        StretchMove("上犬式", "Upward Facing Dog", part: .fullBody, target: "目标拉伸肌群", kind: "瑜伽体式", difficulty: 2, video: "Upward-Facing-Dog.mp4"),
        StretchMove("手腕绕环", "Wrist Circles", part: .arm, target: "前臂与手臂肌群", kind: "绕环", difficulty: 1, video: "Wrist Circles.mp4"),
        StretchMove("腕伸肌拉伸", "Wrist Extensor Stretch", part: .arm, target: "前臂与手臂肌群", kind: "拉伸", difficulty: 1, video: "Wrist Extensor Stretch.mp4"),
        StretchMove("腕屈肌拉伸", "Wrist Flexor Stretch", part: .arm, target: "前臂与手臂肌群", kind: "拉伸", difficulty: 1, video: "Wrist Flexor Stretch.mp4"),
    ]

    /// 某部位下的全部拉伸动作。
    static func moves(in part: StretchPart) -> [StretchMove] {
        moves.filter { $0.part == part }
    }

    /// 各部位计数（用于 tab 标签）。
    static func count(in part: StretchPart) -> Int {
        moves(in: part).count
    }

    /// 关键词搜索（中文名 / 英文名 / 目标 / 类型）。
    static func search(_ keyword: String) -> [StretchMove] {
        let key = keyword.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !key.isEmpty else { return [] }
        return moves.filter {
            $0.name.lowercased().contains(key)
                || $0.nameEn.lowercased().contains(key)
                || $0.target.lowercased().contains(key)
                || $0.kind.lowercased().contains(key)
        }
    }
}
