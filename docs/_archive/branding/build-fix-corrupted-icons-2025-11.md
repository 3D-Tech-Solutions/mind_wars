# Build Fix: Corrupted Launcher Icons (November 2025)

## Issue Summary

**Problem:** Alpha APK build failing in GitHub Actions with AAPT2 compilation errors

**Error Messages:**
```
ERROR: /home/runner/work/mind-wars/mind-wars/android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png: AAPT: error: file failed to compile.
ERROR: /home/runner/work/mind-wars/mind-wars/android/app/src/main/res/mipmap-mdpi/ic_launcher.png: AAPT: error: file failed to compile.
ERROR: /home/runner/work/mind-wars/mind-wars/android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png: AAPT: error: file failed to compile.
```

**Build Command:**
```bash
flutter build apk --flavor alpha --release --dart-define=FLAVOR=alpha
```

## Root Cause

All launcher icon PNG files (`ic_launcher.png`) in `android/app/src/main/res/mipmap-*` directories were corrupted:

- **Corruption Type:** "IDAT: invalid bit length repeat"
- **Affected Files:** All 5 density variants (mdpi, hdpi, xhdpi, xxhdpi, xxxhdpi)
- **Impact:** AAPT2 (Android Asset Packaging Tool) cannot compile corrupted PNG resources
- **Detection:** Validated using ImageMagick's `identify` tool

The files appeared valid on the surface (correct PNG header signature) but had internal IDAT chunk corruption that prevented Android's resource compiler from processing them.

## Solution Implemented

### 1. Icon Regeneration

Regenerated all launcher icons using ImageMagick:

```bash
# For each density (mdpi: 48px, hdpi: 72px, xhdpi: 96px, xxhdpi: 144px, xxxhdpi: 192px)
convert -size WxH \
    -define png:color-type=6 \
    gradient:'#4A90E2-#7B68EE' \
    -gravity center \
    -font DejaVu-Sans-Bold \
    -pointsize SIZE \
    -fill white \
    -stroke black \
    -strokewidth WIDTH \
    -annotate +0+0 "MW" \
    -strip \
    PNG32:output.png
```

### 2. Optimization

Optimized all icons using optipng:

```bash
optipng -o2 ic_launcher.png
```

### 3. Verification

Verified all icons are now valid:
- ✅ Proper PNG signature (89 50 4e 47)
- ✅ Correct dimensions for each density
- ✅ No metadata that could cause AAPT2 issues
- ✅ Successfully pass `identify` validation

### 4. Documentation

Added comprehensive documentation:
- **android/app/src/main/res/README.md** - Detailed icon requirements and update procedures
- **android/app/build.gradle** - Comments explaining icon requirements for future developers
- **This document** - Complete fix history for architectural records

## New Icon Specifications

| Density  | Size      | File Size | Format           |
|----------|-----------|-----------|------------------|
| mdpi     | 48×48 px  | 1.0 KB    | PNG (Palette)    |
| hdpi     | 72×72 px  | 1.9 KB    | PNG (TrueColor)  |
| xhdpi    | 96×96 px  | 2.5 KB    | PNG (TrueColor)  |
| xxhdpi   | 144×144 px| 3.7 KB    | PNG (TrueColor)  |
| xxxhdpi  | 192×192 px| 4.8 KB    | PNG (TrueColor)  |

All icons:
- ✅ sRGB colorspace
- ✅ 8-bit depth
- ✅ No embedded metadata
- ✅ Optimized for size

## Current Icon Design

The new icons are **placeholder designs** featuring:
- Gradient background (blue #4A90E2 to purple #7B68EE)
- "MW" text in white with black stroke
- Simple, clean, and functional

**Note:** These are temporary placeholders. Replace with professionally designed launcher icons before production release. See the res/README.md for recommended tools and procedures.

## Files Changed

1. `android/app/src/main/res/mipmap-mdpi/ic_launcher.png` - Regenerated
2. `android/app/src/main/res/mipmap-hdpi/ic_launcher.png` - Regenerated
3. `android/app/src/main/res/mipmap-xhdpi/ic_launcher.png` - Regenerated
4. `android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png` - Regenerated
5. `android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png` - Regenerated
6. `android/app/build.gradle` - Added comments about resource requirements
7. `android/app/src/main/res/README.md` - Created comprehensive documentation

## Testing Required

After this fix, the following should work:

- ✅ `flutter build apk --flavor alpha --release --dart-define=FLAVOR=alpha`
- ✅ `flutter build apk --flavor production --release`
- ✅ GitHub Actions workflow: `.github/workflows/build-alpha.yml`
- ✅ Local builds using `./build-alpha.sh android`

## Prevention for Future

To prevent similar issues:

1. **Always validate PNG files before committing:**
   ```bash
   identify android/app/src/main/res/mipmap-*/ic_launcher.png
   ```

2. **Use proper tools for icon generation:**
   - Android Studio's Image Asset Studio (recommended)
   - ImageMagick with `-strip` flag to remove metadata
   - optipng for optimization

3. **Test builds locally before pushing:**
   ```bash
   flutter clean
   flutter pub get
   flutter build apk --flavor alpha --release
   ```

4. **Review the resource README:**
   - `android/app/src/main/res/README.md` contains detailed guidelines

## Related Issues

- GitHub Actions build failing with AAPT2 errors
- Task: Continue troubleshooting build task issues

## References

- [AAPT2 Documentation](https://developer.android.com/studio/command-line/aapt2)
- [Android Icon Design Guidelines](https://developer.android.com/guide/practices/ui_guidelines/icon_design_launcher)
- [PNG Specification](http://www.libpng.org/pub/png/spec/1.2/PNG-Contents.html)

---

**Fix Date:** November 11, 2025  
**Build System:** Flutter 3.24.x, Gradle 8.x, Android SDK 34  
**Status:** ✅ Fixed - Build should now succeed
