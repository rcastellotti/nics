{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/master";
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
    ippy = {
      url = "git+https://g.rcastellotti.dev/rc/ippy";
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
      nix-darwin,
      sops-nix,
      disko,
      ippy,
      dela,
      helium-flake,
      tma,
      ...
    }:
    let
      system = "x86_64-linux";
      devSystems = [
        "x86_64-linux"
        "aarch64-darwin"
      ];
      forAllDevSystems = nixpkgs.lib.genAttrs devSystems;
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        config.allowBroken = true;
      };
    in
    {
      devShells = forAllDevSystems (
        devSystem:
        let
          devPkgs = import nixpkgs {
            system = devSystem;
            config.allowUnfree = true;
          };
        in
        {
          default = devPkgs.mkShell {
            packages = [
              devPkgs.age
              devPkgs.sops
              devPkgs.wireguard-tools
              devPkgs.terraform
              devPkgs.terraform-ls
              devPkgs.hugo
            ]
            ++ nixpkgs.lib.optionals devPkgs.stdenv.hostPlatform.isLinux [
              devPkgs.nixos-anywhere
              devPkgs.nixos-rebuild
            ];
          };
        }
      );
      nixosConfigurations = {
        grizzly = import ./hosts/grizzly {
          inherit
            system
            self
            nixpkgs
            sops-nix
            home-manager
            helium-flake
            ;
        };
        rcastellotti-dev = import ./hosts/rcastellotti-dev {
          inherit
            system
            self
            nixpkgs
            sops-nix
            disko
            ippy
            dela
            home-manager
            tma
            ;
        };
      };
      darwinConfigurations.polar = import ./hosts/polar {
        inherit nix-darwin home-manager;
      };
    };
}
