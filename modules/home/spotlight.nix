{ ... }:
{
  # GUI apps installed via nix-darwin environment.systemPackages → rsynced to
  # /Applications/Nix Apps (Spotlight-indexed). HM doesn't need to manage them.
  targets.darwin.linkApps.enable = false;
  targets.darwin.copyApps.enable = false;
}
