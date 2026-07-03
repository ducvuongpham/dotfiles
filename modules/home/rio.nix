{ pkgs, ... }:
{
  programs.rio = {
    enable = true;
    # Bundle installed via nix-darwin environment.systemPackages so Rio.app lands
    # in /Applications/Nix Apps (Spotlight-indexed). HM only manages settings.
    package = null;

    # Settings mirror modules/home/alacritty.nix so Rio matches Alacritty's look
    # and feel. Colors are NOT set here: catppuccin/nix merges a [colors] block
    # (macchiato) into programs.rio.settings, the same palette source Alacritty
    # uses — see modules/home/default.nix.
    settings = {
      # Match Alacritty's env.TERM so tmux/terminfo see the same terminal.
      env-vars = [ "TERM=xterm-256color" ];

      # Alacritty option_as_alt = "Both": let both Option keys send Alt on macOS.
      option-as-alt = "both";

      # Alacritty scrolling.history = 100000.
      scrollback-history-limit = 100000;

      # Alacritty selection.save_to_clipboard = true.
      copy-on-select = true;

      # Alacritty quits without a confirmation prompt; match that.
      confirm-before-quit = false;

      # Bold text uses the bright palette (8-15) instead of normal colors, so
      # shell prompt / syntax highlighting look more vivid (less "bland").
      draw-bold-text-with-light-colors = true;

      window = {
        opacity = 1.0; # opaque; 0.97 let the wallpaper bleed through and mute colors
        decorations = "Buttonless";
        mode = "Windowed"; # AeroSpace tiles it; matches Alacritty startup_mode
        # Rio has no window padding option (unlike Alacritty padding x/y); it
        # manages its own internal cell padding.
      };

      fonts = {
        size = 14;
        family = "JetBrainsMono Nerd Font";
        # Enable OpenType ligature/contextual-alternate features. Without this
        # Rio only shapes repeated-glyph ligatures (==, ===) and skips mixed
        # ones (=>, ->, !=). (Alacritty has no ligatures at all.)
        features = [ "calt" "liga" "dlig" ];
        # Per-slot `style` is SLANT only — Rio accepts "Normal" / "Italic", NOT
        # weight names (the old "Medium"/"Bold" strings made Rio reject the whole
        # config). Weight is a SEPARATE numeric field: bump the body to 500
        # so text isn't razor-thin on macOS. 700 = Bold; drop toward 500/600 if
        # too heavy.
        regular = { style = "Normal"; weight = 700; };
        bold.style = "Normal";
        italic.style = "Italic";
        bold-italic.style = "Italic";
      };

      cursor = {
        shape = "block";
        blinking = true; # Alacritty cursor.style.blinking = "On"
      };

      navigation = {
        # This Rio version only accepts Plain / Tab (TopTab is not a valid
        # variant here). "Tab" is the slim strip; tab visibility comes from the
        # colours below now that the config actually parses.
        mode = "Tab";
      };

      # Split-panel divider: default colors.split (#292527) is invisible on the
      # dark bg — set it to the catppuccin lavender accent so the line between
      # panels shows. catppuccin merges the rest of [colors]; this only adds
      # `split` (and overrides the two tab colours below).
      #
      # Tabs: catppuccin sets the INACTIVE tab background to #24273a — the same
      # as the terminal background — so inactive tabs vanish into the bar. Force
      # a visible surface colour so every tab reads as a distinct block; the
      # active tab stays lavender. mkForce is needed because catppuccin already
      # defines these keys.
      colors = {
        split = "#b7bdf8";
        tabs = pkgs.lib.mkForce "#494d64"; # inactive tab bg (surface1)
        tabs-foreground = pkgs.lib.mkForce "#a5adcb"; # inactive tab text
      };

      # Mirror the tmux keybindings (home/tmux/tmux.conf) so Rio's own
      # splits/tabs feel the same WITHOUT tmux — which is what lets image.nvim /
      # pets.nvim render free of the tmux-passthrough cursor flicker.
      #
      # tmux drives everything from a prefix (C-Space) that Rio has no equivalent
      # for, so prefixed binds are remapped onto Cmd (super) as the stand-in,
      # keeping tmux's *letter* choices. The one prefix-free tmux group,
      # `M-arrow` pane focus, copies exactly to Alt+arrows.
      #
      # `with` is quoted because it is a reserved word in Nix.
      #
      # Not copied (no Rio equivalent): directional resize left/right, pane swap,
      # window swap, rename, and the tmux plugins (resurrect/continuum session
      # persistence, sessionx, floax, thumbs, extrakto). Rio also keeps its
      # native Cmd-T (new tab ~ tmux `c`), Cmd-W (close ~ tmux `x`), and
      # Cmd-Shift-[ / ] (tab nav ~ tmux window nav); Cmd-C/Cmd-X stay copy/cut.
      bindings = {
        keys = [
          # tmux `prefix |` (split -h, side by side) / `prefix -` (split -v, stacked)
          { key = "\\"; "with" = "super"; action = "SplitRight"; }
          { key = "-"; "with" = "super"; action = "SplitDown"; }
          # tmux `M-Left/Right/Up/Down` (no prefix) pane focus — 1:1 to Alt+arrows.
          # Rio has only next/prev split, so left/up = prev, right/down = next.
          { key = "left"; "with" = "alt"; action = "SelectPrevSplit"; }
          { key = "up"; "with" = "alt"; action = "SelectPrevSplit"; }
          { key = "right"; "with" = "alt"; action = "SelectNextSplit"; }
          { key = "down"; "with" = "alt"; action = "SelectNextSplit"; }
          # tmux `prefix h/j/k/l` (vim pane focus) → Cmd+h/j/k/l.
          { key = "h"; "with" = "super"; action = "SelectPrevSplit"; }
          { key = "k"; "with" = "super"; action = "SelectPrevSplit"; }
          { key = "l"; "with" = "super"; action = "SelectNextSplit"; }
          { key = "j"; "with" = "super"; action = "SelectNextSplit"; }
          # tmux `prefix H/J/K/L` (resize) → Cmd+Shift+Up/Down (Rio moves the
          # divider up/down only; there is no left/right divider action).
          { key = "up"; "with" = "super | shift"; action = "MoveDividerUp"; }
          { key = "down"; "with" = "super | shift"; action = "MoveDividerDown"; }
        ];
      };
    };
  };
}
