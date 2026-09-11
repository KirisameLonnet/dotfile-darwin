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

  # home-manager 给 launchd.agents.<name> 生成的 Label 就是这个前缀 + name。
  # 下面的 agent 和 activation 里的 kickstart 共用它，避免两处写死后跑偏。
  colimaAgentLabel = "org.nix-community.home.colima";
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

  # ===== Docker / colima =====
  #
  # 分工：Nix 决定"服务跑不跑"，colima 自己的配置文件决定"VM 长什么样"。
  #
  # 下面这个 agent 刻意**不带任何规格参数**。`colima start` 不给 flag 时会读
  # ~/.colima/default/colima.yaml，那才是 CPU / 内存 / 磁盘 / vm-type 的事实
  # 来源，改它用 `colima start --edit`，不用回来改 nix、也不用 rebuild。
  # 一旦在这里写死 `--cpus 4`，VM 规格就被 Nix 接管了，那不是想要的效果。
  launchd.agents.colima = {
    enable = true;
    config = {
      Label = colimaAgentLabel;
      # --foreground 让 colima 进程留在前台，launchd 才能真正监管它；
      # 默认的 `colima start` 会自己 daemonize，launchd 看到进程立刻退出，
      # 会误判成启动失败。
      ProgramArguments = [
        "${pkgs.colima}/bin/colima"
        "start"
        "--foreground"
      ];
      EnvironmentVariables = {
        HOME = config.home.homeDirectory;
        # colima 的 Nix wrapper 已经把 lima / qemu / krunkit / docker 注入
        # PATH，这里只需补上系统路径：lima 的 ssh 端口转发要用 /usr/bin/ssh。
        PATH = "/usr/bin:/bin:/usr/sbin:/sbin";
      };
      WorkingDirectory = config.home.homeDirectory;
      RunAtLoad = true; # 登录时起；rebuild 换了 plist 内容也会重新 bootstrap
      # 只在异常退出时重启。`colima stop` 属于正常退出（exit 0），
      # 于是手动停下来释放内存这件事仍然有效，不会被 launchd 立刻拉回来。
      KeepAlive = {
        SuccessfulExit = false;
      };
      ThrottleInterval = 30; # 起 VM 比起 web 服务慢，失败重试别太密
      # 首次启动要下载并初始化 Linux 镜像，耗时几分钟且全在后台。
      # 这两个日志是唯一能看到进度的地方。
      StandardOutPath = "${config.home.homeDirectory}/Library/Logs/colima.log";
      StandardErrorPath = "${config.home.homeDirectory}/Library/Logs/colima.error.log";
    };
  };

  # home-manager 的 setupLaunchAgents 只在 plist 内容变了、或 agent 根本没加载
  # 时才会 bootstrap。"手动 colima stop 过 → 再 rebuild" 这条路径里 agent 仍然
  # 是 loaded 状态（只是进程正常退出了没被拉起），于是 switch 不会把 VM 带回来。
  # kickstart 补上这个缺口：没在跑就起，已经在跑就什么都不做——注意**不加 -k**，
  # 否则每次 rebuild 都会杀掉一个健康的 VM 重来。
  home.activation.startColima = lib.hm.dag.entryAfter [ "setupLaunchAgents" ] ''
    if ! run /bin/launchctl kickstart "gui/$(id -u)/${colimaAgentLabel}"; then
      warnEcho "colima agent 没能启动，看 ~/Library/Logs/colima.error.log"
    fi
  '';

  # docker CLI 只在 ~/.docker/cli-plugins 和几个 /usr/... 目录里找插件，Nix
  # profile 的 libexec 不在搜索路径上，所以 `docker compose` / `docker buildx`
  # 这两个子命令必须靠符号链接接进去。
  #
  # 刻意只链这两个文件，而不是接管整个 ~/.docker：config.json、contexts、
  # 凭证和 buildx 的状态都在同一个目录下，必须保持可写、由 docker 自己维护。
  home.file = {
    ".docker/cli-plugins/docker-compose".source =
      "${pkgs.docker-compose}/libexec/docker/cli-plugins/docker-compose";
    ".docker/cli-plugins/docker-buildx".source =
      "${pkgs.docker-buildx}/libexec/docker/cli-plugins/docker-buildx";
  };

  # Note: All packages are now managed in packages.nix
  # This file only contains program configurations
}
