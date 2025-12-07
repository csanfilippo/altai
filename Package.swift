// swift-tools-version: 6.0

#if canImport(Darwin)
let privacyManifestExclude: [String] = []
let privacyManifestResource: [PackageDescription.Resource] = [.copy("PrivacyInfo.xcprivacy")]
#else
let privacyManifestExclude: [String] = ["PrivacyInfo.xcprivacy"]
let privacyManifestResource: [PackageDescription.Resource] = []
#endif

import PackageDescription

let package = Package(
    name: "altai",
    platforms: [.iOS(.v13), .macOS(.v13), .watchOS(.v8), .tvOS(.v13)],
    products: [
        .library(
            name: "altai",
            targets: ["altai"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.4.0")
    ],
    targets: [
        .target(
            name: "altai",
            exclude: privacyManifestExclude,
            resources: privacyManifestResource,
        ),
        .testTarget(
            name: "altaiTests",
            dependencies: ["altai"]
        ),
    ]
)
