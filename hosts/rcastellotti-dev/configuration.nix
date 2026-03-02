{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    ./disko-config.nix
  ];

  networking.hostName = "rcastellotti-dev";
  networking.useDHCP = lib.mkDefault true;
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  environment.systemPackages = [ pkgs.tailscale ];

  services.tailscale.enable = true;

  users.users.rc = {
    isNormalUser = true;
    description = "rc";
    initialHashedPassword = "$y$j9T$17wh/3yJrjKDieCQllkEM0$tPKMhABvPxNGJkcvzMI26pqhxRVKs3TtTMD2pHBN0b3";
    extraGroups = [
      "wheel"
    ];
    packages = with pkgs; [
      nushell
      tailscale
    ];
  };
  age.secrets.tailscale-authkey = {
    file = ../secrets/tailscale-authkey.age;
  };

  systemd.services.tailscale-autoconnect = {
    description = "Automatic connection to Tailscale";

    after = [
      "network-pre.target"
      "tailscale.service"
    ];
    wants = [
      "network-pre.target"
      "tailscale.service"
    ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig.Type = "oneshot";

    script = with pkgs; ''
      # wait for tailscaled to settle
      sleep 2

      # check if we are already authenticated to tailscale
      status="$(${tailscale}/bin/tailscale status -json | ${jq}/bin/jq -r .BackendState)"
      if [ $status = "Running" ]; then # if so, then do nothing
        exit 0
      fi

      authkey="$(cat ${config.age.secrets.tailscale-authkey.path})"

      # otherwise authenticate with tailscale
      ${tailscale}/bin/tailscale up --authkey="$authkey" --ssh --accept-routes
    '';
  };

  system.stateVersion = "25.11";
}
