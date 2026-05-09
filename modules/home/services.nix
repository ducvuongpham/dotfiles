{ config, lib, ... }:
{
  # macOS Quick Actions / Services live under ~/Library/Services/<name>.workflow.
  # We symlink the whole bundle out of dotfiles so edits in the repo show up
  # without rebuilding nix-darwin.
  home.file."Library/Services/Open in Alacritty.workflow".source =
    config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/dotfiles/home/services/Open in Alacritty.workflow";
}
