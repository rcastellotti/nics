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

        kodiak = import ./hosts/kodiak {
          inherit
            system
            self
            nixpkgs
            sops-nix
            disko
            dela
            home-manager
            tma
            ;
        };
      };
    };
}
