# Shared SSH public keys allowed to log in as root and rc on any host that
# enables OpenSSH. Add new host keys here instead of duplicating them per host.
{ ... }:
let
  authorizedKeys = [
    # grizzly
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILqVLRRlGF1nezM9nM87dUBkp3hKkDB+yqJyqPVwt2Wg"
    # polar
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGawr5pI2c6Mbk6c1d9slxH69i7UnoLYIQTAN5KwJ0zx"
    # kodiak deploy (private key in secrets/secrets.yaml)
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDRrtgYeCFj2vR1SSMCq5WyXj8c9sb+XScT53n8JfcvB"
  ];
in
{
  users.users.root.openssh.authorizedKeys.keys = authorizedKeys;
  users.users.rc.openssh.authorizedKeys.keys = authorizedKeys;
}
