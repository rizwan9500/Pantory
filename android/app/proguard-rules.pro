# Pantory ProGuard Rules
# Optimized for maximum functionality and performance, not size reduction

# Keep all classes - maximize functionality
-dontobfuscate
-optimizations !code/simplification/arithmetic,!code/simplification/cast,!field/*,!class/merging/*

# Keep all native methods for full platform support
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep all enums for better compatibility
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# Flutter specific rules - keep everything for maximum compatibility
-keep class io.flutter.** { *; }
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-dontwarn io.flutter.**

# Keep all Flutter plugins
-keep class io.flutter.plugins.** { *; }

# Preserve line numbers for better crash reporting
-keepattributes SourceFile,LineNumberTable
-renamesourcefileattribute SourceFile

# Keep all annotations
-keepattributes *Annotation*

# Keep all serializable classes for data persistence
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}

# Performance optimization: keep inline methods
-keepattributes Signature
-keepattributes InnerClasses
-keepattributes EnclosingMethod

# Keep custom application class
-keep public class com.pantory.app.** { *; }

# Optimize for speed, not size
-optimizationpasses 3
-allowaccessmodification
-repackageclasses ''

# Enable aggressive optimizations for performance
-optimizations !code/simplification/arithmetic
-optimizations !code/allocation/variable

# Keep Kotlin metadata for reflection
-keep class kotlin.Metadata { *; }
-keepclassmembers class kotlin.Metadata {
    public <methods>;
}

# Keep all Kotlin classes for maximum compatibility
-keep class kotlin.** { *; }
-keepclassmembers class kotlin.** {
    public <methods>;
}
