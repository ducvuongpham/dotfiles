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

      mkHome = { username, system }:
        home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.${system};
          extraSpecialArgs = { inherit inputs username; };
          modules = [
            ./home/${username}.nix
            catppuccin.homeModules.catppuccin
          ];
        };
    in {
      darwinConfigurations."tada-mbp" = mkHost {
        hostname = "tada-mbp";
        username = "tada";
        system = "aarch64-darwin";
      };

      # Standalone home-manager output so `nh home switch` / `home-manager switch`
      # can target the user profile without going through nix-darwin.
      # NB: the darwinConfiguration above still embeds home-manager — both paths
      # produce equivalent results; pick whichever fits the rebuild scope.
      homeConfigurations."tada" = mkHome {
        username = "tada";
        system = "aarch64-darwin";
      };
    };
}
