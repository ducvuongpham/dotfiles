{ pkgs, lib, config, ... }:
{
  # Raycast itself is installed via brew cask (modules/darwin/homebrew.nix).
  # This module ships a tracked .rayconfig and triggers Raycast's import flow
  # on first bootstrap so a fresh machine doesn't need manual setup of
  # extensions / quicklinks / aliases.
  #
  # Raycast has no headless import — `open -a Raycast <file>` shows the
  # import dialog you click once. We touch a marker after firing it so
  # subsequent rebuilds skip. To force a re-import: delete the marker.
  home.activation.importRaycastConfig =
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      marker="$HOME/.config/raycast/.imported"
      config="$HOME/dotfiles/home/raycast/tada.rayconfig"

      if [ ! -f "$marker" ] && [ -f "$config" ]; then
        /bin/mkdir -p "$(dirname "$marker")"
        # Async — the import dialog blocks until you click; don't wedge
        # the home-manager activation behind a UI.
        /usr/bin/open -a Raycast "$config" || true
        /usr/bin/touch "$marker"
      fi
    '';
}
