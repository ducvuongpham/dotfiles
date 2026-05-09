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
      # raycast: managed via nix (modules/darwin/default.nix)
      # vscode managed via home-manager (modules/home/vscode.nix)
      "telegram"
      "tailscale-app"
      # karabiner-elements: managed via nix (modules/darwin/default.nix)
      "maccy"
      "monitorcontrol"
      "keycastr"
      "mos"
      "microsoft-office"
    ];

    masApps = { };
  };
}
