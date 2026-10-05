{ pkgs, ... }:

{
  environment.etc."chromium/native-messaging-hosts/org.keepassxc.keepassxc_browser.json".text =
    builtins.toJSON
      {
        name = "org.keepassxc.keepassxc_browser";
        description = "KeePassXC integration with native messaging support";
        path = "${pkgs.keepassxc}/bin/keepassxc-proxy";
        type = "stdio";
        allowed_origins = [
          "chrome-extension://oboonakemofpalcgghocfoadofidjkkk/"
        ];
      };
}
