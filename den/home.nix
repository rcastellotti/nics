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
  ];
  home.stateVersion = "26.05";
  programs.home-manager.enable = true;
  programs.direnv.enable = true;

  programs.git = {
    enable = true;
    settings = {
      user.name = "Roberto Castellotti";
      user.email = "me@rcastellotti.dev";
    };
  };

  programs.zed-editor = {
    enable = true;
    extensions = [ "nix" ];
    userSettings = {
      auto_update = false;
      terminal = {
        shell = {
          program = "fish";
        };
        working_directory = "current_project_directory";
      };
      vim_mode = false;
      load_direnv = "shell_hook";
      ui_font_size = 12;
      buffer_font_size = 12;
      disable_ai = true;
    };
  };
}
