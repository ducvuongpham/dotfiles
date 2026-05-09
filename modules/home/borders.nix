{ config, ... }:
{
  xdg.configFile."borders".source = config.lib.file.mkOutOfStoreSymlink
    "${config.home.homeDirectory}/dotfiles/home/borders";
}
