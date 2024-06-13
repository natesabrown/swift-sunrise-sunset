// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "swift-sunrise-sunset",
    products: [
        .library(
            name: "SwiftSunriseSunset",
            targets: ["SwiftSunriseSunset"]),
    ],
    dependencies: [
      .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "SwiftSunriseSunset"),
        .testTarget(
            name: "SwiftSunriseSunsetTests",
            dependencies: ["SwiftSunriseSunset"]),
    ]
)
