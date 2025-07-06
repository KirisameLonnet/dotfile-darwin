# AI/ML Tools Package Configuration
{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    # Node.js (required for Gemini CLI & Copilot Agent)
    nodejs_20              # LTS Node.js
    gh-copilot             # Copilot Agent for @workspace support
    
    # Python AI/ML ecosystem
    python3
    python3Packages.pip
    python3Packages.virtualenv
    python3Packages.numpy
    python3Packages.pandas
  ];
}