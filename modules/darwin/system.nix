{ config, pkgs, ... }:

{
  # Disable nix-darwin's Nix management for Determinate Nix compatibility
  nix.enable = false;

  # Necessary for using flakes on this system.
  nix.settings.experimental-features = "nix-command flakes";

  # Create /etc/zshrc that loads the nix-darwin environment.
  programs.zsh.enable = true;

  # Used for backwards compatibility
  system.stateVersion = 5;

  # The platform the configuration will be used on.
  nixpkgs.hostPlatform = "aarch64-darwin";

  # Users and primary user setting
  users.users.lonnetkirisame = {
    name = "lonnetkirisame";
    home = "/Users/lonnetkirisame";
  };
  
  # Set primary user for system preferences
  system.primaryUser = "lonnetkirisame";

  # Environment variables
  environment.variables = {
    EDITOR = "vim";
    VISUAL = "vim";
    GIT_EDITOR = "vim";
  };

  # System preferences
  system.defaults = {
    dock = {
      autohide = true;
      autohide-delay = 0.3;           # Slower dock appearance for elegance
      autohide-time-modifier = 1.0;   # Standard macOS dock animation speed
      mru-spaces = false;
      orientation = "bottom";
      showhidden = true;
      show-recents = false;
      tilesize = 48;
      # Enhanced dock animations - synchronized with yabai timing
      expose-animation-duration = 0.35; # Match yabai window animation duration
      minimize-to-application = true;
      mineffect = "genie";             # Classic genie effect
      show-process-indicators = true;
      static-only = false;
      # Dock appearance tweaks
      magnification = false;           # Disable magnification for consistency
      largesize = 64;                  # Size when magnified (if enabled)
    };

    finder = {
      AppleShowAllExtensions = true;
      AppleShowAllFiles = true;
      CreateDesktop = false;
      FXDefaultSearchScope = "SCcf";
      FXEnableExtensionChangeWarning = false;
      QuitMenuItem = true;
      ShowPathbar = true;
      ShowStatusBar = true;
    };

    loginwindow = {
      GuestEnabled = false;
      SHOWFULLNAME = false;  # Show user avatars instead of requiring username input  
      DisableConsoleAccess = true;
    };

    menuExtraClock = {
      Show24Hour = true;
      ShowAMPM = false;
      ShowDate = 0;
      ShowDayOfMonth = true;
      ShowDayOfWeek = true;
      ShowSeconds = false;
    };

    NSGlobalDomain = {
      AppleInterfaceStyle = "Dark";
      AppleKeyboardUIMode = 3;
      ApplePressAndHoldEnabled = false;
      KeyRepeat = 2;
      InitialKeyRepeat = 15;
      NSAutomaticCapitalizationEnabled = false;
      NSAutomaticDashSubstitutionEnabled = false;
      NSAutomaticPeriodSubstitutionEnabled = false;
      NSAutomaticQuoteSubstitutionEnabled = false;
      NSAutomaticSpellingCorrectionEnabled = false;
      NSDocumentSaveNewDocumentsToCloud = false;
      NSNavPanelExpandedStateForSaveMode = true;
      NSNavPanelExpandedStateForSaveMode2 = true;
      PMPrintingExpandedStateForPrint = true;
      PMPrintingExpandedStateForPrint2 = true;
      
      # Enhanced animation settings for smoother UI
      NSWindowResizeTime = 0.15;           # Faster window resize animations
      NSAutomaticWindowAnimationsEnabled = true;  # Enable window animations
      NSScrollAnimationEnabled = true;     # Smooth scrolling animations
      
      # Enhanced native animations and transitions
      NSUseAnimatedFocusRing = true;       # Animated focus rings
      
      # Native gesture and navigation support
      AppleEnableSwipeNavigateWithScrolls = true;        # Two finger swipe navigation
      AppleEnableMouseSwipeNavigateWithScrolls = true;   # Mouse swipe navigation
      AppleSpacesSwitchOnActivate = false; # Don't auto-switch spaces when activating apps
      
      # Enhanced transparency and blur settings for better window distinction
      NSWindowShouldDragOnGesture = true;  # Enable window dragging gestures
      NSDisableAutomaticTermination = true; # Prevent automatic app termination
    };

    # Hide menu bar automatically - DISABLED (SketchyBar removed)
    # NSGlobalDomain._HIHideMenuBar = true;

    screencapture = {
      location = "~/Pictures/Screenshots";
      type = "png";
    };

    trackpad = {
      ActuationStrength = 1;               # Normal force click strength
      Clicking = true;                     # Tap to click
      FirstClickThreshold = 1;             # Click sensitivity
      SecondClickThreshold = 1;            # Force click sensitivity  
      TrackpadRightClick = true;           # Two finger right click
      TrackpadThreeFingerDrag = false;     # Disable to avoid gesture conflicts
    };

    # Universal access settings to ensure transparency and blur effects work
    universalaccess = {
      reduceMotion = false;        # Keep animations enabled for smooth transitions
      reduceTransparency = false;  # Critical: Keep transparency enabled for window blur
      closeViewScrollWheelToggle = false; # Disable zoom scroll toggle
      mouseDriverCursorSize = 1.0; # Standard cursor size
    };
  };

  # Keyboard configuration with enhanced features
  system.keyboard = {
    enableKeyMapping = true;
    # Configure CapsLock for input method switching instead of Escape
    remapCapsLockToControl = false;
    remapCapsLockToEscape = false;
    # CapsLock will be configured for input switching via custom settings
  };

  # Security - updated option name
  security.pam.services.sudo_local.touchIdAuth = true;

  # System activation script for configurations that nix-darwin doesn't support
  system.activationScripts.postActivation.text = ''
    # Configure native macOS trackpad gestures for the primary user
    # These settings are not directly supported by nix-darwin, so we set them via defaults
    echo "Configuring native macOS trackpad gestures..."
    
    # Get the primary user's information
    PRIMARY_USER="lonnetkirisame"
    if id "$PRIMARY_USER" >/dev/null 2>&1; then
      # Configure Dock gesture settings (four finger gestures only)
      sudo -u "$PRIMARY_USER" defaults write com.apple.dock showMissionControlGestureEnabled -bool true
      sudo -u "$PRIMARY_USER" defaults write com.apple.dock showAppExposeGestureEnabled -bool true
      sudo -u "$PRIMARY_USER" defaults write com.apple.dock showLaunchpadGestureEnabled -bool true
      sudo -u "$PRIMARY_USER" defaults write com.apple.dock showDesktopGestureEnabled -bool true
      
      # Configure multitouch trackpad gestures
      # Four finger gestures for window management
      sudo -u "$PRIMARY_USER" defaults write com.apple.AppleMultitouchTrackpad TrackpadFourFingerVertSwipeGesture -int 2
      sudo -u "$PRIMARY_USER" defaults write com.apple.AppleMultitouchTrackpad TrackpadFourFingerHorizSwipeGesture -int 2
      sudo -u "$PRIMARY_USER" defaults write com.apple.AppleMultitouchTrackpad TrackpadFourFingerPinchGesture -int 2
      sudo -u "$PRIMARY_USER" defaults write com.apple.AppleMultitouchTrackpad TrackpadFiveFingerPinchGesture -int 2
      
      # Keep three finger gestures for text selection (default macOS behavior)
      # Three finger drag is disabled to allow text selection with three finger swipe
      sudo -u "$PRIMARY_USER" defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerTapGesture -int 0
      sudo -u "$PRIMARY_USER" defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerDrag -bool false
      
      # Configure built-in trackpad gestures (for MacBook)
      # Four finger gestures for window management
      sudo -u "$PRIMARY_USER" defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadFourFingerVertSwipeGesture -int 2
      sudo -u "$PRIMARY_USER" defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadFourFingerHorizSwipeGesture -int 2
      sudo -u "$PRIMARY_USER" defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadFourFingerPinchGesture -int 2
      sudo -u "$PRIMARY_USER" defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadFiveFingerPinchGesture -int 2
      
      # Keep three finger gestures for native text selection
      sudo -u "$PRIMARY_USER" defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerDrag -bool false
      sudo -u "$PRIMARY_USER" defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerTapGesture -int 0
      
      # Enable Mission Control gestures via symbolic hotkeys (for four finger gestures)
      sudo -u "$PRIMARY_USER" defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 32 '<dict><key>enabled</key><true/></dict>'
      sudo -u "$PRIMARY_USER" defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 33 '<dict><key>enabled</key><true/></dict>'
      sudo -u "$PRIMARY_USER" defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 34 '<dict><key>enabled</key><true/></dict>'
      sudo -u "$PRIMARY_USER" defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 35 '<dict><key>enabled</key><true/></dict>'
      
      # Configure Mission Control for four finger gestures
      sudo -u "$PRIMARY_USER" defaults write com.apple.dock mcx-expose-disabled -bool false
      sudo -u "$PRIMARY_USER" defaults write com.apple.dock expose-group-apps -bool true
      
      # Enable navigation gestures
      sudo -u "$PRIMARY_USER" defaults write NSGlobalDomain AppleEnableSwipeNavigateWithScrolls -bool true
      sudo -u "$PRIMARY_USER" defaults write NSGlobalDomain AppleEnableMouseSwipeNavigateWithScrolls -bool true
      
      # Configure additional system preferences for gestures and animations
      sudo -u "$PRIMARY_USER" defaults write com.apple.systempreferences com.apple.preference.trackpad.forceClick -bool true
      
      # Enhanced native macOS animations and transitions
      sudo -u "$PRIMARY_USER" defaults write NSGlobalDomain NSScrollViewRubberbanding -bool true
      sudo -u "$PRIMARY_USER" defaults write NSGlobalDomain NSDocumentRevisionsDebugMode -bool false
      sudo -u "$PRIMARY_USER" defaults write NSGlobalDomain NSToolbarTitleViewRolloverDelay -float 0.5
      sudo -u "$PRIMARY_USER" defaults write NSGlobalDomain NSInitialToolTipDelay -int 1000
      sudo -u "$PRIMARY_USER" defaults write NSGlobalDomain NSPeriodicFlushInterval -float 0.02
      sudo -u "$PRIMARY_USER" defaults write NSGlobalDomain NSApplicationCrashOnExceptions -bool false
      sudo -u "$PRIMARY_USER" defaults write NSGlobalDomain NSTextInsertionPointBlinkPeriod -int 500
      
      # Window dragging and space switching animations
      sudo -u "$PRIMARY_USER" defaults write com.apple.dock workspaces-auto-swoosh -bool true
      sudo -u "$PRIMARY_USER" defaults write com.apple.dock workspaces-swoosh-animation-off -bool false
      sudo -u "$PRIMARY_USER" defaults write com.apple.dock expose-animation-duration -float 0.35
      sudo -u "$PRIMARY_USER" defaults write com.apple.dock springboard-show-duration -float 0.4
      sudo -u "$PRIMARY_USER" defaults write com.apple.dock springboard-hide-duration -float 0.2
      sudo -u "$PRIMARY_USER" defaults write com.apple.dock workspaces-edge-delay -float 0.2
      
      # Mission Control and Spaces animation settings
      sudo -u "$PRIMARY_USER" defaults write com.apple.dock missioncontrol-animation-duration -float 0.4
      sudo -u "$PRIMARY_USER" defaults write com.apple.dock expose-group-apps -bool true
      sudo -u "$PRIMARY_USER" defaults write com.apple.dock dashboard-enabled-state -int 1
      
      # CoreGraphics and window animation improvements
      sudo -u "$PRIMARY_USER" defaults write NSGlobalDomain NSWindowResizeTime -float 0.15
      sudo -u "$PRIMARY_USER" defaults write NSGlobalDomain NSAutomaticWindowAnimationsEnabled -bool true
      sudo -u "$PRIMARY_USER" defaults write NSGlobalDomain NSBrowserColumnAnimationSpeedMultiplier -float 1.0
      sudo -u "$PRIMARY_USER" defaults write NSGlobalDomain NSMenuBarFlashInterval -float 0.5
      
      # Mission Control desktop tinting and visual effects
      sudo -u "$PRIMARY_USER" defaults write com.apple.dock reduce-desktop-tinting -bool false
      sudo -u "$PRIMARY_USER" defaults write com.apple.dock enable-spring-load-actions-on-all-items -bool true
      
      # Window shadow and visual effects
      sudo -u "$PRIMARY_USER" defaults write com.apple.WindowManager EnableStandardClickToShowDesktop -bool false
      
      # Restart required services to apply gesture settings
      sudo -u "$PRIMARY_USER" killall Dock 2>/dev/null || true
      sudo -u "$PRIMARY_USER" killall SystemUIServer 2>/dev/null || true
      
      echo "✓ Complete native trackpad gestures configured for user: $PRIMARY_USER"
      echo "  - Mission Control (4-finger swipe up)"
      echo "  - App Exposé (4-finger swipe down)" 
      echo "  - Desktop switching (4-finger swipe left/right)"
      echo "  - Launchpad (4-finger pinch)"
      echo "  - Three finger gestures reserved for text selection"
    else
      echo "⚠ Primary user not found, skipping gesture configuration"
    fi
  '';
}
