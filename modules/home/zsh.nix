{ pkgs, lib, config, ... }:
{
  # ~/dotfiles compatibility shim. Legacy refs (this file's p10k.zsh path,
  # alias drs/nhs/nhh below, modules/home/tmux.nix activation, etc.) hardcode
  # `~/dotfiles`. If the repo is cloned somewhere else (e.g. ~/.dotfiles), we
  # create a symlink so those refs still resolve. If ~/dotfiles is already a
  # real repo (tada-mbp clones directly), we leave it alone — we *cannot*
  # use `home.file."dotfiles"` because home-manager would back up the real
  # repo directory to ~/dotfiles.hm-backup.
  #
  # Also self-heal: a previous version of this module used `home.file` and was
  # later removed, which left ~/dotfiles as an empty stub directory after a
  # subsequent activation. Detect that (no flake.nix and ~/.dotfiles is the
  # real repo) and replace with the correct symlink.
  #
  # Runs before linkGeneration so the path resolves when other modules'
  # mkOutOfStoreSymlinks try to follow it.
  # `bat` caches syntax/theme bundles keyed by binary version. After a
  # nixpkgs bump, the cache is incompatible and bat prints a noisy error
  # on every invocation until you `bat cache --clear`. Clear on every
  # activation — the cache rebuilds lazily on first use, so this is cheap.
  home.activation.batCacheClear = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    if [ -d "''${XDG_CACHE_HOME:-$HOME/.cache}/bat" ]; then
      ${pkgs.coreutils}/bin/rm -rf -- "''${XDG_CACHE_HOME:-$HOME/.cache}/bat"
    fi
  '';

  home.activation.dotfilesShim = lib.hm.dag.entryBefore [ "linkGeneration" ] ''
    DOT="$HOME/dotfiles"
    REAL="$HOME/.dotfiles"
    if [ -L "$DOT" ]; then
      :  # already a symlink, leave it
    elif [ -d "$DOT" ] && [ -f "$DOT/flake.nix" ]; then
      :  # real repo directory (e.g. tada-mbp clones directly), leave it
    elif [ -e "$DOT" ] && [ -d "$REAL" ] && [ -f "$REAL/flake.nix" ]; then
      # stub / leftover — replace with correct symlink
      ${pkgs.coreutils}/bin/rm -rf -- "$DOT"
      ${pkgs.coreutils}/bin/ln -s "$REAL" "$DOT"
    elif [ ! -e "$DOT" ] && [ -d "$REAL" ] && [ -f "$REAL/flake.nix" ]; then
      ${pkgs.coreutils}/bin/ln -s "$REAL" "$DOT"
    fi
  '';

  # ~/.p10k.zsh — symlinked out of dotfiles so edits via `p10k configure`
  # persist + appended catppuccin overrides stay tracked.
  home.file.".p10k.zsh".source = config.lib.file.mkOutOfStoreSymlink
    "${config.home.homeDirectory}/dotfiles/home/zsh/p10k.zsh";

  # ~/.zshenv — loaded before .zshrc. Standard z4h pattern: fetch z4h.zsh on
  # first run, then source it so `z4h` function is available in .zshrc.
  home.file.".zshenv".text = ''
    if [ -n "''${ZSH_VERSION-}" ]; then
      : ''${ZDOTDIR:=~}
      setopt no_global_rcs
      [[ -o no_interactive && -z "''${Z4H_BOOTSTRAPPING-}" ]] && return
      setopt no_rcs
      unset Z4H_BOOTSTRAPPING
    fi

    Z4H_URL="https://raw.githubusercontent.com/romkatv/zsh4humans/v5"
    : "''${Z4H:=''${XDG_CACHE_HOME:-$HOME/.cache}/zsh4humans/v5}"

    umask o-w

    if [ ! -e "$Z4H"/z4h.zsh ]; then
      mkdir -p -- "$Z4H" || return
      >&2 printf '\033[33mz4h\033[0m: fetching \033[4mz4h.zsh\033[0m\n'
      if command -v curl >/dev/null 2>&1; then
        curl -fsSL -- "$Z4H_URL"/z4h.zsh >"$Z4H"/z4h.zsh.$$ || return
      elif command -v wget >/dev/null 2>&1; then
        wget -O-   -- "$Z4H_URL"/z4h.zsh >"$Z4H"/z4h.zsh.$$ || return
      else
        >&2 printf '\033[33mz4h\033[0m: please install \033[32mcurl\033[0m or \033[32mwget\033[0m\n'
        return 1
      fi
      mv -- "$Z4H"/z4h.zsh.$$ "$Z4H"/z4h.zsh || return
    fi

    . "$Z4H"/z4h.zsh || return

    setopt rcs
  '';

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
    # its own tar invocation, and uutils-tar (when present) breaks it.

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
    zstyle ':fzf-tab:*' fzf-flags --height=60% --border=none --layout=default --preview-window=right:55%:wrap
    zstyle ':fzf-tab:*' fzf-min-height 1
    zstyle ':fzf-tab:*' switch-group ',' '.'
    zstyle ':fzf-tab:*' show-group brief

    # ── fzf-tab previews ────────────────────────────────────────────────────
    # Path previews (dir → eza tree; file → bat) cover cd, ls, cat, vim, …
    # Per-context overrides below add richer previews (proc info for kill,
    # git log for checkout/diff, ssh hosts).
    _ft_path_preview='
      f=$realpath
      [ -z "$f" ] && f=$word
      if [ -d "$f" ]; then
        eza --tree --color=always --icons=auto --level=2 "$f" 2>/dev/null
      elif [ -f "$f" ]; then
        bat --color=always --style=numbers --line-range=:200 "$f" 2>/dev/null \
          || cat "$f" 2>/dev/null
      else
        echo "$word"
      fi
    '
    zstyle ':fzf-tab:complete:*' fzf-preview "$_ft_path_preview"
    zstyle ':fzf-tab:complete:kill:argument-rest' fzf-preview '/bin/ps -p $word -o pid,user,etime,command 2>/dev/null'
    zstyle ':fzf-tab:complete:(git-checkout|git-switch|git-rebase|git-merge|git-show|git-log|git-diff):argument-rest' fzf-preview 'git log --color=always --oneline --decorate -n 30 $word 2>/dev/null'
    zstyle ':fzf-tab:complete:ssh:argument-rest' fzf-preview 'awk -v h=$word "BEGIN{IGNORECASE=1} /^[Hh]ost / && (\$2==h || \$2~h){p=1} p && /^[[:space:]]*$/{exit} p" ~/.ssh/config 2>/dev/null'
    zstyle ':fzf-tab:complete:systemctl-*:*' fzf-preview 'SYSTEMD_COLORS=1 systemctl status $word 2>/dev/null'
    # Environment-variable expansion: show the value before completing.
    zstyle ':fzf-tab:complete:-parameter-:*' fzf-preview 'echo ''${(P)word}'
    zstyle ':completion:*' group-name ""
    zstyle ':completion:*:descriptions' format '[%d]'

    # nix-zsh-completions' _nix_attr_paths uses the legacy ~/.cache/nix/
    # tarballs cache that Determinate Nix never populates → tab-completion
    # of `nix-shell -p` prints "[Eval failed, can't complete (an URL might
    # not be cached)]". Override the whole _nix-shell completion with one
    # backed by a cached package list that's refreshed once a day.
    # Build/refresh the cached nixpkgs package list on demand.
    _my_nix_refresh_cache() {
      local cache="''${XDG_CACHE_HOME:-$HOME/.cache}/nix-pkg-names"
      local age=999999
      if [[ -f $cache ]]; then
        age=$(( $(date +%s) - $(date -r "$cache" +%s 2>/dev/null || echo 0) ))
      fi
      if (( age > 86400 )) || [[ ! -s $cache ]]; then
        local store
        store=$(nix flake prefetch --json \
          'https://flakehub.com/f/DeterminateSystems/nixpkgs-weekly/%2A.tar.gz' \
          2>/dev/null | jq -r '.storePath' 2>/dev/null)
        [[ -z $store || ! -d $store ]] && return 1
        # Filter out Linux-only packages — meta.platforms is either unset
        # (= all systems) or must contain the current host system. Otherwise
        # `nix run nixpkgs#<linux-only>` blows up with eval errors at runtime.
        local system="$(uname -m | sed 's/arm64/aarch64/')-darwin"
        nix-env -qaP -f "$store" --json --meta 2>/dev/null \
          | jq -r --arg sys "$system" '
              to_entries
              | map(select(
                  (.value.meta.platforms // null) == null
                  or (.value.meta.platforms | index($sys))
                ))
              | .[] | .key | sub("^nixpkgs\\."; "")' \
          > "$cache.tmp" \
          && mv "$cache.tmp" "$cache"
      fi
      print -- "$cache"
    }

    # Live-search fallback when the cache misses. Hits `nix search` (network) and
    # caches the result so the next tab is instant. Only fires for prefixes
    # >= 2 chars to avoid pulling tens of thousands of results.
    _my_nix_live_search() {
      local prefix=$1
      [[ ''${#prefix} -lt 2 ]] && return 1
      _message "searching nixpkgs for ''${prefix}…"
      local json
      json=$(nix search --json nixpkgs "^''${prefix}" 2>/dev/null) || return 1
      [[ -z $json || $json == "{}" ]] && return 1
      print -- "$json" | jq -r 'keys[] | sub("^legacyPackages\\.[^.]+\\."; "")'
    }

    # `nix-shell -p <TAB>` and `-A <TAB>` package completer. Cache first, live
    # search fallback if cache yields no matches for what the user has typed.
    _my_nix_pkg_names() {
      local cache
      cache=$(_my_nix_refresh_cache) || { _message 'nixpkgs prefetch failed'; return 1; }
      local -a pkgs matches
      pkgs=("''${(@f)$(<$cache)}")
      local pre=''${PREFIX:-}
      matches=("''${(@M)pkgs:#''${pre}*}")
      if (( ''${#matches} == 0 )); then
        local -a live
        live=("''${(@f)$(_my_nix_live_search "$pre")}")
        if (( ''${#live} > 0 )); then
          matches=($live)
        fi
      fi
      _wanted packages expl 'nix package' compadd -a matches
    }

    _my_nix_shell() {
      local -a opts=(
        '--command[Run command instead of starting interactive shell]:Command:_command_names'
        '--run[Run command non-interactively]:Command:_command_names'
        '--pure[Clear environment]'
        '*'{--packages,-p}'[run with packages from <nixpkgs>]:package:_my_nix_pkg_names'
        '*'{--attr,-A}'[build shell for attr]:attr:_my_nix_pkg_names'
        '-I[Add nix-path entry]:path:'
        '-i[Specify interpreter]:interpreter:_command_names'
      )
      local -a args=()
      local word need_pkg=0
      for word in "''${words[@]}"; do
        case "$word" in
          --packages|-p) need_pkg=1 ;;
        esac
      done
      if (( need_pkg )); then
        args=('*:package:_my_nix_pkg_names')
      else
        args=('*:path:_files')
      fi
      _arguments -s "''${opts[@]}" "''${args[@]}"
    }
    compdef _my_nix_shell nix-shell

    # The `nix` command (modern flake CLI) ships its own completion via
    # NIX_GET_COMPLETIONS — Determinate's _nix function uses that and already
    # handles `nix run he<TAB>` correctly. No custom override needed.

    # Always-on supplementary completer for command position: adds
    # `nix run 'nixpkgs#<match>'` candidates alongside whatever _complete
    # finds, so the fzf-tab popup mixes real commands/aliases/funcs with
    # nixpkgs candidates in a single menu. Returns 1 so zsh keeps the
    # completer chain going (stopping early would suppress _complete).
    _my_nix_run_completer() {
      local pre=$PREFIX
      (( ''${#pre} >= 2 )) || return 1
      local prev=''${words[CURRENT-1]:-}
      case $prev in
        ""|"|"|";"|"&&"|"||"|"&") ;;
        *) return 1 ;;
      esac
      local cache="''${XDG_CACHE_HOME:-$HOME/.cache}/nix-pkg-names"
      [[ -f $cache ]] || return 1
      local -a all matches
      all=("''${(@f)$(<$cache)}")
      matches=("''${(@M)all:#''${pre}*}")
      (( ''${#matches} > 0 )) || return 1
      # Single-quote the flake ref — `#` triggers zsh extended_glob otherwise
      # ("zsh: no matches found: nixpkgs#cowsay" when running the command).
      local -a suggestions
      local m
      for m in "''${matches[@]}"; do
        suggestions+=("nix run 'nixpkgs#$m'")
      done
      # Force menu/fzf mode so the first TAB pops fzf instead of inserting
      # the common prefix `nix run nixpkgs#cow`.
      compstate[insert]=menu
      _wanted nix-run-fallback expl 'nix run candidate' \
        compadd -U -Q -- "''${suggestions[@]}"
      return 1
    }
    zstyle ':completion:*' completer _my_nix_run_completer _complete

    # Command-not-found: if zsh can't find a binary but it exists in the
    # nixpkgs cache, transparently re-run the line as
    # `nix run 'nixpkgs#<cmd>' -- <args>`. Build the cache on first miss
    # so this works without prior tab-completion priming it.
    command_not_found_handler() {
      local cmd=$1
      shift
      local cache="''${XDG_CACHE_HOME:-$HOME/.cache}/nix-pkg-names"
      if [[ ! -f $cache ]]; then
        print -u2 "→ building nixpkgs package-name cache (one-time, ~30s)..."
        _my_nix_refresh_cache >/dev/null 2>&1
      fi
      if [[ -f $cache ]] && grep -qxF "$cmd" "$cache"; then
        print -u2 "→ nix run 'nixpkgs#$cmd' -- $*"
        nix run "nixpkgs#$cmd" -- "$@"
        return $?
      fi
      print -u2 "zsh: command not found: $cmd"
      return 127
    }

    # Default editor — many tools exec this directly (git commit, lazygit, etc.)
    export EDITOR=nvim
    export VISUAL=nvim

    # Force yazi to use the kitty graphics protocol. Inside tmux (TERM=tmux-*)
    # yazi can't autodetect that the OUTER terminal (Rio) supports kitty
    # graphics, so it falls back to chafa/unicode blocks and images render
    # tiny. tmux's `allow-passthrough on` (home/tmux/tmux.conf) forwards the
    # DCS-wrapped sequences through to Rio. Set unconditionally — Rio is the
    # only outer terminal used, and Alacritty won't render either way.
    export YAZI_ADAPTER=kgp

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
    alias ncdu='dua i'

    # Render `man` through bat for syntax/colour (uses the catppuccin theme
    # wired by programs.bat). `col -bx` strips backspace overstrike that
    # roff emits for bold/underline so bat doesn't choke on the codes.
    export MANPAGER="sh -c 'col -bx | bat -l man -p --paging=always'"
    export MANROFFOPT="-c"

    # tealdeer cache auto-updates (programs.tealdeer settings in default.nix).
    # Manual refresh: `tldr --update`.

    # Rebuild shortcuts — flake at ~/dotfiles, host = $(hostname -s).
    # Use noglob/quoted form so zsh doesn't expand `#`.
    alias drs='noglob sudo darwin-rebuild switch --flake ~/dotfiles#'"$(hostname -s)"
    alias nhs='nh darwin switch ~/dotfiles -H '"$(hostname -s)"  # full system via nh
    alias nhh='nh home switch ~/dotfiles'                          # home-manager only via nh

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

    # FZF_DEFAULT_OPTS — base flags for every bare `fzf` invocation (raw
    # pipes, ad-hoc selectors). Smart preview: dirs → eza tree, files → bat.
    # Custom pickers (ff/fa/fw) override --preview with $_smart_preview for
    # the richer image/audio/pdf/sqlite preview; this base covers everything
    # else.
    export FZF_DEFAULT_OPTS="--height=60% --layout=reverse --border --preview-window=right:55%:wrap --preview '
      if [ -d {} ]; then
        eza --tree --color=always --icons=auto --level=2 {} 2>/dev/null
      elif [ -f {} ]; then
        bat --color=always --style=numbers --line-range=:200 {} 2>/dev/null || cat {} 2>/dev/null
      else
        echo {}
      fi
    '"
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
