# MenuIP

一个轻量级的 macOS 菜单栏工具，用于显示和快速复制当前设备的 IP 地址。

## 功能特性

- 🖥️ 在菜单栏实时显示当前 IP 地址（IPv4/IPv6）
- 📋 左键点击快速复制 IP 地址到剪贴板
- ⚙️ 右键点击显示操作菜单
- 🔄 每 30 秒自动刷新 IP 地址
- 🌐 优先显示以太网接口地址
- 🇨🇳 中文界面支持
- 🚫 无 Dock 图标，仅在菜单栏运行

## 系统要求

- macOS 10.15 (Catalina) 或更高版本
- Xcode 命令行工具（用于编译）

## 安装与使用

### 编译安装

1. 克隆仓库：
```bash
git clone git@github.com:madou1217/mac-menu-ip.git
cd mac-menu-ip
```

2. 编译应用：
```bash
make build
```

3. 运行应用：
```bash
make run
```

或者直接打开生成的应用：
```bash
open build/MenuIP.app
```

### 使用方法

1. 启动后，IP 地址会显示在菜单栏右侧
2. **左键点击** - 快速复制 IP 地址到剪贴板
3. **右键点击** - 显示菜单选项：
   - 复制当前 IP
   - 刷新 IP 地址
   - 退出应用

## 开发说明

本项目使用 Swift 和 Cocoa 框架开发，主要文件结构：

```
MenuIP/
├── Sources/
│   ├── AppMain.swift      # 应用入口
│   └── AppDelegate.swift  # 主要逻辑
├── Info.plist            # 应用配置
├── Makefile             # 构建脚本
└── build/               # 编译输出
```

### 构建命令

- `make build` - 编译应用
- `make run` - 编译并运行
- `make clean` - 清理构建文件

## 技术实现

- 使用系统网络接口 API 获取 IP 地址
- 支持 IPv4 和 IPv6 地址检测
- 优先选择活跃的以太网接口（en、bridge、utun）
- 使用 NSStatusItem 实现菜单栏显示
- 支持鼠标左右键不同操作

## 开发工具

本项目由 **CodeBuddy** AI 助手开发完成。

## 许可证

MIT License

## 贡献

欢迎提交 Issue 和 Pull Request！