---
title: "it ain't much, but it's honest work"
date: 2026-03-27
---

Recently I thought it was a good idea to purchase the `itshonest.work` domain to do the funniest thing ever (maybe), nothing too interesting, but I learned a couple of things I want to write down. I suggest you give the [repo](https://git.rcastellotti.dev/rc/aintmuch.but.itshonest.work/) a check before moving on tho, if you are too lazy here is a TLDR for the "architecture":

- `index.html` and `abiw.png` are uploaded to [Cloudflare R2](https://www.cloudflare.com/en-gb/developer-platform/products/r2/)
- a transform rule is added to rewrite path from `/` to `/index.html`, as R2 doesn't serve a [default document](https://docs.aws.amazon.com/AmazonS3/latest/userguide/IndexDocumentSupport.html)
- a cache rule is created, more on this below

## you can just cache things

By default R2 files are not cached, as you can see by consulting the `cf-cache-status` header:

```shell
$: curl -s -o /dev/null -D - https://aintmuch.but.itshonest.work/abiw.png | grep "cache"
cf-cache-status: DYNAMIC
```

`DYNAMIC` means that `abiw.png` was [requested from the origin web server](https://developers.cloudflare.com/cache/concepts/cache-responses/#dynamic), but, what's a Cloudflare without a caching? Let's fix that by creating a ruleset first,
and a caching rule:

```sh
CACHE_RULESET_ID=$(
  cf "/zones/$ZONE_ID/rulesets" \
    -X POST \
    --data '{
      "description": "cache all the things",
      "kind": "zone",
      "phase": "http_request_cache_settings"
    }' \
| jq -r '.result.id'
)
```

```sh
cf "/zones/$ZONE_ID/rulesets/$CACHE_RULESET_ID" \
  -X PUT \
  --json '{
  "rules": [
  {
    "expression": "(http.host eq \"aintmuch.but.itshonest.work\")",
    "description": "cache everything forever",
    "action": "set_cache_settings",
    "action_parameters": {
      "cache": true,
      "edge_ttl": { "mode": "override_origin", "default": 31536000 },
      "browser_ttl": { "mode": "override_origin", "default": 31536000 }
    }
  }]
}' | jq
```

NOTE: `cf` is a custom function calling `curl` with a bunch of preset values.

So what? `HIT`ting cache now? you bet:

```shell
$: curl -s -o /dev/null -D - https://aintmuch.but.itshonest.work | grep "cache"
cache-control: max-age=31536000
cf-cache-status: HIT
```

## you can just store secrets in the repo

Apparently [I am doing nix now](https://git.rcastellotti.dev/rc/nics), and with this comes a nice approach to secret management.

The [flake](https://git.rcastellotti.dev/rc/aintmuch.but.itshonest.work/src/branch/main/flake.nix) pins two inputs beyond nixpkgs:

- [**agenix**](https://github.com/ryantm/agenix): a tool for encrypting secrets with [`filosottile/age`](https://github.com/filosottile/age)
- [**agenix-shell**](https://github.com/aciceri/agenix-shell): a companion flake to decrypt secrets into environment variables in the devShell.

The `devShell` provides `age`, `agenix`, `jq`, and [`liquidprompt`](https://github.com/liquidprompt/liquidprompt) (defintely unnecessary, but I like it). The `shellHook` sources liquidprompt and then runs the `agenix-shell` installation script, which decrypts three secrets (`CLOUDFLARE_API_TOKEN`, `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`). This is super handy for development as it means i can just copy a command from the script and run it without having to worry about manually setting them.

Decryption uses a private SSH key located at `/tmp/rc-ssh-key` I extract from my Bitwarden vault with:

```shell
bw get item $(bw list items --search "rc-ssh-key" | jq -r '.[].id') | jq -r '.sshKey.privateKey' > /tmp/rc-ssh-key
```

The matching public key is fetched at eval time from [https://git.rcastellotti.dev/rc.keys](https://git.rcastellotti.dev/rc.keys`) inside [`secrets.nix`](https://git.rcastellotti.dev/rc/aintmuch.but.itshonest.work/src/branch/main/secrets.nix), which declares which public keys can decrypt each secret file.

Each `.age` file is the encrypted ciphertext of the corresponding secret, this is safe to commit, because they can only be decrypted by whoever holds the matching private key (aka me).

To set or rotate a secret I run, e.g.:

```shell
agenix -e CLOUDFLARE_API_TOKEN.age
```

This is quickly becoming my favourite approach to secret management, if you don't like nix you can use [jdx/fnox](https://github.com/jdx/fnox), perhaps in combination with [jdx/mise](https://github.com/jdx/mise), to achieve something similar.

## you can just upload to S3 with curl

Uploading a file to S3 is easy with `curl`:

```sh
curl -X PUT "https://$ACCOUNT_ID.r2.cloudflarestorage.com/$BUCKET_NAME/abiw.png" \
  --aws-sigv4 "aws:amz:auto:s3" \
  --user "$AWS_ACCESS_KEY_ID:$AWS_SECRET_ACCESS_KEY" \
  --upload-file abiw.png \
  -H "Content-Type: image/png"
```

Yup, I hear you, yet another `curl` W, hard to disagree.

## conclusions

This setup is essentially free to run, as Cloudflare free tier includes:

- 1 milion [R2 Standard Class A Operations](https://developers.cloudflare.com/r2/pricing/#class-a-operations) per month
- 10 milion [R2 Standard Class B Operations](https://developers.cloudflare.com/r2/pricing/#class-b-operations) per month
- no egress fees
- free caching

P.S: I am not a paid shill, I do this for free :P

[It ain't much, but it's honest work](https://aintmuch.but.itshonest.work), someone may say :)
