{ pkgs, ... }:

{
  services.dela = {
    enable = true;
    port = 9076;
  };
}
