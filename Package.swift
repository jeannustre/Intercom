// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Intercom",
    platforms: [
        .watchOS(.v7), .iOS(.v15)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "IntercomPhone",
            targets: [
                "IntercomUtils",
                "IntercomPhone"]),
        .library(
            name: "IntercomWatch",
            targets: [
                "IntercomUtils",
                "IntercomWatch"]),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "IntercomUtils",
            path: "Sources/IntercomUtils"
        ),
        .target(
            name: "IntercomPhone",
            dependencies: ["IntercomUtils"],
            path: "Sources/IntercomPhone"
        ),
        .target(
            name: "IntercomWatch",
            dependencies: ["IntercomUtils"],
            path: "Sources/IntercomWatch"
        )
//        .testTarget(
//            name: "IntercomTests",
//            dependencies: ["IntercomPhone", "IntercomWatch"]),
    ]
)
