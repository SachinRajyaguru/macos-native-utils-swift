// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "macos-native-utils-swift",
    products: [
        .executable(
            name: "macapps",
            targets: ["MacOSNativeUtils"]
        ),
        .library(
            name: "MacOSNativeUtils",
            targets: ["MacOSNativeUtils"]
        ),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "MacOSNativeUtils",
            dependencies: []
        ),
        .testTarget(
            name: "MacOSNativeUtilsTests",
            dependencies: ["MacOSNativeUtils"]
        ),
    ]
)
