{
  config,
  pkgs,
  lib,
  ...
}:

let
  npmGlobalPackages = [
    "wrangler"
    "windmill-cli"
    "@openai/codex@latest"
  ];

  # DSH is published as a large set of interdependent prerelease packages.
  # Restrict resolution to the completed rc.2 release window so an in-progress
  # rc.3 rollout cannot produce a dependency tree containing unpublished parts.
  dshPackage = "@deepseek-ai/dsh@0.1.5-rc.2";
  dshReleaseCutoff = "2026-09-11T00:00:00Z";

  npmPrefix = "${config.home.homeDirectory}/.local/share/npm";

  # home-manager 给 launchd.agents.<name> 生成的 Label 就是这个前缀 + name。
  # 下面的 agent 和 activation 里的 kickstart 共用它，避免两处写死后跑偏。
  colimaAgentLabel = "org.nix-community.home.colima";
  # ===== 关掉 dsh web 的浏览器登录 token =====
  #
  # dsh 没有为此提供任何开关：dsh-client-connection 的 apply() 无条件 new 出
  # BrowserAuth，schema 里只有 trustedHosts / cookieMaxAgeDays /
  # maxRequestBodyBytes，DSH_* 环境变量里也没有逃生口。所以只能在运行时改行为。
  #
  # 好在 HostConnectionService 是**导出**的，而 frontend-static 和 /api 路由都是
  # 在实例上调这两个方法，因此改原型就够了，不用碰 npm 包里的任何文件。
  #
  # 刻意只吞掉 401（token/cookie 缺失），保留 403：那是 requestRejection 里的
  # Host/Origin 围栏，挡的是"你访问的恶意网页用 JS 打 127.0.0.1:3080 来驱动你的
  # agent"（CSRF / DNS rebinding）。既然服务只听回环，这层就是唯一剩下的防线，
  # 不能一起拆掉。
  #
  # 代价：这是贴着上游内部实现写的，dsh 升级后若类名或方法签名变了会失效。
  # 失效表现是 401 回来了（或启动时抛 "HostConnectionService not found"），
  # 属于"退回安全默认"，不会静默变得更不安全。
  dshNoAuthPlugin = pkgs.writeText "dsh-no-browser-auth.js" ''
    import { createRequire } from "node:module";
    import { pathToFileURL } from "node:url";

    export const name = "dsh-no-browser-auth";

    const DSH_BIN = "${npmPrefix}/lib/node_modules/@deepseek-ai/dsh/lib/bin.js";

    export async function apply(ctx) {
      const require = createRequire(DSH_BIN);
      const entry = require.resolve("@deepseek-ai/dsh-client-connection");
      const mod = await import(pathToFileURL(entry).href);
      const proto = mod.HostConnectionService?.prototype;
      if (!proto) throw new Error("dsh-no-browser-auth: HostConnectionService not found");

      // 401 = 没有 token/cookie，放行；403 = Host/Origin 围栏，保留。
      const originalRejection = proto.requestRejection;
      proto.requestRejection = function (request) {
        const rejection = originalRejection.call(this, request);
        return rejection === 401 ? undefined : rejection;
      };
      proto.authorizeIndex = function () { return true; };
      // 让启动日志里印出干净的 URL，而不是再带一个没用的 ?token=。
      proto.authenticatedUrl = function (baseUrl) { return baseUrl; };
      console.log("dsh-no-browser-auth: browser authentication disabled");
    }
  '';

  # patch 条目要用 `insert` 才是"往树里加一行插件"；只写 id + name 会被当成
  # 对某个已有 id 的覆盖，匹配不到就静默跳过（调了半天没反应就是踩这个）。
  # name 写绝对路径时 dsh 会自动转成 file:// URL。
  dshNoAuthPatch = pkgs.writeText "dsh-no-auth.patch.yml" ''
    - insert:
        - id: no-browser-auth
          name: ${dshNoAuthPlugin}
  '';

  deepseekHarness = pkgs.writeShellScriptBin "dsh" ''
    dsh="${npmPrefix}/bin/dsh"
    if [ ! -x "$dsh" ]; then
      echo "DeepSeek Harness is not installed yet: $dsh" >&2
      exit 75
    fi

    # DSH 访问的内网服务用自签证书，默认关掉 Node 的证书校验；
    # 需要严格校验时在外面显式设置 NODE_TLS_REJECT_UNAUTHORIZED=1 即可覆盖。
    export NODE_TLS_REJECT_UNAUTHORIZED="''${NODE_TLS_REJECT_UNAUTHORIZED:-0}"

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
    ${pkgs.nodejs_22}/bin/npm install --global --prefix "$npm_prefix" \
      --before=${lib.escapeShellArg dshReleaseCutoff} \
      ${lib.escapeShellArg dshPackage} --quiet

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
  #
  # --no-open：这是个常驻服务，KeepAlive 每次拉起都弹一次默认浏览器会很烦。
  # --patch dshNoAuthPatch：去掉浏览器登录 token，理由见上面那段注释。
  # host / port 留默认的 127.0.0.1:3080，只听回环。
  # TLS 校验不用在这里关：ProgramArguments 走的是上面那个 dsh wrapper，
  # NODE_TLS_REJECT_UNAUTHORIZED=0 已经在 wrapper 里 export 过了。
  launchd.agents.deepseek-harness = {
    enable = true;
    config = {
      ProgramArguments = [
        "${deepseekHarness}/bin/dsh"
        "--profile"
        "web"
        "--patch"
        "${dshNoAuthPatch}"
        "--no-open"
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

  # ===== somark-baremetal K8s 隧道 =====
  #
  # 集群 API 只在内网可达，本地 kubectl 得经 kepler3 中转。
  #
  # 为什么是 SOCKS5（-D）而不是端口转发（-L）：API 证书的 SAN 是
  # eva / kubernetes / 10.96.0.1 / 192.168.7.201 / 192.168.7.200，不含 127.0.0.1。
  # 走 SOCKS 时 kubeconfig 里的 server 仍写真实地址 https://192.168.7.200:8443，
  # TLS 校验能正常通过，不需要 tls-server-name 之类的绕过。
  #
  # 影响面只有 somark 一个集群：proxy-url 是写在 ~/.kube/somark-baremetal.yaml
  # 的 cluster 条目里的，lab 集群和其它流量都不经过这条隧道。
  launchd.agents.somark-tunnel = {
    enable = true;
    config = {
      # 用 /usr/bin/ssh 而不是 pkgs.openssh：要走 ~/.ssh/config 里的 kepler3
      # 别名（HostName 114.80.15.158 / Port 2203 / User ops）。
      # 刻意**不加 -f**：launchd 要进程留在前台才能监管，自己 daemonize 会被
      # 误判成启动即退出，然后被 KeepAlive 无限重拉。
      ProgramArguments = [
        "/usr/bin/ssh"
        "-N"
        "-D"
        "127.0.0.1:11080"
        # 端口已被占用就直接失败退出交给 KeepAlive 重试，
        # 而不是留一个连上了却没在转发的假隧道。
        "-o"
        "ExitOnForwardFailure=yes"
        # 网络断掉时 ~90s 内进程退出，KeepAlive 才有机会重连；
        # 否则 TCP 会僵在那里，kubectl 表现为长时间挂起而不是报错。
        "-o"
        "ServerAliveInterval=30"
        "-o"
        "ServerAliveCountMax=3"
        # 后台没人盯着，任何交互提示（host key 变更、要密码）直接失败进日志，
        # 不要挂死。id_ed25519 没有 passphrase，正常路径不需要 ssh-agent。
        "-o"
        "BatchMode=yes"
        "kepler3"
      ];
      EnvironmentVariables = {
        # ssh 靠 HOME 找 ~/.ssh/config 和默认身份 id_ed25519。
        HOME = config.home.homeDirectory;
        PATH = "/usr/bin:/bin";
      };
      WorkingDirectory = config.home.homeDirectory;
      RunAtLoad = true;
      KeepAlive = true; # 断线自动重连
      ThrottleInterval = 10;
      StandardOutPath = "${config.home.homeDirectory}/Library/Logs/somark-tunnel.log";
      StandardErrorPath = "${config.home.homeDirectory}/Library/Logs/somark-tunnel.error.log";
    };
  };

  # 这里**不需要**往 ~/.docker/cli-plugins 链 compose / buildx：nixpkgs 的
  # docker-client 是个 makeBinaryWrapper，已经把这两个包的 libexec 目录塞进了
  # DOCKER_CLI_PLUGIN_EXTRA_DIRS，`docker compose` / `docker buildx` 开箱即用。
  # 验证：DOCKER_CONFIG=$(mktemp -d) docker compose version —— 绕开 ~/.docker
  # 之后插件依旧解析得到，路径直接指向 /nix/store。
  # 好处是 ~/.docker 整个目录保持"Nix 完全不碰"，与 README §4.13 的分工一致。

  # Note: All packages are now managed in packages.nix
  # This file only contains program configurations
}
