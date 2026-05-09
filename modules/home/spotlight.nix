{ pkgs, lib, config, ... }:
let
  apps = pkgs.buildEnv {
    name = "home-manager-applications";
    paths = config.home.packages;
    pathsToLink = [ "/Applications" ];
  };
in
{
  # Spotlight skips /nix/store, so HM-app symlinks into the store stay invisible.
  # mkalias creates real macOS Finder aliases that Spotlight + Raycast index.
  home.activation.aliasApplications = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    app_folder="$HOME/Applications/Home Manager Apps"
    # HM rewrites $app_folder as a /nix/store symlink each switch and dumps our
    # previous aliased dir into ".hm-backup". Clean both up before re-aliasing.
    rm -rf "$app_folder" "$app_folder.hm-backup"
    mkdir -p "$app_folder"
    while IFS= read -r -d "" app; do
      target_name="$(basename "$app")"
      target_path="$app_folder/$target_name"
      ${pkgs.mkalias}/bin/mkalias "$(readlink -f "$app")" "$target_path"
    done < <(find ${apps}/Applications -maxdepth 1 -mindepth 1 -print0 2>/dev/null)
  '';
}
