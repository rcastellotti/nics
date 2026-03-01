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
  };

  outputs =
    inputs@{
      self,
      nix-darwin,
      nixpkgs,
      disko,
      home-manager,
    }:
    {
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
          ./den-configuration.nix
        ];
      };
    };
}
