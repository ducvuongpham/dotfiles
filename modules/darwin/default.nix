{ pkgs, ... }:
{
  imports = [
    ./system-defaults.nix
    ./homebrew.nix
  ];

  # Determinate Nix manages the daemon itself — keep nix-darwin off the daemon.
  nix.enable = false;

  programs.zsh.enable = true;

  # Touch ID for sudo (writes /etc/pam.d/sudo_local; survives macOS updates).
  # `reattach` adds pam_reattach.so so Touch ID also works inside tmux.
  security.pam.services.sudo_local = {
    touchIdAuth = true;
    reattach = true;
  };

  environment.systemPackages = with pkgs; [
    git
    curl
    wget
    coreutils

    # GUI apps go here so nix-darwin rsyncs them to /Applications/Nix Apps
    # (Spotlight indexes that path; user-level HM apps don't get indexed reliably).
    alacritty-graphics
    vscode
    karabiner-elements
    raycast
    google-chrome
    brave
    slack
    # telegram-desktop on darwin source-builds (~45 min) — using brew instead
    dbeaver-bin
    aerospace
    maccy
    monitorcontrol
    keycastr
    mos
  ];

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
  ];
}
