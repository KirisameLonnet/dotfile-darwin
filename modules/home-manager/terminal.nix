{ config, pkgs, ... }:

{
  # Alacritty terminal configuration
  programs.alacritty = {
    enable = true;
    settings = {
      # Window configuration
      window = {
        decorations = "buttonless";
        opacity = 0.8;
        blur = true;
        option_as_alt = "Both";
        padding = {
          x = 20;
          y = 20;
        };
        dimensions = {
          columns = 120;
          lines = 40;
        };
      };
      
      # Font configuration - using nix-managed fonts
      font = {
        normal = {
          family = "JetBrainsMono Nerd Font";
          style = "Regular";
        };
        bold = {
          family = "JetBrainsMono Nerd Font";
          style = "Bold";
        };
        italic = {
          family = "JetBrainsMono Nerd Font";
          style = "Italic";
        };
        size = 14.0;
      };
      
      # Catppuccin Mocha color scheme
      colors = {
        primary = {
          background = "#1e1e2e";
          foreground = "#cdd6f4";
          dim_foreground = "#7f849c";
          bright_foreground = "#cdd6f4";
        };
        
        cursor = {
          text = "#1e1e2e";
          cursor = "#f5e0dc";
        };
        
        vi_mode_cursor = {
          text = "#1e1e2e";
          cursor = "#b4befe";
        };
        
        search = {
          matches = {
            foreground = "#1e1e2e";
            background = "#a6adc8";
          };
          focused_match = {
            foreground = "#1e1e2e";
            background = "#a6e3a1";
          };
        };
        
        footer_bar = {
          foreground = "#1e1e2e";
          background = "#a6adc8";
        };
        
        hints = {
          start = {
            foreground = "#1e1e2e";
            background = "#f9e2af";
          };
          end = {
            foreground = "#1e1e2e";
            background = "#a6adc8";
          };
        };
        
        selection = {
          text = "#1e1e2e";
          background = "#f5e0dc";
        };
        
        normal = {
          black = "#45475a";
          red = "#f38ba8";
          green = "#a6e3a1";
          yellow = "#f9e2af";
          blue = "#89b4fa";
          magenta = "#f5c2e7";
          cyan = "#94e2d5";
          white = "#bac2de";
        };
        
        bright = {
          black = "#585b70";
          red = "#f38ba8";
          green = "#a6e3a1";
          yellow = "#f9e2af";
          blue = "#89b4fa";
          magenta = "#f5c2e7";
          cyan = "#94e2d5";
          white = "#a6adc8";
        };
        
        dim = {
          black = "#45475a";
          red = "#f38ba8";
          green = "#a6e3a1";
          yellow = "#f9e2af";
          blue = "#89b4fa";
          magenta = "#f5c2e7";
          cyan = "#94e2d5";
          white = "#bac2de";
        };
      };
      
      # Cursor configuration
      cursor = {
        style = {
          shape = "Block";
          blinking = "On";
        };
        blink_interval = 500;
        unfocused_hollow = true;
      };
      
      # Scrolling
      scrolling = {
        history = 10000;
        multiplier = 3;
      };
      
      # Mouse
      mouse = {
        hide_when_typing = true;
      };
      
      # Key bindings
      keyboard.bindings = [
        { key = "V"; mods = "Command"; action = "Paste"; }
        { key = "C"; mods = "Command"; action = "Copy"; }
        { key = "Q"; mods = "Command"; action = "Quit"; }
        { key = "N"; mods = "Command"; action = "SpawnNewInstance"; }
        { key = "Return"; mods = "Command"; action = "ToggleFullscreen"; }
        
        # Vi mode bindings
        { key = "Space"; mods = "Shift|Control"; action = "ToggleViMode"; }
        { key = "Escape"; action = "ClearLogNotice"; }
        { key = "Escape"; mode = "Vi"; action = "ClearSelection"; }
        
        # Search
        { key = "F"; mods = "Command"; action = "SearchForward"; }
        { key = "B"; mods = "Command"; action = "SearchBackward"; }
      ];
      
      # General configuration
      general = {
        live_config_reload = true;
      };
      
      # Terminal shell configuration
      terminal = {
        shell = {
          program = "${pkgs.zsh}/bin/zsh";
          args = [ "--login" ];
        };
      };
    };
  };
  
  # Note: Starship prompt is configured in shell.nix to avoid duplication
}

