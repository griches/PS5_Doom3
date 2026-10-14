#!/usr/bin/env bash
# Doom 3 BFG for the PlayStation 5 - pack the built title folder as a release archive.
#
#   ps5/tools/package-release.sh VERSION      (through tools/vm.sh package-release 1.0)
#
# Writes dist/Doom3BFG-PS5-vVERSION.zip: the title folder dist/<TITLE_ID>/ as the
# console takes it (eboot.bin, sce_sys/, sce_module/, base/ with the title's
# shaders, configs and material fixes, licenses/), with SOURCE.txt beside
# eboot.bin naming the revision of every part the build linked and the licences
# it is offered under. No game data, RBDoom3BFG data pack, save or setting goes
# in, and it refuses if one is in the folder.
#
# After the Ghostship port's package-release.sh.
# SPDX-License-Identifier: GPL-3.0-or-later
set -euo pipefail
version=${1:?usage: package-release.sh VERSION}
ps5=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
root=$(dirname "$ps5")
vulkan=$(cd -- "${PS5_VULKAN_DIR:-$root/../PS5_Vulkan}" && pwd)
game="$root/vendor/RBDOOM-3-BFG"
title_id=$(python3 -c 'import json,sys; print(json.load(open(sys.argv[1]))["titleId"])' "$ps5/sce_sys/param.json")
app="$root/dist/$title_id"
for file in eboot.bin sce_sys/param.json sce_sys/icon0.png sce_sys/pic0.dds sce_sys/pic1.dds sce_module/libc.prx \
        base/default.cfg base/materials/_ps5_flashlight.mtr licenses/RBDoom3BFG-LICENSE.md; do
    [[ -e $app/$file ]] || { echo "missing $app/$file: run build.sh first" >&2; exit 2; }
done
shaders=$(find "$app/base/renderprogs2/spirv" -name '*.bin' 2>/dev/null | wc -l)
[[ $shaders -gt 100 ]] || { echo "the title has $shaders shaders: run shaders.sh first" >&2; exit 2; }
stray=$(find "$app" \( -name '*.resources' -o -name '*.crc' -o -name '_rbdoom_*.pk4' -o -iname '*.wad' -o -name userdata \
    -o -name 'env.txt' -o -name 'args.txt' -o -name 'D3BFGConfig.cfg' -o -name 'devloop-*' \) -print -quit)
[[ -z $stray ]] || { echo "game data, a save or a setting in the title folder ($stray): a release never carries it" >&2; exit 2; }
# the title folder's art and name are this commit's
for file in param.json icon0.png pic0.dds pic1.dds; do
    cmp -s "$ps5/sce_sys/$file" "$app/sce_sys/$file" || { echo "dist's sce_sys/$file is not ps5/sce_sys/$file: run build.sh" >&2; exit 2; }
done
# the submodule's working tree carries the console's patch: that is not a change here
[[ -z $(git -C "$root" status --porcelain --ignore-submodules=dirty) ]] ||
    { echo "uncommitted changes: a release is built from a commit" >&2; exit 2; }
provenance="$vulkan/.deps/native/radv-release/PROVENANCE.txt"
cp "$root/licenses/GPL-3.0.txt" "$root/licenses/MIT.txt" "$root/licenses/Zlib.txt" "$app/licenses/"
cp "$root/LICENSING.md" "$app/licenses/LICENSING.md"
cp "$game/neo/extern/nvrhi/LICENSE.txt" "$app/licenses/NVRHI-LICENSE.txt"
cp "$game/neo/extern/ShaderMake/LICENSE.txt" "$app/licenses/ShaderMake-LICENSE.txt"
cat > "$app/SOURCE.txt" <<SOURCE
Doom 3 BFG for PlayStation 5, version $version
An unofficial homebrew build of RBDoom3BFG, free of charge. Not affiliated with
Robert Beckebans' RBDoom3BFG project, id Software, ZeniMax, Bethesda or Sony
Interactive Entertainment.

This is a MODIFIED build of RBDoom3BFG: ps5/patches/rbdoom3bfg.patch is applied
to it (the console's paths, Vulkan from the linked RADV driver, start-up
arguments, restarting, a late controller, frame timings), and it is built with
SDL2, openal-soft and this port's console drivers. base/renderprogs2 holds the
engine's shaders compiled to SPIR-V; base/materials/_ps5_flashlight.mtr replaces
the flashlight beam's materials.

Licence. The title as built is under the GNU General Public License, version 3
(licenses/GPL-3.0.txt), with id Software's additional terms and the exceptions
in licenses/RBDoom3BFG-LICENSE_EXCEPTIONS.md; it links MIT, Zlib and LGPL parts.
licenses/LICENSING.md lists them. All of its source is at the revisions below.

The port (patch, SDL2 drivers, platform layer, build)
  $(git -C "$root" remote get-url origin 2>/dev/null || echo "this repository")
  $(git -C "$root" rev-parse HEAD)
The engine: RBDOOM-3-BFG (GPL-3.0), with ps5/patches/rbdoom3bfg.patch
  https://github.com/RobertBeckebans/RBDOOM-3-BFG
  $(git -C "$game" rev-parse HEAD) ($(git -C "$game" describe --tags 2>/dev/null))
  NVRHI $(git -C "$game/neo/extern/nvrhi" rev-parse HEAD), ShaderMake $(git -C "$game/neo/extern/ShaderMake" rev-parse HEAD) (MIT)
openal-soft (LGPL-2.0-or-later)
  https://github.com/kcat/openal-soft
  $(sed -n 's/^tag=//p' "$ps5/tools/setup-openal.sh")
SDL2 (Zlib), with ps5/patches/sdl.patch and the drivers in ps5/sdl
  https://github.com/libsdl-org/SDL
  $(sed -n 's/^tag=//p' "$ps5/tools/setup-sdl.sh")
The Vulkan driver: RADV, from PS5_Mesa (MIT)
  https://github.com/mihawk-99/PS5_Mesa
  $(sed -n 's/^revision: //p' "$provenance")
The link recipe, CRT, libc.prx and packaging: PS5_Vulkan (GPL-3.0)
  https://github.com/mihawk-99/PS5_Vulkan
  $(git -C "$vulkan" rev-parse HEAD)
The platform layer and SDK: PS5_PayloadSDK (GPL-3.0), over ps5-payload-dev/sdk
  https://github.com/mihawk-99/PS5_PayloadSDK
  title: $(sed -n 's/^sdk_revision=//p' "$ps5/tools/setup-sdk.sh")
  RADV archive: $(sed -n 's/^sdk: //p' "$provenance")
Shaders compiled with DXC $(sed -n 's/^tag=//p' "$ps5/tools/setup-dxc.sh"); the BC6H kernel with ISPC $(sed -n 's/^tag=//p' "$ps5/tools/ispc-kernel.sh").
Compiler: $(${PS5_CLANG:-clang} --version | head -1)

No game data is included. Doom 3 BFG Edition belongs to id Software; this title
does nothing without the base folder of your own copy, and RBDoom3BFG's three
_rbdoom_*.pk4 data packs, in base/ (see the README). The pictures in sce_sys/
were made for this port and contain nothing of id Software's.

eboot.bin sha256: $(sha256sum "$app/eboot.bin" | cut -d' ' -f1)
SOURCE
out="$root/dist/Doom3BFG-PS5-v$version.zip"
rm -f "$out"
(cd "$root/dist" && zip -q -r -X "$out" "$title_id" -x '*/.DS_Store')
printf '==> %s (%s bytes)\n' "$out" "$(stat -c %s "$out")"
unzip -l "$out" | tail -n +4 | awk '{print "    " $1, $4}' | grep -v "/renderprogs2/\|/base/" | head -30
