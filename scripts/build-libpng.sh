#!/bin/sh
# Build libpng for aarch64 HarmonyOS
set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$SCRIPT_DIR/../config.sh"

SRC="libpng-1.6.43"
TARBALL="${SRC}.tar.gz"
URL="https://download.sourceforge.net/libpng/${TARBALL}"

cd "$WORK"
[ -f "$TARBALL" ] || curl -sLO "$URL"
rm -rf "$SRC"; tar xzf "$TARBALL"

BUILD_DIR="$WORK/${SRC}-build"
rm -rf "$BUILD_DIR" && mkdir -p "$BUILD_DIR" && cd "$BUILD_DIR"

cmake "$WORK/$SRC" \
  -DCMAKE_SYSTEM_NAME=Linux \
  -DCMAKE_SYSTEM_PROCESSOR=aarch64 \
  -DCMAKE_C_COMPILER="$CC" \
  -DCMAKE_CXX_COMPILER="$CXX" \
  -DCMAKE_SYSROOT="$SYSROOT" \
  -DCMAKE_INSTALL_PREFIX="$PREFIX" \
  -DCMAKE_C_FLAGS="$CFLAGS" \
  -DCMAKE_CXX_FLAGS="$CXXFLAGS" \
  -DBUILD_SHARED_LIBS=OFF \
  -DPNG_TESTS=OFF \
  -DPNG_SHARED=OFF \
  -DPNG_STATIC=ON \
  > configure.log 2>&1

cmake --build . -j"$JOBS" >> build.log 2>&1
cmake --install . >> install.log 2>&1

echo "=== libpng done ==="
echo "  lib: libpng16.a, libpng.a"
echo "  headers: include/png.h, include/pngconf.h"
