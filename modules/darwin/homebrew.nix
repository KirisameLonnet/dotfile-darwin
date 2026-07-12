{ config, ... }:

{
  # Homebrew packages declared through nix-darwin's supported module.
  homebrew = {
    enable = true;

    # Use nix-darwin's native activation policy instead of raw brew flags.
    onActivation = {
      cleanup = "none";
      autoUpdate = false;
      upgrade = true;
      extraFlags = [
        "--cleanup"
        "--zap"
        "--quiet"
      ];
    };

    # Global homebrew settings optimized for Nix management
    global = {
      brewfile = true; # Generate Brewfile for compatibility

      autoUpdate = false; # Disable homebrew's auto-update
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
      "ifstat" # Network statistics

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

      # System Integration Applications
      "marta" # File manager replacement options

      # Optional: FelixKratz workflow apps
      # "raycast"                  # Application launcher (modern Spotlight)
      # "cleanmymac"               # System maintenance
      # "finder"                   # File manager replacement options

      # Media & Productivity (optional)
      # "spotify"                  # Music streaming
      "vesktop" # Discord alternative (stable app path for macOS permissions)
      "flutter" # Flutter SDK for cross-platform development
      "cc-switch" # CC Switch GUI app for AI coding CLI provider management
      {
        name = "codex-app"; # OpenAI Codex desktop app for managing coding agents
        greedy = true; # Upgrade despite Homebrew auto_updates flag
      }
      "libreoffice" # Office suite (includes soffice CLI)
      # "notion"                   # Note-taking
    ];

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
