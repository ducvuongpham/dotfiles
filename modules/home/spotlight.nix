{ pkgs, lib, config, ... }:
let
  apps = pkgs.buildEnv {
    name = "home-manager-applications";
    paths = config.home.packages;
    pathsToLink = [ "/Applications" ];
  };
in
{
  # Spotlight skips /nix/store, and macOS TCC re-prompts on every nix-store path
  # change. Copy bundles to a stable ~/Applications path so TCC keys on a
  # stable location; only re-copy when the underlying /nix/store target changes
  # (tracked via .nix-source marker file).
  home.activation.copyApplications = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    app_folder="$HOME/Applications/Home Manager Apps"
    rm -rf "$app_folder.hm-backup"
    mkdir -p "$app_folder"

    while IFS= read -r -d "" app; do
      target_name="$(basename "$app")"
      target_path="$app_folder/$target_name"
      source_real="$(readlink -f "$app")"
      marker="$target_path/.nix-source"

      if [ ! -d "$target_path" ] || [ ! -f "$marker" ] || [ "$(cat "$marker" 2>/dev/null)" != "$source_real" ]; then
        rm -rf "$target_path"
        ${pkgs.coreutils}/bin/cp -R "$source_real" "$target_path"
        # cp from /nix/store is read-only; restore writability so we can drop the marker.
        chmod -R u+w "$target_path"
        echo "$source_real" > "$marker"
      fi
    done < <(find ${apps}/Applications -maxdepth 1 -mindepth 1 -print0 2>/dev/null)
  '';
}
