# Unified Package Management
{ config, pkgs, lib, inputs, system, ... }:

{
  # Import all package modules
  imports = [
    ./packages/ai.nix          # AI/ML tools (includes Node.js)
    ./packages/development.nix # Development tools
    ./packages/media.nix       # Media processing tools
    ./packages/network.nix     # Network tools
    ./packages/system.nix      # System utilities
    ./packages/terminal.nix    # Terminal and CLI tools
    ];

  # Core packages that don't fit into specific categories
  home.packages = with pkgs; [
    # Essential utilities
    unzip              # ZIP extractor
    p7zip              # 7-Zip archiver
    inputs.ashpipe.packages.${system}.default
  ];
}
