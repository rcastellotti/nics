{
  config,
  lib,
  pkgs,
  ...
}:
{
  sops.secrets.forgejo-password.owner = config.services.forgejo.user;
  systemd.services.forgejo.preStart = lib.mkAfter ''
    adminCmd="${lib.getExe config.services.forgejo.package} admin user"
    password="$(cat ${config.sops.secrets.forgejo-password.path})"
    $adminCmd create \
      --admin --email 'me@rcastellotti.dev' \
      --username 'rc' --password "$password" \
      --must-change-password=false || true
  '';

  services.forgejo = {
    enable = true;
    package = pkgs.forgejo;
    database.type = "sqlite3";
    settings = {
      server = {
        DOMAIN = "g.rcastellotti.dev";
        ROOT_URL = "https://g.rcastellotti.dev/";
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
