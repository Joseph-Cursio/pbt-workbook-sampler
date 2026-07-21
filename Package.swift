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
// The grader machinery (Core + Swift binding) is a shared, public package
// (`pbt-workbook-grader`), consumed by version — one source of truth, shared with
// the private product. It's infrastructure, not answer key: it carries no
// mutants, so it stays public.
//
// Engine-only: a submission imports just `PropertyBased` (inherited from the
// grader package's pin). The sampler doubles as proof the spine needs none of
// the kit.
let package = Package(
    name: "pbt-workbook-sampler",
    platforms: [.macOS(.v14)],
    products: [
        .executable(name: "pbt-workbook-sampler", targets: ["WorkbookRunner"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Joseph-Cursio/pbt-workbook-grader.git",
                 .upToNextMinor(from: "0.1.0")),
        .package(url: "https://github.com/x-sheep/swift-property-based.git",
                 .upToNextMinor(from: "1.2.0")),
    ],
    targets: [
        .target(
            name: "WorkbookCorpus",
            dependencies: [
                .product(name: "WorkbookGraderCore", package: "pbt-workbook-grader"),
            ]
        ),
        .testTarget(
            name: "WorkbookGraderSwiftTests",
            dependencies: [
                .product(name: "WorkbookGraderSwift", package: "pbt-workbook-grader"),
                "WorkbookCorpus",
                "WorkbookExercises",
                .product(name: "PropertyBased", package: "swift-property-based"),
            ]
        ),
        .target(
            name: "WorkbookExercises",
            dependencies: [
                .product(name: "WorkbookGraderSwift", package: "pbt-workbook-grader"),
                "WorkbookCorpus",
                .product(name: "PropertyBased", package: "swift-property-based"),
            ]
        ),
        .executableTarget(
            name: "WorkbookRunner",
            dependencies: [
                "WorkbookExercises",
                .product(name: "WorkbookGraderSwift", package: "pbt-workbook-grader"),
            ]
        ),
    ]
)
