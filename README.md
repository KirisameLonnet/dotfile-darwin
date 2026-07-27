# nixconfig

这台 Mac 的唯一事实来源（single source of truth）。基于 [nix-darwin](https://github.com/nix-darwin/nix-darwin) + [home-manager](https://github.com/nix-community/home-manager) 的声明式 macOS 配置：系统偏好、软件包、窗口管理（yabai + skhd）、终端与编辑器，全部由本仓库定义。

> 目标机器：`Lonnets-MacBook-Air` · `aarch64-darwin` · 用户 `lonnetkirisame` · [Determinate Nix](https://determinate.systems/)

本文档按使用频率编排：日常操作在最前，架构与决策记录居中，装机流程与速查表在后。

---

## 1. 日常操作

99% 的情况下你只需要这一条（在仓库根目录）：

```bash
sudo darwin-rebuild switch --flake .
```

更新依赖时，先审查锁文件、再验证、最后切换：

```bash
nix flake update            # 或只更新一个：nix flake update nixpkgs
git diff -- flake.lock
sudo darwin-rebuild check --flake .
sudo darwin-rebuild switch --flake .
```

其余命令（build / fmt / develop 等）见[附录 A](#附录-a命令速查)。

## 2. 改什么，去哪儿改

| 想改的东西 | 编辑这里 | 生效方式 |
| :--- | :--- | :--- |
| CLI 工具 / 软件包 | `modules/home-manager/packages/{ai,development,media,system,terminal}.nix` | rebuild |
| GUI 应用、cask 字体 | `modules/darwin/homebrew.nix` | rebuild |
| 快捷键 | `config/skhd/skhdrc` | **rebuild**（见下方说明） |
| 窗口规则 / 布局 / 动画 | `config/yabai/yabairc` | **rebuild**（见下方说明） |
| Shell 别名、环境变量 | `modules/home-manager/shell.nix` | rebuild |
| 临时环境变量（免 rebuild） | `~/.custom-env/*.env` | 新开 shell 即生效 |
| Neovim 插件 / LSP | `modules/home-manager/editor/nvim.nix` | rebuild |
| kitty 外观与行为 | `modules/home-manager/terminal.nix` | rebuild |
| git 身份、tmux、fzf | `modules/home-manager/development.nix` | rebuild |
| npm 全局 CLI | `development.nix` 顶部的 `npmGlobalPackages` | rebuild |
| macOS 系统偏好（Dock、键盘、手势…） | `modules/darwin/system.nix` | rebuild |
| Nix 管理的字体 | `modules/darwin/fonts.nix` | rebuild |
| 自定义打包 | `packages/`（现有示例：`wwan-manager.nix`） | rebuild |

> **为什么改 yabairc/skhdrc 也要 rebuild**：这两个文件在构建时被 `builtins.readFile` 嵌入 launchd 服务定义，并非运行时读取。`wm-reload` 只重启服务，不会加载未 rebuild 的改动。

## 3. 心智模型

### 3.1 一个 flake，两层管理

```
flake.nix
└── darwinConfigurations."Lonnets-MacBook-Air"
    ├── modules/darwin/           系统层（root 权限域）
    │   ├── system.nix              macOS defaults、键盘/触控板、launchd、Touch ID sudo
    │   ├── fonts.nix               Nerd Fonts 等（Nix 管理）
    │   ├── homebrew.nix            Homebrew 声明式管理（brews + casks）
    │   └── window-manager.nix      yabai + skhd 服务
    └── modules/home-manager/     用户层（$HOME 权限域，作为 nix-darwin 模块集成）
        ├── packages/               按类别拆分的软件包清单
        ├── shell.nix               zsh + starship
        ├── terminal.nix            kitty
        ├── development.nix         git、tmux、fzf、npm 全局包
        ├── editor/nvim.nix         Neovim（LazyVim）
        ├── ui.nix                  yabai/skhd 配置链接、wm-status / wm-reload 脚本
        ├── envdir.nix              direnv + nix-direnv
        └── fastfetch.nix           fastfetch
```

划分原则：需要 root / 作用于整机的进系统层，只影响 `$HOME` 的进用户层。

### 3.2 配置的三种形态

1. **Nix module options** —— 大多数配置（`programs.kitty`、`system.defaults`…），改动即声明。
2. **原生配置文件**（`config/` 目录）—— yabai、skhd、fastfetch 保留原生格式，构建时由 Nix 引入。窗口管理行为的**单一事实来源是 `yabairc` / `skhdrc`**，`window-manager.nix` 只负责装包和管理服务，两边不重复定义（避免配置冲突，且保留工具的完整功能面）。
3. **运行时逃生舱** —— 少数刻意留在声明式体系之外的东西：
   - `~/.custom-env/*.env`：zsh 启动时自动 source，放密钥和机器本地变量，改动免 rebuild；
   - `ASHPIPE_ENABLE_ZSH_HOOK=1`：按需启用 ashpipe 的 zsh hook（默认关闭，因为它在 `cd` 时探测远程门户，不可达时会阻塞）。

### 3.3 软件包的四个来源

| 来源 | 用于 | 例子 |
| :--- | :--- | :--- |
| **Nix**（默认） | 一切 CLI 与开发工具 | eza、ripgrep、rustc、go、claude-code、vscode |
| **Homebrew cask** | GUI .app（需要稳定路径给 macOS 权限系统）、Apple 字体、内核扩展 | vesktop、macfuse、font-sf-pro、flutter、libreoffice |
| **Homebrew brew** | macOS 专属或 Nix 中缺失的 CLI | switchaudio-osx、nowplaying-cli |
| **npm 全局**（activation 脚本） | 迭代太快、不值得等 nixpkgs 的 CLI | wrangler、@openai/codex |

PATH 顺序保证 **Nix 优先于 Homebrew**；新装包默认走 Nix，除非命中后三类的理由。

## 4. 设计决策记录

未来的自己：下面这些"看起来很怪"的地方都是故意的，改之前先读原因。

1. **`nix.enable = false`**（`system.nix`）—— Determinate Nix 自己管理 daemon 和 `/etc/nix/nix.conf`，这是 nix-darwin 官方的兼容方式。全局 Nix 设置去 `/etc/nix/nix.custom.conf` 改，不要试图让 nix-darwin 接管。
2. **自制 Rust 工具链**（`packages/development.nix` 的 `rustToolchain`）—— 把 rustc/cargo/rustfmt 组装成一个自带 sysroot 的目录，并将 std 源码嫁接进 `lib/rustlib/src/`，让 rust-analyzer 能跳转标准库定义。不要换成裸的 `rustc` + `cargo` 组合，会破坏 rust-analyzer。
3. **Neovim 禁用 Mason**（`editor/nvim.nix`）—— LSP / formatter 全部由 Nix 提供（nil、vtsls、pyright、ruff、rust-analyzer…），Mason 的 `ensure_installed` 清空。Mason 下载的二进制在 Nix 环境下不可靠，且会产生双头管理。
4. **kitty 关闭配置热重载**（`auto_reload_config = -1`）—— 配置监视器会顺着 home-manager 符号链接进入 `/nix/store/.links/`，打开 6 万+ 文件描述符。
5. **maxfiles 提到 524288**（两个 launchd daemon）—— 默认 122880 在 Nix 重度场景（kitty + zsh + store watcher）下会耗尽。
6. **zsh 里显式规整 PATH** —— 把 `~/.nix-profile/bin` 移出、把 `/etc/profiles/per-user/...` 提前，防止历史遗留的 standalone home-manager 链接抢占优先级。
7. **vesktop 用 cask 而不是 Nix** —— macOS 的权限（TCC）绑定应用路径，Nix store 路径每次更新都变，会反复丢权限。
8. **Homebrew 强制 `require_sha` + 关闭遥测**；`autoUpdate = true` 是刻意的——保持 brew 客户端与其线上 API 兼容。
9. **Stage Manager、mru-spaces 关闭** —— 与 yabai 的空间管理冲突。
10. **npm 全局包装进 `~/.local/share/npm`** —— 用户可写前缀，activation 脚本顺带修复 `@openai/codex` 平台包缺 `package.json` 和签名的问题。
11. **flake 里的两个 overlay** —— `unity-test` 跳过在 darwin 上失败的测试；`vscode` 修正 1.129+ 的 ripgrep 路径。上游修复后可移除。

## 5. 新机器引导

很少用到，但要用时必须完整：

1. 装 [Determinate Nix](https://determinate.systems/)，装 Xcode CLT（`xcode-select --install`）。
2. 克隆并首次激活：

   ```bash
   git clone https://github.com/KirisameLonnet/dotfile-darwin.git ~/.config/nixconfig
   cd ~/.config/nixconfig
   sudo nix run nix-darwin/master#darwin-rebuild -- switch --flake .
   ```

   首次 switch 会同时完成：Homebrew 应用与字体安装、npm 全局包安装、yabai/skhd 服务注册。之后日常使用第 1 节的命令即可。

3. **手动授权**（无法声明式完成）：
   - 系统设置 → 隐私与安全性 → **辅助功能**：授权 `yabai`、`skhd`；
   - **屏幕录制**：授权 `yabai`（窗口动画依赖此权限）。
4. 机器本地的密钥放进 `~/.custom-env/*.env`。
5. 如果新机器的 `LocalHostName` 不是 `Lonnets-MacBook-Air`，在 `flake.nix` 中新增/改名 `darwinConfigurations` 条目，或 rebuild 时显式指定 `--flake .#Lonnets-MacBook-Air`。

## 6. 故障排查

| 症状 | 原因与处理 |
| :--- | :--- |
| `filesystem error: in create_hard_link: File exists` | Determinate Nix 的 `auto-optimise-store` 所致。在其配置中关闭；临时绕过：`darwin-rebuild ... --option auto-optimise-store false` |
| 窗口动画不生效 | yabai 缺屏幕录制权限 |
| 快捷键 / 窗口管理无响应 | 先 `wm-status` 看服务状态，`wm-reload` 重启；仍不行则检查辅助功能授权。这两个脚本在 `~/.local/bin/`，由 `ui.nix` 管理 |
| 改了 skhdrc/yabairc 没生效 | 需要 rebuild，不是 `wm-reload`（原因见第 2 节） |
| `too many open files` | maxfiles daemon 未生效，重启后再查 `launchctl limit maxfiles` |
| `cd` 时终端卡住 | 误开了 ashpipe zsh hook 且门户不可达，去掉 `ASHPIPE_ENABLE_ZSH_HOOK` |

---

## 附录 A：命令速查

| 操作 | 命令 |
| :--- | :--- |
| 构建并应用 | `sudo darwin-rebuild switch --flake .` |
| 仅构建（不激活） | `darwin-rebuild build --flake .` |
| 检查配置与激活条件 | `sudo darwin-rebuild check --flake .` |
| 校验 flake 输出 | `nix flake check` |
| 格式化 Nix 文件 | `nix fmt` |
| 更新全部 / 单个输入 | `nix flake update` / `nix flake update nixpkgs` |
| 开发 shell（nil、nixfmt、nix-tree） | `nix develop` |
| 窗口管理服务状态 / 重启 | `wm-status` / `wm-reload` |

Flake 输入：`nixpkgs`（unstable）、`nix-darwin`、`home-manager`、[`ashpipe`](https://github.com/KirisameLonnet/ashpipe)。

## 附录 B：快捷键（yabai + skhd）

主修饰键 `Alt`，完整定义见 [`config/skhd/skhdrc`](config/skhd/skhdrc)。布局为 BSP、8px 间隙；应用规则（IDE → 空间 1、媒体/设计 → 3、通讯 → 4、系统工具浮动）见 [`config/yabai/yabairc`](config/yabai/yabairc)。

<details>
<summary>展开完整列表</summary>

**焦点与窗口**

| 快捷键 | 功能 |
| :--- | :--- |
| `Alt + H/J/K/L` | 焦点切换（左/下/上/右） |
| `Shift + Alt + H/J/K/L` | 移动（warp）窗口 |
| `Ctrl + Alt + H/J/K/L` | 调整窗口大小 |
| `Shift + Ctrl + Alt + H/J/K/L` | 设置插入方向 |
| `Ctrl + Alt + E` | 均衡窗口尺寸 |
| `Shift + Alt + Space` | 浮动 / 平铺切换 |
| `Alt + F` / `Shift + Alt + F` | 缩放全屏 / 原生全屏 |
| `Alt + E` | 切换分割方向 |
| `Alt + S` | sticky（所有空间可见） |
| `Alt + P` | 画中画 |
| `Alt + Q` | 关闭窗口 |
| `Shift + Alt + C` | 浮动窗口居中（4:4 网格中央 2×2） |

**布局**

| 快捷键 | 功能 |
| :--- | :--- |
| `Ctrl + Alt + A/S/D` | BSP / 堆叠 / 浮动 |
| `Alt + R` / `Shift + Alt + R` | 逆 / 顺时针旋转 |
| `Shift + Alt + X/Y` | 沿 X / Y 轴镜像 |
| `Alt + N` / `Alt + B` | 堆叠内下一个 / 上一个窗口 |

**工作区**

| 快捷键 | 功能 |
| :--- | :--- |
| `Alt + 1…0` | 切换到空间 1–10 |
| `Shift + Alt + 1…0` | 移动窗口到空间 1–10 |
| `Shift + Alt + D` | 新建空间并切换 |
| `Alt + Tab` | 切回最近空间 |

**应用**

| 快捷键 | 功能 |
| :--- | :--- |
| `Alt + Return` / `Shift + Alt + Return` | 打开 kitty / kitty（single-instance） |
| `Alt + W` | Finder「前往文件夹」 |
| `Shift + Ctrl + Alt + R` | 重启 yabai |

</details>

## 附录 C：Shell 别名与函数

<details>
<summary>展开</summary>

| 别名 | 实际命令 |
| :--- | :--- |
| `ls` / `ll` | `eza` / `eza -la` |
| `cat` / `grep` / `find` / `top` | `bat` / `rg` / `fd` / `btop` |
| `vim` / `v` | `nvim` |
| `ssh` / `icat` | `kitten ssh` / `kitten icat` |
| `..` `...` `....` | 逐级向上 `cd` |
| `g` `gs` `ga` `gaa` `gb` `gc` `gcm` `gco` `gd` `gl` `gp` `gpl` | git 系列 |
| `fm` | `nnn` |
| `gemini` / `gm` / `gemini-chat` | `npx @google/gemini-cli` |
| `reload` | `source ~/.zshrc` |
| `showfiles` / `hidefiles` | Finder 显示 / 隐藏隐藏文件 |

函数：`mkcd`（建目录并进入）、`extract`（通用解压）。zsh 为 vi 模式；git 自身另有 `st` `co` `br` `ci` `lg` `unstage` `undo` 等别名（`development.nix`）。

</details>

## 附录 D：环境清单

- **终端**：kitty（JetBrainsMono Nerd Font 14pt，Catppuccin Mocha，80% 不透明 + 背景模糊）、tmux（前缀 `Ctrl+A`）、zellij
- **Shell**：zsh（vi 模式、自动建议、语法高亮）+ Starship 双行提示符 + direnv/nix-direnv + fzf（fd 后端、bat/tree 预览）
- **编辑器**：Neovim = [LazyVim](https://www.lazyvim.org/) + extras（TypeScript / Python / Nix / JSON / Rust），Catppuccin 透明背景，leader 为 `Space`；另有 VS Code、vim
- **语言**：Rust（自制工具链 + rust-analyzer）、Go、Node.js 22、Python 3（+ uv）；嵌入式：arduino-cli、avrdude、picocom、clangd
- **AI CLI**：claude-code、github-copilot-cli、codex（npm）、gemini（npx 别名）
- **系统工具**：htop/btop、fastfetch、gnupg、mas、m-cli、nix-tree、nix-output-monitor、WWAN Manager（自定义打包，QDC507 拨号 GUI）
- **macOS 定制**：深色模式、Dock 自动隐藏、快速按键重复、禁用自动大写/智能引号、截图存 `~/Pictures/Screenshots`、Touch ID sudo、四指手势（三指保留给文本选择）
