{ pkgs, ... }:
{
  imports = [
    ./system-defaults.nix
    ./homebrew.nix
  ];

  # Determinate Nix manages the daemon itself — keep nix-darwin off the daemon.
  nix.enable = false;

  programs.zsh.enable = true;

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
