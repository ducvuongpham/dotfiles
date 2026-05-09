{ pkgs, ... }:
{
  programs.tmux = {
    enable = true;
    shortcut = "a";
    baseIndex = 1;
    keyMode = "vi";
    mouse = true;
    terminal = "screen-256color";
    historyLimit = 100000;
    escapeTime = 0;
    clock24 = true;

    plugins = with pkgs.tmuxPlugins; [
      sensible
      yank
      resurrect
      continuum
    ];

    extraConfig = ''
      set -g default-terminal "screen-256color"
      set -ga terminal-overrides ",*256col*:Tc"

      # vim-like pane nav
      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R

      # split panes using current dir
      bind '"' split-window -v -c "#{pane_current_path}"
      bind % split-window -h -c "#{pane_current_path}"

      # reload config
      bind r source-file ~/.config/tmux/tmux.conf \; display "reloaded"
    '';
  };
}
