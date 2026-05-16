{ config, ... }:
{
  # sleepwatcher (brew formula in modules/darwin/homebrew.nix) runs ~/.sleep
  # on sleep and ~/.wakeup on wake. We use it solely for ~/.wakeup → restart
  # sketchybar because the AeroSpace<->sketchybar trigger IPC sometimes drops
  # events after the system wakes, leaving the workspace indicator stale.
  home.file.".wakeup".source =
    config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/dotfiles/home/sleepwatcher/wakeup.sh";
}
