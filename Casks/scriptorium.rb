cask "scriptorium" do
  version "0.2.0"
  sha256 "24ed545ca0fa7276cd67b4934e145e100073bec45b9bade18fe4eab23c868ad7"

  url "https://github.com/fabea87/scriptorium/releases/download/v#{version}/Scriptorium_#{version}_aarch64.dmg",
      verified: "github.com/fabea87/scriptorium/"
  name "Scriptorium"
  desc "Local-first academic writing desk with Zotero citations and tracked revisions"
  homepage "https://github.com/fabea87/scriptorium"

  depends_on arch: :arm64
  depends_on macos: ">= :big_sur"

  app "Scriptorium.app"

  zap trash: [
    "~/.config/scriptorium",
    "~/.cache/scriptorium",
    "~/.local/share/scriptorium",
  ]

  caveats <<~EOS
    Scriptorium is not notarised yet. If macOS refuses to open it:
      xattr -dr com.apple.quarantine /Applications/Scriptorium.app

    Exporting to docx/PDF also needs pandoc and academic-md (mdac):
      brew install pandoc
    Citations need Zotero 7 running with Better BibTeX.
  EOS
end
