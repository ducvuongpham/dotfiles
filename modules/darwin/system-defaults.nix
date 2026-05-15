{ username, ... }:
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
        TrackpadThreeFingerHorizSwipeGesture = 0;  # off — aerospace-swipe captures raw multitouch
        TrackpadThreeFingerVertSwipeGesture = 2;
        # tap+hold-drag (no drag lock — lift = drop).
        Dragging = true;
        DragLock = false;
      };
      "com.apple.AppleMultitouchTrackpad" = {
        TrackpadThreeFingerHorizSwipeGesture = 0;  # off — aerospace-swipe captures raw multitouch
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

      # Maccy: sandboxed (App Store / Nix), so prefs live in
      # ~/Library/Containers/org.p0deje.Maccy/…  — written via postActivation below.

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
      # Menu bar (Control Center module visibility). _HIHideMenuBar above
      # auto-hides the native bar — these decide what shows up when you
      # reveal it. Strict mode: pin only Battery/Clock/NowPlaying/CC icon;
      # everything else explicitly hidden so click-pinning in the UI gets
      # yanked back on next rebuild.
      "com.apple.controlcenter" = {
        # visible (pinned to menu bar)
        "NSStatusItem VisibleCC Battery" = 1;
        "NSStatusItem VisibleCC BentoBox-0" = 1;   # Control Center icon itself
        "NSStatusItem VisibleCC Clock" = 1;
        "NSStatusItem VisibleCC NowPlaying" = 1;
        # hidden (still accessible inside Control Center popover)
        "NSStatusItem VisibleCC WiFi" = 0;
        "NSStatusItem VisibleCC Bluetooth" = 0;
        "NSStatusItem VisibleCC AirDrop" = 0;
        "NSStatusItem VisibleCC FocusModes" = 0;
        "NSStatusItem VisibleCC StageManager" = 0;
        "NSStatusItem VisibleCC ScreenMirroring" = 0;
        "NSStatusItem VisibleCC Display" = 0;
        "NSStatusItem VisibleCC Sound" = 0;
        "NSStatusItem VisibleCC AccessibilityShortcuts" = 0;
        "NSStatusItem VisibleCC UserSwitcher" = 0;
        "NSStatusItem VisibleCC MusicRecognition" = 0;
        "NSStatusItem VisibleCC KeyboardBrightness" = 0;
        "NSStatusItem VisibleCC VoiceControl" = 0;
        "NSStatusItem VisibleCC VPN" = 0;
        "NSStatusItem VisibleCC FastUserSwitching" = 0;
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
    /usr/bin/sudo -u ${username} /bin/mkdir -p "/Users/${username}/Pictures/Screenshots"
    /usr/sbin/chown ${username}:staff "/Users/${username}/Pictures/Screenshots"

    # Install Rosetta 2 on Apple Silicon if not already present.
    if [ "$(/usr/bin/uname -m)" = "arm64" ] && ! /usr/bin/pgrep -q oahd; then
      echo "installing Rosetta 2..."
      /usr/sbin/softwareupdate --install-rosetta --agree-to-license || true
    fi

    # Wipe all desktop widgets + reload WindowManager so StandardHideWidgets applies.
    /usr/bin/sudo -u ${username} /usr/bin/defaults delete com.apple.chronod 2>/dev/null || true
    /usr/bin/sudo -u ${username} /usr/bin/killall chronod 2>/dev/null || true
    /usr/bin/sudo -u ${username} /usr/bin/killall WindowManager 2>/dev/null || true
    /usr/bin/sudo -u ${username} /usr/bin/killall Dock 2>/dev/null || true
    # Re-read com.apple.controlcenter so menu bar visibility changes take effect.
    /usr/bin/sudo -u ${username} /usr/bin/killall ControlCenter 2>/dev/null || true

    # Maccy is sandboxed — write prefs to its container domain.
    MACCY_DOMAIN="/Users/${username}/Library/Containers/org.p0deje.Maccy/Data/Library/Preferences/org.p0deje.Maccy"
    /usr/bin/sudo -u ${username} /usr/bin/defaults write "$MACCY_DOMAIN" searchMode -string "fuzzy"
    /usr/bin/sudo -u ${username} /usr/bin/defaults write "$MACCY_DOMAIN" showInStatusBar -bool true
    /usr/bin/sudo -u ${username} /usr/bin/defaults write "$MACCY_DOMAIN" showFooter -bool false
    /usr/bin/sudo -u ${username} /usr/bin/defaults write "$MACCY_DOMAIN" pasteByDefault -bool true
    /usr/bin/sudo -u ${username} /usr/bin/defaults write "$MACCY_DOMAIN" showSearch -bool true
    /usr/bin/sudo -u ${username} /usr/bin/defaults write "$MACCY_DOMAIN" showApplicationIcons -bool true
    /usr/bin/sudo -u ${username} /usr/bin/defaults write "$MACCY_DOMAIN" clearOnQuit -bool false
    /usr/bin/sudo -u ${username} /usr/bin/defaults write "$MACCY_DOMAIN" historySize -int 200
    /usr/bin/sudo -u ${username} /usr/bin/defaults write "$MACCY_DOMAIN" ignoreOnlyNextEvent -bool false
    /usr/bin/sudo -u ${username} /usr/bin/defaults write "$MACCY_DOMAIN" clipboardCheckInterval -float 0.5
    # Popup hotkey = Cmd+Shift+V (carbonModifiers=768, carbonKeyCode=9).
    /usr/bin/sudo -u ${username} /usr/bin/defaults write "$MACCY_DOMAIN" KeyboardShortcuts_popup -string '{"carbonModifiers":768,"carbonKeyCode":9}'
    /usr/bin/sudo -u ${username} /usr/bin/killall Maccy 2>/dev/null || true

    # Make sure borders + sketchybar are registered with launchd as brew services
    # so they auto-start at login independently of AeroSpace.
    /usr/bin/sudo -u ${username} /opt/homebrew/bin/brew services start borders 2>/dev/null || true
    /usr/bin/sudo -u ${username} /opt/homebrew/bin/brew services start sketchybar 2>/dev/null || true
  '';
}
