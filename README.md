# macOS Nix Darwin Configuration

基于 Nix Darwin + Home Manager 的 macOS 系统配置，包含窗口管理器 yabai + skhd。

## 快速开始

```bash
# 构建并安装
make install

# 或分步执行
make build
make switch
```

## 快捷键

### 窗口导航
- `Alt + H/J/K/L` - 窗口焦点移动（左/下/上/右）
- `Shift + Alt + H/J/K/L` - 移动窗口位置
- `Ctrl + Alt + H/J/K/L` - 调整窗口大小

### 工作空间
- `Alt + 1/2/3...0` - 切换工作空间
- `Shift + Alt + 1/2/3...0` - 移动窗口到工作空间
- `Shift + Alt + D` - 创建新工作空间

### 窗口布局
- `Alt + E` - 切换分割方向
- `Alt + R` - 旋转窗口布局 270°
- `Shift + Alt + R` - 旋转窗口布局 90°
- `Shift + Alt + X/Y` - X/Y 轴镜像
- `Ctrl + Alt + E` - 平衡窗口大小

### 窗口模式
- `Shift + Alt + Space` - 浮动/平铺切换
- `Alt + F` - 全屏（zoom）
- `Shift + Alt + F` - 原生全屏
- `Alt + S` - 置顶（sticky）
- `Alt + O` - 保持在最前
- `Alt + P` - 画中画模式

### 布局切换
- `Ctrl + Alt + A` - BSP 布局
- `Ctrl + Alt + D` - 浮动布局
- `Ctrl + Alt + S` - 堆叠布局

### 应用启动
- `Alt + Return` - 打开 Alacritty 终端
- `Shift + Alt + Return` - 新建 Alacritty 实例
- `Alt + W` - Finder "前往文件夹"

### 系统操作
- `Alt + Q` - 关闭窗口
- `Shift + Ctrl + Alt + R` - 重启 Yabai

## 目录结构

```
nixconfig/
├── flake.nix              # 主配置入口
├── home.nix               # Home Manager 配置
├── Makefile               # 构建和管理脚本
├── config/                # 应用配置文件
│   ├── skhd/skhdrc       # 快捷键配置
│   ├── yabai/yabairc     # 窗口管理器配置
│   ├── sketchybar/       # 状态栏配置（已禁用）
│   └── borders/bordersrc # 窗口边框配置
└── modules/               # Nix 模块
    ├── darwin/           # macOS 系统配置
    │   ├── default.nix
    │   ├── fonts.nix     # 字体配置
    │   ├── homebrew.nix  # Homebrew 包管理
    │   ├── system.nix    # 系统设置
    │   └── window-manager.nix # 窗口管理器服务
    ├── home-manager/     # 用户环境配置
    │   ├── default.nix
    │   ├── development.nix # 开发工具
    │   ├── packages.nix   # 用户软件包
    │   ├── shell.nix     # Shell 环境
    │   ├── terminal.nix  # 终端配置
    │   └── ui.nix        # UI 相关配置
    └── shared/
        └── default.nix   # 共享配置
```

## 安装新软件

### 1. Nix 包（推荐）
编辑 `modules/home-manager/packages.nix`：
```nix
home.packages = with pkgs; [
  # 现有包...
  neovim        # 添加新包
  git
  curl
];
```

### 2. Homebrew 包
编辑 `modules/darwin/homebrew.nix`：
```nix
homebrew = {
  brews = [
    # 现有包...
    "new-package"  # 添加新包
  ];
  casks = [
    # 现有应用...
    "new-app"      # 添加新应用
  ];
};
```

### 3. 开发工具
编辑 `modules/home-manager/development.nix`：
```nix
home.packages = with pkgs; [
  # 现有工具...
  nodejs        # 添加开发工具
  python3
];
```

## 配置文件管理

### 添加新的配置文件
1. 将配置文件放在 `config/` 目录下
2. 在 `modules/home-manager/ui.nix` 中添加符号链接：
```nix
home.file.".config/app/config" = {
  source = ../../config/app/config;
};
```

### 修改现有配置
- `config/skhd/skhdrc` - 快捷键配置
- `config/yabai/yabairc` - 窗口管理器配置
- 修改后运行 `make switch` 应用更改

## 构建和管理

### 构建 vs 应用的区别

在 Nix Darwin 中，"构建" 和 "应用" 是两个不同的步骤：

#### `make build` - 只构建，不应用
```bash
nix build ".#darwinConfigurations.simple.system"
```
**作用**：
- 计算并构建所有需要的包和配置文件
- 在 `/nix/store/` 中生成新的系统配置
- 创建 `result` 符号链接指向新构建的系统
- **但不会激活新配置**，系统依然使用旧配置

**好处**：
- 检查配置是否有语法错误
- 预先下载所有依赖
- 验证构建过程是否成功
- 不会影响当前运行的系统

#### `make switch` - 构建并应用
```bash
# 先构建，再应用
nix build + sudo darwin-rebuild switch
```
**作用**：
- 首先执行构建过程
- 然后激活新配置，包括：
  - 更新系统设置
  - 重启需要重启的服务 (如 skhd, yabai)
  - 更新环境变量
  - 应用新的配置文件
  - 切换到新的系统 generation

#### 实际例子
比如你修改了 `config/skhd/skhdrc`：

**只构建**：
- ✅ 新的 skhdrc 被构建到 `/nix/store/xxx/etc/skhdrc`
- ❌ 但 skhd 依然读取旧的配置文件，快捷键修改不会生效

**构建并应用**：
- ✅ 新的 skhdrc 被构建并应用到 `/etc/skhdrc`
- ✅ skhd 服务被重启，读取新配置，快捷键修改立即生效

### 常用命令

```bash
# 显示帮助
make help

# 完整安装
make install

# 只构建（测试配置，不应用）
make build

# 构建并应用（立即生效）
make switch

# 重启服务
make restart-all        # 重启所有服务
make restart-yabai      # 只重启 yabai
make restart-skhd       # 只重启 skhd

# 系统信息
make info              # 基本信息
make status            # 详细状态
make test              # 测试配置

# 维护
make clean             # 清理构建缓存
make update            # 更新依赖
make check             # 检查配置语法

# 回滚操作
sudo darwin-rebuild rollback  # 回滚到上一个 generation
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system  # 查看所有 generation
```

### Nix Generation 概念

Nix 系统有 "generation" 概念：
- 每次 `make switch` 创建一个新的 generation
- 可以安全地回滚到之前的任何 generation
- `make build` 只是准备新 generation，不激活

这就是为什么 Nix 既安全又强大 - 你可以安全地测试构建，确认无误后再应用！

## 权限设置

首次安装后需要手动设置权限：
```bash
make permissions
```
或手动在"系统偏好设置 → 安全性与隐私 → 辅助功能"中添加：
- Terminal.app / 或者是你正在用的shell
- yabai
- skhd
- 相关进程都要添加...

## 故障排除

```bash
# 查看服务状态
make status

# 查看日志
make logs

# 测试配置
make test

# 重启服务
make restart-all
```

## 自定义

1. **修改快捷键**：编辑 `config/skhd/skhdrc`
2. **窗口管理行为**：编辑 `config/yabai/yabairc`
3. **系统设置**：编辑 `modules/darwin/system.nix`
4. **字体和主题**：编辑 `modules/darwin/fonts.nix`

修改后运行 `make switch` 应用更改。
