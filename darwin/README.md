```
xcode-select --install
sh <(curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install)
sudo reboot
git clone https://github.com/rcastellotti/nics
sudo nix --extra-experimental-features "nix-command flakes"  run nix-darwin/master#darwin-rebuild -- switch --flake .#bearbook
```

```
sudo darwin-rebuild switch --flake .#bearbook
```
