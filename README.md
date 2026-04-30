# WeChat Duplicate

macOS 微信双开解决方案，支持自定义图标替换（含深色模式），基于 [Raycast](https://raycast.com) Script Command。

## 功能特性

- 🔄 **一键克隆** — 将 WeChat.app 复制为 WeChat2.app，自动修改 Bundle ID 并重新签名
- 🎨 **自定义图标** — 支持选择 `.icns` 文件替换图标，深色模式同样生效
- 🚀 **Raycast 集成** — 作为 Raycast Script Command 使用，随时呼出

## 文件说明

| 文件 | 说明 |
|------|------|
| `wechat_duplicate.applescript` | 微信双开 + 自定义图标替换（含深色模式支持） |
| `wechat_duplicate_without_icon.applescript` | 微信双开（不替换图标，轻量版） |
| `微信双开.sh` | 快速启动已克隆的 WeChat2（需先运行上述脚本完成克隆） |

## 使用方法

### 前置要求

- macOS 系统
- 已安装 [Raycast](https://raycast.com)（或使用系统脚本编辑器运行）
- 已安装微信（WeChat）

### 方式一：通过 Raycast 使用（推荐）

1. 将脚本文件放入 Raycast 的 Script Command 目录
2. 在 Raycast 中搜索 `WeChat_Duplicate` 并执行
3. 根据提示选择 `.icns` 图标文件（带图标版本）
4. 输入管理员密码，等待克隆完成

### 方式二：通过脚本编辑器使用

1. 右键 `.applescript` 文件 → 打开方式 → 脚本编辑器
2. 点击运行按钮 ▶️

## 工作原理

```
cp WeChat.app → WeChat2.app       # 克隆应用
        ↓
修改 CFBundleIdentifier            # 系统识别为独立应用
        ↓
替换 AppIcon.icns                  # 自定义浅色模式图标
        ↓
删除 CFBundleIconName              # 防止 Asset Catalog 覆盖
        ↓
codesign 重新签名                   # 确保图标和签名一致
        ↓
NSWorkspace.setIcon (Swift)        # 写入 Finder 资源叉，覆盖深色模式
        ↓
killall iconservicesd + Dock       # 清除缓存，立即生效
```

### 深色模式图标替换

macOS 会自动为 Dock 图标生成深色模式变体。仅替换 `.icns` 文件无法覆盖深色模式图标。

本脚本通过编译一个 Swift 小工具，调用 `NSWorkspace.shared.setIcon()` 将自定义图标写入应用的 **Finder 资源叉（Resource Fork）**，等同于在「显示简介」中粘贴图标，使 macOS 在深色/浅色模式下都使用自定义图标。

## 许可证

[MIT License](LICENSE)
