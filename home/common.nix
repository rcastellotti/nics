{ pkgs, ... }:

{
  home.username = "rc";
  home.homeDirectory = "/home/rc";
  home.packages = with pkgs; [
    nixd
    nil
    eza
    fastfetch
    htop
    git
    jq
    curl
    typst
    yt-dlp
    ffmpeg
    yazi
    unzip
    gimp
    dbeaver-bin
    jetbrains-mono
    ghostty
    vlc
    obsidian
    vscodium
    transmission_4-gtk
    lollypop
    easytag
    chromium
  ];
  home.stateVersion = "26.05";
  programs.home-manager.enable = true;
  fonts.fontconfig.enable = true;

  programs.direnv = {
    enable = true;
    enableFishIntegration = true;
  };

  programs.git = {
    enable = true;
    settings = {
      user.name = "Roberto Castellotti";
      user.email = "me@rcastellotti.dev";
    };
    settings = {
      init.defaultBranch = "main";
    };
  };

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
