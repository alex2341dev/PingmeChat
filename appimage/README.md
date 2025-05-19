# PingmeChat AppImage

PingmeChat is provided as AppImage too. To Download, visit pingmechat.im.

## Building

- Ensure you install `appimagetool`

```shell
flutter build linux

# copy binaries to appimage dir
cp -r build/linux/{x64,arm64}/release/bundle appimage/PingmeChat.AppDir
cd appimage

# prepare AppImage files
cp PingmeChat.desktop PingmeChat.AppDir/
mkdir -p PingmeChat.AppDir/usr/share/icons
cp ../assets/logo.svg PingmeChat.AppDir/pingmechat.svg
cp AppRun PingmeChat.AppDir

# build the AppImage
appimagetool PingmeChat.AppDir
```
