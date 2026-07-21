// swift-tools-version: 6.0
import PackageDescription

// Properties, Worked — PUBLIC SAMPLER.
//
// The free, engine-only slice of the auto-graded PBT lab: Warm-up + Set 1 only.
// This repo is public, so it contains NO secret mutants — the corpus here is the
// intended free sample, and the paid product's private grading corpora
// (Sets 2–10, the Capstone, and the harder mutants) live elsewhere and never
// appear here. See the private pbt-workbook repo and the book's
// planning/workbook-repo-topology.md.
//
// The grader machinery (Core + Swift binding) is deliberately public — it's
// infrastructure, not answer key. For the pilot it is vendored (copied) rather
// than shared via a package dependency; extracting a shared public grader
// package is post-validation work, like the corpus extraction.
//
// Engine-only: a submission imports just `PropertyBased`. The sampler doubles as
// proof the spine needs none of the kit.
let package = Package(
    name: "pbt-workbook-sampler",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "WorkbookGraderCore", targets: ["WorkbookGraderCore"]),
        .library(name: "WorkbookGraderSwift", targets: ["WorkbookGraderSwift"]),
        .executable(name: "pbt-workbook-sampler", targets: ["WorkbookRunner"]),
    ],
    dependencies: [
        .package(url: "https://github.com/x-sheep/swift-property-based.git",
                 .upToNextMinor(from: "1.2.0")),
    ],
    targets: [
        .target(name: "WorkbookGraderCore"),
        .testTarget(
            name: "WorkbookGraderCoreTests",
            dependencies: ["WorkbookGraderCore"]
        ),
        .target(
            name: "WorkbookCorpus",
            dependencies: ["WorkbookGraderCore"]
        ),
        .target(
            name: "WorkbookGraderSwift",
            dependencies: [
                "WorkbookGraderCore",
                .product(name: "PropertyBased", package: "swift-property-based"),
            ]
        ),
        .testTarget(
            name: "WorkbookGraderSwiftTests",
            dependencies: [
                "WorkbookGraderSwift",
                "WorkbookCorpus",
                "WorkbookExercises",
                .product(name: "PropertyBased", package: "swift-property-based"),
            ]
        ),
        .target(
            name: "WorkbookExercises",
            dependencies: [
                "WorkbookGraderSwift",
                "WorkbookCorpus",
                .product(name: "PropertyBased", package: "swift-property-based"),
            ]
        ),
        .executableTarget(
            name: "WorkbookRunner",
            dependencies: ["WorkbookExercises", "WorkbookGraderSwift"]
        ),
    ]
)
