#!/bin/sh
# Build all system libraries for aarch64 HarmonyOS
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SCRIPTS="$SCRIPT_DIR/scripts"

echo "============================================"
echo "  ohos-libs: Build all system libraries"
echo "============================================"
echo ""

# Step 0: zlib.pc (zlib from sysroot, just generate .pc file)
echo ">>> Step 0/10: zlib.pc"
/bin/sh "$SCRIPTS/build-zlib-pc.sh"
echo ""

# Step 1: bzip2
echo ">>> Step 1/10: bzip2"
/bin/sh "$SCRIPTS/build-bzip2.sh"
echo ""

# Step 2: xz (liblzma)
echo ">>> Step 2/10: xz (liblzma)"
/bin/sh "$SCRIPTS/build-xz.sh"
echo ""

# Step 3: pcre2
echo ">>> Step 3/10: pcre2"
/bin/sh "$SCRIPTS/build-pcre2.sh"
echo ""

# Step 4: pixman (needed by cairo)
echo ">>> Step 4/10: pixman"
/bin/sh "$SCRIPTS/build-pixman.sh"
echo ""

# Step 5: gmp
echo ">>> Step 5/10: gmp"
/bin/sh "$SCRIPTS/build-gmp.sh"
echo ""

# Step 6: fftw
echo ">>> Step 6/10: fftw"
/bin/sh "$SCRIPTS/build-fftw.sh"
echo ""

# Step 7: cairo (depends on pixman, zlib, libpng, freetype — install those first)
echo ">>> Step 7/10: cairo"
/bin/sh "$SCRIPTS/build-cairo.sh"
echo ""

# Step 8: geos
echo ">>> Step 8/10: geos"
/bin/sh "$SCRIPTS/build-geos.sh"
echo ""

# Step 9: stub libraries
echo ">>> Step 9/10: stubs (libmuslstubs, libbacktrace_stub)"
/bin/sh "$SCRIPTS/build-stubs.sh"
echo ""

# Step 10: verify
echo ">>> Step 10/10: Verification"
echo ""
echo "Installed libraries in $PREFIX/lib/:"
ls -1 "$PREFIX/lib/"*.a "$PREFIX/lib/"*.so 2>/dev/null || echo "  (none found)"
echo ""
echo "Installed headers in $PREFIX/include/:"
ls -1 "$PREFIX/include/" 2>/dev/null || echo "  (none found)"
echo ""

echo "============================================"
echo "  Build complete!"
echo "============================================"
