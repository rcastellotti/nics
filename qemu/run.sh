#!/bin/sh

qemu-system-x86_64 \
  -smp 4 \
  -m 4096 \
  -machine q35 \
  -drive file=nixos.qcow2,if=virtio,format=qcow2 \
  -drive if=pflash,format=raw,unit=0,readonly=on,file=/opt/zerobrew/share/qemu/edk2-x86_64-code.fd \
  -drive if=pflash,format=raw,unit=1,file=./edk2-x86_64-vars.fd \
  -netdev user,id=net0,hostfwd=tcp::2222-:22 \
  -device virtio-net-pci,netdev=net0
