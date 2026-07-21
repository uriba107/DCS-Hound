# Hound ELINT — Syria HARM Targeting Demo

HARM-focused demo on the Syria map showcasing Hound ELINT's ability to detect, track, and report enemy radar emitters for SEAD strike planning. Includes ELINT C-130 orbits, ground-based sensors, Skynet IADS integration, a mobile SA-6 battery with auto-respawn, pre-briefed contacts (SA-2, EWRs), Apache target ranges, and randomized SHORAD/MANPADS threats.

## How It Runs

Load `Hound_Demo_syria.miz` in DCS World (Syria map). Join a BLUE aircraft slot (F-16C, A-10C, AH-64D, etc.). Hound ELINT auto-initializes and begins reporting via radio (ATIS, sector controller, notifier) and map markers. SA-6 battery activates 120s after start and respawns every 600s at North/South/Joker positions. Use the F10 **Mission Actions** menu to manually trigger SA-6 spawns, toggle MANPADS, set Apache range difficulty, and spawn target groups.

## File Descriptions

| File | Role | Key Details |
|------|------|-------------|
| `Hound_Demo_syria.lua` | Main mission script | Hound setup, ELINT platforms (C-130s + ground stations), sectors (Lebanon, Northern Israel), radio controllers, BDA, markers, pre-briefed contacts (SA-2, EWRs), event handler for RADAR_DESTROYED → SA-6 cleanup |
| `extras/Hound_Demo_syria_SAMs.lua` | Red air defense | Skynet IADS (`redIADS`), SA-6 battery spawner (North/South/Joker, 600s respawn), SHORAD random activation (30%), MANPADS toggle, debug F10 menu (blowup commands) |
| `extras/Hound_Demo_syria_apache.lua` | Apache target range | Two ranges (Hula, Golan) with 3 difficulty levels (EASY/MEDIUM/HARD), dynamic group spawning via F10 menu, randomized vehicle types per difficulty |
| `hound_contacts_1.csv` | Pre-generated ELINT contacts | 15 emitters: SA-2 Fan-song/Flat Face, SA-11 Fire Dome/Snow Drift, SA-6 Straight Flush, 5 EWRs; lat/lon, MGRS, accuracy, DCS type/unit/group mappings |
| `Hound_Demo_syria.miz` | Compiled DCS mission | Binary — load in DCS |
| `KNEEBOARD/IMAGES/00_HARM_cheatsheet.png` | Pilot kneeboard | HARM targeting reference for in-flight use |

## Mission Layout

### BLUE / ELINT Platforms
- **C-130s**: `ELINT North`, `ELINT South`, `ELINT Galil` — orbiting ELINT platforms
- **Ground stations**: `ELINT HERMON`, `ELINT MERON` — static ELINT sensor sites
- **Sectors**: Lebanon, Northern Israel (zones defined by `Sector_Lebanon`, `Sector_Israel`)
- **Radio**: Controller on 251.000 AM / 122.000 AM / 35.000 FM / 3.500 AM; ATIS on 253.000 AM / 124.000 AM; transmitter via `ELINT MERON`

### RED Forces
- **SA-2 Site** (`SYR_SA-2`): Pre-briefed, Fan-song + Flat Face radars
- **SA-6 Battery** (`SYR_SA6`): Mobile, spawns at North (zone `SA6_North`), South (zone `SA6_South`), and Joker (random template from SA-6/SA-11/SA-8) on 600s cycle
- **SA-11 Site** (`SYRIA gnd 3`): Reported in CSV, Snow Drift + 4x Fire Dome
- **EWRs**: 5 sites (EWR-SKYNET-0 through 4), all pre-briefed
- **SHORAD**: Groups prefixed `SHORAD-`, 30% random activation via Skynet
- **MANPADS**: Groups prefixed `MANPAD-`, toggleable via F10 menu (50% activation chance)
- **IADS**: Skynet instance `lebanonIADS`, EWRs added by prefix `EWR-SKYNET`

### HARM CSV Contact Data
15 rows covering SA-2 (active), SA-11 (asleep/down), SA-6 (down/asleep), and 5 EWRs (active). Accuracy ranges from Precise to Very Low. Pre-briefed contacts drive Hound's initial emitter tracking without requiring ELINT platform detection.

## Running the Mission

1. Copy `Hound_Demo_syria.miz` to your DCS `Missions` folder or open directly.
2. Requires **Syria** map.
3. **HoundElint.lua** is bundled in the .miz — no external install needed.
4. **SRS** (DCS-SimpleRadio-Standalone) is optional but recommended for TTS radio output. The script sets `STTS.DIRECTORY` to the SRS ExternalAudio path.
5. **Skynet IADS** library is bundled in the .miz.
6. For development, set `HoundWorkDir` in `hound_loader.lua` and use `HoundElint_devel.lua` to load individual source files.

## Discrepancies and Notes

1. **Viggen human ELINT handler** (`Hound_Demo_syria.lua:103–127`): A detailed handler for adding an AJS37 Viggen pilot as a human ELINT platform (with auto-add on spawn, remove on leave) is **commented out**. It was a WIP feature for turning a human-recce Viggen into an ELINT data source.
2. **CSV auto-dump commented out** (`Hound_Demo_syria.lua:17`): The `dumpCsv` scheduled task is disabled (`taskId = nil`). Intel brief can still be triggered manually.
3. **SA-6 Joker spawn uses random template** (`extras/Hound_Demo_syria_SAMs.lua:111–113`): The Joker position randomly picks from SA-6, SA-11, or SA-8 templates — not always an SA-6.
4. **SA-6 South clone commented out** (`extras/Hound_Demo_syria_SAMs.lua:106`): A `mist.cloneInZone` line for SA-6 South is commented out — the line below does the same work, left as a dev note.
5. **SHORAD Skynet integration** (`extras/Hound_Demo_syria_SAMs.lua:12`): `addSAMSitesByPrefix("SHORAD-")` is commented out; instead SHORAD groups are iterated manually with 30% random activation.
6. **IADS debug commented out** (`extras/Hound_Demo_syria_SAMs.lua:26–35`): Skynet debug settings are present but disabled.
7. **Apache range zones**: Hula and Golan ranges reference zone names `PlayGround_Hula` and `PlayGround_Golan` — ensure these zones exist in the .miz if modifying the mission.
8. **Callsign override** (`Hound_Demo_syria.lua:97-100`): `setCallsignOverride({Colt = '*', Chaos = '*'})` — `'*'` replaces the DCS formation callsign (e.g. "Colt 1 1" → "Colt") with the **group's DCS name** (e.g. `SYR_SA-2`). This makes Hound address flights by their group name instead of the standard DCS callsign pool. Set per-flight overrides (e.g. `Colt = 'Viper'`) instead of `'*'` for custom callsigns.
