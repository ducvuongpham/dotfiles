{ ... }:
# Stop Spotlight (and anything that piggy-backs on its index, including
# Raycast's File Search, which calls `mdfind`) from indexing local files.
# Frees `mds` / `mds_stores` CPU+disk and prevents file content from being
# stored in the metadata DB.
#
# Side effects worth knowing:
# - Finder content search and Mail/Photos full-text search stop working
#   (filename search via live filesystem walk still works).
# - Cmd-Space is already remapped to Raycast (see system-defaults.nix), so
#   no launcher impact.
#
# Cosmetic Raycast cleanup (manual, one-time): Raycast → Settings →
# Extensions → File Search → toggle off. Raycast doesn't expose a stable
# defaults key for that, so it's not worth scripting.
#
# To re-enable later: `sudo mdutil -a -i on` (and remove this module).
{
  system.activationScripts.disableSpotlightIndex.text = ''
    /usr/bin/mdutil -a -i off >/dev/null 2>&1 || true
  '';
}
