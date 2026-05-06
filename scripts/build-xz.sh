#!/bin/sh
# Build xz (liblzma) for aarch64 HarmonyOS
set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$SCRIPT_DIR/../config.sh"

SRC="xz-5.6.3"
TARBALL="${SRC}.tar.gz"
URL="https://github.com/tukaani-project/xz/releases/download/v${SRC}/${TARBALL}"

cd "$WORK"
[ -f "$TARBALL" ] || curl -sLO "$URL"
rm -rf "$SRC"; tar xzf "$TARBALL"

# Patch config.sub for OHOS
[ -f "$SRC/config.sub" ] && sed -i 's/-qnx\*)/-qnx*|-ohos*)/' "$SRC/config.sub" 2>/dev/null || true

BUILD_DIR="$WORK/${SRC}-build"
rm -rf "$BUILD_DIR" && mkdir -p "$BUILD_DIR" && cd "$BUILD_DIR"

"$WORK/$SRC/configure" \
  --host=aarch64-linux-gnu --build=aarch64-linux-gnu \
  --prefix="$PREFIX" --disable-shared --enable-static \
  CC="$CC" CFLAGS="$CFLAGS" LDFLAGS="$LDFLAGS"

make -j"$JOBS" && make install

echo "=== xz (liblzma) done ==="
