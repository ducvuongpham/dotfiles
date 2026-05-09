{ ... }:
{
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      cleanup = "zap";
      upgrade = true;
    };

    taps = [
      "felixkratz/formulae"
    ];

    brews = [
      "felixkratz/formulae/borders"      # JankyBorders — colored window borders
      "felixkratz/formulae/sketchybar"   # custom menu bar
      "switchaudio-osx"                  # SwitchAudioSource CLI (audio output picking)
      "blueutil"                         # bluetooth CLI (power + paired devices)
    ];

    casks = [
      "font-sketchybar-app-font"  # icon font for sketchybar app icons
      "betterdisplay"             # CLI for internal+external brightness (Apple Silicon)
      # Brew-only because not in nixpkgs or has Mac-specific entitlements:
      "zen"                    # not in nixpkgs
      "brave-browser"          # auto-update via brew
      "tailscale-app"          # NetworkExtension entitlements, GUI not in nixpkgs
      "microsoft-office"       # proprietary, not in nixpkgs
      "telegram"               # nixpkgs builds from source (~45 min) — too slow
      "karabiner-elements"     # DriverKit + helper SMAppServices need real codesigned bundle
    ];

    masApps = { };
  };
}
