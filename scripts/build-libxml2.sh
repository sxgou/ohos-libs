#!/bin/sh
# Build libxml2 for aarch64 HarmonyOS
set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$SCRIPT_DIR/../config.sh"

SRC="libxml2-2.12.9"
TARBALL="${SRC}.tar.xz"
URL="https://download.gnome.org/sources/libxml2/2.12/${TARBALL}"

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
  -DLIBXML2_WITH_PYTHON=OFF \
  -DLIBXML2_WITH_TESTS=OFF \
  -DLIBXML2_WITH_PROGRAMS=OFF \
  > configure.log 2>&1

cmake --build . -j"$JOBS" >> build.log 2>&1
cmake --install . >> install.log 2>&1

echo "=== libxml2 done ==="
echo "  lib: libxml2.a"
echo "  headers: include/libxml2/"
