cask "thinkwatch-lite" do
  version "2026.9.10"
  sha256 "22f560c8f3070c166cc07d106bacad8d607ee3a79e0a6ba7b31daf13872fec17"

  url "https://github.com/ThinkWatchProject/ThinkWatch-Lite/releases/download/v#{version}/ThinkWatch-Lite-#{version}-arm64.dmg"
  name "ThinkWatch Lite"
  desc "Menu-bar app for a local AI API gateway"
  homepage "https://github.com/ThinkWatchProject/ThinkWatch-Lite"

  livecheck do
    url :url
    strategy :github_latest
  end

  # Apple Silicon only. There is no universal binary, so on an Intel Mac
  # this has to fail at install time rather than hand someone an app that
  # downloads and will not open.
  depends_on arch: :arm64
  depends_on macos: :monterey

  app "ThinkWatch Lite.app"

  # The build is signed with the project's self-signed certificate, not by a
  # registered Apple developer.
  # macOS quarantines anything downloaded and refuses to open it, and since
  # macOS 15 the Control-click bypass is gone — the only way through is
  # System Settings, per install, or removing the attribute.
  #
  # Removing it here is what makes `brew install` a single step. Anyone who
  # would rather not delegate that can install by hand: the README has the
  # same command, to run themselves.
  postflight_steps do
    run "/usr/bin/xattr",
        args: ["-dr", "com.apple.quarantine", "{{appdir}}/ThinkWatch Lite.app"]
  end

  # Quit before replacing the bundle — `brew upgrade` removes the old app
  # first, and removing a running one leaves a half-replaced bundle.
  #
  # The login item is deliberately not unloaded here. `uninstall` runs on
  # upgrade too, so unloading would silently turn off a setting the user
  # switched on, every time they upgrade. It is removed by `--zap` instead.
  uninstall quit: "app.thinkwatch.lite"

  # `~/.thinkwatch` holds the config, the traffic database and the upstream
  # keys. That is why it is in `zap` and not in `uninstall`: removing the app
  # should not remove what it recorded.
  zap trash: [
    "~/.thinkwatch",
    "~/Library/Caches/app.thinkwatch.lite",
    "~/Library/HTTPStorages/app.thinkwatch.lite",
    "~/Library/LaunchAgents/app.thinkwatch.lite.plist",
    "~/Library/Preferences/app.thinkwatch.lite.plist",
    "~/Library/Saved Application State/app.thinkwatch.lite.savedState",
    "~/Library/WebKit/app.thinkwatch.lite",
  ]
end
