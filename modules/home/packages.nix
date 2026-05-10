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
    atuin             # shell history search/sync
    android-tools     # adb / fastboot
    yt-dlp            # video downloader (YouTube + many other sites)
    uv                # fast Python package/project manager (used by koe server)

    # koe overlay (Tauri v2): Rust toolchain + tauri CLI. Build with
    # `cargo tauri build` from ~/code/koe/overlay/. libiconv is required
    # for nix-rustc to link against on darwin (the SDK's .tbd alone isn't
    # discoverable through nix's cc-wrapper).
    rustc
    cargo
    cargo-tauri
    libiconv
    kew               # terminal music player (vim-keys via config)
    vivid             # generates LS_COLORS for theming `ls`, completion menus
    claude-code       # Anthropic's CLI (was managed by mise; nix is more declarative)
    fastfetch         # neofetch-style system info on shell start (`ff`)
    zsh-fzf-tab       # interactive fzf-popup completion menu (sourced from .zshrc)

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
    lua5_4    # sketchybar lua config interpreter

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

    # Rust-implemented uutils (https://github.com/uutils) take the standard
    # names. Replaces GNU coreutils/sed/tar; skips gawk (uutils-awk not ready).
    # Skipped: uutils-acl/login/procps/util-linux (Linux-only).
    uutils-coreutils-noprefix  # includes hostname — uutils-hostname conflicts
    uutils-diffutils
    uutils-findutils
    uutils-sed
    uutils-tar
    gawk
  ];
}
