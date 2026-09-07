{
  nixpkgs,
  home-manager,
}:
home-manager.lib.homeManagerConfiguration {
  pkgs = import nixpkgs {
    system = "aarch64-darwin";
    config = {
      allowBroken = true;
      allowUnfree = true;
    };
  };
  modules = [ ./home.nix ];
}
