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
    # Note: vim and curl are managed by home-manager packages
    # Note: Window management tools (yabai, skhd) are defined in window-manager.nix
  ];

}
