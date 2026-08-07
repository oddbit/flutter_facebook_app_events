# Contributing 

We appreciate your interest in contributing to the `flutter_facebook_app_events` plugin. Contributions are essential for the growth and improvement of this project.

## How to Contribute

1. **Fork the Repository**: Start by forking the [repository](https://github.com/oddbit/flutter_facebook_app_events) to your GitHub account.

2. **Clone Your Fork**: Clone your forked repository to your local machine:
   ```bash
   git clone https://github.com/your-username/flutter_facebook_app_events.git
   cd flutter_facebook_app_events
   ```

3. **Create a Branch**: Create a new branch for your feature or bug fix:
   ```bash
   git checkout -b your-branch-name
   ```

4. **Make Changes**: Implement your changes, ensuring you follow the existing code style.

5. **Commit Changes**: Commit your changes with a clear and concise commit message:
   ```bash
   git add .
   git commit -m "Description of your changes"
   ```

6. **Push to GitHub**: Push your changes to your forked repository:
   ```bash
   git push origin your-branch-name
   ```

7. **Submit a Pull Request**: Open a pull request to the main repository. Provide a detailed description of your changes and reference any related issues.

## Attribution and Name Usage

If you publish a fork or derivative work, retain the project's license and
notice files and clearly identify your version as modified.

Please also follow the repository's [Trademark Policy](TRADEMARK_POLICY.md)
when referring to the Oddbit name in project names, package names,
descriptions, or branding.

## Reporting Issues
If you encounter any bugs or have suggestions for enhancements, please [open an issue](https://github.com/oddbit/flutter_facebook_app_events/issues). Provide as much detail as possible to help us understand and address the issue promptly.

Use the configured [Github issue report template](https://github.com/oddbit/flutter_facebook_app_events/issues/new?assignees=&labels=&template=bug_report.md&title=) when reporting an issue. 

Make sure to state your observations and expectations as objectively and informative as possible so that we can understand your need and be able to troubleshoot.


## Code of Conduct

We are committed to fostering a welcoming and respectful community. By participating in this project, you agree to adhere to our [Code of Conduct](CODE_OF_CONDUCT.md).

## Release Process

Before tagging a release, update the version in **both** of these files — they must match, otherwise CocoaPods consumers resolve the wrong version:

- `pubspec.yaml` — `version:` field
- `ios/facebook_app_events.podspec` — `s.version` field

Also check the pinned Graph API version while preparing a release. The plugin overrides the SDK's outdated default with a literal that appears in **three** places, which must match each other:

- `android/src/main/kotlin/id/oddbit/flutter/facebook_app_events/FacebookAppEventsPlugin.kt` — `FacebookSdk.setGraphApiVersion(...)`
- `ios/facebook_app_events/Sources/facebook_app_events/FacebookAppEventsPlugin.swift` — `Settings.shared.graphAPIVersion = ...`
- `README.md` — the "Graph API Version" section under Known Limitations

The deadline worth tracking is **not** a version's expiry date. Calls to an expired version are routed to the oldest version that is still usable ([Graph API versioning](https://developers.facebook.com/docs/graph-api/guides/versioning/)), so nothing breaks outright. What reaches app owners is Meta's deprecation notice, which sets a floor ("all versions prior to vXX will be removed") on Meta's own schedule, independent of any expiry. Compare the pin against [Meta's Graph API changelog](https://developers.facebook.com/docs/graph-api/changelog/) at release time and bump it if the current latest has moved well past it.

Then update `CHANGELOG.md` and create and push a tag in the format `v<major>.<minor>.<patch>`. For example:
```bash
git tag v1.2.3
git push origin v1.2.3
```
You can view existing tags [here](https://github.com/oddbit/flutter_facebook_app_events/tags).

Thank you for contributing to `flutter_facebook_app_events`!
