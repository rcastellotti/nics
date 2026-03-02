# nics // i guess we are doing nix now

Nix flake for two machines:
- `den`: NixOS server (`x86_64-linux`)
  - `sudo nixos-rebuild switch --flake github:rcastellotti/nics#den`  
- `bearbook`: macOS laptop via nix-darwin (`aarch64-darwin`)
  - `sudo darwin-rebuild -- switch --flake .#bearbook`   
- `rcastelloti-dev`: hetzner main machine (`x86_64-linux`)
  - `sudo nixos-rebuild switch --flake "github:rcastellotti/nics/rcastellotti-dev?dir=path/to/subdir#rcastellotti-dev"`

## `den`

- install nixOS using the graphical ISO
- `nix-shell --extra-experimental-features "nix-command flakes" -p vim git -- git clone https://github.com/rcastellotti/nics`
- `cd nics`
- `nixos-generate-config --show-hardware-config > hardware-configuration.nix`
- `sudo nixos-rebuild switch --flake .#den`

## `bearbook`

- factory reset macOS
- `xcode-select --install`
- `sh <(curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install)`
- `sudo reboot`
- `git clone https://github.com/rcastellotti/nics`
- `sudo nix --extra-experimental-features "nix-command flakes" run nix-darwin/master#darwin-rebuild -- switch --flake .#bearbook`

## rcastellotti.dev

1. `nix shell nixpkgs#mkpasswd --command mkpasswd` and update `configuration.nix` (optional)
2. `nix develop`
  3. `terraform init`
  4. `terraform apply` -> outputs ip
  5. `ssh root@9.167.105.83` and change password
  5. `nix run github:nix-community/nixos-anywhere -- --flake .#rcastellotti-dev --target-host root@89.167.105.83 --build-on-remote` 
  6. start `tailscale` and close firewall

# add a secret

start by extracting the ssh-key from bitwarden:

+ `bw login`
+ `export BW_SESSION="$(bw unlock --raw)"`
+ `bw list items --search "rc-ssh-key" | jq -r '.[]  | {id: .id, name: .name}'`
+ `bw get item <OUTPUT_FROM_ABOVE> | jq -r '.sshKey.privateKey' > /tmp/rc-ssh`

then proceed to set secret:

+ add secret to `secrets.nix`
+ `nix develop --command agenix -e <SECRET_NAME>.age -i /tmp/rc-ssh-key`
+ (optional) `mv <SECRET_NAME>.age secrets/`
+ register secret `installationScript` in `flake.nix`
