#!/usr/bin/env bash
# Doom 3 BFG for the PlayStation 5 - the shaders, as SPIR-V, into the title folder.
#
#   ps5/tools/shaders.sh
#
# RBDoom3BFG's shaders are HLSL (vendor/RBDOOM-3-BFG/neo/shaders), compiled
# ahead of time by its ShaderMake with DXC into base/renderprogs2/spirv, which
# the game loads at start-up. Both run on the build host: ShaderMake is built
# here for it (not for the console), DXC by tools/setup-dxc.sh. The flags are
# the ones RBDoom3BFG's own build gives ShaderMake for Vulkan (neo/compileshaders.cmake).
#
# SPDX-License-Identifier: GPL-3.0-or-later
set -euo pipefail
ps5=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
root=$(dirname "$ps5")
neo="$root/vendor/RBDOOM-3-BFG/neo"
bash "$ps5/tools/setup-source.sh"
dxc=$(bash "$ps5/tools/setup-dxc.sh")
host="$(dirname "${PS5_BUILD_DIR:-$root/build/game}")/shadermake-host"
ninja=$(command -v ninja || echo "$HOME/.local/bin/ninja")

if [[ ! -f $host/build.ninja ]]; then
    cmake -S "$neo/extern/ShaderMake" -B "$host" -G Ninja -DCMAKE_MAKE_PROGRAM="$ninja" \
        -DCMAKE_BUILD_TYPE=Release -DSHADERMAKE_FIND_FXC=OFF -DSHADERMAKE_FIND_DXC=OFF \
        -DSHADERMAKE_FIND_DXC_SPIRV=OFF -DSHADERMAKE_BIN_OUTPUT_PATH="$host/bin" > "$host.configure.log" 2>&1 \
        || { tail -30 "$host.configure.log" >&2; exit 1; }
fi
"$ninja" -C "$host" ShaderMake > /dev/null
shadermake="$host/bin/Release/ShaderMake"

title_id=$(python3 -c 'import json,sys; print(json.load(open(sys.argv[1]))["titleId"])' "$ps5/sce_sys/param.json")
out="${PS5_DIST_DIR:-$root/dist}/$title_id/base/renderprogs2/spirv"
mkdir -p "$out"
"$shadermake" --config="$neo/shaders/shaders.cfg" --out="$out" --platform=SPIRV --binaryBlob \
    --outputExt=.bin --retryCount=20 -I "$neo/shaders" -D SPIRV \
    --vulkanVersion=1.2 --shaderModel=6_0 -O3 --WX --matrixRowMajor \
    --tRegShift=0 --sRegShift=128 --bRegShift=256 --uRegShift=384 \
    --compiler="$dxc"
printf '==> %s: %s shaders\n' "$out" "$(find "$out" -name '*.bin' | wc -l)"
