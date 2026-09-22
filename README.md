# setup-shulker

Installs [shulker](https://shulker.sh), the modpack CLI, in a GitHub Actions job:

- installs a shulker release on Linux, macOS or Windows runners;
- adds `shulker` to `PATH` for later steps;
- restores and saves shulker's cache, keyed on `shulker.lock`.

## Usage

```yaml
steps:
  - uses: actions/checkout@v7
  - uses: shulker-sh/setup-shulker@v1
    with:
      version: v0.0.1
  - run: shulker export mrpack --version "${GITHUB_REF_NAME#v}"
```

Exporting, releasing and publishing stay your workflow's own steps. The
[GitHub Actions guide](https://shulker.sh/docs/github-actions) has a complete workflow that releases a pack on a
version tag.

## Inputs

| Input | Default | Description |
| --- | --- | --- |
| `version` | `latest` | The shulker release to install, such as `v0.0.1`. Pin it so a new shulker release never changes your builds until you bump it. |
| `lock-files` | `shulker.lock` | The lock files the cache is keyed on, one path per line, relative to the workspace. |
| `prune` | `true` | Prune files the lock no longer needs from a cache restored from an older lock. Set it to `false` to keep them. |

## Outputs

| Output | Description |
| --- | --- |
| `version` | The shulker release that was installed, such as `v0.0.1`. |
| `cache-hit` | `true` when the cache was restored from an exact match for the lock files. |

## Cache

The action sets `SHULKER_CACHE` to a folder in the runner's temp directory and caches it with
[`actions/cache`](https://github.com/actions/cache). The key is the runner OS plus a hash of every file in
`lock-files`: while the locks are unchanged, an export downloads nothing, and after a change it starts from the
previous cache and downloads only what's new.

A repository with more than one pack lists each pack's lock:

```yaml
  - uses: shulker-sh/setup-shulker@v1
    with:
      lock-files: |
        packs/survival/shulker.lock
        packs/creative/shulker.lock
```

When the cache is restored from an older lock, the action runs `shulker cache prune` in the lock's folder, so the
saved cache holds only what the current lock needs, not every version it ever held. Pruning needs exactly one lock
file: with several, the action skips it and says so.

## Verification

The action runs shulker's own installers, which check each download against the release's SHA256 checksums and
verify its build provenance with `gh`. A download whose provenance can't be verified fails the step.

## License

[MIT](LICENSE)
