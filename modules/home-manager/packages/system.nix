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
    libxkbcommon       # XKB keymap handling library

    # ===== ARCHIVE AND COMPRESSION =====
    # Core archive tools moved to main packages.nix

    # ===== SYSTEM MONITORING =====
    htop                # Interactive process viewer
    btop                # Modern process viewer
    
    # Nix specific tools
    nix-output-monitor  # For better nix build logs
    
    # Other
    fastfetch           # System information tool (modern neofetch replacement)
    cava

    # ===== SECURITY =====
    gnupg              # GPG encryption

    # ===== NIX TOOLS =====
    nix-tree           # Dependency visualization

    # ===== MACOS SPECIFIC =====
    mas                # Mac App Store CLI
    m-cli              # macOS management CLI
];
}
