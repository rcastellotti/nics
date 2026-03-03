{ config, ... }:
let
  dnsName = "${config.networking.hostName}.gannet-kardashev.ts.net";
in
{
  services.hedgedoc = {
    enable = true;
    settings = {
      domain = dnsName;
      host = "127.0.0.1";
      port = 9072;
      protocol = "https";
      protocolUseSSL = true;
      trustProxy = true;
      allowOrigin = [ dnsName ];
      db = {
        dialect = "sqlite";
        storage = "/var/lib/hedgedoc/db.sqlite";
      };
      urlPath = "pad";
      allowAnonymous = false;
      allowAnonymousEdits = false;
      allowEmailRegister = true;
      sessionSecret = "HEDGEDOC_SESSION_SECRET";
    };
  };
}
