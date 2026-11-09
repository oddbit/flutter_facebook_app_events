// swift-tools-version: 5.9
// Copyright (c) Oddbit (https://oddbit.id)
//
// This source file is part of facebook_app_events.
// Licensed under the Apache License, Version 2.0. See LICENSE and NOTICE.

// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "facebook_app_events",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        // If the plugin name contains "_", the library name must use "-".
        .library(name: "facebook-app-events", targets: ["facebook_app_events"])
    ],
    dependencies: [
        .package(url: "https://github.com/facebook/facebook-ios-sdk.git", "19.0.0"..<"20.0.0"),
        // Local package the Flutter tool (3.41+) generates next to each plugin
        // package. Flutter's plugin-author guide requires it, and future Flutter
        // versions will reject SwiftPM plugins without it. This is why the
        // plugin's minimum Flutter version is 3.41.
        .package(name: "FlutterFramework", path: "../FlutterFramework")
    ],
    targets: [
        .target(
            name: "facebook_app_events",
            dependencies: [
                .product(name: "FacebookCore", package: "facebook-ios-sdk"),
                .product(name: "FacebookBasics", package: "facebook-ios-sdk"),
                .product(name: "FlutterFramework", package: "FlutterFramework")
            ]
        )
    ]
)
