# Compositor 1.4.9 简体中文版

基于 [robbietilton/Compositor v1.4.9](https://github.com/robbietilton/Compositor/releases/tag/v1.4.9)，应用版本 **1.4.9**、构建号 **44** 与上游一致。本发行版由 emptykid/Compositor 独立维护，并非上游官方发行版。

## 本次更新

- 首次发布简体中文汉化版本，包含 1223 条中英文词条。
- 汉化菜单、工具提示、图层与混合模式、滤镜与 Camera Raw、导入导出、快捷键和主要弹窗。
- 支持中文命令搜索；保留项目文件格式、存储值及快捷键设置兼容性。
- 新增中文 README 和本地化维护文档。
- 中文版使用独立的更新源和更新签名，后续更新来自本仓库。

编辑功能保持与上游 1.4.9 一致。上游本版包括 Camera Raw 改进与预览加速、图层效果和文字在尺寸调整时的保留，以及 WebP 导入等更新；完整说明见上游 Release。

## 安装与语言

需要 Apple 芯片 Mac 和 macOS 26.0 或更高版本。下载 `Compositor.dmg`，打开后将 `Compositor.app` 拖入“应用程序”。

应用跟随 macOS 语言偏好。可在“系统设置 → 通用 → 语言与地区 → 应用程序”中为 Compositor 选择“简体中文”，然后重启应用。

## 签名与公证状态

本次应用及 DMG 均已完成 **Developer ID 签名和 Apple 公证**，Apple 审核结果均为 `Accepted`，且已附加并验证公证票据。应用通过 macOS 分发检查（`syspolicy_check distribution`）。

公证安装包在首次发布后补发，`Compositor.dmg` 与 `SHA256SUMS` 已同步更新。应用代码、版本 **1.4.9** 和构建号 **44** 保持不变；已下载早期未公证安装包的用户可重新下载当前文件。

## 验证

- 572 项全量测试通过（含参数化测试共 645 次执行）。
- 中文环境的本地化、面板和文件监听专项测试通过。
- 中英文词条完整性、格式参数及编译提取覆盖检查通过。
