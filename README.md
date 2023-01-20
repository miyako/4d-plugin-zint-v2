![version](https://img.shields.io/badge/version-17%2B-3E8B93)
![platform](https://img.shields.io/static/v1?label=platform&message=mac-intel%20|%20mac-arm%20|%20win-64&color=blue)
![downloads](https://img.shields.io/github/downloads/miyako/4d-plugin-zint-v2/total)

### Dependencies and Licensing

* the source code of this plugin developed using the [4D Plug-in SDK](https://github.com/4d/4D-Plugin-SDK) is licensed under the [MIT license](https://github.com/miyako/4d-plugin-gs/blob/master/LICENSE).
* see [zint](https://github.com/zint/zint) for the licensing of **zint** (shared library).
* other dependencies: **libpng** and **JsonCpp**

### Syntax

[miyako.github.io](https://miyako.github.io/2019/11/27/4d-plugin-zint.html)

### Notes on ARM

to compile libpng for ARM, add

```
set(CMAKE_SYSTEM_PROCESSOR arm CACHE INTERNAL "")
```

to CMakeLists.txt, set architecture to `arm` in Xcode, build, `lipo -create`.
