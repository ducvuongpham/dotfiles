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

    # nix helper + dev tooling
    nh
    nixd                # LSP server (richer, uses nixpkgs eval)
    nixfmt-rfc-style    # formatter (rfc spec)
    statix              # linter
    deadnix             # find dead code

    # misc
    wget
    curl
    coreutils
    gnused
    gnutar
    gawk
  ];
}
