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
echo ">>> Step 0/13: zlib.pc"
/bin/sh "$SCRIPTS/build-zlib-pc.sh"
echo ""

# Step 1: bzip2
echo ">>> Step 1/13: bzip2"
/bin/sh "$SCRIPTS/build-bzip2.sh"
echo ""

# Step 2: xz (liblzma)
echo ">>> Step 2/13: xz (liblzma)"
/bin/sh "$SCRIPTS/build-xz.sh"
echo ""

# Step 3: pcre2
echo ">>> Step 3/13: pcre2"
/bin/sh "$SCRIPTS/build-pcre2.sh"
echo ""

# Step 4: openssl
echo ">>> Step 4/13: openssl"
/bin/sh "$SCRIPTS/build-openssl.sh"
echo ""

# Step 5: libcurl (needs openssl from step 4)
echo ">>> Step 5/13: libcurl"
/bin/sh "$SCRIPTS/build-curl.sh"
echo ""

# Step 6: pixman (needed by cairo)
echo ">>> Step 6/13: pixman"
/bin/sh "$SCRIPTS/build-pixman.sh"
echo ""

# Step 7: libpng
echo ">>> Step 7/13: libpng"
/bin/sh "$SCRIPTS/build-libpng.sh"
echo ""

# Step 8: freetype2
echo ">>> Step 8/13: freetype2"
/bin/sh "$SCRIPTS/build-freetype.sh"
echo ""

# Step 9: libxml2
echo ">>> Step 9/13: libxml2"
/bin/sh "$SCRIPTS/build-libxml2.sh"
echo ""

# Step 10: gmp
echo ">>> Step 10/13: gmp"
/bin/sh "$SCRIPTS/build-gmp.sh"
echo ""

# Step 11: fftw
echo ">>> Step 11/13: fftw"
/bin/sh "$SCRIPTS/build-fftw.sh"
echo ""

# Step 12: cairo (depends on pixman, libpng, freetype2, zlib)
echo ">>> Step 12/13: cairo"
/bin/sh "$SCRIPTS/build-cairo.sh"
echo ""

# Step 13: geos + ann + stubs
echo ">>> Step 13/13: geos, ann, stub libraries"
/bin/sh "$SCRIPTS/build-geos.sh"
echo ""
/bin/sh "$SCRIPTS/build-ann.sh"
echo ""
/bin/sh "$SCRIPTS/build-stubs.sh"
echo ""

# Verify
echo ">>> Verification"
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
