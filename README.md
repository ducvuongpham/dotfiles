# dotfiles

macOS system + user config managed by [nix-darwin](https://github.com/LnL7/nix-darwin) and
[home-manager](https://github.com/nix-community/home-manager), wired together with a flake.

Theme: [Catppuccin Macchiato](https://github.com/catppuccin/nix) (system-wide).

## Hosts

| host       | system          | user |
| ---------- | --------------- | ---- |
| `tada-mbp` | `aarch64-darwin` | `tada` |

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

# 2. clone
git clone git@git.tada.io.vn:tada/dotfiles.git ~/dotfiles
cd ~/dotfiles

# 3. first build (replace tada-mbp with your host)
nix run nix-darwin -- switch --flake .#tada-mbp
```

After the first switch, `darwin-rebuild` and `home-manager` are on PATH.

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
