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
          "${pkgs.zed-editor}/Applications/Zed.app"
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
}
