{ config, ... }:
{
  # AeroSpace installed via brew cask (modules/darwin/homebrew.nix).
  # Config file is read from ~/.aerospace.toml or ~/.config/aerospace/aerospace.toml.

  # Mutable symlink for helper scripts so edits apply without home-manager rebuild.
  home.file.".config/aerospace/scripts".source = config.lib.file.mkOutOfStoreSymlink
    "${config.home.homeDirectory}/dotfiles/home/aerospace/scripts";

  home.file.".config/aerospace/aerospace.toml".text = ''
    # AeroSpace tiling window manager config
    # https://nikitabobko.github.io/AeroSpace/guide

    after-login-command = []
    # borders + sketchybar are managed by `brew services` (launchd) so they
    # start independently and survive AeroSpace restarts. No need to launch here.
    # Reload config a few seconds after startup — at login AeroSpace can race
    # display detection and workspace-to-monitor pinning ends up wrong; the
    # reload re-applies it once monitors are stable.
    after-startup-command = ['exec-and-forget sh -c "sleep 5 && /opt/homebrew/bin/aerospace reload-config"']
    # On workspace change: flatten any leftover single-child containers
    # (closed-window debris) AND fire the sketchybar event for the bar.
    exec-on-workspace-change = ['/bin/bash', '-c',
      '/opt/homebrew/bin/aerospace flatten-workspace-tree 2>/dev/null; sketchybar --trigger aerospace_workspace_change FOCUSED_WORKSPACE=$AEROSPACE_FOCUSED_WORKSPACE'
    ]

    start-at-login = true

    # Disabled so `split opposite` (used by alt-enter for dwindle/Fibonacci
    # tiling) is preserved across normalization. Trade-off: closing a window
    # may leave single-child containers; run `aerospace flatten-workspace-tree`
    # if nesting gets deep.
    enable-normalization-flatten-containers = false
    enable-normalization-opposite-orientation-for-nested-containers = true

    accordion-padding = 30

    default-root-container-layout = 'tiles'
    default-root-container-orientation = 'auto'

    on-focused-monitor-changed = ['move-mouse monitor-lazy-center']

    # Workspace -> monitor pinning with fallback chains.
    #   Monitor 1 (built-in):  1 2 3 4 5
    #   Monitor 2 (secondary): Q W E R T
    #   Monitor 3 (tertiary):  A S D F G
    # With fewer monitors, each set falls back along its chain to the next
    # available monitor (so e.g. on a single screen everything lands on built-in).
    [workspace-to-monitor-force-assignment]
    1 = 'built-in'
    2 = 'built-in'
    3 = 'built-in'
    4 = 'built-in'
    5 = 'built-in'
    Q = ['secondary', 'built-in']
    W = ['secondary', 'built-in']
    E = ['secondary', 'built-in']
    R = ['secondary', 'built-in']
    T = ['secondary', 'built-in']
    # Note: 'secondary' is intentionally skipped so A-G fall back to built-in
    # (not monitor 2) when only 2 monitors are present — otherwise they'd
    # collide with Q-T on the external display.
    A = [3, 'built-in']
    S = [3, 'built-in']
    D = [3, 'built-in']
    F = [3, 'built-in']
    G = [3, 'built-in']

    [key-mapping]
    preset = 'qwerty'

    [gaps]
    inner.horizontal = 8
    inner.vertical = 8
    outer.left = 8
    outer.bottom = 8
    # Per-monitor: built-in is shorter (BetterDisplay notch-conceals already
    # reserves the top strip). Externals keep the full 38 for sketchybar.
    outer.top = [{ monitor."built-in" = 4 }, 38]
    outer.right = 8

    # main mode
    [mode.main.binding]
    # focus pane / monitor — chain a sketchybar trigger so window_title /
    # front_app refresh even when focus moves between two windows of the
    # same app (front_app_switched doesn't fire in that case). The
    # --boundaries-action wraps focus around the workspace edges.
    alt-h = ['focus --boundaries-action wrap-around-the-workspace left',  'exec-and-forget sketchybar --trigger aerospace_focus_change']
    alt-l = ['focus --boundaries-action wrap-around-the-workspace right', 'exec-and-forget sketchybar --trigger aerospace_focus_change']
    # focus monitor with wrap (cycles through all displays). With N monitors,
    # alt-j cycles backward (prev) and alt-k cycles forward (next), wrapping
    # around 1 → 2 → 3 → 1.
    alt-j = ['focus-monitor --wrap-around prev', 'exec-and-forget sketchybar --trigger aerospace_focus_change']
    alt-k = ['focus-monitor --wrap-around next', 'exec-and-forget sketchybar --trigger aerospace_focus_change']

    # move
    alt-shift-h = 'move left'
    alt-shift-j = 'move down'
    alt-shift-k = 'move up'
    alt-shift-l = 'move right'

    # resize (smart = width or height depending on split direction)
    alt-minus = 'resize smart -50'
    alt-equal = 'resize smart +50'
    alt-shift-minus = 'resize height -50'
    alt-shift-equal = 'resize height +50'
    alt-ctrl-minus  = 'resize width -50'
    alt-ctrl-equal  = 'resize width +50'

    # layout
    alt-slash = 'layout tiles horizontal vertical'
    alt-comma = 'layout accordion horizontal vertical'

    # i3-style zoom: toggle focused window to cover the workspace.
    # Moved off alt-f because F is now a workspace key (monitor 3).
    alt-m = 'fullscreen'

    # Smart split + spawn. Delegated to a script so we can branch:
    #   1 window in workspace → force `tiles horizontal` so the new Alacritty
    #     always lands side-by-side, regardless of last split orientation.
    #   >1 windows → `split opposite` (Fibonacci dwindle, spirals inward).
    alt-enter = 'exec-and-forget ~/.config/aerospace/scripts/smart-split-spawn.sh'

    # Manual cleanup: flatten the current workspace (collapses any
    # single-child containers left behind by closed windows).
    alt-shift-slash = 'flatten-workspace-tree'

    # workspaces — monitor 1 (built-in): numbers
    alt-1 = 'workspace 1'
    alt-2 = 'workspace 2'
    alt-3 = 'workspace 3'
    alt-4 = 'workspace 4'
    alt-5 = 'workspace 5'
    # workspaces — monitor 2 (secondary): Q W E R T
    alt-q = 'workspace Q'
    alt-w = 'workspace W'
    alt-e = 'workspace E'
    alt-r = 'workspace R'
    alt-t = 'workspace T'
    # workspaces — monitor 3 (tertiary): A S D F G
    alt-a = 'workspace A'
    alt-s = 'workspace S'
    alt-d = 'workspace D'
    alt-f = 'workspace F'
    alt-g = 'workspace G'

    # move window AND follow it to that workspace
    alt-shift-1 = ['move-node-to-workspace 1', 'workspace 1']
    alt-shift-2 = ['move-node-to-workspace 2', 'workspace 2']
    alt-shift-3 = ['move-node-to-workspace 3', 'workspace 3']
    alt-shift-4 = ['move-node-to-workspace 4', 'workspace 4']
    alt-shift-5 = ['move-node-to-workspace 5', 'workspace 5']
    alt-shift-q = ['move-node-to-workspace Q', 'workspace Q']
    alt-shift-w = ['move-node-to-workspace W', 'workspace W']
    alt-shift-e = ['move-node-to-workspace E', 'workspace E']
    alt-shift-r = ['move-node-to-workspace R', 'workspace R']
    alt-shift-t = ['move-node-to-workspace T', 'workspace T']
    alt-shift-a = ['move-node-to-workspace A', 'workspace A']
    alt-shift-s = ['move-node-to-workspace S', 'workspace S']
    alt-shift-d = ['move-node-to-workspace D', 'workspace D']
    alt-shift-f = ['move-node-to-workspace F', 'workspace F']
    alt-shift-g = ['move-node-to-workspace G', 'workspace G']

    alt-tab = 'workspace-back-and-forth'
    alt-shift-tab = 'move-workspace-to-monitor --wrap-around next'

    # service
    alt-shift-semicolon = 'mode service'

    [mode.service.binding]
    esc = ['reload-config', 'mode main']
    r = ['flatten-workspace-tree', 'mode main']
    f = ['layout floating tiling', 'mode main']
    backspace = ['close-all-windows-but-current', 'mode main']
  '';
}
