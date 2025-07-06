# System Utilities Package Configuration
{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    # ===== CORE SYSTEM TOOLS =====
    coreutils          # GNU core utilities
    findutils          # GNU find utilities
    gnused             # GNU sed
    gawk               # GNU awk
    gnugrep            # GNU grep

    # ===== ARCHIVE AND COMPRESSION =====
    # Core archive tools moved to main packages.nix

    # ===== SYSTEM MONITORING =====
    htop               # Process viewer
    btop               # Modern system monitor
    fastfetch          # System information tool

    # ===== SECURITY =====
    gnupg              # GPG encryption

    # ===== NIX TOOLS =====
    nix-tree           # Dependency visualization
    home-manager       # Home Manager CLI tool

    # ===== MACOS SPECIFIC =====
    mas                # Mac App Store CLI
    m-cli              # macOS management CLI
  ];
}
