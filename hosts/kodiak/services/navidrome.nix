let
  navidromePort = 4533;
in
{
  services.navidrome = {
    enable = true;
    openFirewall = false;
    settings = {
      Address = "127.0.0.1";
      Port = navidromePort;
      MusicFolder = "/var/lib/navidrome/music";
    };
  };
}
