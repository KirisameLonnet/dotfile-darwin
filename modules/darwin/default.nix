{ config, pkgs, lib, ... }:

{
  imports = [
    ./system.nix
    ./fonts.nix
    ./homebrew.nix
    ./window-manager.nix
  ];

  # Basic system packages - prioritize Nix over Homebrew
  environment.systemPackages = with pkgs; [
    # Core utilities
    vim
    git
    curl
    wget
    tree
    htop
    jq
    ripgrep
    fd
    eza
    bat
    fzf
    gh
    
    # Development
    nodejs
    python3
    rustc
    cargo
    go
    
    # Window management
    yabai
    skhd
    
    # System tools
    mas # Mac App Store CLI
    coreutils
    findutils
    gnused
    gawk
    gnugrep
    
    # Media tools
    imagemagick
    ffmpeg
    
    # Network tools
    httpie
    
    # Archive tools
    unzip
    p7zip
  ];

  # Minimal Homebrew usage - only for packages that absolutely need it
  homebrew = {
    enable = true;
    onActivation = {
      cleanup = "zap";
      autoUpdate = false; # Let Nix manage updates
      upgrade = false;
    };
    
    # Only packages that can't be built with Nix or need system integration
    taps = [
      # "FelixKratz/formulae" # For SketchyBar - DISABLED
    ];
    
    brews = [
      # "sketchybar" # Currently requires Homebrew for proper integration - DISABLED
      "nowplaying-cli" # For media information
      "switchaudio-osx" # For audio control
    ];
    
    casks = [
      # "sf-symbols" # Required by SketchyBar for icons - DISABLED
      # Optional: Add applications that benefit from Homebrew cask integration
      # "raycast"
      # "alacritty" # Can be managed by Nix, but cask version has better integration
    ];
  };
}
