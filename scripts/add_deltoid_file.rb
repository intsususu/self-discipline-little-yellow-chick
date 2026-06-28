# 一次性接线：把 DeltoidDiagramView.swift 加入 HealthApp target 的 Sources。
# 用法：RUBYOPT="-EUTF-8" ruby scripts/add_deltoid_file.rb
require "xcodeproj"
PROJECT = "HealthApp.xcodeproj"
REL = "HealthApp/Features/Tools/TrainingPlan/DeltoidDiagramView.swift"
project = Xcodeproj::Project.open(PROJECT)
app = project.targets.find { |t| t.name == "HealthApp" } or abort "找不到 App target"
abs = File.expand_path(REL)
ref = project.files.find { |f| f.real_path.to_s == abs }
if ref.nil?
  dir = File.dirname(REL)
  grp = project.main_group.children.find { |g| g.is_a?(Xcodeproj::Project::Object::PBXGroup) && g.path == dir } ||
        project.main_group.new_group(File.basename(dir), dir)
  ref = grp.new_file(File.basename(REL))
end
unless app.source_build_phase.files_references.include?(ref)
  app.add_file_references([ref])
  puts "已加入 target：#{REL}"
else
  puts "已存在于 target，跳过"
end
project.save
