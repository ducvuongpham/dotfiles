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
    ./browser-font.nix
    ./services.nix
    # spotlight.nix renamed to apps.nix conceptually — keeping path same.
    ./spotlight.nix
  ];

  # catppuccin/nix — applies catppuccin mocha to every supported program
  # (alacritty, bat, btop, fzf, gh, lazygit, etc.). Programs we manage
  # manually (tmux via TPM with green accent override; nvim via vim.pack
  # with custom highlight overrides) are opted out below so our overrides
  # win.
  catppuccin = {
    enable = true;
    flavor = "macchiato";
    accent = "sapphire";
  };
  # We don't use programs.neovim/programs.tmux home-manager modules
  # (nvim is managed via vim.pack + symlink, tmux is symlinked + TPM),
  # so there are no programs.{neovim,tmux}.catppuccin options to opt out
  # of — catppuccin/nix simply has nothing to apply for those.
}
