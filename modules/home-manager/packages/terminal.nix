# Terminal and CLI Tools Package Configuration
{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    # ===== TERMINAL EMULATORS =====
    # kitty is managed by programs.kitty in ../terminal.nix

    # ===== TERMINAL MULTIPLEXERS =====
    tmux # Terminal multiplexer
    zellij # Modern terminal multiplexer

    # ===== MODERN CLI REPLACEMENTS =====
    eza # Better ls
    bat # Better cat
    ripgrep # Better grep
    fd # Better find
    fzf # Fuzzy finder
    tree # Directory tree viewer

    # ===== FILE MANAGEMENT =====
    yazi # Modern file manager

    # ===== NETWORK TOOLS =====
    httpie # Modern HTTP client
    nmap # Network discovery
    bandwhich # Network utilization monitor

    # ===== DATA PROCESSING =====
    jq # JSON processor
    yq # YAML processor

    # ===== MODERN UNIX ALTERNATIVES =====
    choose # Human-friendly cut
    sd # sed alternative
    procs # ps alternative
    dust # du alternative
    hyperfine # Benchmarking tool
  ];

  programs.nnn = {
    enable = true;
    enableZshIntegration = true;
    quitcd = true;
    bookmarks = {
      d = "~/Documents";
      D = "~/Downloads";
      p = "~/Pictures";
      v = "~/Videos";
      m = "~/Music";
      c = "~/.config";
    };
  };
}
