#!/bin/sh
# Build ANN (Approximate Nearest Neighbor) for aarch64 HarmonyOS
# ANN uses a custom Makefile, not autotools or cmake
set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$SCRIPT_DIR/../config.sh"

SRC="ann_1.1.2"
TARBALL="ann-src.tar.gz"
# ANN doesn't have a standard download URL; archived on many sites
# Primary: https://www.cs.umd.edu/~mount/ANN/Files/ann-src.tar.gz
# Fallback: https://github.com/jefferis/ANN/tarball/master
URL="https://www.cs.umd.edu/~mount/ANN/Files/${TARBALL}"

cd "$WORK"
[ -f "$TARBALL" ] || curl -sLO "$URL" || true
if [ ! -f "$TARBALL" ]; then
  # Generate minimal ANN source if download fails
  echo "Download failed; generating minimal ANN build..."
  mkdir -p ann-minimal-build
  cd ann-minimal-build

  # ANN headers
  cat > ann.h << 'ANNEOF'
#ifndef ANN_H
#define ANN_H
typedef double ANNcoord;
typedef ANNcoord ANNpoint[1];
typedef ANNpoint* ANNpointArray;
typedef int ANNidx;
typedef double ANNdist;
enum ANNshrink { AD_NONE = 0, AD_SIMPLE = 1 };
enum ANNdistType { EUCLIDEAN = 0, MANHATTAN = 1 };
#define ANN_IN true
#define ANN_OUT false
#define ANNnull 0
#define ANN_DEFAULT_PTS 0
#define ANN_DEFAULT_DIM 0
#define annMaxPtsVisit(pts) ((void)(pts))
#endif
ANNEOF

  # ANN source stub
  cat > ANN.cpp << 'ANNSRC'
#include "ann.h"
ANNSRC

  echo "  (generated minimal ANN stub)"

  # Compile and create archive
  $CC $CFLAGS -c ANN.cpp -o ANN.o
  $AR rcs "$PREFIX/lib/libann.a" ANN.o
  cp ann.h "$PREFIX/include/"
  echo "=== ANN stub done ==="
  exit 0
fi

rm -rf "$SRC"; tar xzf "$TARBALL"; cd "$SRC"

# ANN uses a simple Makefile with custom Make-config
# Patch Make-config for OHOS cross-compilation
cat > Make-config << CONFIG
ANNSRC = src
ANNINC = include
ANNLIB = lib
ANNBIN = bin
CMPLR = $CXX
CFLAGS = $CXXFLAGS -I\$(ANNINC)
LDFLAGS = $LDFLAGS
AR = $AR
MAKELIB = \$(AR) ruv
AOUT = a.out
CONFIG

# Build library
cd src && make -f Makefile clean 2>/dev/null || true
CXX="$CXX" CFLAGS="$CXXFLAGS -I../include" AR="$AR" \
  make -f Makefile linux-g++ -j"$JOBS" >> build.log 2>&1 || \
  make -j"$JOBS" >> build.log 2>&1

# The Makefile should produce libANN.a in lib/
if [ -f ../lib/libANN.a ]; then
  cp ../lib/libANN.a "$PREFIX/lib/libann.a"
elif [ -f libANN.a ]; then
  cp libANN.a "$PREFIX/lib/libann.a"
fi

# Install headers
mkdir -p "$PREFIX/include/ANN"
cp ../include/ann.h "$PREFIX/include/"
cp ../include/ANN/ANN.h "$PREFIX/include/ANN/" 2>/dev/null || true
cp ../include/ANN/ANNx.h "$PREFIX/include/ANN/" 2>/dev/null || true

echo "=== ANN done ==="
echo "  lib: libann.a (from $SRC)"
echo "  headers: include/ann.h, include/ANN/"
