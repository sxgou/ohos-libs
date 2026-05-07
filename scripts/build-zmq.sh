#!/bin/sh
# Build libzmq (ZeroMQ) 4.3.5 for aarch64 HarmonyOS
set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$SCRIPT_DIR/../config.sh"

SRC="zeromq-4.3.5"
TARBALL="v4.3.5.tar.gz"
URL="https://github.com/zeromq/libzmq/archive/refs/tags/${TARBALL}"

if [ ! -f "$WORK/$TARBALL" ]; then
  cd "$WORK"
  curl -sLO "$URL"
fi
rm -rf "$WORK/$SRC"
cd "$WORK"
tar xzf "$TARBALL"
mv "libzmq-4.3.5" "$SRC"

BUILD_DIR="$WORK/${SRC}-build"
rm -rf "$BUILD_DIR" && mkdir -p "$BUILD_DIR" && cd "$BUILD_DIR"

cmake "$WORK/$SRC" \
  -DCMAKE_TOOLCHAIN_FILE=/data/service/hnp/ohos-sdk.org/ohos-sdk_26.0.0.18/ohos/native/build/cmake/ohos.toolchain.cmake \
  -DOHOS_ARCH=arm64-v8a \
  -DCMAKE_INSTALL_PREFIX="$PREFIX" \
  -DBUILD_SHARED=ON \
  -DBUILD_STATIC=ON \
  -DBUILD_TESTS=OFF \
  -DBUILD_DRAFTS=OFF \
  -DWITH_PERF_TOOL=OFF \
  -DWITH_DOCS=OFF \
  -DZMQ_BUILD_TCP=ON \
  -DZMQ_BUILD_IPC=OFF \
  -DENABLE_CURVE=OFF \
  -DENABLE_WS=OFF \
  -DWITH_OPENPGM=OFF \
  -DWITH_NORM=OFF \
  -DWITH_VMCI=OFF \
  -DCMAKE_BUILD_TYPE=Release

make -j"$JOBS"
make install

echo "=== libzmq 4.3.5 build complete ==="
echo "  Library: $PREFIX/lib/libzmq.so"
echo "  Header:  $PREFIX/include/zmq.h"
