# AGENTS.md

Instructions for AI coding agents working in this repository. If a user's request
disagrees with this file, the user wins.

## Project

Public release repository for the Lafke analysis engine. The engine source is private
(`lafke/engine`), so this repository checks it out, builds every platform, attests
provenance and publishes the binaries. It carries no engine code. The `lafke` CLI
(https://github.com/lafke/lafke) installs from these releases with `lafke engine install`.

## Layout

- `.github/workflows/build.yml`: builds and smoke-tests every platform on pushes and pull
  requests, with version `dev`. Nothing is published.
- `.github/workflows/release.yml`: builds from a `lafke/engine` tag, creates a draft release
  with every asset, attests the binaries and publishes only after all attestations succeed.
  Triggered by `repository_dispatch` (`engine-release`) from `lafke/engine`, or by
  `workflow_dispatch` with a tag.
- `scripts/package.sh <goos> <goarch> <version>`: builds one platform from the engine's `rust/` crate with its `scripts/build-release.sh` and writes the archive. The matrix in both workflows names the native runner and Rust target of each platform.
- `scripts/manifest.sh`: writes `engine-manifest.json` (version, protocol, checksums).
- `README.md`: what a release contains and how to verify a download.

## Rules

- This repository is public. Never commit or print a secret, token or key. The workflows use
  `ENGINE_ACCESS_TOKEN`, `RULEPACK_PUBLIC_KEY` and `RULEPACK_DECRYPTION_KEY`; keep their
  values out of logs, and do not add `set -x` or `echo` of them.
- Pin every third-party action by commit SHA with a version comment, as the workflows do.
- Keep `permissions` minimal: `contents: read` by default, and `id-token: write` and
  `attestations: write` only on the attest job.
- The release must stay draft until every attestation has succeeded, so `/releases/latest`
  never points at an unattested release. Do not reorder that.
- Release tags are engine versions (`vX.Y.Z`) and must point at the current `main` commit of
  `lafke/engine`. They are independent of the CLI's tags. Never move or reuse a published tag.
- Scripts are POSIX `sh` unless they already use bash.
- Code, comments, commit messages, and everything published to GitHub are in English.
- Every commit message follows Conventional Commits, is all lowercase, and is 35 to 55
  characters long, counting the whole subject line (e.g. `ci(release): attest the sbom before publishing`).
  Check the length before committing.
