{
  pkgs,
  ...
}:
{
  environment.systemPackages = [
    pkgs.android-mic
    pkgs.android-tools
  ];

  services.pipewire.extraConfig.pipewire."60-android-mic" = {
    context.objects = [
      {
        factory = "adapter";
        args = {
          "factory.name" = "support.null-audio-sink";
          "node.name" = "AndroidMic_Sink";
          "node.description" = "AndroidMic Sink";
          "media.class" = "Audio/Sink";
          "audio.position" = [
            "FL"
            "FR"
          ];
          "object.linger" = true;
        };
      }
    ];
    context.modules = [
      {
        name = "libpipewire-module-loopback";
        args = {
          "node.description" = "AndroidMic Microphone";
          "node.group" = "androidmic";
          "capture.props" = {
            "node.target" = "AndroidMic_Sink";
            "stream.capture.sink" = true;
            "node.passive" = true;
          };
          "playback.props" = {
            "node.name" = "AndroidMic_Microphone";
            "media.class" = "Audio/Source";
            "audio.position" = [ "MONO" ];
          };
        };
      }
    ];
  };
}
