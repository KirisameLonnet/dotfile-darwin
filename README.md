# Nix-darwin

本仓库包含一套完整的、模块化的 macOS 配置，基于 [Nix](https://nixos.org/)、[nix-darwin](https://github.com/LnL7/nix-darwin) 和 [home-manager](https://github.com/nix-community/home-manager) 构建。它旨在提供一个一致、可复现且高度自动化的开发环境，核心是围绕 [yabai](https://github.com/koekeishiya/yabai) 和 [skhd](https://github.com/koekeishiya/skhd) 打造的平铺式窗口管理器体验。

## ✨ 核心特性

- **声明式配置**: 通过 Nix 同时管理系统级 (`nix-darwin`) 和用户级 (`home-manager`) 的配置。
- **可复现环境**: 一键在新设备上复现你熟悉的开发环境。
- **平铺式窗口管理器**: 预设 `yabai` 和 `skhd`，提供高效、键盘驱动的工作流。
- **模块化与自动化**: 配置结构清晰，并通过 `Makefile` 简化了所有常用操作。

## 🚀 快速上手

1.  **环境准备**:
    *   安装 [Nix 包管理器](https://nixos.org/download.html) 并启用 Flakes。
    *   安装 Xcode 命令行工具: `xcode-select --install`

2.  **克隆仓库**:
    ```bash
    # 推荐将配置克隆到 ~/.config/nixconfig
    git clone https://github.com/your-username/nixconfig.git ~/.config/nixconfig
    cd ~/.config/nixconfig
    ```

3.  **应用配置**:
    ```bash
    # 构建配置并切换到新系统
    make switch
    ```
    此命令将构建 `flake.nix` 中定义的完整系统配置，并激活它。

4.  **授权辅助功能**:
    首次安装后，窗口管理器需要权限才能工作。
    ```bash
    make permissions
    ```
    此命令会打开系统设置面板，请手动为 `yabai` 授权。

## ⚙️ Makefile 使用指南

`Makefile` 是管理本配置的主要入口，封装了所有常用命令。

<details>
<summary>点击展开/折叠 Makefile 命令列表</summary>

| 命令 | 描述 |        
| :--- | :--- |
| **核心命令** | |
| `make switch` | **(最常用)** 构建并应用新配置。对配置的任何更改都通过此命令生效。 |
| `make build` | 仅构建配置，不激活。用于在应用前检查配置是否存在错误。 |
| `make update` | 更新所有 Nix Flake 依赖 (如 nixpkgs) 到最新版本，并应用新配置。 |
| **诊断与维护** | |
| `make status` | 显示详细的系统状态，包括服务运行状态和配置文件检查。 |
| `make logs` | 显示 `yabai` 和 `skhd` 的最新日志，用于排查问题。 |
| `make test` | 运行一系列测试，检查 `yabai` 权限、`skhd` 语法等。 |
| `make clean` | 清理旧的 Nix Store generations 和构建产物，释放磁盘空间。 |
| `make format` | 格式化项目中的所有 `.nix` 文件。 |
| `make help` | 显示所有可用的 `make` 命令及其描述。 |
 
</details>

## 🛠️ 已安装工具与别名

本配置通过 Nix 和 Homebrew 安装了大量工具，并通过 Zsh 提供了方便的别名。

<details>
<summary>点击展开/折叠工具与别名列表</summary>

### 主要工具

| 类别 | 工具 | 描述 |
| :--- | :--- | :--- |
| **终端与 Shell** | `wezterm`, `zsh`, `starship` | 终端、Shell 及提示符 |
| | `tmux`, `zellij` | 终端复用器 |
| | `eza`, `bat`, `ripgrep`, `fd` | `ls`, `cat`, `grep`, `find` 的现代替代品 |
| **开发工具** | `neovim` | 高度可扩展的文本编辑器 |
| | `git`, `gh`, `lazygit`, `delta` | 版本控制与辅助工具 |
| | `nodejs`, `python3`, `rustc`, `go` | 多语言开发环境 |
| **系统与监控** | `htop`, `btop` | 进程与系统监控 |
| | `fastfetch` | 系统信息展示工具 |

### 常用别名

| 别名 | 原始命令 | 描述 |
| :--- | :--- | :--- |
| `ll`, `ls` | `eza -la`, `eza` | 现代化的 `ls` |
| `cat` | `bat` | 语法高亮的 `cat` |
| `vim`, `v` | `nvim` | 使用 Neovim |
| `..` | `cd ..` | 快速切换上级目录 |
| `g`, `gs`, `ga` | `git`, `git status`, `git add` | Git 常用命令 |
| `nixup` | `darwin-rebuild switch --flake ...` | 更新并应用 Nix 配置 |
| `reload` | `source ~/.zshrc` | 重新加载 Zsh 配置 |

</details>

## ⌨️ Yabai + Skhd 快捷键

所有快捷键配置在 `config/skhd/skhdrc` 文件中。主要修饰键为 `Alt`。

<details>
<summary>点击展开/折叠快捷键列表</summary>

### 窗口管理
- `Alt + H/J/K/L`: 焦点切换 (左/下/上/右)
- `Shift + Alt + H/J/K/L`: 移动窗口
- `Ctrl + Alt + H/J/K/L`: 调整窗口大小
- `Shift + Alt + Space`: 切换窗口浮动/平铺模式
- `Alt + F`: 切换窗口缩放全屏
- `Alt + Q`: 关闭当前窗口

### 工作区 (Space) 管理
- `Alt + 1...0`: 切换到指定工作区
- `Shift + Alt + 1...0`: 移动当前窗口到指定工作区
- `Shift + Alt + D`: 创建一个新的工作区并切换

### 布局管理
- `Ctrl + Alt + A/D/S`: 切换为 BSP/浮动/堆叠布局
- `Alt + E`: 切换窗口分割方向 (水平/垂直)

### 应用与系统
- `Alt + Return`: 打开 WezTerm 终端
- `Shift + Ctrl + Alt + R`: 重启 Yabai 服务

</details>

## 📝 Neovim 配置

集成了功能齐全的 Neovim 环境，配置于 `modules/home-manager/editor/nvim.nix`。

### 插件使用指南

**Leader 键**: `Space` (空格键)

| 快捷键 | 功能 | 插件 |
| :--- | :--- | :--- |
| `<Space> + e` | 打开或关闭文件浏览器 | `neo-tree.nvim` |
| `<Space> + ff` | **F**ind **F**iles - 模糊搜索项目中的文件 | `telescope.nvim` |
| `<Space> + fg` | **F**ind **G**rep - 在项目中进行文本搜索 | `telescope.nvim` |
| `gd` | **G**o to **D**efinition - 跳转到定义 | `nvim-lspconfig` |
| `K` | (普通模式下) 显示光标下符号的文档 | `lspsaga.nvim` |
| `<Space> + ca` | **C**ode **A**ction - 显示可用的代码操作 | `lspsaga.nvim` |
| `<Space> + gb` | **G**it **B**lame - 显示当前行的 Git Blame 信息 | `gitsigns.nvim` |
| `<Tab>` | (插入模式下) 接受 GitHub Copilot 的建议 | `copilot.lua` |
| `<Space> + h` | 显示 Neovim 快捷键帮助菜单 | (自定义) |

## 🔧 自定义与维护

- **添加软件包**: 编辑 `modules/home-manager/packages/` 或 `modules/darwin/homebrew.nix`，然后运行 `make switch`。
- **修改快捷键**: 编辑 `config/skhd/skhdrc`，然后运行 `make restart-skhd` 或 `make switch`。
- **修改 Neovim**: 编辑 `modules/home-manager/editor/nvim.nix`，然后运行 `make switch`.


