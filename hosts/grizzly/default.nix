{
  system,
  self,
  nixpkgs,
  sops-nix,
  home-manager,
  helium-flake,
}:
nixpkgs.lib.nixosSystem {
  inherit system;
  specialArgs = {
    inherit self;
  };
  modules = [
    ./configuration.nix
    sops-nix.nixosModules.sops
    home-manager.nixosModules.home-manager
    helium-flake.nixosModules.default
    {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.users.rc = {
        imports = [
          ./home.nix
        ];
      };
    }
  ];
}
