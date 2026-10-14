#!/usr/bin/env bash
# Doom 3 BFG for the PlayStation 5 - the game's sources, with the console's changes.
#
#   ps5/tools/setup-source.sh          apply ps5/patches/rbdoom3bfg.patch
#   ps5/tools/setup-source.sh --save   write the tree's changes back to the patch
#
# vendor/RBDOOM-3-BFG is RBDoom3BFG at an upstream revision, with NVRHI and
# ShaderMake as its own submodules. What the console needs changed is kept here
# as a patch, not as a fork. A patch already applied is left alone, so this can
# run before every build. A build refuses to start over edits not yet saved.
#
# SPDX-License-Identifier: GPL-3.0-or-later
set -euo pipefail
root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)
game="$root/vendor/RBDOOM-3-BFG"
patch="$root/ps5/patches/rbdoom3bfg.patch"
[[ -f $game/neo/extern/nvrhi/CMakeLists.txt ]] || git -C "$game" submodule update --init --recursive

if [[ ${1:-} == --save ]]; then
    # new files too: plain git diff leaves out what git does not track yet
    git -C "$game" add --intent-to-add -A -- neo
    git -C "$game" diff --ignore-submodules -- neo > "$patch"
    git -C "$game" reset -q
    exit 0
fi
[[ -s $patch ]] || exit 0
if git -C "$game" apply --reverse --check "$patch" 2>/dev/null; then
    # applied already: refuse edits made since that are not in the patch
    saved=$(mktemp)
    git -C "$game" add --intent-to-add -A -- neo
    git -C "$game" diff --ignore-submodules -- neo > "$saved"
    git -C "$game" reset -q
    if ! cmp -s "$saved" "$patch"; then
        rm -f "$saved"
        echo "setup-source.sh: vendor/RBDOOM-3-BFG has edits not in the patch: run ps5/tools/setup-source.sh --save" >&2
        exit 2
    fi
    rm -f "$saved"
    exit 0
fi
git -C "$game" apply --check "$patch" || {
    echo "setup-source.sh: rbdoom3bfg.patch does not apply to $game (a different upstream revision?)" >&2
    exit 2
}
git -C "$game" apply --whitespace=nowarn "$patch"
echo "setup-source.sh: applied rbdoom3bfg.patch" >&2
