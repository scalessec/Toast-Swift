// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "Toast",
    platforms: [
        .iOS(.v10),
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
                .copy("Toast/Resources/PrivacyInfo.xcprivacy")
            ])
    ],
    swiftLanguageVersions: [.v5]
)