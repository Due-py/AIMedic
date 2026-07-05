# home_widget pulls in androidx.work, whose Room database implementation is
# instantiated by reflection; R8 stripped it in release builds, crashing the
# app at process start (Failed to create an instance of WorkDatabase).
-keep class androidx.work.** { *; }
-keep class androidx.room.** { *; }
