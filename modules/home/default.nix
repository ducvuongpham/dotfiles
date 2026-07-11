{ ... }:
{
  imports = [
    ./packages.nix
    ./zsh.nix
    ./nushell.nix
    ./git.nix
    ./alacritty.nix
    ./rio.nix
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
    ./eza.nix
    ./mise.nix
    ./claude.nix
    ./ccstatusline.nix
    ./raycast.nix
    ./sleepwatcher.nix
    ./fastfetch.nix
    ./kew.nix
    ./brew-bin-shims.nix
    ./whisper-stream.nix
    ./dbeaver-secrets.nix
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
    autoEnable = true; # explicit match to enable; silences upcoming default flip warning
    flavor = "macchiato";
    accent = "sapphire";
  };

  # Enable bat via the home-manager module so catppuccin/nix can apply the
  # macchiato theme automatically. (Raw `bat` in packages.nix was unthemed —
  # catppuccin only hooks programs.* modules.)
  programs.bat.enable = true;

  # tealdeer: fast Rust `tldr` client. auto_update=true → cache refreshes
  # on first run after expiry (default 30d), no manual `tldr --update`.
  programs.tealdeer = {
    enable = true;
    settings.updates.auto_update = true;
  };
  # We don't use programs.neovim/programs.tmux home-manager modules
  # (nvim is managed via vim.pack + symlink, tmux is symlinked + TPM),
  # so there are no programs.{neovim,tmux}.catppuccin options to opt out
  # of — catppuccin/nix simply has nothing to apply for those.
}
