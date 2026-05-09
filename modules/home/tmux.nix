{ pkgs, lib, config, ... }:
{
  # tmux binary; config managed via symlink to absorbed repo at ~/dotfiles/home/tmux.
  home.packages = with pkgs; [ tmux ];

  # Mutable symlink: ~/.config/tmux -> ~/dotfiles/home/tmux.
  # Lets you edit tmux.conf in place; TPM writes plugins/ into the same dir
  # (gitignored — see ~/dotfiles/.gitignore).
  xdg.configFile."tmux".source = config.lib.file.mkOutOfStoreSymlink
    "${config.home.homeDirectory}/dotfiles/home/tmux";

  # Bootstrap TPM (Tmux Plugin Manager) on first run. Plugins installed via
  # `prefix + I` inside tmux. Plugin dirs are gitignored.
  home.activation.cloneTPM = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ ! -d "$HOME/dotfiles/home/tmux/plugins/tpm" ]; then
      ${pkgs.git}/bin/git clone --depth=1 https://github.com/tmux-plugins/tpm \
        "$HOME/dotfiles/home/tmux/plugins/tpm"
    fi
  '';
}
