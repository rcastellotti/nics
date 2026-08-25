{
  self,
  nix-darwin,
  home-manager,
  sops-nix,
}:
nix-darwin.lib.darwinSystem {
  specialArgs = { inherit self; };
  modules = [
    ./configuration.nix
    home-manager.darwinModules.home-manager
    sops-nix.darwinModules.sops
    {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.users.rc = import ./home.nix;
    }
  ];
}
