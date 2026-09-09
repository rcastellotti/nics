{ osConfig, pkgs, ... }:

{
  imports = [
    ../../home/common.nix
  ];

  home.packages = with pkgs; [
    gimp
    sqlitestudio
    vlc
    obsidian
    transmission_4-gtk
    gnome-music
    easytag
    chromium
    firefox-devedition
    caddy
    discord
  ];

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    settings.kodiak = {
      HostName = "kodiak.t.rcastellotti.dev";
      User = "rc";
    };
    settings.polar = {
      HostName = "10.0.0.3";
      User = "rc";
    };
  };

  dconf.settings = {
    "org/gnome/desktop/background" = {
      picture-uri = "none";
      picture-uri-dark = "none";
      primary-color = "#000000";
      secondary-color = "#000000";
      color-shading-type = "solid";
    };
    "org/gnome/desktop/peripherals/mouse".natural-scroll = true;
    "org/gnome/desktop/interface".enable-animations = false;
  };

  programs.thunderbird = {
    enable = true;
    profiles.Default.isDefault = true;
  };

  accounts.email.accounts."me@rcastellotti.dev" = {
    primary = true;
    realName = "Roberto Castellotti";
    address = "me@rcastellotti.dev";
    userName = "r.castellotti@icloud.com";
    imap = {
      host = "imap.mail.me.com";
      port = 993;
      tls = {
        enable = true;
        useStartTls = false;
      };
    };
    smtp = {
      host = "smtp.mail.me.com";
      port = 587;
      tls.useStartTls = true;
    };
    thunderbird.enable = true;
  };

  programs.vscodium.enable = true;
}
