# Properties, Worked — build & grade.
#
# `make grade` builds and runs the reader-facing grader. It resolves the Swift
# runtime's `libTesting.dylib` on a fallback path, which the executable needs at
# launch: the `swift-property-based` engine links Swift Testing, so anything that
# links the engine inherits that load-time dependency. (Under `swift test` this
# is already on the path — that's why `make test` needs no wrapper.)

# The active toolchain's runtime resource dir, then its Testing subdir.
RESOURCE_DIR := $(shell swiftc -print-target-info | grep -o '"runtimeResourcePath"[^,]*' | sed 's/.*: *"//;s/"//')
TESTING_DIR  := $(RESOURCE_DIR)/macosx/testing
BIN_DIR      := $(shell swift build --product pbt-workbook-sampler --show-bin-path)

.PHONY: grade build test clean

grade: build
	@DYLD_FALLBACK_LIBRARY_PATH="$(TESTING_DIR)" "$(BIN_DIR)/pbt-workbook-sampler"

build:
	@swift build --product pbt-workbook-sampler

test:
	@swift test

clean:
	@swift package clean
