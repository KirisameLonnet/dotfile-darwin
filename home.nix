{ config, pkgs, ... }:

{
  # Import modular configurations
  imports = [
    ./modules/home-manager/shell.nix
    ./modules/home-manager/terminal.nix
    ./modules/home-manager/development.nix
    ./modules/home-manager/ui.nix
  ];

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "lonnetkirisame";
  home.homeDirectory = "/Users/lonnetkirisame";

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  home.stateVersion = "24.05";

  # Packages
  home.packages = with pkgs; [
    # Development tools
    neovim
    tmux
    zellij
    
    # Terminal utilities
    eza
    bat
    ripgrep
    fd
    fzf
    tree
    htop
    btop
    lazygit
    
    # Programming languages
    nodejs
    python3
    rustc
    cargo
    go
    
    # System tools
    mas
    coreutils
    findutils
    gnused
    gawk
    gnugrep
    
    # Media tools
    imagemagick
    ffmpeg
    
    # Network tools
    curl
    wget
    httpie
    
    # Archive tools
    unzip
    p7zip
  ];

  # Git
  programs.git = {
    enable = true;
    userName = "lonnetkirisame";
    userEmail = "your-email@example.com";
    extraConfig = {
      init.defaultBranch = "main";
      core.editor = "nvim";
      pull.rebase = true;
      push.autoSetupRemote = true;
      rerere.enabled = true;
    };
  };

  # Zsh
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    
    shellAliases = {
      ll = "eza -la";
      ls = "eza";
      cat = "bat";
      grep = "rg";
      find = "fd";
      top = "btop";
      vim = "nvim";
      v = "nvim";
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
      
      # System aliases
      brewup = "brew update && brew upgrade && brew cleanup";
      nixup = "darwin-rebuild switch --flake ~/.config/nixconfig";
      reload = "source ~/.zshrc";
      
      # Window manager aliases
      yreload = "yabai --restart-service";
      sreload = "skhd --restart-service";
      wmreload = "yabai --restart-service && skhd --restart-service";
      wmstatus = "echo 'Yabai:' && yabai -m config; echo '\\nSKHD:' && pgrep -x skhd > /dev/null && echo 'Running' || echo 'Not running'";
      yconfig = "yabai -m config";
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
      
      # Add ~/.local/bin to PATH
      export PATH="$HOME/.local/bin:$PATH"
      
      # Load FZF if available
      if command -v fzf >/dev/null 2>&1; then
        source <(fzf --zsh)
      fi
      
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
    '';
  };

  # Starship prompt
  programs.starship = {
    enable = true;
    settings = {
      format = "$all$character";
      right_format = "$time";
      
      character = {
        success_symbol = "[➜](bold green)";
        error_symbol = "[➜](bold red)";
      };
      
      time = {
        disabled = false;
        format = "[$time]($style)";
        style = "bright-blue";
      };
      
      directory = {
        truncation_length = 3;
        truncation_symbol = "…/";
        style = "bold cyan";
      };
      
      git_branch = {
        symbol = " ";
        style = "bold purple";
      };
      
      git_status = {
        style = "bold yellow";
      };
      
      nodejs = {
        symbol = " ";
        style = "bold green";
      };
      
      python = {
        symbol = " ";
        style = "bold yellow";
      };
      
      rust = {
        symbol = " ";
        style = "bold orange";
      };
      
      package = {
        symbol = " ";
        style = "bold red";
      };
    };
  };

  # Alacritty terminal
  programs.alacritty = {
    enable = true;
    settings = {
      window = {
        decorations = "buttonless";
        opacity = 0.95;
        blur = true;
        option_as_alt = "Both";
        padding = {
          x = 20;
          y = 20;
        };
      };
      
      font = {
        normal = {
          family = "JetBrainsMono Nerd Font";
          style = "Regular";
        };
        bold = {
          family = "JetBrainsMono Nerd Font";
          style = "Bold";
        };
        italic = {
          family = "JetBrainsMono Nerd Font";
          style = "Italic";
        };
        size = 14.0;
      };
      
      colors = {
        primary = {
          background = "#1e1e2e";
          foreground = "#cdd6f4";
        };
        normal = {
          black = "#45475a";
          red = "#f38ba8";
          green = "#a6e3a1";
          yellow = "#f9e2af";
          blue = "#89b4fa";
          magenta = "#f5c2e7";
          cyan = "#94e2d5";
          white = "#bac2de";
        };
        bright = {
          black = "#585b70";
          red = "#f38ba8";
          green = "#a6e3a1";
          yellow = "#f9e2af";
          blue = "#89b4fa";
          magenta = "#f5c2e7";
          cyan = "#94e2d5";
          white = "#a6adc8";
        };
      };
      
      cursor = {
        style = {
          shape = "Block";
          blinking = "On";
        };
        blink_interval = 500;
      };
      
      general = {
        live_config_reload = true;
      };
    };
  };

  # SketchyBar and yabai configuration - SketchyBar DISABLED
  # home.file.".config/sketchybar" = {
  #   source = ./config/sketchybar;
  #   recursive = true;
  # };

  home.file.".config/yabai" = {
    source = ./config/yabai;
    recursive = true;
  };

  home.file.".config/skhd" = {
    source = ./config/skhd;
    recursive = true;
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
