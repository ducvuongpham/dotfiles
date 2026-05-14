{ pkgs, hostname, username, system, ... }:
{
  imports = [
    ../../modules/darwin
  ];

  networking.hostName = hostname;
  networking.computerName = hostname;
  networking.localHostName = hostname;

  system.primaryUser = username;

  users.users.${username} = {
    name = username;
    home = "/Users/${username}";
  };

  nixpkgs.hostPlatform = system;
  nixpkgs.config.allowUnfree = true;

  system.stateVersion = 6;
}
