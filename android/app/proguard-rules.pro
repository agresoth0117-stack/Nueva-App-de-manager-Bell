# Keep Flutter classes
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.embedding.** { *; }

# Prevent obfuscation issues
-keep class com.google.** { *; }
-dontwarn com.google.**
