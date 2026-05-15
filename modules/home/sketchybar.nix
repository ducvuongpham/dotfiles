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
        export PATH="/usr/bin:/bin:/usr/sbin:/sbin"
        cd "$tmp/SbarLua" && /usr/bin/make install
        mkdir -p "$HOME/.local/share/sketchybar_lua"
        /bin/cp "lua-5.5.0/src/lua" "$HOME/.local/share/sketchybar_lua/lua"
        /bin/chmod +x "$HOME/.local/share/sketchybar_lua/lua"
      )
      rm -rf "$tmp"
    fi
  '';

  # Fetch sketchybar-app-font icon_map.lua (MIT, kvndrsslr release asset) —
  # maps macOS app names to glyphs in the sketchybar-app-font font.
  home.activation.fetchAppIconMap = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    icon_map="$HOME/.local/share/sketchybar_lua/icon_map.lua"
    if [ ! -f "$icon_map" ]; then
      mkdir -p "$HOME/.local/share/sketchybar_lua"
      ${pkgs.curl}/bin/curl -fsSL \
        "https://github.com/kvndrsslr/sketchybar-app-font/releases/latest/download/icon_map.lua" \
        -o "$icon_map"
    fi
  '';

  # Compile a tiny Swift binary that prints the current input source ID using
  # the public Carbon TISCopyCurrentKeyboardInputSource API — uncached, unlike
  # `defaults read`. Used by sketchybar's language widget.
  home.activation.buildInputSourceCli = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    bin="$HOME/.local/share/sketchybar_lua/inputsource"
    if [ ! -x "$bin" ]; then
      tmp="$(mktemp -d)"
      cat > "$tmp/inputsource.swift" <<'EOF'
import Carbon
if let src = TISCopyCurrentKeyboardInputSource()?.takeRetainedValue(),
   let raw = TISGetInputSourceProperty(src, kTISPropertyInputSourceID) {
    let id = Unmanaged<CFString>.fromOpaque(raw).takeUnretainedValue() as String
    print(id)
}
EOF
      /usr/bin/swiftc -O "$tmp/inputsource.swift" -o "$bin"
      rm -rf "$tmp"
    fi
  '';

  # Compile a helper that finds the NSScreen under the mouse cursor and runs
  # `aerospace focus-monitor <name>` for it. Sketchybar click_scripts call
  # this so clicking the bar on monitor X focuses that monitor.
  home.activation.buildFocusMouseMonitorCli = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    bin="$HOME/.local/share/sketchybar_lua/focus-mouse-monitor"
    mkdir -p "$HOME/.local/share/sketchybar_lua"
    if [ ! -x "$bin" ]; then
      tmp="$(mktemp -d)"
      cat > "$tmp/focus-mouse-monitor.swift" <<'EOF'
import AppKit
import Foundation

let mouse = NSEvent.mouseLocation
let screen = NSScreen.screens.first(where: { $0.frame.contains(mouse) })
if let name = screen?.localizedName {
    let task = Process()
    task.launchPath = "/opt/homebrew/bin/aerospace"
    task.arguments = ["focus-monitor", name]
    try? task.run()
    task.waitUntilExit()
}
EOF
      /usr/bin/swiftc -O "$tmp/focus-mouse-monitor.swift" -o "$bin"
      rm -rf "$tmp"
    fi
  '';
}
