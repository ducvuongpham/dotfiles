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

    # zoxide as cd
    eval "$(zoxide init zsh --cmd cd)"

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
