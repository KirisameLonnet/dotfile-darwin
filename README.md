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
| CLI 工具 / 软件包 | `modules/home-manager/packages/{ai,development,media,network,system,terminal}.nix` | rebuild |
| GUI 应用、cask 字体、App Store 应用 | `modules/darwin/homebrew.nix`（`casks` / `masApps`） | rebuild |
| 默认打开方式（媒体文件→VLC） | `modules/home-manager/default-apps.nix` | rebuild |
| 网络工具、VPN（ZeroTier 等） | `modules/darwin/network.nix` + `modules/home-manager/packages/network.nix` | rebuild |
| 快捷键 | `config/skhd/skhdrc` | **rebuild**（见下方说明） |
| 窗口规则 / 布局 / 动画 | `config/yabai/yabairc` | **rebuild**（见下方说明） |
| Shell 别名、环境变量 | `modules/home-manager/shell.nix` | rebuild |
| 临时环境变量（免 rebuild） | `~/.custom-env/*.env` | 新开 shell 即生效 |
| Neovim 插件 / LSP | `modules/home-manager/editor/nvim.nix` | rebuild |
| kitty 外观与行为 | `modules/home-manager/terminal.nix` | rebuild |
| git 身份、tmux、fzf | `modules/home-manager/development.nix` | rebuild |
| npm 全局 CLI | `development.nix` 顶部的 `npmGlobalPackages` | rebuild |
| Docker VM 规格（CPU/内存/磁盘） | `colima start --edit` | **不用 rebuild**（见 §4.13） |
| Docker 相关 CLI / 自启 agent | `packages/development.nix` 的 CONTAINERS 段 / `home-manager/development.nix` | rebuild |
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
    │   ├── network.nix             网络栈：ZeroTier 等 VPN / 网络类 brew 与 cask
    │   └── window-manager.nix      yabai + skhd 服务
    └── modules/home-manager/     用户层（$HOME 权限域，作为 nix-darwin 模块集成）
        ├── packages/               按类别拆分的软件包清单
        ├── shell.nix               zsh + starship
        ├── terminal.nix            kitty
        ├── development.nix         git、tmux、fzf、npm 全局包
        ├── editor/nvim.nix         Neovim（LazyVim）
        ├── ui.nix                  yabai/skhd 配置链接、wm-status / wm-reload 脚本
        ├── envdir.nix              direnv + nix-direnv
        ├── default-apps.nix        duti 绑定默认打开方式（媒体 → VLC）
        └── fastfetch.nix           fastfetch
```

划分原则：需要 root / 作用于整机的进系统层，只影响 `$HOME` 的进用户层。

### 3.2 配置的三种形态

1. **Nix module options** —— 大多数配置（`programs.kitty`、`system.defaults`…），改动即声明。
2. **原生配置文件**（`config/` 目录）—— yabai、skhd、fastfetch 保留原生格式，构建时由 Nix 引入。窗口管理行为的**单一事实来源是 `yabairc` / `skhdrc`**，`window-manager.nix` 只负责装包和管理服务，两边不重复定义（避免配置冲突，且保留工具的完整功能面）。
3. **运行时逃生舱** —— 少数刻意留在声明式体系之外的东西：
   - `~/.custom-env/*.env`：zsh 启动时自动 source，放密钥和机器本地变量，改动免 rebuild；
   - `ASHPIPE_ENABLE_ZSH_HOOK=1`：按需启用 ashpipe 的 zsh hook（默认关闭，因为它在 `cd` 时探测远程门户，不可达时会阻塞）。
   - **colima 的 `~/.colima/default/colima.yaml`**：VM 规格（CPU/内存/磁盘）的事实来源，`colima start --edit` 改，免 rebuild，见 §4.13。

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
11. **`flake.nix` 里没有 overlay，以后也不要加在那儿** —— 曾经有三个 `overrideAttrs`（`unity-test` 关测试、`vscode` 补 ripgrep 路径、`claude-code` 抢跑版本），到 2026-09-11 全部核对为**死代码**：上游早就修好了，三个 override 生成的 derivation 与 stock nixpkgs 逐字节相同，已删除。教训有两条，重要性高于这三个包本身：
    - **overlay 会静默腐烂**。`builtins.replaceStrings` 找不到目标时不报错、只是原样返回；`overrideAttrs` 覆盖一个上游已经修好的属性同样悄无声息。`claude-code` 那条更糟——它把版本钉死在 `2.1.220`，nixpkgs 一旦走到 2.2.x，这个"为了抢新版"写的 override 就反过来变成降级锁，而且不会有任何提示。**每次 `nix flake update` 之后要主动验证 overlay 是否还有必要**，方法是比对 drvPath：

      ```bash
      nix eval --raw .#darwinConfigurations.Lonnets-MacBook-Air.pkgs.<pkg>.drvPath
      # 与不带 overlay 的 stock nixpkgs 对比，相同即说明这条 override 已经是死代码
      ```

    - **真要加 overlay，加在模块层**（`modules/darwin/` 里的 `nixpkgs.overlays`），不要塞回 `flake.nix`。`nixpkgs.overlays` 本来就是模块选项；`flake.nix` 的职责只有"声明 inputs + 接线"，一旦开始在里面写包的构建细节，层级就塌了——这也是 `packages/`（自定义打包）和 `modules/`（配置）分开的同一条理由。
12. **`nixpkgs.pkgs` 而不是 `nixpkgs.config` + `nixpkgs.overlays`**（`flake.nix`）—— 后者会让 nix-darwin 自己再 `import nixpkgs` 一次，加上 `let` 里给 formatter/devShell 用的那份，整个 nixpkgs 被求值两遍。改成把已经实例化好的 `pkgs` 传进去，全仓库只剩一份，home-manager 再靠 `useGlobalPkgs` 复用。注意：设了 `nixpkgs.pkgs` 之后 `nixpkgs.config` 会被忽略，`allowUnfree` 要写在 `import nixpkgs` 那里。
13. **Docker：Nix 只管"服务跑不跑"，colima 自己管"VM 长什么样"**（`home-manager/development.nix`）—— 刻意的半托管。
    - **没有 Docker Desktop**。daemon 跑在 `colima` 拉起的 Linux 虚拟机里，Nix 装的是 `colima` + `docker-client`（纯客户端）+ compose/buildx；
    - **`darwin-rebuild switch` 之后不需要再手动跑任何东西**：`launchd.agents.colima` 在 activation 时被 bootstrap，登录时也会自启；
    - **agent 刻意不带任何规格参数**。不给 flag 时 `colima start` 读 `~/.colima/default/colima.yaml`，那才是 CPU / 内存 / 磁盘 / vm-type 的事实来源，用 `colima start --edit` 改，改完不用 rebuild。**一旦在 nix 里写死 `--cpus 4`，VM 规格就被声明式接管了**，那正是不想要的；
    - `~/.colima`、`~/.docker/config.json`、contexts、镜像、卷、容器，rebuild 一概不碰；
    - **`--foreground` + `KeepAlive.SuccessfulExit = false`**：前者让 launchd 真正监管进程（默认的 `colima start` 自己 daemonize，launchd 会误判成启动失败）；后者让崩溃能自动拉起，而手动 `colima stop`（正常退出）不会被立刻拽回来——想省内存仍然停得掉；
    - activation 里那句 `launchctl kickstart`（**不带 `-k`**）补的是一个具体缺口：plist 没变且 agent 仍是 loaded 时，home-manager 不会重新 bootstrap，于是"手动停过 → 再 rebuild"不会把 VM 带回来。kickstart 没跑就起、在跑就什么都不做；加了 `-k` 则会每次 rebuild 杀掉健康的 VM 重来；
    - `~/.docker/cli-plugins/` 里两个符号链接（compose、buildx）是唯一被 Nix 管的 docker 配置——docker CLI 只认这个目录和几个 `/usr/...` 路径，不链进去 `docker compose` 子命令就不存在。**只链这两个文件，不接管整个 `~/.docker`**，因为凭证和 context 状态也在那儿，必须保持可写；
    - `colima start` 会自动创建并切换到名为 `colima` 的 docker context，所以不需要设 `DOCKER_HOST`。

    首次 switch 之后 VM 要下载并初始化 Linux 镜像，耗时几分钟且全在后台，进度只能从日志看：

    ```bash
    tail -f ~/Library/Logs/colima.log     # 首次初始化进度
    colima status                          # VM 状态
    launchctl print gui/$(id -u)/org.nix-community.home.colima   # agent 状态
    ```

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
| `docker: Cannot connect to the Docker daemon` | colima VM 没起。先 `colima status`，再看 `~/Library/Logs/colima.error.log`；agent 本身的状态用 `launchctl print gui/$(id -u)/org.nix-community.home.colima`。首次 switch 后 VM 要几分钟才初始化好，见 §4.13 |
| `docker: 'compose' is not a docker command` | `~/.docker/cli-plugins/` 里的链接丢了（手工删过 `~/.docker`？），rebuild 一次即可重建 |

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
- **容器**：colima（Linux VM，launchd agent 自启）+ docker CLI / compose / buildx / lazydocker；无 Docker Desktop，VM 规格与运行时状态不受 Nix 管理（§4.13）
- **系统工具**：htop/btop、fastfetch、gnupg、mas、m-cli、nix-tree、nix-output-monitor、WWAN Manager（自定义打包，QDC507 拨号 GUI）
- **macOS 定制**：深色模式、Dock 自动隐藏、快速按键重复、禁用自动大写/智能引号、截图存 `~/Pictures/Screenshots`、Touch ID sudo、四指手势（三指保留给文本选择）
