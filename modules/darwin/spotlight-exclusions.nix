{ ... }:
{
  # Hide background-only utilities from Spotlight (and consequently from
  # anything that piggy-backs on Spotlight's CoreSpotlight index). Apps that
  # only have a menu-bar UI or are launched via hotkeys / launchd don't need
  # to be searchable. Raycast indexes apps independently — its hidden list
  # has to be set in Raycast's own settings UI.
  system.activationScripts.postActivation.text = ''
    # Hide background-only apps from Spotlight + Finder.
    HIDDEN_APPS=(
      # Maccy left visible to Spotlight/Raycast — useful as a discoverable app.
      "/Applications/Nix Apps/Mos.app"
      "/Applications/Nix Apps/KeyCastr.app"
    )
    /usr/bin/defaults write /Library/Preferences/com.apple.spotlight Exclusions -array "''${HIDDEN_APPS[@]}"
    for app in "''${HIDDEN_APPS[@]}"; do
      [ -e "$app" ] && /usr/bin/chflags hidden "$app" 2>/dev/null || true
    done
    /usr/bin/killall mds 2>/dev/null || true
  '';
}
