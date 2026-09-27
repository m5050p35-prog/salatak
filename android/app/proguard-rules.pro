# Flutter
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Supabase & Realtime
-keep class io.supabase.** { *; }
-keep class com.google.gson.** { *; }
-dontwarn io.supabase.**

# SharedPreferences
-keep class androidx.preference.** { *; }

# Kotlin
-dontwarn kotlin.**
-keep class kotlin.** { *; }
