# ThinkWatch Homebrew tap

**[English](README.md) | [中文](README.zh-CN.md)**

The Homebrew cask for [ThinkWatch Lite](https://thinkwat.ch/lite/), a desktop
app that runs a local gateway for Claude Code, Codex and other AI clients. It
requires macOS 12 or later on Apple silicon; the cask refuses to install on an
Intel Mac.

```bash
brew install --cask thinkwatchproject/tap/thinkwatch-lite
```

Installing by the full name taps this repository; no separate `brew tap` is
needed. Windows and Linux builds and the macOS disk image are on the
[download page](https://thinkwat.ch/lite/#install).

## Unsigned app and the quarantine attribute

The app is signed with the project's self-signed certificate, not an Apple
Developer ID, so Gatekeeper does not accept it. The certificate keeps the
signer the same across releases, so `brew upgrade` does not report a changed
signer. The cask's `postflight` step removes the quarantine attribute, which
is the only action it takes besides copying the app:

```bash
xattr -dr com.apple.quarantine "/Applications/ThinkWatch Lite.app"
```

To do this step by hand instead, download `ThinkWatch-Lite-<version>-arm64.dmg`
from the [releases page](https://github.com/ThinkWatchProject/ThinkWatch-Lite/releases/latest),
check it against the published SHA-256 checksum and run the command above.
Otherwise, System Settings › Privacy & Security › Open Anyway is required once
per installation; since macOS 15, Control-click no longer bypasses the check.

## Updates

```bash
brew update && brew upgrade --cask thinkwatch-lite
```

An app installed with Homebrew does not update itself, so that Homebrew's
record of the installed version stays correct. The app announces a new version
once this cask carries it, and offers the command above to copy. Each release
updates the cask when it is published, with an hourly job here as a fallback.
`brew update` is included because `brew upgrade` refreshes taps at most once a
day.

## Uninstallation

First use Settings › Full uninstall in the app: it restores every connected
client and turns off launch at login. Removing the app alone leaves clients
pointed at a port where nothing is listening.

```bash
brew uninstall --cask thinkwatch-lite
```

This keeps `~/.thinkwatch`, which holds the configuration with upstream keys,
the request history and the keys of remote connections. To move that directory
and the app's other files to the Trash as well:

```bash
brew uninstall --zap --cask thinkwatch-lite
```
