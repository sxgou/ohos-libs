#!/bin/sh
# Build cairo for aarch64 HarmonyOS
# Prerequisites: pixman, libpng, freetype2 built and installed in $PREFIX
set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$SCRIPT_DIR/../config.sh"

# Ensure zlib.pc exists
[ -f "$PREFIX/lib/pkgconfig/zlib.pc" ] || "$SCRIPT_DIR/build-zlib-pc.sh"

SRC="cairo-1.16.0"
TARBALL="${SRC}.tar.xz"
URL="https://www.cairographics.org/releases/${TARBALL}"

cd "$WORK"
[ -f "$TARBALL" ] || curl -sLO "$URL"
rm -rf "$SRC"; tar xJf "$TARBALL"

# Patch config.sub for OHOS
[ -f "$SRC/config.sub" ] && sed -i 's/-qnx\*)/-qnx*|-ohos*)/' "$SRC/config.sub" 2>/dev/null || true

BUILD_DIR="$WORK/${SRC}-build"
rm -rf "$BUILD_DIR" && mkdir -p "$BUILD_DIR" && cd "$BUILD_DIR"

"$WORK/$SRC/configure" \
  --prefix="$PREFIX" --host=aarch64-linux-gnu --build=aarch64-linux-gnu \
  --enable-shared=no --enable-static=yes \
  --enable-xlib=no --enable-xlib-xrender=no \
  --enable-xcb=no --enable-xlib-xcb=no

# Fix config.status for HarmonyOS
cs="config.status"
sed -i 's/mktemp -d "\.\/confXXXXXX"/mkdir -p .\/conftmp/g' "$cs"
sed -i "s/ECHO='print -r --'/ECHO='echo'/" "$cs"
CONFIG_SHELL=/bin/sh /bin/sh ./config.status

# Fix libtool
sed -i '1s|#! /bin/sh|#!/data/service/hnp/bin/bash|' libtool 2>/dev/null || true
sed -i 's/print -r --/echo/g' libtool 2>/dev/null || true
sed -i 's/umask 077//g' libtool 2>/dev/null || true

make -j"$JOBS" && make install

echo "=== cairo done ==="
