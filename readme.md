# `grizzly`

```sh
sudo nixos-generate-config --show-hardware-config > hosts/grizzly/hardware-configuration.nix
mkdir -p ~/.config/sops/age
nix-shell -p ssh-to-age --run "ssh-to-age -private-key -i /tmp/grizzly-ssh-key > ~/.config/sops/age/keys.txt"
sudo nixos-rebuild switch --flake .#grizzly
```

# `kodiak`

import private ssh key in `/tmp/kodiak-ssh-key`

```sh
sops exec-env secrets/secrets.yaml 'terraform apply'
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
