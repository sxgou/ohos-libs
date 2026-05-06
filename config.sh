#!/bin/sh
# ohos-libs: Common toolchain configuration for aarch64 HarmonyOS cross-compilation
# Source this from build scripts: . "$(cd "$(dirname "$0")" && pwd)/config.sh"
set -e

# ---------------------------------------------------------------
# Override these env vars to match your OHOS NDK installation:
#   OHOS_CLANG, OHOS_CLANGXX, SYSROOT, PREFIX, WORK, JOBS
# ---------------------------------------------------------------

: "${OHOS_CLANG:=$(command -v aarch64-unknown-linux-ohos-clang 2>/dev/null || echo /data/service/hnp/bin/aarch64-unknown-linux-ohos-clang)}"
: "${OHOS_CLANGXX:=$(command -v aarch64-unknown-linux-ohos-clang++ 2>/dev/null || echo /data/service/hnp/bin/aarch64-unknown-linux-ohos-clang++)}"
: "${OHOS_AR:=$(command -v aarch64-unknown-linux-ohos-ar 2>/dev/null || echo /data/service/hnp/bin/ar)}"
: "${SYSROOT:=/data/service/hnp/ohos-sdk.org/ohos-sdk_26.0.0.18/ohos/native/sysroot}"
: "${PREFIX:=$HOME/.local/ohos-libs}"
: "${WORK:=/tmp/ohos-libs-build}"
: "${JOBS:=1}"  # keep 1 unless you have a non-seccomp'd make

export CC="$OHOS_CLANG"
export CXX="$OHOS_CLANGXX"
export AR="$OHOS_AR"
export CFLAGS="--sysroot=$SYSROOT -O2 -fPIC"
export CXXFLAGS="--sysroot=$SYSROOT -O2 -fPIC"
export LDFLAGS="--sysroot=$SYSROOT"
export CPPFLAGS="-I$PREFIX/include"
export PKG_CONFIG_PATH="$PREFIX/lib/pkgconfig"
export TMPDIR="$WORK"
export CONFIG_SHELL="/bin/sh"
export SHELL="/bin/sh"

mkdir -p "$PREFIX/lib/pkgconfig" "$WORK"

# Print configuration summary
echo "=== OHOS Cross-compilation config ==="
echo "  CC:      $CC"
echo "  CXX:     $CXX"
echo "  AR:      $AR"
echo "  SYSROOT: $SYSROOT"
echo "  PREFIX:  $PREFIX"
echo "  WORK:    $WORK"
echo "  JOBS:    $JOBS"
echo "====================================="
