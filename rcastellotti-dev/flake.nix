{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    agenix.url = "github:ryantm/agenix";
    disko.url = "github:nix-community/disko";
    agenix-shell.url = "github:aciceri/agenix-shell";
    agenix-shell.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
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
          HCLOUD_TOKEN.file = ./secrets/HCLOUD_TOKEN.age;
          CLOUDFLARE_API_TOKEN.file = ./secrets/CLOUDFLARE_API_TOKEN.age;
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

      nixosConfigurations.rcastellotti-dev = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./rcastellotti-dev-configuration.nix
          inputs.disko.nixosModules.disko
        ];
      };
    };
}
