{ pkgs, lib, config, ... }:
{
  # Mutable symlink so you can edit lua and hotload (sbar.hotload(true)).
  xdg.configFile."sketchybar".source = config.lib.file.mkOutOfStoreSymlink
    "${config.home.homeDirectory}/dotfiles/home/sketchybar";

  # Build SbarLua (felixkratz/SbarLua, MIT) once into ~/.local/share/sketchybar_lua/.
  # The sketchybarrc loads it via package.cpath.
  home.activation.installSbarLua = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    target="$HOME/.local/share/sketchybar_lua/sketchybar.so"
    if [ ! -f "$target" ]; then
      tmp="$(mktemp -d)"
      ${pkgs.git}/bin/git clone --depth=1 https://github.com/FelixKratz/SbarLua.git "$tmp/SbarLua"
      (
        # Use Apple's system toolchain (Command Line Tools) — nix's wrapped
        # clang fights dsymutil/lto-paths during SbarLua's link step.
        export PATH="/usr/bin:/bin:/usr/sbin:/sbin"
        cd "$tmp/SbarLua" && /usr/bin/make install
      )
      rm -rf "$tmp"
    fi
  '';
}
