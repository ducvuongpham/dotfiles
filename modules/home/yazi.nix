{ pkgs, ... }:
{
  programs.yazi = {
    enable = true;
    package = pkgs.yazi;
    enableZshIntegration = false; # programs.zsh.enable = false; we wire shellWrapperName below

    settings = {
      manager = {
        ratio = [ 1 4 3 ];
        sort_by = "natural";
        sort_dir_first = true;
        sort_sensitive = false;
        sort_reverse = false;
        linemode = "size";
        show_hidden = false;
        show_symlink = true;
      };
      preview = {
        image_filter = "lanczos3";
        image_quality = 90;
        tab_size = 2;
        max_width = 1000;
        max_height = 1000;
        cache_dir = "";
        ueberzug_scale = 1;
        ueberzug_offset = [ 0 0 0 0 ];
      };
      opener = {
        edit = [ { run = ''nvim "$@"''; block = true; } ];
        open = [ { run = ''open "$@"''; desc = "Open"; } ];
      };
    };

    keymap = {
      manager.prepend_keymap = [
        { on = [ "<C-h>" ]; run = "escape --filter"; desc = "clear filter"; }
        { on = "y"; run = [ "yank" "shell -- echo \"$@\" | xclip -selection clipboard" ]; desc = "yank to clipboard"; }
      ];
    };
  };

  # `y` shell function: launch yazi, cd to last dir on quit.
  # Defined in zsh.nix .zshrc so it can mutate parent shell's PWD.
}
