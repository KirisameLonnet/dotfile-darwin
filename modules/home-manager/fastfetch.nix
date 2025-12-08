{ config, pkgs, ... }:

{
  programs.fastfetch = {
    enable = true;
    settings = {
      # Use a preset for overall styling
      # Available presets: "catppuccin-mocha", "catppuccin-latte", etc.
      theme = "catppuccin-mocha";

      # Custom ASCII art (NixOS logo)
      # You can replace this with any other ASCII art or set it to "auto"
      logo = {
        type = "ascii";
        source = ''
          ${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg
        '';
        # The Nix snowflake SVG is complex, so we'll use a simpler text-based one
        # for better rendering in the terminal.
        # This is a simplified representation.
        content = ''
          
            
          
        '';
      };
      
      # Configure the modules to display
      modules = [
        # System Info with Icons
        {
          type = "os";
          key = "";
          format = "{1} {2}";
        }
        {
          type = "host";
          key = "󰌢";
          format = "{1} {2}";
        }
        {
          type = "kernel";
          key = "";
          format = "{1} {2}";
        }
        
        # Separator
        "break"
        
        # Status Info
        {
          type = "uptime";
          key = "󰔟";
        }
        {
          type = "packages";
          key = "󰏗";
        }
        {
          type = "shell";
          key = "";
          format = "{2}"; # Show only shell name, not version
        }
        {
          type = "wm";
          key = "󰖲";
          format = "{1}";
        }
        
        # Separator
        "break"
        
        # Hardware Info
        {
          type = "cpu";
          key = "";
          format = "{1} ({5})"; # e.g., Apple M2 (8)
        }
        {
          type = "gpu";
          key = "󰢮";
          format = "{1}";
        }
        {
          type = "memory";
          key = "󰍛";
          format = "{1} / {2} ({3}%)";
        }
        
        # Separator
        "break"
        
        # Colors
        "colors"
      ];
    };
  };
}
