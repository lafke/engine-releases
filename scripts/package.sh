#!/bin/sh
# Builds the engine for one platform and packages it in one archive.
#
# usage: package.sh <goos> <goarch> <version>
# env:   ENGINE_DIR (default ./engine), OUT_DIR (default ./dist),
#        RULEPACK_PUBLIC_KEY and RULEPACK_DECRYPTION_KEY (required by the engine's
#        scripts/build-release.sh, which pins them in the executable). The engine is built
#        from its Cargo crate; GOOS and GOARCH only select the target.
set -eu

goos=${1:?goos}
goarch=${2:?goarch}
version=${3:?version}

ENGINE_DIR=$(cd "${ENGINE_DIR:-engine}" && pwd)
mkdir -p "${OUT_DIR:-dist}"
OUT_DIR=$(cd "${OUT_DIR:-dist}" && pwd)

ext=""
if [ "$goos" = windows ]; then ext=".exe"; fi

stage=$(mktemp -d)
trap 'rm -rf "$stage"' EXIT

export GOOS="$goos" GOARCH="$goarch"
(cd "$ENGINE_DIR" && VERSION="$version" OUTPUT="$stage/lafke-engine${ext}" bash scripts/build-release.sh)

cp "$ENGINE_DIR/LICENSE" "$stage/LICENSE"

name="lafke-engine_${goos}_${goarch}"
if [ "$goos" = windows ]; then
  # The Windows runner has 7-Zip, not zip.
  if command -v zip >/dev/null 2>&1; then
    (cd "$stage" && zip -q "$OUT_DIR/${name}.zip" lafke-engine.exe LICENSE)
  else
    (cd "$stage" && 7z a -tzip -bso0 "$(cygpath -w "$OUT_DIR/${name}.zip")" lafke-engine.exe LICENSE)
  fi
  echo "$OUT_DIR/${name}.zip"
else
  tar -C "$stage" -czf "$OUT_DIR/${name}.tar.gz" lafke-engine LICENSE
  echo "$OUT_DIR/${name}.tar.gz"
fi
