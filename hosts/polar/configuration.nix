{
  config,
  self,
  ...
}:

let
  grizzlySSHKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILqVLRRlGF1nezM9nM87dUBkp3hKkDB+yqJyqPVwt2Wg";
in
{
  nixpkgs.hostPlatform = "aarch64-darwin";
  nixpkgs.config = {
    allowBroken = true;
    allowUnfree = true;
  };
  nix.settings.experimental-features = "nix-command flakes";

  networking = {
    computerName = "polar";
    hostName = "polar";
    localHostName = "polar";
  };

  system = {
    primaryUser = "rc";
    stateVersion = 6;
  };

  users.users.rc = {
    home = "/Users/rc";
    openssh.authorizedKeys.keys = [ grizzlySSHKey ];
  };

  services.openssh = {
    enable = true;
    extraConfig = ''
      PasswordAuthentication no
      KbdInteractiveAuthentication no
    '';
  };

  sops = {
    defaultSopsFile = "${self}/secrets/secrets.yaml";
    age.keyFile = "/Users/rc/Library/Application Support/sops/age/keys.txt";
    secrets.wg-polar = { };
  };

  launchd.daemons.wg-quick-wg0.serviceConfig.AbandonProcessGroup = true;
  networking.wg-quick.interfaces.wg0 = {
    address = [ "10.0.0.3/32" ];
    privateKeyFile = config.sops.secrets.wg-polar.path;
    peers = [
      {
        publicKey = "gZeKUDU/F7xcX6X26AjKz3EJcHKa8wcqsrNOysULnzw=";
        allowedIPs = [ "10.0.0.0/24" ];
        endpoint = "wg.rcastellotti.dev:51820";
        persistentKeepalive = 25;
      }
    ];
  };
}
