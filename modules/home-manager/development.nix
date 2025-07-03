{ config, pkgs, ... }:

{
  # Development-specific configurations and specialized tools
  # Note: All packages are managed in packages.nix
  
  # Git configuration
  programs.git = {
    enable = true;
    userName = "lonnetkirisame";
    userEmail = "your-email@example.com";
    
    extraConfig = {
      init.defaultBranch = "main";
      core = {
        editor = "nvim";
        autocrlf = "input";
        safecrlf = true;
      };
      pull.rebase = true;
      push = {
        autoSetupRemote = true;
        default = "simple";
      };
      rerere.enabled = true;
      merge.conflictstyle = "diff3";
      diff.algorithm = "patience";
      
      # Use delta for better diffs
      core.pager = "delta";
      interactive.diffFilter = "delta --color-only";
      delta = {
        navigate = true;
        light = false;
        side-by-side = true;
        line-numbers = true;
      };
    };
    
    aliases = {
      # Short commands
      st = "status";
      co = "checkout";
      br = "branch";
      ci = "commit";
      
      # Log commands
      lg = "log --oneline --graph --decorate";
      lga = "log --oneline --graph --decorate --all";
      
      # Diff commands
      d = "diff";
      dc = "diff --cached";
      
      # Reset commands
      unstage = "reset HEAD --";
      undo = "reset --soft HEAD~1";
      
      # Stash commands
      save = "stash save";
      pop = "stash pop";
    };
  };

  # FZF configuration
  programs.fzf = {
    enable = true;
    defaultCommand = "fd --type f --hidden --follow --exclude .git";
    defaultOptions = [
      "--height 40%"
      "--layout=reverse"
      "--border"
      "--inline-info"
    ];
    
    fileWidgetCommand = "fd --type f --hidden --follow --exclude .git";
    fileWidgetOptions = [ "--preview 'bat --color=always {}'" ];
    
    changeDirWidgetCommand = "fd --type d --hidden --follow --exclude .git";
    changeDirWidgetOptions = [ "--preview 'tree -C {} | head -200'" ];
    
    historyWidgetOptions = [ "--sort" "--exact" ];
  };

  # Tmux configuration
  programs.tmux = {
    enable = true;
    terminal = "screen-256color";
    historyLimit = 100000;
    keyMode = "vi";
    customPaneNavigationAndResize = true;
    
    extraConfig = ''
      # Enable mouse support
      set -g mouse on
      
      # Set prefix to Ctrl-a
      set -g prefix C-a
      unbind C-b
      bind C-a send-prefix
      
      # Split panes using | and -
      bind | split-window -h
      bind - split-window -v
      unbind '"'
      unbind %
      
      # Reload config file
      bind r source-file ~/.tmux.conf \; display-message "Config reloaded!"
      
      # Start windows and panes at 1, not 0
      set -g base-index 1
      setw -g pane-base-index 1
      
      # Automatically renumber windows
      set -g renumber-windows on
      
      # Status bar configuration
      set -g status-bg colour234
      set -g status-fg colour137
      set -g status-left ""
      set -g status-right "#[fg=colour233,bg=colour241,bold] %d/%m #[fg=colour233,bg=colour245,bold] %H:%M:%S "
      
      # Window status
      setw -g window-status-current-style fg=colour81,bg=colour238,bold
      setw -g window-status-current-format " #I#[fg=colour250]:#[fg=colour255]#W#[fg=colour50]#F "
      setw -g window-status-style fg=colour138,bg=colour235,none
      setw -g window-status-format " #I#[fg=colour237]:#[fg=colour250]#W#[fg=colour244]#F "
    '';
  };
  
  # Note: All packages are now managed in packages.nix
  # This file only contains program configurations
}
