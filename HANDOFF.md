# AYMDevKitUI 交接文档

> 交接对象：下一位接手这个仓库的工程师 / AI  
> 生成时间：2026-10-29  
> 仓库：<https://github.com/Dirty-Octopus/AYMDevKitUI>  
> 分支：`main`；版本标签：`v1.0.0`（以 `git log -1` / `git tag` 为准）

## 1. 当前状态

AYMDevKitUI（简称 AYMDKUI）已经是一个可构建、可测试、可运行、已推送的 macOS SwiftUI 设计系统与框架库。

- `swift build` 通过。
- `swift test` 16 个测试全部通过。
- `swift run AYMDevKitUIDemo` 可运行；欢迎页、深浅色切换、动态 ASCII 背景已实际运行验证。
- README、设计规范、交互规范、面板规范、组件目录均已完成，并附有截图。
- 远端 `main` 与 `v1.0.0` 已推送。

## 2. 环境与命令

要求：macOS 14+、Swift 5.9+、完整 Xcode（SwiftUI 宏需要完整工具链）。

```bash
# 如果 swift 指向 Command Line Tools，先执行：
export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer

swift build
swift test
swift run AYMDevKitUIDemo
swift run AYMDevKitUIDemo --snapshot docs   # 重新生成 README 截图
```

> 用 Command Line Tools 直接构建会出现 `SwiftUIMacros` 插件找不到的错误。这不是代码问题，是工具链问题。

## 3. 架构地图

```
Sources/
  AYMDevKitUI/
    Core/
      DKBrand.swift              六色品牌
      DKColor.swift              颜色数学 / 对比度 / hex
      DKTheme.swift              由品牌和外观推导所有 token
      DKTapography.swift         字号
      DKMetrics.swift            间距 / 圆角 / 控件尺寸 / 动效
      DKWindow.swift             窗口 chrome、预设、原地缩放、辅助窗口
      DKLocalization.swift       en / zh-Hans 语言与文案
      DKAppInfo.swift            应用身份 + 框架信息
      DKAppSettings.swift        持久化设置 / 欢迎版本
      DKAppearanceTransition.swift  整个主题 frame 的深浅色交叉淡化
    Components/
      DKSurface.swift            Card / Inset / Hairline / ASCIIRule / 背景 / 步骤头 / 窗口预览
      DKASCIIField.swift         密集动态 ASCII 字符场 + Perlin + ripple/trail
      DKButton.swift             六种按钮 + 图标按钮
      DKBadge.swift              Badge / 状态点 / 脉冲点
      DKInput.swift              输入框 / 搜索 / Toggle / 选项卡 / 分段控件 / 菜单选择
      DKFeedback.swift           Notice / 进度 / 空状态 / Spinner
      DKDataDisplay.swift        InfoRow / StatTile / Avatar
      DKNavigation.swift         Sidebar
      DKDropZone.swift           文件拖放
      DKMark.swift               应用标记 / Orb
    Panels/
      DKWelcomePanel.swift       统一欢迎面板
      DKSettingsPanel.swift      统一设置面板 + 宿主扩展分区
    Shell/
      DKShell.swift              AppRoot / AppShell / TopBar / 窗口 accessor / 拖拽区
      DKCommands.swift           Settings / View / About 菜单
    Resources/
      en.lproj / zh-Hans.lproj
  AYMDKUI/                       重新导出 AYMDevKitUI 的短别名
  AYMDevKitUIDemo/               组件画廊 / 欢迎与设置预览 / 离屏截图
Tests/AYMDevKitUITests/
docs/                            规范文档与 README 截图
```

## 4. 不能破坏的契约

这些是这一轮反复修正后确定的规则，后续改动请先读这里。

### 4.1 外观与颜色

- 默认外观必须是 `.system`（跟随系统）。
- 颜色只能来自 `DKBrand` / `DKTheme`，组件里不要写死 hex。
- **不要在 `DKAppRoot` / `DKSettingsPanel` 上再加 `.preferredColorScheme(...)`。** 它会绕过库的交叉淡化，导致只有“跟随系统”才有过渡动画。
- 外观切换由 `NSApp.appearance` 驱动，`DKAppearanceTransition` 负责快照整个 theme frame 并淡出旧帧。
- 左右方向（light → dark、dark → light）必须走同一条路径。
- 标题栏与内容必须一起淡入淡出；不要只 snapshot `contentView`。

### 4.2 标题栏

- 使用原生交通灯，但不要系统灰色标题栏。
- 当前实现：`fullSizeContentView` + `titlebarAppearsTransparent = true` + `titleVisibility = .hidden` + `titlebarSeparatorStyle = .none`。
- 主窗口 `topBarLeadingInset = 92`，给交通灯留位置；截图模式可传 20。
- Settings 等辅助窗口通过 `DKWindowManager.styleAuxiliary(_:)` 使用同一套 chrome。
- 不要加回“可见标题文字”；产品决定是只保留红绿灯。

### 4.3 窗口缩放

- `DKWindowManager.apply` 必须保持当前左上角原地缩放。
- 永远不要在应用预设后调用 `center()`；这是之前“关闭设置页后窗口跳位”的根因。
- 数学逻辑在 `DKWindowManager.anchoredFrame`，有单元测试。

### 4.4 ASCII 字符场

- 网格 10 × 10pt，字号 8.5pt，基线按扫描行整行绘制以控制成本。
- **字符本身必须动态**：每个单元格按错开的 1.35s 时钟重新生成字符。
- **字符场自身的颜色不能自主变化**：基线、波峰都只用主色。强调色只能由点击/悬停交互引入。
- 点击涟漪：扩散环，独立字符集（`~ = + * #`）和强调色，持续 2.4s。
- 悬停尾迹：写入同一套字符网格的 wake，独立字符集（`0 1 2 < > /`）和强调色。
- **Tail 的字符尺寸必须恒定**。衰减的是每个 trail point 的**影响半径**（2.8 格 → 0.8 格），不是字体大小。不要把 size tiers 加回来。
- 空闲 6fps，交互 12fps；窗口失焦或 Reduce Motion 时暂停。
- 背景性能可通过 `DKAppRoot(backgroundFieldIntensity:)` 调低或关闭。

### 4.5 面板顺序

欢迎和设置的核心顺序永远是：

1. Language
2. Appearance
3. Window size
4. 宿主追加 sections
5. About

宿主只能追加 `DKSettingsSection`，不能重排核心。

### 4.6 本地化

所有新增文案必须同时补 `Resources/en.lproj/Localizable.strings` 与 `zh-Hans.lproj/Localizable.strings`。测试会检查 key 覆盖。

## 5. 本轮最后修复记录

- 欢迎页两个圆形模糊改为 **RadialGradient**，不再使用 `.blur`；切换外观时不会消失。位置与透明度在 `DKWelcomePanel.brandColumn`。
- ASCII 场基线/波峰只使用主色；强调色只由 ripple/trail 进入。
- Trail 从“字体尺寸三档”改为“**影响半径随年龄衰减**”，字符尺寸恒定。
- 外观过渡移除 `.preferredColorScheme`，改为 `NSApp.appearance` + theme frame 整体 snapshot；预生成两套外观的字形图集，并留 0.08s 让 SwiftUI 提交新外观。
- 标题栏改为无缝透明、隐藏标题、保留交通灯。
- Settings 窗口补齐 `styleAuxiliary` 与顶部 34pt 安全间距。

## 6. 已知风险 / 尚未充分验证

请务必先读这一节，不要假设一切都被验证过。

1. **深浅色反向过渡的视觉验收仍建议人工再做一次。**  
   代码路径已统一，日志确认 `apply` 与 overlay 都执行；自动化点击受窗口激活/坐标影响，未能稳定截到中段帧。请人工在 light → dark 和 dark → light 各录一次，尤其看标题栏/交通灯是否同步。

2. **Settings 独立窗口的 chrome 未在真实场景完整验证。**  
   `styleAuxiliary` 与 34pt 顶部 padding 是按主窗口经验推的；请实际按 `⌘,` 打开设置，检查交通灯是否压住 `[ PREFERENCES ]` 标题。

3. **ASCII 场 CPU 仍偏高。**  
   Debug 构建、窗口激活、密集字符下大约 10% 左右（因机器/帧率而异）。已经做了行级基线、glyph atlas、自适应 fps；若要进一步优化，可把基线缓存成 2x NSImage，或把 idle 降到 4fps。

4. **ImageRenderer 截图有天然限制。**  
   它不能渲染 `TextField`、`Menu`、`Link`、`onDrop`、`NSViewRepresentable`，也不能渲染 ScrollView 内容。因此：
   - 组件的截图用 `snapshot: true` + 静态 mock 输入。
   - 面板截图用 `scrolls: false`。
   - 预览图不包含原生交通灯；`docs/chrome-*.jpg` 是真实窗口截图。

5. **`DKAppearanceTransition` 依赖 `contentView.superview`（theme frame）。**  
   这是 AppKit 的窗口 frame view；在当前 macOS 版本工作正常，但不是公开 API 契约。若未来系统改版出现异常，回退到 `contentView` + 标题栏单独处理。

6. **`docs/chrome-light.jpg` / `docs/chrome-dark.jpg` 是运行截图**，包含当时的语言/appearance 状态；如果 UI 改动，需要重拍。

7. **没有 CI、没有 Release workflow、没有 Xcode 工程。**  
   目前只有 SwiftPM。发布 tag 已存在，但没有 GitHub Release。

8. **测试覆盖偏底层。**  
   只有 tokens、settings、localization、Perlin、窗口几何；没有 View snapshot / UI test / 过渡自动化测试。

## 7. 建议的下一步

按优先级：

1. 人工验收两种方向的 appearance 过渡，必要时录屏；如果仍不丝滑，检查 overlay 是否覆盖 titlebar、以及新 UI 是否在 0.08s 内完成布局。
2. 实际打开 Settings，检查辅助窗口的交通灯、顶部 padding、滚动。
3. 用 Instruments / `sample` 看 ASCII 场的热点；如果基线 `Text` 行仍是大头，缓存成 NSImage。
4. 给 `DKWelcomePanel` / `DKSettingsPanel` 加 ViewInspector 或 snapshot 测试。
5. 添加 GitHub Actions：`swift build`、`swift test`。
6. 如果发布，补 GitHub Release 说明并把 README 的 `from:` 指向正式 tag。

## 8. 常用排查

- **`SwiftUIMacros` not found**：用完整 Xcode，`DEVELOPER_DIR=...`。
- **截图里 ScrollView 空白**：ImageRenderer 限制；用 `scrolls: false`。
- **截图里黄色禁用图标**：原生控件/NSViewRepresentable；用静态 mock，或不要截图该控件。
- **窗口跳位**：检查是否又调用了 `center()` 或把 `apply` 改成 `setContentSize`。
- **只有 System 有过渡**：检查是否又加了 `.preferredColorScheme`。
- **欢迎页圆形消失**：检查是否又把 RadialGradient 改回 `.blur`。
- **Trail 字体变大**：检查是否又加了 size tier；只允许 radius decay。

## 9. 远程与版本

```bash
git remote -v
# origin https://github.com/Dirty-Octopus/AYMDevKitUI.git

git log --oneline -5
git tag
```

发布前如果要改版本：同步更新 `DKFrameworkInfo.version`、README、tag。

---

交接文档到这里。下一份 `FINAL_NOTES.md` 是更偏设计意图和个人判断的“遗言”，建议一起读。
