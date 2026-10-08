# Network Tools Package Configuration
{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    # ===== TRANSFER =====
    curl               # Data transfer tool
    wget               # File downloader

    # ===== REMOTE ACCESS =====
    mosh               # Roaming-friendly SSH replacement
    sshfs              # SSH filesystem
    sshs               # TUI host picker over ~/.ssh/config

    # ===== HTTP CLIENTS =====
    httpie             # Modern HTTP client

    # ===== DIAGNOSTICS =====
    nmap               # Network discovery
    nexttrace          # Visual traceroute
    bandwhich          # Network utilization monitor

    # ===== CELLULAR / WWAN =====
    (pkgs.callPackage ../../../packages/wwan-manager.nix { }) # WWAN/PPP GUI
  ];
}
