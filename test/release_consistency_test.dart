import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Guards the values that CONTRIBUTING.md ("Release Process") says must be
/// kept in step by hand across several files.
void main() {
  String read(String path) {
    final file = File(path);
    expect(file.existsSync(), isTrue, reason: '$path should exist');
    return file.readAsStringSync();
  }

  String firstGroup(String path, RegExp pattern) {
    final match = pattern.firstMatch(read(path));
    expect(match, isNotNull, reason: '${pattern.pattern} not found in $path');
    return match!.group(1)!;
  }

  const kotlinPlugin =
      'android/src/main/kotlin/id/oddbit/flutter/facebook_app_events/FacebookAppEventsPlugin.kt';
  const swiftPlugin =
      'ios/facebook_app_events/Sources/facebook_app_events/FacebookAppEventsPlugin.swift';

  group('plugin version', () {
    // Read inside the tests: `expect` cannot run while tests are declared.
    String pubspecVersion() => firstGroup(
          'pubspec.yaml',
          RegExp(r'^version:\s*(\S+)', multiLine: true),
        );

    // CocoaPods consumers resolve the podspec version, not the pubspec one.
    test('podspec matches pubspec.yaml', () {
      final podspecVersion = firstGroup(
        'ios/facebook_app_events.podspec',
        RegExp(r'''s\.version\s*=\s*['"]([^'"]+)['"]'''),
      );
      expect(podspecVersion, pubspecVersion());
    });

    // The version bump and its release notes are written in the same commit,
    // and the release workflow fails without a CHANGELOG entry for the tag.
    test('the newest CHANGELOG entry is for the pubspec.yaml version', () {
      final newestEntry = firstGroup(
        'CHANGELOG.md',
        RegExp(r'^## (\S+)', multiLine: true),
      );
      expect(newestEntry, pubspecVersion());
    });
  });

  group('pinned Graph API version', () {
    String kotlinPin() => firstGroup(
          kotlinPlugin,
          RegExp(r'FacebookSdk\.setGraphApiVersion\("(v\d+\.\d+)"\)'),
        );

    test('iOS pins the same version as Android', () {
      final swiftPin = firstGroup(
        swiftPlugin,
        RegExp(r'Settings\.shared\.graphAPIVersion = "(v\d+\.\d+)"'),
      );
      expect(swiftPin, kotlinPin());
    });

    test('README states the pinned version', () {
      final readmePin = firstGroup(
        'README.md',
        RegExp(r'pins the Graph API version to `(v\d+\.\d+)`'),
      );
      expect(readmePin, kotlinPin());
    });
  });

  // AGENTS.md "Facebook SDK version policy": all three follow the same major.
  group('Facebook SDK major version', () {
    String androidMajor() => firstGroup(
          'android/build.gradle',
          RegExp(r'facebook-android-sdk:\[(\d+)\.0,\d+\.0\)'),
        );

    test('Android range spans exactly one major', () {
      final upper = firstGroup(
        'android/build.gradle',
        RegExp(r'facebook-android-sdk:\[\d+\.0,(\d+)\.0\)'),
      );
      expect(int.parse(upper), int.parse(androidMajor()) + 1);
    });

    test('CocoaPods follows the same major', () {
      final podMajor = firstGroup(
        'ios/facebook_app_events.podspec',
        RegExp(r'''s\.dependency\s+'FBSDKCoreKit',\s*'~>\s*(\d+)\.0'\s*$''',
            multiLine: true),
      );
      expect(podMajor, androidMajor());
    });

    test('Swift Package Manager follows the same major', () {
      final spm = RegExp(r'"(\d+)\.0\.0"\.\.<"(\d+)\.0\.0"')
          .firstMatch(read('ios/facebook_app_events/Package.swift'));
      expect(spm, isNotNull, reason: 'SDK range not found in Package.swift');
      expect(spm!.group(1), androidMajor());
      expect(int.parse(spm.group(2)!), int.parse(androidMajor()) + 1);
    });
  });
}
