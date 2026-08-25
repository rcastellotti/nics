# grizzly

```sh
sudo nixos-generate-config --show-hardware-config > hosts/grizzly/hardware-configuration.nix
mkdir -p ~/.config/sops/age
nix-shell -p ssh-to-age --run "ssh-to-age -private-key -i /tmp/rc-ssh-key > ~/.config/sops/age/keys.txt"
sudo nixos-rebuild switch --flake .#grizzly
```

# polar

```sh
curl -fsSL https://install.determinate.systems/nix | sh -s -- install
sudo nix run nix-darwin/master#darwin-rebuild -- switch --flake .#polar
sudo darwin-rebuild switch --flake .#polar
```

# `rcastellotti-dev`

```sh
sops exec-env secrets/secrets.yaml 'terraform plan'
```

## generate WG server key

1. `wg genkey | tee server.priv | wg pubkey > server.pub`
2. Edit the SOPS file with `sops secrets/secrets.yaml` (using `/tmp/rc-ssh-key` as the age identity).
3. create a client config to connect(see below)

## add a WG client:

1. generate key: `wg genkey | tee private.key | wg pubkey > public.key`
2. add it to the configuration block in `configuration.nix`
3. use the following config skeleton

```ini
[Interface]
PrivateKey = SERVER_PRIVATE_KEY
Address = 10.0.0.2/32
DNS = 1.1.1.1

[Peer]
PublicKey = CLIENT_PUBLIC_KEY
AllowedIPs = 10.0.0.2/24
Endpoint = vpn.rcastellotti.dev:51820
PersistentKeepalive = 25
```
