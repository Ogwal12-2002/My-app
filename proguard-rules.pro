# Keep rules for release builds (minifyEnabled true).
# Without these, R8/ProGuard can strip classes that mobile_scanner, sqflite,
# or other plugins reach via reflection, causing release-only crashes that
# don't reproduce in debug builds.

# mobile_scanner / ML Kit barcode scanning
-keep class com.google.mlkit.vision.barcode.** { *; }
-keep class com.google.mlkit.vision.codescanner.** { *; }
-dontwarn com.google.mlkit.**

# sqflite
-keep class com.tekartik.sqflite.** { *; }

# Generic Flutter plugin safety net
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.embedding.** { *; }
