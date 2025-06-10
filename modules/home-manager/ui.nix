{ config, pkgs, ... }:

{
  # SketchyBar configuration with SbarLua support - DISABLED
  # home.file.".config/sketchybar/init.lua" = {
  #   source = ../../config/sketchybar/init.lua;
  #   executable = true;
  # };
  
  # home.file.".config/sketchybar/sketchybarrc" = {
  #   source = ../../config/sketchybar/sketchybarrc;
  #   executable = true;
  # };
  
  # home.file.".config/sketchybar/colors" = {
  #   source = ../../config/sketchybar/colors;
  #   recursive = true;
  #   executable = true;
  # };
  
  # home.file.".config/sketchybar/items" = {
  #   source = ../../config/sketchybar/items;
  #   recursive = true;
  #   executable = true;
  # };
  
  # home.file.".config/sketchybar/plugins" = {
  #   source = ../../config/sketchybar/plugins;
  #   recursive = true;
  #   executable = true;
  # };

  # Yabai configuration
  home.file.".config/yabai/yabairc" = {
    source = ../../config/yabai/yabairc;
    executable = true;
  };

  # skhd configuration  
  home.file.".config/skhd/skhdrc" = {
    source = ../../config/skhd/skhdrc;
    executable = true;
  };

  # Finder Go To Folder script (managed by nix)
  home.file.".config/skhd/finder-goto.sh" = {
    text = ''
      #!/bin/bash
      # Finder Go To Folder script - managed by home-manager
      /usr/bin/osascript -e 'tell application "Finder" to activate' -e 'delay 0.2' -e 'tell application "System Events" to keystroke "g" using {command down, shift down}'
    '';
    executable = true;
  };

  # JankyBorders configuration (FelixKratz window decorations)
  home.file.".config/borders/bordersrc" = {
    source = ../../config/borders/bordersrc;
    executable = true;
  };

  # fnnn configuration (FelixKratz's custom nnn)
  home.file.".config/fnnn/config.sh" = {
    source = ../../config/fnnn/config.sh;
    executable = true;
  };

  # Create necessary directories
  # home.file.".config/sketchybar/.keep".text = "";  # DISABLED
  home.file.".config/yabai/.keep".text = "";
  home.file.".config/skhd/.keep".text = "";
  home.file.".config/borders/.keep".text = "";
  home.file.".config/fnnn/.keep".text = "";

  # System management scripts (managed by nix)
  home.file.".local/bin/wm-status" = {
    text = ''
      #!/bin/bash
      # Window manager status check - managed by home-manager
      echo "🪟 Window Manager Status"
      echo "======================="
      
      # Check yabai
      if pgrep -x yabai > /dev/null; then
          echo "✅ yabai: Running (PID: $(pgrep -x yabai))"
      else
          echo "❌ yabai: Not running"
      fi
      
      # Check skhd
      if pgrep -x skhd > /dev/null; then
          echo "✅ skhd: Running (PID: $(pgrep -x skhd))"
      else
          echo "❌ skhd: Not running"
      fi
      
      # Check border
      if pgrep -x borders > /dev/null; then
          echo "✅ borders: Running (PID: $(pgrep -x borders))"
      else
          echo "❌ borders: Not running"
      fi
      
      echo ""
      echo "🔧 Quick Commands:"
      echo "  wm-reload  - Restart window manager services"
      echo "  yconfig    - Show yabai configuration"
    '';
    executable = true;
  };

  home.file.".local/bin/wm-reload" = {
    text = ''
      #!/bin/bash
      # Window manager reload script - managed by home-manager
      echo "🔄 Reloading window manager services..."
      
      # Restart yabai
      echo "🪟 Restarting yabai..."
      yabai --restart-service
      
      # Restart skhd
      echo "⌨️  Restarting skhd..."
      skhd --restart-service
      
      # Wait a moment
      sleep 2
      
      # Check status
      if pgrep -x yabai > /dev/null && pgrep -x skhd > /dev/null; then
          echo "✅ Services reloaded successfully!"
      else
          echo "❌ Some services failed to restart"
      fi
    '';
    executable = true;
  };
}
