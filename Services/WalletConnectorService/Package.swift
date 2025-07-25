// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "WalletConnectorService",
    platforms: [.iOS(.v17), .macOS(.v15)],
    products: [
        .library(
            name: "WalletConnectorService",
            targets: ["WalletConnectorService"]
        ),
        .library(
            name: "WalletConnectorServiceTestKit",
            targets: ["WalletConnectorServiceTestKit"]
        )
    ],
    dependencies: [
        .package(name: "Primitives", path: "../../Packages/Primitives"),
        .package(url: "https://github.com/gemwalletcom/reown-swift.git", revision: "f061a10"),
        .package(url: "https://github.com/daltoniam/Starscream.git", exact: Version(stringLiteral: "3.1.2")),
        .package(name: "Gemstone", path: "../../Packages/Gemstone"),
        .package(name: "GemstonePrimitives", path: "../../Packages/GemstonePrimitives"),
    ],
    targets: [
        .target(
            name: "WalletConnectorService",
            dependencies: [
                "Primitives",
                "Gemstone",
                "GemstonePrimitives",
                .product(
                    name: "WalletConnect",
                    package: "reown-swift"
                ),
                .product(
                    name: "ReownWalletKit",
                    package: "reown-swift"
                ),
                .product(name: "Starscream", package: "Starscream"),
            ],
            path: "Sources"
        ),
        .target(
            name: "WalletConnectorServiceTestKit",
            dependencies: ["WalletConnectorService"],
            path: "TestKit"
        ),
        .testTarget(
            name: "WalletConnectorServiceTests",
            dependencies: ["WalletConnectorService"]
        ),
    ]
)
