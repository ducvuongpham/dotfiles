{ config, lib, ... }:
{
  # ~/.config/mise/config.toml — symlinked out of dotfiles for hot-edits.
  # Mise picks up changes on next shell launch.
  home.file.".config/mise/config.toml".source =
    config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/dotfiles/home/mise/config.toml";
}
