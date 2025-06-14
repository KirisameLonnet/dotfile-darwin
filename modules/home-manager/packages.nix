# Package Management - Prefer Nix over Homebrew
{ config, pkgs, lib, ... }:

{
  # System packages managed by Nix
  home.packages = with pkgs; [
    # Terminal and CLI Tools
    alacritty          # Terminal emulator (prefer over homebrew cask)
    
    # Development Tools (additional)
    httpie             # Modern HTTP client
    jq                 # JSON processor
    yq                 # YAML processor
    fd                 # Better find
    ripgrep            # Better grep
    eza                # Better ls
    bat                # Better cat
    delta              # Better diff
    tokei              # Code statistics
    vim                # Text editor (Neovim preferred, but vim for compatibility)
    yazi               # Yet another zsh interface (alternative to oh-my-zsh)
    vscode             # Just visual studio code


    # System Monitoring
    htop               # Process viewer
    btop               # Modern system monitor
    bandwhich          # Network utilization by process
    fastfetch          # System information tool (modern neofetch)
    
    # Networking Tools
    nmap               # Network discovery
    wget               # File downloader
    curl               # Data transfer tool
    
    # Archive Tools
    p7zip              # 7-Zip archiver
    unzip              # ZIP extractor
    
    # Media Tools
    ffmpeg             # Media processing
    imagemagick        # Image manipulation
    
    # File Management
    tree               # Directory tree viewer
    fzf                # Fuzzy finder
    nnn                # Minimal file manager (FelixKratz workflow compatible)
    
    # Security
    gnupg              # GPG encryption
    
    # Nix Tools
    nil                # Nix language server
    nixpkgs-fmt        # Nix formatter
    nix-tree           # Dependency visualization
    home-manager       # Home Manager CLI tool
    direnv             # auto change env by .envrc in folder
    nix-direnv         # nix plugin for direnv
    
    # Modern Unix Tools
    choose             # Human-friendly cut
    sd                 # sed alternative
    procs              # ps alternative
    dust               # du alternative
    hyperfine          # Benchmarking tool
  ];
}
