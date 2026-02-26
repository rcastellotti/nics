# nics

Local NixOS VM bootstrap using a flake, `disko`, and `nixos-anywhere` for macOS

![](https://github.com/user-attachments/assets/c1ac5fa6-b005-439f-8e51-cb504c5dea1a)

## requirements

- `nix` (`sh <(curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install)`)
- `qemu-system-x86_64` and `qemu-img` (`zb install qemu`)
- `qemu-img create -f qcow2 nixos.qcow2 20G`
- `curl -LO https://releases.nixos.org/nixos/25.11/nixos-25.11.6327.c217913993d6/nixos-minimal-25.11.6327.c217913993d6-x86_64-linux.iso`
- `dd if=/dev/zero of=./edk2-x86_64-vars.fd bs=1k count=64 status=none`

## quickstart

```sh
qemu-system-x86_64 \
  -smp 4 \
  -m 4096 \
  -machine q35 \
  -cdrom nixos-minimal-25.11.6327.c217913993d6-x86_64-linux.iso \
  -drive file=nixos.qcow2,if=virtio,format=qcow2 \
  -drive if=pflash,format=raw,unit=0,readonly=on,file=/opt/zerobrew/share/qemu/edk2-x86_64-code.fd \
  -drive if=pflash,format=raw,unit=1,file=./edk2-x86_64-vars.fd \
  -netdev user,id=net0,hostfwd=tcp::2222-:22 \
  -device virtio-net-pci,netdev=net0
```

In a second terminal:

```sh
nix \
  --extra-experimental-features "nix-command flakes" \
  run github:nix-community/nixos-anywhere -- \
  --flake .#rcastellotti-dev \
  --generate-hardware-config nixos-generate-config ./hardware-configuration.nix \
  --ssh-port 2222 \
  root@localhost
```

Once you are done, restart the vm without the `-cdrom` flag and connect with `ssh rc@localhost -p 2222 -i id_ed25519`

> [!WARNING]  
> `id_ed25519` and `id_ed25519.pub` are intentionally committed for this local VM workflow. Do not reuse them for anything sensitive.


## usage

```sh
git clone https://github.com/rcastellotti/nics.git
make changes
sudo nixos-rebuild switch --flake .#rcastellotti-dev
```
