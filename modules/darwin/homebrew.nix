{ ... }:
{
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      # "zap" requires brew bundle's --force-cleanup which nix-darwin does not
      # yet pass; newer Homebrew refuses --cleanup without it. Revert to "zap"
      # once nix-darwin upstream adds the flag.
      cleanup = "none";
      upgrade = true;
    };

    taps = [
      "felixkratz/formulae"
      "nikitabobko/tap"          # aerospace
    ];

    brews = [
      "felixkratz/formulae/borders"      # JankyBorders — colored window borders
      "felixkratz/formulae/sketchybar"   # custom menu bar
      "switchaudio-osx"                  # SwitchAudioSource CLI (audio output picking)
      "blueutil"                         # bluetooth CLI (power + paired devices)
      "sleepwatcher"                     # runs ~/.wakeup on wake (used to repoke sketchybar)
      "gulp-cli"                         # gulp task runner CLI (not in nixpkgs since nodePackages removal)
      "rtk"                              # rtk-ai/rtk — CLI proxy compressing LLM tool output (~60-90% token savings)
      # input-source CLI: compiled via Swift in modules/home/sketchybar.nix activation
    ];

    casks = [
      "font-sketchybar-app-font"  # icon font for sketchybar app icons
      "betterdisplay"             # CLI for internal+external brightness (Apple Silicon)
      # Brew-only because not in nixpkgs or has Mac-specific entitlements:
      "zen"                    # not in nixpkgs
      "brave-browser"          # auto-update via brew
      "tailscale-app"          # NetworkExtension entitlements, GUI not in nixpkgs
      "telegram"               # nixpkgs builds from source (~45 min) — too slow
      "karabiner-elements"     # DriverKit + helper SMAppServices need real codesigned bundle
      "nikitabobko/tap/aerospace"  # nix rsync of /Applications/Nix Apps killed the running daemon every switch
      "vlc"                    # not in nixpkgs darwin (Linux-only build)
      "figma"                  # proprietary, not in nixpkgs
      "hoppscotch"             # API client (open-source Postman alternative); not in nixpkgs
      "bluesnooze"             # auto-disable Bluetooth on sleep; not in nixpkgs
      "blackhole-2ch"          # virtual audio device — capture system audio for whisper-stream
      "rustdesk"               # remote desktop — brew cask is the signed build with TCC entitlements
      "microsoft-edge"
      "anki"                   # spaced-repetition flashcards; not in nixpkgs darwin
      "bitwarden"              # password manager GUI — brew cask for auto-updates + signed bundle
      "vivaldi"                # Chromium-based browser; not in nixpkgs darwin
      "peazip"                 # archive manager; not in nixpkgs darwin
    ];

    masApps = { };
  };
}
