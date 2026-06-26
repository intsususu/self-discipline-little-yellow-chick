# add_widget_target.rb
# 一次性接线脚本：为 HealthApp 工程新增「自律打卡」WidgetKit extension target，
# 配置 App Group、把共享源文件加入两个 target，并将 extension 嵌入主 App。
#
# 用法：RUBYOPT="-EUTF-8" ruby scripts/add_widget_target.rb
# 幂等：若 target 已存在则跳过创建。

require "xcodeproj"

PROJECT      = "HealthApp.xcodeproj"
APP_TARGET   = "HealthApp"
EXT_TARGET   = "SelfDisciplineWidgetExtension"
APP_BUNDLE   = "com.xltc.sdlyc"
EXT_BUNDLE   = "com.xltc.sdlyc.SelfDisciplineWidget"
TEAM         = "64FF893SV4"
DEPLOY       = "17.0"

# 共享源文件（编入主 App 与 Widget 两个 target），路径相对仓库根。
SHARED_FILES = [
  "HealthApp/SelfDiscipline/Shared/SelfDisciplineModel.swift",
  "HealthApp/SelfDiscipline/Shared/CheckInStore.swift",
  "HealthApp/SelfDiscipline/Shared/SelfDisciplineSnapshot.swift",
  "HealthApp/SelfDiscipline/Shared/SelfDisciplineUI.swift",
]
# 仅主 App 的新文件。
APP_ONLY_FILES = [
  "HealthApp/Features/Tools/SelfDiscipline/SelfDisciplineView.swift",
]
# 仅 Widget 的新文件。
WIDGET_FILES = [
  "SelfDisciplineWidget/SelfDisciplineWidgetBundle.swift",
  "SelfDisciplineWidget/SelfDisciplineWidget.swift",
  "SelfDisciplineWidget/CheckInIntent.swift",
]
# 已存在、需同时编入 Widget 的文件（颜色 token）。
SHARED_EXISTING = [
  "HealthApp/DesignSystem/Color+Tokens.swift",
]

project = Xcodeproj::Project.open(PROJECT)
app = project.targets.find { |t| t.name == APP_TARGET } or abort "找不到 App target"

# 按目录缓存逻辑分组：分组 path 设为相对 SRCROOT 的完整目录，保证文件 real_path 正确。
# 幂等：优先复用已存在、path 相同的分组。
GROUP_CACHE = {}
def group_for(project, dir)
  GROUP_CACHE[dir] ||= (
    project.main_group.children.find { |g| g.is_a?(Xcodeproj::Project::Object::PBXGroup) && g.path == dir } ||
    project.main_group.new_group(File.basename(dir), dir)
  )
end

# 找到（或创建）某仓库相对路径对应的 PBXFileReference。
def file_ref(project, rel_path)
  abs = File.expand_path(rel_path)
  existing = project.files.find { |f| f.real_path.to_s == abs }
  return existing if existing
  group_for(project, File.dirname(rel_path)).new_file(File.basename(rel_path))
end

# 1) 新文件加入主 App
(SHARED_FILES + APP_ONLY_FILES).each do |rel|
  ref = file_ref(project, rel)
  app.add_file_references([ref]) unless app.source_build_phase.files_references.include?(ref)
end

# 2) 创建 Widget extension target（幂等）
ext = project.targets.find { |t| t.name == EXT_TARGET }
if ext.nil?
  ext = project.new_target(:app_extension, EXT_TARGET, :ios, DEPLOY)
  ext.product_type = "com.apple.product-type.app-extension"
end

ext.build_configurations.each do |cfg|
  s = cfg.build_settings
  s["PRODUCT_BUNDLE_IDENTIFIER"] = EXT_BUNDLE
  s["PRODUCT_NAME"]              = "$(TARGET_NAME)"
  s["INFOPLIST_FILE"]           = "SelfDisciplineWidget/Info.plist"
  s["CODE_SIGN_ENTITLEMENTS"]   = "SelfDisciplineWidget/SelfDisciplineWidget.entitlements"
  s["CODE_SIGN_STYLE"]          = "Automatic"
  s["DEVELOPMENT_TEAM"]         = TEAM
  s["IPHONEOS_DEPLOYMENT_TARGET"] = DEPLOY
  s["SWIFT_VERSION"]            = "5.0"
  s["GENERATE_INFOPLIST_FILE"]  = "NO"
  s["SKIP_INSTALL"]             = "YES"
  s["TARGETED_DEVICE_FAMILY"]   = "1,2"
  s["SWIFT_EMIT_LOC_STRINGS"]   = "YES"
  s["CURRENT_PROJECT_VERSION"]  = "1"
  s["MARKETING_VERSION"]        = "1.0"
  s["LD_RUNPATH_SEARCH_PATHS"]  = ["$(inherited)", "@executable_path/Frameworks", "@executable_path/../../Frameworks"]
end

# 3) Widget 源文件加入 Widget target（含共享文件与 Color+Tokens）
widget_refs = (WIDGET_FILES + SHARED_FILES + SHARED_EXISTING).map { |rel| file_ref(project, rel) }
existing_ext_refs = ext.source_build_phase.files_references
ext.add_file_references(widget_refs.reject { |r| existing_ext_refs.include?(r) })

# 4) 把 extension 嵌入主 App（依赖 + Embed App Extensions 拷贝阶段）
app.add_dependency(ext) unless app.dependencies.any? { |d| d.target == ext }

embed = app.copy_files_build_phases.find { |ph| ph.name == "Embed App Extensions" }
if embed.nil?
  embed = app.new_copy_files_build_phase("Embed App Extensions")
  embed.symbol_dst_subfolder_spec = :plug_ins
  embed.dst_path = ""
end
prod = ext.product_reference
unless embed.files_references.include?(prod)
  bf = embed.add_file_reference(prod)
  bf.settings = { "ATTRIBUTES" => ["RemoveHeadersOnCopy"] }
end

# 5) Widget 资源目录（背景插图）加入 Widget target 的 Resources
assets_rel = "SelfDisciplineWidget/Assets.xcassets"
if Dir.exist?(assets_rel)
  ref = file_ref(project, assets_rel)
  unless ext.resources_build_phase.files_references.include?(ref)
    ext.resources_build_phase.add_file_reference(ref)
  end
end

project.save
puts "完成：#{EXT_TARGET} 已创建并嵌入 #{APP_TARGET}。"
puts "App target sources: #{app.source_build_phase.files.count} 文件"
puts "Widget target sources: #{ext.source_build_phase.files.count} 文件"
