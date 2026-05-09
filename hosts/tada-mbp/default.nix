{ pkgs, hostname, username, ... }:
{
  imports = [
    ../../modules/darwin
  ];

  networking.hostName = hostname;
  networking.computerName = "tada-mbp";
  networking.localHostName = hostname;

  system.primaryUser = username;

  users.users.${username} = {
    name = username;
    home = "/Users/${username}";
  };

  nixpkgs.hostPlatform = "aarch64-darwin";
  nixpkgs.config.allowUnfree = true;

  system.stateVersion = 6;
}
