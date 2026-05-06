#!/bin/sh
# Build FreeType2 for aarch64 HarmonyOS
set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$SCRIPT_DIR/../config.sh"

SRC="freetype-2.13.3"
TARBALL="${SRC}.tar.xz"
URL="https://download.savannah.gnu.org/releases/freetype/${TARBALL}"

cd "$WORK"
[ -f "$TARBALL" ] || curl -sLO "$URL"
rm -rf "$SRC"; tar xJf "$TARBALL"

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
  -DFT_DISABLE_ZLIB=OFF \
  -DFT_DISABLE_BZIP2=OFF \
  -DFT_DISABLE_PNG=OFF \
  -DFT_DISABLE_HARFBUZZ=ON \
  -DFT_DISABLE_BROTLI=ON \
  > configure.log 2>&1

cmake --build . -j"$JOBS" >> build.log 2>&1
cmake --install . >> install.log 2>&1

echo "=== FreeType done ==="
echo "  lib: libfreetype.a"
echo "  headers: include/freetype2/"
