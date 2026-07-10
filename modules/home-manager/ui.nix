{ config, pkgs, ... }:

{
  # UI and Interface Configuration
  # Note: Starship is configured in terminal.nix to avoid duplication

  # Window Manager Configuration Files
  home.file.".config/yabai" = {
    source = ../../config/yabai;
    recursive = true;
  };

  home.file.".config/skhd" = {
    source = ../../config/skhd;
    recursive = true;
  };

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

      echo ""
      echo "🔧 Quick Commands:"
      echo "  wm-reload  - Restart window manager services"
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
      launchctl kickstart -k "gui/$UID/org.nixos.yabai"

      # Restart skhd
      echo "⌨️  Restarting skhd..."
      launchctl kickstart -k "gui/$UID/org.nixos.skhd"

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
