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
}
