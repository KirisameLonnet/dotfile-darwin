{ config, pkgs, ... }:

{
  # Kitty terminal configuration (modern, fast, GPU-accelerated)
  programs.kitty = {
    enable = true;
    font = {
      name = "JetBrainsMono Nerd Font";
      size = 14;
    };
    settings = {
      # Performance
      input_delay = 0;
      repaint_delay = 8;
      sync_to_monitor = "yes";

      # Window Configuration
      window_padding_width = 20;
      background_opacity = "0.8";
      dynamic_background_opacity = "yes";
      macos_titlebar_color = "background";
      hide_window_decorations = "titlebar-only";

      # Tab Bar
      tab_bar_min_tabs = 2;
      tab_bar_style = "fade";

      # Background Blur (MacOS)
      background_blur = 32;

      # Cursor
      cursor_shape = "block";
      cursor_blink_interval = "0.5";
      # Smooth Cursor / Cursor Trail (requires Kitty 0.35+)
      cursor_trail = 1;
      cursor_trail_decay = "0.1 0.4";
      cursor_trail_start_threshold = 2;

      # Mouse
      focus_follows_mouse = "no";
      mouse_hide_wait = "3.0";

      # Colors (Catppuccin Mocha)
      background = "#1e1e2e";
      foreground = "#cdd6f4";
      selection_background = "#f5e0dc";
      selection_foreground = "#1e1e2e";
      cursor = "#f5e0dc";
      cursor_text_color = "#1e1e2e";

      # black
      color0 = "#45475a";
      color8 = "#585b70";
      # red
      color1 = "#f38ba8";
      color9 = "#f38ba8";
      # green
      color2 = "#a6e3a1";
      color10 = "#a6e3a1";
      # yellow
      color3 = "#f9e2af";
      color11 = "#f9e2af";
      # blue
      color4 = "#89b4fa";
      color12 = "#89b4fa";
      # magenta
      color5 = "#f5c2e7";
      color13 = "#f5c2e7";
      # cyan
      color6 = "#94e2d5";
      color14 = "#94e2d5";
      # white
      color7 = "#bac2de";
      color15 = "#a6adc8";
    };
    extraConfig = ''
      # MacOS specific
      macos_option_as_alt yes
      macos_quit_when_last_window_closed yes
    '';
  };
  
  # Note: Starship prompt is configured in shell.nix to avoid duplication
}
