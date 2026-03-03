# nics // i guess we are doing nix now

Nix flake for two machines:
- `den`: NixOS server (`x86_64-linux`)
  - `sudo nixos-rebuild switch --flake github:rcastellotti/nics#den`  
- `bearbook`: macOS laptop via nix-darwin (`aarch64-darwin`)
  - `sudo darwin-rebuild -- switch --flake .#bearbook`   
- `rcastelloti-dev`: hetzner main machine (`x86_64-linux`)
  - `sudo nixos-rebuild switch --flake "github:rcastellotti/nics#rcastellotti-dev"`

## `den`

- install nixOS using the graphical ISO
- `nix run nixpkgs#git -- clone https://github.com/rcastellotti/nics`
- `cd nics`
- `nixos-generate-config --show-hardware-config > hardware-configuration.nix`
- `sudo nixos-rebuild switch --flake .#den`

## `bearbook`

- factory reset macOS
- `xcode-select --install`
- `sh <(curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install)`
- `sudo reboot`
- `git clone https://github.com/rcastellotti/nics`
- `sudo nix run nix-darwin/master#darwin-rebuild -- switch --flake .#bearbook`
  

## rcastellotti.dev

1. `nix run nixpkgs#mkpasswd` and update `configuration.nix` (optional)
2. `nix develop`
  3. `terraform init`
  4. `terraform apply` -> outputs ip
  5. check `deploy.sh` and run it (uploads ssh key needed to decrypt secrets) 

# add a secret

start by extracting the ssh-key from bitwarden:

+ `bw login`
+ `bw get item $(bw list items --search "rc-ssh-key" | jq -r '.[].id') | jq -r '.sshKey.privateKey' > /tmp/rc-ssh-key`

then proceed to set secret:

+ add secret to `secrets.nix`
+ `nix develop --command agenix -e <SECRET_NAME>.age -i /tmp/rc-ssh-key`
+ (optional) `mv <SECRET_NAME>.age secrets/`
+ register secret `installationScript` in `flake.nix`
