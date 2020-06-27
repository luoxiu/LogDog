// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "LogDog",
    products: [
        .library(name: "LogDog", targets: ["LogDog"]),
        .executable(name: "app", targets: ["app"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-log.git", from: "1.0.0"),
        .package(url: "https://github.com/luoxiu/Chalk", from: "0.0.1"),
        .package(url: "https://github.com/luoxiu/ProcessStartTime.git", from: "0.0.1"),
        .package(url: "https://github.com/luoxiu/Backtrace.git", from: "0.1.0"),
        .package(url: "https://github.com/1024jp/GzipSwift", from: "5.1.1"),
        .package(url: "https://github.com/krzyzanowskim/CryptoSwift.git", from: "1.3.1"),
    ],
    targets: [
        .target(name: "app", dependencies: ["LogDog", "Backtrace"]),
        .target(name: "LogDog", dependencies: [
            "Logging",
            "ProcessStartTime",
            "Chalk",
            "Backtrace",
            "Gzip",
            "CryptoSwift"
        ]),
        .testTarget(name: "LogDogTests", dependencies: ["LogDog"]),
    ]
)
