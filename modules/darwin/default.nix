{ config, pkgs, lib, ... }:

{
  imports = [
    ./system.nix
    ./fonts.nix
    ./homebrew.nix
    ./window-manager.nix
  ];

  # Basic system packages - Only essential system-level packages
  environment.systemPackages = with pkgs; [
    # Core system utilities (needed for nix-darwin functionality)
    vim                # Basic editor
    curl               # System network tool
    
    # Note: Window management tools (yabai, skhd) are defined in window-manager.nix
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
