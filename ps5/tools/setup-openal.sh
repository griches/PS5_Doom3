#!/usr/bin/env bash
# Doom 3 BFG for the PlayStation 5 - openal-soft at a pinned release.
#
#   ps5/tools/setup-openal.sh       fetch it into .deps/openal-soft (once a release), print the path
#
# RBDoom3BFG plays its sound through OpenAL on every system but Windows.
# openal-soft is built into the title (ps5/cmake/ps5-game.cmake), static, with
# SDL2 for its only backend: SDL2's audio is the console's (ps5/sdl/SDL_ps5audio.c).
#
# SPDX-License-Identifier: GPL-3.0-or-later
set -euo pipefail
root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)
openal="$root/.deps/openal-soft"
tag=1.24.3

if [[ $(git -C "$openal" describe --tags --exact-match 2>/dev/null) != "$tag" ]]; then
    {
        rm -rf -- "$openal"
        git clone -q --depth 1 -b "$tag" https://github.com/kcat/openal-soft.git "$openal"
    } >&2
fi
echo "$openal"
