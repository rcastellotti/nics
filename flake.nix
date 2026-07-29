{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    agenix.url = "github:ryantm/agenix";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      agenix,
      ...
    }:
    {
      nixosConfigurations = {
        den = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            # ./modules/common.nix
            ./hosts/den/configuration.nix
            agenix.nixosModules.default
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;

              home-manager.users.rc = import ./home/common.nix;
            }
          ];
        };

        rcastellotti-dev = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            # ./modules/common.nix
            ./hosts/rcastellotti-dev/configuration.nix
          ];
        };
      };
    };
}
