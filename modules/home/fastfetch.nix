{ config, lib, ... }:
{
  # ~/.config/fastfetch/config.jsonc — symlinked from dotfiles for hot-edits.
  home.file.".config/fastfetch/config.jsonc".source =
    config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/dotfiles/home/fastfetch/config.jsonc";
}
