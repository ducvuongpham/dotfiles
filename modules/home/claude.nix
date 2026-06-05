{ config, lib, ... }:
{
  # ~/.claude/settings.json — small, static, edit-it-and-it-syncs.
  # Other ~/.claude content (settings.local.json with per-project permissions,
  # sessions/projects/cache/history, skills/plugins symlinks) is per-machine
  # state and intentionally NOT tracked.
  # Credentials live in the macOS Keychain entry "Claude Code-credentials" —
  # iCloud Keychain syncs that across Macs; otherwise re-run `claude login`.
  home.file.".claude/settings.json".source =
    config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/dotfiles/home/claude/settings.json";

  # Status line script — referenced by settings.json statusLine.command.
  home.file.".claude/statusline.sh".source =
    config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/dotfiles/home/claude/statusline.sh";

  # Caveman mode tracker — UserPromptSubmit hook that writes /caveman <mode> to .caveman-active.
  home.file.".claude/caveman-track.sh".source =
    config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/dotfiles/home/claude/caveman-track.sh";
}
