{ config, ... }:
{
  services.forgejo = {
    enable = true;
    database.type = "sqlite3";
    settings = {
      server = {
        DOMAIN = "git.rcast.dev";
        ROOT_URL = "https://git.rcast.dev/";
        HTTP_PORT = 3000;
        SERVE_FROM_SUB_PATH = true;
        PROTOCOL = "http";
        HTTP_ADDR = "127.0.0.1";
      };
      service.DISABLE_REGISTRATION = true;
    };
  };
}
