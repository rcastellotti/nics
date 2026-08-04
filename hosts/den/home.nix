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
    dbeaver-bin
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
  ];

  fonts.fontconfig.enable = true;

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

  programs.vscodium = {
    enable = true;
    profiles.default.extensions = with pkgs.vscode-extensions; [
      biomejs.biome
      jnoortheen.nix-ide
    ];
    profiles.default.userSettings = {
      "window.autoDetectColorScheme" = true;
      "terminal.integrated.defaultProfile.linux" = "fish";
      "terminal.integrated.profiles.linux" = {
        fish = {
          path = "${pkgs.fish}/bin/fish";
        };
      };
    };
  };

  programs.zed-editor = {
    enable = true;
    extensions = [
      "nix"
      "biome"
      "sql"
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
