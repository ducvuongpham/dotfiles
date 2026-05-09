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
        startup_mode = "Maximized";
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

      # Tokyo Night Storm
      colors = {
        primary = { background = "#24283b"; foreground = "#c0caf5"; };
        normal = {
          black = "#1d202f";
          red = "#f7768e";
          green = "#9ece6a";
          yellow = "#e0af68";
          blue = "#7aa2f7";
          magenta = "#bb9af7";
          cyan = "#7dcfff";
          white = "#a9b1d6";
        };
        bright = {
          black = "#414868";
          red = "#f7768e";
          green = "#9ece6a";
          yellow = "#e0af68";
          blue = "#7aa2f7";
          magenta = "#bb9af7";
          cyan = "#7dcfff";
          white = "#c0caf5";
        };
      };

      keyboard.bindings = [
        { key = "N"; mods = "Command"; action = "CreateNewWindow"; }
      ];
    };
  };
}
