# grizzly

```sh
sudo nixos-generate-config --show-hardware-config > hosts/grizzly/hardware-configuration.nix
mkdir -p ~/.config/sops/age
nix-shell -p ssh-to-age --run "ssh-to-age -private-key -i /tmp/rc-ssh-key > ~/.config/sops/age/keys.txt"
sudo nixos-rebuild switch --flake .#grizzly
```

# polar

```sh
curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install | sh
sudo nix run --extra-experimental-features 'nix-command flakes' nix-darwin/master#darwin-rebuild -- switch --flake .#polar
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

```sh
hugo new content 2026/08/27.md
```

preview with `hugo server -D --port 9172`.
