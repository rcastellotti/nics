---
title: "yogit"
date: 2026-08-29
---

# Yogit implementation plan

## Goal

Yogit is a deliberately minimal, single-tenant Git hosting service for Linux. It is distributed as one Go binary and delegates Git protocol and repository operations to the installed `git` executable.

The service provides:

- Git clone, fetch, and push through an embedded SSH server.
- Automatic creation of a bare repository on its first push.
- A public, read-only web interface for repositories, commits, trees, files, branches, and tags.
- CLI management of multiple authorized SSH public keys.
- A Nix flake and a NixOS module.

Yogit is not a collaboration platform. It has no pull requests, issues, comments, additional users, roles, or repository permission system.

## Fixed decisions

- The project and executable are named `yogit`.
- Linux is the only supported operating system.
- The application is a single Go binary at runtime, with Git available as an external executable.
- Configuration is supplied through CLI flags.
- SQLite stores application metadata.
- Bare repositories are stored as directories on disk.
- There are no web identities, login flows, or authenticated HTTP actions.
- The operator may register multiple SSH keys through the local CLI.
- All registered SSH keys have access to every repository.
- The SSH username is always `git`.
- Git transport is SSH only. HTTP does not expose Git's smart protocol.
- Repository web pages are public.
- Repositories are created by pushing to a missing repository name.
- Nested repository names are rejected.
- Yogit offers no repository deletion or renaming operation.
- Repository descriptions use the bare repository's standard `description` file.
- Manually copied bare repositories are discovered automatically.
- Production HTTPS is expected to terminate at a reverse proxy.
- The NixOS module may optionally manage nginx and ACME.
- HTML is rendered with `templ`.
- Goldmark renders Markdown and Chroma performs syntax highlighting.

## Process model

The binary initially exposes these commands:

```text
yogit serve
yogit admin key add
yogit admin key a
yogit admin key remove
yogit admin repo description
```

`yogit serve` runs the HTTP and SSH listeners in one process. Either listener failing during startup must prevent the service from reporting itself ready. Runtime failure of a listener should shut down the process cleanly so the service manager can restart it.

The `admin` commands operate locally against the configured data directory. They do not expose an administration protocol over HTTP or SSH.

## Persistent data

The default layout is:

```text
/var/lib/yogit/
|-- yogit.db
`-- repositories/
    |-- yogit.git/
    `-- example.git/
```

SQLite contains only application state:

- Schema version and migrations.
- SSH public keys, fingerprints, and labels.

Repository existence, refs, objects, default branch, and description remain Git-native data. Repository descriptions are read from and written to each bare repository's `description` file.

Backups must include the SQLite database, the complete repositories directory, and the SSH server host key.

## Operator CLI

All privileged actions are local CLI operations requiring filesystem access to Yogit's data directory. The website is entirely public and read-only.

Initial SSH-key setup uses a command similar to:

```sh
yogit admin key add \
  --data-dir /var/lib/yogit \
  --label laptop \
  ~/.ssh/id_ed25519.pub
```

The CLI provides commands to:

- Add and label an SSH public key.
- List authorized SSH keys and their fingerprints.
- Remove an SSH public key by fingerprint.
- Set or clear a repository description.

Key input is parsed and normalized before storage. Duplicate keys are rejected. There are no web accounts, passkeys, passwords, invitations, sessions, roles, or per-repository permissions.

## Embedded SSH server

A typical remote is:

```sh
git remote add origin ssh://git@git.example.com:2222/project.git
git push -u origin main
```

The server accepts public-key authentication only. A key is authorized when its normalized fingerprint matches a non-revoked key in SQLite.

The SSH server must reject:

- Usernames other than `git`.
- Interactive shells and PTYs.
- Port, agent, and X11 forwarding.
- Arbitrary commands.
- Unsupported subsystems.
- Environment manipulation beyond the narrow protocol requirements Git needs.

Only these commands are accepted:

- `git-upload-pack` for clone and fetch.
- `git-receive-pack` for push and push-to-create.

The received command must be parsed without invoking a shell. Repository names are normalized and validated before constructing an absolute path beneath the repository root. Git subprocesses are executed directly with controlled arguments and environment variables.

## Repository names

Repository names are flat. Nested paths are rejected.

The initial validation policy should:

- Accept lowercase ASCII letters, digits, `.`, `_`, and `-`.
- Require at least one valid character.
- Accept and normalize one trailing `.git`.
- Reject names beginning with `-`.
- Reject `.` and `..`.
- Reject path separators, control characters, whitespace, shell syntax, and NUL bytes.
- Reject names that become empty after normalization.

The exact maximum length should be conservative and tested. The normalized on-disk name includes a `.git` suffix.

## Push-to-create

When `git-receive-pack` targets a repository that does not exist:

1. Normalize and validate the repository name.
2. Acquire a per-name creation lock.
3. Check again whether the repository exists.
4. Initialize a bare repository.
5. Set symbolic `HEAD` to `refs/heads/main`.
6. Run `git-receive-pack` against it.
7. Keep the repository if at least one ref was created.
8. Remove it if this process created it, the initial push failed, and it still contains no refs.

Concurrent initial pushes to the same name must be serialized. Cleanup must never remove a repository that existed before the current request or one that has acquired a ref.

There is no repository creation form or authenticated HTTP endpoint.

## Existing repository discovery

The repository listing is derived from valid bare repositories immediately beneath the configured repository root. A directory is visible only if it has a valid flat name and Git recognizes it as a bare repository.

This permits importing and restoring repositories by copying bare repositories into place while Yogit is stopped. Invalid directories should be ignored and logged, not exposed as repositories.

Yogit does not offer repository deletion or renaming. Those operations are performed manually by an operator while the service is stopped.

## Public web interface

The web interface is server-rendered with `templ` and works without client-side JavaScript. Its visual direction follows stagit: compact typography, simple tables, durable links, minimal decoration, and a small stylesheet.

Planned public pages include:

```text
/                              repository list
/:repo                         repository summary and README
/:repo/log                     commit history
/:repo/commit/:oid             commit details and patch
/:repo/tree                    tree at the default ref
/:repo/tree/*path              tree path at a selected ref
/:repo/blob/*path              file at a selected ref
/:repo/refs                    branches and tags
/:repo/tag/:tag                annotated tag details
```

The final route encoding may use query parameters for refs so branch names containing `/` cannot be confused with file paths.

Pages should expose:

- Repository name and description.
- SSH clone command.
- Default branch and latest commit.
- Paginated commit history.
- Commit object ID, author, committer, timestamps, parents, and message.
- Commit changes and patch, subject to configured limits.
- Trees and file contents.
- Branches and tags.
- Annotated tag metadata.
- A rendered README on the repository summary page when present.

The default branch comes from the bare repository's symbolic `HEAD`. Files are shown from that branch by default, while commits and refs across all branches and tags remain navigable.

## Rendering and safety limits

- Goldmark renders README and other Markdown content.
- Raw HTML in Markdown is disabled.
- Generated links and URL schemes are sanitized.
- Chroma highlights source files and fenced Markdown code.
- Unknown text formats receive a plain-text view.
- Binary files receive metadata or a download response rather than inline rendering.
- File content, patch output, and Git command output have configurable size limits.
- Expensive Git operations have timeouts and concurrency limits.
- User-controlled content is escaped by default in templates.

Repository data must be read with Git plumbing commands rather than by making assumptions about object storage internals.

## Git integration

### Server-side Git programs

Yogit delegates the Git wire protocol to Git's standard server-side programs. Their names describe data flow from the server's perspective:

| Client operation                     | Server program     | Data direction                           |
| ------------------------------------ | ------------------ | ---------------------------------------- |
| `git clone`, `git fetch`, `git pull` | `git-upload-pack`  | Server uploads objects to the client.    |
| `git push`                           | `git-receive-pack` | Server receives objects from the client. |

When a client clones or fetches over SSH, it requests a command equivalent to:

```text
git-upload-pack 'project.git'
```

Yogit authenticates the SSH key, requires the `git` username, parses and validates the command and flat repository name, resolves the absolute repository path, and starts `git upload-pack` directly. It connects the SSH channel to the child process as follows:

```text
SSH input  -> git-upload-pack stdin
SSH output <- git-upload-pack stdout
SSH errors <- git-upload-pack stderr
```

`git-upload-pack` then:

1. Advertises repository refs and protocol capabilities.
2. Receives the objects the client has and the refs or objects it wants.
3. Computes the missing commits, trees, and blobs.
4. Produces a compressed pack containing those objects.
5. Streams the pack to the client.

A push similarly requests:

```text
git-receive-pack 'project.git'
```

After Yogit authenticates and validates the request, it connects the SSH channel to `git receive-pack`. Git then:

1. Advertises the current refs and capabilities.
2. Receives the proposed ref updates.
3. Receives the required objects as a pack.
4. Validates and indexes the objects.
5. Applies valid branch and tag updates with Git's normal locking semantics.
6. Reports success or failure to the client.

For push-to-create, Yogit initializes and locks the missing bare repository before starting `git-receive-pack`. After the process exits, Yogit retains the repository if the push created a ref. It removes a repository created by that request only when the push failed and the repository still has no refs.

Yogit does not parse pack files or implement protocol negotiation, object traversal, deltas, ref transactions, or Git object validation. Those responsibilities remain with Git.

### Command parsing boundary

The command requested by an SSH client is untrusted input. Yogit must never pass it to a shell. It accepts only the exact logical forms:

```text
git-upload-pack '<flat-repository-name>'
git-receive-pack '<flat-repository-name>'
```

After parsing and validation, Yogit constructs the executable and arguments itself. Conceptually:

```go
exec.CommandContext(
    ctx,
    gitPath,
    "upload-pack",
    "/var/lib/yogit/repositories/project.git",
)
```

The client controls neither the executable nor the final filesystem path. Extra arguments, absolute or nested paths, option-like names, traversal components, malformed quoting, shell operators, and unsupported services are rejected.

### Responsibility boundary

Yogit is responsible for:

- SSH listening and public-key authentication.
- Enforcing the fixed `git` username.
- Allowlisting and parsing service commands.
- Validating and resolving repository names.
- Safely creating repositories on first push.
- Starting, supervising, and cancelling Git processes.
- Connecting SSH streams to Git processes.
- Logging outcomes without leaking credentials or protocol data.

Git is responsible for:

- Wire-protocol negotiation and capability advertisement.
- Ref advertisement.
- Reachability and missing-object calculation.
- Pack generation, decoding, and validation.
- Object quarantine and indexing where supported by Git.
- Ref locking, validation, and updates.
- Compatibility with standard Git clients.

This boundary keeps Yogit small while retaining the behavior and compatibility of the reference Git implementation. It results in one Yogit application binary, with the `git` executable as an explicit runtime dependency supplied by the Nix package closure.

### Repository browsing commands

Yogit will initially use commands such as:

- `git upload-pack`
- `git receive-pack`
- `git for-each-ref`
- `git log`
- `git show`
- `git diff-tree`
- `git ls-tree`
- `git cat-file`
- `git rev-parse`

Every invocation must use direct argument execution, explicit repository paths, a controlled environment, bounded output where applicable, and contextual cancellation. No request-derived value may be interpreted by a shell.

## CLI flags

The initial `serve` configuration is expected to include:

```text
--data-dir
--http-listen
--ssh-listen
--external-url
--ssh-host
--ssh-port
--ssh-host-key
--git-path
--trusted-proxy
--log-level
--max-file-size
--max-diff-size
```

Example:

```sh
yogit serve \
  --data-dir /var/lib/yogit \
  --http-listen 127.0.0.1:8080 \
  --ssh-listen 0.0.0.0:2222 \
  --external-url https://git.example.com \
  --ssh-host git.example.com \
  --ssh-port 2222
```

Flag defaults must be safe for local development. Production configuration should fail early when required public-host or SSH host-key settings are missing or inconsistent.

## Nix flake

The flake will provide:

- `packages.<system>.default`
- `apps.<system>.default`
- `devShells.<system>.default`
- `checks.<system>`
- `nixosModules.default`

The package closure includes Git so Yogit has a known Git executable at runtime. The development shell includes Go, Git, `templ`, formatting tools, and test tools.

## NixOS module

An expected configuration shape is:

```nix
services.yogit = {
  enable = true;
  package = inputs.yogit.packages.${pkgs.system}.default;

  domain = "git.example.com";
  dataDir = "/var/lib/yogit";

  httpListen = "127.0.0.1:8080";
  sshListen = "0.0.0.0:2222";
  sshPort = 2222;

  nginx.enable = true;
  acme.enable = true;
};
```

The module will:

- Create a dedicated system user and group.
- Create the state and repository directories.
- Generate or persist an SSH host key.
- Run Yogit as a hardened systemd service.
- Open the configured SSH port when requested.
- Optionally configure nginx and ACME.
- Permit operation behind an independently configured reverse proxy.

Secrets should be referenced through files or systemd credentials rather than placed directly in the Nix store.

## Explicit non-goals

The first version does not include:

- Additional users or organizations.
- Repository permission management.
- Pull requests or code review.
- Issues, comments, stars, follows, or activity feeds.
- Repository deletion or renaming.
- Repository creation through HTTP.
- Git smart HTTP or native `git://` transport.
- Git LFS.
- Fork management.
- Releases as a separate abstraction.
- Global code search or indexing.
- Branch protection policies.
- Managed server-side hooks.
- A JavaScript application framework.
- Non-Linux support.

## Test strategy

Unit and integration tests should cover:

- Repository-name normalization and traversal rejection.
- SSH command parsing and quoting.
- Authorized, unknown, and revoked SSH keys.
- Rejection of shells, PTYs, forwarding, and unsupported commands.
- Clone and fetch through a real Git client.
- Push to an existing repository.
- Push-to-create.
- Cleanup after a failed initial push.
- Concurrent creation attempts.
- Discovery of manually copied bare repositories.
- Commit, tree, blob, ref, and annotated-tag rendering.
- Markdown sanitization and HTML escaping.
- Binary and oversized file handling.
- Adding, listing, deduplicating, and removing SSH keys through the CLI.
- Setting and clearing repository descriptions through the CLI.
- SQLite migrations.
- Graceful shutdown of both listeners.
- Nix flake evaluation, package builds, and NixOS module tests.

Integration tests should use real temporary Git repositories and real SSH and HTTP listeners rather than mocking the Git protocol.

## Documentation

The repository documentation will cover:

- Building and running Yogit.
- NixOS deployment.
- Reverse proxy and HTTPS configuration.
- Adding, listing, and removing SSH public keys through the CLI.
- Push-to-create and clone workflows.
- Editing repository descriptions through the CLI.
- Importing an existing bare repository.
- Backing up SQLite, bare repositories, and the SSH host key.
- Manually renaming or removing a repository while Yogit is stopped.
- Security boundaries and unsupported features.

## Implementation sequence

1. Create the Go module, package skeleton, CLI parsing, logging, and graceful process lifecycle.
2. Add the data-directory layout, SQLite connection, migrations, and repository-name validation.
3. Implement bare-repository discovery and the Git command execution layer.
4. Implement the embedded SSH server, authorized-key lookup, strict command parsing, clone, and fetch.
5. Implement push and concurrency-safe push-to-create with failed-push cleanup.
6. Add public repository, ref, log, commit, tree, and blob view models.
7. Build the minimal `templ` pages and stylesheet.
8. Add Goldmark README rendering, Chroma highlighting, sanitization, and display limits.
9. Implement CLI management of SSH keys and repository descriptions.
10. Add the Nix flake, reproducible package, development shell, and checks.
11. Add the NixOS module, systemd hardening, SSH host-key handling, and optional nginx/ACME integration.
12. Complete end-to-end tests, operator documentation, and a security review of all request-to-Git boundaries.

## Definition of done

The first version is complete when a new Linux deployment can:

1. Build or install Yogit through the flake.
2. Enable it through the NixOS module or run it manually.
3. Add an SSH public key through the local CLI.
4. Push to a missing flat repository name and create it automatically.
5. Clone, fetch, and push that repository over embedded SSH.
6. Browse its README, commits, patch, files, branches, and tags publicly over HTTP without login.
7. Discover an existing bare repository copied into the repository directory.
8. Back up and restore all persistent state using the documented procedure.
