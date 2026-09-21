# FLINT TOOLS — FFmpeg corresponding source / 対応ソース

[English](#english) ｜ [日本語](#日本語)

---

## English

This repository holds the **corresponding source** for the `ffmpeg` and `ffprobe`
binaries bundled with FLINT TOOLS products (Rush Tools and the others).

We build FFmpeg from **unmodified upstream source** under the
**GNU Lesser General Public License, version 2.1 or later**, with `--disable-gpl`,
`--disable-nonfree` and `--disable-version3`. No external libraries are linked
(only zlib, which ships with macOS).

The products call `ffmpeg` and `ffprobe` as **separate processes**. They do not link
against FFmpeg.

### What is here

| File | What it is |
|---|---|
| `tools/build_ffmpeg.sh` | The exact script we use. It pins the version, the tarball SHA-256 and the full `configure` line. |
| `THIRD_PARTY.md` | The notice shipped inside the app, with the version and the full `configure` line. |
| `LICENSE` | LGPL v2.1, the same text shipped as `LICENSE.ffmpeg` inside the app. |

The source tarball itself is **not** in git. It is attached to a
[Release](../../releases) tagged `ffmpeg-<version>`, together with its SHA-256.

### Version we ship

- FFmpeg **8.1.2**
- Tarball: https://ffmpeg.org/releases/ffmpeg-8.1.2.tar.xz
- SHA-256: `464beb5e7bf0c311e68b45ae2f04e9cc2af88851abb4082231742a74d97b524c`

### How to build it yourself

```sh
git clone https://github.com/nice-gecko/flint-ffmpeg-source.git
cd flint-ffmpeg-source
tools/build_ffmpeg.sh
```

The script downloads the tarball, checks the SHA-256, runs `configure` with the
pinned options and builds. The result lands in
`build/ffmpeg-lgpl-<version>-<arch>-<hash of the configure line>/`, containing
`ffmpeg`, `ffprobe`, `CONFIGURE.txt` and `COPYING.LGPLv2.1`.

You need Xcode command line tools and `nasm` (`brew install nasm`).

To use your own build, replace the two binaries inside the app at
`<Product>.app/Contents/Frameworks/bin/ffmpeg` and `ffprobe`.

### Contact

https://flinttools.app

---

## 日本語

このリポジトリは、FLINT TOOLS の製品（Rush Tools ほか）に同梱している
`ffmpeg` / `ffprobe` の **対応ソース** を置く場所です。

FFmpeg は **無改変の配布元のソース**から、`--disable-gpl` `--disable-nonfree`
`--disable-version3` を付けて **GNU Lesser General Public License v2.1 以降**で
ビルドしています。外部ライブラリはリンクしていません（zlib だけ。macOS 標準のもの）。

製品は `ffmpeg` / `ffprobe` を**別プロセスとして呼び出す**だけで、リンクしていません。

### 置いてあるもの

| ファイル | 中身 |
|---|---|
| `tools/build_ffmpeg.sh` | 実際に使っているスクリプト。版・tarball の SHA-256・`configure` の全文を固定しています |
| `THIRD_PARTY.md` | アプリに同梱している告知。版と `configure` の全文が入っています |
| `LICENSE` | LGPL v2.1。アプリに `LICENSE.ffmpeg` として同梱しているものと同じ全文です |

ソースの tarball は git に入れていません。`ffmpeg-<版>` のタグを付けた
[Release](../../releases) に、SHA-256 と一緒に添付しています。

### 同梱している版

- FFmpeg **8.1.2**
- tarball: https://ffmpeg.org/releases/ffmpeg-8.1.2.tar.xz
- SHA-256: `464beb5e7bf0c311e68b45ae2f04e9cc2af88851abb4082231742a74d97b524c`

### 自分でビルドする手順

```sh
git clone https://github.com/nice-gecko/flint-ffmpeg-source.git
cd flint-ffmpeg-source
tools/build_ffmpeg.sh
```

tarball を落とし、SHA-256 を確かめ、固定した `configure` でビルドします。
出力は `build/ffmpeg-lgpl-<版>-<arch>-<configure のハッシュ>/` に入り、
`ffmpeg` `ffprobe` `CONFIGURE.txt` `COPYING.LGPLv2.1` が置かれます。

Xcode のコマンドラインツールと `nasm`（`brew install nasm`）が要ります。

自分でビルドしたものに差し替えるときは、アプリの中の
`<製品>.app/Contents/Frameworks/bin/ffmpeg` と `ffprobe` を置き換えてください。

### 問い合わせ先

https://flinttools.app
