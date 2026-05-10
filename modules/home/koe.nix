{ pkgs, ... }:
# koe — live multilingual subtitles via Gemma 4 audio (Ja/En/Vi).
#
# Architecture (v1, browser-overlay path):
#   - Python server at ~/code/koe/server runs FastAPI + Gemma 4 E4B via
#     LiteRT-LM. Streams transcript + 2 translations as `[src]/[en]/[ja]/
#     [vi]` marker text over WebSocket.
#   - Overlay is the same Python server's index.html, opened by Chrome
#     in `--app=` mode (borderless window). AeroSpace handles always-on-
#     top + visible-across-spaces via a window rule (see aerospace.nix).
#
# Future polish: native Tauri overlay. Build is currently blocked on
# `tauri::generate_context!()` SIGABRTing rustc during macro expansion —
# happens with nix's rustc 1.94 + Tauri 2.11 on macOS 26. Sources of fix
# to try later: rust-overlay flake with a different rustc, or a fenix-
# pinned nightly. The Tauri scaffold lives at ~/code/koe/overlay/.
#
# Usage:
#   koe up              # start server + open overlay window
#   koe down            # stop both
#   koe status          # is the server running? which model?
#   koe logs            # tail server output
#   koe restart         # bounce server (overlay stays open)
let
  KOE_DIR = "$HOME/code/koe";
  KOE_LOG = "/tmp/koe.log";
  # Chrome is nix-managed via systemPackages → rsynced to /Applications/Nix Apps.
  CHROME = "/Applications/Nix Apps/Google Chrome.app/Contents/MacOS/Google Chrome";

  koe = pkgs.writeShellApplication {
    name = "koe";
    runtimeInputs = [ pkgs.uv pkgs.curl pkgs.coreutils ];
    text = ''
      KOE_DIR="${KOE_DIR}"
      KOE_LOG="${KOE_LOG}"
      CHROME="${CHROME}"
      PORT="''${KOE_PORT:-8000}"
      MODEL="''${KOE_MODEL:-E4B}"

      pid_of_server() {
        # Identify by listener on $PORT — uv-spawned children don't carry the
        # full path in their argv, so name-based pgrep is unreliable.
        lsof -nP -iTCP:"$PORT" -sTCP:LISTEN 2>/dev/null | awk 'NR>1 {print $2; exit}'
      }

      start_server() {
        if [ -n "$(pid_of_server)" ]; then
          echo "[koe] server already running (pid $(pid_of_server))"
          return 0
        fi
        if [ ! -d "$KOE_DIR/server" ]; then
          echo "[koe] missing $KOE_DIR/server — clone or restore the project" >&2
          return 1
        fi
        echo "[koe] starting server (model=$MODEL, port=$PORT) ..."
        ( cd "$KOE_DIR/server" && nohup env KOE_MODEL="$MODEL" PORT="$PORT" \
            uv run server.py > "$KOE_LOG" 2>&1 < /dev/null & disown ) || true

        # Wait up to 60s for /health to come up
        for _ in $(seq 1 60); do
          if curl -fsS "http://127.0.0.1:$PORT/health" > /dev/null 2>&1; then
            echo "[koe] server ready on http://localhost:$PORT"
            return 0
          fi
          sleep 1
        done
        echo "[koe] server didn't come up in 60s — check $KOE_LOG" >&2
        return 1
      }

      stop_server() {
        local pid
        pid="$(pid_of_server)"
        if [ -n "$pid" ]; then
          echo "[koe] stopping server (pid $pid)"
          kill "$pid" 2>/dev/null || true
          # Also kill the parent uv that spawned it
          pkill -f "uv run server.py" 2>/dev/null || true
          sleep 1
        else
          echo "[koe] server not running"
        fi
      }

      open_overlay() {
        if [ ! -x "$CHROME" ]; then
          echo "[koe] $CHROME not found — install google-chrome cask" >&2
          return 1
        fi
        # --app= gives a borderless app-style window. Custom user-data-dir
        # keeps the window separate from your normal Chrome session, and
        # AeroSpace can target it by app-id (com.google.Chrome.app.koe).
        "$CHROME" \
          --user-data-dir="$HOME/.cache/koe-chrome" \
          --app="http://localhost:$PORT/" \
          --window-size=720,260 \
          --no-first-run \
          --no-default-browser-check \
          > /dev/null 2>&1 &
        disown
      }

      close_overlay() {
        # Kill any chrome process running with our user-data-dir
        pkill -f "user-data-dir=$HOME/.cache/koe-chrome" 2>/dev/null || true
      }

      cmd="''${1:-up}"
      case "$cmd" in
        up)
          start_server || exit 1
          open_overlay
          echo "[koe] overlay opened — settings via cog icon, mic via prompt."
          ;;
        down)
          close_overlay
          stop_server
          ;;
        status)
          pid="$(pid_of_server)" || true
          if [ -n "$pid" ]; then
            echo "server: running (pid $pid)"
            curl -fsS "http://127.0.0.1:$PORT/health" 2>/dev/null \
              | python3 -m json.tool 2>/dev/null || true
          else
            echo "server: stopped"
          fi
          ;;
        logs)
          tail -f "$KOE_LOG"
          ;;
        restart)
          stop_server
          start_server
          ;;
        *)
          echo "usage: koe {up|down|status|logs|restart}" >&2
          exit 2
          ;;
      esac
    '';
  };
in
{
  home.packages = [ koe ];
}
