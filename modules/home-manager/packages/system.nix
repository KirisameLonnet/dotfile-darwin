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
        # System Utilities
    htop                # Interactive process viewer
    btop                # Modern process viewer
    eza                 # Modern `ls` replacement
    fd                  # Modern `find` replacement
    ripgrep             # Modern `grep` replacement
    fzf                 # Command-line fuzzy finder
    unzip               # For extracting zip files
    jq                  # JSON processor
    
    # Nix specific tools
    nix-output-monitor  # For better nix build logs
    
    # Other
    neofetch            # System information tool (classic)


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
