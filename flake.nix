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
    ippy = {
      url = "git+https://g.rcastellotti.dev/rc/ippy";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    dela = {
      url = "git+https://g.rcastellotti.dev/rc/dela?ref=main";
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
      };
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
            ;
        };
      };
    };
}
