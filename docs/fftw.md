# FFTW for HarmonyOS

FFTW (Fastest Fourier Transform in the West) cross-compiled for aarch64 HarmonyOS.

## Build

```bash
bash scripts/build-fftw.sh
```

Builds both double-precision (`libfftw3.a`) and single-precision (`libfftw3f.a`) static libraries.

## Version

- Library: FFTW 3.3.10
- Target: aarch64-unknown-linux-ohos
- SDK: ohos-sdk 26.0.0.18

## Patches

- `config.sub`: Added `-ohos*` OS pattern recognition
- `config.status`: Replaced `mktemp -d` + `umask 077` with `mkdir -p`
- `libtool`: Replaced `print -r --` with `echo`; removed `umask 077`
- Make: Uses `-j1` to avoid `mkfifo` jobserver issue on HarmonyOS

## Notes

Static library build for linking R packages needing FFTW (fftw, fftwtools, spatstat).
