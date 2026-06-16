{
  config,
  pkgs,
  lib,
  self,
  ...
}:
{
  age.secrets.forgejo-password = {
    file = "${self}/secrets/forgejo-password.age";
    owner = config.services.forgejo.user;
  };
  systemd.services.forgejo.preStart =
    let
      adminCmd = "${lib.getExe config.services.forgejo.package} admin user";
      passwd = "$(cat ${config.age.secrets.forgejo-password.path})";
    in
    lib.mkAfter ''
      ${adminCmd} create --admin \
        --email "me@rcastellotti.dev" \
        --username "rc" \
        --password "${passwd}" \
        2>/dev/null || true
      ${adminCmd} change-password \
        --username "rc" \
        --password "${passwd}"
    '';
  services.forgejo = {
    enable = true;
    package = pkgs.forgejo;
    database.type = "sqlite3";
    settings = {
      server = {
        DOMAIN = "g.rcast.dev";
        ROOT_URL = "https://g.rcast.dev/";
        HTTP_PORT = 9073;
        PROTOCOL = "http";
        HTTP_ADDR = "127.0.0.1";
        SSH_PORT = lib.head config.services.openssh.ports;
      };
      repository.ENABLE_PUSH_CREATE_USER = true;
      service.DISABLE_REGISTRATION = true;
    };
  };
}
