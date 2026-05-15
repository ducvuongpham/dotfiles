{ config, ... }:
{
  # ccstatusline writes ~/.config/ccstatusline/settings.json from its TUI.
  # mkOutOfStoreSymlink so TUI edits land in the dotfiles repo directly —
  # commit when satisfied. Initial seed is just `{}`; run `ccstatusline` once
  # to populate via the TUI.
  # The ccstatusline binary itself comes from mise (home/mise/config.toml,
  # tool "npm:ccstatusline"), wired into Claude via statusLine.command in
  # home/claude/settings.json.
  home.file.".config/ccstatusline/settings.json".source =
    config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/dotfiles/home/ccstatusline/settings.json";
}
