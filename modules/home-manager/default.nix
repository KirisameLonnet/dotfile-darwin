# Home Manager Configuration
{ config, pkgs, ... }:

{
  imports = [
    ./packages.nix            # Unified package management (includes all package modules)
    ./shell.nix
    ./terminal.nix
    ./development.nix
    ./ui.nix
    ./envdir.nix
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

  home.file.".config/lan-mouse/config.toml".text = ''
    [[clients]]
    position = "left"
    ips = ["192.168.1.176"]
    port = 4242
  '';
}
