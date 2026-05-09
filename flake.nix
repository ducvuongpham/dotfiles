{
  description = "tada's macOS system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    nix-darwin = {
      url = "github:LnL7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    catppuccin.url = "github:catppuccin/nix";
  };

  outputs = { self, nixpkgs, nix-darwin, home-manager, catppuccin, ... }@inputs:
    let
      mkHost = { hostname, username, system }:
        nix-darwin.lib.darwinSystem {
          inherit system;
          specialArgs = { inherit inputs hostname username; };
          modules = [
            ./hosts/${hostname}
            home-manager.darwinModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "hm-backup";
              home-manager.extraSpecialArgs = { inherit inputs username; };
              home-manager.sharedModules = [ catppuccin.homeModules.catppuccin ];
              home-manager.users.${username} = import ./home/${username}.nix;
            }
          ];
        };
    in {
      darwinConfigurations."tada-mbp" = mkHost {
        hostname = "tada-mbp";
        username = "tada";
        system = "aarch64-darwin";
      };
    };
}
