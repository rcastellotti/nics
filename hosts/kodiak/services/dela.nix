{
  pkgs,
  dela,
  ...
}:
{
  services.dela = {
    package = dela.packages.${pkgs.stdenv.hostPlatform.system}.default;
    enable = true;
    port = 9076;
  };
}
