{
  description = "nics";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    inputs@{
      self,
      nix-darwin,
      nixpkgs,
      home-manager,
    }:
    let
      configuration =
        { pkgs, ... }:
        {
          # https://nix-darwin.github.io/nix-darwin/manual/
          fonts.packages = [ pkgs.jetbrains-mono ];

          users.users.rc = {
            name = "rc";
            home = "/Users/rc";
          };

          nix.settings.experimental-features = "nix-command flakes";

          nixpkgs.hostPlatform = "aarch64-darwin";
          nixpkgs.config.allowUnfree = true;
          networking.hostName = "bearbook";
          security.pam.services.sudo_local.touchIdAuth = true;

          system = {
            stateVersion = 6;
            primaryUser = "rc";
            defaults = {
              dock = {
                autohide = true;
                show-recents = false;
                tilesize = 32;
                orientation = "left";
                launchanim = false;
                mineffect = "suck";
                persistent-apps = [
                  "${pkgs.vscode}/Applications/Visual Studio Code.app"
                  "${pkgs.vscode}/Applications/Visual Studio Code.app"
                  "${pkgs.bitwarden-desktop}/Applications/Bitwarden.app"
                ];
              };
            };
          };

          system.activationScripts.setBlackWallpaper.text = ''
            osascript -e '
              tell application "System Events"
                set picture of every desktop to "/System/Library/Desktop Pictures/Solid Colors/Black.png"
              end tell
            '
          '';
        };
    in
    {
      darwinConfigurations."bearbook" = nix-darwin.lib.darwinSystem {
        modules = [
          configuration
          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "hm-backup";
            home-manager.users.rc = ./home.nix;
          }
        ];
      };
    };
}
