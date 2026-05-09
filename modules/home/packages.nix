{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # core cli
    eza
    bat
    zoxide
    fzf
    ripgrep
    fd
    jq
    yq
    gh
    lazygit
    tree
    htop
    btop

    # yazi runtime previewers
    ffmpeg
    p7zip
    poppler
    imagemagick
    chafa

    # nvim runtime deps
    neovim
    gcc
    nodejs_22
    unzip
    sqlite
    tree-sitter

    # lang version manager
    mise

    # nix helper
    nh

    # misc
    wget
    curl
    coreutils
    gnused
    gnutar
    gawk
  ];
}
