{ pkgs, ... }:

{
  home.username = "rc";
  home.homeDirectory = "/home/rc";
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
    };
    settings = {
      init.defaultBranch = "main";
    };
  };

  programs.tmux = {
    enable = true;
    mouse = true;
    historyLimit = 10000;
    baseIndex = 1;
    shell = "${pkgs.fish}/bin/fish";
    prefix = "C-a";
    extraConfig = ''
      # Enable true color
      set -g default-terminal "tmux-256color"

      # Reload config
      bind r source-file ~/.tmux.conf \; display-message "tmux config reloaded"

      # Split panes using | and -
      bind | split-window -h
      bind - split-window -v
      unbind '"'
      unbind %

      # switch panes using Alt-arrow without prefix
      bind -n M-Left select-pane -L
      bind -n M-Right select-pane -R
      bind -n M-Up select-pane -U
      bind -n M-Down select-pane -D

    '';
  };
}
