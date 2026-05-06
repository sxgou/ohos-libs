#!/bin/sh
# Build PCRE2 for aarch64 HarmonyOS (8/16/32 bit + posix)
set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$SCRIPT_DIR/../config.sh"

SRC="pcre2-10.44"
TARBALL="${SRC}.tar.bz2"
URL="https://github.com/PCRE2Project/pcre2/releases/download/${SRC}/${TARBALL}"

cd "$WORK"
[ -f "$TARBALL" ] || curl -sLO "$URL"
rm -rf "$SRC"; tar xf "$TARBALL"

# Patch config.sub for OHOS
[ -f "$SRC/config.sub" ] && sed -i 's/-qnx\*)/-qnx*|-ohos*)/' "$SRC/config.sub" 2>/dev/null || true

BUILD_DIR="$WORK/${SRC}-build"
rm -rf "$BUILD_DIR" && mkdir -p "$BUILD_DIR" && cd "$BUILD_DIR"

"$WORK/$SRC/configure" \
  --host=aarch64-linux-gnu --build=aarch64-linux-gnu \
  --prefix="$PREFIX" --disable-shared --enable-static \
  --enable-pcre2-16 --enable-pcre2-32 \
  CC="$CC" CFLAGS="$CFLAGS" LDFLAGS="$LDFLAGS"

make -j"$JOBS" && make install

echo "=== pcre2 done ==="
