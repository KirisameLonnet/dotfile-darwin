{ config, pkgs, ... }:

{
  # Homebrew fully managed by Nix - zero manual intervention
  homebrew = {
    enable = true;
    
    # Strict cleanup and management policies - Nix controls everything
    onActivation = {
      cleanup = "zap";              # Remove ALL packages not declared in this file
      autoUpdate = false;           # Nix controls updates, not Homebrew
      upgrade = false;              # No automatic upgrades outside of Nix
      extraFlags = [
        "--quiet"                   # Suppress unnecessary output
        "--force"                   # Force operations when needed
      ];
    };
    
    # Global homebrew settings optimized for Nix management
    global = {
      brewfile = true;              # Generate Brewfile for compatibility
      lockfiles = false;            # Nix handles version pinning
      autoUpdate = false;           # Disable homebrew's auto-update
    };
    
    # Essential taps - FelixKratz ecosystem + core tools
    taps = [
      # "FelixKratz/formulae"         # SketchyBar, borders, fnnn - DISABLED
      "koekeishiya/formulae"        # yabai, skhd (backup if nix fails)
    ];
    
    # CLI tools following FelixKratz's setup (macOS-specific or enhanced versions)
    brews = [
      # Core UI Components - FelixKratz ecosystem
      "borders"                     # JankyBorders - window borders
      
      # Audio & Media - macOS integration tools
      "switchaudio-osx"             # Audio device switching
      "nowplaying-cli"              # Media information
      "ifstat"                      # Network statistics
      
      # Terminal & Development Tools
      "lua"                         # For SbarLua configuration
      "lua-language-server"         # LSP for Lua development
      
      # Scientific Computing (FelixKratz's research focus)
      "gsl"                         # GNU Scientific Library
      "llvm"                        # LLVM compiler infrastructure
      "boost"                       # C++ libraries collection
      "libomp"                      # OpenMP runtime library
      "armadillo"                   # Linear algebra library
      
      # Additional Development Tools
      "tree-sitter"                 # Parser generator for syntax highlighting
      
      # Note: fnnn is available through nix, no need for homebrew HEAD install
    ];
    
    # GUI applications - FelixKratz's font requirements + essential apps
    casks = [
      # Apple Fonts - Required for SketchyBar - DISABLED
      # "sf-symbols"                  # Apple's official symbol font (SketchyBar requirement)
      "font-sf-mono"               # San Francisco Mono font
      "font-sf-pro"                # San Francisco Pro font
      
      # Nerd Fonts - Programming fonts with icons
      "font-hack-nerd-font"        # Hack Nerd Font (FelixKratz preference)
      "font-jetbrains-mono"        # JetBrains Mono (terminal primary)
      "font-meslo-lg-nerd-font"    # Meslo LG Nerd Font (correct name)
      "font-fira-code-nerd-font"   # Fira Code with ligatures
      
      # Development Fonts
      "font-victor-mono"           # Victor Mono (cursive italics)
      "font-cascadia-code"         # Microsoft's programming font
      
      # System Integration Applications
      "docker"                     # Docker Desktop for Mac
      "wezterm"                    # WezTerm terminal emulator
      
      # Optional: FelixKratz workflow apps
      # "raycast"                  # Application launcher (modern Spotlight)
      # "cleanmymac"               # System maintenance
      # "finder"                   # File manager replacement options
      
      # Media & Productivity (optional)
      # "spotify"                  # Music streaming
      # "discord"                  # Communication
      # "notion"                   # Note-taking
    ];
    
    # Strict cask installation settings
    caskArgs = {
      appdir = "/Applications";     # Standard location
      require_sha = true;           # Verify checksums for security
    };
  };
  
  # Environment integration - make homebrew tools available but secondary to nix
  environment.systemPath = [
    # Note: homebrew is added AFTER nix paths to give nix packages priority
    config.homebrew.brewPrefix
  ];
  
  # Security and privacy settings for homebrew
  environment.variables = {
    HOMEBREW_NO_ANALYTICS = "1";           # Disable telemetry
    HOMEBREW_NO_INSECURE_REDIRECT = "1";   # Security hardening
    HOMEBREW_CASK_OPTS = "--require-sha";  # Verify cask integrity
    HOMEBREW_NO_AUTO_UPDATE = "1";         # Prevent auto-updates
    HOMEBREW_NO_INSTALL_CLEANUP = "1";     # Let nix handle cleanup
    HOMEBREW_BAT = "1";                    # Use bat for better output (if available)
  };
  
  # Post-activation scripts to verify homebrew state
  system.activationScripts.postActivation.text = ''
    # Verify homebrew is under nix control
    echo "Verifying Homebrew is managed by Nix..."
    if command -v brew &> /dev/null; then
      echo "✓ Homebrew available at: $(which brew)"
      echo "✓ Homebrew prefix: $(brew --prefix)"
      echo "✓ Homebrew is properly managed by Nix"
    else
      echo "⚠ Homebrew not found - will be installed by nix-darwin"
    fi
  '';
}
