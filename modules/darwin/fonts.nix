{ config, pkgs, ... }:

{
  # Fonts managed by nix instead of homebrew
  fonts.packages = with pkgs; [
    # Nerd Fonts - comprehensive programming fonts
    nerd-fonts.hack
    nerd-fonts.jetbrains-mono
    nerd-fonts.fira-code
    nerd-fonts.meslo-lg
    nerd-fonts.iosevka
    nerd-fonts.victor-mono
    
    # Additional useful fonts
    font-awesome
    inter
    roboto
    source-code-pro
    
    # Apple fonts (if available)
    # sf-pro - Usually comes with macOS
  ];
}
