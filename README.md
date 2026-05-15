# dotfiles

macOS system + user config managed by [nix-darwin](https://github.com/LnL7/nix-darwin) and
[home-manager](https://github.com/nix-community/home-manager), wired together with a flake.

Theme: [Catppuccin Macchiato](https://github.com/catppuccin/nix) (system-wide).

## Hosts

| host                       | system            | user      | keyboard |
| -------------------------- | ----------------- | --------- | -------- |
| `tada-mbp`                 | `aarch64-darwin`  | `tada`    | jis      |
| `pishi391noMacBook-Pro`    | `aarch64-darwin`  | `pc391`   | ansi     |

Per-host overrides go in `hosts/<host>/meta.nix`. Supported fields:
`system`, `username`, `keyboardType` (`ansi` | `iso` | `jis`).

## Layout

```
flake.nix              # entry — declares hosts, pins inputs
hosts/<host>/          # per-host darwin module (system-level)
modules/darwin/        # shared darwin modules (homebrew, defaults, …)
modules/home/          # shared home-manager modules (zsh, tmux, nvim, …)
home/                  # raw config files (sketchybar lua, tmux.conf, aerospace.toml scripts, …)
                       # symlinked into $HOME via mkOutOfStoreSymlink so edits apply live
home/<username>.nix    # entry import for the user's home-manager profile
```

`mkOutOfStoreSymlink` is used for anything where I want to edit-and-go without rebuilding
(tmux, sketchybar, aerospace scripts). Pure nix-managed files (most `modules/*.nix`) need a
rebuild to apply.

## Bootstrap

### Pre-flight

Things to know *before* the first `darwin-rebuild`:

- **Hostname must match `hosts/<name>/`.** Set it first or `darwin-rebuild`
  can't find the matching configuration:
  ```bash
  sudo scutil --set HostName       <hostname>
  sudo scutil --set LocalHostName  <hostname>
  sudo scutil --set ComputerName   <hostname>
  ```
- **SSH signing key.** `modules/home/git.nix` enables `commit.gpgsign` against
  `~/.ssh/id_ed25519.pub`. Without the key the first git commit fails with
  `Couldn't load public key`. Generate it before switching:
  ```bash
  ssh-keygen -t ed25519 -C "<your-email>"   # accept default path, set passphrase
  ```
  Then add the public key to GitHub as a **Signing Key** (Settings → SSH and
  GPG keys). The `gitAllowedSigners` activation writes
  `~/.config/git/allowed_signers` on every switch — if the file is empty after
  the first switch, the key didn't exist yet; just rebuild.
- **Repo clone path.** Prefer `~/dotfiles`. If you clone to `~/.dotfiles`
  instead, the `dotfilesShim` activation in `modules/home/zsh.nix` creates a
  `~/dotfiles → ~/.dotfiles` symlink so legacy refs (p10k.zsh path, tmux
  plugin path, `drs`/`nhs`/`nhh` aliases) keep resolving. Cloning to a third
  location won't work without editing those refs.
- **zsh `#` glob.** zsh expands `#` so the bare flake ref errors with
  `no matches found`. Use `noglob`, escape (`\#`), or quote the path:
  ```bash
  noglob nix run nix-darwin -- switch --flake .#<hostname>
  ```

### Steps

```bash
# 1. install Determinate Nix (or any nix with flakes)
curl -fsSL https://install.determinate.systems/nix | sh -s -- install

# 2. clone (see pre-flight note above re: path)
git clone git@git.tada.io.vn:tada/dotfiles.git ~/dotfiles
cd ~/dotfiles

# 3. (optional) generate ed25519 signing key (see pre-flight note)
ssh-keygen -t ed25519 -C "<your-email>"

# 4. first build (replace <hostname> with your `scutil --get LocalHostName`)
noglob sudo nix run nix-darwin -- switch --flake .#<hostname>
```

After the first switch:
- `darwin-rebuild`, `home-manager`, `nh` are on PATH.
- `drs` / `nhs` / `nhh` aliases work hostname-aware.
- A `.zshrc.hm-backup` / `.zshenv.hm-backup` may sit next to the new symlinked
  copies — that's home-manager moving your existing files aside. Delete when
  you're sure the new config is what you want.
- Grant the macOS TCC permissions in the next section, otherwise SketchyBar,
  Karabiner, AeroSpace will misbehave silently.

## System permissions (post-switch checklist)

macOS gates several APIs behind TCC (privacy permission prompts) and
driver-extension approval flows. nix cannot grant these — you must approve
them once after the first switch. Until you do, the bits below misbehave
silently (no error, just nothing happens).

Open **System Settings → Privacy & Security** and walk down the list:

| Panel                              | App / target                          | Why it's needed                                                                 |
| ---------------------------------- | ------------------------------------- | ------------------------------------------------------------------------------- |
| **Screen Recording**               | SketchyBar                            | Reads menu-bar items, display info (brightness widget needs per-display UUIDs)  |
| **Input Monitoring**               | Karabiner-Elements, Karabiner-EventViewer | Captures key events for caps-lock → esc/ctrl remap                          |
| **Input Monitoring**               | KeyCastr                              | Shows pressed keys on screen during presentations/screen-share                  |
| **Accessibility**                  | AeroSpace                             | Window focus / move / workspace switching                                       |
| **Accessibility**                  | Maccy                                 | Listens for the global Cmd-Shift-V hotkey                                       |
| **Accessibility**                  | Mos                                   | Scrolls under non-Apple mice (system extension hook)                            |
| **Accessibility**                  | Raycast                               | Window management, system commands                                              |
| **Full Disk Access**               | Your terminal (Alacritty / Terminal)  | `brew bundle`'s `zap` step removes files outside `/opt/homebrew`                |
| **Local Network**                  | Telegram, Brave, Microsoft Edge       | Bonjour / LAN discovery — granted on first launch via popup                     |
| **Notifications**                  | Telegram, etc.                        | Granted on first launch                                                         |
| **Login Items & Extensions** → **Background Items** | Karabiner_DriverKit_VirtualHIDDevice, BetterDisplay driver | Driver extensions need to be **Allowed** here AND under "System software from…" at the bottom of the panel |
| **Login Items**                    | (Optional) AeroSpace, sketchybar, borders, Karabiner-Elements, Maccy | If you want them to launch at login. Most are already wired via launchd / brew services in `modules/darwin/`. |

After granting Screen Recording / Input Monitoring / Accessibility, restart
the affected services so they re-read the permission:

```bash
brew services restart sketchybar borders
killall aerospace; aerospace &        # or just log out / in
open -a "Karabiner-Elements"          # opens the GUI; loads new perms
```

A few extras that aren't TCC but still need a one-time tap:

- **Touch ID for sudo** — `modules/darwin/default.nix` sets
  `security.pam.services.sudo_local.touchIdAuth = true`. macOS may require
  a logout/reboot before Touch ID actually prompts. Test with `sudo -k; sudo true`.
- **DriverKit extensions (Karabiner, BlackHole, BetterDisplay)** — after
  install, macOS shows a banner "System software from <vendor> requires
  approval" in **Privacy & Security**. Approve once, then reboot for the
  extension to load.
- **Karabiner profile** — after granting permissions, launch
  Karabiner-Elements once and confirm the "Default" profile is active. The
  profile JSON is at `~/.config/karabiner/karabiner.json` (nix-managed).

### Things nix does manage but require state outside the repo

- **TPM plugins** — `modules/home/tmux.nix` clones tpm + runs `install_plugins`
  on every `home-manager` activation. If the plugin dirs got nuked, just run
  `darwin-rebuild switch` again.
- **z4h cache** — `modules/home/zsh.nix` writes a `.zshenv` that bootstraps
  z4h on the first interactive shell. If z4h goes into "recovery mode",
  `rm -rf ~/.cache/zsh4humans/v5` and `exec zsh`.
- **nixpkgs package-name cache** (for `command_not_found_handler`) —
  `command_not_found_handler` in `modules/home/zsh.nix` builds
  `~/.cache/nix-pkg-names` lazily on the first miss (one-time ~30s).

## Adding a new machine

Hosts are auto-discovered from `hosts/`. To add a new machine:

```bash
cp -r hosts/tada-mbp hosts/<new-hostname>
# edit hosts/<new-hostname>/meta.nix if system/username/keyboard differ
#   system       = "aarch64-darwin" | "x86_64-darwin"
#   username     = "tada" | ...
#   keyboardType = "ansi" | "iso" | "jis"
# also add home/<username>.nix if you introduced a new user
scutil --set LocalHostName <new-hostname>
noglob darwin-rebuild switch --flake ~/dotfiles#<new-hostname>
```

`flake.nix` needs no edits — it reads `hosts/` at evaluation time.

## Daily rebuild

Using [nh](https://github.com/viperML/nh) (installed by this flake):

```bash
nh os switch ~/dotfiles      # full system rebuild
nh home switch ~/dotfiles    # home-manager only (faster)
```

Or vanilla:

```bash
darwin-rebuild switch --flake ~/dotfiles
home-manager switch --flake ~/dotfiles
```

Flake inputs update:

```bash
nix flake update
```

## Tools wired up

- **WM:** [AeroSpace](https://github.com/nikitabobko/AeroSpace) — i3-style tiling, alt-prefixed bindings
- **Bar:** [sketchybar](https://github.com/FelixKratz/SketchyBar) + SbarLua (compiled on activation)
- **Terminal:** [Alacritty](https://github.com/alacritty/alacritty) + [tmux](https://github.com/tmux/tmux) (TPM bootstrapped)
- **Shell:** zsh + [zsh4humans](https://github.com/romkatv/zsh4humans), [atuin](https://github.com/atuinsh/atuin), [fzf-tab](https://github.com/Aloxaf/fzf-tab)
- **Editor:** Neovim
- **Browsers / apps not in nixpkgs:** managed via [`homebrew`](modules/darwin/homebrew.nix) cask

## Secrets

Nothing secret lives in this repo. AWS / SSH / API credentials stay under `~/.aws/`, `~/.ssh/`,
or [fnox](https://fnox.jdx.dev). The repo is intentionally public-publishable.

## Notes

- `home/tmux/plugins/`, `home/nvim/plugged/` are gitignored — populated at runtime by their
  respective plugin managers.
- The Claude Code permission allowlist in `.claude/settings.local.json` is committed so a
  fresh clone gets the same tool permissions; rotate/edit freely.
