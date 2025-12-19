# facebook_app_events_example

Demonstrates how to use the `facebook_app_events` plugin.

## Run the example

From the repo root:

1. Fetch dependencies:
	- `cd example && flutter pub get`
2. Run on a device/emulator:
	- `flutter run`

The example UI includes a few buttons that call into the plugin (log events, purchases, and user data), so you can verify that events reach Meta's tools.

For Meta App Events setup and platform configuration, see the official docs:
- [iOS](https://developers.facebook.com/docs/app-events/getting-started-app-events-ios)
- [Android](https://developers.facebook.com/docs/app-events/getting-started-app-events-android)

# Privacy Policy
Please note that this example project is configured to run against a Facebook app
that might collect your information if you run the example **as it is**. 

Reconfigure the Facebook app integration if you do not wish to that the example
app reports any information to our test/debug app project. 

By running this example project as it is you are approving any potential collection
of information that the plugin might provide.

We are not using any of the collected information apart from troubleshooting
and for further development of the plugin.
