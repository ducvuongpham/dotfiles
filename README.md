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

```bash
# 1. install Determinate Nix (or any nix with flakes)
curl -fsSL https://install.determinate.systems/nix | sh -s -- install

# 2. clone — preferred path is ~/dotfiles. If you must clone elsewhere
#    (e.g. ~/.dotfiles), modules/home/zsh.nix activation creates a
#    ~/dotfiles → <clone-path> shim so legacy refs in this repo resolve.
git clone git@git.tada.io.vn:tada/dotfiles.git ~/dotfiles
cd ~/dotfiles

# 3. first build (replace tada-mbp with your host)
#    NOTE: zsh chokes on the `#`, so prefix with noglob (or use \#).
noglob nix run nix-darwin -- switch --flake .#tada-mbp
```

After the first switch, `darwin-rebuild` and `home-manager` are on PATH,
and the `drs`/`nhs`/`nhh` aliases work hostname-aware.

## Manual steps not in nix

macOS gates several APIs behind TCC (privacy permission prompts). nix
cannot grant these — you must approve them once after the first switch.
Until you do, the bits below misbehave silently.

| What                          | Where to grant                                                | Symptom if missing                                                              |
| ----------------------------- | ------------------------------------------------------------- | ------------------------------------------------------------------------------- |
| SketchyBar bar widgets        | System Settings → Privacy & Security → **Screen Recording**   | Bar items array stays empty; `--query default_menu_items` returns a perm error  |
| SketchyBar brightness widget  | (same as above)                                               | Per-display UUID resolution fails                                               |
| Karabiner-Elements key remap  | System Settings → Privacy & Security → **Input Monitoring** + driverkit extension approval | Caps-lock → esc/ctrl mapping doesn't fire; keyboard type wrong |
| Terminal full-disk operations | System Settings → Privacy & Security → **Full Disk Access**   | `brew bundle` complains it can't remove some cask files during cleanup          |
| Accessibility (AeroSpace etc.)| System Settings → Privacy & Security → **Accessibility**      | Window focus / move commands silently no-op                                     |

After granting, restart the affected service:

```bash
brew services restart sketchybar borders
# Karabiner-Elements: open the app once so it loads the new permission
```

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
