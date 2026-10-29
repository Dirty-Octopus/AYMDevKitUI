// swift-tools-version: 5.9
import PackageDescription

/// AYMDevKitUI — Andy Yu's macOS Development Kit for UI.
///
/// Products:
///   • `AYMDevKitUI` — canonical module.
///   • `AYMDKUI`     — short alias that re-exports the canonical module.
///   • `AYMDevKitUIDemo` — component gallery and panel previews.
let package = Package(
    name: "AYMDevKitUI",
    defaultLocalization: "en",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "AYMDevKitUI", targets: ["AYMDevKitUI"]),
        .library(name: "AYMDKUI", targets: ["AYMDKUI"]),
        .executable(name: "AYMDevKitUIDemo", targets: ["AYMDevKitUIDemo"])
    ],
    targets: [
        .target(
            name: "AYMDevKitUI",
            path: "Sources/AYMDevKitUI",
            resources: [.process("Resources")]
        ),
        .target(
            name: "AYMDKUI",
            dependencies: ["AYMDevKitUI"],
            path: "Sources/AYMDKUI"
        ),
        .executableTarget(
            name: "AYMDevKitUIDemo",
            dependencies: ["AYMDevKitUI"],
            path: "Sources/AYMDevKitUIDemo"
        ),
        .testTarget(
            name: "AYMDevKitUITests",
            dependencies: ["AYMDevKitUI", "AYMDKUI"],
            path: "Tests/AYMDevKitUITests"
        )
    ]
)
