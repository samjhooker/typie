// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "typie",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "typie", targets: ["Typie"])
    ],
    dependencies: [
        .package(url: "https://github.com/FluidInference/FluidAudio.git", from: "0.15.0")
    ],
    targets: [
        .executableTarget(
            name: "Typie",
            dependencies: [
                .product(name: "FluidAudio", package: "FluidAudio")
            ],
            path: "Sources/Typie",
            resources: [
                .process("Resources")
            ]
        )
    ]
)
