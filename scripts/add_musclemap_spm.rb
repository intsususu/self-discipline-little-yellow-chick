# 一次性接线：
#  1) 给 HealthApp 加 SPM 依赖 MuscleMap（melihcolpan/MuscleMap, >=1.6.4）
#  2) 从 target 移除已删除文件 DeltoidDiagramView.swift / BodyPaths.swift 的引用
# 用法：RUBYOPT="-EUTF-8" ruby scripts/add_musclemap_spm.rb
require "xcodeproj"

project = Xcodeproj::Project.open("HealthApp.xcodeproj")
app = project.targets.find { |t| t.name == "HealthApp" } or abort "找不到 App target"
URL = "https://github.com/melihcolpan/MuscleMap"

# 1) 远程包引用（幂等）
pkg = project.root_object.package_references.find { |r|
  r.respond_to?(:repositoryURL) && r.repositoryURL == URL
}
if pkg.nil?
  pkg = project.new(Xcodeproj::Project::Object::XCRemoteSwiftPackageReference)
  pkg.repositoryURL = URL
  pkg.requirement = { "kind" => "upToNextMajorVersion", "minimumVersion" => "1.6.4" }
  project.root_object.package_references << pkg
  puts "已添加 SPM 包引用：#{URL}"
else
  puts "SPM 包引用已存在"
end

# 2) 产品依赖 + frameworks 阶段（幂等）
dep = app.package_product_dependencies.find { |d| d.product_name == "MuscleMap" }
if dep.nil?
  dep = project.new(Xcodeproj::Project::Object::XCSwiftPackageProductDependency)
  dep.package = pkg
  dep.product_name = "MuscleMap"
  app.package_product_dependencies << dep
  bf = project.new(Xcodeproj::Project::Object::PBXBuildFile)
  bf.product_ref = dep
  app.frameworks_build_phase.files << bf
  puts "已把 MuscleMap 链接到 HealthApp target"
else
  puts "MuscleMap 产品依赖已存在"
end

# 3) 清掉已删除文件的引用
["DeltoidDiagramView.swift", "BodyPaths.swift"].each do |name|
  refs = project.files.select { |f| f.path && File.basename(f.path) == name }
  refs.each do |ref|
    app.source_build_phase.files.select { |bf| bf.file_ref == ref }.each(&:remove_from_project)
    ref.remove_from_project
    puts "已移除引用：#{name}"
  end
end

project.save
puts "完成。App target sources: #{app.source_build_phase.files.count} 文件"
