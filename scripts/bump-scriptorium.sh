#!/usr/bin/env bash
# Point Casks/scriptorium.rb at the latest GitHub release.
# Usage: bash scripts/bump-scriptorium.sh [--push]
set -euo pipefail

repo="fabea87/scriptorium"
cd "$(dirname "$0")/.."

tag=$(gh release view --repo "$repo" --json tagName --jq .tagName)
version=${tag#v}
url="https://github.com/$repo/releases/download/$tag/Scriptorium_${version}_aarch64.dmg"

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
echo "fetching $url"
curl -fsSL "$url" -o "$tmp/Scriptorium.dmg"
sha=$(shasum -a 256 "$tmp/Scriptorium.dmg" | awk '{print $1}')

sed -i '' -e "s/^  version \".*\"/  version \"$version\"/" \
          -e "s/^  sha256 \".*\"/  sha256 \"$sha\"/" Casks/scriptorium.rb

if git diff --quiet Casks/scriptorium.rb; then
  echo "already at $version"
  exit 0
fi
echo "scriptorium -> $version ($sha)"
git add Casks/scriptorium.rb
git commit -qm "scriptorium $version"
if [[ "${1:-}" == "--push" ]]; then git push; fi
