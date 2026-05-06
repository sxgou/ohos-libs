#!/bin/sh
# Generate zlib.pc for pkg-config (zlib is in OHOS sysroot but has no .pc file)
set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$SCRIPT_DIR/../config.sh"

# zlib (from sysroot at $SYSROOT/usr/lib/aarch64-linux-ohos/)
ZDIR="$SYSROOT/usr"
cat > "$PREFIX/lib/pkgconfig/zlib.pc" << ZEOF
prefix=$ZDIR
exec_prefix=\${prefix}
libdir=\${exec_prefix}/lib/aarch64-linux-ohos
includedir=\${prefix}/include
Name: zlib
Description: zlib compression library
Version: 1.2.11
Libs: -L\${libdir} -lz
Cflags: -I\${includedir}
ZEOF

echo "=== zlib.pc generated ==="
