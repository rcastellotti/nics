{
  pkgs,
  config,
  lib,
  ...
}:
let
  waybar-dark = ./waybar-dark.css;
  waybar-light = ./waybar-light.css;
  rofi-dark = ./rofi-dark.rasi;
  rofi-light = ./rofi-light.rasi;
  mako-dark = ./mako-dark;
  mako-light = ./mako-light;

  apply-theme = pkgs.writeShellScriptBin "apply-theme" ''
    set -eu

    interface=org.gnome.desktop.interface
    scheme=$(${pkgs.glib}/bin/gsettings get "$interface" color-scheme)

    if [ "$scheme" = "'prefer-dark'" ]; then
      waybar_style=${waybar-dark}
      rofi_theme=${rofi-dark}
      mako_config=${mako-dark}
    else
      waybar_style=${waybar-light}
      rofi_theme=${rofi-light}
      mako_config=${mako-light}
    fi

    ${pkgs.coreutils}/bin/mkdir -p "$HOME/.config/waybar" "$HOME/.config/mako" "$HOME/.local/share/rofi/themes"
    ln -sfn "$waybar_style" "$HOME/.config/waybar/style.css"
    ln -sfn "$rofi_theme" "$HOME/.local/share/rofi/themes/rofi.rasi"
    ln -sfn "$mako_config" "$HOME/.config/mako/config"

    ${pkgs.procps}/bin/pkill -SIGUSR2 -x waybar \
      || ${pkgs.procps}/bin/pkill -SIGUSR2 -x .waybar-wrapped \
      || true

    ${pkgs.mako}/bin/makoctl reload || true
  '';

  toggle-theme = pkgs.writeShellScriptBin "toggle-theme" ''
    set -eu

    interface=org.gnome.desktop.interface
    current=$(${pkgs.glib}/bin/gsettings get "$interface" color-scheme)

    if [ "$current" = "'prefer-dark'" ]; then
      ${pkgs.glib}/bin/gsettings set "$interface" color-scheme 'default'
      ${pkgs.glib}/bin/gsettings set "$interface" gtk-theme 'Adwaita'
    else
      ${pkgs.glib}/bin/gsettings set "$interface" color-scheme 'prefer-dark'
      ${pkgs.glib}/bin/gsettings set "$interface" gtk-theme 'Adwaita-dark'
    fi

    ${apply-theme}/bin/apply-theme
  '';

  popup = app_id: {
    command = "floating enable, resize set 800 600, move position 100 ppt 0 ppt, move left 480 px";
    criteria = { inherit app_id; };
  };
in
{
  home.packages = [
    toggle-theme
    apply-theme
  ];

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
      fonts = {
        names = [ "JetBrainsMono Nerd Font" ];
        size = 8.0;
      };
      gaps = {
        inner = 5;
        outer = 2;
      };
      bars = [ ];
      menu = "${pkgs.rofi}/bin/rofi -show drun";
      window = {
        commands = [
          {
            command = "floating enable, move position center, move scratchpad";
            criteria = {
              app_id = "com.example.scratch-terminal";
            };
          }
          (popup "com.example.bluetooth-popup")
          (popup "com.example.network-popup")
        ];
      };
      startup = [
        {
          command = "swaymsg workspace number 1";
          always = false;
        }
        { command = "${pkgs.keepassxc}/bin/keepassxc"; }
        { command = "apply-theme && exec waybar"; }
        {
          command = "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=sway";
        }
      ];
      keybindings =
        let
          mod = "Mod4";
        in
        pkgs.lib.mkOptionDefault {
          "${mod}+Mod1+t" = "exec toggle-theme";
          "${mod}+Mod1+l" = "exec swaylock";
          "${mod}+Mod1+Left" = "workspace prev";
          "${mod}+Mod1+Right" = "workspace next";
          "${mod}+space" = "exec ${config.wayland.windowManager.sway.config.menu}";
          "${mod}+q" = "kill";
          "${mod}+Escape" = "exec rofi -no-show-icons -show p -modi p:'rofi-power-menu'";
          "${mod}+s" = "exec ghostty -e caddy file-server --listen localhost:9172 --browse";
          "${mod}+b" = "exec firefox";
          "${mod}+n" = "exec zeditor /home/rc/g/nics";
          "${mod}+z" = "exec zeditor";
          "${mod}+t" = "exec Telegram";
          "${mod}+Return" = "exec ghostty";
          "${mod}+Shift+Return" =
            "exec ghostty --class=com.example.scratch-terminal --gtk-single-instance=false";
          "XF86AudioRaiseVolume" = "exec wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+";
          "XF86AudioLowerVolume" = "exec wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-";
          "XF86AudioMute" = "exec wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
          "XF86MonBrightnessUp" = "exec brightnessctl set 5%+";
          "XF86MonBrightnessDown" = "exec brightnessctl set 5%-";
          "Print" = "exec flameshot gui";
        };
    };
  };

  programs.rofi = {
    enable = true;
    theme = "rofi";
    settings = {
      modi = "drun";
      font = "JetBrainsMono Nerd Font 10";
      show-icons = true;
      icon-theme = "Adwaita";
      drun-display-format = "{name}";
      hover-select = true;
    };
  };

  xdg.dataFile."rofi/themes/rofi.rasi" = {
    source = ./rofi-dark.rasi;
    force = true;
  };

  services.mako = {
    enable = true;
  };

}
