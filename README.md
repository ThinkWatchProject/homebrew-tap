# ThinkWatch Homebrew tap

**[English](README.md) | [中文](README.zh-CN.md)**

The Homebrew cask for [ThinkWatch Lite](https://thinkwat.ch/lite/), the
desktop app for a local AI API gateway. The cask installs the macOS build,
which runs on Apple silicon with macOS 12 or later.

```bash
brew install --cask thinkwatchproject/tap/thinkwatch-lite
```

Installing by the full name taps this repository automatically; a separate
`brew tap` is not required.

The Windows and Linux builds, and the disk image for a manual installation on
macOS, are available on the [ThinkWatch Lite page](https://thinkwat.ch/lite/#install)
and on the [releases page](https://github.com/ThinkWatchProject/ThinkWatch-Lite/releases/latest).

## What the cask installs

`ThinkWatch Lite.app` in `/Applications`. The gateway, ThinkWatch Core, is
part of the app bundle, so no second package or background service has to be
installed.

The app is built for Apple silicon only. There is no universal binary, so the
cask requires an arm64 Mac and refuses to install on an Intel Mac instead of
installing an app that cannot run there.

## Code signing and the quarantine attribute

The app is signed with the project's self-signed certificate, not with an
Apple Developer ID. The certificate does not satisfy Gatekeeper. It gives
every release the same signer, so that `brew upgrade` recognizes a new version
as coming from the same source as the installed one and does not report a
changed signer.

macOS quarantines files downloaded from the internet and does not open an app
that is not signed by a registered Apple developer. Since macOS 15, opening
the app with a Control-click no longer bypasses this check; the remaining
options are System Settings › Privacy & Security › Open Anyway, once per
installation, or removing the quarantine attribute. The cask's `postflight`
step removes the attribute:

```bash
xattr -dr com.apple.quarantine "/Applications/ThinkWatch Lite.app"
```

Apart from copying the app out of its disk image, this is the only action the
cask performs. To install without it, download
`ThinkWatch-Lite-<version>-arm64.dmg` from the
[releases page](https://github.com/ThinkWatchProject/ThinkWatch-Lite/releases/latest),
compare it with the SHA-256 checksum published beside it, and run the command
above.

The checksum in the cask is not copied from that published file. It is
computed from the disk image that the update job downloads, and the update
fails if the two checksums differ: a checksum published next to the file it
describes does not verify that file on its own.

## Updates

```bash
brew update && brew upgrade --cask thinkwatch-lite
```

An app installed with Homebrew does not update itself. Homebrew records the
version it placed in `/Applications`; if the app replaced its own bundle, that
record would point to a version that is no longer on disk, and the next
`brew upgrade` would install the older version over the newer one.

The app checks this tap instead of the release page, so a new version is
reported only after the cask here carries it. The app reports it in a
notification, in its menu and in Settings; each of these opens a window with
the command above and a button that copies it. Every ThinkWatch Lite release
updates the cask as soon as it is published; an hourly job in this repository
serves as the fallback.

`brew update` is part of the command because `brew upgrade` refreshes taps on
its own at most once a day (`HOMEBREW_AUTO_UPDATE_SECS`). Without it, an
outdated copy of this tap would report that the latest version is already
installed.

## Uninstallation

Before the cask is uninstalled, Settings › Uninstall in the app restores every
connected client and turns off launch at login. Removing the app alone does
neither, which leaves connected clients pointed at a port where nothing is
listening.

```bash
brew uninstall --cask thinkwatch-lite
```

This quits and removes the app, and keeps `~/.thinkwatch`, which holds the
configuration with the upstream keys, the request history and the keys of
remote connections. To remove that directory and the app's other files as
well:

```bash
brew uninstall --zap --cask thinkwatch-lite
```

`--zap` moves those files to the Trash rather than deleting them.
