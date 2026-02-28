set shell := ["cmd", "/c"]

default:
    @just --list

test:
    cls && zig build test --summary all

fuzz:
    cls && zig build fuzz -- --full

fuzz-test:
    cls && zig build fuzz-test --summary all

fuzz-smoke:
    cls && zig build fuzz -- --smoke

fuzz-stress:
    cls && zig build fuzz -- --stress

build:
    cls && zig build

examples:
    cls && zig build examples

example name="basic":
    cls && just clean && zig build examples && zig-out\bin\{{name}}.exe

fmt:
    cls && zig fmt src/ examples/ testing/

clean:
    cls
    if exist zig-out rd /s /q zig-out
    if exist .zig-cache rd /s /q .zig-cache

release:
    cls && zig build -Doptimize=ReleaseSafe
