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
        export PATH="${pkgs.gnumake}/bin:${pkgs.gcc}/bin:${pkgs.clang}/bin:${pkgs.llvm}/bin:$PATH"
        export CPATH="${pkgs.readline.dev}/include:${pkgs.ncurses.dev}/include:''${CPATH:-}"
        export LIBRARY_PATH="${pkgs.readline}/lib:${pkgs.ncurses}/lib:''${LIBRARY_PATH:-}"
        cd "$tmp/SbarLua" && ${pkgs.gnumake}/bin/make install
      )
      rm -rf "$tmp"
    fi
  '';
}
