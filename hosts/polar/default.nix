{
  nix-darwin,
  home-manager,
}:
nix-darwin.lib.darwinSystem {
  modules = [
    ./configuration.nix
    home-manager.darwinModules.home-manager
    {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.users.rc = import ./home.nix;
    }
  ];
}
