# Andy Yu's MacOS Development Kit for UI

面向 macOS 软件的 Electron 界面组件与应用框架。采用 Portfolio 的红黄蓝视觉体系、像素标识、SVG CRT 曲面、颗粒背景、交互音效和面板构造动效。

[English](README.md) · [构建与实现说明](desktop/README.md)

## 本地运行

```sh
cd desktop
npm ci
npm run build
npm run desktop:dev
```

运行 `npm run desktop:build` 构建 Apple Silicon macOS 应用。产物位于 `desktop/release/mac-arm64/AYM DevKit.app`，用于本地测试，未进行发布签名和公证。字体与资产全部随应用打包，可离线运行。

## 已实现

- 源项目的 2.5 秒构造入场、面板收起与展开、连续切页排队处理。
- 单窗口应用内设置，支持 Escape 关闭、Command-comma 打开。
- 中英文切换时执行 ASCII 遍历，并预留两种语言所需的布局尺寸。
- 跟随系统、浅色、深色外观；默认跟随系统，切换带颜色渐变。
- 经典蓝、高对比、灰阶处理，以及动效、音效、CRT 和柔化选项。
- 可交互控件的预选中和点击音、切页音，以及 56 px 滚动吸附、刻度与卡点音。
- 通用工具蓝色 `#164BFF`，娱乐软件黄色 `#FFE500`，其他软件红色 `#F22A30`；16 × 16 标识在红蓝底上为白色，在黄底上为黑色。

## 验证

在 `desktop` 中运行 `npm test`；安装 Chromium 测试浏览器后，启动 `npm run dev`，再在另一终端运行 `npm run test:browser`。

自动化覆盖曲面坐标、设置数据、鼠标命中、音频播放启动、入场与连续切页、滚动反馈、语言切换尺寸以及外观切换。发布前仍应在目标 Mac 上检查视觉与听感。目前提供可运行的组件展示与迁移基础，尚未发布独立的 Web 组件包。

## 目录

- `desktop/`：当前使用的 Electron 应用、前端与测试。
- `Sources/`、`Tests/`、`Package.swift`：保留的 SwiftUI 实现与测试，不是当前桌面程序的运行时。
- `docs/`：历史 SwiftUI 文档和截图，不代表当前 Electron 视觉。

动效、程序化背景和界面音效来自作者的 Portfolio 项目；未包含其作品目录媒体。具体移植关系见 `desktop/README.md`。
