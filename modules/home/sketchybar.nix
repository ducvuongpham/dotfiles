{ pkgs, lib, config, ... }:
{
  # Mutable symlink so you can edit lua and hotload (sbar.hotload(true)).
  xdg.configFile."sketchybar".source = config.lib.file.mkOutOfStoreSymlink
    "${config.home.homeDirectory}/dotfiles/home/sketchybar";

  # Build SbarLua (felixkratz/SbarLua, MIT) once into ~/.local/share/sketchybar_lua/.
  # The sketchybarrc loads it via package.cpath.
  home.activation.installSbarLua = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    target="$HOME/.local/share/sketchybar_lua/sketchybar.so"
    bundled_lua="$HOME/.local/share/sketchybar_lua/lua"
    if [ ! -f "$target" ] || [ ! -x "$bundled_lua" ]; then
      tmp="$(mktemp -d)"
      ${pkgs.git}/bin/git clone --depth=1 https://github.com/FelixKratz/SbarLua.git "$tmp/SbarLua"
      (
        # Use Apple's system toolchain — nix's wrapped clang fights dsymutil paths.
        export PATH="/usr/bin:/bin:/usr/sbin:/sbin"
        cd "$tmp/SbarLua" && /usr/bin/make install
        # Copy the lua 5.5 interpreter built alongside (sketchybar.so embeds 5.5 ABI;
        # running sketchybarrc with system lua 5.4 segfaults).
        mkdir -p "$HOME/.local/share/sketchybar_lua"
        /bin/cp "lua-5.5.0/src/lua" "$HOME/.local/share/sketchybar_lua/lua"
        /bin/chmod +x "$HOME/.local/share/sketchybar_lua/lua"
      )
      rm -rf "$tmp"
    fi
  '';
}
