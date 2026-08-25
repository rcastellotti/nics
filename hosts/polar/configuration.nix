{
  config,
  self,
  ...
}:

{
  nixpkgs.hostPlatform = "aarch64-darwin";
  nixpkgs.config = {
    allowBroken = true;
    allowUnfree = true;
  };

  networking = {
    computerName = "polar";
    hostName = "polar";
    localHostName = "polar";
  };

  system = {
    primaryUser = "rc";
    stateVersion = 6;
  };

  users.users.rc.home = "/Users/rc";

  sops = {
    defaultSopsFile = "${self}/secrets/secrets.yaml";
    age.keyFile = "/Users/rc/Library/Application Support/sops/age/keys.txt";
    secrets.wg-polar = { };
  };

  networking.wg-quick.interfaces.wg0 = {
    address = [ "10.0.0.3/32" ];
    privateKeyFile = config.sops.secrets.wg-polar.path;
    peers = [
      {
        publicKey = "gZeKUDU/F7xcX6X26AjKz3EJcHKa8wcqsrNOysULnzw=";
        allowedIPs = [ "10.0.0.1/32" ];
        endpoint = "wg.rcastellotti.dev:51820";
        persistentKeepalive = 25;
      }
    ];
  };

  # Determinate manages the Nix daemon and build users.
  nix.enable = false;
}
