# ThinkWatch tap

The Homebrew cask for [ThinkWatch Lite](https://github.com/ThinkWatchProject/ThinkWatch-Lite),
a menu-bar app for a local AI API gateway.

**[English](README.md) | [中文](README.zh-CN.md)**

```bash
brew install --cask thinkwatchproject/tap/thinkwatch-lite
```

No `brew tap` first — the long name taps this repository on the way past.

## What gets installed

One thing: `ThinkWatch Lite.app` in `/Applications`. The gateway binary is
inside the app bundle, so there is no second package and no daemon to set up.

Apple Silicon, macOS 12 or newer. There is no universal binary, so the cask
refuses to install on an Intel Mac rather than leaving you with an app that
downloads and will not open.

## Why the install removes a quarantine attribute

The app is ad-hoc signed. It is not signed by a registered Apple developer,
because that is a paid, renewed-yearly account and nobody has taken that on.

macOS quarantines anything downloaded from the internet and refuses to open an
app it cannot attribute to a registered developer. Since macOS 15 the
Control-click bypass is gone; what is left is System Settings › Privacy &
Security › Open Anyway, once per install, or removing the attribute. The cask's
`postflight` removes it:

```bash
xattr -dr com.apple.quarantine "/Applications/ThinkWatch Lite.app"
```

That is the whole of what this tap does beyond copying the app out of its disk
image. If you would
rather not delegate it, skip the cask: download the build from the
[releases page](https://github.com/ThinkWatchProject/ThinkWatch-Lite/releases),
check its sha256 against the one published beside it, and run that command
yourself.

The cask's checksum is not copied from that published file. It is the hash of
the bytes the bump job downloaded, and the job fails if the two disagree —
a checksum published next to the file it describes proves nothing on its own.

## Updating

```bash
brew update && brew upgrade --cask thinkwatch-lite
```

An app installed this way does not update itself. Homebrew moves the app into
`/Applications` and records the version it put there; an app that replaced its
own bundle would leave that record pointing at a version that is no longer on
disk, and the next `brew upgrade` would write the old one back over it.

So when a new version exists, the app opens a window with this command and a
button to copy it. It checks this tap rather than the release page to decide:
the window appears only once the cask here carries the new version, which the
bump job picks up within the hour. Before that, the command would have nothing
to install.

`brew update` is part of the command because `brew upgrade` refreshes taps on
its own at most once a day (`HOMEBREW_AUTO_UPDATE_SECS`); without it, a
day-old copy of this tap would answer that the latest version is already
installed.

## Uninstalling

```bash
brew uninstall --cask thinkwatch-lite
```

That removes the app and leaves `~/.thinkwatch` alone — the config, the traffic
database and the upstream keys are yours, not the app's. To remove those too:

```bash
brew uninstall --zap --cask thinkwatch-lite
```

`--zap` moves them to the Trash rather than deleting them.
