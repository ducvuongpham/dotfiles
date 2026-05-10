{ pkgs, ... }:
{
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

    # Install or update core z4h plugins.
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

    # Aliases
    alias ls='eza --icons=auto'
    alias ll='eza -lah --icons=auto --git'
    alias la='eza -lah --icons=auto'
    alias tree='eza --tree --icons=auto'
    alias cat='bat --paging=never'
    alias less='bat'
    alias g='git'
    alias lg='lazygit'
    alias v='nvim'

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
