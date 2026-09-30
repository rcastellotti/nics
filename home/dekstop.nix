{ pkgs, ... }:
let
  toggle-theme = pkgs.writeShellScriptBin "toggle-theme" ''
    CURRENT=$(${pkgs.glib}/bin/gsettings get org.gnome.desktop.interface color-scheme)
    if [ "$CURRENT" = "'prefer-dark'" ]; then
        ${pkgs.glib}/bin/gsettings set org.gnome.desktop.interface color-scheme 'default'
    else
        ${pkgs.glib}/bin/gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
    fi
  '';
in
{
  imports = [ ./core.nix ];

  home.packages = with pkgs; [
    jetbrains-mono
    nil
    nixd
    yt-dlp
    telegram-desktop
    gimp
    sqlitestudio
    vlc
    transmission_4-gtk
    easytag
    caddy
    discord
    flameshot
    bluetui
    toggle-theme
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

  wayland.windowManager.sway = {
    enable = true;
    wrapperFeatures.gtk = true;

    config = {
      defaultWorkspace = "1";
      input = {
        "type:pointer" = {
          natural_scroll = "enabled";
        };
      };
      modifier = "Mod4";
      terminal = "ghostty";

      window = {
        commands = [
          {
            command = "floating enable, move position center, move scratchpad";
            criteria = {
              app_id = "com.example.scratch-terminal";
            };
          }
        ];
      };
      startup = [
        { command = "${pkgs.keepassxc}/bin/keepassxc"; }
      ];
      keybindings =
        let
          mod = "Mod4";
        in
        pkgs.lib.mkOptionDefault {
          "${mod}+Mod1+t" = "exec toggle-theme";
          "${mod}+Mod1+Left" = "workspace prev";
          "${mod}+Mod1+Right" = "workspace next";
          "${mod}+space" = "exec ${pkgs.rofi}/bin/rofi -show combi -combi-modes \"window,drun\" -show-icons";
          "${mod}+b" = "exec helium";
          "${mod}+z" = "exec zeditor";
          "${mod}+t" = "exec Telegram";
          "${mod}+Return" = "exec ghostty";
          "${mod}+q" = "kill";
          "${mod}+Shift+Return" =
            "exec ghostty --class=com.example.scratch-terminal --gtk-single-instance=false";
          "XF86AudioRaiseVolume" = "exec wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+";
          "XF86AudioLowerVolume" = "exec wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-";
          "XF86AudioMute" = "exec wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
          "Print" = "exec flameshot gui";
        };
    };
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


  fonts.fontconfig.enable = true;

  programs.zathura.enable = true;

  programs.thunderbird = {
    enable = true;
    profiles.Default.isDefault = true;
  };


  programs.vscodium.enable = true;

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

  programs.ghostty = {
    enable = true;
    package = if pkgs.stdenv.hostPlatform.isDarwin then pkgs.ghostty-bin else pkgs.ghostty;
    enableFishIntegration = true;
    settings = {
      font-size = 10;
      font-family = "JetBrains Mono";
      theme = "light:GitHub Light Colorblind,dark:GitHub Dark Colorblind";
      command = "${pkgs.fish}/bin/fish --login --interactive";
    };
  };

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
      "typst"
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
        shell.program = "fish";
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
