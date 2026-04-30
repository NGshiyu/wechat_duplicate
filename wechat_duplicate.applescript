#!/usr/bin/osascript

# Raycast metadata
# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title WeChat_Duplicate
# @raycast.mode compact

# Optional parameters:
# @raycast.icon 🤖
# @raycast.packageName Raycast Script

# Documentation:
# @raycast.description 克隆 WeChat 为 Wechat2 用于双开，并更换自定义图标
# @raycast.author yangyangSheep
# @raycast.authorURL https://raycast.com/yangyangSheep

# Step 0: 如果已存在 WeChat2.app，则删除
try
	set checkExists to "if [ -d /Applications/WeChat2.app ]; then echo 'EXISTS'; fi"
	set result to do shell script checkExists

	if result is equal to "EXISTS" then
		display dialog "检测到已存在 WeChat2.app，将删除旧版本。" buttons {"继续"} default button 1
		do shell script "rm -rf /Applications/WeChat2.app" with administrator privileges
	end if
end try

# Step 1: 选择图标文件
set iconFile to choose file with prompt "请选择一个 .icns 图标文件"
set iconPath to POSIX path of iconFile

# Step 2: 确认操作
try
	display dialog "即将开始克隆 WeChat 并替换图标，是否继续？" buttons {"取消", "继续"} default button "继续" cancel button "取消"
on error
	display dialog "❌ 已取消操作。" buttons {"OK"} default button 1
	return
end try

# Step 3: 执行克隆和图标替换（注意顺序：先替换图标，再签名）
try
	-- 3.1 复制应用
	do shell script "cp -R /Applications/WeChat.app /Applications/WeChat2.app" with administrator privileges

	-- 3.2 修改 Bundle ID
	do shell script "/usr/libexec/PlistBuddy -c \"Set :CFBundleIdentifier com.tencent.xinWeChat2\" /Applications/WeChat2.app/Contents/Info.plist" with administrator privileges

	-- 3.3 替换图标文件（必须在签名之前）
	do shell script "cp \"" & iconPath & "\" \"/Applications/WeChat2.app/Contents/Resources/AppIcon.icns\"" with administrator privileges

	-- 3.4 删除 CFBundleIconName 键（避免 macOS 优先从 Asset Catalog 读取图标而忽略 .icns 文件）
	try
		do shell script "/usr/libexec/PlistBuddy -c \"Delete :CFBundleIconName\" /Applications/WeChat2.app/Contents/Info.plist" with administrator privileges
	end try

	-- 3.5 重新签名（在图标替换之后，否则签名会校验失败导致图标不生效）
	do shell script "codesign --force --deep --sign - /Applications/WeChat2.app" with administrator privileges

	-- 3.6 编译图标设置工具（首次运行时编译，后续复用）
	try
		do shell script "test -f /tmp/set_icon || swiftc -o /tmp/set_icon -framework Cocoa -e '
import Cocoa
guard CommandLine.arguments.count >= 3 else { exit(1) }
if let img = NSImage(contentsOfFile: CommandLine.arguments[1]) {
let r = NSWorkspace.shared.setIcon(img, forFile: CommandLine.arguments[2], options: [])
exit(r ? 0 : 1)
}
exit(1)
'"
	end try

	-- 3.7 通过 Finder 资源叉设置自定义图标（覆盖深色模式自动着色）
	-- 需要先将 app 所有权改为当前用户，NSWorkspace.setIcon 才能写入资源叉
	do shell script "chown -R $(whoami) /Applications/WeChat2.app && /tmp/set_icon \"" & iconPath & "\" /Applications/WeChat2.app && chown -R root:admin /Applications/WeChat2.app" with administrator privileges

	-- 3.8 清理图标缓存并刷新（彻底覆盖深色模式图标）
	try
		do shell script "/System/Library/Frameworks/CoreServices.framework/Versions/A/Frameworks/LaunchServices.framework/Versions/A/Support/lsregister -f /Applications/WeChat2.app"
	end try
	try
		do shell script "killall -KILL iconservicesd 2>/dev/null; killall -KILL iconservicesagent 2>/dev/null" with administrator privileges
	end try
	try
		do shell script "touch /Applications/WeChat2.app"
		do shell script "killall Dock"
		do shell script "killall Finder"
	end try

	display dialog "✅ WeChat2 克隆成功，图标已替换并重新签名！" buttons {"好的"} default button 1
on error errMsg
	display dialog "❌ 出错了：" & errMsg buttons {"OK"} default button 1
end try
