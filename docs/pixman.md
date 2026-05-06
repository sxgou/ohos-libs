# Pixman for HarmonyOS

Pixman (pixel manipulation library) cross-compiled for aarch64 HarmonyOS.

## Build

```bash
bash scripts/build-pixman.sh
```

## Version

- Library: Pixman 0.42.2
- Target: aarch64-unknown-linux-ohos
- SDK: ohos-sdk 26.0.0.18

## Patches

- Disabled ARM NEON/SIMD/IWMMXT assembly (incompatible with clang assembler)
- `config.status`: Replaced `mktemp -d` + `umask 077` with `mkdir -p`
- `libtool`: Replaced `print -r --` with `echo`; removed `umask 077`

## Notes

Build as a dependency of Cairo. Static library only.
