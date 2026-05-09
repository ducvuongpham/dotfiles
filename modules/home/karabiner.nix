{ ... }:
{
  # Karabiner-Elements installed via brew cask. Config = JSON at
  # ~/.config/karabiner/karabiner.json. Minimal starter: caps_lock -> escape (tap)
  # / control (hold). Extend rules as needed.
  home.file.".config/karabiner/karabiner.json".text = builtins.toJSON {
    global = {
      check_for_updates_on_startup = true;
      show_in_menu_bar = false;
      show_profile_name_in_menu_bar = false;
    };
    profiles = [
      {
        name = "Default";
        selected = true;
        simple_modifications = [ ];
        complex_modifications = {
          rules = [
            {
              description = "caps_lock -> esc (tap) / left_control (hold)";
              manipulators = [
                {
                  type = "basic";
                  from = {
                    key_code = "caps_lock";
                    modifiers.optional = [ "any" ];
                  };
                  to = [ { key_code = "left_control"; } ];
                  to_if_alone = [ { key_code = "escape"; } ];
                }
              ];
            }
            {
              description = "left_control -> esc (tap) / left_control (hold)";
              manipulators = [
                {
                  type = "basic";
                  from = {
                    key_code = "left_control";
                    modifiers.optional = [ "any" ];
                  };
                  to = [ { key_code = "left_control"; } ];
                  to_if_alone = [ { key_code = "escape"; } ];
                }
              ];
            }
            {
              description = "right_control -> esc (tap) / right_control (hold)";
              manipulators = [
                {
                  type = "basic";
                  from = {
                    key_code = "right_control";
                    modifiers.optional = [ "any" ];
                  };
                  to = [ { key_code = "right_control"; } ];
                  to_if_alone = [ { key_code = "escape"; } ];
                }
              ];
            }
          ];
        };
        virtual_hid_keyboard = {
          keyboard_type_v2 = "jis";
        };
      }
    ];
  };
}
