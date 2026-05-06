#!/bin/sh
# Build FFTW for aarch64 HarmonyOS (double + single precision)
set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$SCRIPT_DIR/../config.sh"

SRC="fftw-3.3.10"
TARBALL="${SRC}.tar.gz"
URL="https://fftw.org/pub/fftw/${TARBALL}"

cd "$WORK"
[ -f "$TARBALL" ] || { curl -sLO "$URL" || curl -sLO "https://ftp.gnu.org/gnu/fftw/${TARBALL}"; }
rm -rf "$SRC"; tar xzf "$TARBALL"

# Patch config.sub for OHOS
[ -f "$SRC/config.sub" ] && sed -i 's/-qnx\*)/-qnx*|-ohos*)/' "$SRC/config.sub" 2>/dev/null || true

build_fftw() {
  local extra="$1" desc="$2"
  local bdir="$WORK/${SRC}-build${desc}"
  rm -rf "$bdir" && mkdir -p "$bdir" && cd "$bdir"

  "$WORK/$SRC/configure" \
    --prefix="$PREFIX" --host=aarch64-linux-gnu --build=aarch64-linux-gnu \
    --enable-shared=no --enable-static=yes $extra

  # Fix config.status
  sed -i 's/mktemp -d "\.\/confXXXXXX"/mkdir -p .\/conftmp/g' config.status
  sed -i "s/ECHO='print -r --'/ECHO='echo'/" config.status
  CONFIG_SHELL=/bin/sh /bin/sh ./config.status

  # Fix libtool
  sed -i '1s|#! /bin/sh|#!/data/service/hnp/bin/bash|' libtool 2>/dev/null || true
  sed -i 's/print -r --/echo/g' libtool 2>/dev/null || true
  sed -i 's/umask 077//g' libtool 2>/dev/null || true

  make -j"$JOBS" && make install
}

build_fftw "" "double"
build_fftw "--enable-single" "single"

echo "=== fftw done ==="
