# Gemini CLI Basic Configuration
{ config, pkgs, ... }:

{
  # Basic shell aliases for Gemini CLI
  programs.zsh.shellAliases = {
    # 主要 Gemini CLI 访问方式
    "gemini" = "npx @google/gemini-cli";
    "gm" = "npx @google/gemini-cli";
    
    # 交互模式
    "gemini-chat" = "npx @google/gemini-cli -i";
  };
}
