{ ... }:
{
  system.defaults = {
    NSGlobalDomain = {
      AppleInterfaceStyle = "Dark";
      _HIHideMenuBar = true;  # native menu bar auto-hides; revealed by cursor at top, overlays sketchybar
      AppleShowAllExtensions = true;
      AppleShowScrollBars = "WhenScrolling";
      InitialKeyRepeat = 10;
      KeyRepeat = 1;
      ApplePressAndHoldEnabled = false;
      NSAutomaticCapitalizationEnabled = false;
      NSAutomaticDashSubstitutionEnabled = false;
      NSAutomaticPeriodSubstitutionEnabled = false;
      NSAutomaticQuoteSubstitutionEnabled = false;
      NSAutomaticSpellingCorrectionEnabled = false;
      NSDocumentSaveNewDocumentsToCloud = false;
      NSNavPanelExpandedStateForSaveMode = true;
      NSNavPanelExpandedStateForSaveMode2 = true;
      NSWindowResizeTime = 1.0e-3;
      "com.apple.keyboard.fnState" = true;
      "com.apple.mouse.tapBehavior" = 1;
      # Keep macOS "natural scroll" ON for trackpad. Mos reverses ONLY the mouse
      # wheel so trackpad gestures stay natural.
      "com.apple.swipescrolldirection" = true;
      "com.apple.trackpad.scaling" = 3.0;
    };

    dock = {
      autohide = true;
      autohide-delay = 0.0;
      autohide-time-modifier = 0.2;
      orientation = "bottom";
      show-recents = false;
      tilesize = 48;
      mineffect = "scale";
      minimize-to-application = true;
      mru-spaces = false;
      expose-group-apps = true;
    };

    finder = {
      AppleShowAllExtensions = true;
      AppleShowAllFiles = true;
      CreateDesktop = false;
      FXDefaultSearchScope = "SCcf";
      FXEnableExtensionChangeWarning = false;
      FXPreferredViewStyle = "Nlsv";
      ShowPathbar = true;
      ShowStatusBar = true;
      _FXShowPosixPathInTitle = true;
      _FXSortFoldersFirst = true;
    };

    trackpad = {
      Clicking = true;
      TrackpadRightClick = true;
      # 3-finger swipes for navigation (Spaces, Mission Control, App Expose).
      # Drag-windows-by-3-fingers off so swipes stay on 3 fingers (not 4).
      TrackpadThreeFingerDrag = false;
      TrackpadThreeFingerTapGesture = 0;
    };

    screencapture = {
      location = "~/Pictures/Screenshots";
      type = "png";
      disable-shadow = true;
    };

    loginwindow = {
      GuestEnabled = false;
      LoginwindowText = "tada-mbp";
    };

    LaunchServices.LSQuarantine = false;

    CustomUserPreferences = {
      "com.apple.screensaver" = {
        askForPassword = 1;
        askForPasswordDelay = 0;
      };
      "com.apple.AdLib" = {
        allowApplePersonalizedAdvertising = false;
      };
      ".GlobalPreferences" = {
        "com.apple.mouse.scaling" = 3.0;
      };
      # Mos (mouse smoothing + reverse mouse-only scroll). Complex shortcut
      # bindings (block/dash/toggle/applications/buttonBindings) are JSON-data
      # blobs and stay user-managed in the app — Mos preserves them across
      # switches.
      # 3-finger swipes for both built-in + external Magic Trackpad.
      # Horiz=2 -> swipe between full-screen apps/spaces.
      # Vert=2  -> swipe up = Mission Control, swipe down = App Expose.
      "com.apple.driver.AppleBluetoothMultitouch.trackpad" = {
        TrackpadThreeFingerHorizSwipeGesture = 0;  # leave horizontal 3-finger swipe to aerospace-swipe
        TrackpadThreeFingerVertSwipeGesture = 2;
        # tap+hold-drag (no drag lock — lift = drop).
        Dragging = true;
        DragLock = false;
      };
      "com.apple.AppleMultitouchTrackpad" = {
        TrackpadThreeFingerHorizSwipeGesture = 0;  # leave horizontal 3-finger swipe to aerospace-swipe
        TrackpadThreeFingerVertSwipeGesture = 2;
        Dragging = true;
        DragLock = false;
      };
      "com.apple.dock" = {
        showMissionControlGestureEnabled = true;
        showAppExposeGestureEnabled = true;
      };

      # Hide desktop widgets entirely (no weather/calendar/photos on desktop).
      "com.apple.WindowManager" = {
        StandardHideWidgets = 1;
        StageManagerHideWidgets = 1;
      };

      # Maccy clipboard manager.
      # Hotkey is encoded data — written via postActivation defaults command below.
      "org.p0deje.Maccy" = {
        searchMode = "fuzzy";
        showInStatusBar = true;
        showFooter = false;
        pasteByDefault = true;
        showSearch = true;
        showApplicationIcons = true;
        clearOnQuit = false;
        historySize = 200;
        ignoreOnlyNextEvent = false;
        clipboardCheckInterval = 0.5;
      };

      "com.caldis.Mos" = {
        optionsExist = "optionsExist";
        hideStatusItem = true;
        allowlist = false;
        smooth = true;
        smoothVertical = true;
        smoothHorizontal = true;
        smoothSimTrackpad = false;
        reverse = true;
        reverseVertical = true;
        reverseHorizontal = true;
        speed = 10;
        step = 200;
        duration = 0.5;
        deadZone = 0;
        updateCheckOnAppStart = false;
        updateIncludingBetaVersion = false;
      };
      # Free up Ctrl-Space (and Ctrl-Opt-Space) by disabling input-source switching.
      # 60 = previous input source, 61 = next source in Input menu.
      "com.apple.symbolichotkeys" = {
        AppleSymbolicHotKeys = {
          # 60/61: input source switching (free Ctrl-Space for tmux).
          # 64/65: Spotlight (free Cmd-Space for Raycast).
          "60".enabled = false;
          "61".enabled = false;
          "64".enabled = false;
          "65".enabled = false;
        };
      };
    };
  };

  system.activationScripts.postActivation.text = ''
    /usr/bin/sudo -u tada /bin/mkdir -p "/Users/tada/Pictures/Screenshots"
    /usr/sbin/chown tada:staff "/Users/tada/Pictures/Screenshots"

    # Install Rosetta 2 on Apple Silicon if not already present.
    if [ "$(/usr/bin/uname -m)" = "arm64" ] && ! /usr/bin/pgrep -q oahd; then
      echo "installing Rosetta 2..."
      /usr/sbin/softwareupdate --install-rosetta --agree-to-license || true
    fi

    # Wipe all desktop widgets + reload WindowManager so StandardHideWidgets applies.
    /usr/bin/sudo -u tada /usr/bin/defaults delete com.apple.chronod 2>/dev/null || true
    /usr/bin/sudo -u tada /usr/bin/killall chronod 2>/dev/null || true
    /usr/bin/sudo -u tada /usr/bin/killall WindowManager 2>/dev/null || true
    /usr/bin/sudo -u tada /usr/bin/killall Dock 2>/dev/null || true

    # Maccy popup hotkey = Cmd+Shift+V (carbonModifiers=768, carbonKeyCode=9).
    # KeyboardShortcuts lib stores this as JSON-encoded String under
    # `KeyboardShortcuts_popup`. defaults write -string sets the right type.
    /usr/bin/sudo -u tada /usr/bin/defaults write org.p0deje.Maccy KeyboardShortcuts_popup -string '{"carbonModifiers":768,"carbonKeyCode":9}'
    /usr/bin/sudo -u tada /usr/bin/killall Maccy 2>/dev/null || true

    # Make sure borders + sketchybar are registered with launchd as brew services
    # so they auto-start at login independently of AeroSpace.
    /usr/bin/sudo -u tada /opt/homebrew/bin/brew services start borders 2>/dev/null || true
    /usr/bin/sudo -u tada /opt/homebrew/bin/brew services start sketchybar 2>/dev/null || true
  '';
}
