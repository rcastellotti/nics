{ ... }:
{
  services.hedgedoc = {
    enable = true;
    settings = {
      domain = "pad.rcastellotti.dev";
      host = "127.0.0.1";
      port = 9072;
      protocol = "https";
      protocolUseSSL = true;
      trustProxy = true;
      allowOrigin = [ "pad.rcastellotti.dev" ];
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
