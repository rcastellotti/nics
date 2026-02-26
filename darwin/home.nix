{
  config,
  pkgs,
  ...
}:
{
  home.stateVersion = "23.05";

  home.packages = [
    pkgs.nushell
    pkgs.starship
    pkgs.atuin
    pkgs.eza
    pkgs.delta
    pkgs.gh

    pkgs.nil
    pkgs.nixd
    pkgs.alejandra

    pkgs.google-chrome
    pkgs.raycast
    pkgs.bitwarden-desktop
    pkgs.tailscale

    pkgs.zed-editor
    pkgs.vscode
    pkgs.ghostty-bin
    pkgs.openssh
    pkgs.yazi
  ];
  # https://nix-community.github.io/home-manager/options.xhtml
  programs.home-manager.enable = true;

  programs.ghostty = {
    enable = true;
    package = pkgs.ghostty-bin;
    settings = {
      theme = "dark:3024 Night,light:3024 Day";
      font-size = 12.0;
    };
  };

  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "Roberto Castellotti";
        email = "me@rcastellotti.dev";
      };
    };
  };

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks = {
      "*" = {
        forwardAgent = false;
      };
      "github.com" = {
        identityFile = "~/.ssh/id_ed25519_sk_rk";
      };
    };
  };

  programs.zed-editor = {
    enable = true;
    # https://github.com/zed-industries/extensions/tree/main/extensions
    extensions = [ "github-theme" ];
    userSettings = {
      ui_font_size = 12.0;
      buffer_font_size = 12.0;
      ui_font_family = "JetBrains Mono";
      buffer_font_family = "JetBrains Mono";
      autosave = "on_focus_change";
      theme = {
        mode = "system";
        dark = "GitHub Dark High Contrast";
        light = "GitHub Light High Contrast";
      };
    };
  };

  programs.vim = {
    enable = true;
    defaultEditor = true;
  };

  programs.nushell = {
    enable = true;
    extraConfig = "$env.config.show_banner = false";
  };

  programs.starship = {
    enable = true;
    settings = {
      # "$schema" = "https://starship.rs/config-schema.json";
      # https://gist.githubusercontent.com/s-a-c/0e44dc7766922308924812d4c019b109/raw/ac779c68568d0b5f433ab843585eb47967caf509/starship.nix
      add_newline = true;
      format = "[┌╴\\(](bold green)[$username@$hostname](bold blue)[\\)](bold green) $all[└─](green) $character";
      username = {
        style_user = "blue bold";
        style_root = "red bold";
        format = "[$user]($style)";
        show_always = true;
      };
      hostname = {
        ssh_only = false;
        format = "[$ssh_symbol](bold blue)[$hostname](bold blue)";
        disabled = false;
      };
    };
  };
}
