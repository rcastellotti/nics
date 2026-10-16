{
  services.tailscale = {
    enable = true;
    openFirewall = true;
    extraSetFlags = [ "--ssh" ];
  };
}
