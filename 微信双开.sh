#!/bin/bash
# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title 微信双开
# @raycast.mode compact

# Optional parameters:
# @raycast.icon 🤖
# @raycast.packageName Application Scripts

# Documentation:
# @raycast.description 微信双开
# @raycast.author yangyangSheep
# @raycast.authorURL https://raycast.com/yangyangSheep



# 1.​复制微信应用​
# 终端执行：
# sudo cp -R /Applications/WeChat.app /Applications/WeChat2.app
# 2.​修改 Bundle ID​
# 防止微信检测为同一应用：（直接复制下面两行的内容，不要分别复制）

# sudo /usr/libexec/PlistBuddy -c "Set :CFBundleIdentifier com.tencent.xinWeChat2" /Applications/WeChat2.app/Contents/Info.plist

# 3.​重新签名应用​
# 终端执行（需输入密码）：

# sudo codesign --force --deep --sign - /Applications/WeChat2.app

# ​4.启动双开​
# 手动打开第一个微信（原应用）
# 终端启动第二个：

# nohup /Applications/WeChat2.app/Contents/MacOS/WeChat >/dev/null 2>&1 &

# 第二个终端应用启动后，可以选择右键在程序坞中保留，这样下次直接点程序坞的程序就可以运行了，不需要再次使用终端命令打开第二个微信。
# 用此方法也不影响微信输入法的正常使用。

# 5.替换图标
# 修改包内的Appicon文件并且清理Dock缓存



# sudo find /private/var/folders/ -name com.apple.dock.iconcache -exec rm {} \;
# sudo find /private/var/folders/ -name com.apple.iconservices -exec rm -rf {} \;
# killall Dock
echo "正在打开微信2"

nohup /Applications/WeChat2.app/Contents/MacOS/WeChat > /dev/null 2>&1 &

echo "正在打开微信1"

nohup /Applications/WeChat.app/Contents/MacOS/WeChat > /dev/null 2>&1 &


