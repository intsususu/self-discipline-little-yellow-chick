# 训练计划页重构 · 施工总览

> 把现在的「4 部位硬编码图鉴」重构成对标 [docs/fitness/index.html](../../fitness/index.html) 的**动作库**：7 类共 86 个精选动作，每个动作带英文名 / 主练肌群 / 类型 / 难度(1–5) / 男女演示视频（先占位），并提供**可点击的人体解剖图**按肌群筛选动作。
>
> 原型见会话中的三屏原型图（动作库主页 / 动作详情 / 解剖图选肌群）。
> 旧设计（4 部位）见 [docs/prd/训练计划设计.md](../../prd/训练计划设计.md)，本次重构取代其内容定位。

## 已确认的范围口径

1. **视频素材**：先做**占位**（详情页视频区用占位图/图标，数据模型预留 `maleVideo`/`femaleVideo` 字段），素材到位再接入。仓库当前无任何 mp4，docs 里的 `../downloads/*.mp4` 链接尚未就位。
   - **演示性别不做手动切换**：按个人资料性别（[ProfileStore](../../../HealthApp/Features/Profile/UserProfile.swift) `profile.gender`）自动匹配。`.female` → 女版，其余（`.male` / `.other` / 未填，默认即 `.male`）→ 男版。各页沿用项目现有模式 `@StateObject private var profileStore = ProfileStore()` 读取（参考 [NutrientTierView.swift:9](../../../HealthApp/Features/Tools/FoodCalorie/NutrientTierView.swift)）。
2. **收录范围**：**7 类全量 86 个精选**（核心 / 胸 / 背 / 肩 / 手臂 / 下肢 / 功能），数据源 [docs/fitness/index.md](../../fitness/index.md)。
3. **解剖图**：做**可点击解剖图**（点正/背面人体高亮肌群 → 筛选动作）。

## 复用的外部资源（GitHub 检索结论）

| 用途 | 仓库 | 协议 | 怎么用 |
|---|---|---|---|
| 人体形状 SVG 路径（正/背 + 男/女，按肌群 slug） | [HichamELBSI/react-native-body-highlighter](https://github.com/HichamELBSI/react-native-body-highlighter) `assets/body*.ts` | MIT | **只移植 path 数据**，不引运行时依赖；保留 MIT 署名 |
| SVG path → iOS `CGPath` 解析与渲染 | [PocketSVG](https://github.com/pocketsvg/PocketSVG) | MIT | SPM 接入；或自写极小 path 解析器（见 TP04） |
| 动作图片占位 / 肌群映射参照（可选） | [yuhonas/free-exercise-db](https://github.com/yuhonas/free-exercise-db) | 公有领域 | 视频未就位时可借图片占位 |

## 任务拆分与依赖

```
TP01 数据层 ──┬─> TP02 动作库主页 ──┐
              ├─> TP03 动作详情页 ──┼─> TP05 工程接线与联调
              └─> TP04 可点击解剖图 ┘
```

| 任务 | 内容 | 依赖 | 可独立交付 |
|---|---|---|---|
| [TP01](TP01-数据层.md) ✅ | 数据模型扩展 + 86 个动作数据生成 | — | 已完成 |
| [TP02](TP02-动作库主页.md) | 主页：搜索 / 部位 tabs / 类型 chips / 动作列表（演示性别随资料） | TP01 | 是 |
| [TP03](TP03-动作详情页.md) | 详情页：视频占位 / 难度肌群类型 / 发力图 / 要点 | TP01 | 是 |
| [TP04](TP04-可点击解剖图.md) | 正/背面人体 SVG + 点肌群筛选 | TP01 | 是（最大难点，可后做） |
| [TP05](TP05-工程接线与联调.md) | Xcode target 接线 / 入口 / 联调 / 真机验证 | TP01–04 | 收尾 |

## 进度

- **TP01 已完成**（2026-06-28）：[TrainingPlanModels.swift](../../../HealthApp/Features/Tools/TrainingPlan/TrainingPlanModels.swift) 重写为动作库模型（`MuscleCategory` / `MuscleGroup` / `Exercise` + 86 个动作 + 查询接口）。旧 4 部位 UI 已替换为**过渡版**（[TrainingPlanView.swift](../../../HealthApp/Features/Tools/TrainingPlan/TrainingPlanView.swift) 分类切换 + 列表，[ExerciseCard.swift](../../../HealthApp/Features/Tools/TrainingPlan/ExerciseCard.swift) 精简行），项目编译通过、可运行。`points`/`setsReps` 取方案 A（暂空）。完整 UI 待 TP02/TP03。

## 建议施工顺序

最快出可用版本：**TP01 → TP02 → TP03 → TP05（先接线跑通）→ TP04（解剖图后补）**。
TP04 工作量最大且可独立，留到主流程跑通后再做，避免阻塞。

## 全局约定

- 全中文界面，复用 App 现有 `CardView` / 颜色 token（`.brandBlue` `.cardBg` `.textPrimary` 等）。
- 新文件按[非同步组工程规则](../../../HealthApp.xcodeproj/project.pbxproj)用 xcodeproj 脚本接 target（见 TP05），不要只丢文件。
- 底部保留免责声明：「训练动作仅供参考，请量力而行，必要时在专业指导下进行」。
- 现有 4 部位文件 [TrainingPlanView.swift](../../../HealthApp/Features/Tools/TrainingPlan/TrainingPlanView.swift) / [ExerciseCard.swift](../../../HealthApp/Features/Tools/TrainingPlan/ExerciseCard.swift) / [TrainingPlanModels.swift](../../../HealthApp/Features/Tools/TrainingPlan/TrainingPlanModels.swift) 将被重写/拆分，注意 git 历史。
