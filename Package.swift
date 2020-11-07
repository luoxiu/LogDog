// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "LogDog",
    products: [
        .library(name: "LogDog", targets: ["LogDog"]),
        .executable(name: "LogDogApp", targets: ["LogDogApp"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-log.git", from: "1.0.0"),
    ],
    targets: [
        .target(name: "LogDogApp", dependencies: ["LogDog"]),
        .target(name: "LogDog", dependencies: [
            .product(name: "Logging", package: "swift-log")
        ]),
        .testTarget(name: "LogDogTests", dependencies: ["LogDog"]),
    ]
)
