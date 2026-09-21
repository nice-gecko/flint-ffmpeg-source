# Rush Tools に同梱しているソフトウェア

## FFmpeg（ffmpeg / ffprobe）

- 版: 8.1.2（無改変のソースから静的ビルド。外部ライブラリなし）
- ライセンス: GNU Lesser General Public License v2.1 以降（全文は同梱の LICENSE.ffmpeg）
- ソース: https://ffmpeg.org/releases/ffmpeg-8.1.2.tar.xz
  （SHA-256: 464beb5e7bf0c311e68b45ae2f04e9cc2af88851abb4082231742a74d97b524c。同じ tarball をこの .app の配布元にも置く）
- 対象: macOS x86_64、macOS 10.15 以上
- configure（ソースを展開したディレクトリで実行した全文）:

```
./configure --disable-gpl --disable-nonfree --disable-version3 --disable-autodetect --enable-zlib --enable-static --disable-shared --pkg-config-flags=--static --disable-doc --disable-network --disable-debug --disable-ffplay --disable-avdevice --disable-everything --enable-protocol=file,pipe --enable-demuxer=mov,mxf,wav,matroska '--enable-decoder=prores,h264,hevc,dnxhd,mjpeg,aac,pcm_*' --enable-parser=h264,hevc,aac --enable-filter=scale,format,aformat,fps,aresample,null,anull,trim,atrim,setpts,asetpts --enable-encoder=pcm_f32le,rawvideo,png --enable-muxer=rawvideo,image2,image2pipe,pcm_f32le,wav --extra-cflags=-mmacosx-version-min=10.15 --extra-ldflags=-mmacosx-version-min=10.15 --extra-version=ppro-rushes-lgpl
```

- 同梱先: Rush Tools.app/Contents/Frameworks/bin/ffmpeg, ffprobe。Rush Tools は別プロセスとして呼び出すだけで、リンクしていない。
  差し替えたい場合は、同じ場所に別の ffmpeg / ffprobe を置けば使われる。

## Python と Python パッケージ

| 名前 | 版 | ライセンス |
|---|---|---|
| Python | 3.12.13 | PSF License |
| Tcl/Tk | 9.0.3 | Tcl/Tk License（BSD 系） |
| openpyxl | 3.1.5 | MIT |
| et-xmlfile | 2.0.0 | MIT |
| numpy | 2.5.3 | BSD-3-Clause（同梱の OpenBLAS 等は numpy の LICENSE を参照） |
| pillow | 12.3.0 | MIT-CMU |

PyInstaller 6.22.3 でまとめている（ブートローダーは GPL の例外条項により配布物のライセンスに影響しない）。
