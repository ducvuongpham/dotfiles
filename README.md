# dotfiles

My macOS setup as a single command. nix-darwin + home-manager via a flake, Catppuccin Macchiato theme.

Tiling WM (AeroSpace), sketchybar bar, Alacritty + tmux + zsh4humans, Neovim, Karabiner caps-lock remap, Homebrew casks for the rest. Everything declarative — `darwin-rebuild switch` reproduces the whole system.

## Use it as your own

To get my exact setup, you change **three things**: your macOS hostname, the host directory name, and your username. Then run one command.

### 1. Install Nix

```bash
curl -fsSL https://install.determinate.systems/nix | sh -s -- install
```

Restart your terminal so `nix` is on PATH.

### 2. Clone

```bash
git clone https://github.com/<this-repo> ~/dotfiles
cd ~/dotfiles
```

Clone to `~/dotfiles` exactly — several configs reference that path.

### 3. Set your macOS hostname

Pick a hostname (letters, digits, hyphens) and set all three:

```bash
sudo scutil --set HostName       my-mac
sudo scutil --set LocalHostName  my-mac
sudo scutil --set ComputerName   my-mac
```

Verify: `scutil --get LocalHostName` should print `my-mac`.

### 4. Rename the host + user files to match

The flake auto-discovers hosts from `hosts/<hostname>/` and users from `home/<username>.nix`. Rename both to match yours:

```bash
mv hosts/pishi391noMacBook-Pro  hosts/my-mac     # match your scutil hostname
mv home/pc391.nix               home/alice.nix   # match your macOS username (whoami)
```

Then edit `hosts/my-mac/meta.nix`:

```nix
{
  system       = "aarch64-darwin";   # or "x86_64-darwin" on Intel Macs
  username     = "alice";            # match home/<this>.nix and `whoami`
  keyboardType = "ansi";             # "ansi" | "iso" | "jis"
}
```

### 5. Generate an SSH signing key

Git commits are signed with SSH. Without a key, the first commit fails:

```bash
ssh-keygen -t ed25519 -C "you@example.com"   # accept default path
```

(Optional) Add the public key to GitHub as a **Signing Key** so commits show as Verified.

### 6. Build

zsh expands `#` in unquoted args, so prefix with `noglob`:

```bash
noglob sudo nix run nix-darwin -- switch --flake .#my-mac
```

First run takes 10–30 min (downloads + Homebrew casks). Subsequent runs are seconds.

After it finishes:

- `darwin-rebuild`, `home-manager`, `nh` are on PATH
- `drs` / `nhs` / `nhh` shell aliases work (hostname-aware rebuild shortcuts)
- Home-manager may leave `.zshrc.hm-backup` next to its new symlinks — delete once you're happy

### 7. Grant macOS permissions

macOS gates a few APIs behind privacy prompts that Nix can't approve. Open **System Settings → Privacy & Security** and grant:

| Panel                                           | App / target                                                | Why                                                            |
| ----------------------------------------------- | ----------------------------------------------------------- | -------------------------------------------------------------- |
| Screen Recording                                | SketchyBar                                                  | Reads menu-bar items, per-display info                         |
| Input Monitoring                                | Karabiner-Elements, Karabiner-EventViewer, KeyCastr         | Key event capture (caps→esc/ctrl, on-screen keys)              |
| Accessibility                                   | AeroSpace, Maccy, Mos, Raycast                              | Window focus, hotkeys, scroll, automation                      |
| Full Disk Access                                | Your terminal (Alacritty)                                   | `brew bundle` zap step touches files outside `/opt/homebrew`   |
| Login Items & Extensions → Background Items     | Karabiner_DriverKit_VirtualHIDDevice, BetterDisplay driver  | Driver extensions need explicit approval                       |

After granting, restart the affected services:

```bash
brew services restart sketchybar borders
killall aerospace; aerospace &
open -a "Karabiner-Elements"
```

A few one-offs that aren't TCC:

- **Touch ID for sudo** — already enabled in nix; may need a reboot. Test: `sudo -k; sudo true`.
- **DriverKit extensions** — after Karabiner / BlackHole / BetterDisplay install, macOS shows "System software from <vendor> requires approval" in Privacy & Security. Approve, then reboot.

Done. You have my system.

## Daily use

```bash
nh os switch ~/dotfiles      # full system rebuild
nh home switch ~/dotfiles    # home-manager only (faster)
nix flake update             # bump inputs
```

Or vanilla:

```bash
darwin-rebuild switch --flake ~/dotfiles
home-manager switch --flake ~/dotfiles
```

## Adding more machines later

Same flake, more hosts — no flake edits needed:

```bash
cp -r hosts/my-mac hosts/<new-hostname>
# edit hosts/<new-hostname>/meta.nix
scutil --set LocalHostName <new-hostname>
noglob darwin-rebuild switch --flake ~/dotfiles#<new-hostname>
```

If the new machine has a new user, also `cp home/alice.nix home/<new-user>.nix`.

## Layout

```
flake.nix              entry — auto-discovers hosts/, pins inputs
hosts/<host>/          per-host darwin module (system-level)
  meta.nix             system / username / keyboardType overrides
modules/darwin/        shared darwin modules (homebrew, defaults, …)
modules/home/          shared home-manager modules (zsh, tmux, nvim, …)
home/<user>.nix        user entrypoint
home/                  raw config files (sketchybar lua, tmux.conf, aerospace, …)
                       symlinked into $HOME so edits apply without a rebuild
```

`mkOutOfStoreSymlink` is used for anything I want to edit live (tmux, sketchybar, aerospace scripts). Pure nix-managed files (most `modules/*.nix`) need a rebuild to apply.

## Tools wired up

- **WM:** [AeroSpace](https://github.com/nikitabobko/AeroSpace) — i3-style tiling, alt-prefixed bindings
- **Bar:** [sketchybar](https://github.com/FelixKratz/SketchyBar) + SbarLua (compiled on activation)
- **Terminal:** [Alacritty](https://github.com/alacritty/alacritty) + [tmux](https://github.com/tmux/tmux) (TPM bootstrapped)
- **Shell:** zsh + [zsh4humans](https://github.com/romkatv/zsh4humans), [atuin](https://github.com/atuinsh/atuin), [fzf-tab](https://github.com/Aloxaf/fzf-tab)
- **Editor:** Neovim
- **Browsers / apps not in nixpkgs:** [Homebrew casks](modules/darwin/homebrew.nix)
- **Secrets:** [sops-nix](https://github.com/Mic92/sops-nix) (age-encrypted) for DBeaver connections + creds

## Secrets

Nothing private lives in the repo. AWS / SSH / API credentials stay under `~/.aws/`, `~/.ssh/`, or [fnox](https://fnox.jdx.dev). sops-encrypted secrets in `secrets/` are unreadable without the matching age key. The repo is intentionally public-publishable.

## Troubleshooting

- **`no matches found: .#<hostname>`** — zsh ate the `#`. Prefix with `noglob` or quote the flake ref.
- **First commit fails with `Couldn't load public key`** — generate `~/.ssh/id_ed25519` (step 5) and rebuild.
- **Empty `~/.config/git/allowed_signers`** — key didn't exist at activation time; just rebuild.
- **z4h "recovery mode"** — `rm -rf ~/.cache/zsh4humans/v5 && exec zsh`.
- **TPM plugins missing** — `darwin-rebuild switch` again; `modules/home/tmux.nix` reinstalls on every activation.
- **`command_not_found_handler` slow first time** — building `~/.cache/nix-pkg-names` (one-time ~30s).
