{ ... }:
{
  # AeroSpace installed via brew cask (modules/darwin/homebrew.nix).
  # Config file is read from ~/.aerospace.toml or ~/.config/aerospace/aerospace.toml.
  home.file.".config/aerospace/aerospace.toml".text = ''
    # AeroSpace tiling window manager config
    # https://nikitabobko.github.io/AeroSpace/guide

    after-login-command = []
    after-startup-command = [
      'exec-and-forget borders',
      'exec-and-forget sketchybar',
    ]
    # Fire SKETCHYBAR event on workspace change so the bar updates highlight.
    exec-on-workspace-change = ['/bin/bash', '-c',
      'sketchybar --trigger aerospace_workspace_change FOCUSED_WORKSPACE=$AEROSPACE_FOCUSED_WORKSPACE'
    ]

    start-at-login = true

    enable-normalization-flatten-containers = true
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
    outer.top = 44   # leave room for sketchybar (36px height + 8 margin)
    outer.right = 8

    # main mode
    [mode.main.binding]
    # focus
    alt-h = 'focus left'
    alt-j = 'focus down'
    alt-k = 'focus up'
    alt-l = 'focus right'

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
