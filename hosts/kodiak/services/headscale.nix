{ pkgs, ... }:
let
  headscalePolicy = pkgs.writeText "headscale-policy.json" (
    builtins.toJSON {
      ssh = [
        {
          action = "accept";
          src = [ "autogroup:member" ];
          dst = [ "autogroup:self" ];
          users = [ "autogroup:nonroot" ];
        }
      ];
    }
  );
in
{
  services.headscale = {
    enable = true;
    address = "127.0.0.1";
    port = 9077;
    settings = {
      server_url = "https://vpn.rcastellotti.dev";
      policy = {
        mode = "file";
        path = headscalePolicy;
      };
      dns = {
        magic_dns = true;
        base_domain = "t.rcastellotti.dev";
        extra_records = [
          {
            name = "m.kodiak.t.rcastellotti.dev";
            type = "A";
            value = "100.64.0.3";
          }
        ];
        nameservers.global = [
          "1.1.1.1"
          "1.0.0.1"
        ];
      };
    };
  };
}
