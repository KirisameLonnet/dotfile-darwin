{ config, pkgs, ... }:

{
  # Enable the fastfetch program itself
  programs.fastfetch.enable = true;

  # Use home.file to link the configuration files declaratively.
  # This ensures that both the config and the logo it refers to are in place.
  home.file = {
    ".config/fastfetch/config.jsonc" = {
      source = ../../config/fastfetch/config.jsonc;
    };
    ".config/fastfetch/logo.png" = {
      source = ../../config/fastfetch/logo.png;
    };
  };
}
