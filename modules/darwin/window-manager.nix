{ config, pkgs, ... }:

# ============================================================================
# 窗口管理器配置策略
# ============================================================================
#
# 配置方式：简化混合策略
# - Nix Darwin: 只管理服务启动/停止，包管理
# - yabairc: 处理所有实际配置（基础设置、规则、信号）
#
# 为什么采用这种方式：
# 1. 避免配置重复和冲突
# 2. yabairc 支持完整的 yabai 功能
# 3. Nix Darwin 负责服务管理，确保可靠启动
# 4. 配置更改只需要修改一个文件 (yabairc)
#
# 修复的问题：
# - 移除了 nix 配置和 yabairc 之间的重复配置
# - 消除了动画冲突
# - 简化了维护（yabai 配置的单一真相来源）
#
# 配置文件：
# - window-manager.nix: 服务管理 + 包安装
# - config/yabai/yabairc: 所有 yabai 配置
# - config/skhd/skhdrc: 所有快捷键配置
# ============================================================================

{
  # 窗口管理工具 - 全部使用 nix 构建而不是 homebrew
  environment.systemPackages = with pkgs; [
    yabai # 平铺窗口管理器
    skhd # 简单快捷键守护进程
    jankyborders # 聚焦窗口边框 (yabai 7.x 移除了原生 window_border)
  ];

  # 启用 yabai 和 skhd 服务
  services = {
    yabai = {
      enable = true;
      package = pkgs.yabai;
      # 加载外部 yabairc 配置文件
      extraConfig = builtins.readFile ../../config/yabai/yabairc;
    };

    skhd = {
      enable = true;
      package = pkgs.skhd;
      skhdConfig = builtins.readFile ../../config/skhd/skhdrc;
    };
  };

  launchd.user.agents."org.nixos.yabai".serviceConfig = {
    Nice = -20;
    ProcessType = "Interactive";
    LowPriorityIO = false;
  };

  launchd.user.agents."org.nixos.skhd".serviceConfig = {
    Nice = -20;
    ProcessType = "Interactive";
  };

  # JankyBorders - 聚焦窗口边框守护进程
  # yabai 7.x 移除了原生边框功能,改用 JankyBorders 绘制
  # 配置单一来源: config/borders/bordersrc (与 skhd 的 skhdConfig 模式一致)
  # 注意:
  # - nix-darwin 会自动给 key 加 org.nixos. 前缀,不要写全名
  # - borders 无参启动时不会可靠地执行 ~/.config/borders/bordersrc,
  #   所以这里显式用 bash 执行 nix store 中的配置副本
  # - bordersrc 内部用绝对路径调用 borders,因为 launchd 的 PATH 很精简
  launchd.user.agents.borders.serviceConfig = {
    ProgramArguments = [
      "/bin/bash"
      "${pkgs.writeText "bordersrc" (builtins.readFile ../../config/borders/bordersrc)}"
    ];
    RunAtLoad = true;
    KeepAlive = true;
    Nice = -20;
    ProcessType = "Interactive";
    LowPriorityIO = false;
  };

  # 增强的窗口管理默认设置
  system.defaults = {
    WindowManager = {
      EnableStandardClickToShowDesktop = false;
      StandardHideDesktopIcons = true;
      HideDesktop = false; # 临时启用，避免影响系统设置
      StageManagerHideWidgets = true;
      GloballyEnabled = false; # 禁用 Stage Manager，避免与 yabai 冲突
    };

    spaces = {
      spans-displays = false;
    };

    # 自定义应用特定设置以隐藏标题
    universalaccess = {
      reduceMotion = false; # 保持动画效果启用
      reduceTransparency = false; # 保持透明度效果
    };
  };
}
