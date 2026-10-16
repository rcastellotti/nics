{
  pkgs,
  tma,
  ...
}:
{
  services.tma = {
    enable = true;
    package = tma.packages.${pkgs.stdenv.hostPlatform.system}.default;
    port = 9075;
  };
}
