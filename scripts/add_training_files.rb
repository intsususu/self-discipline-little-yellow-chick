# 一次性接线：把训练计划重构新增的 Swift 文件加入 HealthApp target 的 Sources。
# 用法：RUBYOPT="-EUTF-8" ruby scripts/add_training_files.rb
require "xcodeproj"

PROJECT = "HealthApp.xcodeproj"
DIR = "HealthApp/Features/Tools/TrainingPlan"
FILES = %w[
  StretchData.swift
  HIITData.swift
  HIITWorkouts.swift
  TrainingPlanPresets.swift
  MoveDetailView.swift
  TrainingSearchView.swift
  HIITCalorie.swift
]

project = Xcodeproj::Project.open(PROJECT)
app = project.targets.find { |t| t.name == "HealthApp" } or abort "找不到 App target"
grp = project.main_group.children.find { |g| g.is_a?(Xcodeproj::Project::Object::PBXGroup) && g.path == DIR } ||
      project.main_group.new_group(File.basename(DIR), DIR)

FILES.each do |name|
  rel = "#{DIR}/#{name}"
  abs = File.expand_path(rel)
  ref = project.files.find { |f| f.real_path.to_s == abs } || grp.new_file(name)
  if app.source_build_phase.files_references.include?(ref)
    puts "已存在，跳过：#{name}"
  else
    app.add_file_references([ref])
    puts "已加入 target：#{name}"
  end
end

project.save
