{ config, pkgs, ... }:

{
  # WezTerm terminal configuration (visually mirrors Alacritty)
  programs.wezterm = {
    enable = true;
    extraConfig = ''
      local wezterm = require 'wezterm'
      local config = {}

      -- Use config_builder if available, otherwise fall back to the config table
      if wezterm.config_builder then
        config = wezterm.config_builder()
      end

      -- Window Configuration (matching Alacritty)
      config.window_decorations = "RESIZE" -- Similar to buttonless, allows resizing
      config.window_background_opacity = 0.8
      config.macos_window_background_blur = 20 -- Similar to Alacritty's blur
      config.window_padding = {
        left = 20,
        right = 20,
        top = 20,
        bottom = 20,
      }
      config.initial_cols = 120
      config.initial_rows = 40
      config.enable_tab_bar = false -- Hides the tab bar for a minimal look

      -- Font Configuration (matching Alacritty)
      config.font = wezterm.font_with_fallback({
        { family = "JetBrainsMono Nerd Font", weight = "Regular" },
        { family = "Apple Color Emoji" }, -- Fallback for emojis
      })
      config.font_size = 14.0

      -- Catppuccin Mocha Color Scheme (matching Alacritty)
      config.colors = {
        background = '#1e1e2e',
        foreground = '#cdd6f4',

        cursor_bg = '#f5e0dc',
        cursor_border = '#f5e0dc',
        cursor_fg = '#1e1e2e',

        selection_bg = '#f5e0dc',
        selection_fg = '#1e1e2e',

        ansi = {
          '#45475a', -- Black
          '#f38ba8', -- Red
          '#a6e3a1', -- Green
          '#f9e2af', -- Yellow
          '#89b4fa', -- Blue
          '#f5c2e7', -- Magenta
          '#94e2d5', -- Cyan
          '#bac2de', -- White
        },
        brights = {
          '#585b70', -- Bright Black
          '#f38ba8', -- Bright Red
          '#a6e3a1', -- Bright Green
          '#f9e2af', -- Bright Yellow
          '#89b4fa', -- Bright Blue
          '#f5c2e7', -- Bright Magenta
          '#94e2d5', -- Bright Cyan
          '#a6adc8', -- Bright White
        },
      }

      -- Cursor Configuration (matching Alacritty)
      config.default_cursor_style = 'BlinkingBlock'
      config.cursor_blink_rate = 500

      -- Scrolling Configuration
      config.scrollback_lines = 10000

      -- Mouse Configuration
      config.hide_mouse_cursor_when_typing = true

      -- Key Bindings (WezTerm uses different defaults, these are for reference)
      -- Most Cmd+C, Cmd+V, etc. work out of the box on macOS.
      -- config.keys = { ... }

      -- Shell Configuration (WezTerm will inherit the default shell from your environment)
      -- config.default_prog = { '${pkgs.zsh}/bin/zsh', '--login' }

      return config
    '';
  };
  
  # Note: Starship prompt is configured in shell.nix to avoid duplication
}

