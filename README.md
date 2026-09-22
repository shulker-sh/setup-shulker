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

## Cache

The action sets `SHULKER_CACHE` to a folder in the runner's temp directory and caches it with
[`actions/cache`](https://github.com/actions/cache). The key is the runner OS plus a hash of `shulker.lock` at the
repository root: while the lock is unchanged, an export downloads nothing, and after a change it starts from the
previous cache and downloads only what's new.

## Verification

The action runs shulker's own installers, which check each download against the release's SHA256 checksums and
verify its build provenance with `gh`.

## License

[MIT](LICENSE)
