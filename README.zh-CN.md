# ThinkWatch Homebrew tap

**[English](README.md) | [中文](README.zh-CN.md)**

[ThinkWatch Lite](https://thinkwat.ch/zh-CN/lite/) 的 Homebrew cask。ThinkWatch
Lite 是为 Claude Code、Codex 等 AI 客户端在本机运行网关的桌面应用，要求
macOS 12 及以上版本的 Apple silicon 机型；在 Intel 机型上 cask 会拒绝安装。

```bash
brew install --cask thinkwatchproject/tap/thinkwatch-lite
```

按完整名称安装时会自动添加此 tap，无需先执行 `brew tap`。Windows 与 Linux
版本以及 macOS 磁盘映像见[下载页面](https://thinkwat.ch/zh-CN/lite/#install)。

## 未签名的应用与隔离属性

应用使用项目自有的自签名证书签名，而非 Apple Developer ID，因此无法通过
Gatekeeper。该证书使各版本的签名者保持一致，`brew upgrade` 不会提示签名者已
变更。cask 的 `postflight` 步骤会移除隔离属性，这是它在复制应用之外执行的唯一
操作：

```bash
xattr -dr com.apple.quarantine "/Applications/ThinkWatch Lite.app"
```

如需手动完成这一步，可从[发布页面](https://github.com/ThinkWatchProject/ThinkWatch-Lite/releases/latest)
下载 `ThinkWatch-Lite-<版本>-arm64.dmg`，与发布的 SHA-256 校验和核对后执行上面
的命令。否则每次安装后需在「系统设置 › 隐私与安全性」中选择「仍要打开」；自
macOS 15 起，按住 Control 键点按打开已无法绕过这项检查。

## 更新

```bash
brew update && brew upgrade --cask thinkwatch-lite
```

通过 Homebrew 安装的应用不会自行更新，以免 Homebrew 记录的已安装版本失准。此
cask 更新到新版本后，应用会提示新版本并给出上面的命令供复制。每次发布时 cask
随即更新，此仓库每小时运行一次的任务作为补充。命令中包含 `brew update`，是因为
`brew upgrade` 自身最多每天刷新一次 tap。

## 卸载

应先在应用的「设置 › 完全卸载」中执行卸载：该操作会还原所有已接管的客户端，并
取消开机启动。仅删除应用时，已接管的客户端会继续向一个无人监听的端口发送请求。

```bash
brew uninstall --cask thinkwatch-lite
```

此命令保留 `~/.thinkwatch`，其中包括含上游密钥的配置、请求记录以及远程连接的
密钥。如需将该目录和应用的其他文件一并移到废纸篓：

```bash
brew uninstall --zap --cask thinkwatch-lite
```
