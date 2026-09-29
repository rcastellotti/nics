{ config, lib, ... }:
let
  me = config.networking.hostName;
  devices = {
    grizzly = {
      id = "FTHJ4C3-WXZPLWO-MRJTF3T-4PH5Z2S-TQEGCGO-WLYY4I6-TJX44XC-FKEXBAJ";
      addresses = [ "tcp://grizzly:22000" ];
    };
    kodiak = {
      id = "4W6B5RZ-YB6T3UR-BU56QNK-2YV6SLC-7UFBEUN-B3KR2LV-D22GXXI-E4EOKQW";
      addresses = [ "tcp://kodiak:22000" ];
    };
  };
  st = config.services.syncthing;
in
{
  sops.secrets."syncthing-${me}-cert" = {
    owner = st.user;
    restartUnits = [ "syncthing.service" ];
  };
  sops.secrets."syncthing-${me}-key" = {
    owner = st.user;
    restartUnits = [ "syncthing.service" ];
  };
  sops.secrets."syncthing-gui-password" = {
    owner = st.user;
    restartUnits = [ "syncthing.service" ];
  };

  services.syncthing = {
    enable = true;
    cert = config.sops.secrets."syncthing-${me}-cert".path;
    key = config.sops.secrets."syncthing-${me}-key".path;
    guiPasswordFile = config.sops.secrets."syncthing-gui-password".path;

    overrideDevices = true; # config is the source of truth, GUI changes get wiped
    overrideFolders = true;

    settings = {
      inherit devices;
      folders.cloud = {
        path = "/srv/cloud";
        devices = [
          "grizzly"
          "kodiak"
        ];
      };
      options = {
        # tailnet only, so no need for discovery or relays
        globalAnnounceEnabled = false;
        localAnnounceEnabled = false;
        relaysEnabled = false;
        urAccepted = -1;
      };
    };
  };

  # replaces openDefaultPorts: only reachable over tailscale
  networking.firewall.interfaces.tailscale0 = {
    allowedTCPPorts = [ 22000 ];
    allowedUDPPorts = [ 22000 ];
  };
  users.users.rc.extraGroups = [ "syncthing" ];

  systemd.tmpfiles.rules = [
    "d /srv/cloud 2770 syncthing syncthing -"
    "A+ /srv/cloud - - - - d:g:syncthing:rwx" # default ACL so files rc creates stay group-writable
  ];

  systemd.services.syncthing.serviceConfig.UMask = "0007";
}
