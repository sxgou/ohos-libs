#!/bin/sh
# Build libcurl for aarch64 HarmonyOS (with OpenSSL backend)
set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$SCRIPT_DIR/../config.sh"

# Prerequisites: OpenSSL must be built and installed in $PREFIX
SRC="curl-8.11.0"
TARBALL="${SRC}.tar.xz"
URL="https://curl.se/download/${TARBALL}"

cd "$WORK"
[ -f "$TARBALL" ] || curl -sLO "$URL"
rm -rf "$SRC"; tar xJf "$TARBALL"

# Patch config.sub for OHOS
[ -f "$SRC/config.sub" ] && sed -i 's/-qnx\*)/-qnx*|-ohos*)/' "$SRC/config.sub" 2>/dev/null || true

BUILD_DIR="$WORK/${SRC}-build"
rm -rf "$BUILD_DIR" && mkdir -p "$BUILD_DIR" && cd "$BUILD_DIR"

export PKG_CONFIG_PATH="$PREFIX/lib/pkgconfig"

"$WORK/$SRC/configure" \
  --host=aarch64-linux-gnu --build=aarch64-linux-gnu \
  --prefix="$PREFIX" \
  --with-openssl \
  --disable-shared --enable-static \
  --without-libpsl --without-quic --without-brotli \
  --without-zstd --without-libidn2 --without-nghttp2 \
  --without-nghttp3 \
  --disable-ldap --disable-ldaps --disable-rtsp \
  --disable-dict --disable-telnet --disable-tftp \
  --disable-pop3 --disable-imap --disable-smtp \
  --disable-gopher --disable-mqtt \
  CC="$CC" CFLAGS="$CFLAGS" LDFLAGS="$LDFLAGS" \
  LIBS="-lpthread -ldl" \
  > configure.log 2>&1

make -j"$JOBS" >> make.log 2>&1
make install >> install.log 2>&1

echo "=== libcurl done ==="
echo "  lib: libcurl.a"
echo "  headers: include/curl/"
