# Licences

The repository as a whole is offered under the GNU General Public License,
version 3 ([`LICENSE`](LICENSE)), the licence of the engine it ports. Its files
come from projects under several licences, each compatible with that; every
source file names its own in its header, and may also be used under that
licence alone.

| Path | Licence | Text |
| --- | --- | --- |
| `ps5/patches/rbdoom3bfg.patch` (the console's changes to RBDoom3BFG) | GPL-3.0, as RBDoom3BFG | [`LICENSE`](LICENSE) |
| `ps5/base/materials/_ps5_flashlight.mtr`, `ps5/include/`, `ps5/cmake/`, and the tools written for this port (`build.sh`, `shaders.sh`, `setup-dxc.sh`, `setup-openal.sh`, `ispc-kernel.sh`, `setup-source.sh`, `console-files.sh`, `vm.sh`, `ps5/art/make-title-art.sh`) | GPL-3.0-or-later | [`licenses/GPL-3.0.txt`](licenses/GPL-3.0.txt) |
| `ps5/tools/png-to-title-dds.py` (encoder from PS5 RetroArch, by Mihawk) | GPL-3.0-or-later | [`licenses/GPL-3.0.txt`](licenses/GPL-3.0.txt) |
| `ps5/src/platform.c`, `ps5/src/platform.h` and the tools taken from the PS5 Vulkan Template (by Mihawk): `link-title.sh`, `setup-sdk.sh`, `deploy.sh` | MIT | [`licenses/MIT.txt`](licenses/MIT.txt) |
| The rest of `ps5/src/`, `ps5/stubs/`, `cc-init-array.sh`, `run.sh` and `setup-sdl.sh` (from the PS5 Ghostship port) | MIT | [`licenses/MIT.txt`](licenses/MIT.txt) |
| `ps5/sdl/` (SDL2 drivers for the console) and `ps5/patches/sdl.patch` | Zlib, as SDL | [`licenses/Zlib.txt`](licenses/Zlib.txt) |

## What is built from elsewhere

Nothing below is stored in this repository; the build takes each from its own
project, under that project's licence.

| Part | Project | Licence |
| --- | --- | --- |
| The engine | [RBDOOM-3-BFG](https://github.com/RobertBeckebans/RBDOOM-3-BFG), from id Software's Doom 3 BFG Edition GPL source release | GPL-3.0 with id's additional terms; the code in its `LICENSE_EXCEPTIONS.md` is under its own terms |
| The renderer's graphics layer | NVIDIA's NVRHI and ShaderMake, as RBDoom3BFG carries them ([nvrhi](https://github.com/RobertBeckebans/nvrhi), [ShaderMake](https://github.com/RobertBeckebans/ShaderMake)) | MIT |
| The Vulkan driver | RADV, from [PS5_Mesa](https://github.com/mihawk-99/PS5_Mesa), through [PS5_Vulkan](https://github.com/mihawk-99/PS5_Vulkan) | MIT (Mesa); GPL-3.0 (PS5_Vulkan) |
| Sound | [openal-soft](https://github.com/kcat/openal-soft) | LGPL-2.0-or-later |
| Windowing, input and sound output | [SDL2](https://github.com/libsdl-org/SDL) | Zlib |
| The platform layer and SDK | [PS5_PayloadSDK](https://github.com/mihawk-99/PS5_PayloadSDK), a fork of ps5-payload-dev/sdk | GPL-3.0 |
| Build tools only (nothing of them is in the title) | [DXC](https://github.com/microsoft/DirectXShaderCompiler), [ISPC](https://github.com/ispc/ispc) | NCSA/LLVM; BSD-3-Clause |

## What is not covered

- **The game.** Doom 3, Resurrection of Evil, The Lost Mission and the classic
  Doom games, their data and everything in them belong to id Software and
  ZeniMax (Bethesda). None of it is in this repository, and no licence above
  covers it: the title plays your own copy of the BFG Edition's data.
- **RBDoom3BFG's data packs.** `_rbdoom_core.pk4`, `_rbdoom_blood.pk4` and
  `_rbdoom_global_illumination_data.pk4` come from RBDoom3BFG's own release and
  are not stored here.
- **Artwork.** `ps5/art/icon0-source.png` and `ps5/art/pic-source.png` (a
  research base on Mars under a red sky), and the `ps5/sce_sys/icon0.png`,
  `pic0.dds` and `pic1.dds` made from them, are the port's own: made for it by
  Gary Riches with an image generator. Nothing in them is from the game, and no
  licence above is claimed for them beyond their use with this port.
- **Trademarks.** "Doom", "Doom 3" and "id Software" are trademarks of id
  Software / ZeniMax Media. "PlayStation", "PS5" and "DualSense" are trademarks
  of Sony Interactive Entertainment. They are used here only to say what this
  software works with. This project is not affiliated with, endorsed or
  sponsored by any of them.
