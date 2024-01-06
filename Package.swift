// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "Toast",
    platforms: [
        .iOS(.v12),
    ],
    products: [
        .library(
            name: "Toast",
            targets: ["Toast"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Toast",
            dependencies: [],
            path: "Toast",
            resources: [
                .copy("Resources/PrivacyInfo.xcprivacy")
            ])
    ],
    swiftLanguageVersions: [.v5]
)