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

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nix-darwin, home-manager, catppuccin, sops-nix, ... }@inputs:
    let
      lib = nixpkgs.lib;

      # ── Host auto-discovery ─────────────────────────────────────────────────
      # Every subdir of ./hosts is treated as a darwin host whose name is the
      # hostname. Per-host overrides (system, username) live in an optional
      # ./hosts/<host>/meta.nix; missing fields fall back to defaults below.
      defaults = {
        system = "aarch64-darwin";
        username = "tada";
        keyboardType = "jis";   # karabiner virtual_hid_keyboard.keyboard_type_v2: ansi | iso | jis
      };

      hostNames = lib.attrNames (
        lib.filterAttrs (_: t: t == "directory") (builtins.readDir ./hosts)
      );

      metaFor = host:
        let p = ./hosts + "/${host}/meta.nix";
        in defaults // (if builtins.pathExists p then import p else { });

      # ── Builders ────────────────────────────────────────────────────────────
      mkHost = hostname:
        let m = metaFor hostname; in
        nix-darwin.lib.darwinSystem {
          inherit (m) system;
          specialArgs = { inherit inputs hostname; inherit (m) username system keyboardType; };
          modules = [
            ./hosts/${hostname}
            home-manager.darwinModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "hm-backup";
              home-manager.extraSpecialArgs = { inherit inputs; inherit (m) username keyboardType; };
              home-manager.sharedModules = [
                catppuccin.homeModules.catppuccin
                sops-nix.homeManagerModules.sops
              ];
              home-manager.users.${m.username} = import ./home/${m.username}.nix;
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
            sops-nix.homeManagerModules.sops
          ];
        };

      # Unique (username, system) pairs across all hosts -> homeConfigurations.
      # Same username on multiple hosts collapses to one entry (first wins).
      uniqueUsers = lib.foldl' (acc: h:
        let m = metaFor h; in
        if acc ? ${m.username} then acc
        else acc // { ${m.username} = { inherit (m) username system; }; }
      ) { } hostNames;
    in
    {
      darwinConfigurations =
        lib.genAttrs hostNames mkHost;

      # Standalone home-manager output: `nh home switch` / `home-manager switch`
      # without going through nix-darwin. Same modules either way.
      homeConfigurations =
        lib.mapAttrs (_: u: mkHome u) uniqueUsers;
    };
}
