# Cairo for HarmonyOS

Cairo 2D graphics library cross-compiled for aarch64 HarmonyOS.

## Build

```bash
# Prerequisites: pixman, libpng, freetype2 installed in PREFIX
bash scripts/build-cairo.sh
```

## Dependencies

- [pixman](pixman.md) (required)
- libpng
- freetype2
- zlib

## Version

- Library: Cairo 1.16.0 (autotools version)
- Target: aarch64-unknown-linux-ohos
- SDK: ohos-sdk 26.0.0.18

## Patches

- Disabled X11/XCB/Quartz/Win32 backends (unavailable on OHOS)
- Created `zlib.pc` for pkg-config (not provided by OHOS sysroot)
- `config.status`: Replaced `mktemp -d` + `umask 077` with `mkdir -p`
- `libtool`: Replaced `print -r --` with `echo`; removed `umask 077`

## Notes

Used by R packages needing Cairo graphics (Cairo, gdtools, R.devices).
Cairo 1.18+ uses the Meson build system — this build uses 1.16 (autotools).
