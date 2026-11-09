import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Regression guard for https://github.com/oddbit/flutter_facebook_app_events/issues/514
///
/// Flutter's Swift Package Manager guide for plugin authors requires the plugin's Package.swift
/// to depend on the local `FlutterFramework` package that the Flutter tool generates (3.41+).
/// Flutter's own check only looks for the word `FlutterFramework` anywhere in the manifest
/// (`validatePluginSupportsSwiftPackageManager`), and the builds still pass when one of the two
/// declarations is missing. So this test checks for both: the package dependency and the
/// target's product dependency. Comment lines are ignored so a commented-out declaration fails.
void main() {
  final packageDependency = RegExp(
    r'''\.package\(\s*name:\s*"FlutterFramework"\s*,\s*path:\s*"\.\./FlutterFramework"\s*\)''',
  );
  final productDependency = RegExp(
    r'''\.product\(\s*name:\s*"FlutterFramework"\s*,\s*package:\s*"FlutterFramework"\s*\)''',
  );

  test('ios Package.swift depends on FlutterFramework (issue #514)', () {
    final file = File('ios/facebook_app_events/Package.swift');
    expect(file.existsSync(), isTrue,
        reason: 'ios/facebook_app_events/Package.swift should exist');
    final code = file
        .readAsStringSync()
        .replaceAll(RegExp(r'/\*.*?\*/', dotAll: true), '')
        .split('\n')
        .where((line) => !line.trimLeft().startsWith('//'))
        .join('\n');

    expect(
      packageDependency.hasMatch(code),
      isTrue,
      reason: 'Package.swift must declare '
          '`.package(name: "FlutterFramework", path: "../FlutterFramework")` in the package '
          'dependencies (see issue #514).',
    );
    expect(
      productDependency.hasMatch(code),
      isTrue,
      reason: 'Package.swift must declare '
          '`.product(name: "FlutterFramework", package: "FlutterFramework")` in the '
          'facebook_app_events target dependencies (see issue #514).',
    );
  });
}
