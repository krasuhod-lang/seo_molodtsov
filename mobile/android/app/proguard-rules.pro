# Flutter / Firebase / Play Core
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.embedding.** { *; }
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**

# Keep model classes parsed from Firestore (нужны для рефлексии)
-keepclassmembers class ru.zaymy247.app.** {
    <init>(...);
    <fields>;
}
