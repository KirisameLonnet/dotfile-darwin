# Home Manager Configuration
{ config, pkgs, ... }:

{
  imports = [
    ./packages.nix            # Unified package management (includes all package modules)
    ./shell.nix
    ./terminal.nix
    ./development.nix
    ./ait.nix # ait-app/ait nightly, activation + daily update
    ./ui.nix
    ./envdir.nix
    ./default-apps.nix # Default app associations (VLC for media)
    ./editor/nvim.nix
    ./fastfetch.nix           # Custom fastfetch configuration
  ];

  # Basic home manager configuration
  home = {
    username = "lonnetkirisame";
    homeDirectory = "/Users/lonnetkirisame";
    stateVersion = "24.05";
  };

  # Let Home Manager install and manage itself
  programs.home-manager.enable = true;
}
