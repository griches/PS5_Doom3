#!/usr/bin/env bash
# Doom 3 BFG for the PlayStation 5 - RBDoom3BFG's ISPC kernel, as an x86-64 object.
#
#   ps5/tools/ispc-kernel.sh       on macOS: build/ispc/kernel.o and kernel_ispc.h
#
# RBDoom3BFG's BC6H encoder (neo/libs/ispc_texcomp, used when it loads baked
# lighting) is ISPC source. ISPC's arm64 Linux release has no x86 backend, so
# the VM cannot compile it; its macOS release can. tools/vm.sh build runs this
# on the Mac first, and the title's build links the object it leaves
# (ISPC_PREBUILT_DIR, ps5/patches/rbdoom3bfg.patch), with upstream's own
# target (SSE4, x86-64, position independent).
#
# SPDX-License-Identifier: GPL-3.0-or-later
set -euo pipefail
root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)
tag=v1.32.0
case $(uname -s)-$(uname -m) in
Darwin-arm64) package=macOS.arm64 ;;
Darwin-x86_64) package=macOS.x86_64 ;;
Linux-x86_64) package=linux ;;
*) echo "ispc-kernel.sh: no ISPC release here with an x86 backend; run it on macOS" >&2; exit 2 ;;
esac
ispc="$root/.deps/ispc-$tag-$package/bin/ispc"
if [[ ! -x $ispc ]]; then
    mkdir -p "$root/.deps"
    curl -fsSL "https://github.com/ispc/ispc/releases/download/$tag/ispc-$tag-$package.tar.gz" | tar -xz -C "$root/.deps"
fi
source="$root/vendor/RBDOOM-3-BFG/neo/libs/ispc_texcomp/kernel.ispc"
out="$root/build/ispc"
mkdir -p "$out"
if [[ ! -f $out/kernel.o || $source -nt $out/kernel.o || $0 -nt $out/kernel.o ]]; then
    "$ispc" "$source" -o "$out/kernel.o" -h "$out/kernel_ispc.h" \
        --target=sse4-i32x4 --arch=x86-64 --target-os=linux --pic --woff
fi
