{ config, ... }:
{
  # kew (terminal music player) — config lives at
  # ~/Library/Preferences/kew/kewrc on macOS. Symlink out of dotfiles so
  # edits are tracked + reproducible. kew never rewrites kewrc on its own
  # except when running `kew path`, so the symlink is safe.
  home.file."Library/Preferences/kew/kewrc".source =
    config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/dotfiles/home/kew/kewrc";
}
