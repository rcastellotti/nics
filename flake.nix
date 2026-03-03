{
  description = "nics";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
    agenix.url = "github:ryantm/agenix";
    agenix-shell.url = "github:aciceri/agenix-shell";
    agenix-shell.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    inputs@{
      self,
      nix-darwin,
      nixpkgs,
      disko,
      home-manager,
      agenix,
      agenix-shell,
      ...
    }:
    let
      system = "aarch64-darwin";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };

      agenixShellScript = agenix-shell.lib.installationScript system {
        secrets = {
          HCLOUD_TOKEN.file = ./hosts/rcastellotti-dev/secrets/HCLOUD_TOKEN.age;
          CLOUDFLARE_API_TOKEN.file = ./hosts/rcastellotti-dev/secrets/CLOUDFLARE_API_TOKEN.age;
          AWS_ACCESS_KEY_ID.file = ./hosts/rcastellotti-dev/secrets/AWS_ACCESS_KEY_ID.age;
          AWS_SECRET_ACCESS_KEY.file = ./hosts/rcastellotti-dev/secrets/AWS_SECRET_ACCESS_KEY.age;
          AWS_ENDPOINT_URL_S3.file = ./hosts/rcastellotti-dev/secrets/AWS_ENDPOINT_URL_S3.age;
        };
        identityPaths = [ "/tmp/rc-ssh-key" ];
      };
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        buildInputs = [ agenix.packages.${system}.default ];
        packages = [
          pkgs.terraform
          pkgs.terraform-ls
          pkgs.age
          pkgs.age-plugin-yubikey
          pkgs.bitwarden-cli
        ];
        shellHook = ''
          source ${pkgs.lib.getExe agenixShellScript}
        '';
      };

      darwinConfigurations."bearbook" = nix-darwin.lib.darwinSystem {
        modules = [
          ./bearbook-configuration.nix
          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "hm-backup";
            home-manager.users.rc = ./bearbook-home.nix;
          }
        ];
      };

      nixosConfigurations."den" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hosts/den/configuration.nix
        ];
      };

      nixosConfigurations.rcastellotti-dev = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hosts/rcastellotti-dev/configuration.nix
          inputs.disko.nixosModules.disko
          agenix.nixosModules.default
        ];
        specialArgs = {
          inherit self; # ← pass self down to ALL modules
          inherit agenix; # if you want agenix too (optional, since you're using its module)
          # inherit inputs;     # ← optional: pass the whole inputs set if you need other flakes
        };
      };
    };
}
