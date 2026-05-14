{ pkgs, ... }:
{
  programs.alacritty = {
    enable = true;
    # Bundle installed via nix-darwin environment.systemPackages so it lands in
    # /Applications/Nix Apps (Spotlight-indexed). HM only manages settings.
    package = null;

    settings = {
      env.TERM = "xterm-256color";

      window = {
        opacity = 0.97;
        padding = { x = 12; y = 12; };
        decorations = "buttonless";
        option_as_alt = "Both";
        startup_mode = "Windowed";  # AeroSpace tiles it; Maximized bypasses tiling
      };

      scrolling.history = 100000;

      font = {
        normal = { family = "JetBrainsMono Nerd Font"; style = "Regular"; };
        bold = { family = "JetBrainsMono Nerd Font"; style = "Bold"; };
        italic = { family = "JetBrainsMono Nerd Font"; style = "Italic"; };
        bold_italic = { family = "JetBrainsMono Nerd Font"; style = "Bold Italic"; };
        size = 14;
      };

      cursor.style = { shape = "Block"; blinking = "On"; };

      selection.save_to_clipboard = true;

      # Colors come from catppuccin/nix (macchiato) — see modules/home/default.nix.

      keyboard.bindings = [
        { key = "N"; mods = "Command"; action = "CreateNewWindow"; }
        # Disable macOS default Cmd-T new tab — Alacritty's tab story is poor;
        # use AeroSpace workspaces / tmux windows instead.
        { key = "T"; mods = "Command"; chars = "CreateNewWindow"; }
      ];
    };
  };
}
