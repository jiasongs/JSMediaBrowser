// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "JSMediaBrowser",
    platforms: [
        .iOS(.v10),
    ],
    swiftLanguageVersions: [
        .v4.2,
        .v5
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "JSMediaBrowser",
            targets: ["JSMediaBrowser"]),
        .library(
            name: "MediaView",
            targets: ["MediaView"]),
        .library(
            name: "MediaImage",
            targets: ["MediaImage"]),
        .library(
            name: "MediaImageForSDWebImage",
            targets: ["MediaImageForSDWebImage"]),
        .library(
            name: "MediaVideo",
            targets: ["MediaVideo"]),
        .library(
            name: "Business",
            targets: ["Business"]),
        .library(
            name: "BusinessForImage",
            targets: ["BusinessForImage"]),
        .library(
            name: "BusinessForVideo",
            targets: ["BusinessForVideo"])
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/jiasongs/JSCoreKit.git", from: "0.1.6"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "JSMediaBrowser",
            dependencies: [],
            path: "Sources/Core",
        ),
        .target(
            name: "MediaView",
            dependencies: ["JSMediaBrowser"],
            path: "Sources/MediaView/Basis",
        ),
        .target(
            name: "MediaImage",
            dependencies: ["MediaView"],
            path: "Sources/MediaView/Image",
        ),
        .target(
            name: "MediaImageForSDWebImage",
            dependencies: ["MediaImage", "SDWebImage"],
            path: "Sources/MediaView/Image/SDWebImage",
        ),
    ]
)
