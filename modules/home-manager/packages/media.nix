# Media Processing Tools Package Configuration
{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    # ===== IMAGE PROCESSING =====
    imagemagick        # Image manipulation

    # ===== VIDEO/AUDIO PROCESSING =====
    ffmpeg             # Media processing

    # ===== COMMUNICATION =====
    # vesktop         # Discord alternative (moved to Homebrew cask for stable app path)

  ];
}
