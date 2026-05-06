# ohos-libs

System library cross-compilation suite for **aarch64 HarmonyOS (OpenHarmony)**.

This project contains build scripts for C system libraries needed by R,
Python, and other language runtimes on HarmonyOS. Every script handles
the quirks of the OHOS platform: no `/tmp` (set `TMPDIR`), `umask 077`
breakage, `mktemp` incompatibility, seccomp-blocked `mkfifo`, and missing
`config.sub` entries.

## Libraries

| Library | Ver | Build | Deps | Provides |
|---------|-----|-------|------|----------|
| [bzip2](https://sourceware.org/bzip2/) | 1.0.8 | Make | — | libbz2.a |
| [xz (liblzma)](https://tukaani.org/xz/) | 5.6.3 | Autotools | — | liblzma.a |
| [PCRE2](https://github.com/PCRE2Project/pcre2) | 10.44 | Autotools | — | libpcre2-{8,16,32,posix}.a |
| [zlib.pc](https://zlib.net/) | 1.2.11 | — | (sysroot) | zlib.pc |
| [OpenSSL](https://openssl.org/) | 3.0.15 | Configure | — | libssl.a, libcrypto.a |
| [libcurl](https://curl.se/) | 8.11.0 | Autotools | OpenSSL | libcurl.a |
| [libpng](http://libpng.org/) | 1.6.43 | CMake | zlib | libpng16.a |
| [FreeType2](https://freetype.org/) | 2.13.3 | CMake | libpng, bzip2 | libfreetype.a |
| [pixman](https://www.cairographics.org/) | 0.42.2 | Autotools | — | libpixman-1.a |
| [Cairo](https://www.cairographics.org/) | 1.16.0 | Autotools | pixman, libpng, freetype2, zlib | libcairo.a |
| [FFTW](https://fftw.org/) | 3.3.10 | Autotools | — | libfftw3.a, libfftw3f.a |
| [GEOS](https://libgeos.org/) | 3.12.0 | CMake | — | libgeos.a, libgeos_c.a |
| [GMP](https://gmplib.org/) | 6.3.0 | Autotools | — | libgmp.a |
| [libxml2](https://gitlab.gnome.org/GNOME/libxml2) | 2.12.9 | CMake | — | libxml2.a |
| [ANN](https://www.cs.umd.edu/~mount/ANN/) | 1.1.2 | Make | — | libann.a |
| libmuslstubs | — | — | — | libmuslstubs.so |
| libbacktrace_stub | — | — | — | libbacktrace_stub.so |

All static libs built with `-fPIC` so they can be linked into R shared
objects.

## Prerequisites

- **OHOS NDK clang** (`aarch64-unknown-linux-ohos-clang++`) in `$PATH`
- **OHOS sysroot** (tested with ohos-sdk 26.0.0.18)
- **CMake 3.5+** (for GEOS build)
- **curl** (to download source tarballs)
- **gfortran for OHOS** (for R; not covered by this project)

## Quick Start

```bash
git clone https://github.com/sxgou/ohos-libs.git
cd ohos-libs

# Override defaults to match your environment
export SYSROOT=/path/to/ohos/native/sysroot
export PREFIX=$HOME/.local/ohos-libs

# Build everything
bash build-all.sh
```

Or build individually:

```bash
bash scripts/build-bzip2.sh
bash scripts/build-xz.sh
bash scripts/build-pcre2.sh
bash scripts/build-pixman.sh
bash scripts/build-gmp.sh
bash scripts/build-fftw.sh
bash scripts/build-cairo.sh       # needs pixman, libpng, freetype2, zlib
bash scripts/build-geos.sh
bash scripts/build-stubs.sh       # libmuslstubs, libbacktrace_stub
```

## Configuration

All scripts source `config.sh`, which reads these environment variables:

| Variable | Default | Description |
|----------|---------|-------------|
| `OHOS_CLANG` | `aarch64-unknown-linux-ohos-clang` (in PATH) | C compiler |
| `OHOS_CLANGXX` | `aarch64-unknown-linux-ohos-clang++` (in PATH) | C++ compiler |
| `OHOS_AR` | `aarch64-unknown-linux-ohos-ar` (in PATH) | Archiver |
| `SYSROOT` | `/data/service/hnp/ohos-sdk.org/ohos-sdk_26.0.0.18/ohos/native/sysroot` | OHOS sysroot |
| `PREFIX` | `$HOME/.local/ohos-libs` | Install target |
| `WORK` | `/tmp/ohos-libs-build` | Build working directory |
| `JOBS` | `1` | Parallel make jobs (see Caveats) |

## Build Principles and Caveats

### OpenSSL (perl Configure, not autotools)

OpenSSL uses its own `./Configure` script (not autotools), which takes a
target triplet directly. We use `linux-aarch64` with OHOS clang as CC.

```bash
./Configure linux-aarch64 --prefix="$PREFIX" --libdir=lib \
  no-shared no-tests no-dso no-engine \
  no-afalgeng no-async no-atexit \
  CC="$CC" CFLAGS="$CFLAGS" LDFLAGS="$LDFLAGS"
```

**Caveats:**
- **Target must be `linux-aarch64`, not `linux-generic64`.** The generic
  target produces slower bignum code (no assembly optimizations). The
  aarch64 target enables ARMv8-A cryptographic extensions and Montgomery
  multiplication.
- **`no-atexit` is critical.** Without it, OpenSSL registers `atexit()`
  handlers that crash on OHOS because musl's `atexit` implementation
  differs. This leaks some global state on unload but linking is safe.
- **`no-engine` removes ENGINE support.** No hardware crypto accelerators
  can be loaded. Only software crypto is available.
- **`install_sw` vs `install`.** Use `make install_sw` to install only
  the software (libraries + headers) without man pages and docs.
- **Perl is required** for the Configure step. Install with `apt install perl`.

---

### libcurl (Autotools, depends on OpenSSL)

Standard autotools cross-compile but with many features disabled to
minimize dependencies. The critical dependency is OpenSSL for HTTPS.

```bash
../configure --host=aarch64-linux-gnu --prefix="$PREFIX" \
  --with-openssl --disable-shared --enable-static \
  --without-libpsl --without-quic --without-brotli \
  --without-zstd --without-libidn2 --without-nghttp2 \
  --without-nghttp3 --disable-ldap --disable-rtsp \
  --disable-dict --disable-telnet --disable-tftp \
  --disable-pop3 --disable-imap --disable-smtp \
  --disable-gopher --disable-mqtt \
  LIBS="-lpthread -ldl"
```

**Caveats:**
- **HTTP/2 and HTTP/3 disabled.** No nghttp2/nghttp3 on OHOS. All
  transfers are HTTP/1.1.
- **No alt-svc, no brotli, no zstd.** Content-encoding negotiation is
  limited to gzip/deflate (via zlib).
- **Threading.** curl needs `-lpthread -ldl` explicitly because OHOS
  doesn't auto-link these.
- **config.sub must be patched** for `-ohos*` just like other autotools
  builds.
- **Many disabled protocols.** Only HTTP/HTTPS, FTP, FILE, and proxy
  are enabled. SMTP, IMAP, POP3, LDAP, etc. are all disabled.

---

### libpng (CMake)

Straightforward CMake build. Only the static library is built; tests
and shared library are disabled.

```bash
cmake ../libpng-1.6.43 \
  -DCMAKE_SYSTEM_NAME=Linux \
  -DCMAKE_SYSTEM_PROCESSOR=aarch64 \
  -DCMAKE_C_COMPILER="$CC" \
  -DCMAKE_SYSROOT="$SYSROOT" \
  -DCMAKE_INSTALL_PREFIX="$PREFIX" \
  -DPNG_SHARED=OFF -DPNG_STATIC=ON -DPNG_TESTS=OFF
```

**Caveats:**
- **`libpng.a` is a symlink to `libpng16.a`.** Linking against `-lpng`
  or `-lpng16` both work, but prefer `-lpng16` to be explicit.
- **zlib is expected in the sysroot.** libpng's CMake finds zlib via
  its CMake config or pkg-config. If zlib.pc was generated first,
  CMake finds it automatically through `PKG_CONFIG_PATH`.
- **No SIMD-optimized CRC.** libpng's `pngpriv.h` includes ARM NEON
  optimizations if detected, but the cross-compile disables runtime
  CPU detection. PNG decoding may be slower than on a native ARM build.

---

### FreeType2 (CMake)

CMake build with optional features disabled to minimize dependencies.

```bash
cmake ../freetype-2.13.3 \
  -DCMAKE_SYSTEM_NAME=Linux \
  -DCMAKE_SYSTEM_PROCESSOR=aarch64 \
  -DCMAKE_C_COMPILER="$CC" \
  -DCMAKE_CXX_COMPILER="$CXX" \
  -DCMAKE_SYSROOT="$SYSROOT" \
  -DCMAKE_INSTALL_PREFIX="$PREFIX" \
  -DFT_DISABLE_HARFBUZZ=ON -DFT_DISABLE_BROTLI=ON \
  -DBUILD_SHARED_LIBS=OFF
```

**Caveats:**
- **HarfBuzz shaping is disabled.** Complex text layout (Arabic, Indic
  scripts) will not work correctly. For English/European text this is
  fine, but for CJK or RTL scripts, text may render incorrectly.
- **Brotli compression disabled.** WOFF2 font decompression won't work.
  Only GZip-compressed fonts are supported.
- **`FT_DISABLE_*` flags.** Disabling features reduces the library size
  from ~2MB to ~600KB. Enable harfbuzz if you need complex text layout.
- **Include path is `freetype2/`.** Consumers must add
  `-I$PREFIX/include/freetype2` to find `ft2build.h`.

---

### libxml2 (CMake)

CMake build with Python bindings and test programs disabled.

```bash
cmake ../libxml2-2.12.9 \
  -DCMAKE_SYSTEM_NAME=Linux \
  -DCMAKE_SYSTEM_PROCESSOR=aarch64 \
  -DCMAKE_C_COMPILER="$CC" \
  -DCMAKE_SYSROOT="$SYSROOT" \
  -DCMAKE_INSTALL_PREFIX="$PREFIX" \
  -DLIBXML2_WITH_PYTHON=OFF \
  -DLIBXML2_WITH_TESTS=OFF \
  -DLIBXML2_WITH_PROGRAMS=OFF \
  -DBUILD_SHARED_LIBS=OFF
```

**Caveats:**
- **No Python bindings.** The `libxml2-python` module is not built.
  R's `XML` package doesn't need it (it uses the C API directly).
- **No xmllint or test programs.** The CLI tools are not built.
- **Iconv dependency.** libxml2 needs iconv for character encoding
  conversion. OHOS sysroot provides a limited iconv; some encodings
  (EBCDIC, ISO-2022-JP) may fail. UTF-8 and Latin-1 work fine.
- **Include path is `libxml2/`.** Consumers need
  `-I$PREFIX/include/libxml2` to find `libxml/parser.h`.

---

### ANN (custom Makefile, no autotools/CMake)

ANN (Approximate Nearest Neighbor) uses a simple hand-written Makefile
with a `Make-config` configuration file.

```bash
# Patch Make-config for cross-compilation, then:
cd src && make -j1
```

**Caveats:**
- **Vulnerable to compiler changes.** ANN's Makefile hardcodes `g++`
  flags. The build script overrides `CXX` and `CFLAGS` explicitly.
- **No configure step.** ANN has no autoconf/CMake, so there's no
  platform detection. All platform-specific settings must be in the
  Make-config override.
- **Only static library.** ANN does not support building shared libs.
- **Obsolete upstream.** ANN 1.1.2 is from 2010. No active maintenance.
  The library is used only by R packages FNN and RANN.

---

### bzip2 (Makefile, no autotools)

The simplest build in the set. bzip2's Makefile only needs `CC` and `CFLAGS`
overridden — no configure step, no `config.sub`, no libtool issues.

```bash
make CC="$CC" CFLAGS="$CFLAGS -fPIC" libbz2.a libbz2.so
```

**Caveats:** None significant. The shared lib is built alongside the static
one but only the `.a` file is typically used (R links statically).

---

### xz / liblzma (Autotools)

Standard autotools cross-compile with `--host=aarch64-linux-gnu`. The only
platform-specific issue is `config.sub` not recognizing `-ohos*`.

```bash
# Before configure, patch config.sub
sed -i 's/-qnx\*)/-qnx*|-ohos*)/' config.sub

# Out-of-tree configure
../configure --host=aarch64-linux-gnu --build=aarch64-linux-gnu \
             --disable-shared --enable-static
```

**Caveats:**
- Install names `liblzma.a` but R looks for `liblzma.so` at runtime in some
  configurations. Force static linking via `LDFLAGS=-llzma`.
- `config.h` is auto-generated by configure; no manual patching needed.

---

### PCRE2 (Autotools)

PCRE2 must be built with three width variants (8/16/32 bit) because R uses
UTF-16 internally (`--enable-pcre2-16`) and some external packages need 32-bit
support (`--enable-pcre2-32`). The default 8-bit is always built.

```bash
../configure --host=aarch64-linux-gnu --disable-shared --enable-static \
             --enable-pcre2-16 --enable-pcre2-32
```

**Caveats:**
- All three variants compile simultaneously from one configure run — no need
  for separate builds.
- R's configure checks for `pcre2-config` or `pkg-config libpcre2-8`. The
  .pc file is installed automatically.
- Static link order matters: `-lpcre2-8 -lpcre2-posix` (posix must come
  after pcre2-8).

---

### zlib.pc (sysroot, not built from source)

zlib is provided by the OHOS sysroot at `$SYSROOT/usr/lib/aarch64-linux-ohos/`,
but there is no `.pc` file for pkg-config. Many autotools builds and R itself
use `pkg-config --libs zlib` to find zlib, so we generate a minimal `.pc` file.

```bash
cat > "$PREFIX/lib/pkgconfig/zlib.pc" << ZEOF
prefix=$SYSROOT/usr
exec_prefix=\${prefix}
libdir=\${exec_prefix}/lib/aarch64-linux-ohos
includedir=\${prefix}/include
Name: zlib
Version: 1.2.11
Libs: -L\${libdir} -lz
Cflags: -I\${includedir}
ZEOF
```

**Caveats:**
- Only a `.pc` file is generated — no library is built. The actual `.so` is
  loaded from the sysroot at runtime.
- If the sysroot path changes, the `.pc` file content must be updated.
- This approach assumes the sysroot zlib is compatible. It works for R and
  Cairo but may fail if a library needs newer zlib features.

---

### pixman (Autotools)

Pixel manipulation library used by Cairo. Simpler than Cairo but shares the
same autotools quirk set.

ARM NEON/SIMD/IWMMXT assembly must be disabled because the GNU assembler
directives in pixman's `pixman-arm-neon-asm.S` and similar files are
incompatible with clang's integrated assembler.

```bash
../configure --host=aarch64-linux-gnu --disable-shared --enable-static \
             --disable-arm-a64-neon --disable-arm-neon \
             --disable-arm-simd --disable-arm-iwmmxt \
             --disable-gcc-inline-asm
```

**Caveats:**
- **Performance loss without NEON.** The pixel blending routines fall back
  to generic C, which is 2–5× slower on large operations. Cairo-dependent
  R packages (Cairo, gdtools) will be noticeably slower for plotting.
- The `--disable-arm-*` flags affect only pixman, not Cairo itself.

---

### Cairo (Autotools, depends on pixman)

Cairo's configure detects many optional backends. For HarmonyOS we disable
everything except the image surface (the core pixman-based backend) and the
"meta" backends (PDF, PS, SVG) that don't need hardware.

```bash
../configure --host=aarch64-linux-gnu --disable-shared --enable-static \
             --enable-xlib=no --enable-xlib-xrender=no \
             --enable-xcb=no --enable-xlib-xcb=no
```

The platform quirks are more involved than other libraries:

1. **config.status**: Cairo's configure generates deeply nested `mktemp -d`
   calls guarded by `umask 077`. On OHOS, `umask 077` creates directories
   the calling process can't write to (filesystem quirk). These must be
   replaced with `mkdir -p`.
2. **libtool**: Cairo's libtool uses `print -r --` (ksh-ism) and embeds
   `umask 077`. These are patched to `echo` and empty string respectively.
3. **Build order**: Cairo must be built after pixman, zlib.pc generation,
   and optionally libpng/freetype2 if PNG/PDF/PS backends are needed.

```bash
# After configure, patch generated files
sed -i 's/mktemp -d "\.\/confXXXXXX"/mkdir -p .\/conftmp/g' config.status
sed -i "s/ECHO='print -r --'/ECHO='echo'/" config.status
CONFIG_SHELL=/bin/sh /bin/sh ./config.status
sed -i 's/print -r --/echo/g' libtool
sed -i 's/umask 077//g' libtool
```

**Caveats:**
- **No X11 or Wayland backends.** R's `X11()` device won't work, but the
  Cairo-based `png()` and `svg()` devices do.
- **Font rendering depends on freetype2.** If freetype2 is not in `PREFIX`,
  Cairo's fontconfig-based font selection is unavailable, and Cairo falls
  back to toy font API (only a few built-in faces).
- **configure is fragile.** Cairo's configure runs many feature tests that
  can fail in unexpected ways without X11 or GL libraries. Expect errors
  like `checking for cairo's atomic ops... no` — these are harmless and
  result in fallback code paths.
- **Version choice matters.** Cairo 1.18+ uses Meson. This project uses
  Cairo 1.16.0 (the last autotools version) to avoid rewriting the build
  for Meson's cross-compile machinery.

---

### FFTW (Autotools, dual build)

FFTW must be built twice: once with default flags (double precision,
`libfftw3.a`), once with `--enable-single` (float precision, `libfftw3f.a`).

```bash
build_fftw "" "double"        # libfftw3.a
build_fftw "--enable-single" "single"  # libfftw3f.a
```

Each build goes through a full configure → make cycle because the precision
touches code generation.

**Caveats:**
- **Must use `-j1`.** FFTW's makefile uses generated code that doesn't
  parallelize well, and make's jobserver (`mkfifo`) is blocked by OHOS
  seccomp policy. Parallel builds cause random build failures.
- **Long build time.** FFTW generates many specialized codelets (small
  assembly-like routines for different transform sizes) during the build.
  Expect 5–15 minutes per precision variant.
- **Wisdom is not persisted.** FFTW's "wisdom" (runtime planner results)
  is normally saved to a file. R packages that use FFTW will regenerate
  wisdom on each session unless the application persists it explicitly.
- **Quad precision (`libfftw3q.a`) is not built.** OHOS lacks `__float128`
  support in the clang configuration used.

---

### GEOS (CMake)

The only CMake-based library in the set. GEOS uses modern CMake with proper
toolchain file support.

```bash
cmake ../geos-3.12.0 \
  -DCMAKE_SYSTEM_NAME=Linux \
  -DCMAKE_SYSTEM_PROCESSOR=aarch64 \
  -DCMAKE_C_COMPILER="$CC" \
  -DCMAKE_CXX_COMPILER="$CXX" \
  -DCMAKE_SYSROOT="$SYSROOT" \
  -DCMAKE_INSTALL_PREFIX="$PREFIX" \
  -DBUILD_SHARED_LIBS=OFF \
  -DBUILD_TESTING=OFF
```

**Caveats:**
- **CMake policy version.** Some HarmonyOS SDK environments ship CMake 3.28+
  which deprecates old policy levels. `-DCMAKE_POLICY_VERSION_MINIMUM=3.5`
  avoids compatibility warnings.
- **Install target may fail.** `cmake --install` sometimes fails due to
  directory permissions; the script falls back to manual `cp`.
- **Tests must be disabled.** `-DBUILD_TESTING=OFF` avoids test compilation
  which would fail due to missing C++ test frameworks on OHOS.
- **C++17 required.** GEOS 3.12 requires C++14/17 features. The OHOS NDK
  clang supports these, but older GEOS versions (3.11-) would work too.

---

### GMP (Autotools)

GMP's configure includes hand-tuned assembly for many architectures. On
HarmonyOS it detects aarch64 but may not find all optimized paths.

```bash
../configure --host=aarch64-linux-gnu --disable-shared --enable-static
```

**Caveats:**
- **Missing assembly optimizations.** GMP's aarch64 assembly uses GNU
  assembler syntax that clang's integrated assembler partially rejects.
  Configure falls back to generic C, making bignum operations ~3× slower.
- **M4 requirement.** GMP's configure uses M4 to process assembly files.
  If `m4` is not in `PATH`, configure may hang or fail. Install `m4`
  via `apt install m4` or `brew install m4`.
- **`config.guess` needs patching too.** In addition to `config.sub`,
  GMP's `config.guess` may not return the correct triplet under OHOS.
  The build fixes this by explicitly passing `--build=aarch64-linux-gnu`.
- **C++ wrappers disabled.** GMP's C++ interface (`libgmpxx`) is not
  built because OHOS lacks a C++ exception handling runtime. Only the
  C interface (`libgmp.a`) is available.

---

### libmuslstubs / libbacktrace_stub (hand-written, -nostdlib)

These provide stub implementations for functions that R expects from musl
libc but are absent on HarmonyOS.

```c
/* musl_stubs.c provides: */
backtrace_create_state()  // R's error handler uses this
backtrace_simple()        // R's stack trace on crash
dl_iterate_phdr()         // R's dynamic library inspection
```

Compiled as shared objects with `-nostdlib`:

```bash
$CC -shared -fPIC -nostdlib -o libmuslstubs.so musl_stubs.c
$CC -shared -fPIC -nostdlib -o libbacktrace_stub.so backtrace_stub.c
```

**Caveats:**
- **Not real implementations.** These are empty functions that return 0 or
  null. Features that depend on actual backtraces (R's `traceback()`,
  debugger interaction) will silently produce no output.
- **Fragile API dependency.** If a future version of R relies on additional
  musl functions not currently stubbed, linking will fail with undefined
  references. Adding a new stub is trivial (one function signature) but
  requires recompilation.
- **`-nostdlib` is critical.** Without it, clang injects references to
  musl's `_start` and `__libc_start_main`, causing link errors.
- **`dl_iterate_phdr` is especially stubby.** Some OHOS versions do have
  this symbol but don't export it; the stub prevents link errors but
  provides no actual ELF module enumeration.

## HarmonyOS Platform Quirks

| Quirk | Root cause | Workaround |
|-------|-----------|------------|
| No `/tmp` writable | hmmac (Mandatory Access Control) restricts `/tmp` | Set `TMPDIR` to a user-writable path |
| `umask 077` breaks `mktemp -d` | OHOS filesystem interprets 077 as unwritable by owner | Replace `umask 077 && mktemp -d` with `mkdir -p` in `config.status` |
| `libtool` uses ksh `print -r --` | libtool hardcodes ksh syntax; OHOS has bash | Patch libtool: `s/print -r --/echo/g` |
| `config.sub` has no `-ohos*` | autotools upstream hasn't added OHOS | Add `-ohos*` pattern alongside `-qnx*` |
| make jobserver uses `mkfifo` | seccomp blocks `mkfifo` syscall | Default `JOBS=1`; cannot use parallel make |
| `zlib.pc` missing | OHOS NDK ships zlib but no pkg-config file | Generate `zlib.pc` pointing to sysroot paths |
| No `libexecinfo` / `backtrace` | musl feature not provided by OHOS libc | Provide stub implementations (see Stubs section) |
| `ar` uses wrong format | OHOS `ar` defaults to host format | Use `aarch64-unknown-linux-ohos-ar` or set `AR` |
| Static-only for most libs | OHOS dynamic linker has limited symbol resolution | Build `--enable-static --disable-shared` |

## Project Structure

```
ohos-libs/
├── README.md            # this file
├── build-all.sh         # master build script
├── config.sh            # common toolchain configuration
├── scripts/
│   ├── build-bzip2.sh     # bzip2 (Makefile)
│   ├── build-xz.sh        # xz/liblzma (Autotools)
│   ├── build-pcre2.sh     # PCRE2 8/16/32-bit (Autotools)
│   ├── build-zlib-pc.sh   # zlib.pc generator
│   ├── build-openssl.sh   # OpenSSL (Configure)
│   ├── build-curl.sh      # libcurl (Autotools)
│   ├── build-pixman.sh    # pixman (Autotools)
│   ├── build-libpng.sh    # libpng (CMake)
│   ├── build-freetype.sh  # FreeType2 (CMake)
│   ├── build-libxml2.sh   # libxml2 (CMake)
│   ├── build-cairo.sh     # Cairo image/pdf/svg (Autotools)
│   ├── build-fftw.sh      # FFTW double+single (Autotools)
│   ├── build-geos.sh      # GEOS (CMake)
│   ├── build-gmp.sh       # GMP (Autotools)
│   ├── build-ann.sh       # ANN (Makefile)
│   └── build-stubs.sh     # musl/backtrace stubs
└── stubs/
    ├── musl_stubs.c     # stub for missing musl functions
    └── backtrace_stub.c # stub backtrace implementation
```
