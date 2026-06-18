import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Regression guard for https://github.com/oddbit/flutter_facebook_app_events/issues/492
///
/// Flutter 3.44+ flags plugins that apply the Kotlin Gradle Plugin (KGP) by a *static text scan*
/// of each plugin's `android/build.gradle` (see `detectApplyingKotlinGradlePlugin` /
/// `kgpRegexGroovy` in Flutter's `FlutterPluginUtils.kt`). The scan only matches the *DSL* forms —
/// `apply plugin: "kotlin-android"` and `plugins { id "kotlin-android" }` — and ignores the
/// imperative `project.pluginManager.apply("kotlin-android")` the plugin uses (inside an
/// `agpMajor < 9` guard). Because detection is purely textual, wrapping the DSL form in a
/// conditional does NOT help; the DSL form must be absent. This test fails if either DSL form
/// is reintroduced into the plugin's build.gradle.
void main() {
  // `^[ \t]*apply plugin: 'kotlin-android'` (or `org.jetbrains.kotlin.android`), any quote style.
  final legacyApply = RegExp(
    r'''^[ \t]*apply[ \t]+plugin[ \t]*:[ \t]*(['"])(?:kotlin-android|org\.jetbrains\.kotlin\.android)\1''',
    multiLine: true,
  );
  // `id 'kotlin-android'` / `id("kotlin-android")` inside a `plugins {}` block.
  final pluginsBlockId = RegExp(
    r'''^[ \t]*(?:id|alias)[ \t]*\(?\s*(['"])(?:kotlin-android|org\.jetbrains\.kotlin\.android)\1''',
    multiLine: true,
  );

  test('plugin android/build.gradle does not apply KGP via a DSL form (issue #492)', () {
    final file = File('android/build.gradle');
    expect(file.existsSync(), isTrue, reason: 'android/build.gradle should exist');
    final text = file.readAsStringSync();

    expect(
      legacyApply.hasMatch(text),
      isFalse,
      reason: 'android/build.gradle applies KGP via `apply plugin: "kotlin-android"`; Flutter 3.44+ '
          'flags this. Use the imperative `project.pluginManager.apply("kotlin-android")` form '
          'guarded by `agpMajor < 9` instead (see issue #492).',
    );
    expect(
      pluginsBlockId.hasMatch(text),
      isFalse,
      reason: 'android/build.gradle applies KGP via a `plugins { id "kotlin-android" }` block; '
          'Flutter 3.44+ flags this. Use the imperative `project.pluginManager.apply(...)` form '
          'guarded by `agpMajor < 9` instead (see issue #492).',
    );
  });
}
