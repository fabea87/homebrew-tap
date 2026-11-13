#!/usr/bin/env bash
# Regenerate Casks/betterbird.rb from the current Betterbird release.
# Betterbird ships no auto-updater and publishes every build behind the same
# getloc.php redirect, so the cask has to be re-pinned here on a schedule
# (.github/workflows/bump.yml). Exit 0 with or without changes; prints the
# version that was written.
set -euo pipefail

CASK="${CASK:-Casks/betterbird.rb}"
BASE="https://www.betterbird.eu/downloads"
LOCALE="${LOCALE:-en-US}"
CHANNEL="${CHANNEL:-release}"   # release | previous

resolve() {
  local os="$1" url
  url=$(curl -fsSL --max-time 60 "$BASE/getloc.php?os=$os&lang=$LOCALE&version=$CHANNEL") || return 1
  [ -n "$url" ] || return 1
  printf '%s\n' "$url"
}

arm_url=$(resolve mac-arm64)
intel_url=$(resolve mac)

# betterbird-153.7.0esr-bb13.en-US.mac-arm64.dmg -> "153.7.0 13"
read -r ver bb <<<"$(basename "$arm_url" | sed -E 's/^betterbird-([0-9.]+)esr-bb([0-9]+)\.(.+)$/\1 \2/')"
[ -n "${ver:-}" ] && [ -n "${bb:-}" ] || { echo "error: cannot parse version from $arm_url" >&2; exit 1; }
esr_major="${ver%%.*}"

sums=$(curl -fsSL --max-time 60 "$BASE/sha256-${esr_major}.txt")
sum_for() {
  printf '%s\n' "$sums" | awk -v f="$1" '{ n = $2; sub(/^\*/, "", n); if (n == f) { print $1; exit } }'
}
arm_sha=$(sum_for "$(basename "$arm_url")")
intel_sha=$(sum_for "$(basename "$intel_url")")
[ -n "$arm_sha" ] && [ -n "$intel_sha" ] || {
  echo "error: no published checksum for $ver,$bb" >&2
  exit 1
}

cat >"$CASK" <<EOF
cask "betterbird" do
  version "${ver},${bb}"
  sha256 arm:   "${arm_sha}",
         intel: "${intel_sha}"

  on_arm do
    url "https://www.betterbird.eu/downloads/MacDiskImage/betterbird-#{version.csv.first}esr-bb#{version.csv.second}.en-US.mac-arm64.dmg"
  end
  on_intel do
    url "https://www.betterbird.eu/downloads/MacDiskImage/betterbird-#{version.csv.first}esr-bb#{version.csv.second}.en-US.mac.dmg"
  end

  name "Betterbird"
  desc "Thunderbird derivative with additional bug fixes"
  homepage "https://www.betterbird.eu/"

  livecheck do
    url "https://www.betterbird.eu/downloads/getloc.php?os=mac-arm64&lang=en-US&version=release"
    strategy :page_match do |page|
      page[/betterbird[._-](\d+(?:\.\d+)+)esr[._-]bb(\d+)/i]
      "#{Regexp.last_match(1)},#{Regexp.last_match(2)}"
    end
  end

  depends_on :macos

  app "Betterbird.app"

  # Builds are unsigned and not notarised: without this the app is quarantined
  # and macOS reports it as "damaged" on first launch.
  postflight_steps do
    run "/usr/bin/xattr",
        args:           ["-cr", "{{appdir}}/Betterbird.app"],
        writable_paths: ["{{appdir}}/Betterbird.app"]
  end

  zap trash: [
    "~/Library/Application Support/Betterbird",
    "~/Library/Caches/Betterbird",
    "~/Library/Preferences/org.mozilla.betterbird.plist",
    "~/Library/Saved Application State/org.mozilla.betterbird.savedState",
    "~/Library/Thunderbird",
  ]
end
EOF

echo "cask=${ver},${bb}"
