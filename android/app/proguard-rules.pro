# Room creates database implementations through reflection. Keep their default
# constructors so R8 full mode does not remove them from release builds.
-keep class * extends androidx.room.RoomDatabase { void <init>(); }
