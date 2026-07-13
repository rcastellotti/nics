let
  key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILqVLRRlGF1nezM9nM87dUBkp3hKkDB+yqJyqPVwt2Wg";
in
{
  "wireguard-client.age".publicKeys = [ key ];
  "wireguard-client-lallo.age".publicKeys = [ key ];
}
