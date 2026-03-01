let
  key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILqVLRRlGF1nezM9nM87dUBkp3hKkDB+yqJyqPVwt2Wg";
in
{
  "HCLOUD_TOKEN.age".publicKeys = [ key ];
  "CLOUDFLARE_API_TOKEN.age".publicKeys = [ key ];
}
