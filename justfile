set shell := ["cmd", "/c"]

# Default recipe
default:
    @just --list

# Run unit tests
test:
    cls && zig build test --summary all

# Build the library
build:
    cls && zig build

# Build all examples
examples:
    cls && zig build examples

# Build and run a specific example
example name="basic":
    cls && just clean && zig build examples && zig-out\bin\{{name}}.exe

# Format all source files
fmt:
    cls && zig fmt src/ examples/

# Clean build artifacts
clean:
    cls
    if exist zig-out rd /s /q zig-out
    if exist .zig-cache rd /s /q .zig-cache

# Build in release mode
release:
    cls && zig build -Doptimize=ReleaseSafe
