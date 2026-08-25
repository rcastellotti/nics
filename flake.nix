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
          secret_exports="$(
            set -o pipefail
            ${pkgs.sops}/bin/sops \
              --decrypt \
              --output-type json \
              "$PWD/secrets/secrets.yaml" |
              ${pkgs.jq}/bin/jq -r '
                . as $secrets
                | [
                    "AWS_ACCESS_KEY_ID",
                    "AWS_ENDPOINT_URL_S3",
                    "AWS_SECRET_ACCESS_KEY",
                    "CLOUDFLARE_API_TOKEN",
                    "HCLOUD_TOKEN"
                  ][]
                | select($secrets[.] != null)
                | "export \(.)=\($secrets[.] | @sh)"
              '
          )" || {
            echo "Failed to decrypt development secrets" >&2
            return 1
          }

          eval "$secret_exports"
          unset secret_exports
        '';
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
            tma
            ;
        };
      };
      darwinConfigurations.polar = nix-darwin.lib.darwinSystem {
        modules = [
          ./hosts/polar/configuration.nix
          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.rc = import ./hosts/polar/home.nix;
          }
        ];
      };
    };
}
