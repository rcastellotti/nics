{ pkgs, ... }:

{
  home.username = "rc";
  home.homeDirectory = if pkgs.stdenv.isDarwin then "/Users/rc" else "/home/rc";
  home.stateVersion = "26.05";
  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    eza
    fastfetch
    btop
    git
    jq
    curl
    ffmpeg
    yazi
    unzip
    ncdu
    sqlite
    rlwrap
  ];

  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };

  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set -g fish_greeting
    '';
  };

  programs.direnv = {
    enable = true;
    enableFishIntegration = true;
  };

  programs.git = {
    enable = true;
    settings = {
      user.name = "Roberto Castellotti";
      user.email = "me@rcastellotti.dev";
      init.defaultBranch = "main";
    };
  };

  programs.zellij.enable = true;
}
