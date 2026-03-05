let
  key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILqVLRRlGF1nezM9nM87dUBkp3hKkDB+yqJyqPVwt2Wg";
in
{
  "HCLOUD_TOKEN.age".publicKeys = [ key ];
  "CLOUDFLARE_API_TOKEN.age".publicKeys = [ key ];
  "AWS_ACCESS_KEY_ID.age".publicKeys = [ key ];
  "AWS_SECRET_ACCESS_KEY.age".publicKeys = [ key ];
  "AWS_ENDPOINT_URL_S3.age".publicKeys = [ key ];
  "tailscale-authkey.age".publicKeys = [ key ];
  "hedgedoc-session-secret.age".publicKeys = [ key ];
}
