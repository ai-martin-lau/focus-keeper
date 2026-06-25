// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "QuitOtherApps",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "QuitOtherApps", targets: ["QuitOtherApps"])
    ],
    targets: [
        .executableTarget(name: "QuitOtherApps")
    ],
    swiftLanguageVersions: [.v5]
)
