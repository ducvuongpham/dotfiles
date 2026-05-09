{ config, ... }:
{
  home.file.".hammerspoon".source = config.lib.file.mkOutOfStoreSymlink
    "${config.home.homeDirectory}/dotfiles/home/hammerspoon";
}
