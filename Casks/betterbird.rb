cask "betterbird" do
  version "153.7.0,13"
  sha256 arm:   "b5eacb2ba1c11b6e1b36c73898611246b0a7f38431a73dfbb4762116393a98d9",
         intel: "bf7f0dc3658acd28376fec734017846b630887d6ff1ee3d0e2aa07b5e8b25268"

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
