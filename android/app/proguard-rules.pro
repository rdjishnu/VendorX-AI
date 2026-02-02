# Flutter standard rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Isar specific rules
-keep class io.isar.** { *; }
-keep class * extends io.isar.IsarLink { *; }
-keep class * extends io.isar.IsarLinks { *; }
-keep @io.isar.Collection class * { *; }
-keep @io.isar.Id class * { *; }
-keep @io.isar.Index class * { *; }
-keep @io.isar.Name class * { *; }
-keep @io.isar.Size class * { *; }

# Google Generative AI
-keep class com.google.ai.client.generativeai.** { *; }

# Play Core (referenced by Flutter but usually not needed unless using deferred components)
-dontwarn com.google.android.play.core.**

# ML Kit (referenced by plugin but not all models are used)
-dontwarn com.google.mlkit.vision.text.chinese.**
-dontwarn com.google.mlkit.vision.text.devanagari.**
-dontwarn com.google.mlkit.vision.text.japanese.**
-dontwarn com.google.mlkit.vision.text.korean.**

# General warnings that can be ignored for R8
-ignorewarnings
