{ pkgs, username, ... }:
{
  imports = [
    ../modules/home
  ];

  home.username = username;
  home.homeDirectory = "/Users/${username}";
  home.stateVersion = "25.05";

  programs.home-manager.enable = true;

  # Disabled until secrets/dbeaver/*.enc are re-encrypted to include
  # tada_mbp's age recipient. On pc391 run:
  #   sops updatekeys secrets/dbeaver/credentials-config.enc
  #   sops updatekeys secrets/dbeaver/data-sources.enc
  # then commit + push. Pull here and flip this back to true.
  local.dbeaver.enable = false;
}
