{ pkgs, lib, config, ... }:
{
  # tmux binary; config managed via symlink to absorbed repo at ~/dotfiles/home/tmux.
  home.packages = with pkgs; [ tmux ];

  # Mutable symlink: ~/.config/tmux -> ~/dotfiles/home/tmux.
  # Lets you edit tmux.conf in place; TPM writes plugins/ into the same dir
  # (gitignored — see ~/dotfiles/.gitignore).
  xdg.configFile."tmux".source = config.lib.file.mkOutOfStoreSymlink
    "${config.home.homeDirectory}/dotfiles/home/tmux";

  # Bootstrap TPM (Tmux Plugin Manager) + auto-install configured plugins on
  # first run. Plugin dirs are gitignored. Must run after linkGeneration so
  # the ~/dotfiles symlink (zsh.nix) is in place; otherwise the clone target
  # path is dangling on a fresh machine.
  home.activation.cloneTPM = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    tpm_dir="$HOME/dotfiles/home/tmux/plugins/tpm"
    if [ ! -d "$tpm_dir" ]; then
      ${pkgs.git}/bin/git clone --depth=1 https://github.com/tmux-plugins/tpm "$tpm_dir"
    fi
    # Install the plugins listed in tmux.conf (idempotent — skips already-installed).
    [ -x "$tpm_dir/bin/install_plugins" ] && "$tpm_dir/bin/install_plugins" >/dev/null 2>&1 || true
  '';
}
