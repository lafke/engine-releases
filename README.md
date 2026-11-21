# Lafke engine releases

Prebuilt `lafke-engine` executables for the [Lafke](https://github.com/lafke/lafke)
CLI. The engine does the source-code analysis behind `lafke sast`, `security` and
related commands.

The engine source is not public. Every executable published here is built by this
repository's workflows and carries a GitHub build provenance attestation,
so you can check where it came from before you run it.

## Install

You normally do not download anything from this page. The Lafke installer and the CLI
do it for you:

```sh
lafke engine install      # newest engine that works with your lafke
lafke engine update       # install a newer one and remove the old ones
lafke engine status       # show which engine lafke uses
```

`lafke engine install` picks the newest release whose protocol your `lafke`
speaks, checks its SHA-256 and its attestation, and keeps it in your user cache. The
verification needs the [GitHub CLI](https://cli.github.com) (`gh`); pass
`--skip-attestation` to install without it. Set `LAFKE_ENGINE_VERSION` to pin a
version, or `LAFKE_ENGINE` to use an executable at another path.

## What a release contains

| File | Description |
| --- | --- |
| `lafke-engine_<os>_<arch>.tar.gz` / `.zip` | the executable for Linux, macOS (`tar.gz`) or Windows (`zip`), on amd64 and arm64 |
| `engine-manifest.json` | engine version, protocol version and the SHA-256 of every archive |
| `checksums.txt` | SHA-256 of every file in the release |
| `lafke-engine.spdx.json` | SPDX software bill of materials of the engine |

Release tags are engine versions (`v1.2.3`). They are independent of the CLI's versions;
the protocol version in the manifest decides which CLI can use which engine.

## Verify a download

Download an archive from the [releases page](https://github.com/lafke/engine-releases/releases),
then:

```sh
# 1. the checksum matches the one in the release
grep ' lafke-engine_linux_amd64.tar.gz$' checksums.txt | sha256sum --check

# 2. the archive was built by this repository's workflow
gh attestation verify lafke-engine_linux_amd64.tar.gz --repo lafke/engine-releases

# 3. the executable inside carries its own attestation
tar -xzf lafke-engine_linux_amd64.tar.gz
gh attestation verify lafke-engine --repo lafke/engine-releases
```

On macOS use `shasum -a 256 --check` in place of `sha256sum --check`.

## Reporting problems

Report a vulnerability as described in the
[Lafke security policy](https://github.com/lafke/lafke/blob/main/SECURITY.md).
For bugs or questions about analysis results, open an issue in the
[lafke/lafke](https://github.com/lafke/lafke/issues) repository.
