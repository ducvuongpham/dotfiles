{ ... }:
{
  # HM built-in app handling for macOS:
  # - linkApps off → no /nix/store symlinks under ~/Applications/Home Manager Apps
  # - copyApps on  → real bundle copies to ~/Applications/Home Manager Apps
  # Stable paths keep TCC permissions across switches; Spotlight indexes them.
  targets.darwin.linkApps.enable = false;
  targets.darwin.copyApps.enable = true;
}
