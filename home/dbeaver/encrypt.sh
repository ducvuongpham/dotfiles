#!/usr/bin/env bash
# Push local DBeaver connections + credentials into the dotfiles repo as
# sops-encrypted files. Run this after making changes in DBeaver that you
# want to sync to other devices, then commit + push.
#
# One-time bootstrap on a brand-new dotfiles checkout:
#   1. mkdir -p ~/.config/sops/age && age-keygen -o ~/.config/sops/age/keys.txt
#   2. Paste `age-keygen -y ~/.config/sops/age/keys.txt` into .sops.yaml as
#      the pc391_macbook recipient.
#   3. Run this script to produce the initial encrypted files.
#   4. Set `local.dbeaver.enable = true;` in home/pc391.nix and rebuild.
set -euo pipefail

DOTFILES="${DOTFILES_DIR:-$HOME/.dotfiles}"
DBEAVER_DIR="$HOME/Library/DBeaverData/workspace6/General/.dbeaver"
SECRETS_DIR="$DOTFILES/secrets/dbeaver"

if [ ! -d "$DBEAVER_DIR" ]; then
  echo "DBeaver workspace not found at $DBEAVER_DIR" >&2
  exit 1
fi

if ! command -v sops >/dev/null 2>&1; then
  echo "sops not on PATH. Run darwin-rebuild first (sops is in modules/home/packages.nix)." >&2
  exit 1
fi

mkdir -p "$SECRETS_DIR"

encrypt_one() {
  local file="$1"
  local src="$DBEAVER_DIR/$file"
  local dst="$SECRETS_DIR/${file%.json}.enc"
  if [ ! -r "$src" ]; then
    echo "skip: $file (not present in DBeaver workspace)"
    return
  fi
  # Copy first, then encrypt in-place so sops matches the in-repo path against
  # the path_regex in .sops.yaml (rules match against the file path sops sees).
  cp "$src" "$dst"
  ( cd "$DOTFILES" && sops --encrypt --in-place --input-type binary --output-type binary "${dst#"$DOTFILES/"}" )
  echo "encrypted: $file -> ${dst#"$DOTFILES/"}"
}

encrypt_one credentials-config.json
encrypt_one data-sources.json

cat <<EOF

Done. Review and commit:
  cd "$DOTFILES" && git diff secrets/dbeaver
  git add secrets/dbeaver && git commit -m "dbeaver: sync secrets"
EOF
