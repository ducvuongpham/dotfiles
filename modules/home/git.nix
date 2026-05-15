{ pkgs, lib, config, ... }:
{
  programs.git = {
    enable = true;

    settings = {
      user = {
        name = "ducvuongpham";
        email = "ducvuongpham2004@gmail.com";
        signingkey = "~/.ssh/id_ed25519.pub";
      };

      init.defaultBranch = "main";
      pull.rebase = true;
      push.autoSetupRemote = true;
      push.default = "current";
      rebase.autoStash = true;
      fetch.prune = true;
      core.editor = "nvim";

      # delta — syntax-highlighted diff pager (binary in packages.nix).
      # Used by plain `git diff`, `git log -p`, and lazygit (see below).
      core.pager = "delta";
      interactive.diffFilter = "delta --color-only";
      delta = {
        navigate = true;          # n/N to move between diff sections
        side-by-side = true;
        line-numbers = true;
        syntax-theme = "Catppuccin Macchiato";
      };
      merge.conflictstyle = "zdiff3";
      diff.colorMoved = "default";

      # ssh signing (ed25519 key generated)
      gpg.format = "ssh";
      "gpg \"ssh\"".allowedSignersFile = "~/.config/git/allowed_signers";
      commit.gpgsign = true;
      tag.gpgsign = true;

      alias = {
        st = "status -sb";
        co = "checkout";
        br = "branch";
        ci = "commit";
        lg = "log --oneline --graph --decorate --all";
        last = "log -1 HEAD --stat";
        unstage = "reset HEAD --";
        amend = "commit --amend --no-edit";
      };
    };

    ignores = [
      ".DS_Store"
      "*.swp"
      ".direnv/"
      ".envrc.local"
      "node_modules/"
      ".idea/"
      ".vscode/"
    ];
  };

  programs.gh = {
    enable = true;
    settings = {
      git_protocol = "ssh";
      editor = "nvim";
    };
  };

  programs.lazygit = {
    enable = true;
    settings = {
      # delta's --features can only enable settings; it can't disable
      # side-by-side once [delta] has it on. So pass --no-gitconfig and
      # re-specify the desired settings inline so lazygit's narrow pane
      # gets single-column rendering.
      git.paging = {
        colorArg = "always";
        pager = "delta --paging=never --no-gitconfig --line-numbers --navigate --syntax-theme 'Catppuccin Macchiato'";
      };

      # Catppuccin Macchiato (sapphire accent, matching system). catppuccin/nix
      # doesn't theme lazygit, so set the palette inline.
      gui = {
        theme = {
          activeBorderColor = [ "#7dc4e4" "bold" ];      # sapphire
          inactiveBorderColor = [ "#cad3f5" ];           # text
          optionsTextColor = [ "#8aadf4" ];              # blue
          selectedLineBgColor = [ "#363a4f" ];           # surface0
          cherryPickedCommitBgColor = [ "#494d64" ];     # surface1
          cherryPickedCommitFgColor = [ "#f4dbd6" ];     # rosewater
          unstagedChangesColor = [ "#ed8796" ];          # red
          defaultFgColor = [ "#cad3f5" ];                # text
          searchingActiveBorderColor = [ "#eed49f" ];    # yellow
        };
        authorColors."*" = "#b7bdf8";                    # lavender
      };
    };
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  # allowed_signers populated by activation script after ed25519 key exists
  home.activation.gitAllowedSigners = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ -f "$HOME/.ssh/id_ed25519.pub" ]; then
      mkdir -p "$HOME/.config/git"
      PUBKEY=$(cat "$HOME/.ssh/id_ed25519.pub")
      echo "ducvuongpham2004@gmail.com namespaces=\"git\" $PUBKEY" > "$HOME/.config/git/allowed_signers"
    fi
  '';
}
