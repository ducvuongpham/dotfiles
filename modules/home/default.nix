{ ... }:
{
  imports = [
    ./packages.nix
    ./zsh.nix
    ./git.nix
    ./alacritty.nix
    ./aerospace.nix
    ./karabiner.nix
    ./neovim.nix
    ./vscode.nix
    ./tmux.nix
    ./yazi.nix
    ./sketchybar.nix
    ./borders.nix
    ./hammerspoon.nix
    # spotlight.nix renamed to apps.nix conceptually — keeping path same.
    ./spotlight.nix
  ];
}
