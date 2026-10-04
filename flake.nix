{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    dela = {
      url = "git+https://g.rcastellotti.dev/rc/dela?ref=main";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    tma = {
      url = "git+https://g.rcastellotti.dev/rc/tma?ref=main";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    helium-flake = {
      url = "github:oxcl/nix-flake-helium-browser";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      sops-nix,
      disko,
      dela,
      tma,
      helium-flake,
      ...
    }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        android_sdk.accept_license = true;
      };
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        packages = with pkgs; [
          sops
          terraform
          terraform-ls
          hugo
          nixos-anywhere
          nixos-rebuild
        ];
      };

      nixosConfigurations = {
        grizzly = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit self;
          };
          modules = [
            ./hosts/grizzly/configuration.nix
            sops-nix.nixosModules.sops
            home-manager.nixosModules.home-manager
            helium-flake.nixosModules.default
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.rc = {
                imports = [
                  ./home/desktop.nix
                ];
              };
            }
          ];
        };

        polar = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit self;
          };
          modules = [
            ./hosts/polar/configuration.nix
            sops-nix.nixosModules.sops
            home-manager.nixosModules.home-manager
            helium-flake.nixosModules.default
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.rc = {
                imports = [
                  ./home/desktop.nix
                ];
              };
            }
          ];
        };

        kodiak = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit self dela tma;
          };
          modules = [
            ./hosts/kodiak/configuration.nix
            sops-nix.nixosModules.sops
            disko.nixosModules.disko
            dela.nixosModules.default
            tma.nixosModules.default
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.rc = import ./home/core.nix;
            }
          ];
        };
      };
    };
}
