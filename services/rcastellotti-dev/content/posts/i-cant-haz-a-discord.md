---
title: "I cant haz a (one) discord"
date: 2026-09-03
---

For some reason I cannot donwload discord

```sh
error: Cannot build '/nix/store/d2kgyamfxd09c26pvwn6wli46s0dh85j-full.distro.drv'.
       Reason: builder failed with exit code 1.
       Output paths:
         /nix/store/p8kv6fihgdb9sasbz0qrih0nh6z87ik7-full.distro
       Last 11 log lines:
       > structuredAttrs is enabled
       >
       > trying https://stable.dl2.discordapp.net/distro/app/stable/linux/x64/1.0.154/full.distro
       > curl: (35) Recv failure: Connection reset by peer
       > Warning: Problem (retrying all errors). Retrying in 1 second. 3 retries left.
       > curl: (35) Recv failure: Connection reset by peer
       > Warning: Problem (retrying all errors). Retrying in 2 seconds. 2 retries left.
       > curl: (35) Recv failure: Connection reset by peer
       > Warning: Problem (retrying all errors). Retrying in 4 seconds. 1 retry left.
       > curl: (35) Recv failure: Connection reset by peer
       > error: cannot download full.distro from any mirror
       For full logs, run:
         nix log /nix/store/d2kgyamfxd09c26pvwn6wli46s0dh85j-full.distro.drv
error: Cannot build '/nix/store/vxx22hmmjmxrf0jyrnh8qhpw0gqbp1k1-discord-1.0.154.drv'.
       Reason: 1 dependency failed.
       Output paths:
         /nix/store/pfrww5qrwx8j1f9xnjpf2zbyhqliljpj-discord-1.0.154
```

## troubleshooting

`nix-prefetch-url` eventually succeeds after a couple of errors:

```sh
rc@grizzly ~/g [2]> nix-prefetch-url https://stable.dl2.discordapp.net/distro/app/stable/linux/x64/1.0.154/full.distro
warning: unable to download 'https://stable.dl2.discordapp.net/distro/app/stable/linux/x64/1.0.154/full.distro': SSL connect error (35) Recv failure: Connection reset by peer; retrying in 341 ms (attempt 1/5)
warning: unable to download 'https://stable.dl2.discordapp.net/distro/app/stable/linux/x64/1.0.154/full.distro': SSL connect error (35) Recv failure: Connection reset by peer; retrying in 610 ms (attempt 2/5)
path is '/nix/store/p8kv6fihgdb9sasbz0qrih0nh6z87ik7-full.distro'
```

Initially i thought it might be something ipv6 related, but forcing ipv4 with `curl` shows the same problem:

```sh
rc@grizzly ~/g [23]> curl -4 -L https://stable.dl2.discordapp.net/distro/app/stable/linux/x64/1.0.154/full.distro -o /dev/null
curl: (35) Recv failure: Connection reset by peer
rc@grizzly ~/g [35]> curl -4 -L https://stable.dl2.discordapp.net/distro/app/stable/linux/x64/1.0.154/full.distro -o /dev/null
curl: (35) Recv failure: Connection reset by peer
rc@grizzly ~/g [35]> curl -4 -L https://stable.dl2.discordapp.net/distro/app/stable/linux/x64/1.0.154/full.distro -o /dev/null
curl: (35) Recv failure: Connection reset by peer
rc@grizzly ~/g [35]> curl -4 -L https://stable.dl2.discordapp.net/distro/app/stable/linux/x64/1.0.154/full.distro -o /dev/null
  % Total    % Received % Xferd  Average Speed  Time    Time    Time   Current
                                 Dload  Upload  Total   Spent   Left   Speed
100 94.93M 100 94.93M   0      0  7.16M      0   00:13   00:13          7.10M
```

i'm not sure what exactly is happening, but now i'm too afraid to ask :)
