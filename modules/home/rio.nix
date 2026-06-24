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
        # Root family applies to every slot; per-slot `style` below only sets
        # the weight (Rio keeps style when family is set at root).
        family = "JetBrainsMono Nerd Font";
        # Enable OpenType ligature/contextual-alternate features. Without this
        # Rio only shapes repeated-glyph ligatures (==, ===) and skips mixed
        # ones (=>, ->, !=). (Alacritty has no ligatures at all.)
        features = [ "calt" "liga" "dlig" ];
        # Slightly bolder body text: Medium instead of Regular. Bold stays Bold
        # so the weight contrast is preserved.
        regular.style = "Medium";
        bold.style = "Bold";
        italic.style = "Medium Italic";
        bold-italic.style = "Bold Italic";
      };

      cursor = {
        shape = "block";
        blinking = true; # Alacritty cursor.style.blinking = "On"
      };

      navigation = {
        # macOS defaults to "NativeTab", whose tab strip reserves space even
        # with a single tab (a blank bar, unlike Alacritty which has no tabs).
        # "Tab" is Rio's own slim strip; hide-if-single (default true) hides it
        # at one tab, so it looks like Alacritty until a 2nd tab exists.
        mode = "Tab";
      };

      # Rio's macOS defaults already bind Cmd-N -> new window and Cmd-T -> new
      # tab. Unlike Alacritty (whose tabs are poor, so we remapped Cmd-T to a
      # window), Rio has first-class tabs — so we keep its native bindings.
    };
  };
}
