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
  rofi-themed = pkgs.writeShellScriptBin "rofi-themed" ''
    scheme=$(${pkgs.glib}/bin/gsettings get org.gnome.desktop.interface color-scheme)
    if [ "$scheme" = "'prefer-dark'" ]; then
      theme=gh-dark-colorblind
    else
      theme=gh-light-colorblind
    fi
    exec ${pkgs.rofi}/bin/rofi -theme "$theme" "$@"
  '';
  rofi-bluetooth-mode = pkgs.writeShellScriptBin "rofi-bluetooth-mode" ''
    bt=${pkgs.bluez}/bin/bluetoothctl

    if [ -z "$1" ]; then
      if $bt show | grep -q "Powered: yes"; then
        echo "Power off"
      else
        echo "Power on"
      fi
      $bt devices | while read -r _ mac name; do
        if $bt info "$mac" | grep -q "Connected: yes"; then
          echo "Disconnect: $name ($mac)"
        else
          echo "Connect: $name ($mac)"
        fi
      done
      exit 0
    fi

    mac=$(echo "$1" | grep -oE '([0-9A-F]{2}:){5}[0-9A-F]{2}')
    case "$1" in
      "Power on")    $bt power on >/dev/null 2>&1 ;;
      "Power off")   $bt power off >/dev/null 2>&1 ;;
      Connect:*)     $bt connect "$mac" >/dev/null 2>&1 ;;
      Disconnect:*)  $bt disconnect "$mac" >/dev/null 2>&1 ;;
    esac
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
    signal-desktop
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
    rofi-power-menu
    rofi-themed
    nerd-fonts.jetbrains-mono
  ];

  xdg.dataFile."rofi/themes/gh-dark-colorblind.rasi".source = ./rofi-gh-dark-colorblind.rasi;
  xdg.dataFile."rofi/themes/gh-light-colorblind.rasi".source = ./rofi-gh-light-colorblind.rasi;

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
      input = {
        "type:pointer" = {
          natural_scroll = "enabled";
        };
        "type:touchpad" = {
          natural_scroll = "enabled";
          tap = "enabled";
        };
      };
      modifier = "Mod4";
      terminal = "ghostty";
      gaps = {
        inner = 10;
        outer = 5;
      };
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
          launcher = "exec ${rofi-themed}/bin/rofi-themed -show combi";
        in
        pkgs.lib.mkOptionDefault {
          "${mod}+Mod1+t" = "exec toggle-theme";
          "${mod}+Mod1+Left" = "workspace prev";
          "${mod}+Mod1+Right" = "workspace next";
          "${mod}+space" = launcher;
          "${mod}+0" = launcher;
          "${mod}+s" = "exec ghostty -e caddy file-server --listen localhost:9172 --browse";
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

  programs.rofi = {
    enable = true;
    package = pkgs.rofi;
    terminal = "${pkgs.ghostty}/bin/ghostty";
    extraConfig = {
      modi = "combi,window,drun,ssh,power:${pkgs.rofi-power-menu}/bin/rofi-power-menu,bluetooth:${rofi-bluetooth-mode}/bin/rofi-bluetooth-mode";
      combi-modes = "window,drun,power,bluetooth";
      show-icons = true;
      icon-theme = "Adwaita";
    };
  };

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

  programs.chromium = {
    enable = true;
    nativeMessagingHosts = [ pkgs.keepassxc ];
    extensions = [
      { id = "oboonakemofpalcgghocfoadofidjkkk"; }
      { id = "ddkjiahejlhfcafbddmgiahcphecmpfh"; }
    ];
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
      "java"
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
