![version](https://img.shields.io/badge/version-18%2B-EB8E5F)
![platform](https://img.shields.io/static/v1?label=platform&message=mac-intel%20|%20mac-arm%20|%20win-64&color=blue)
![downloads](https://img.shields.io/github/downloads/miyako/4d-plugin-zint-v2/total)

# 4d-plugin-zint-v2
Barcode generator based on zint

### Syntax

[miyako.github.io](https://miyako.github.io/2019/11/27/4d-plugin-zint.html)

### Notes on ARM

to compile libnpng for ARM, add

```
set(CMAKE_SYSTEM_PROCESSOR arm CACHE INTERNAL "")
```

to CMakeLists.txt, build, `lipo` with Intel output.
