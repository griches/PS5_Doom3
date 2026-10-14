# Doom 3 BFG for PlayStation 5

[![stars](https://img.shields.io/github/stars/griches/PS5_Doom3?style=flat)](https://github.com/griches/PS5_Doom3/stargazers)
[![release](https://img.shields.io/github/v/release/griches/PS5_Doom3)](https://github.com/griches/PS5_Doom3/releases/latest)
[![licence](https://img.shields.io/badge/licence-GPL--3.0-blue)](LICENSING.md)

A PS5 homebrew port of **[RBDOOM-3-BFG](https://github.com/RobertBeckebans/RBDOOM-3-BFG)**,
Robert Beckebans' modern engine for Doom 3 BFG Edition.

> ## The engine is RBDoom3BFG's
>
> [RBDOOM-3-BFG](https://github.com/RobertBeckebans/RBDOOM-3-BFG), by Robert
> Beckebans and its contributors, is what makes this possible: id Software's
> Doom 3 BFG Edition source, brought up to date with a Vulkan renderer (through
> NVIDIA's NVRHI), physically based lighting, baked global illumination, shadow
> maps, SSAO, TAA and a great deal more. This repository adds only what a PS5
> needs on top of it: a patch of about 150 lines, the console's drivers and
> a build recipe. If you enjoy this, the thanks belong there. **Please star and
> support [RobertBeckebans/RBDOOM-3-BFG](https://github.com/RobertBeckebans/RBDOOM-3-BFG).**

The game runs natively on the console at 3840x2160, drawn with Vulkan through
RADV (Mesa's AMD driver, ported to the PS5). It plays the BFG Edition's three
campaigns, Doom 3, Resurrection of Evil and The Lost Mission, and has the
classic Doom and Doom II built in.

It needs a PS5 that already runs homebrew, and **your own copy of Doom 3 BFG
Edition's data**. No game data, id Software or Bethesda artwork, Sony software
or keys are included.

This is an unofficial port. It is not part of RBDoom3BFG and is not supported
by it: **please do not take PS5 problems to the RBDoom3BFG project.** Report them
[here](https://github.com/griches/PS5_Doom3/issues).

## This is an early release: 1.0

**It is not fully tested.** It was brought up on one console on 2026-10-14 and
played through the start of the Doom 3 campaign. Resurrection of Evil, The Lost
Mission and the classic games have not been played on a PS5. Expect faults, and
keep a copy of your saves.

## What you need

- A PS5 that runs homebrew, with etaHEN (or an equivalent), ShadowMountPlus
  (which shows folders in `/data/homebrew` as games) and an FTP server.
- **Doom 3 BFG Edition's `base` folder.** On Steam, the game sold as
  **DOOM 3** (app 208200) includes the BFG Edition for its owners. The folder
  is the Windows one, so either copy it from a Windows Steam install
  (`steamapps/common/DOOM 3 BFG Edition/base`), or fetch it on any computer
  with [DepotDownloader](https://github.com/SteamRE/DepotDownloader), signing
  in to your own Steam account:

  ```sh
  DepotDownloader -app 208200 -os windows -username YOUR_STEAM_LOGIN -dir doom3bfg
  ```

  You want the files ending in `.resources` (with `maps/`, `wads/`, `video/`
  and the rest). The original Doom 3's `pak000.pk4`...`pak008.pk4` are not used.
- **RBDoom3BFG's three data packs**, from its
  [1.6.0 release](https://github.com/RobertBeckebans/RBDOOM-3-BFG/releases/tag/v1.6.0)
  (the `full` 7z): `base/_rbdoom_core.pk4`, `base/_rbdoom_blood.pk4` and
  `base/_rbdoom_global_illumination_data.pk4`.

## The files you need

Everything goes in one folder on the console, `/data/homebrew/PPSA99313/base/`,
beside the release's own files. From the Steam download of DOOM 3 (BFG
Edition), English, that is 383 files, about 7.4 GB, plus RBDoom3BFG's three
packs (1.5 GB):

| File or folder | Size | What it is |
| --- | --- | --- |
| `_common.resources`, `_common.crc` | 80 MB | The game's shared data: materials, models, scripts, menus |
| `_ordered.resources`, `_ordered.crc` | 11 MB | Start-up data, read in order |
| `_sound_pc.resources`, `_sound_pc.crc` | 546 MB | Sound effects and music |
| `_sound_pc_en.resources`, `_sound_pc_en.crc` | 134 MB | English speech (other languages have their own `_sound_pc_XX` files) |
| `_sound_pc_fr.crc`, `_gr`, `_it`, `_jp`, `_sp` `.crc` | small | Indexes for the other languages' speech (harmless without them) |
| `maps/` | 5.9 GB | 60 levels, a `.resources` and a `.crc` each (120 files) |
| `video/` | 83 MB | 31 Bink movies: cut-scenes and menu backgrounds |
| `sound/VO/video/` | 182 MB | 20 Bink movies with speech: the PDA videos |
| `strings/english.lang` | 0.6 MB | The game's text |
| `wads/DOOM.WAD`, `DOOM2.WAD`, `NERVE.WAD` | 30 MB | Classic Doom, Doom II and No Rest for the Living |
| `classicmusic/` | 5.6 MB | `gravis.cfg` and 190 instrument patches, for the classic games' music |
| `joy_360_0.cfg`, `joy_360_1.cfg`, `joy_lefty.cfg`, `joy_righty.cfg` | small | Controller layouts |
| `_rbdoom_core.pk4` | 4.9 MB | RBDoom3BFG's own assets (from its release) |
| `_rbdoom_blood.pk4` | 24 MB | RBDoom3BFG's blood decals (from its release) |
| `_rbdoom_global_illumination_data.pk4` | 1.5 GB | RBDoom3BFG's baked lighting for every level (from its release) |

Leave out Steam's `default.cfg` (the release's own is newer), and Steam's
`Doom3BFG.exe`, `.dll` files and `_CommonRedist` folder, which are for Windows.

<details>
<summary>Every level in <code>maps/</code></summary>

Doom 3: admin, alphalabs1, alphalabs2, alphalabs3, alphalabs4, caverns1, caverns2, comm1, commoutside, cpu, cpuboss, delta1, delta2a, delta2b, delta3, delta4, delta5, enpro, hell1, hellhole, mars_city1, mars_city2, mc_underground, monorail, recycling1, recycling2, site3

Resurrection of Evil: deltax, erebus1, erebus2, erebus3, erebus4, erebus5, erebus6, hell, phobos1, phobos2, phobos3, phobos4

The Lost Mission: le_enpro1, le_enpro2, le_exis1, le_exis2, le_hell, le_hell_post, le_underground, le_underground2

Multiplayer: d3ctf1, d3ctf2, d3ctf3, d3ctf4, d3dm1, d3dm2, d3dm3, d3dm4, d3dm5, d3xpdm1, d3xpdm2, d3xpdm3, d3xpdm4

Each is `maps/<name>.resources` with `maps/<name>.crc`.
</details>

<details>
<summary>Every movie</summary>

- `video/admin/betruger.bik`
- `video/comm1/swann_vidphone1.bik`
- `video/comm1/swann_vidphone2.bik`
- `video/comm1/swann_vidphone3.bik`
- `video/data.bik`
- `video/delta1/sarge_video1.bik`
- `video/enpro1/lm_meyers_enpro.bik`
- `video/erebusteam.bik`
- `video/fireball.bik`
- `video/hellhole/rescue.bik`
- `video/intro/introloop.bik`
- `video/loadvideo.bik`
- `video/mars1.bik`
- `video/mars_rotation.bik`
- `video/marscity/decom.bik`
- `video/marscity/dropship.bik`
- `video/marscity/monoflyby.bik`
- `video/marscity/sarge_mission_brief.bik`
- `video/marscity/sci_team_request.bik`
- `video/marscity/ship.bik`
- `video/mc_underground/inv1sm.bik`
- `video/mc_underground/inv2sm.bik`
- `video/mc_underground/inv3.bik`
- `video/mc_underground/inv4sm.bik`
- `video/mc_underground/inv5sm.bik`
- `video/mc_underground/inv6sm.bik`
- `video/mc_underground/inv7sm.bik`
- `video/mcneil.bik`
- `video/radar.bik`
- `video/recycling2/cs_bert01_composite.bik`
- `video/recycling2/cs_bert02_composite.bik`
- `sound/VO/video/deployment.bik`
- `sound/VO/video/epd.bik`
- `sound/VO/video/generator.bik`
- `sound/VO/video/grabber.bik`
- `sound/VO/video/hydrocon.bik`
- `sound/VO/video/mfs.bik`
- `sound/VO/video/video_alphalabs_intro.bik`
- `sound/VO/video/video_ancient_civ.bik`
- `sound/VO/video/video_bfg.bik`
- `sound/VO/video/video_chaingun.bik`
- `sound/VO/video/video_demon_museum.bik`
- `sound/VO/video/video_ian_report.bik`
- `sound/VO/video/video_ipn_news.bik`
- `sound/VO/video/video_marine_sops.bik`
- `sound/VO/video/video_meyers_report.bik`
- `sound/VO/video/video_plasmagun.bik`
- `sound/VO/video/video_recycling.bik`
- `sound/VO/video/video_soulcube.bik`
- `sound/VO/video/video_tablets.bik`
- `sound/VO/video/video_uac_welcome.bik`
</details>

## Installing

Download `Doom3BFG-PS5-v<version>.zip` from the
[releases page](https://github.com/griches/PS5_Doom3/releases/latest) and unzip
it (or build the title folder yourself: see
[Building it yourself](#building-it-yourself)). Then with an FTP program
(FileZilla, Cyberduck, WinSCP) copy, into `/data/homebrew/` on the console:

1. The whole `PPSA99313` folder.
2. Everything in your BFG Edition's `base` folder, into `PPSA99313/base/`,
   **except `default.cfg`**: the title's own is newer.
3. The three `_rbdoom_*.pk4` files, into `PPSA99313/base/` as well.

```text
/data/homebrew/PPSA99313/eboot.bin
/data/homebrew/PPSA99313/sce_sys/
/data/homebrew/PPSA99313/sce_module/
/data/homebrew/PPSA99313/licenses/
/data/homebrew/PPSA99313/base/renderprogs2/            (the title's shaders)
/data/homebrew/PPSA99313/base/_common.resources        (yours, and the rest of your base folder)
/data/homebrew/PPSA99313/base/_rbdoom_core.pk4         (and the other two packs)
```

That is about 9 GB. "Doom 3 BFG" then appears on the home screen. If it does
not, check that the folder is exactly `/data/homebrew/PPSA99313/` with
`eboot.bin` directly inside it, and that ShadowMountPlus is running. The first
start takes about 40 seconds to reach the menu.

To update, copy the new release's `PPSA99313` folder over the old one. Your
game data, saves and settings are left alone.

## Playing

RBDoom3BFG's own controller layout:

| DualSense | In the game |
| --- | --- |
| Left stick, right stick | Move, look |
| R2 | Fire |
| L2 | Flashlight |
| L1, R1 | Previous, next weapon |
| Cross | Jump |
| Square | Reload |
| Triangle | Use |
| D-pad | Weapon shortcuts |
| Touch pad button | PDA |
| Options | Menu |

The gamepad is always on: the PC game starts with it switched off, and the PS5
build turns it on at every launch.

Saves and settings are kept in `/data/homebrew/PPSA99313/userdata/`.

**Extra settings.** A file `userdata/args.txt` is read at start-up as a command
line, for example `+set com_showFPS 1` for a frame counter, or `+set logFile 1`
for a log in `userdata/base/qconsole.log`. There is no log by default: on the
console every write to the title's folder takes about 145 ms, so a log costs
frames.

## Status

Tested on one console (PS5, firmware 13.60) on 2026-10-14, with the Steam BFG
Edition data. "Seen" means it ran there and was watched by a person playing,
looked at in the console's own screenshots, or read in the title's log. Nothing
else is claimed.

| Area | Seen on the console | Not yet verified |
| --- | --- | --- |
| Start-up | The BFG Edition menu, the Doom 3 menu, a new game | Resurrection of Evil, The Lost Mission, Doom, Doom II |
| Rendering | 3840x2160 on Vulkan (RADV); the first areas look right; the flashlight beam (see below) | Everything past the start of the campaign |
| Frame rate | The menus hold 60; the counter showed 59 to 90 in the first areas | Heavier areas; a long session |
| Input | The DualSense in the menus and in play | Rumble; a second controller |
| Saving | Autosaves and saves are written | Loading them after a restart |
| Sound | OpenAL Soft starts | A careful listen |

### Known problems

- **The Resolution option has no effect.** The title always draws at the
  console's output size (3840x2160 on a 4K screen; a 1080p screen gets the same
  picture scaled down). Making the option choose a real 1080p, 1440p or 2160p
  mode is planned.
- **The three Vertical Sync choices behave the same.** The console's display
  presents with v-sync only. The title asks for 120 Hz output, and in doing so
  turns the system's VRR off; both are to be reworked so that the choices mean
  something (60 locked, uncapped to 120, and VRR).
- **"Restart Now"** after changing the frame rate restarts the title through the
  system; this is new and not yet tried on a console.
- **The first start takes about 40 seconds** to reach the menu. Not yet looked into.
- **The flashlight's dust beam is replaced.** The original beam adds a dust
  texture through the framebuffer's alpha, which RBDoom3BFG's HDR renderer
  draws as a hard, grainy wedge. The title ships its own material
  ([`ps5/base/materials/_ps5_flashlight.mtr`](ps5/base/materials/_ps5_flashlight.mtr)):
  a faint glow in the beam's shape, without the dust.

## What the console needed

For the curious, and for anyone porting something similar. All of it is in
[`ps5/patches/rbdoom3bfg.patch`](ps5/patches/rbdoom3bfg.patch) and `ps5/`.

- **Vulkan with no loader.** RADV is linked into the title, so the engine's
  `vulkan.hpp` dispatcher, NVRHI and VMA take every command from RADV's own entry
  point; SDL2 gets a video driver that hands out a `VK_KHR_display` surface on
  the console's one display.
- **Shaders built ahead of time.** RBDoom3BFG compiles its HLSL to SPIR-V with
  DXC; that happens on the build machine, and DXC is built from source there
  for an arm64 host ([`ps5/tools/setup-dxc.sh`](ps5/tools/setup-dxc.sh)).
- **One ISPC kernel.** The engine's BC6H encoder (for its baked lighting) is
  ISPC code, compiled on macOS (whose ISPC has an x86 backend) and linked as an
  object ([`ps5/tools/ispc-kernel.sh`](ps5/tools/ispc-kernel.sh)).
- **Sound** through openal-soft, built with SDL2 as its only backend.
- **A pad that arrives late.** The console reports the DualSense just after the
  engine looks for controllers; the engine now opens one when it is added.
- **The console's C library** is FreeBSD's: a few calls a Linux build expects
  (`fnmatch`, `strsignal`, `execl`, `<malloc.h>`) are answered by the port.
- **Paths, restarting and logging**: data in the title's folder, saves in
  `userdata/`, a restart through `sceSystemServiceLoadExec`, and no log file
  unless asked for.

## Building it yourself

The port is built on Linux (an arm64 or x86-64 machine or VM) with LLVM 22,
[PS5_PayloadSDK](https://github.com/mihawk-99/PS5_PayloadSDK) and
[PS5_Vulkan](https://github.com/mihawk-99/PS5_Vulkan) with its RADV archive
built. One step, the ISPC kernel, needs macOS or an x86-64 Linux machine.

```sh
git clone --recursive https://github.com/griches/PS5_Doom3.git && cd PS5_Doom3
ps5/tools/ispc-kernel.sh       # on macOS or x86-64 Linux: build/ispc/kernel.o
export PS5_VULKAN_DIR=/path/to/PS5_Vulkan PS5_PAYLOAD_SDK_FORK=/path/to/PS5_PayloadSDK
ps5/tools/build.sh             # applies the patch, builds dist/PPSA99313/
ps5/tools/shaders.sh           # builds DXC once, then the shaders into the title
```

From a Mac with the Linux VM set up as `ps5` in Lima, `ps5/tools/vm.sh build`
and `ps5/tools/vm.sh shaders` do the same (and `vm.sh build` runs the ISPC step
first). `ps5/tools/setup-source.sh --save` writes changes made under
`vendor/RBDOOM-3-BFG` back to the patch. `ps5/tools/console-files.sh` uploads
game data from `data/game/` to the console.

## Credits

- **Robert Beckebans and the RBDoom3BFG contributors**, for
  [RBDOOM-3-BFG](https://github.com/RobertBeckebans/RBDOOM-3-BFG). This port is
  theirs with a console's worth of glue.
- **id Software**, for releasing the Doom 3 BFG Edition source under the GPL.
- **Mihawk**, for [PS5_Vulkan](https://github.com/mihawk-99/PS5_Vulkan),
  [PS5_Mesa](https://github.com/mihawk-99/PS5_Mesa),
  [PS5_PayloadSDK](https://github.com/mihawk-99/PS5_PayloadSDK) and the PS5
  Vulkan Template this port's platform layer comes from.
- NVIDIA for NVRHI and ShaderMake; the [SDL](https://github.com/libsdl-org/SDL),
  [openal-soft](https://github.com/kcat/openal-soft), [Mesa](https://www.mesa3d.org/),
  DXC and ISPC projects; and [DepotDownloader](https://github.com/SteamRE/DepotDownloader).

## Licence

GPL-3.0 as built; each part keeps its own licence. [`LICENSING.md`](LICENSING.md)
says which covers what, and what is not covered at all: the game, RBDoom3BFG's
data packs and trademarks.

Doom 3 is id Software's. This project is not affiliated with, endorsed or
sponsored by id Software, ZeniMax, Bethesda or Sony Interactive Entertainment.
