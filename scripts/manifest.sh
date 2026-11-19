#!/bin/sh
# Writes engine-manifest.json for the archives in a directory.
#
# usage: manifest.sh <dist-dir> <version> <protocol>
#
# The manifest lists the engine version, the protocol it speaks and the sha256 of every
# archive, so the CLI can pick a compatible engine without downloading it first.
set -eu

dist=${1:?dist dir}
version=${2:?version}
protocol=${3:?protocol}

cd "$dist"
{
  printf '{\n  "version": "%s",\n  "protocol": %s,\n  "archives": {\n' "$version" "$protocol"
  first=1
  for f in lafke-engine_*.tar.gz lafke-engine_*.zip; do
    [ -e "$f" ] || continue
    sum=$(sha256sum "$f" | awk '{print $1}')
    if [ "$first" = 1 ]; then first=0; else printf ',\n'; fi
    printf '    "%s": "%s"' "$f" "$sum"
  done
  printf '\n  }\n}\n'
} > engine-manifest.json
cat engine-manifest.json
