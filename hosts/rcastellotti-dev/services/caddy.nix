let
  domains = [
    "rcastellotti.dev"
    "rcast.dev"
  ];
in
{
  services.caddy = {
    enable = true;
    virtualHosts = builtins.listToAttrs (
      map (domain: {
        name = "pad.${domain}";
        value = {
          extraConfig = ''
            reverse_proxy 127.0.0.1:9072 {
              header_up X-Forwarded-Proto https
              header_up X-Real-IP {remote_host}
            }
          '';
        };
      }) domains
    );
  };
}
