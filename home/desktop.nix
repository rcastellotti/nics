{ pkgs, ... }:
{
  imports = [
    ./core.nix
    modules/sway.nix
    modules/waybar.nix
  ];

  home.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    nil
    nixd
    yt-dlp
    telegram-desktop
    signal-desktop
    simplex-chat-desktop
    vlc
    caddy
    flameshot
    opencode
  ];

  gtk = {
    enable = true;
    theme = {
      name = "Adwaita";
      package = pkgs.gnome-themes-extra;
    };
    iconTheme = {
      name = "Adwaita";
      package = pkgs.adwaita-icon-theme;
    };
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
  };

  home.sessionVariables.QT_QPA_PLATFORMTHEME = "gtk3";

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

  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      monospace = [ "JetBrainsMono Nerd Font" ];
      sansSerif = [ "DejaVu Sans" ];
      serif = [ "DejaVu Serif" ];
      emoji = [ "Noto Color Emoji" ];
    };
  };

  programs.zathura.enable = true;

  programs.discord.enable = true;

  programs.thunderbird = {
    enable = true;
    profiles.Default.isDefault = true;
  };

  programs.keepassxc = {
    enable = true;
    settings = {
      GUI = {
        ApplicationTheme = "dark";
        HidePasswords = true;
      };
      Browser = {
        Enabled = true;
      };
      SSHAgent = {
        Enabled = true;
      };
    };
  };

  programs.firefox = {
    enable = true;
    languagePacks = [ "en-US" ];
    profiles.default.search = {
      force = true;
      engines = {
        "nix-packages" = {
          name = "Nix Packages";
          urls = [
            {
              template = "https://search.nixos.org/packages";
              params = [
                {
                  name = "channel";
                  value = "unstable";
                }
                {
                  name = "type";
                  value = "packages";
                }
                {
                  name = "query";
                  value = "{searchTerms}";
                }
              ];
            }
          ];
          icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
          definedAliases = [ "@n" ];
        };
        "home-manager-options" = {
          name = "Home Manager Options";
          urls = [
            {
              template = "https://home-manager-options.extranix.com/";
              params = [
                {
                  name = "release";
                  value = "master";
                }
                {
                  name = "query";
                  value = "{searchTerms}";
                }
              ];
            }
          ];
          icon = "https://home-manager-options.extranix.com/images/favicon.png";
          definedAliases = [ "@hm" ];
        };
      };
    };
    policies = {
      DontCheckDefaultBrowser = true;
      PasswordManagerEnabled = false;
      OfferToSaveLogins = false;
      DisableFirefoxAccounts = true;
      DisplayBookmarksToolbar = "never";
      FirefoxHome = {
        TopSites = false;
        Weather = false;
        SponsoredTopSites = false;
      };
      ExtensionSettings =
        let
          moz = short: "https://addons.mozilla.org/firefox/downloads/latest/${short}/latest.xpi";
        in
        {
          "uBlock0@raymondhill.net" = {
            install_url = moz "ublock-origin";
            installation_mode = "force_installed";
            updates_disabled = true;
          };
          "keepassxc-browser@keepassxc.org" = {
            install_url = moz "keepassxc-browser";
            installation_mode = "force_installed";
            updates_disabled = true;
          };
        };
    };
  };

  programs.ghostty = {
    enable = true;
    package = pkgs.ghostty;
    enableFishIntegration = true;
    settings = {
      font-size = 10;
      font-family = "JetBrainsMono Nerd Font";
      theme = "light:3024 Day,dark:3024 Night";
      command = "${pkgs.fish}/bin/fish --login --interactive";
      "confirm-close-surface" = false;
    };
  };

  programs.zed-editor = {
    enable = true;
    extensions = [
      "nix"
      "sql"
      "terraform"
      "typst"
      "github-theme"
    ];
    userSettings = {
      format_on_save = "on";
      theme = {
        mode = "system";
        light = "Github Light High Contrast";
        dark = "Github Dark High Contrast";
      };
      auto_update = false;
      terminal = {
        font_family = "JetBrainsMono Nerd Font";
        shell.program = "fish";
        working_directory = "current_project_directory";
      };
      vim_mode = false;
      load_direnv = "shell_hook";
      tab_size = 2;
      ui_font_family = "JetBrainsMono Nerd Font";
      buffer_font_family = "JetBrainsMono Nerd Font";
      ui_font_size = 12;
      buffer_font_size = 12;
      disable_ai = true;
      autosave = "on_focus_change";
    };
  };
}
