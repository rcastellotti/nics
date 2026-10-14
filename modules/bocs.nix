{
  config,
  ...
}:
let
  username = "u691530";
  server = "${username}.your-storagebox.de";

  # rc's uid is allocated at activation time when using mutable users, so it is
  # not known at eval time; fall back to the first normal user's uid.
  uid = if config.users.users.rc.uid == null then 1000 else config.users.users.rc.uid;
in
{
  sops.secrets."bocs-ssh-key" = {
    mode = "0400";
  };

  programs.fuse.userAllowOther = true;

  fileSystems."/srv/bocs" = {
    # (:/) is read-only; the user's writable home lives under /home
    device = "${username}@${server}:/home";
    fsType = "fuse.sshfs";
    options = [
      "IdentityFile=${config.sops.secrets."bocs-ssh-key".path}"
      "StrictHostKeyChecking=accept-new"
      "port=23"
      "allow_other"
      "reconnect"
      "ServerAliveInterval=15"
      "ServerAliveCountMax=3"
      "uid=${toString uid}"
      "gid=${toString config.ids.gids.users}"
      "noauto"
      "_netdev"
      "x-systemd.automount"
      "x-systemd.idle-timeout=600"
      "x-systemd.mount-timeout=30"
    ];
  };

  systemd.tmpfiles.rules = [
    "d /srv/bocs 0755 rc users -"
  ];
}
