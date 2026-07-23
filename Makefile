# Properties, Worked — build & grade.
#
# `make grade` builds and runs the reader-facing grader. It resolves Swift
# Testing on a fallback path, which the executable needs at launch: the
# `swift-property-based` engine links Swift Testing, so anything that links the
# engine inherits that load-time dependency. (Under `swift test` this is already
# on the path — that's why `make test` needs no wrapper.)
#
# Two layouts are in the wild and we set a fallback for both, because which one
# a reader has depends only on their toolchain:
#   • framework — `Testing.framework` under the macOS platform's Developer
#     frameworks dir (Xcode 16.3+ / Swift 6.2). Needs FRAMEWORK_PATH; a library
#     path cannot satisfy an `@rpath/Testing.framework/...` load.
#   • dylib — `libTesting.dylib` under the toolchain's own `macosx/testing`.
# Both are fallbacks, so a stale one is simply never consulted.

# The active toolchain's runtime resource dir, then its Testing subdir.
RESOURCE_DIR  := $(shell swiftc -print-target-info | grep -o '"runtimeResourcePath"[^,]*' | sed 's/.*: *"//;s/"//')
TESTING_DIR   := $(RESOURCE_DIR)/macosx/testing
FRAMEWORK_DIR := $(shell xcrun --show-sdk-platform-path 2>/dev/null)/Developer/Library/Frameworks
BIN_DIR       := $(shell swift build --product pbt-workbook-sampler --show-bin-path)

.PHONY: grade build test clean

grade: build
	@DYLD_FALLBACK_FRAMEWORK_PATH="$(FRAMEWORK_DIR)" \
	 DYLD_FALLBACK_LIBRARY_PATH="$(TESTING_DIR)" \
	 "$(BIN_DIR)/pbt-workbook-sampler"

build:
	@swift build --product pbt-workbook-sampler

test:
	@swift test

clean:
	@swift package clean
