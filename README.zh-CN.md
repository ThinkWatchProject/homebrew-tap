# ThinkWatch tap

[ThinkWatch Lite](https://github.com/ThinkWatchProject/ThinkWatch-Lite) 的
Homebrew cask。ThinkWatch Lite 是本地 AI API 网关的菜单栏应用。

**[English](README.md) | [中文](README.zh-CN.md)**

```bash
brew install --cask thinkwatchproject/tap/thinkwatch-lite
```

不用先 `brew tap` —— 写全名的时候顺手就把这个仓库接上了。

## 装的是什么

一样东西：`/Applications` 里的 `ThinkWatch Lite.app`。网关的二进制在包
里面，没有第二个包要装，也没有守护进程要配。

Apple Silicon，macOS 12 以上。没有通用二进制，所以在 Intel 机器上这个
cask 会直接拒绝安装 —— 而不是给你一个下得下来、打不开的应用。

## 安装为什么要去掉一个隔离属性

这个应用是临时签名的，没有经过 Apple 注册开发者签名 —— 那是一个按年付费
的账号，目前没人承担。

macOS 会把从网上下载的东西标记为隔离，并拒绝打开一个无法归属到注册开发者
的应用。macOS 15 之后，按住 Control 点开的那条路也没有了；剩下的是「系统
设置 › 隐私与安全性 › 仍要打开」，每装一次点一次，或者去掉这个属性。cask
的 `postflight` 做的就是后者：

```bash
xattr -dr com.apple.quarantine "/Applications/ThinkWatch Lite.app"
```

除了解压，这个 tap 做的全部事情就是这一条。不想把这一步交出去的话，可以
不用 cask：从
[release 页面](https://github.com/ThinkWatchProject/ThinkWatch-Lite/releases)
下载，核对旁边那份 sha256，然后自己执行上面这条命令。

cask 里记的校验和不是从那份文件里抄的，而是自动更新那一步真的下载下来之后
自己算的；两者对不上就不更新 —— 一份和它描述的文件放在一起的校验和，单独
证明不了任何事。

## 更新

```bash
brew update && brew upgrade --cask thinkwatch-lite
```

这样装的实例不会自己更新。Homebrew 把应用移进 `/Applications` 并记下它放
进去的是哪一版；应用如果自己把包换掉，那条记录就指向一个已经不在磁盘上的
版本，下一次 `brew upgrade` 会把旧的那版再盖回去。所以有新版本的时候，应用
只负责告诉你，升级交给 Homebrew。

## 卸载

```bash
brew uninstall --cask thinkwatch-lite
```

这会删掉应用，但不动 `~/.thinkwatch` —— 配置、流量库和上游的密钥是你的，
不是这个应用的。连这些一起清掉：

```bash
brew uninstall --zap --cask thinkwatch-lite
```

`--zap` 是移到废纸篓，不是直接删除。
