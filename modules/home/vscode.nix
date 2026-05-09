{ pkgs, ... }:
{
  # Note: VSCode app itself installed via brew cask in modules/darwin/homebrew.nix.
  # programs.vscode here manages settings + extensions declaratively.
  # mutable=true lets you trial-install extensions imperatively too;
  # flip false later for strict declarative.
  programs.vscode = {
    enable = true;
    package = pkgs.vscode;
    mutableExtensionsDir = true;

    profiles.default = {
      extensions = with pkgs.vscode-extensions; [
        # core dx
        editorconfig.editorconfig
        eamodio.gitlens
        usernamehw.errorlens
        christian-kohler.path-intellisense

        # vim mode
        vscodevim.vim

        # langs (add as you need)
        ms-python.python
        rust-lang.rust-analyzer
        golang.go
        bradlc.vscode-tailwindcss
        dbaeumer.vscode-eslint
        esbenp.prettier-vscode

        # nix
        jnoortheen.nix-ide

        # docker
        ms-azuretools.vscode-docker
      ];

      userSettings = {
        "editor.fontFamily" = "JetBrainsMono Nerd Font, Menlo, monospace";
        "editor.fontSize" = 14;
        "editor.fontLigatures" = true;
        "editor.formatOnSave" = true;
        "editor.minimap.enabled" = false;
        "editor.cursorBlinking" = "smooth";
        "editor.cursorSmoothCaretAnimation" = "on";
        "editor.linkedEditing" = true;
        "editor.bracketPairColorization.enabled" = true;
        "editor.guides.bracketPairs" = "active";
        "editor.stickyScroll.enabled" = true;

        "files.trimTrailingWhitespace" = true;
        "files.insertFinalNewline" = true;
        "files.trimFinalNewlines" = true;

        "terminal.integrated.fontFamily" = "JetBrainsMono Nerd Font";
        "terminal.integrated.fontSize" = 13;
        "terminal.integrated.defaultProfile.osx" = "zsh";

        "workbench.colorTheme" = "Default Dark Modern";
        "workbench.iconTheme" = "vs-seti";
        "workbench.startupEditor" = "none";

        "git.autofetch" = true;
        "git.confirmSync" = false;

        "telemetry.telemetryLevel" = "off";
        "redhat.telemetry.enabled" = false;

        "vim.useSystemClipboard" = true;
        "vim.hlsearch" = true;
        "vim.leader" = "<space>";
      };
    };
  };
}
