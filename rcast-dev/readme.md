# `rcast-dev`

```sh
terraform plan
terraform apply -var="allow_ssh=true"
terraform apply -var="allow_ssh=false"
```

```sh
nixos-rebuild switch --flake .#rcast-dev --target-host "root@rcast-dev"
```

## generate WG server key
1. `wg genkey | tee server.priv | wg pubkey > server.pub`
2. `agenix -e wireguard-server.age -i /tmp/rc-ssh-key` (in secrets/)
3. create a client config to connect(see below)

## add a  WG client:
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
  Endpoint = vpn.rcast.dev:51820
  PersistentKeepalive = 25
  ```

TODO: backups
