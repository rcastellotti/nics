{
  system,
  self,
  nixpkgs,
  sops-nix,
  disko,
  ippy,
  dela,
  home-manager,
  tma,
}:
nixpkgs.lib.nixosSystem {
  inherit system;
  specialArgs = {
    inherit self dela tma;
  };
  modules = [
    ./configuration.nix
    sops-nix.nixosModules.sops
    disko.nixosModules.disko
    ippy.nixosModules.ippy
    dela.nixosModules.default
    tma.nixosModules.default
    home-manager.nixosModules.home-manager
    {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.users.rc = import ../../home/common.nix;
    }
  ];
}
