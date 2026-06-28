// MuscleBodyView.swift
// 小工具 · 训练计划：可复用人体肌群图。
// 渲染基于 MuscleMap SDK（melihcolpan/MuscleMap, MIT, SwiftUI）——真人体正/背解剖图，
// 三角肌分前/中/后束。此处做 项目 MuscleGroup ↔ SDK Muscle 的映射与正背双图布局。

import SwiftUI
import MuscleMap

struct MuscleBodyView: View {
    let highlighted: Set<MuscleGroup>
    var onTap: ((MuscleGroup) -> Void)? = nil
    var accent: Color = .exerciseOrange
    var isFemale: Bool = false

    private var gender: BodyGender { isFemale ? .female : .male }

    private var highlightMuscles: [Muscle] {
        Array(Set(highlighted.flatMap { MuscleMapping.muscles(for: $0) }))
    }

    var body: some View {
        HStack(spacing: 12) {
            figure(.front)
            figure(.back)
        }
        .accessibilityElement(children: .contain)
    }

    private func figure(_ side: BodySide) -> some View {
        VStack(spacing: 6) {
            bodyView(side)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            Text(side == .front ? "正面" : "背面")
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.textMuted)
        }
    }

    @ViewBuilder
    private func bodyView(_ side: BodySide) -> some View {
        // showSubGroups：默认会跳过 frontDeltoid/rearDeltoid 等子分组，开启后才能单独高亮前/后束。
        let base = BodyView(gender: gender, side: side)
            .showSubGroups()
            .highlight(highlightMuscles, color: accent)
        if let onTap {
            base.onMuscleSelected { muscle, _ in
                if let group = MuscleMapping.group(from: muscle) {
                    onTap(group)
                }
            }
        } else {
            base
        }
    }
}

// MARK: - MuscleGroup ↔ SDK Muscle 映射

enum MuscleMapping {
    /// 项目肌群 → SDK 肌肉（用于高亮）。多数一对一，缺对应时取最接近。
    static func muscles(for group: MuscleGroup) -> [Muscle] {
        switch group {
        case .abs:           return [.abs]
        case .obliques:      return [.obliques]
        case .chest:         return [.chest]
        case .biceps:        return [.biceps]
        case .triceps:       return [.triceps]
        case .forearm:       return [.forearm]
        case .frontDeltoids: return [.frontDeltoid]
        case .deltoids:      return [.deltoids]
        case .rearDeltoids:  return [.rearDeltoid]
        case .trapezius:     return [.trapezius]
        case .upperBack:     return [.upperBack]
        case .lowerBack:     return [.lowerBack]
        case .quadriceps:    return [.quadriceps]
        case .hamstring:     return [.hamstring]
        case .gluteal:       return [.gluteal]
        case .calves:        return [.calves]
        case .adductor:      return [.adductors]
        case .abductors:     return [.gluteal]
        case .neck:          return [.neck]
        }
    }

    /// SDK 肌肉（点击命中）→ 项目肌群。含子束归并到主肌群；无对应返回 nil。
    static func group(from muscle: Muscle) -> MuscleGroup? {
        switch muscle {
        case .abs, .upperAbs, .lowerAbs:            return .abs
        case .obliques:                             return .obliques
        case .chest, .upperChest, .lowerChest:      return .chest
        case .biceps:                               return .biceps
        case .triceps:                              return .triceps
        case .forearm:                              return .forearm
        case .frontDeltoid:                         return .frontDeltoids
        case .deltoids:                             return .deltoids
        case .rearDeltoid:                          return .rearDeltoids
        case .trapezius, .upperTrapezius, .lowerTrapezius: return .trapezius
        case .upperBack, .rhomboids:                return .upperBack
        case .lowerBack:                            return .lowerBack
        case .quadriceps, .innerQuad, .outerQuad:   return .quadriceps
        case .hamstring:                            return .hamstring
        case .gluteal:                              return .gluteal
        case .calves:                               return .calves
        case .adductors:                            return .adductor
        case .neck:                                 return .neck
        default:                                    return nil
        }
    }
}

#Preview {
    MuscleBodyView(highlighted: [.chest, .frontDeltoids, .quadriceps])
        .frame(height: 260)
        .padding()
        .background(Color.appBg)
}
