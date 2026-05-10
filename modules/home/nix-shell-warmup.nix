{ pkgs, lib, config, ... }:
{
  # Determinate Nix sets `extra-nix-path = nixpkgs=flake:<url>` and
  # `lazy-trees = true`. The combo means `<nixpkgs>` (used by `nix-shell -p`
  # and zsh tab-completion's package enumeration) requires the flake tree to
  # be fetched on demand. When the cached tarball is missing or evicted, zsh
  # completion shows "[Eval failed, can't complete (an URL might not be
  # cached)]" and `nix-shell -p` silently dies before opening a shell.
  #
  # This activation prefetches the flake URL after each home-manager switch
  # so the eval cache is warm by the time the next interactive shell starts.
  home.activation.warmNixpkgsFlake =
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      $DRY_RUN_CMD ${pkgs.nix}/bin/nix flake prefetch \
        'https://flakehub.com/f/DeterminateSystems/nixpkgs-weekly/%2A.tar.gz' \
        >/dev/null 2>&1 || true
    '';
}
