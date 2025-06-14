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
    yabai              # 平铺窗口管理器
    skhd               # 简单快捷键守护进程
    # borders 可以根据需要从源码构建
  ];

  # 启用 yabai 和 skhd 服务
  services = {
    yabai = {
      enable = true;
      package = pkgs.yabai;
      # 使用外部 yabairc 文件，避免重复配置
      # 基础配置已经在 config/yabai/yabairc 中定义
      extraConfig = ''
        # 只在这里处理 Nix 特定的启动逻辑
        echo "yabai service managed by nix-darwin, configuration loaded from yabairc"
      '';
    };

    skhd = {
      enable = true;
      package = pkgs.skhd;
      skhdConfig = builtins.readFile ../../config/skhd/skhdrc;
    };
  };

  # 用户会话服务的 LaunchAgents  
  launchd.agents = {
    skhd = {
      serviceConfig = {
        ProgramArguments = [ "${pkgs.skhd}/bin/skhd" "-c" "/etc/skhdrc" ];
        KeepAlive = true;
        RunAtLoad = true;
        ProcessType = "Interactive";
        StandardOutPath = "/tmp/skhd.out.log";
        StandardErrorPath = "/tmp/skhd.err.log";
        EnvironmentVariables = {
          PATH = "${pkgs.skhd}/bin:${config.environment.systemPath}";
        };
      };
    };
  };

  # 激活后脚本，确保服务正确启动
  system.activationScripts.postActivation.text = ''
    # 确保 yabai 拥有必要权限并正确启动
    if command -v yabai >/dev/null 2>&1; then
      echo "yabai found, ensuring proper configuration..."
      # 杀死任何现有的 yabai 进程以防止冲突
      pkill -f yabai || true
      sleep 1
    fi
    
    # 确保 skhd 正确启动
    if command -v skhd >/dev/null 2>&1; then
      echo "skhd found, ensuring proper configuration..."
      # 杀死任何现有的 skhd 进程以防止冲突
      pkill -f skhd || true
      sleep 1
    fi
    
    echo "Window manager services configured for nix-darwin management"
  '';

  # 增强的窗口管理默认设置
  system.defaults = {
    WindowManager = {
      EnableStandardClickToShowDesktop = false;
      StandardHideDesktopIcons = true;
      HideDesktop = false;  # 临时启用，避免影响系统设置
      StageManagerHideWidgets = true;
      GloballyEnabled = true;  # 临时启用，避免影响系统设置
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
