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

    # ===== PROGRAMMING LANGUAGES =====
    rustc              # Rust compiler
    cargo              # Rust package manager
    go                 # Go programming language
  ];
}
