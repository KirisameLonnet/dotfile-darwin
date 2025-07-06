# Terminal and CLI Tools Package Configuration
{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
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

    # ===== NETWORK TOOLS =====
    httpie             # Modern HTTP client
    nmap               # Network discovery
    bandwhich          # Network utilization monitor

    # ===== DATA PROCESSING =====
    jq                 # JSON processor
    yq                 # YAML processor

    # ===== MODERN UNIX ALTERNATIVES =====
    choose             # Human-friendly cut
    sd                 # sed alternative
    procs              # ps alternative
    dust               # du alternative
    hyperfine          # Benchmarking tool
  ];
}
