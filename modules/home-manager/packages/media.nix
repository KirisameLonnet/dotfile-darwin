# Media Processing Tools Package Configuration
{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    # ===== IMAGE PROCESSING =====
    imagemagick        # Image manipulation

    # ===== VIDEO/AUDIO PROCESSING =====
    ffmpeg             # Media processing

  ];
}
