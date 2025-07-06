# Unified Package Management
{ config, pkgs, lib, ... }:

{
  # Import all package modules
  imports = [
    ./packages/ai.nix          # AI/ML tools (includes Node.js)
    ./packages/development.nix # Development tools
    ./packages/media.nix       # Media processing tools
    ./packages/system.nix      # System utilities
    ./packages/terminal.nix    # Terminal and CLI tools
  ];

  # Core packages that don't fit into specific categories
  home.packages = with pkgs; [
    # Essential utilities
    curl               # Data transfer tool
    wget               # File downloader
    unzip              # ZIP extractor
    p7zip              # 7-Zip archiver
  ];
}
