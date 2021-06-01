# Apple WebRTC

## Sync official repo

Follow official [WebRTC iOS development](https://webrtc.googlesource.com/src/+/refs/heads/master/docs/native-code/ios/index.md) guide to sync official repo.

Note: all commands are executed on Python 2.x shell.

## Build stripped version of WebRTC for iOS and tvOS

Change directory into `src`, run:

```bash
git remote add cdnbye https://github.com/cdnbye/DataChannel.git
git fetch cdnbye
git checkout dc_only_ios
```

Then change directory into parent of `src`, run `gclient sync`.

Put `tvosify-os.sh` and `tvosify-sim.sh` in parent of `src`, then run:

```bash
cd src && \
python tools_webrtc/ios/build_ios_libs.py --bitcode --arch arm64 x64 -o out/iphone_libs/ && \
gn gen out/tvos_arm64 --args='target_os = "ios" target_cpu = "arm64" ios_enable_code_signing = false use_xcode_clang = true is_component_build = false is_debug = false ios_deployment_target = "10.0" rtc_libvpx_build_vp9 = false enable_ios_bitcode = true use_goma = false enable_dsyms = true enable_stripping = true' && \
../tvosify-os.sh ./out/tvos_arm64 && \
ninja -C out/tvos_arm64 framework_objc && \
gn gen out/tvos_x64 --args='target_os = "ios" target_cpu = "x64" ios_enable_code_signing = false use_xcode_clang = true is_component_build = false is_debug = false ios_deployment_target = "10.0" rtc_libvpx_build_vp9 = false enable_ios_bitcode = true use_goma = false enable_dsyms = true enable_stripping = true' && \
../tvosify-sim.sh ./out/tvos_x64 && \
ninja -C out/tvos_x64 framework_objc
```

## Build original version of WebRTC for macOS

Change directory into `src`, run:

```bash
git checkout cdnbye-mac
```

Then change directory into parent of `src`, run `gclient sync`.

Then run:

```bash
cd src && \
gn gen out/mac_x64 --args='target_os = "mac" target_cpu = "x64" is_component_build = false is_debug = false use_goma = false enable_dsyms = true enable_stripping = true' && \
ninja -C out/mac_x64 mac_framework_objc && \
gn gen out/mac_arm64 --args='target_os = "mac" target_cpu = "arm64" is_component_build = false is_debug = false use_goma = false enable_dsyms = true enable_stripping = true' && \
ninja -C out/mac_arm64 mac_framework_objc && \
lipo -create out/mac_x64/WebRTC.framework/WebRTC out/mac_arm64/WebRTC.framework/WebRTC -output out/WebRTC-mac-fat
```

Note: since the stripped version is a little bit old, which doesn't support build for macOS arm64, so macOS uses a different version, so to macOS version after iOS/tvOS version, or vice-versa, you need to checkout branch and run `gclient sync` again.

## Create xcframework

In directory `src`, run:

```bash
rm -rf out/WebRTC.xcframework

xcodebuild -create-xcframework \
  -framework out/iphone_libs/arm64_libs/WebRTC.framework \
  -framework out/iphone_libs/x64_libs/WebRTC.framework \
  -framework out/tvos_arm64/WebRTC.framework \
  -framework out/tvos_x64/WebRTC.framework \
  -framework out/mac_fat/WebRTC.framework \
  -output out/WebRTC.xcframework
```
