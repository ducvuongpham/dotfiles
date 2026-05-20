# DBeaver backup & restore

DBeaver connections + credentials are synced across devices via sops-nix.
This doc covers how to back things up, restore on a new machine, and
recover from common failure modes.

## What's managed

Two files inside `~/Library/DBeaverData/workspace6/General/.dbeaver/`:

| File                       | Contains                                          | Sensitive? |
|----------------------------|---------------------------------------------------|------------|
| `credentials-config.json`  | DBeaver-encrypted blob of saved passwords         | yes — encrypted at rest |
| `data-sources.json`        | Connection definitions (host, port, user, db…)    | yes — server topology  |

Both are stored encrypted in `~/.dotfiles/secrets/dbeaver/*.enc` (sops + age),
decrypted to `~/.config/sops-nix/secrets/` on every `darwin-rebuild switch`,
then copied into the DBeaver workspace by an activation script
(`modules/home/dbeaver-secrets.nix`).

**Not managed**: `project-metadata.json`, `project-settings.json`, any
workbench layout / window state. Recreate as needed on each device.

## ⚠ One-time prerequisite: DBeaver master password

DBeaver's default key for `credentials-config.json` is **per-installation**.
Without changing this, syncing `credentials-config.json` to another machine
gives you connections with blank passwords — DBeaver on machine B can't
decrypt machine A's blob.

Fix once: **DBeaver → Settings → Connections → Security → Use master password**,
set a strong password. DBeaver re-encrypts existing credentials with it. After
that, the file is portable across any machine where you can type the master
password.

Remember the master password the same way you remember your age private key
(see below). Losing it means losing access to saved DBeaver passwords.

## What to back up out-of-band

Two secrets are **not** in this repo and must be backed up manually. Lose them
and the encrypted state in the repo becomes unrecoverable:

1. **`~/.config/sops/age/keys.txt`** — the age private key. Without it,
   nothing in `secrets/` decrypts. Store it in 1Password, a hardware key,
   or encrypted USB. Do not put it in iCloud / Dropbox unencrypted.
2. **DBeaver master password** — see the section above. Treat it like any
   important password (1Password, etc.).

Anyone who has *both* the age key *and* the master password can decrypt
everything. Anyone with only one has nothing useful.

## Daily flow: push local DBeaver changes to dotfiles

After adding / editing connections or passwords in DBeaver:

```bash
~/.dotfiles/home/dbeaver/encrypt.sh
cd ~/.dotfiles
git diff secrets/dbeaver      # sanity-check the changes
git add secrets/dbeaver
git commit -m "dbeaver: sync secrets"
git push
```

The script:

1. Copies `credentials-config.json` and `data-sources.json` from the DBeaver
   workspace into `secrets/dbeaver/*.enc`.
2. Runs `sops --encrypt --in-place` so the files are encrypted to every age
   recipient listed in `.sops.yaml`.

Close DBeaver before running `encrypt.sh` if you can — DBeaver may rewrite
the files while you encrypt, producing a torn snapshot.

## Pull updates from another device

```bash
cd ~/.dotfiles
git pull
sudo darwin-rebuild switch --flake .
```

The activation script overwrites your local DBeaver files. **Dotfiles is the
source of truth** — any local DBeaver edit made since your last `encrypt.sh`
will be lost on the next rebuild. If you've been editing locally, run
`encrypt.sh` and commit *before* pulling.

## Restoring on a brand-new machine

This is the "I have a new Mac" / "I reinstalled macOS" path.

```bash
# 1. Bootstrap nix-darwin and clone dotfiles as you normally would.
git clone <dotfiles-remote> ~/.dotfiles

# 2. Restore the age private key from your out-of-band backup.
#    Copy keys.txt from 1Password (or wherever) into:
mkdir -p ~/.config/sops/age
# (paste contents into the file via your password manager — never email/Slack it)
chmod 600 ~/.config/sops/age/keys.txt

# 3. Build the system. DBeaver files appear in ~/Library/DBeaverData/... .
cd ~/.dotfiles
sudo darwin-rebuild switch --flake .

# 4. Install DBeaver (if not already managed via homebrew.nix), open it,
#    and enter your master password when prompted.
```

If you forgot to back up the age key, see "Recovery scenarios" below.

## Adding a second device (you still have access on device A)

On the new device:

```bash
mkdir -p ~/.config/sops/age
age-keygen -o ~/.config/sops/age/keys.txt
chmod 600 ~/.config/sops/age/keys.txt
age-keygen -y ~/.config/sops/age/keys.txt    # copy the age1... output
```

On a device that already has decryption access, edit `~/.dotfiles/.sops.yaml`
and add the new recipient:

```yaml
keys:
  - &pc391_macbook  age1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
  - &pc391_otherdev age1yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy  # new

creation_rules:
  - path_regex: secrets/.*\.enc$
    age:
      - *pc391_macbook
      - *pc391_otherdev
```

Then re-encrypt the existing secrets to the expanded recipient set:

```bash
cd ~/.dotfiles
sops updatekeys secrets/dbeaver/credentials-config.enc
sops updatekeys secrets/dbeaver/data-sources.enc
git add .sops.yaml secrets/dbeaver
git commit -m "sops: add <device> as recipient"
git push
```

On the new device: `git pull`, then enable the module
(`local.dbeaver.enable = true;` in `home/pc391.nix`) and rebuild.

## Recovery scenarios

### Lost the age private key, still have one device that works
Generate a fresh key on the working device, re-encrypt everything to it, and
treat the old key as compromised:

```bash
mkdir -p ~/.config/sops/age
mv ~/.config/sops/age/keys.txt ~/.config/sops/age/keys.txt.old   # if it still exists
age-keygen -o ~/.config/sops/age/keys.txt
chmod 600 ~/.config/sops/age/keys.txt
# Replace the recipient in .sops.yaml with the new public key, then:
cd ~/.dotfiles
sops updatekeys secrets/dbeaver/credentials-config.enc
sops updatekeys secrets/dbeaver/data-sources.enc
```

`sops updatekeys` uses your *current* key to decrypt and the *new* recipient
list to re-encrypt — so it only works while you still have a working key.

### Lost the age private key and have no working device
The encrypted secrets are unrecoverable by design. Recover by re-creating:

1. Open DBeaver on the new machine.
2. Re-enter connections manually (host, port, user, password).
3. Generate a fresh age key, run `encrypt.sh`, force-push to overwrite the
   broken encrypted files.

This is the worst case. It's why backing up `keys.txt` matters.

### Lost the DBeaver master password
You still have connection metadata (`data-sources.json`), but passwords are
gone. In DBeaver: clear the master password (Settings → Connections →
Security → Reset), then re-enter passwords per connection. Run `encrypt.sh`
afterward to sync the new state.

### Local DBeaver edit got clobbered by a rebuild
By design — dotfiles is the source of truth. Recover the lost edit from
DBeaver's own undo, or from a prior `secrets/dbeaver/*.enc` version via:

```bash
cd ~/.dotfiles
git log -- secrets/dbeaver
git show <sha>:secrets/dbeaver/data-sources.enc > /tmp/old.enc
sops -d --input-type binary --output-type binary /tmp/old.enc
```

## Troubleshooting

### `error loading config: no matching creation rules found`
Run `sops` from inside `~/.dotfiles/` so the `.sops.yaml` `path_regex` matches
the file's repo-relative path. The `encrypt.sh` helper handles this; if you're
running `sops` directly, `cd ~/.dotfiles && sops ...` or pass `--config`.

### `Path 'modules/home/dbeaver-secrets.nix' is not tracked by Git`
Nix flakes can only see git-tracked files. After creating new files run
`git add -A` (without committing) so the next `darwin-rebuild` succeeds.

### Activation runs but DBeaver files unchanged
Check activation order in the rebuild output:

```
Activating sops-nix              ← must come first
Activating dbeaverSecretsSync    ← then this
```

If reversed, `dbeaverSecretsSync` saw empty source paths. Verify
`modules/home/dbeaver-secrets.nix` declares
`entryAfter [ "writeBoundary" "sops-nix" ]`.

### "Authentication failed" on a connection that worked before
The master password layer can't decrypt — probably a master-password change
between machines, or a corrupted credentials file. In DBeaver: edit the
connection → re-enter the password → close DBeaver → run `encrypt.sh`.

### Disabling the module temporarily
Set `local.dbeaver.enable = false;` in `home/pc391.nix` and rebuild. The
encrypted files remain in the repo, but no copying happens on activation.
Useful for one-off experiments where you don't want dotfiles overwriting
local DBeaver state.
