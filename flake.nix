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
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix-shell = {
      url = "github:aciceri/agenix-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    ippy.url = "git+https://g.rcastellotti.dev/rc/ippy";
    dela.url = "git+https://g.rcastellotti.dev/rc/dela?ref=main";
  };
  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      agenix,
      disko,
      agenix-shell,
      ippy,
      dela,

      ...
    }:
    let
      system = "x86_64-linux";
      agenixShellScript = agenix-shell.lib.installationScript system {
        secrets = {
          HCLOUD_TOKEN.file = ./secrets/HCLOUD_TOKEN.age;
          CLOUDFLARE_API_TOKEN.file = ./secrets/CLOUDFLARE_API_TOKEN.age;
          AWS_ACCESS_KEY_ID.file = ./secrets/AWS_ACCESS_KEY_ID.age;
          AWS_SECRET_ACCESS_KEY.file = ./secrets/AWS_SECRET_ACCESS_KEY.age;
          AWS_ENDPOINT_URL_S3.file = ./secrets/AWS_ENDPOINT_URL_S3.age;
        };
        identityPaths = [ "/tmp/rc-ssh-key" ];
      };
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        buildInputs = [ agenix.packages.${system}.default ];
        packages = [
          pkgs.age
          pkgs.nixos-anywhere
          pkgs.nixos-rebuild
          pkgs.wireguard-tools
          pkgs.terraform
          pkgs.terraform-ls
          pkgs.hugo
        ];
        shellHook = ''
          source ${nixpkgs.lib.getExe agenixShellScript}
        '';
      };
      nixosConfigurations = {
        den = nixpkgs.lib.nixosSystem {
          system = system;
          specialArgs = {
            inherit self;
          };
          modules = [
            ({ ... }: {
              nixpkgs.config.allowUnfree = true;
            })
            ./hosts/den/configuration.nix
            agenix.nixosModules.default
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.rc = import ./hosts/den/home.nix;
            }
          ];
        };
        rcastellotti-dev = nixpkgs.lib.nixosSystem {
          system = system;
          specialArgs = {
            inherit self;
          };
          modules = [
            agenix.nixosModules.default
            disko.nixosModules.disko
            agenix.nixosModules.default
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
