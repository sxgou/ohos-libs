# GMP for HarmonyOS

GMP (GNU Multiple Precision Arithmetic Library) cross-compiled for aarch64 HarmonyOS.

## Build

```bash
bash scripts/build-gmp.sh
```

## Version

- Library: GMP 6.3.0
- Target: aarch64-unknown-linux-ohos
- SDK: ohos-sdk 26.0.0.18

## Patches

- `config.sub`: Added `-ohos*` OS pattern recognition
- `config.status`: Replaced `mktemp -d` + `umask 077` with `mkdir -p` (HarmonyOS filesystem quirk)
- `libtool`: Replaced `print -r --` (ksh-ism) with `echo`; removed `umask 077`

## Notes

Static library build for linking R packages that need GMP (e.g., Rmpfr, Ryacas).
