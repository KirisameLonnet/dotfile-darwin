{ config, ... }:

{
  # Homebrew packages declared through nix-darwin's supported module.
  homebrew = {
    enable = true;

    # Use nix-darwin's native activation policy instead of raw brew flags.
    onActivation = {
      cleanup = "none";
      autoUpdate = true; # Keep Homebrew compatible with its live package APIs
      upgrade = true;
      # Do not hand-roll cleanup flags here. Homebrew 6 marks
      # `brew bundle install --cleanup` as odisabled (it hard-errors and aborts
      # activation), and `--zap` without `--force-cleanup` raises a UsageError.
      # Cleanup is driven by `cleanup` above, which emits the correct flags.
      extraFlags = [
        "--quiet"
      ];
    };

    # Global homebrew settings optimized for Nix management
    global = {
      brewfile = true; # Generate Brewfile for compatibility

      autoUpdate = true; # Keep manual Homebrew commands on the current client and API versions
    };

    # Essential taps - FelixKratz ecosystem + core tools
    taps = [
      "farion1231/ccswitch" # CC Switch GUI app
    ];

    # CLI tools following FelixKratz's setup (macOS-specific or enhanced versions)
    brews = [
      # Core UI Components - FelixKratz ecosystem
      # Audio & Media - macOS integration tools
      "switchaudio-osx" # Audio device switching
      "nowplaying-cli" # Media information
      # Note: network formulae (ifstat, ...) are declared in ./network.nix

      # Terminal & Development Tools
      "lua" # For SbarLua configuration
      "lua-language-server" # LSP for Lua development

      # Additional Development Tools
      "tree-sitter" # Parser generator for syntax highlighting
      "libxkbcommon" # Keyboard handling library (Wayland/XKB)
      "little-cms2" # Color management (required by LibreOfficeDev)

    ];

    # GUI applications - FelixKratz's font requirements + essential apps
    casks = [
      "font-sf-mono" # San Francisco Mono font
      "font-sf-pro" # San Francisco Pro font

      # Nerd Fonts - Programming fonts with icons
      "font-hack-nerd-font" # Hack Nerd Font (FelixKratz preference)
      "font-jetbrains-mono" # JetBrains Mono (terminal primary)
      "font-meslo-lg-nerd-font" # Meslo LG Nerd Font (correct name)
      "font-fira-code-nerd-font" # Fira Code with ligatures

      # Development Fonts
      "font-victor-mono" # Victor Mono (cursive italics)
      "font-cascadia-code" # Microsoft's programming font

      # VS Code —— 刻意不走 Nix，见 README §4.14。
      # The Doki Theme 和 Custom CSS and JS Loader 都靠原地改写 app bundle 生效
      # （追加 workbench.desktop.main.css、patch workbench.desktop.main.js、
      # 重算 product.json 的 checksums），需要一个可写且路径稳定的安装位置，
      # 与只读的 /nix/store 正面冲突。理由与 §4.7 的 vesktop 同源。
      #
      # 不加 greedy：cask 是 auto_updates，brew bundle 在 onActivation.upgrade
      # 时会跳过它，版本由 VS Code 自己滚——这正好，免得 brew 和它的自更新器
      # 抢着改同一个 bundle，把扩展打的补丁冲掉。
      #
      # cask 自带 binary artifact，把 code CLI 链到 /opt/homebrew/bin/code，
      # 而 /opt/homebrew/bin 已在 shell.nix 的 PATH 里，所以 `code` 命令照常可用。
      "visual-studio-code"

      # System Integration Applications
      "marta" # File manager replacement options
      {
        name = "macfuse"; # FUSE kernel extension used by Nix sshfs
        greedy = true; # Keep the kernel extension and user-space library current
      }

      # Optional: FelixKratz workflow apps
      # "raycast"                  # Application launcher (modern Spotlight)
      # "cleanmymac"               # System maintenance
      # "finder"                   # File manager replacement options

      # Media & Productivity (optional)
      "flutter" # Flutter SDK for cross-platform development
      "cc-switch" # CC Switch GUI app for AI coding CLI provider management
      {
        name = "apifox"; # API documentation, debugging and testing client
        greedy = true; # Upgrade despite Homebrew auto_updates flag
      }
      {
        name = "codex-app"; # OpenAI Codex desktop app for managing coding agents
        greedy = true; # Upgrade despite Homebrew auto_updates flag
      }
      "libreoffice" # Office suite (includes soffice CLI)
      # "notion"                   # Note-taking

      # Previously hand-installed apps, taken over in place via
      # `brew install --cask --adopt` so the existing bundles (and their
      # granted macOS permissions) were kept rather than reinstalled.
      "android-studio" # Android IDE
      "chatgpt" # OpenAI desktop client
      "figma" # Design tool
      "jordanbaird-ice" # Ice — menu bar manager
      "monitorcontrol" # External display brightness/volume control
      "moonlight" # Game streaming client
      "motrix" # Download manager
      "obs" # Screen recording and streaming
      "playcover-community" # Run iOS apps on Apple silicon
      "tencent-lemon" # System cleanup utility
      "tencent-meeting" # Video conferencing
      "vlc" # Default media player (see ../home-manager/default-apps.nix)

      # Migrated off the Mac App Store (mas cannot drive the App Store on
      # macOS 15, see the masApps note below).
      "localsend" # Adopted in place — cask version matched the installed one
      "telegram" # Replaced the MAS build; messages re-sync from Telegram cloud
      "wechat" # Replaced the MAS build (sandboxed history intentionally dropped)
      "qq" # Replaced the MAS build (sandboxed history intentionally dropped)

      # NOT declarable under `caskArgs.require_sha = true` below — these casks
      # ship `sha256 :no_check` (rolling download URLs), so Homebrew refuses to
      # install them and activation would fail. Left as manual installs:
      #   google-chrome, spotify, steam, loopback
      # Cask disabled upstream (fails macOS Gatekeeper check, 2026-09-01):
      #   torrent-file-editor, xld
      # Local build differs from the cask, adopt rejected:
      #   obsidian (missing obsidian-cli), openmtp (3.2.25 vs 3.3.0),
      #   balenaetcher (2.1.4 vs 2.1.6)
    ];

    # Mac App Store apps are deliberately NOT declared via `masApps`.
    #
    # `mas` 7.0.0 cannot drive the App Store on macOS 15.x: with
    # `onActivation.upgrade = true`, `brew bundle` runs `mas upgrade` on every
    # outdated entry, which fails with a blocking "URL is not trusted" dialog.
    # These apps are also spread across several Apple IDs, so apps bought under
    # a different account additionally fail with a purchase-ownership error.
    # Declaring them turns every `darwin-rebuild switch` into a modal-dialog
    # gauntlet, so the inventory is kept here as documentation only.
    #
    # Office stays on the App Store: the cask ships the standalone installer
    # whose activation goes through a Microsoft 365 sign-in, and re-risking a
    # working activation is not worth managing three more entries.
    #
    # WeChat, QQ and Telegram were migrated off the App Store. Tencent's
    # standalone builds are sandboxed too and keep the same bundle IDs, so they
    # reuse the existing ~/Library/Containers/<bundle-id> data — history and
    # logins carried over intact. Do NOT delete those containers: they are the
    # live data directories, not leftovers from the MAS builds.
    #
    # Current Mac App Store inventory (`mas list` for IDs):
    #   Amphetamine 937984704      Dark Night 1592844577
    #   FastZip 1565629813         iCopy 1638023723
    #   iWall 1214761683           Keynote 409183694
    #   LocalSend 1661733229       Microsoft Excel 462058435
    #   Microsoft PowerPoint 462062816
    #   Microsoft Word 462054704   Numbers 409203825
    #   Pages 409201541            QQ 451108668
    #   Shadowrocket 932747118     Steam Link 1246969117
    #   Telegram 747648890         TeraCopy 1378806557
    #   Userscripts 1463298887     WeChat 836500024
    #   WireGuard 1451685025       Xcode 497799835
    #   Final Cut Pro — has a MAS receipt but `mas list` omits it (other Apple ID)
    #
    # These update through the App Store app itself; nothing here manages them.

    # Strict cask installation settings
    caskArgs = {
      appdir = "/Applications"; # Standard location
      require_sha = true; # Verify checksums for security
    };
  };

  # Environment integration - make homebrew tools available but secondary to nix
  environment.systemPath = [
    # Note: homebrew is added AFTER nix paths to give nix packages priority
    "${config.homebrew.prefix}/bin"
  ];

  # Security and privacy settings for homebrew
  environment.variables = {
    HOMEBREW_NO_ANALYTICS = "1"; # Disable telemetry
    HOMEBREW_NO_INSECURE_REDIRECT = "1"; # Security hardening
    HOMEBREW_CASK_OPTS = "--require-sha"; # Verify cask integrity
    HOMEBREW_BAT = "1"; # Use bat for better output (if available)
  };
}
