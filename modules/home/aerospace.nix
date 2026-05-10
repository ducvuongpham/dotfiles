{ ... }:
{
  # AeroSpace installed via brew cask (modules/darwin/homebrew.nix).
  # Config file is read from ~/.aerospace.toml or ~/.config/aerospace/aerospace.toml.
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
    #   1 mon  : everything on built-in.
    #   2 mons : 1-4 built-in, 5-9 secondary (per spec).
    #   3 mons : 1-4 built-in, 5-6 secondary, 7-9 tertiary.
    [workspace-to-monitor-force-assignment]
    1 = 'built-in'
    2 = 'built-in'
    3 = 'built-in'
    4 = 'built-in'
    5 = ['secondary', 'built-in']
    6 = ['secondary', 'built-in']
    7 = [3, 'secondary', 'built-in']
    8 = [3, 'secondary', 'built-in']
    9 = [3, 'secondary', 'built-in']

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
    # same app (front_app_switched doesn't fire in that case).
    alt-h = ['focus left',  'exec-and-forget sketchybar --trigger aerospace_focus_change']
    alt-l = ['focus right', 'exec-and-forget sketchybar --trigger aerospace_focus_change']
    # focus monitor (alt-j: built-in / internal, alt-k: external / secondary)
    alt-j = ['focus-monitor main',      'exec-and-forget sketchybar --trigger aerospace_focus_change']
    alt-k = ['focus-monitor secondary', 'exec-and-forget sketchybar --trigger aerospace_focus_change']

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

    # Smart split (Fibonacci / dwindle): wrap the focused window in a new
    # sub-container with orientation opposite to its parent, then spawn a
    # fresh Alacritty. The new window joins as sibling of the focused one
    # in that new container — so each alt-enter spirals inward, splitting
    # perpendicular to the prior split.
    alt-enter = ['split opposite', 'exec-and-forget /usr/bin/open -na Alacritty']

    # Manual cleanup: flatten the current workspace (collapses any
    # single-child containers left behind by closed windows).
    alt-shift-slash = 'flatten-workspace-tree'

    # workspaces
    alt-1 = 'workspace 1'
    alt-2 = 'workspace 2'
    alt-3 = 'workspace 3'
    alt-4 = 'workspace 4'
    alt-5 = 'workspace 5'
    alt-6 = 'workspace 6'
    alt-7 = 'workspace 7'
    alt-8 = 'workspace 8'
    alt-9 = 'workspace 9'

    # move window AND follow it to that workspace
    alt-shift-1 = ['move-node-to-workspace 1', 'workspace 1']
    alt-shift-2 = ['move-node-to-workspace 2', 'workspace 2']
    alt-shift-3 = ['move-node-to-workspace 3', 'workspace 3']
    alt-shift-4 = ['move-node-to-workspace 4', 'workspace 4']
    alt-shift-5 = ['move-node-to-workspace 5', 'workspace 5']
    alt-shift-6 = ['move-node-to-workspace 6', 'workspace 6']
    alt-shift-7 = ['move-node-to-workspace 7', 'workspace 7']
    alt-shift-8 = ['move-node-to-workspace 8', 'workspace 8']
    alt-shift-9 = ['move-node-to-workspace 9', 'workspace 9']

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
