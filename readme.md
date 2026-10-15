# `grizzly`

```sh
sudo nixos-generate-config --show-hardware-config > hosts/grizzly/hardware-configuration.nix
mkdir -p ~/.config/sops/age
nix-shell -p ssh-to-age --run "ssh-to-age -private-key -i /tmp/grizzly-ssh-key > ~/.config/sops/age/keys.txt"
sudo nixos-rebuild switch --flake .#grizzly
```

# `kodiak`

The kodiak admin/deploy SSH keypair lives in `secrets/secrets.yaml` as
`kodiak-deploy-ssh-key` / `kodiak-deploy-ssh-key-pub`. Terraform reads it via
the `carlpett/sops` provider, so the age key must be available at plan time:

```sh
SOPS_AGE_KEY_FILE=~/.config/sops/age/keys.txt sops exec-env secrets/secrets.yaml 'terraform apply'
```

## join the tailnet

Headscale is available at `https://vpn.rcastellotti.dev`. MagicDNS is enabled
with the `t.rcastellotti.dev` base domain.

Create a Headscale user once on `kodiak`:

```sh
sudo headscale users create rc
```

join with: 

```sh
sudo tailscale up --login-server https://vpn.rcastellotti.dev 
```

accept from the server (VAL can be fetched from systemd logs):

```sh
 sudo headscale auth register --auth-id <VAL> --user rc
 ```

### add ssh-key (run on machine with key in secrets/secrets.yaml)

1. generate an ssh key with bitwarden
2. temp copy the private key to ~/temp-new-key
3. `nix-shell -p ssh-to-age --run 'ssh-to-age -private-key -i ~/temp-new-key > ~/.config/sops/age/keys.txt'`
4. temp copy the public key to ~/temp-new-key.pub
5. `nix shell nixpkgs#ssh-to-age -c ssh-to-age < ~/temp-new-key.pub` (outputs pub age key)
6. `sops --add-age "$POLAR_AGE_RECIPIENT" --rotate --in-place secrets/secrets.yaml` (use key from above)

## wireguard

A raw WireGuard server runs on `kodiak` as an IPv4-only full-tunnel gateway.

- Endpoint: `wg.rcastellotti.dev:44821/udp` (wildcard DNS already points at kodiak)
- Tunnel subnet: `10.100.0.0/24` (server `10.100.0.1`)
- Server public key: `a2eGxyKGf+diOP53m+kRtwxayUJ3R2kmx61M9uOFLiM=`
- The server private key lives in `secrets/secrets.yaml` as
  `wireguard-kodiak-private-key`.

The listen port must be open in the Hetzner cloud firewall. It is declared in
`main.tf` (`local.ports`); apply it once:

```sh
SOPS_AGE_KEY_FILE=~/.config/sops/age/keys.txt sops exec-env secrets/secrets.yaml 'terraform apply'
```

### add a client

1. Generate a keypair on the client:

   ```sh
   wg genkey | tee client.key | wg pubkey
   ```

2. Register the public key on the server by adding a peer to
   `hosts/kodiak/configuration.nix` (pick an unused `N` from 2-254):

   ```nix
   peers = [
     {
       publicKey = "<client public key>";
       allowedIPs = [ "10.100.0.<N>/32" ];
     }
   ];
   ```

3. Deploy kodiak.

4. Create the client config (see template below) and bring it up:
   `sudo wg-quick up ./client.conf`.

### client config template

```ini
[Interface]
PrivateKey = <client private key from step 1>
Address = 10.100.0.<N>/32
DNS = 1.1.1.1
MTU = 1420

[Peer]
PublicKey = a2eGxyKGf+diOP53m+kRtwxayUJ3R2kmx61M9uOFLiM=
Endpoint = wg.rcastellotti.dev:44821
AllowedIPs = 0.0.0.0/0
PersistentKeepalive = 25
```
