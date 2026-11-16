# fabea87/tap

Personal Homebrew tap.

## betterbird

[Betterbird](https://www.betterbird.eu/) ships no auto-updater, publishes every build behind the
same `getloc.php` redirect, and has no official cask — so this tap carries one:

```sh
brew install fabea87/tap/betterbird
brew upgrade --cask betterbird     # or just rely on `brew upgrade`
```

`Casks/betterbird.rb` is generated, never hand-edited. `scripts/bump-betterbird.sh` resolves the
current release, reads the published SHA-256 for both arch builds and rewrites the cask;
`.github/workflows/bump.yml` runs it every 6 hours and commits when the version moves.

```sh
bash scripts/bump-betterbird.sh   # local, same script CI runs
brew livecheck --cask betterbird  # compare cask vs upstream
```

Mac builds are unsigned and un-notarised; the cask's `postflight_steps` strips
`com.apple.quarantine` so macOS does not report the app as damaged.

## Other casks

`brew install fabea87/tap/<cask>`

## scriptorium

[Scriptorium](https://github.com/fabea87/scriptorium) is a local-first academic
writing desk: markdown, Zotero citations, Word-like tracked revisions, and
docx/PDF export — one Rust + Tauri 2 app, no server, no account.

```sh
brew install --cask fabea87/tap/scriptorium
```

Apple silicon, macOS 11+. The app is unsigned, so the first launch needs
right-click → Open (or `xattr -dr com.apple.quarantine /Applications/Scriptorium.app`).
Export needs `pandoc` and `academic-md`; citations need Zotero 7 with Better BibTeX.
