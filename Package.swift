// swift-tools-version: 5.6
import PackageDescription

let package = Package(
  name: "Tetris",
  platforms: [
    .macOS(.v11)
  ],
  targets: [
    .executableTarget(
      name: "Tetris",
      path: "src"
    ),
    .testTarget(
      name: "TetrisTests",
      dependencies: [
        "Tetris"
      ],
      path: "test"
    )
  ]
)
