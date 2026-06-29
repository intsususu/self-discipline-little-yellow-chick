# 一次性接线：把「运动自动打卡 / 桌面组件后台更新」新增的 Swift 文件加入对应 target。
#   · AutoCheckIn.swift          —— 共享判定逻辑，App + Widget 两个 target；
#   · AutoCheckInObserver.swift  —— HealthKit 后台投递，仅 App target。
# 用法：RUBYOPT="-EUTF-8" ruby scripts/add_autocheckin_files.rb
require "xcodeproj"

PROJECT = "HealthApp.xcodeproj"

project = Xcodeproj::Project.open(PROJECT)
app    = project.targets.find { |t| t.name == "HealthApp" } or abort "找不到 App target"
widget = project.targets.find { |t| t.name == "SelfDisciplineWidgetExtension" } or abort "找不到 Widget target"

# 找（或建）一个 path 显式指向真实目录的逻辑分组，否则文件 real_path 会丢目录层级。
def group_for(project, rel_dir)
  project.main_group.recursive_children.find { |g|
    g.is_a?(Xcodeproj::Project::Object::PBXGroup) && g.path == rel_dir
  } || project.main_group.new_group(File.basename(rel_dir), rel_dir)
end

def add(project, group, name, targets)
  rel = "#{group.path}/#{name}"
  abs = File.expand_path(rel)
  ref = project.files.find { |f| f.real_path.to_s == abs } || group.new_file(name)
  targets.each do |t|
    if t.source_build_phase.files_references.include?(ref)
      puts "已存在，跳过：#{name} @ #{t.name}"
    else
      t.add_file_references([ref])
      puts "已加入 #{t.name}：#{name}"
    end
  end
end

shared_group = group_for(project, "HealthApp/SelfDiscipline/Shared")
sd_group     = group_for(project, "HealthApp/SelfDiscipline")

add(project, shared_group, "AutoCheckIn.swift",         [app, widget])
add(project, sd_group,     "AutoCheckInObserver.swift", [app])

project.save
puts "完成。"
