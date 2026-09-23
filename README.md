# setup-shulker

Installs [shulker](https://shulker.sh), the modpack CLI, in a GitHub Actions job:

- installs a shulker release on Linux, macOS or Windows runners;
- adds `shulker` to `PATH` for later steps;
- restores and saves shulker's cache, keyed on `shulker.lock`, and prunes files the locks no longer need;
- outputs the lock's Minecraft and loader versions for publishing steps.

## Usage

```yaml
steps:
  - uses: actions/checkout@v7
  - uses: shulker-sh/setup-shulker@v1
    with:
      version: v0.0.1
  - run: shulker export mrpack --version "${GITHUB_REF_NAME#v}"
```

To check a pack on every push and pull request, run [`shulker check`](https://shulker.sh/docs/cli#shulker-check)
after the action. It fails when `shulker.lock` doesn't match `shulker.json`, a locked file can't be downloaded, or a
mod's dependencies aren't met, and writes nothing to the project:

```yaml
on: [push, pull_request]

steps:
  - uses: actions/checkout@v7
  - uses: shulker-sh/setup-shulker@v1
    with:
      version: v0.0.1
  - run: shulker check
```

Checking, exporting, releasing and publishing stay your workflow's own steps. The
[GitHub Actions guide](https://shulker.sh/docs/github-actions) has a complete workflow that checks a pack on every
push, and one that releases it on a version tag.

## Inputs

| Input | Default | Description |
| --- | --- | --- |
| `version` | `latest` | The shulker release to install, such as `v0.0.1`. Pin it so a new shulker release never changes your builds until you bump it. Leave it out to install the latest release. |
| `lock-files` | `shulker.lock` | The lock files the cache is keyed on, one path per line, relative to the workspace. |
| `prune` | `true` | Prune files the listed locks no longer need from a cache restored from older locks. Set it to `false` to keep them. |

## Outputs

| Output | Description |
| --- | --- |
| `shulker-version` | The shulker release that was installed, such as `v0.0.1`. |
| `shulker-path` | The full path to the installed shulker binary. |
| `cache-hit` | `true` when the cache was restored from an exact match for the lock files. |
| `minecraft-version` | The lock's Minecraft version, such as `26.3`. |
| `loader` | The lock's mod loader, such as `fabric`. Empty for a pack with no loader. |
| `loader-version` | The lock's mod loader version, such as `0.19.5`. Empty for a pack with no loader. |

`minecraft-version`, `loader` and `loader-version` are read from the lock, so they hold exact versions even when
`shulker.json` allows a range. They are set only when one lock file is listed; with several, read each pack's with
`shulker get --locked` instead. They feed [mc-publish](https://github.com/Kir-Antipov/mc-publish) directly:

```yaml
  - id: shulker
    uses: shulker-sh/setup-shulker@v1
  # ... export ...
  - uses: Kir-Antipov/mc-publish@v3.3
    with:
      game-versions: ${{ steps.shulker.outputs.minecraft-version }}
      loaders: ${{ steps.shulker.outputs.loader }}
```

## Cache

The action sets `SHULKER_CACHE` to a folder in the runner's temp directory and caches it with
[`actions/cache`](https://github.com/actions/cache). The key is the runner OS plus a hash of every file in
`lock-files`: while the locks are unchanged, an export downloads nothing, and after a change it starts from the
previous cache and downloads only what's new. `shulker check` reads the same cache, so a check with unchanged
locks downloads nothing either.

A pack that isn't at the root of its repository names its lock with `lock-files`. A repository holding several packs
lists each one's lock:

```yaml
  - uses: shulker-sh/setup-shulker@v1
    with:
      lock-files: |
        packs/survival/shulker.lock
        packs/creative/shulker.lock
```

When the cache is restored from older locks, the action runs `shulker cache prune` with a `--lock` for each listed
lock, so the saved cache holds only what the current locks need, not every version they ever held.

## Verification

The action runs shulker's own installers, which check each download against the release's SHA256 checksums and
verify its build provenance with `gh`. A download whose provenance can't be verified fails the step.

## License

[MIT](LICENSE)
