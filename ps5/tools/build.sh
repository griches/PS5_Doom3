#!/usr/bin/env bash
# Doom 3 BFG for the PlayStation 5 - build the game into dist/<TITLE_ID>/.
#
#   ps5/tools/build.sh [ninja arguments]
#
# Applies the console's patch to vendor/RBDOOM-3-BFG (tools/setup-source.sh),
# configures it with the payload SDK's CMake toolchain (once) and
# ps5/cmake/ps5-game.cmake, which gives it SDL2 with the console's drivers,
# openal-soft, and the title's link (tools/link-title.sh). The title folder
# gets eboot.bin, sce_sys/, the licences and RBDoom3BFG's own base/ files;
# tools/shaders.sh adds the shaders. No game data: that is yours (README).
#
#   PS5_BUILD_DIR    the build tree (default build/game; the Linux VM's own disk
#                    is several times faster than the shared folder)
#   PS5_VULKAN_DIR   the PS5_Vulkan checkout (default ../PS5_Vulkan)
#
# SPDX-License-Identifier: GPL-3.0-or-later
set -euo pipefail

ps5=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
root=$(dirname "$ps5")
vulkan=$(cd -- "${PS5_VULKAN_DIR:-$root/../PS5_Vulkan}" && pwd)
bash "$ps5/tools/setup-source.sh"
sdl=$(bash "$ps5/tools/setup-sdl.sh")
openal=$(bash "$ps5/tools/setup-openal.sh")
sdk=$(bash "$ps5/tools/setup-sdk.sh")
build=${PS5_BUILD_DIR:-$root/build/game}
ninja=$(command -v ninja || echo "$HOME/.local/bin/ninja")
export PS5_CLANG=${PS5_CLANG:-$(command -v clang || true)}

if [[ ! -f $build/build.ninja ]]; then
    mkdir -p "$build"
    cmake -S "$root/vendor/RBDOOM-3-BFG/neo" -B "$build" -G Ninja -DCMAKE_MAKE_PROGRAM="$ninja" \
        -DCMAKE_TOOLCHAIN_FILE="$sdk/toolchain/prospero.cmake" \
        -DCMAKE_PROJECT_RBDoom3BFG_INCLUDE="$ps5/cmake/ps5-game.cmake" \
        -DPS5_PORT_DIR="$root" -DPS5_VULKAN_DIR="$vulkan" -DSDL_DIR="$sdl" -DOPENAL_DIR="$openal" -DISPC_PREBUILT_DIR="$root/build/ispc" \
        -DCMAKE_BUILD_TYPE=Release -DCMAKE_VERBOSE_MAKEFILE=OFF > "$build/configure.log" 2>&1 \
        || { tail -60 "$build/configure.log" >&2; exit 1; }
fi
[[ -f $root/build/ispc/kernel.o ]] || { echo "no build/ispc/kernel.o: run ps5/tools/ispc-kernel.sh on the Mac (vm.sh build does)" >&2; exit 2; }
"$ninja" -C "$build" "${@:-RBDoom3BFG}"

# The title's name and art, as this tree has them (the link copies them too, but
# only when something relinks), and RBDoom3BFG's own base/ files (configs,
# materials, its textures), which go beside the game's data, and the port's
# own (ps5/base)
title_id=$(python3 -c 'import json,sys; print(json.load(open(sys.argv[1]))["titleId"])' "$ps5/sce_sys/param.json")
app="${PS5_DIST_DIR:-$root/dist}/$title_id"
if [[ -d $app/sce_sys ]]; then
    for asset in param.json icon0.png pic0.dds pic1.dds; do
        [[ -f $ps5/sce_sys/$asset ]] && cp "$ps5/sce_sys/$asset" "$app/sce_sys/"
    done
    mkdir -p "$app/base"
    rsync -a --exclude '_tb/' --exclude '*.bat' "$root/vendor/RBDOOM-3-BFG/base/" "$app/base/"
    # and the port's own (ps5/base: material fixes)
    rsync -a "$ps5/base/" "$app/base/"
fi
