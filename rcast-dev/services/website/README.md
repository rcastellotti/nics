```
oxfmt .
nix build
rsync -avzP --delete result/ root@rcast-dev:/var/www/website
```
