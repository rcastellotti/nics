{ pkgs, ... }:

{
  services.dela = {
    enable = true;
    port = 9076;
    logLevel = "trace";
    env = "PRD";
    webauthn = {
      rpID = "rcastellotti.dev";
      rpName = "rcastellotti.dev";
      expectedOrigins = "https://dela.rcastellotti.dev";
    };
  };
}
