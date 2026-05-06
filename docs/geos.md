# GEOS for HarmonyOS

GEOS (Geometry Engine, Open Source) cross-compiled for aarch64 HarmonyOS.

## Build

```bash
bash scripts/build-geos.sh
```

## Version

- Library: GEOS 3.12.0
- Target: aarch64-unknown-linux-ohos
- SDK: ohos-sdk 26.0.0.18

## Patches

- CMake: Used `-DCMAKE_POLICY_VERSION_MINIMUM=3.5` for compatibility with newer CMake
- Disabled test building to speed up compilation

## Notes

Static library build (`libgeos.a`, `libgeos_c.a`) for R spatial packages (sf, exactextractr, etc.).
