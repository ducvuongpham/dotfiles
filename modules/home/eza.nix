{ pkgs, lib, config, ... }:
{
  # eza reads ~/.config/eza/theme.yml by default. Fetch the official
  # catppuccin theme from eza-community/eza-themes once and persist it.
  home.activation.fetchEzaTheme = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    target="$HOME/.config/eza/theme.yml"
    if [ ! -f "$target" ]; then
      mkdir -p "$HOME/.config/eza"
      ${pkgs.curl}/bin/curl -fsSL \
        "https://raw.githubusercontent.com/eza-community/eza-themes/main/themes/catppuccin-macchiato.yml" \
        -o "$target" 2>/dev/null || true
    fi
  '';
}
