# Home Manager Configuration
{ config, pkgs, ... }:

{
  imports = [
    ./packages.nix
    ./shell.nix
    ./terminal.nix
    ./development.nix
    ./ui.nix
    ./envdir.nix
    ./editor/nvim.nix
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
