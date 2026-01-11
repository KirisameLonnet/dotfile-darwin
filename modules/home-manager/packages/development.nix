# Development Tools Package Configuration  
{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    # ===== VERSION CONTROL =====
    git                # Version control system
    gh                 # GitHub CLI  
    lazygit            # Terminal UI for git
    delta              # Better diff

    # ===== BUILD TOOLS =====
    gnumake            # Make build tool
    cmake              # Cross-platform build tool
    pkg-config         # Package configuration
    android-tools      # Android Debug Bridge (ADB)

    # ===== CODE QUALITY =====
    nil                # Nix language server
    nixpkgs-fmt        # Nix formatter
    tokei              # Code statistics

    # ===== TEXT EDITORS =====
    # neovim is configured via programs.neovim in ../editor/nvim.nix
    vim                # Classic vim (compatibility)
    vscode             # Visual Studio Code

    # ===== DATABASE TOOLS =====
    sqlite             # SQLite database

    # ===== NETWORK TOOLS =====
    mitmproxy          # Interactive TUI proxy

    # ===== VIRTUALIZATION =====
    qemu               # Machine emulator and virtualizer
    lima               # Linux virtual machines

    # ===== PROGRAMMING LANGUAGES =====
    rustc              # Rust compiler
    cargo              # Rust package manager
    go                 # Go programming language
    pipx               # Install and run Python applications in isolated environments
  ];
}
