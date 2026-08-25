{ ... }:

{
  imports = [ ../../home/common.nix ];

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    settings.rcastellotti-dev = {
      HostName = "10.0.0.1";
      User = "rc";
    };
  };
}
