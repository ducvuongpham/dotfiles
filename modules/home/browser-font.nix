{ pkgs, lib, ... }:
{
  # Set the monospace font for Chromium-based browsers (Brave) by patching
  # the per-profile Preferences JSON. Skipped while the browser is running
  # because Chromium rewrites the file on quit and would clobber our edit.
  home.activation.setBraveFont = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    pref="$HOME/Library/Application Support/BraveSoftware/Brave-Browser/Default/Preferences"
    if [ -f "$pref" ]; then
      if /usr/bin/pgrep -x "Brave Browser" >/dev/null 2>&1; then
        echo "[browser-font] Brave is running — skipping font patch"
      else
        ${pkgs.jq}/bin/jq '
          .webkit.webprefs.fonts.fixed.Zyyy    = "JetBrainsMono Nerd Font"
          | .webkit.webprefs.fonts.standard.Zyyy = "JetBrainsMono Nerd Font"
          | .webkit.webprefs.fonts.serif.Zyyy   = "JetBrainsMono Nerd Font"
          | .webkit.webprefs.fonts.sansserif.Zyyy = "JetBrainsMono Nerd Font"
        ' "$pref" > "$pref.tmp" && /bin/mv "$pref.tmp" "$pref"
      fi
    fi
  '';
}
