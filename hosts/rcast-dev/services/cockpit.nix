{ config, ... }:
let
  dnsName = "cp.rcast.dev";
in
{
  systemd.services.cockpit = {
    restartIfChanged = true;
  };

  services.cockpit = {
    enable = true;
    port = 9074;
    allowed-origins = [ "wss://${dnsName} https://${dnsName}" ];
    settings = {
      WebService = {
        ProtocolHeader = "X-Forwarded-Proto";
      };
    };
  };
}
