#!/bin/sh
# Point the Librium manifest at a new release.
# Usage: ./update.sh 0.5.5
set -eu

version="${1:-}"
if [ -z "$version" ]; then
  echo "usage: $0 <version>   (for example: $0 0.5.5)" >&2
  exit 1
fi

root=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
manifest="$root/bucket/librium.json"
[ -f "$manifest" ] || { echo "manifest not found: $manifest" >&2; exit 1; }

# The release asset is uploaded as "Librium <version>.exe" and GitHub turns the space
# into a dot; "#/Librium.exe" tells Scoop to store it under a stable name.
asset="https://github.com/Daloshka/Librium/releases/download/v${version}/Librium.${version}.exe"
url="${asset}#/Librium.exe"
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT HUP INT TERM

echo "downloading $asset"
curl -fL --retry 3 --progress-bar -o "$tmp/librium.exe" "$asset"
sha=$(shasum -a 256 "$tmp/librium.exe" | awk '{print $1}')
echo "sha256 $sha"

sed -e "s|^\(    \"version\": \)\".*\",\$|\1\"${version}\",|" \
    -e "s|^\(    \"url\": \)\".*\",\$|\1\"${url}\",|" \
    -e "s|^\(    \"hash\": \)\".*\",\$|\1\"${sha}\",|" \
    "$manifest" >"$tmp/librium.json"
mv "$tmp/librium.json" "$manifest"

grep -q "\"version\": \"${version}\"," "$manifest" || { echo "version not updated in $manifest" >&2; exit 1; }
grep -q "\"hash\": \"${sha}\"," "$manifest" || { echo "hash not updated in $manifest" >&2; exit 1; }
grep -q "\"url\": \"${url}\"," "$manifest" || { echo "url not updated in $manifest" >&2; exit 1; }
python3 -m json.tool "$manifest" >/dev/null || { echo "manifest is not valid JSON" >&2; exit 1; }

echo
echo "$manifest updated. Next:"
echo "  git -C \"$root\" add bucket/librium.json"
echo "  git -C \"$root\" commit -m 'librium $version'"
echo "  git -C \"$root\" push"
