# ThinkWatch Homebrew tap

**[English](README.md) | [中文](README.zh-CN.md)**

[ThinkWatch Lite](https://thinkwat.ch/zh-CN/lite/) 的 Homebrew cask。ThinkWatch
Lite 是在本机运行 AI API 网关的桌面应用。此 cask 安装 macOS 版本，适用于
macOS 12 及以上版本的 Apple silicon 机型。

```bash
brew install --cask thinkwatchproject/tap/thinkwatch-lite
```

按完整名称安装时会自动添加此 tap，无需先执行 `brew tap`。

Windows 与 Linux 版本，以及在 macOS 上手动安装所用的磁盘映像，见
[ThinkWatch Lite 页面](https://thinkwat.ch/zh-CN/lite/#install)和
[发布页面](https://github.com/ThinkWatchProject/ThinkWatch-Lite/releases/latest)。

## 安装内容

`/Applications` 中的 `ThinkWatch Lite.app`。网关 ThinkWatch Core 包含在应用包
内，无需另外安装软件包或后台服务。

应用仅为 Apple silicon 构建，没有通用二进制，因此 cask 要求 arm64 机型：在
Intel 机型上直接拒绝安装，而不是装上一个无法运行的应用。

## 代码签名与隔离属性

应用使用项目自有的自签名证书签名，而非 Apple Developer ID。该证书不能使应用
通过 Gatekeeper，其作用是让每个版本的签名者保持一致，使 `brew upgrade` 能确认
新版本与已安装的版本来源相同，不提示签名者已变更。

macOS 会为从互联网下载的文件添加隔离属性，并拒绝打开未经注册开发者签名的
应用。自 macOS 15 起，按住 Control 键点按打开已无法绕过这项检查；其余方式是每次
安装后在「系统设置 › 隐私与安全性」中选择「仍要打开」，或移除隔离属性。cask 的
`postflight` 步骤会移除该属性：

```bash
xattr -dr com.apple.quarantine "/Applications/ThinkWatch Lite.app"
```

除从磁盘映像中复制应用外，这是 cask 执行的唯一操作。如不希望由 cask 执行，可从
[发布页面](https://github.com/ThinkWatchProject/ThinkWatch-Lite/releases/latest)
下载 `ThinkWatch-Lite-<版本>-arm64.dmg`，与旁边发布的 SHA-256 校验和核对后，
执行上面的命令。

cask 中的校验和并非抄自那份文件，而是根据更新任务实际下载的磁盘映像计算得出；
两者不一致时，更新失败。与所描述的文件发布在同一处的校验和，本身不能证明该文件
未被替换。

## 更新

```bash
brew update && brew upgrade --cask thinkwatch-lite
```

通过 Homebrew 安装的应用不会自行更新。Homebrew 会记录它放入 `/Applications`
的版本；如果应用自行替换了应用包，这条记录将指向一个已不在磁盘上的版本，下一次
`brew upgrade` 会用旧版本覆盖新版本。

应用查询的是此 tap，而不是发布页面，因此只有这里的 cask 更新到新版本之后，应用
才会提示新版本。提示出现在系统通知、应用的菜单和设置中，均可打开一个窗口，其中
给出上面的命令和复制按钮。ThinkWatch Lite 每次发布时都会立即更新 cask；此仓库中
每小时运行一次的任务作为补充。

命令中包含 `brew update`，是因为 `brew upgrade` 自身最多每天刷新一次 tap
（`HOMEBREW_AUTO_UPDATE_SECS`）。不先刷新时，过时的 tap 会报告已是最新版本。

## 卸载

卸载 cask 之前，应先在应用的「设置 › 完全卸载」中执行卸载：该操作会还原所有已接管
的客户端，并取消开机启动。仅删除应用不会执行这两项，已接管的客户端会继续向一个
无人监听的端口发送请求。

```bash
brew uninstall --cask thinkwatch-lite
```

此命令退出并删除应用，保留 `~/.thinkwatch`：其中包括含上游密钥的配置、请求记录
以及远程连接的密钥。如需一并删除该目录和应用的其他文件：

```bash
brew uninstall --zap --cask thinkwatch-lite
```

`--zap` 会将这些文件移到废纸篓，而不是直接删除。
