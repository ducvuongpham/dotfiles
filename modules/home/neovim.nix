{ config, lib, pkgs, ... }:
{
  # Mutable symlink: ~/.config/nvim -> ~/dotfiles/home/nvim
  # mkOutOfStoreSymlink keeps the symlink target writable so vim.pack can update
  # nvim-pack-lock.json and you can edit lua in place.
  xdg.configFile."nvim".source = config.lib.file.mkOutOfStoreSymlink
    "${config.home.homeDirectory}/dotfiles/home/nvim";

  # sqlite.lua plugin hardcodes brew's libsqlite3 path. Point it at nix's
  # via $LIBSQLITE (read by lua/sqlite/defs.lua before falling back to brew).
  home.sessionVariables.LIBSQLITE = "${pkgs.sqlite.out}/lib/libsqlite3.dylib";
}
