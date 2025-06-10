{ config, pkgs, ... }:

# ============================================================================
# YABAI WINDOW ANIMATION FIX DOCUMENTATION
# ============================================================================
# 
# PROBLEM: Window move animations were not working despite focus animations working
# ROOT CAUSE: Configuration inconsistency between yabairc and nix-darwin configs
# 
# 
# FIXES APPLIED:
# 1. Unified animation settings between config/yabai/yabairc and this file
# 2. Removed unsupported option: window_animation_frame_rate (not in yabai API)
# 3. Synchronized padding/gap values: both configs now use 8px consistently  
# 4. Added proper animation easing: ease_out_quint for smooth macOS-like motion
# 5. Increased animation duration: 0.2s → 0.35s for macOS standard feel
# 6. Slower opacity transitions: 0.15s → 0.25s for better visual feedback
#
# VERIFICATION: 
# - yabai -m config window_animation_duration → should return 0.35
# - yabai -m config window_animation_easing → should return ease_out_quint
# - Window swap/move operations should now show smooth animations
#
# MAINTENANCE: Keep yabairc and this nix config synchronized for animations
# ============================================================================

{
  # Window management tools - all built from nix instead of homebrew
  environment.systemPackages = with pkgs; [
    yabai              # Tiling window manager
    skhd               # Simple hotkey daemon
    # borders can be built from source if needed
  ];

  # Enable yabai and skhd services
  services = {
    yabai = {
      enable = true;
      package = pkgs.yabai;
      config = {
        # Layout settings
        layout = "bsp";
        auto_balance = "off";
        split_ratio = 0.50;
        split_type = "auto";
        window_placement = "second_child";
        
        # Appearance
        window_border = "on";
        window_border_width = 2;
        active_window_border_color = "0xff89b4fa"; # Catppuccin blue
        normal_window_border_color = "0xff45475a"; # Catppuccin surface1
        window_border_radius = 12;
        window_shadow = "on";
        
        # Animation and opacity with enhanced effects
        # NOTE: Fixed window animation issues by ensuring consistency between
        # yabairc and nix-darwin configurations. Key fixes:
        # 1. Unified animation duration settings across both configs
        # 2. Removed unsupported options like window_animation_frame_rate  
        # 3. Added proper easing curves for smooth macOS-like animations
        # 4. Ensured window_gap and padding values match between configs
        # 5. Enhanced transparency: non-focus windows at 0.75 with blur for better visual distinction
        window_animation_duration = 0.35;     # Slower for macOS-like feel (was 0.2)
        window_animation_easing = "ease_out_quint";  # Smooth macOS-style easing
        window_opacity_duration = 0.25;       # Slower opacity transitions (was 0.15)
        active_window_opacity = 1.0;          # Fully opaque focused window
        normal_window_opacity = 0.75;         # Moderate transparency for non-focus windows with blur
        window_opacity = "on";                # Enable opacity effects
        
        # Mouse behavior
        mouse_follows_focus = "off";
        focus_follows_mouse = "off";
        mouse_modifier = "alt";
        mouse_action1 = "move";
        mouse_action2 = "resize";
        mouse_drop_action = "swap";
        
        # Enhanced padding and gaps optimized for 3K screen - SketchyBar integration DISABLED
        top_padding = 8;      # Reduced top padding for better space utilization
        bottom_padding = 8;   # Consistent bottom spacing
        left_padding = 8;     # Consistent side margins
        right_padding = 8;    # Consistent side margins  
        window_gap = 8;       # Consistent gap for visual separation
      };
      
      extraConfig = ''
        # Load scripting addition for advanced functionality
        sudo yabai --load-sa
        yabai -m signal --add event=dock_did_restart action="sudo yabai --load-sa"

        # Window rules for system apps
        yabai -m rule --add app="^System Preferences$" manage=off
        yabai -m rule --add app="^System Settings$" manage=off
        yabai -m rule --add app="^Archive Utility$" manage=off
        yabai -m rule --add app="^Finder$" manage=off
        yabai -m rule --add app="^Activity Monitor$" manage=off
        yabai -m rule --add app="^Calculator$" manage=off
        yabai -m rule --add app="^Digital Colormeter$" manage=off
        yabai -m rule --add app="^System Information$" manage=off
        yabai -m rule --add app="^App Store$" manage=off
        yabai -m rule --add app="^Raycast$" manage=off
        yabai -m rule --add app="^Alfred$" manage=off
        yabai -m rule --add app="^1Password.*$" manage=off
        yabai -m rule --add app="^Karabiner-.*$" manage=off
        yabai -m rule --add app="^CleanMyMac.*$" manage=off
        yabai -m rule --add app="^Disk Utility$" manage=off
        yabai -m rule --add app="^Console$" manage=off
        yabai -m rule --add app="^Audio MIDI Setup$" manage=off
        yabai -m rule --add app="^Wireless Diagnostics$" manage=off
        
        # Finder specific rules for floating windows
        yabai -m rule --add app="^Finder$" title="^Go to.*" manage=off
        yabai -m rule --add app="^Finder$" title="^Connect to.*" manage=off
        yabai -m rule --add app="^Finder$" title="^Copy$" manage=off
        yabai -m rule --add app="^Finder$" title="^Move$" manage=off
        yabai -m rule --add app="^Finder$" title="^Delete$" manage=off
        yabai -m rule --add app="^Finder$" title="^Info$" manage=off
        yabai -m rule --add app="^Finder$" title=".*Info$" manage=off
        
        # Productivity apps - manage these
        yabai -m rule --add app="^Alacritty$" manage=on
        yabai -m rule --add app="^iTerm2$" manage=on
        yabai -m rule --add app="^Code$" manage=on
        yabai -m rule --add app="^Zed$" manage=on
        yabai -m rule --add app="^Cursor$" manage=on
        yabai -m rule --add app="^Firefox$" manage=on
        yabai -m rule --add app="^Safari$" manage=on
        yabai -m rule --add app="^Google Chrome$" manage=on
        yabai -m rule --add app="^Arc$" manage=on
        
        # Signals for SketchyBar integration - DISABLED
        # yabai -m signal --add event=window_focused action="sketchybar --trigger window_focus"
        # yabai -m signal --add event=window_created action="sketchybar --trigger windows_on_spaces"
        # yabai -m signal --add event=window_destroyed action="sketchybar --trigger windows_on_spaces"
        # yabai -m signal --add event=window_moved action="sketchybar --trigger windows_on_spaces"
        # yabai -m signal --add event=space_changed action="sketchybar --trigger space_change"
        # yabai -m signal --add event=display_added action="sketchybar --trigger display_change"
        # yabai -m signal --add event=display_removed action="sketchybar --trigger display_change"
        
        echo "yabai configuration loaded via nix-darwin.."
      '';
    };

    skhd = {
      enable = true;
      package = pkgs.skhd;
      skhdConfig = builtins.readFile ../../config/skhd/skhdrc;
    };
  };

  # LaunchAgents for user session services  
  launchd.agents = {
    skhd = {
      serviceConfig = {
        ProgramArguments = [ "${pkgs.skhd}/bin/skhd" "-c" "/etc/skhdrc" ];
        KeepAlive = true;
        RunAtLoad = true;
        ProcessType = "Interactive";
        StandardOutPath = "/tmp/skhd.out.log";
        StandardErrorPath = "/tmp/skhd.err.log";
        EnvironmentVariables = {
          PATH = "${pkgs.skhd}/bin:${config.environment.systemPath}";
        };
      };
    };
  };

  # Post-activation script to ensure services start correctly
  system.activationScripts.postActivation.text = ''
    # Ensure yabai has necessary permissions and starts correctly
    if command -v yabai >/dev/null 2>&1; then
      echo "yabai found, ensuring proper configuration..."
      # Kill any existing yabai processes to prevent conflicts
      pkill -f yabai || true
      sleep 1
    fi
    
    # Ensure skhd starts correctly
    if command -v skhd >/dev/null 2>&1; then
      echo "skhd found, ensuring proper configuration..."
      # Kill any existing skhd processes to prevent conflicts
      pkill -f skhd || true
      sleep 1
    fi
    
    echo "Window manager services configured for nix-darwin management"
  '';

  # Enhanced window management defaults
  system.defaults = {
    WindowManager = {
      EnableStandardClickToShowDesktop = false;
      StandardHideDesktopIcons = true;
      HideDesktop = true;
      StageManagerHideWidgets = true;
      GloballyEnabled = false;
    };
    
    spaces = {
      spans-displays = false;
    };

    # Custom app-specific settings to hide titles
    universalaccess = {
      reduceMotion = false; # Keep animations enabled
      reduceTransparency = false; # Keep transparency effects
    };
  };
}
