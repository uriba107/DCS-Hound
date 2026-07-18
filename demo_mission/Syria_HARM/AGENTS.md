# DOX: demo_mission/Syria_HARM/ — HARM Targeting Demo

## Purpose

ELINT demo for HARM targeting on the Syria map. Showcases Hound ELINT's emitter detection, sector-based reporting, radio/ATIS/notifier controllers, BDA, pre-briefed contacts, and Skynet IADS integration alongside an Apache target range. Mission scripts are designed as standalone do-blocks loaded from the .miz trigger.

## Ownership

- **`Hound_Demo_syria.lua`** — Main Hound setup: ELINT platforms (C-130s by prefix `ELINT `, ground stations by prefix `ELINT ` static objects), sectors (Lebanon, Northern Israel), controller/ATIS/notifier config, zone binding, marker enable, BDA, pre-briefed contacts (SYR_SA-2, all `EWR-` units), callsign override, HoundTriggers event handler, commented-out Viggen human ELINT handler
- **`extras/Hound_Demo_syria_SAMs.lua`** — Red air defense: `HOUND_MISSION` root table, Skynet IADS `redIADS`, SA-6 lifecycle (North/South/Joker), SHORAD randomization (30% activation via prefix `SHORAD-`), MANPADS toggle (prefix `MANPAD-`, 50% activation), debug F10 blowup commands, SA-6 `GoLive` scheduled every 600s after initial 120s delay
- **`extras/Hound_Demo_syria_apache.lua`** — Apache target ranges: `HOUND_MISSION.PLAYGROUND` with `.ranges` (Hula, Golan), `.vehicleTypes` by difficulty (EASY/MEDIUM/HARD), `.spawnGroup` via `mist.dynAdd`, `.buildRangeMenu()` F10 menu
- **`hound_contacts_1.csv`** — 15 pre-generated ELINT contacts (SA-2, SA-6, SA-11, 5x EWR) with lat/lon, MGRS, accuracy, DCS type/unit/group mappings
- **`Hound_Demo_syria.miz`** — Compiled DCS mission (binary)
- **`KNEEBOARD/IMAGES/00_HARM_cheatsheet.png`** — Pilot kneeboard reference image
- **`README.md`** — User-facing overview, file descriptions, mission layout, running instructions, discrepancies

## Local Contracts

### Cross-File Global State

- All scripts share `HOUND_MISSION` table — scripts depend on each other through globals, not parameters
- `HOUND_MISSION` is initialized in `extras/Hound_Demo_syria_SAMs.lua` and consumed by all three scripts
- `MAIN_MENU` sub-menus are created in `extras/Hound_Demo_syria_SAMs.lua` and extended by `extras/Hound_Demo_syria_apache.lua` (`.apache` subtree)

### SA-6 Lifecycle

- `HOUND_MISSION.SA6.North`, `.South`, `.Joker` — group references
- `HOUND_MISSION.SA6.template = "SYR_SA6"` — base template name
- `GoLive()` runs every 600s (scheduled at +120s initial). Each spawn position:
  - If existing group is nil OR `destroy()` returns true (radar unit life ≤ 1), clone template via `mist.cloneInZone` into the named zone
  - `.activate()` enables emission, sets ROE=OPEN_FIRE, Alarm=RED, engage air weapons=OFF
- `.cleanup(dcsGroup)` — match group against North/South/Joker, then `Group.destroy` and nil the reference
- `.destroy(GroupName)` — check if radar unit (Kub 1S91 str, SA-11 Buk SR 9S18M1, Osa 9A33 ln) has life ≤ 1 or life/life0 ≤ 0.55; if destroyed, call `.destroyRadar` to trigger explosion at radar position
- `.spawnJoker()` — 40% chance to spawn Joker position each cycle
- `.randomTemplate()` — picks from `{"SYR_SA6","SYR_SA11","SYR_SA8"}` for Joker spawns

### Event Handling

- `HoundTriggers` table in `Hound_Demo_syria.lua` has `dumpCsv(interval)` and `onHoundEvent(event)`
- `onHoundEvent` catches `HOUND.EVENTS.RADAR_DESTROYED` on BLUE coalition
- On match: checks if the destroyed group is one of the SA-6 groups (North/South/Joker), schedules `SA6.cleanup` with 30–60s random delay
- CSV auto-dump (`dumpCsv`) is commented out

### Skynet IADS Integration

- `redIADS = SkynetIADS:create('lebanonIADS')` created in SAMs script
- EWRs added by prefix `EWR-SKYNET`
- SHORAD groups (prefix `SHORAD-`) iterated at init: 30% get activated and added to IADS
- MANPADS groups (prefix `MANPAD-`) toggled via F10 menu with 50% activation chance
- Skynet debug settings are present but commented out

### Apache Playground

- `HOUND_MISSION.PLAYGROUND.ranges`: Hula (zone `PlayGround_Hula`), Golan (zone `PlayGround_Golan`)
- Three difficulty levels: EASY (tanks + trucks), MEDIUM (adds Strela + Shilka), HARD (adds Tunguska)
- `spawnGroup(rangeName)` — picks random point in zone, creates 4–8 units in circle (25–200m radius), sets ROE=OPEN_FIRE, Alarm=RED
- `buildRangeMenu()` — rebuilds F10 menu with current difficulty label per range

### CSV Contact Format

`SiteId,SiteNatoDesignation,TrackId,RadarType,State,Bullseye,Latitude,Longitude,MGRS,Accuracy,lastSeen,DcsType,DcsUnit,DcsGroup,ReportGenerated`

State: Active/Asleep/Down. Accuracy: Precise/High/Very High/Very Low. Pre-briefed contacts in main script use group names from the DcsGroup column.

### Lua Conventions

- All scripts wrapped in `do ... end` blocks
- Loaded sequentially in the .miz trigger — Hound runtime must be available before these scripts execute
- Uses `HOUND.Utils.Filter.groupsByPrefix`, `.unitsByPrefix`, `.staticObjectsByPrefix` for dynamic discovery
- Uses `mist` utilities: `cloneInZone`, `getRandomPointInZone`, `getRandPointInCircle`, `dynAdd`, `scheduleFunction`

## Work Guidance

### Adding New SAM Sites

1. Add the DCS group to the .miz with a recognizable prefix (e.g., `SYR_` or `EWR-SKYNET-`).
2. Add CSV rows for the emitter contacts in `hound_contacts_1.csv` (see format above).
3. If adding to IADS, call `redIADS:addSAMSite(grpName)` or `redIADS:addEarlyWarningRadarsByPrefix()`.
4. Optionally add a `HoundBlue:preBriefedContact(siteName)` line to the main script.

### Extending the CSV

- Maintain column order and headers.
- Use `State` = `Active` for emitters that are radiating at mission start, `Asleep` for dormant ones.
- `DcsType` must match the exact DCS type name for the radar unit.
- `DcsGroup` must match the DCS group name in the .miz.

### Adding Apache Range Targets

1. Add a zone to the .miz (e.g., `PlayGround_NewRange`).
2. Add a new entry to `HOUND_MISSION.PLAYGROUND.ranges` in `Hound_Demo_syria_apache.lua`.
3. Optionally add new vehicle types to the `.vehicleTypes` table per difficulty level.
4. The menu rebuilds automatically on next call to `buildRangeMenu()`.

### Modifying SA-6 Behavior

- Adjust respawn interval by changing the second argument to `mist.scheduleFunction` (currently 600).
- Adjust Joker spawn probability via `HOUND_MISSION.SA6.spawnJoker` (currently 40%).
- Add or remove templates from `randomTemplate()` to change Joker composition.

## Verification

- Load `Hound_Demo_syria.miz` in DCS (Syria map) and observe:
  - Hound radio reports on configured frequencies
  - Map markers appearing for detected emitters
  - SA-6 battery spawns at ~120s and respawns every 600s
  - Destroying an SA-6 radar triggers cleanup and re-spawn
  - Apache F10 menu spawns target groups in Hula/Golan zones
  - MANPADS toggle activates/destroys MANPAD- groups
- Verify CSV content by inspecting `hound_contacts_1.csv` — data drives pre-briefed contacts
- Check `dcs.log` for `GoLive` and SA-6 lifecycle messages
- No automated test suite — in-mission observation required

## Child DOX Index

(none — files directly in this directory are the leaf level)
