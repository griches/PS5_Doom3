#!/usr/bin/env bash
# Doom 3 BFG for the PlayStation 5 - DXC, the HLSL compiler, for the build host.
#
#   ps5/tools/setup-dxc.sh       build it into ~/ps5/dxc (once a release), print dxc's path
#
# RBDoom3BFG's shaders are HLSL, compiled to SPIR-V ahead of time (by its
# ShaderMake, with DXC) into base/renderprogs2/spirv: data the title loads, the
# same for every GPU. Microsoft publishes DXC for x86-64 Linux and Windows only,
# and the VM is arm64, so it is built here from its release tag. It runs on the
# build host only; nothing of it goes into the title.
#
# SPDX-License-Identifier: GPL-3.0-or-later
set -euo pipefail
tag=v1.9.2609
home=${PS5_DXC_HOME:-$HOME/ps5/dxc}
src="$home/src" build="$home/build-$tag"
dxc="$build/bin/dxc"

if [[ ! -x $dxc ]]; then
    {
        if [[ ! -d $src/.git ]]; then
            git clone -q --depth 1 -b "$tag" --recurse-submodules --shallow-submodules \
                https://github.com/microsoft/DirectXShaderCompiler.git "$src"
        fi
        mkdir -p "$build"
        cmake -S "$src" -B "$build" -G Ninja -C "$src/cmake/caches/PredefinedParams.cmake" \
            -DCMAKE_BUILD_TYPE=Release -DLLVM_ENABLE_ASSERTIONS=OFF \
            -DHLSL_INCLUDE_TESTS=OFF -DLLVM_INCLUDE_TESTS=OFF -DCLANG_INCLUDE_TESTS=OFF \
            -DSPIRV_BUILD_TESTS=OFF -DENABLE_SPIRV_CODEGEN=ON -DLLVM_TARGETS_TO_BUILD=None
        ninja -C "$build" dxc
    } >&2
fi
echo "$dxc"
