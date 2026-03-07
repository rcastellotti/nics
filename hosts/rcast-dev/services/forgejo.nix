{
  config,
  pkgs,
  lib,
  ...
}:
{
  services.forgejo = {
    enable = true;
    database.type = "sqlite3";
    settings = {
      server = {
        DOMAIN = "git.rcast.dev";
        ROOT_URL = "https://git.rcast.dev/";
        HTTP_PORT = 9073;
        PROTOCOL = "http";
        HTTP_ADDR = "127.0.0.1";
        SSH_PORT = lib.head config.services.openssh.ports;
      };
      service.DISABLE_REGISTRATION = false;
    };
  };
}
