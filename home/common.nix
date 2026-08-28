{ pkgs, ... }:

{
  imports = [ ./core.nix ];

  home.packages = with pkgs; [
    jetbrains-mono
    nil
    nixd
    typst
    yt-dlp
    telegram-desktop
  ];

  fonts.fontconfig.enable = true;

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

  programs.zoxide.enable = true;
}
