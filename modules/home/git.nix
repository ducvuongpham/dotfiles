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
      # Route lazygit's diff/log panes through delta. Lazygit handles its
      # own pane layout, so we override side-by-side from the git config to
      # keep delta single-column inside the smaller pane.
      git.paging = {
        colorArg = "always";
        pager = "delta --paging=never --side-by-side=false --line-numbers";
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
