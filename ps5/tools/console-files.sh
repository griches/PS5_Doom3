#!/usr/bin/env bash
# Doom 3 BFG for the PlayStation 5 - upload your own game data to the console.
#
#   ps5/tools/console-files.sh       data/game/ (base/ with the BFG Edition's files
#                                    and RBDoom3BFG's _rbdoom_*.pk4) to
#                                    /data/homebrew/<TITLE_ID>/ on the console
#
# The game's data is yours and is never part of dist/ or of a release: it goes
# up apart from the title, with PS5_Vulkan's console settings (its .env). Files
# already there at the same size are skipped; each file goes up under a
# .upload name and takes its own only once complete.
#
# SPDX-License-Identifier: GPL-3.0-or-later
set -euo pipefail
ps5=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
root=$(dirname "$ps5")
vulkan=$(cd -- "${PS5_VULKAN_DIR:-$root/../PS5_Vulkan}" && pwd)
title_id=$(python3 -c 'import json,sys; print(json.load(open(sys.argv[1]))["titleId"])' "$ps5/sce_sys/param.json")
[[ -f $root/data/game/base/_common.resources ]] || { echo "no data/game/base/_common.resources: README has where your game data goes" >&2; exit 2; }
exec python3 - "$vulkan/tools" "$root/data/game" "$title_id" <<'PY'
import sys, time
from ftplib import FTP, error_perm
from pathlib import Path

sys.path.insert(0, sys.argv[1])
import ps5_console

folder, title = Path(sys.argv[2]), sys.argv[3]
settings = ps5_console.load_settings()
status = ps5_console.ps5vkctl_command(settings, "procs", timeout=20)
if " count=0 " not in status + " ":
    raise SystemExit(f"the console is running an application ({status.strip()}); not uploading")
files = sorted(p for p in folder.rglob("*") if p.is_file() and p.name != ".DS_Store")
total = sum(p.stat().st_size for p in files)
done = sent = 0
start = time.monotonic()
with FTP() as ftp:
    ftp.connect(settings["host"], settings["ftp_port"], timeout=60)
    ftp.login(settings["ftp_user"], settings["ftp_password"] or "codex")
    ftp.voidcmd("TYPE I")
    made = set()
    for local in files:
        relative = local.relative_to(folder).as_posix()
        remote = f"/data/homebrew/{title}/{relative}"
        size = local.stat().st_size
        parent = remote.rsplit("/", 1)[0]
        if parent not in made:
            path = ""
            for part in parent.strip("/").split("/"):
                path += "/" + part
                try:
                    ftp.mkd(path)
                except error_perm:
                    pass
            made.add(parent)
        try:
            if ftp.size(remote) == size:
                done += size
                continue
        except error_perm:
            pass
        with local.open("rb") as data:
            ftp.storbinary(f"STOR {remote}.upload", data, blocksize=1 << 20)
        ftp.rename(f"{remote}.upload", remote)
        done += size
        sent += size
        rate = sent / max(time.monotonic() - start, 1e-3) / 1e6
        print(f"  {relative}  {size:,} bytes  ({done * 100 // total}% of {total / 1e9:.1f} GB, {rate:.0f} MB/s)", flush=True)
print(f"==> {title}: game data on the console ({total / 1e9:.1f} GB)")
PY
