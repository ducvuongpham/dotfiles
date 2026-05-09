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
      "nikitabobko/tap"
    ];

    brews = [ ];

    casks = [
      "google-chrome"
      "brave-browser"
      "zen"
      "slack"
      "dbeaver-community"
      "nikitabobko/tap/aerospace"
      "raycast"
      # vscode managed via home-manager (modules/home/vscode.nix)
      "telegram"
      "tailscale-app"
      "karabiner-elements"
      "maccy"
      "monitorcontrol"
      "keycastr"
      "mos"
      "microsoft-office"
    ];

    masApps = { };
  };
}
