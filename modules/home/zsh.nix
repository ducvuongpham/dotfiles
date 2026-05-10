{ pkgs, config, ... }:
{
  # ~/.p10k.zsh — symlinked out of dotfiles so edits via `p10k configure`
  # persist + appended catppuccin overrides stay tracked.
  home.file.".p10k.zsh".source = config.lib.file.mkOutOfStoreSymlink
    "${config.home.homeDirectory}/dotfiles/home/zsh/p10k.zsh";

  # zsh4humans bootstraps itself on first shell launch (clones to ~/.cache/zsh4humans).
  # We just write a .zshrc following the official z4h pattern + our extras.
  home.file.".zshrc".text = ''
    # Personal Zsh configuration file. It is strongly recommended to keep all shell customization
    # and configuration (including exported environment variables such as PATH) in this file or
    # in files sourced from it.

    # Periodic auto-update on Zsh startup: 'ask' or 'no'.
    zstyle ':z4h:'                                  auto-update            no
    zstyle ':z4h:'                                  auto-update-days       28

    # Keyboard type: 'mac' or 'pc'.
    zstyle ':z4h:bindkey'                           keyboard               mac

    # Start tmux if not already in tmux ('integrated' is the default).
    zstyle ':z4h:'                                  start-tmux             no

    # Mark up shell's output with semantic information.
    zstyle ':z4h:'                                  term-shell-integration y

    # Right-prompt prompt-on-empty-cmd
    zstyle ':z4h:autosuggestions'                   forward-char           accept

    # Recursive globbing in completion (e.g., 'foo/b/r' matches 'foo/bar/baz').
    zstyle ':z4h:fzf-complete'                      recurse-dirs           no

    # Enable direnv to automatically source .envrc files.
    zstyle ':z4h:direnv'                            enable                 yes
    zstyle ':z4h:direnv:success'                    notify                 yes

    # fzf-tab is installed via nix (modules/home/packages.nix) and sourced
    # from its store path after z4h init below — z4h's plugin loader uses
    # its own tar invocation that breaks against uutils-tar 0.0.1.

    # Enable ('yes') or disable ('no') automatic teleportation of z to
    # a directory of the most-recently-visited subdirectory.
    zstyle ':z4h:cd-down'                           recurse-dirs           yes

    # Clone z4h repo (one-time). Uses the official bootstrapper.
    z4h_bootstrap_url='https://raw.githubusercontent.com/romkatv/zsh4humans/v5/install'
    if [ ! -e "''${Z4H:-$HOME/.cache/zsh4humans/v5}/z4h.zsh" ]; then
      if command -v curl >/dev/null 2>&1; then
        sh -c "$(curl -fsSL $z4h_bootstrap_url)" -- --no-rcs --quiet || return
      elif command -v wget >/dev/null 2>&1; then
        sh -c "$(wget -O- $z4h_bootstrap_url)" -- --no-rcs --quiet || return
      else
        echo "Need curl or wget to bootstrap z4h" >&2
        return 1
      fi
    fi

    # Install or update core z4h plugins (fzf-tab is loaded via the
    # ':z4h:fzf-tab channel stable' zstyle above — z4h handles install).
    z4h install ohmyzsh/ohmyzsh || return

    # Extend PATH.
    path=(~/.local/bin $path)

    # Load HM session variables (programs.zsh.enable = false, so we source manually).
    hm_vars="/etc/profiles/per-user/$USER/etc/profile.d/hm-session-vars.sh"
    [ -f "$hm_vars" ] && . "$hm_vars"
    unset hm_vars

    # Init z4h. Anything below this line is user config.
    z4h init || return

    # ── Catppuccin macchiato theming for zsh ───────────────────────────
    # Install catppuccin theme for fast-syntax-highlighting (z4h's syntax
    # highlighter) on first run, then apply it.
    if [ ! -d "$HOME/.cache/catppuccin-zsh-fsh" ]; then
      git clone --depth=1 -q https://github.com/catppuccin/zsh-fsh.git "$HOME/.cache/catppuccin-zsh-fsh" 2>/dev/null || true
    fi
    if (( $+functions[fast-theme] )); then
      fast-theme "$HOME/.cache/catppuccin-zsh-fsh/themes/catppuccin-macchiato.ini" >/dev/null 2>&1 || true
    fi
    # Autosuggest color — macchiato overlay0 (subtle gray, distinct from typed text).
    ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#6e738d'

    # LS_COLORS — catppuccin-macchiato via vivid (used by ls/eza completion + zsh menus).
    if command -v vivid >/dev/null 2>&1; then
      export LS_COLORS="$(vivid generate catppuccin-macchiato 2>/dev/null)"
    fi

    # vi-mode: Esc → normal mode, i/a/etc. → insert mode (vim semantics on the
    # command line). KEYTIMEOUT=1 makes Esc register in 10ms instead of 400.
    bindkey -v
    export KEYTIMEOUT=1
    # Keep useful emacs-style binds in insert mode.
    bindkey -M viins '^R' z4h-fzf-history
    bindkey -M viins '^A' beginning-of-line
    bindkey -M viins '^E' end-of-line
    # Substring-matching history nav: type any fragment, ^P/^N walks entries
    # that contain it anywhere (z4h's local-history substring widgets).
    bindkey -M viins '^P' z4h-up-substring-local
    bindkey -M viins '^N' z4h-down-substring-local

    # Source fzf-tab from the nix-store-installed package (avoids z4h's
    # downloader, which uses tar flags incompatible with uutils-tar).
    zmodload zsh/complist
    zstyle ':completion:*' menu no
    source ${pkgs.zsh-fzf-tab}/share/fzf-tab/fzf-tab.plugin.zsh
    zstyle ':fzf-tab:*' fzf-flags --height=40% --no-preview --border=none --layout=default
    zstyle ':fzf-tab:*' fzf-min-height 5
    zstyle ':fzf-tab:*' switch-group ',' '.'
    zstyle ':fzf-tab:*' show-group brief
    zstyle ':completion:*' group-name ""
    zstyle ':completion:*:descriptions' format '[%d]'

    # nix-zsh-completions' _nix_attr_paths looks up <nixpkgs> in the legacy
    # ~/.cache/nix/tarballs/ cache that Determinate Nix never populates
    # (modern Nix uses tarball-cache-v2 + flake fetcher cache). The mismatch
    # makes `nix-shell -p <TAB>` print "[Eval failed, can't complete (an URL
    # might not be cached)]" and the bare `nix-shell -p` quoted to that error
    # instead of opening a sub-shell. Stub the function so completion falls
    # back to plain word completion (you type the package name yourself).
    _nix_attr_paths() { return 0; }

    # Default editor — many tools exec this directly (git commit, lazygit, etc.)
    export EDITOR=nvim
    export VISUAL=nvim

    # History — 100k entries, dedup aggressively.
    HISTSIZE=100000
    SAVEHIST=100000
    setopt HIST_IGNORE_ALL_DUPS    # if a new entry duplicates an older one, drop the older
    setopt HIST_IGNORE_SPACE       # commands starting with a space aren't recorded
    setopt HIST_FIND_NO_DUPS       # don't show dups while searching history
    setopt HIST_SAVE_NO_DUPS       # don't write dups to the history file
    setopt HIST_REDUCE_BLANKS      # collapse runs of whitespace before saving
    setopt SHARE_HISTORY           # incrementally share history between sessions

    # Aliases
    alias ls='eza --icons=auto'
    alias ll='eza -lah --icons=auto --git'
    alias la='eza -lah --icons=auto'
    alias tree='eza --tree --icons=auto'
    alias cat='bat --paging=never'
    alias less='bat'
    alias g='git'
    alias lg='lazygit'
    alias neofetch='fastfetch'

    # ── v: smart editor wrapper ─────────────────────────────────────────────
    #   v <file>      → opens nvim cwd'd at the nearest git ancestor
    #                    (file's parent if no git repo) with the file focused
    #   v <dir>       → launches yazi in that directory
    #   v             → bare nvim
    # Decide whether a path is "text-like" enough to open in nvim. Anything
    # else (images / video / audio / pdf / sqlite / archives) goes through
    # macOS `open` so it lands in the right app (Preview / mpv / DBeaver / …).
    _is_textish() {
      local mime
      mime=$(file --mime-type -b "$1" 2>/dev/null)
      case "$mime" in
        text/*) return 0 ;;
        application/json|application/xml|application/x-shellscript|application/javascript|application/x-sh|application/toml|application/x-perl|application/x-python|application/x-ruby) return 0 ;;
        application/x-empty) return 0 ;;
        inode/x-empty) return 0 ;;
      esac
      return 1
    }
    v() {
      if [ $# -eq 0 ]; then
        nvim
        return
      fi
      local target="$1"
      local abs="''${target:A}"
      if [ -d "$abs" ]; then
        yazi "$abs"
        return
      fi
      if ! _is_textish "$abs"; then
        open "$abs"
        return
      fi
      local dir="''${abs:h}"
      local root="$(cd "$dir" 2>/dev/null && git rev-parse --show-toplevel 2>/dev/null)"
      [ -z "$root" ] && root="$dir"
      (cd "$root" && nvim "$abs")
    }

    # ── Find: nvim-style file/word/dir pickers (fd + rg + fzf + bat) ────────
    #   ff [pattern]   find file/dir (respect .gitignore) → v opens it
    #   fa [pattern]   like ff but include hidden + ignored
    #   fw [query]     live-grep through repo → opens nvim at git root + line
    # Smart preview: dirs → eza tree, images → chafa ASCII, audio/video →
    # ffprobe summary, pdf → pdftotext, sqlite → schema, fallback → bat.
    _smart_preview='
      f={}
      if [ -d "$f" ]; then
        eza --tree --color=always --icons=auto --level=2 "$f" 2>/dev/null
        exit
      fi
      mime=$(file --mime-type -b "$f")
      case "$mime" in
        image/*) chafa -f sixel -s 80x40 --animate=off "$f" 2>/dev/null \
                   || chafa --size=80x40 "$f" 2>/dev/null ;;
        video/*|audio/*) ffprobe -v error -show_format -show_streams "$f" 2>/dev/null | head -40 ;;
        application/pdf) pdftotext "$f" - 2>/dev/null | head -200 ;;
        application/x-sqlite3|application/vnd.sqlite3) sqlite3 "$f" .schema 2>/dev/null | head -80 ;;
        application/zip|application/x-tar|application/gzip|application/x-bzip2|application/x-xz|application/x-7z-compressed)
          file "$f" ; echo ; tar tf "$f" 2>/dev/null | head -50 ;;
        *) bat --color=always --style=numbers --line-range=:200 "$f" 2>/dev/null || cat "$f" ;;
      esac
    '
    # If the LAST arg is a directory, peel it off as the search root —
    #   ff <pattern>          search current dir for <pattern>
    #   ff <folder>           list everything in <folder>
    #   ff <pattern> <folder> search <folder> for <pattern>
    _peel_root() {
      _peel_root_root="."
      _peel_root_args=("$@")
      if (( $#_peel_root_args >= 1 )) && [ -d "$_peel_root_args[-1]" ]; then
        _peel_root_root="$_peel_root_args[-1]"
        # zsh slice un-quoted so each element stays separate (quotes would
        # join them into one string).
        _peel_root_args=($_peel_root_args[1,-2])
      fi
    }
    ff() {
      _peel_root "$@"
      local picked
      picked="$(fd --type f --type d --hidden --exclude .git "$_peel_root_args[@]" . "$_peel_root_root" 2>/dev/null \
        | fzf --preview "$_smart_preview")"
      [ -n "$picked" ] && v "$picked"
    }
    fa() {
      _peel_root "$@"
      local picked
      picked="$(fd --type f --type d --hidden --no-ignore --exclude .git "$_peel_root_args[@]" . "$_peel_root_root" 2>/dev/null \
        | fzf --preview "$_smart_preview")"
      [ -n "$picked" ] && v "$picked"
    }
    fw() {
      _peel_root "$@"
      local query="''${_peel_root_args[*]:-.}"
      local picked
      picked="$(rg --line-number --no-heading --color=never --hidden -g '!.git' \
        "$query" "$_peel_root_root" 2>/dev/null \
        | fzf --delimiter=: \
            --preview 'bat --color=always --highlight-line {2} --style=numbers,changes {1}' \
            --preview-window 'right,60%,+{2}-/2')"
      [ -z "$picked" ] && return
      local file="''${picked%%:*}"
      local rest="''${picked#*:}"
      local line="''${rest%%:*}"
      local abs="''${file:A}"
      local dir="''${abs:h}"
      local root="$(cd "$dir" 2>/dev/null && git rev-parse --show-toplevel 2>/dev/null)"
      [ -z "$root" ] && root="$PWD"
      (cd "$root" && nvim "+$line" "$abs")
    }

    # zoxide — frecency-ranked dir jumps. `cd` stays the shell builtin.
    #   z <fragment>      jump to best match
    #   z <fragment><Tab> tab-complete frecent matches
    #   zi                interactive fzf picker
    #   z -               previous dir
    export _ZO_RESOLVE_SYMLINKS=1
    export _ZO_EXCLUDE_DIRS="/nix:/nix/*:/private:/private/*"
    export _ZO_FZF_OPTS="--height=40% --reverse --border --preview 'eza --tree --color=always --icons=auto --level=2 {2}' --preview-window=right:50%:wrap"
    eval "$(zoxide init zsh)"

    # mise (lang version manager)
    eval "$(mise activate zsh)"

    # atuin (shell history search). Hooks Up-Arrow + Ctrl-R.
    eval "$(atuin init zsh)"
    # Disable atuin in vi NORMAL mode — atuin binds ^R / Up / k / j in vicmd
    # too, which fights vim-style history navigation. Restore vi defaults.
    bindkey -M vicmd '^R'   redo
    bindkey -M vicmd '^[[A' up-line-or-history
    bindkey -M vicmd '^[OA' up-line-or-history
    bindkey -M vicmd '^[[B' down-line-or-history
    bindkey -M vicmd '^[OB' down-line-or-history
    bindkey -M vicmd 'k'    up-line-or-history
    bindkey -M vicmd 'j'    down-line-or-history

    # direnv (z4h has its own integration via zstyle above; this is a fallback)
    if ! type _direnv_hook >/dev/null 2>&1; then
      eval "$(direnv hook zsh)"
    fi

    # yazi: y = launch yazi, cd to last dir on quit
    function y() {
      local tmp="$(mktemp -t yazi-cwd.XXXXXX)"
      yazi "$@" --cwd-file="$tmp"
      local cwd="$(cat -- "$tmp")"
      if [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
        builtin cd -- "$cwd"
      fi
      rm -f -- "$tmp"
    }
  '';
}
