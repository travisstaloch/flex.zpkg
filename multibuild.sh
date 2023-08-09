#!/bin/sh

targets="x86_64-macos aarch64-macos" # x86_64-windows-gnu aarch64-windows-gnu

for arch in x86_64 aarch64; do
    for abi in gnu musl; do
        targets="${targets} ${arch}-linux-${abi}"
    done
done

for target in ${targets}; do
    echo "Building for ${target}..."
    zig-0.11.0 build "-Dtarget=${target}" || exit 1
done
