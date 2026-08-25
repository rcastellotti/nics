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
mkdir -p ~/Library/Application Support/sops/age
nix-shell -p ssh-to-age --run "ssh-to-age -private-key -i /tmp/polar-ssh-key > ~/Library/Application Support/sops/age/keys.txt"
sudo darwin-rebuild switch --flake .#polar
```

# `rcastellotti-dev`

import private ssh key in `/tmp/rcastellotti-dev-ssh-key`

```sh
sops exec-env secrets/secrets.yaml 'terraform apply'
```

### add ssh-key (run on machine with key in secrets/secrets.yaml)

1. generate an ssh key with bitwarden
2. temp copy the private key to ~/temp-new-key
3. `nix-shell -p ssh-to-age --run 'ssh-to-age -private-key -i ~/temp-new-key > ~/.config/sops/age/keys.txt'`
4. temp copy the public key to ~/temp-new-key.pub
5. `nix shell nixpkgs#ssh-to-age -c ssh-to-age < ~/temp-new-key.pub` (outputs pub age key)
6. `sops --add-age "$POLAR_AGE_RECIPIENT" --rotate --in-place secrets/secrets.yaml` (use key from above)

## add a WireGuard client

+ choose an unused address from the `10.0.0.0/24` VPN subnet. The example below uses `10.0.0.3`;
+ `wg genkey | tee wireguard-client.key | wg pubkey > wireguard-client.pub`
+ add `wireguard-client.pub` to in `hosts/rcastellotti-dev/configuration.nix`:

   ```nix
   {
     publicKey = "CLIENT_PUBLIC_KEY";
     allowedIPs = [ "10.0.0.3/32" ];
   }
   ```
+ create the client configuration. for nix, copy from polar/grizzly, otherwise use:
   ```ini
   [Interface]
   PrivateKey = CLIENT_PRIVATE_KEY
   Address = 10.0.0.3/32

   [Peer]
   PublicKey = SERVER_PUBLIC_KEY
   AllowedIPs = 10.0.0.0/24
   Endpoint = vpn.rcastellotti.dev:51820
   PersistentKeepalive = 25
   ```

+ deploy: `sops exec-env secrets/secrets.yaml 'terraform apply'`
+ verify: `sudo wg show`