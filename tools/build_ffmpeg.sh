#!/bin/bash
# LGPL 版の ffmpeg / ffprobe をソースから作る（外部ライブラリなし・静的リンク）。手順の説明は docs/BUILD.md。
#   tools/build_ffmpeg.sh    # build/ffmpeg-lgpl-<版>-<arch>-<設定のハッシュ>/ に ffmpeg ffprobe CONFIGURE.txt COPYING.LGPLv2.1
#                            # 出力先は build/ffmpeg-lgpl.path に書く（tools/build_app.sh が読む）
# 出力先が既にあればビルドは飛ばし、LGPL の確認だけする。
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

FFMPEG_VERSION=8.1.2
FFMPEG_SHA256=464beb5e7bf0c311e68b45ae2f04e9cc2af88851abb4082231742a74d97b524c  # 署名（FFmpeg release signing key）を確認した tarball
FFMPEG_URL="https://ffmpeg.org/releases/ffmpeg-$FFMPEG_VERSION.tar.xz"

ARCH="$(uname -m)"  # x86_64 / arm64
case "$ARCH" in
  x86_64) MACOS_MIN=10.15 ;;
  arm64) MACOS_MIN=11.0 ;;
  *) echo "未対応のアーキテクチャ: $ARCH" >&2; exit 1 ;;
esac

# このツールが ffmpeg に頼むことだけを入れる（flint_rush/probe.py edge_motion.py slate.py）:
#   ffprobe の JSON / csv、WAV・カメラ音声の f32le モノ化、fps+scale+gray の rawvideo、PNG 1枚
COMPONENTS=(
  --enable-protocol=file,pipe
  --enable-demuxer=mov,mxf,wav,matroska
  --enable-decoder=prores,h264,hevc,dnxhd,mjpeg,aac,'pcm_*'
  --enable-parser=h264,hevc,aac
  --enable-filter=scale,format,aformat,fps,aresample,null,anull,trim,atrim,setpts,asetpts,crop  # crop・trim は Onset のコマ取り出し（flint_rush/onset/ocr.py）
  --enable-encoder=pcm_f32le,rawvideo,png
  --enable-muxer=rawvideo,image2,image2pipe,pcm_f32le,wav  # -f f32le の muxer 名は pcm_f32le
)

CONFIGURE=(
  ./configure
  --disable-gpl --disable-nonfree --disable-version3
  --disable-autodetect --enable-zlib           # 外部ライブラリは使わない（zlib は PNG に要る。macOS 標準の libz）
  --enable-static --disable-shared --pkg-config-flags=--static
  --disable-doc --disable-network --disable-debug --disable-ffplay
  --disable-avdevice --disable-everything
  "${COMPONENTS[@]}"
  --extra-cflags="-mmacosx-version-min=$MACOS_MIN" --extra-ldflags="-mmacosx-version-min=$MACOS_MIN"
  --extra-version=ppro-rushes-lgpl
)

# 出力先の名前に configure の中身のハッシュを入れる（中身を変えたら別の場所に作り直す。CI のキャッシュキーにも使う）
CFG_HASH="$(printf '%s\n' "${CONFIGURE[@]}" | shasum -a 256 | cut -c1-10)"
OUT="build/ffmpeg-lgpl-$FFMPEG_VERSION-$ARCH-$CFG_HASH"

# LGPL 表記の確認。GPL・nonfree・version3 が混ざっていたら止まる
check_lgpl() {
  local head
  head="$("$OUT/ffmpeg" -hide_banner -L | head -3 | tr '\n' ' ' | sed 's/  */ /g')"
  echo "ffmpeg -L: $head"
  case "$head" in
    *"GNU Lesser General Public License as published"*) ;;
    *) echo "LGPL ではない: $OUT" >&2; exit 1 ;;
  esac
  if "$OUT/ffmpeg" -hide_banner -buildconf | grep -qE -- "--enable-(gpl|nonfree|version3)"; then
    echo "GPL / nonfree / version3 が有効: $OUT" >&2
    exit 1
  fi
  echo "LGPL を確認: $OUT"
  echo "$OUT" > build/ffmpeg-lgpl.path  # tools/build_app.sh が読む
}

if [ -x "$OUT/ffmpeg" ] && [ -x "$OUT/ffprobe" ]; then
  echo "既にある: $OUT"
  check_lgpl
  exit 0
fi

SRC="build/src"
mkdir -p "$SRC"
TAR="$SRC/ffmpeg-$FFMPEG_VERSION.tar.xz"
if [ ! -f "$TAR" ]; then
  curl -fsSL -o "$TAR.part" "$FFMPEG_URL"
  mv "$TAR.part" "$TAR"
fi
echo "$FFMPEG_SHA256  $TAR" | shasum -a 256 -c -

WORK="build/ffmpeg-work-$FFMPEG_VERSION-$ARCH"
mkdir -p "$WORK"
tar -xf "$TAR" -C "$WORK" --strip-components 1

(cd "$WORK" && MACOSX_DEPLOYMENT_TARGET=$MACOS_MIN "${CONFIGURE[@]}" && make -j"$(sysctl -n hw.ncpu)" ffmpeg ffprobe)

mkdir -p "$OUT"
cp "$WORK/ffmpeg" "$WORK/ffprobe" "$OUT/"
cp "$WORK/COPYING.LGPLv2.1" "$OUT/"
for a in "${CONFIGURE[@]}"; do  # そのまま貼って再現できる形（* を含む引数だけ引用する）
  case "$a" in *'*'*|*' '*) printf "'%s' " "$a" ;; *) printf '%s ' "$a" ;; esac
done | sed 's/ $//' > "$OUT/CONFIGURE.txt"
echo >> "$OUT/CONFIGURE.txt"

check_lgpl
