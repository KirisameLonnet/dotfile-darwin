# AI/ML Tools Package Configuration
{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    # Node.js (required for Gemini CLI & Copilot Agent)
    nodejs_22              # Node.js v22 LTS
    github-copilot-cli     # Copilot Agent for @workspace support
    claude-code            # Anthropic Claude Code CLI
    
    # Python AI/ML ecosystem
    python3
    python3Packages.pip
    python3Packages.virtualenv
    python313Packages.uv
  ];
}
