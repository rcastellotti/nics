{ osConfig, pkgs, ... }:

{
  imports = [
    ../../home/common.nix
  ];

  home.packages = with pkgs; [
    nixd
    nil
    typst
    yt-dlp
    gimp
    sqlitestudio
    jetbrains-mono
    ghostty
    vlc
    obsidian
    transmission_4-gtk
    lollypop
    easytag
    chromium
    thunderbird
    firefox-devedition
    caddy
  ];
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
  fonts.fontconfig.enable = true;

  programs.thunderbird = {
    enable = true;
    profiles."Default" = {
      isDefault = true;
    };
  };

  accounts.email.accounts = {
    "me@rcastellotti.dev" = {
      thunderbird = {
        enable = true;
      };
      primary = true;
      realName = "Roberto Castellotti";
      address = "me@rcastellotti.dev";
      userName = "r.castellotti@icloud.com";
      passwordCommand = "${pkgs.coreutils}/bin/cat ${osConfig.sops.secrets.icloud-password.path}";
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
        tls = {
          useStartTls = true;
        };
      };
    };
  };
  programs.zoxide.enable = true;

  programs.ghostty = {
    enable = true;
    enableFishIntegration = true;
    settings = {
      font-size = 10;
      font-family = "JetBrains Mono";
      theme = "light:GitHub Light Colorblind,dark:GitHub Dark Colorblind";
      command = "${pkgs.fish}/bin/fish --login --interactive";
    };
  };

  programs.vscodium.enable = true;

  programs.zed-editor = {
    enable = true;
    extensions = [
      "nix"
      "oxc"
      "sql"
      "github-theme"
      "templ"
      "terraform"
      "svelte"
    ];
    userSettings = {
      format_on_save = "on";
      theme = {
        mode = "system";
        dark = "GitHub Dark Colorblind";
        light = "GitHub Light Colorblind";
      };
      auto_update = false;
      terminal = {
        font_family = "JetBrains Mono";
        shell = {
          program = "fish";
        };
        working_directory = "current_project_directory";
      };
      vim_mode = false;
      load_direnv = "shell_hook";
      tab_size = 2;
      ui_font_family = "JetBrains Mono";
      buffer_font_family = "JetBrains Mono";
      ui_font_size = 12;
      buffer_font_size = 12;
      disable_ai = true;
      autosave = "on_focus_change";
    };
  };
}
