# DOX: demo_mission/Syria_POC — Syria AD POC Demo

## Purpose

Scale proof-of-concept DCS World mission on the Syria map demonstrating Hound ELINT operating at scale (dozens to hundreds of SAM/EWR radars) alongside MOOSE (MANTIS IADS, EASYGCICAP GCI/CAP). Based on Pikey's Syrian Air Defense 2012 template. Establishes that Hound's emitter count scales to a full AD network.

## Ownership

| File | Role |
|------|------|
| `Hound_Demo_SyADFGCI.lua` | Main mission script — Hound setup, SEAD spawn handler (MOOSE AUFTRAG/SPAWN), SRS config, EWR import via MOOSE as prebriefed contacts, sector/controller/ATIS definitions |
| `SydADF2012.lua` | Pikey's Syria AD 2012 template (external, not project code) |
| `Hound_Demo_SyADFGCI.miz` | Compiled DCS mission (binary) |
| `extras/Moose.lua` | MOOSE framework (third-party, ~9.3 MB, gitignored, do not edit) |
| `README.md` | High-level reference |

## Local Contracts

### Pikey's AD Template (`SydADF2012.lua`)

- **External code** — modifications should be minimal and documented. Not owned by the Hound project. Uses pure MOOSE APIs throughout.
- **SAM availability**: editable variables `SA6pc`, `SA2pc`, `SA3pc`, `SA10pc`, `EWRpc` (default 75). At mission start, random groups are destroyed to reduce each type to the configured percentage.
- **MOOSE SET_GROUP API**: filters by prefix (`"SAM SA-6"`, `"SAM SA-2"`, `"SAM SA-3"`, `"SAM SA-10"`, `"EWR"`) with `FilterActive(true)` and `FilterOnce()` for SAMs, `FilterStart()` for EWR.
- **MANTIS IADS** (MOOSE): `MANTIS:New('SYRIA','SAM','EWR',nil,"red",false,nil,true)` — 15s detect interval, 80 km SAM range.
- **GCI/CAP**: `EASYGCICAP` with MiG-23 (54/695 Sqns), MiG-29A (698 Sqn), Su-30 (Russia GCI). 4 CAP patrol points (Marj Ruhayyil, Al-Dumayr, An Nasiriyah, Bassel Al-Assad) at 25,000 ft / 450 kn. Engage range 97 NM, mission range 54 NM.
- **CAS spawning**: Scheduled AUFTRAG:NewCAS missions against Aleppo/Golan zones every 900s (first batch at 4s, second at 300s).
- **Spawned defenders/attackers**: `SpawnScheduled(600, .9)` with limits of 7-8 groups.

### Hound Configuration (`Hound_Demo_SyADFGCI.lua`)

- **`HOUND.FORCE_MANAGE_MARKERS = true`** — Hound controls all marker creation/cleanup. Marker removal triggers SEAD flight RTB and deletion (60s/120s delays in Hound core).
- **Platforms** (5): `Mt_Hermon_ELINT`, `Mt_Meron_ELINT`, `ELINT_C130_south`, `ELINT_C130_north`, `ELINT_TURKEY`. All transmitters route through `Mt_Meron_ELINT`.
- **Sectors** (9 direct + 3 meta): Damascus, South Syria, Homs, Latakya, Palmyra, Sayqal, Haleb, Tabqa, Lebanon. Meta-sectors: South AO (OPTIMUS, 306.000 AM, supertonic), North AO (JAZZ, 306.500 AM, libritts), East AO (BUMBLEBEE, 307.000 AM, supertonic).
- **ATIS**: Enabled on 7 sectors with piper/libritts providers. No controllers enabled (all commented out).
- **Prebriefed contacts**: All EWR groups matched by prefix `EWR` via `HOUND.Utils.Filter.unitsByPrefix` are imported as prebriefed.
- **SRS**: `STTS.DIRECTORY` set to `C:\Program Files\DCS-SimpleRadio-Standalone\ExternalAudio`.

### SEAD Spawn Mechanics

- **Event**: `HOUND.EVENTS.SITE_CREATED` (not `SITE_LAUNCH`/`SITE_ALERT`).
- **Selection**: Nearest of three pre-placed flight groups (`SEAD_NORTH`, `SEAD_WEST`, `SEAD_SOUTH`) by 2D distance to contact position.
- **Mission**: `AUFTRAG:NewSEAD(siteMGroup, 20000)` — A-10C or F-16 (per miz template). Randomized loadout from template defaults.
- **Radio**: If the contact's sector has a controller, the SEAD flight is given the controller's frequency/modulation.
- **Output**: Coalition outText: `"Fragging a SEAD flight (%s) to strike %s (%s)"`.
- **300-second cooldown** between SEAD spawns — `_lastSeadSpawn` timestamp prevents unbounded task accumulation.

### Third-Party Libraries

- `extras/Moose.lua` is 9.3 MB, gitignored, treat as read-only. Loaded inside the miz. Provides all IADS, GCI, spawning, and scheduling (MANTIS, EASYGCICAP, AUFTRAG, SPAWN, SCHEDULER, SET_GROUP, etc.).
- Hound ELINT is embedded in the miz, built from `src/*.lua` via `hound_builder.sh`.

## Work Guidance

- **Adjust SAM availability**: Edit `SydADF2012.lua` lines 10-14 (`SA6pc`, `SA2pc`, `SA3pc`, `SA10pc`, `EWRpc`).
- **Add SEAD flight types**: Place new groups in the miz with unique prefix names, add them to the `seadFlights` table in `HoundEventHandler:onHoundEvent`.
- **Add ELINT platforms**: Add a group in the miz, then call `Elint_blue:addPlatform("name")` in `Hound_Demo_SyADFGCI.lua`.
- **Add sectors**: Add a zone in the miz, then call `Elint_blue:addSector("Name")` + `setZone(...)` in the script.
- **Voice providers**: `supertonic` uses random voice from 10 options (F1-F5, M1-M5). `piper`/`libritts` use `en_US-libritts-high` with random speaker index.
- **Rebuilding miz**: Edit the `.lua` scripts, then repack the miz with your preferred miz tool (e.g., 7zip). The miz is a standard ZIP archive.
- **Marker behavior**: `HOUND.FORCE_MANAGE_MARKERS = true` means Hound owns marker lifecycle. Do not add third-party marker management.

## Verification

- Load `Hound_Demo_SyADFGCI.miz` in DCS (Syria map).
- Watch for BLUE ELINT platforms to detect RED emissions and create contacts.
- Observe SEAD spawns: look for outText messages and spawned A-10C/F-16 flights.
- Monitor `dcs.log` for Hound diagnostics (`env.info("configuring Hound")`, `env.info("importing EWRs as prebriefed contacts")`, `env.info("Hound - End of config")`).
- Tune SRS to meta-sector frequencies (306.000 / 306.500 / 307.000 AM) for voice reports.
- Verify RED IADS reactivity by approaching with the MQ-9 or a player aircraft.

## Child DOX Index

(none — files directly in this directory are the leaf level)
