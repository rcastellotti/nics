{ pkgs, ... }:

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

  home.sessionVariables = {
    QT_WPA_PLATFORM="wayland";
  };

  fonts.fontconfig.enable = true;

  programs.zoxide.enable=true;
  
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

  programs.vscodium.enable=true;
  
  programs.zed-editor = {
    enable = true;
    extensions = [
      "nix"
      "oxc"
      "sql" 
      "github-theme"
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
