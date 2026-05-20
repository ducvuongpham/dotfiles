{ pkgs, username, ... }:
{
  imports = [
    ../modules/home
  ];

  home.username = username;
  home.homeDirectory = "/Users/${username}";
  home.stateVersion = "25.05";

  programs.home-manager.enable = true;

  local.dbeaver.enable = true;
}
