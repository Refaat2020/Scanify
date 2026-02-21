# ML Kit Text Recognition
-keep class com.google.mlkit.** { *; }
-keep class com.google.android.gms.internal.mlkit_vision_text_common.** { *; }

# Prevent stripping text recognizer options
-keep class com.google.mlkit.vision.text.** { *; }

# Keep native libs
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.mlkit.**