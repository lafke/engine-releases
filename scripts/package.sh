#!/bin/sh
# Builds the engine for one platform and packages it in one archive.
#
# usage: package.sh <goos> <goarch> <version>
# env:   ENGINE_DIR (default ./engine), OUT_DIR (default ./dist),
#        RULEPACK_PUBLIC_KEY and RULEPACK_DECRYPTION_KEY (required by the engine's
#        scripts/build-release.sh, which pins them in the executable)
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

export CGO_ENABLED=0 GOOS="$goos" GOARCH="$goarch"
(cd "$ENGINE_DIR" && VERSION="$version" OUTPUT="$stage/lafke-engine${ext}" bash scripts/build-release.sh)

cp "$ENGINE_DIR/LICENSE" "$stage/LICENSE"

name="lafke-engine_${goos}_${goarch}"
if [ "$goos" = windows ]; then
  (cd "$stage" && zip -q "$OUT_DIR/${name}.zip" lafke-engine.exe LICENSE)
  echo "$OUT_DIR/${name}.zip"
else
  tar -C "$stage" -czf "$OUT_DIR/${name}.tar.gz" lafke-engine LICENSE
  echo "$OUT_DIR/${name}.tar.gz"
fi
