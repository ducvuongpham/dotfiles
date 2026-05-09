{ config, lib, ... }:
{
  # Mutable symlink: ~/.config/nvim -> ~/dotfiles/home/nvim
  # mkOutOfStoreSymlink keeps the symlink target writable so vim.pack can update
  # nvim-pack-lock.json and you can edit lua in place.
  xdg.configFile."nvim".source = config.lib.file.mkOutOfStoreSymlink
    "${config.home.homeDirectory}/dotfiles/home/nvim";
}
