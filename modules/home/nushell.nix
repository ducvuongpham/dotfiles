{ pkgs, lib, config, ... }:
{
  # Optional secondary shell. zsh stays as the login shell (modules/home/zsh.nix);
  # launch this by typing `nu`. programs.nushell.enable also adds the nushell
  # package to home.packages, so no duplicate entry in packages.nix is needed.
  programs.nushell = {
    enable = true;

    # `ls` is intentionally NOT aliased — nushell's built-in ls returns structured
    # data (filterable / sortable as a table); replacing it with eza loses that.
    # Use ll/la/tree for the eza views.
    shellAliases = {
      ll       = "eza -lah --icons=auto --git";
      la       = "eza -lah --icons=auto";
      tree     = "eza --tree --icons=auto";
      g        = "git";
      lg       = "lazygit";
      neofetch = "fastfetch";
      ncdu     = "dua i";
    };

    extraEnv = ''
      $env.EDITOR = "nvim"
      $env.VISUAL = "nvim"
      # Match zsh's `path=(~/.local/bin $path)`. PATH is auto-converted to a list
      # via ENV_CONVERSIONS in nu's defaults.
      $env.PATH = ($env.PATH | prepend $"($env.HOME)/.local/bin")
    '';

    extraConfig = ''
      # Build-time-generated init hooks live in ~/.config/nushell/hooks/.
      source ${config.home.homeDirectory}/.config/nushell/hooks/mise.nu
      source ${config.home.homeDirectory}/.config/nushell/hooks/zoxide.nu
      source ${config.home.homeDirectory}/.config/nushell/hooks/atuin.nu

      # Rebuild shortcuts — flake at ~/dotfiles, host = `hostname -s` evaluated
      # at call time (so the same definition works on tada-mbp / pc391 / etc.).
      def drs [] {
        let h = (^hostname -s | str trim)
        sudo darwin-rebuild switch --flake $"($env.HOME)/dotfiles#($h)"
      }
      def nhs [] {
        let h = (^hostname -s | str trim)
        nh darwin switch $"($env.HOME)/dotfiles" -H $h
      }
      def nhh [] {
        nh home switch $"($env.HOME)/dotfiles"
      }
    '';
  };

  # Generate the mise/zoxide/atuin init hooks at nix-build time. The outputs are
  # deterministic per-binary-version and cached in /nix/store, so they only
  # rebuild when one of those packages bumps.
  #
  # HOME=$TMPDIR: the build sandbox sets HOME=/homeless-shelter (read-only),
  # and atuin (and potentially mise) tries to mkdir ~/.config/<tool> at startup.
  # Redirecting HOME to the writable build tmpdir lets the init commands run.
  home.file = {
    ".config/nushell/hooks/mise.nu".source = pkgs.runCommand "mise-nu" { } ''
      HOME=$TMPDIR ${pkgs.mise}/bin/mise activate nu > $out
    '';
    ".config/nushell/hooks/zoxide.nu".source = pkgs.runCommand "zoxide-nu" { } ''
      HOME=$TMPDIR ${pkgs.zoxide}/bin/zoxide init nushell > $out
    '';
    ".config/nushell/hooks/atuin.nu".source = pkgs.runCommand "atuin-nu" { } ''
      HOME=$TMPDIR ${pkgs.atuin}/bin/atuin init nu > $out
    '';
  };
}
