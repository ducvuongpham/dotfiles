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
  ];

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
  ];
}
