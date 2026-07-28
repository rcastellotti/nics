{ pkgs, ... }:

{
  services.dela = {
    enable = true;
    port = 9076;
    environment = {
      NODE_ENV = "production";
    };
  };
}
