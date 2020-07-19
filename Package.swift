// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "LogDog",
    products: [
        .library(name: "LogDog", targets: ["LogDog"]),
        .executable(name: "LogDogApp", targets: ["LogDogApp"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-log.git", from: "1.0.0"),
        .package(url: "https://github.com/luoxiu/Chalk", from: "0.1.0"),
        .package(url: "https://github.com/luoxiu/ProcessStartTime.git", from: "0.0.1"),
        .package(url: "https://github.com/1024jp/GzipSwift", from: "5.1.1"),
        .package(url: "https://github.com/krzyzanowskim/CryptoSwift.git", from: "1.3.1"),
        .package(url: "https://github.com/nvzqz/FileKit.git", from: "6.0.0")
    ],
    targets: [
        .target(name: "LogDogApp", dependencies: ["LogDog"]),
        .target(name: "LogDog", dependencies: [
            "Logging",
            "ProcessStartTime",
            "Chalk",
            "Gzip",
            "CryptoSwift",
            "FileKit"
        ]),
        .testTarget(name: "LogDogTests", dependencies: ["LogDog"]),
    ]
)
