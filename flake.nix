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
    ippy.url = "git+https://g.rcastellotti.dev/rc/ippy";
    dela.url = "git+https://g.rcastellotti.dev/rc/dela?ref=main";
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
      ippy,
      dela,
      helium-flake,
      ...
    }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        config.allowBroken = true;
      };
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        packages = [
          pkgs.age
          pkgs.sops
          pkgs.nixos-anywhere
          pkgs.nixos-rebuild
          pkgs.wireguard-tools
          pkgs.terraform
          pkgs.terraform-ls
          pkgs.hugo
        ];
        shellHook = ''
          eval "$(${pkgs.sops}/bin/sops decrypt --output-type dotenv ./secrets/secrets.yaml \
            | sed -E '/^[A-Z][A-Z0-9_]*=/!d; s/^/export /')"
        '';
      };
      nixosConfigurations = {
        grizzly = nixpkgs.lib.nixosSystem {
          system = system;
          specialArgs = {
            inherit self;
          };
          modules = [
            ({ ... }: {
              nixpkgs.config.allowUnfree = true;
            })
            ./hosts/grizzly/configuration.nix
            sops-nix.nixosModules.sops
            home-manager.nixosModules.home-manager
            helium-flake.nixosModules.default
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.rc = {
                imports = [
                  ./hosts/grizzly/home.nix
                ];
              };
            }
          ];
        };
        rcastellotti-dev = nixpkgs.lib.nixosSystem {
          system = system;
          specialArgs = {
            inherit self dela;
          };
          modules = [
            sops-nix.nixosModules.sops
            disko.nixosModules.disko
            ippy.nixosModules.ippy
            dela.nixosModules.default
            ./hosts/rcastellotti-dev/configuration.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.rc = import ./home/common.nix;
            }
          ];
        };
      };
    };
}
