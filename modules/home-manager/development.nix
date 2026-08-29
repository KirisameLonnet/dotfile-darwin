{
  config,
  pkgs,
  lib,
  ...
}:

let
  npmGlobalPackages = [
    "wrangler"
    "@openai/codex"
    "@deepseek-ai/dsh"
  ];

  npmPrefix = "${config.home.homeDirectory}/.local/share/npm";
  deepseekHarness = pkgs.writeShellScriptBin "dsh" ''
    dsh="${npmPrefix}/bin/dsh"
    if [ ! -x "$dsh" ]; then
      echo "DeepSeek Harness is not installed yet: $dsh" >&2
      exit 75
    fi

    exec ${pkgs.nodejs_22}/bin/node --expose-internals "$dsh" "$@"
  '';
in
{
  # Development-specific configurations and specialized tools
  # Note: All packages are managed in packages.nix

  # The DSH web profile's HMR plugin requires Node loader internals.
  home.packages = [ deepseekHarness ];

  # Git configuration
  programs.git = {
    enable = true;
    ignores = [
      "**/.claude/settings.local.json"
      ".DS_Store"
    ];
    signing.format = null;
    settings.user.name = "lonnetkirisame";
    settings.user.email = "szfsy06@gmail.com";

    settings = {
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

    settings.alias = {
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

    fileWidget = {
      command = "fd --type f --hidden --follow --exclude .git";
      options = [ "--preview 'bat --color=always {}'" ];
    };

    changeDirWidget = {
      command = "fd --type d --hidden --follow --exclude .git";
      options = [ "--preview 'tree -C {} | head -200'" ];
    };

    historyWidget.options = [
      "--sort"
      "--exact"
    ];
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

  # Install npm-managed CLIs into a user-writable prefix.
  home.activation.installNpmGlobalPackages = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    npm_prefix="${npmPrefix}"
    mkdir -p "$npm_prefix"
    export PATH="${pkgs.nodejs_22}/bin:$npm_prefix/bin:$PATH"
    ${pkgs.nodejs_22}/bin/npm install --global --prefix "$npm_prefix" ${lib.escapeShellArgs npmGlobalPackages} --quiet

    # Fix @openai/codex: npm alias optional deps miss package.json and bin symlink
    codex_platform_dir="$npm_prefix/lib/node_modules/@openai/codex/node_modules/@openai/codex-darwin-arm64"
    if [ -d "$codex_platform_dir" ] && [ ! -f "$codex_platform_dir/package.json" ]; then
      echo '{"name":"@openai/codex-darwin-arm64","version":"0.0.0"}' > "$codex_platform_dir/package.json"
    fi
    codex_bin="$codex_platform_dir/vendor/aarch64-apple-darwin/bin/codex"
    if [ -f "$codex_bin" ] && ! /usr/bin/codesign -v "$codex_bin" 2>/dev/null; then
      /usr/bin/codesign --force --sign - "$codex_bin" 2>/dev/null || true
    fi
    ln -sf ../lib/node_modules/@openai/codex/bin/codex.js "$npm_prefix/bin/codex" 2>/dev/null || true
  '';

  # Start the DeepSeek Harness Web UI when the user logs in.
  launchd.agents.deepseek-harness = {
    enable = true;
    config = {
      ProgramArguments = [
        "${deepseekHarness}/bin/dsh"
        "web"
      ];
      EnvironmentVariables = {
        HOME = config.home.homeDirectory;
        PATH = "${pkgs.nodejs_22}/bin:${npmPrefix}/bin:/usr/bin:/bin";
      };
      WorkingDirectory = config.home.homeDirectory;
      RunAtLoad = true;
      KeepAlive = true;
      ThrottleInterval = 10;
      StandardOutPath = "${config.home.homeDirectory}/Library/Logs/deepseek-harness.log";
      StandardErrorPath = "${config.home.homeDirectory}/Library/Logs/deepseek-harness.error.log";
    };
  };

  # Note: All packages are now managed in packages.nix
  # This file only contains program configurations
}
