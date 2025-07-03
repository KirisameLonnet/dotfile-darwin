# Unified Package Management
{ config, pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    # ===== CORE SYSTEM TOOLS =====
    coreutils          # GNU core utilities
    findutils          # GNU find utilities
    gnused             # GNU sed
    gawk               # GNU awk
    gnugrep            # GNU grep
    
    # ===== TERMINAL EMULATORS =====
    alacritty          # GPU-accelerated terminal
    
    # ===== TERMINAL MULTIPLEXERS =====
    tmux               # Terminal multiplexer
    zellij             # Modern terminal multiplexer
    
    # ===== MODERN CLI REPLACEMENTS =====
    eza                # Better ls
    bat                # Better cat
    ripgrep            # Better grep
    fd                 # Better find
    fzf                # Fuzzy finder
    tree               # Directory tree viewer
    
    # ===== FILE MANAGEMENT =====
    nnn                # Minimal file manager
    yazi               # Modern file manager
    
    # ===== ARCHIVE AND COMPRESSION =====
    unzip              # ZIP extractor
    p7zip              # 7-Zip archiver
    
    # ===== NETWORK TOOLS =====
    curl               # Data transfer tool
    wget               # File downloader
    httpie             # Modern HTTP client
    nmap               # Network discovery
    bandwhich          # Network utilization monitor
    
    # ===== DATA PROCESSING =====
    jq                 # JSON processor
    yq                 # YAML processor
    
    # ===== PROGRAMMING LANGUAGES =====
    nodejs             # JavaScript runtime
    python3            # Python interpreter
    rustc              # Rust compiler
    cargo              # Rust package manager
    go                 # Go programming language
    
    # ===== VERSION CONTROL =====
    git                # Version control system
    gh                 # GitHub CLI
    lazygit            # Terminal UI for git
    delta              # Better diff
    
    # ===== TEXT EDITORS =====
    # neovim is configured via programs.neovim in editor/nvim.nix
    vim                # Classic vim (compatibility)
    vscode             # Visual Studio Code
    
    # ===== BUILD TOOLS =====
    gnumake            # Make build tool
    cmake              # Cross-platform build tool
    pkg-config         # Package configuration
    
    # ===== PYTHON PACKAGES =====
    python3Packages.pip
    python3Packages.virtualenv
    
    # ===== DATABASE TOOLS =====
    sqlite             # SQLite database
    
    # ===== CODE QUALITY =====
    nil                # Nix language server
    nixpkgs-fmt        # Nix formatter
    tokei              # Code statistics
    
    # ===== SYSTEM MONITORING =====
    htop               # Process viewer
    btop               # Modern system monitor
    fastfetch          # System information tool
    
    # ===== SECURITY =====
    gnupg              # GPG encryption
    
    # ===== NIX TOOLS =====
    nix-tree           # Dependency visualization
    home-manager       # Home Manager CLI tool
    
    # ===== MODERN UNIX ALTERNATIVES =====
    choose             # Human-friendly cut
    sd                 # sed alternative
    procs              # ps alternative
    dust               # du alternative
    hyperfine          # Benchmarking tool
    
    # ===== MEDIA TOOLS =====
    imagemagick        # Image manipulation
    ffmpeg             # Media processing
    
    # ===== AI/ML TOOLS =====
    nodejs             # Required for Gemini CLI (Node.js 18+)
    # Note: Gemini CLI is installed globally via npm: npm install -g @google/gemini-cli
    
    # ===== MACOS SPECIFIC =====
    mas                # Mac App Store CLI
    m-cli              # macOS management CLI
  ];
}
