{ pkgs, ... }:
{
  imports = [
    ./system-defaults.nix
    ./homebrew.nix
    ./login-items.nix
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

  # Allow tada to toggle Low Power Mode without password prompt
  # (sketchybar's battery popup uses this; click-script runs non-interactively).
  system.activationScripts.lowpowermodeSudoers.text = ''
    /usr/bin/printf 'tada ALL=(root) NOPASSWD: /usr/bin/pmset -a lowpowermode *\n' > /etc/sudoers.d/lowpowermode
    /bin/chmod 0440 /etc/sudoers.d/lowpowermode
  '';

  environment.systemPackages = with pkgs; [
    git
    curl
    wget
    coreutils

    # GUI apps go here so nix-darwin rsyncs them to /Applications/Nix Apps
    # (Spotlight indexes that path; user-level HM apps don't get indexed reliably).
    alacritty-graphics
    vscode
    zed-editor
    # karabiner-elements: managed via brew (nix bundle breaks DriverKit + helper SMAppServices)
    raycast
    google-chrome
    # brave: managed via brew (nix freezes browser version)
    slack
    # telegram-desktop on darwin source-builds (~45 min) — using brew instead
    dbeaver-bin
    # aerospace: managed via brew (nix systemPackages rsync kills the running daemon every switch)
    maccy
    monitorcontrol
    keycastr
    mos
  ];

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
  ];
}
