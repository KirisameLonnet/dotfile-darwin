{ config, pkgs, ... }:

{
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
      
      # System management
      nixup = "darwin-rebuild switch --flake ~/.config/nixconfig";
      nixcheck = "nix flake check ~/.config/nixconfig";
      nixbuild = "nix build ~/.config/nixconfig#darwinConfigurations.simple.system";
      reload = "source ~/.zshrc";
      
      # Modern setup script aliases
      setup = "./quick-setup.sh";
      setup-verify = "./quick-setup.sh --verify";
      setup-restart = "./quick-setup.sh --services";
      setup-help = "./quick-setup.sh --help";
      
      # macOS specific
      showfiles = "defaults write com.apple.finder AppleShowAllFiles -bool true && killall Finder";
      hidefiles = "defaults write com.apple.finder AppleShowAllFiles -bool false && killall Finder";
      
      # FelixKratz workflow aliases
      fm = "fnnn";                                   # File manager (custom nnn)
      # sb = "sketchybar";                            # SketchyBar control - DISABLED
      borders = "borders";                          # JankyBorders control
      restart-wm = "brew services restart yabai && brew services restart skhd && brew services restart borders";  # SketchyBar removed
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
      
      # macOS specific settings
      export BROWSER="open"
      
      # FelixKratz fnnn configuration
      if [ -f "$HOME/.config/fnnn/config.sh" ]; then
        source "$HOME/.config/fnnn/config.sh"
      fi
      
      # Enhanced path for FelixKratz tools
      export PATH="/opt/homebrew/bin:$PATH"
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
      
      nix_shell = {
        symbol = " ";
        style = "bold blue";
      };
    };
  };
}
