{ self, config, ... }:
{
  age.secrets.hedgedoc-session-secret.file = "${self}/hosts/rcast-dev/secrets/hedgedoc-session-secret.age";

  services.hedgedoc = {
    enable = true;
    settings = {
      domain = "pad.rcast.dev";
      host = "127.0.0.1";
      port = 9072;
      protocol = "https";
      protocolUseSSL = true;
      trustProxy = true;
      allowOrigin = [
        "pad.rcast.dev"
      ];
      db = {
        dialect = "sqlite";
        storage = "/var/lib/hedgedoc/db.sqlite";
      };
      allowAnonymous = false;
      allowAnonymousEdits = false;
      allowEmailRegister = true;
      sessionSecret = config.age.secrets.hedgedoc-session-secret.path;
    };
  };
}
