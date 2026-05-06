#!/bin/sh
# Build GEOS for aarch64 HarmonyOS (cmake-based)
set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$SCRIPT_DIR/../config.sh"

SRC="geos-3.12.0"
TARBALL="${SRC}.tar.bz2"
URL="https://download.osgeo.org/geos/${TARBALL}"

cd "$WORK"
[ -f "$TARBALL" ] || curl -sLO "$URL"
rm -rf "$SRC"; tar xjf "$TARBALL"

BUILD_DIR="$WORK/${SRC}-build"
rm -rf "$BUILD_DIR" && mkdir -p "$BUILD_DIR" && cd "$BUILD_DIR"

cmake "$WORK/$SRC" \
  -DCMAKE_POLICY_VERSION_MINIMUM=3.5 \
  -DCMAKE_SYSTEM_NAME=Linux \
  -DCMAKE_SYSTEM_PROCESSOR=aarch64 \
  -DCMAKE_C_COMPILER="$CC" \
  -DCMAKE_CXX_COMPILER="$CXX" \
  -DCMAKE_SYSROOT="$SYSROOT" \
  -DCMAKE_INSTALL_PREFIX="$PREFIX" \
  -DCMAKE_C_FLAGS="$CFLAGS" \
  -DCMAKE_CXX_FLAGS="$CXXFLAGS" \
  -DBUILD_SHARED_LIBS=OFF \
  -DBUILD_TESTING=OFF

cmake --build . -j"$JOBS"
cmake --install . --prefix "$PREFIX" 2>/dev/null || {
  cp lib/libgeos*.a "$PREFIX/lib/"
  cp -r include/geos* "$PREFIX/include/"
}

echo "=== geos done ==="
