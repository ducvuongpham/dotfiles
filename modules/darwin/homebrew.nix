{ ... }:
{
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      cleanup = "zap";
      upgrade = true;
    };

    taps = [ ];

    brews = [ ];

    casks = [
      # Brew-only because not in nixpkgs or has Mac-specific entitlements:
      "zen"                    # not in nixpkgs
      "tailscale-app"          # NetworkExtension entitlements, GUI not in nixpkgs
      "microsoft-office"       # proprietary, not in nixpkgs
      "telegram"               # nixpkgs builds from source (~45 min) — too slow
      "karabiner-elements"     # DriverKit + helper SMAppServices need real codesigned bundle
    ];

    masApps = { };
  };
}
