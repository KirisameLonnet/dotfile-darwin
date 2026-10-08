{ config, pkgs, ... }:

{
  home.sessionPath = [
    "$HOME/.local/bin"
    "$HOME/.local/share/npm/bin"
    "$HOME/.local/share/pnpm" # pnpm 的全局 bin 目录，见下方 PNPM_HOME
  ];

  # Shell configuration
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    # Environment variables to suppress macOS system logs
    sessionVariables = {
      # Default text editor
      EDITOR = "nvim";
      VISUAL = "nvim";
      GIT_EDITOR = "nvim";

      # Suppress macOS input method and keyboard logs
      OS_ACTIVITY_MODE = "disable";
      # Reduce CoreFoundation logging
      CFLOG_FORCE_DISABLE_STDERR = "1";
      # Suppress TSM (Text Services Manager) logs
      TSM_DISABLE_LOG = "1";

      # Rust standard library source for rust-analyzer
      RUST_SRC_PATH = "${pkgs.rustPlatform.rustLibSrc}";

      # pnpm 全局安装目录。显式设定是必要的：不设的话 `pnpm add -g` 会让你去跑
      # `pnpm setup`，而它要往 .zshrc 里追加 PATH——那个文件是 home-manager 管的
      # 只读符号链接，改不动。路径对齐 npm 全局包的 ~/.local/share/npm。
      PNPM_HOME = "$HOME/.local/share/pnpm";

      # 多集群并存：lab 集群（~/.kube/config）+ somark-baremetal。
      # kubectl config get-contexts 能同时看到两边，用 use-context 或 --context 切。
      KUBECONFIG = "$HOME/.kube/config:$HOME/.kube/somark-baremetal.yaml";

      # Gemini CLI Configuration
      # API key should be set in ~/.gemini/.env file
    };

    shellAliases = {
      # Modern replacements for classic commands
      ll = "eza -la";
      ls = "eza";
      cat = "bat";
      grep = "rg";
      find = "fd";
      top = "btop";
      vim = "nvim";
      v = "nvim";
      ssh = "kitten ssh";
      icat = "kitten icat";

      # Navigation
      ".." = "cd ..";
      "..." = "cd ../..";
      "...." = "cd ../../..";

      # Git aliases
      g = "git";
      ga = "git add";
      gaa = "git add --all";
      gb = "git branch";
      gc = "git commit";
      gcm = "git commit -m";
      gco = "git checkout";
      gd = "git diff";
      gl = "git log --oneline --graph --decorate";
      gp = "git push";
      gpl = "git pull";
      gs = "git status";

      # Shell helpers
      reload = "source ~/.zshrc";
      sudo = "sudo ";

      # macOS specific
      showfiles = "defaults write com.apple.finder AppleShowAllFiles -bool true && killall Finder";
      hidefiles = "defaults write com.apple.finder AppleShowAllFiles -bool false && killall Finder";

      # FelixKratz workflow aliases
      fm = "nnn";

      # AI/ML Tools aliases
      gemini = "npx @google/gemini-cli";
      gm = "npx @google/gemini-cli";
      gemini-chat = "npx @google/gemini-cli -i";

      # dsh web 是个 launchd 常驻服务（见 development.nix），改了 nix 要先
      # darwin-rebuild switch 再用这个重启，光 kickstart 不会换 store 路径。
      dsh-restart = "launchctl kickstart -k gui/501/org.nix-community.home.deepseek-harness";
      dsh-log = "tail -f ~/Library/Logs/deepseek-harness.log";

      # somark K8s 隧道（launchd 常驻，见 development.nix）
      sk-restart = "launchctl kickstart -k gui/501/org.nix-community.home.somark-tunnel";
      sk-log = "tail -f ~/Library/Logs/somark-tunnel.error.log";
    };

    initContent = ''
      # Enable vi mode
      bindkey -v

      # History configuration
      HISTFILE=~/.zsh_history
      HISTSIZE=10000
      SAVEHIST=10000
      setopt HIST_VERIFY
      setopt SHARE_HISTORY
      setopt APPEND_HISTORY
      setopt INC_APPEND_HISTORY
      setopt HIST_IGNORE_DUPS
      setopt HIST_IGNORE_ALL_DUPS
      setopt HIST_IGNORE_SPACE
      setopt HIST_EXPIRE_DUPS_FIRST
      setopt HIST_SAVE_NO_DUPS

      # Directory options
      setopt AUTO_CD
      setopt AUTO_PUSHD
      setopt PUSHD_IGNORE_DUPS
      setopt PUSHD_SILENT

      # Completion options
      setopt COMPLETE_ALIASES
      setopt COMPLETE_IN_WORD
      setopt ALWAYS_TO_END

      # Custom functions
      function mkcd() {
        mkdir -p "$1" && cd "$1"
      }

      function extract() {
        if [ -f $1 ] ; then
          case $1 in
            *.tar.bz2)   tar xjf $1     ;;
            *.tar.gz)    tar xzf $1     ;;
            *.bz2)       bunzip2 $1     ;;
            *.rar)       unrar e $1     ;;
            *.gz)        gunzip $1      ;;
            *.tar)       tar xf $1      ;;
            *.tbz2)      tar xjf $1     ;;
            *.tgz)       tar xzf $1     ;;
            *.zip)       unzip $1       ;;
            *.Z)         uncompress $1  ;;
            *.7z)        7z x $1        ;;
            *)     echo "'$1' cannot be extracted via extract()" ;;
          esac
        else
          echo "'$1' is not a valid file"
        fi
      }

      # somark-baremetal 集群的 kubectl 简写。隧道由 launchd agent 常驻
      # （见 development.nix 的 launchd.agents.somark-tunnel），这里不用管。
      # 连不上先看 sk-log。
      function sk() {
        kubectl --context kubernetes-admin@somark-baremetal "$@"
      }

      # macOS specific settings
      export BROWSER="open"

      # Normalize PATH to the nix-darwin per-user profile and avoid stale standalone Home Manager links taking priority.
      path=(''${path:#$HOME/.nix-profile/bin})
      path=(/etc/profiles/per-user/lonnetkirisame/bin $HOME/.local/bin $HOME/.local/share/npm/bin $HOME/.local/share/pnpm /opt/homebrew/bin $path)
      export PATH

      # ashpipe: SSH Native Agent Bridge
      # Disabled by default because `ashpipe detect` runs on every `cd` via the
      # zsh chpwd hook and blocks when configured portals are unreachable.
      if [[ "''${ASHPIPE_ENABLE_ZSH_HOOK:-0}" == "1" ]] && command -v ashpipe >/dev/null 2>&1; then
        eval "$(ashpipe hook zsh)"
      fi

      # Load any user-managed environment fragments from ~/.custom-env without requiring a rebuild.
      for env_file in "$HOME"/.custom-env/*.env(N); do
        source "$env_file"
      done
    '';
  };

  # Starship prompt
  programs.starship = {
    enable = true;
    settings = {
      # Use a two-line prompt structure with a connecting line
      format = ''
        ╭─$os$hostname$directory$git_branch$git_status
        ╰─$character'';

      # Hide the time from the right format for a cleaner look
      right_format = "$cmd_duration";

      # General settings
      add_newline = true;

      # OS Module
      os = {
        format = "[$symbol]($style)";
        style = "bold blue";
        disabled = false;
      };
      os.symbols = {
        Macos = "󰀵 ";
      };

      # Hostname module (only shown when on remote machine)
      hostname = {
        ssh_only = true;
        format = "on [$hostname]($style) ";
        style = "bold yellow";
        disabled = false;
      };

      # Directory Module with custom symbols and colors
      directory = {
        format = "in [$path]($style)[$read_only]($read_only_style) ";
        truncation_length = 3;
        truncation_symbol = "…/";
        style = "bold cyan";
        read_only = " 🔒";
        read_only_style = "red";
      };

      # Git Branch Module with custom symbol
      git_branch = {
        symbol = " ";
        format = "on [$symbol$branch]($style) ";
        style = "bold purple";
      };

      # Git Status Module with detailed symbols
      git_status = {
        format = "([$all_status$ahead_behind]($style))";
        style = "bold yellow";
        conflicted = " ";
        ahead = " ";
        behind = " ";
        diverged = " ";
        untracked = " ";
        stashed = " 󰏖";
        modified = " ";
        staged = " ";
        renamed = "     renaming";
        deleted = " 🗑";
      };

      # Command Duration Module (only shows for slow commands)
      cmd_duration = {
        min_time = 2000; # 2 seconds
        format = "took [$duration]($style) ⏳";
        style = "bold yellow";
      };

      # Character Module (the prompt symbol)
      character = {
        success_symbol = "[❯](bold green)";
        error_symbol = "[❯](bold red)";
        vimcmd_symbol = "[❮](bold green)";
        vimcmd_replace_one_symbol = "[❮](bold purple)";
        vimcmd_replace_symbol = "[❮](bold purple)";
        vimcmd_visual_symbol = "[❮](bold yellow)";
      };

      # Language-specific modules with Nerd Font icons
      nodejs = {
        symbol = " ";
        style = "bold green";
        format = "via [$symbol($version)]($style) ";
      };
      python = {
        symbol = " ";
        style = "bold yellow";
        format = "via [$symbol($version)]($style) ";
      };
      rust = {
        symbol = " ";
        style = "bold orange";
        format = "via [$symbol($version)]($style) ";
      };
      nix_shell = {
        symbol = " ";
        style = "bold blue";
        format = "in [$symbol$state]($style) ";
      };
      package = {
        symbol = "󰏗 ";
        style = "bold red";
        format = "[$symbol$version]($style) ";
      };
    };
  };
}
