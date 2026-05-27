# Flutter wrapper — never strip Flutter engine classes
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Flutter deferred components use Play Core which is not present in sideload APKs
-dontwarn com.google.android.play.core.**

# Firebase
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }

# Keep all Dart model classes used via reflection/serialization
-keepattributes Signature
-keepattributes *Annotation*
-keepattributes SourceFile,LineNumberTable

# flutter_local_notifications
-keep class com.dexterous.** { *; }

# image_picker / image_cropper
-keep class com.yalantis.ucrop.** { *; }

# Prevent stripping of enum names (used in switch statements via JSON)
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# Kotlin serialization
-keepclassmembers class kotlinx.serialization.json.** { *** Companion; }
-keepclasseswithmembers class ** {
    kotlinx.serialization.KSerializer serializer(...);
}
