# Preserve Facebook App Events classes used by this plugin.
# Without this rule, R8 in the host app may strip App Events classes that are
# only referenced reflectively by the Facebook App Events SDK, causing runtime crashes.
-keep class com.facebook.appevents.** { *; }
