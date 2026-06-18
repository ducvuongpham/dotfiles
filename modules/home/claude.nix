{ config, lib, ... }:
{
  # ~/.claude/settings.json — small, static, edit-it-and-it-syncs.
  # Tracked alongside it: CLAUDE.md (global instructions), RTK.md (@-referenced
  # by CLAUDE.md), and the hand-written skills/lang-coach. Everything else under
  # ~/.claude (settings.local.json per-project permissions, sessions/projects/
  # cache/history, other skills/plugins) is per-machine state and NOT tracked.
  # Credentials live in the macOS Keychain entry "Claude Code-credentials" —
  # iCloud Keychain syncs that across Macs; otherwise re-run `claude login`.
  home.file.".claude/settings.json".source =
    config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/dotfiles/home/claude/settings.json";

  # Global instructions + its @-referenced include.
  home.file.".claude/CLAUDE.md".source =
    config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/dotfiles/home/claude/CLAUDE.md";

  home.file.".claude/RTK.md".source =
    config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/dotfiles/home/claude/RTK.md";

  # Hand-written skill — lang-coach (English+Japanese learning, always-on).
  home.file.".claude/skills/lang-coach".source =
    config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/dotfiles/home/claude/skills/lang-coach";

  # Status line script — referenced by settings.json statusLine.command.
  home.file.".claude/statusline.sh".source =
    config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/dotfiles/home/claude/statusline.sh";

  # Caveman mode tracker — UserPromptSubmit hook that writes /caveman <mode> to .caveman-active.
  home.file.".claude/caveman-track.sh".source =
    config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/dotfiles/home/claude/caveman-track.sh";
}
