# nics // i guess we are doing nix now

Nix flake for two machines:
- `den`: NixOS server (`x86_64-linux`)
- `bearbook`: macOS laptop via nix-darwin (`aarch64-darwin`)

## `den`

- install nixOS using the graphical ISO
- `nix-shell --extra-experimental-features "nix-command flakes" -p vim git -- git clone https://github.com/rcastellotti/nics`
- `cd nics`
- `nixos-generate-config --show-hardware-config > den-hardware-configuration.nix`
- `sudo nixos-rebuild switch --flake .#den`

## `bearbook`

- factory reset macOS
- `xcode-select --install`
- `sh <(curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install)`
- `sudo reboot`
- `git clone https://github.com/rcastellotti/nics`
- `sudo nix --extra-experimental-features "nix-command flakes" run nix-darwin/master#darwin-rebuild -- switch --flake .#bearbook`
