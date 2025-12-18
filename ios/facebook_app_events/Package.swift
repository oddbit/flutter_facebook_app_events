// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "facebook_app_events",
    platforms: [
        .iOS(.v12)
    ],
    products: [
        // If the plugin name contains "_", the library name must use "-".
        .library(name: "facebook-app-events", targets: ["facebook_app_events"])
    ],
    dependencies: [
        .package(url: "https://github.com/facebook/facebook-ios-sdk.git", from: "18.0.0")
    ],
    targets: [
        .target(
            name: "facebook_app_events",
            dependencies: [
                .product(name: "FacebookCore", package: "facebook-ios-sdk"),
                .product(name: "FacebookBasics", package: "facebook-ios-sdk")
            ]
        )
    ]
)
