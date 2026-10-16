{ ... }:

{
  xdg.configFile."waybar/style.css" = {
    source = ./waybar-dark.css;
    force = true;
  };

  programs.waybar.enable = true;
  programs.waybar.settings.main = {
    modules-left = [
      "custom/power"
      "sway/workspaces"
      "sway/mode"
      "sway/scratchpad"
    ];
    modules-center = [ "clock" ];
    modules-right = [
      "tray"
      "cpu"
      "memory"
      "disk"
      "wireplumber"
      "bluetooth"
      "network"
      "battery"
    ];
    "custom/power" = {
      format = "󰐥";
      tooltip = false;
      on-click = "exec rofi -no-show-icons -show p -modi p:'rofi-power-menu'";
    };
    clock = {
      format = "{:%a %m/%d/%y %H:%M} ";
      "format-alt" = "{:%A, %B %d, %Y (%R)} ";
      "tooltip-format" = "<tt><small>{calendar}</small></tt>";
      calendar = {
        mode = "year";
        "mode-mon-col" = 3;
        "weeks-pos" = "right";
        "first-day-of-week" = 1;
        "on-scroll" = 1;
        "on-click-right" = "mode";
        format = {
          months = "<span color='#01a0e4'><b>{}</b></span>";
          days = "<span color='#01a252'><b>{}</b></span>";
          weeks = "<span color='#cdab53'><b>W{}</b></span>";
          weekdays = "<span color='#a16a94'><b>{}</b></span>";
          today = "<span color='#db2d20'><b><u>{}</u></b></span>";
        };
      };
      actions = {
        "on-click-right" = "mode";
        "on-click-forward" = "tz_up";
        "on-click-backward" = "tz_down";
        "on-scroll-up" = "shift_up";
        "on-scroll-down" = "shift_down";
      };
    };
    network = {
      "on-click" = "scratchpad-term wifi impala";
      "on-click-right" = "scratchpad-term wifi impala";
      format-wifi = "  ({ipaddr})";
      "format-alt" = "  {essid} ({ipaddr})";
      "format-alt-click" = 1;
      format-ethernet = "󰈀 {ifname} ({ipaddr})";
      format-disconnected = "󰖪 Disconnected";
      tooltip-format-wifi = "{essid}\n{ipaddr}\nSignal: {signalStrength}%";
      tooltip-format-ethernet = "Wired: {ifname}\n{ipaddr}";
      tooltip-format-disconnected = "Disconnected";
    };
    bluetooth = {
      "on-click" = "scratchpad-term bluetooth bluetui";
      "on-click-right" = "scratchpad-term bluetooth bluetui";
      format = " {status}";
      format-disabled = "";
      format-connected = " {num_connections} connected";
      tooltip-format = "{controller_alias}\t({controller_address})";
      tooltip-format-connected = "{controller_alias}\t({controller_address})\nConnected: {num_connections}\n\n{device_enumerate}";
      tooltip-format-enumerate-connected = "{device_alias}\t{device_address}";
    };
    battery = {
      interval = 60;
      states = {
        warning = 90;
        critical = 20;
      };
      events = {
        on-discharging-warning = "notify-send -u normal 'Low Battery'";
        on-discharging-critical = "notify-send -u critical 'Very Low Battery'";
        on-charging-100 = "notify-send -u normal 'Battery Full!'";
        on-discharging = "notify-send -u normal 'Power Switch' Discharging";
        on-charging = "notify-send -u normal 'Power Switch' Charging'";
      };
      format = "{capacity}% {icon}";
      format-charging = "󰂄 {capacity}%";
      format-plugged = "󰚥 {capacity}%";
      format-full = "󰁹 {capacity}%";
      format-icons = [
        ""
        ""
        ""
        ""
        ""
      ];
      tooltip-format-charging = "{capacity}% Charging ({time})";
      tooltip-format-discharging = "{capacity}% Discharging ({time})";
      tooltip-format-plugged = "{capacity}% Plugged in";
      tooltip-format-full = "{capacity}% Full";
      max-length = 25;
    };
    wireplumber = {
      format = "{volume}% {icon}";
      format-bluetooth = "{volume}% {icon}";
      format-muted = "";
      format-icons = [
        ""
        ""
      ];
      scroll-step = 1;
      on-click = "pwvucontrol";
    };
    cpu = {
      interval = 1;
      format = "{icon0}{icon1}{icon2}{icon3} {usage:>2}% ";
      format-icons = [
        "▁"
        "▂"
        "▃"
        "▄"
        "▅"
        "▆"
        "▇"
        "█"
      ];
    };
    disk = {
      interval = 30;
      format = "{percentage_free}% free on {path}";
    };
    memory = {
      interval = 30;
      format = "{used:0.1f}G/{total:0.1f}G ";
    };
  };
}
