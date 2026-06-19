# Required image assets — read before building a release

This folder needs **three PNG files you must supply** before running the
icon/splash generators. I can write all the code and config, but I can't
design your brand artwork — that's a real design decision for you to make
(or commission), not something to fake with a placeholder that ships to
the Play Store.

## Files needed

| File | Size | Purpose |
|---|---|---|
| `icons/app_icon.png` | 1024×1024 | Main app icon (used for standard + Play Store listing icon) |
| `icons/app_icon_foreground.png` | 1024×1024, transparent background | Foreground layer for Android adaptive icons (the part that sits on top of the colored background defined in pubspec.yaml) |
| `icons/splash_logo.png` | ~512×512, transparent background | Logo shown on the splash screen while the app cold-starts |

## Design guidance for this app specifically

- Keep it simple and geometric — a stylized QR-code corner-bracket mark or
  a scan-line-through-a-square works well and stays legible at 48×48 (the
  smallest size Android renders it at).
- Avoid thin lines or fine detail — they disappear at small sizes.
- The adaptive icon foreground needs ~66% safe zone in the center (Android
  crops/masks the outer edges differently per device, e.g. circle vs
  squircle vs rounded square).
- Match the brand blue already defined in the app:
  `#2F6FED` (see `lib/core/theme/app_colors.dart`) — using it in the icon
  keeps the icon and in-app branding consistent.

## Once you have the files

```bash
# Drop your 3 PNGs into assets/icons/ with the exact filenames above, then:
flutter pub get
dart run flutter_launcher_icons
dart run flutter_native_splash:create
```

This generates all required Android density buckets (mipmap-mdpi through
mipmap-xxxhdpi) and wires up the splash screen automatically — you don't
need to manually touch any Android resource files.

## If you want help designing it

I can generate icon concepts as SVG/HTML mockups for you to review and
export, or describe exact specs for a designer/Midjourney/Figma — just ask.
