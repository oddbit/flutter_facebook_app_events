# Preserve Facebook App Events SDK classes used by this plugin.
# Without this rule, R8 in the host app may strip classes that are only
# referenced reflectively by the Facebook SDK, causing runtime crashes.
-keep class com.facebook.appevents.** { *; }
