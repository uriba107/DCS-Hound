# DOX: src/ -- Core Hound ELINT Source

## Purpose

Implement the Hound ELINT DCS World mod: radar emitter detection, triangulation, tracking, map markers, voice comms (ATIS/Controller/Notifier), sector management, and data export.

### Runtime Constraints

Runs in DCS sandbox (Lua 5.1): no `require`, no `io.*`/`os.*` (except `os.time`/`os.date`). All APIs are DCS globals (`timer`, `coalition`, `Unit`, `world`, `env`).

## Ownership

This subtree owns all Lua source files that compose the HoundElint system. The single deliverable is `include/HoundElint.lua` (minified build), assembled from these sources by `hound_builder.sh`.

## Local Contracts

- **Numbered loading order**: 36 files prefixed `NNN - ` loaded sequentially by `HoundElint_devel.lua`. The numbering establishes dependency order (lower = loaded first).
- **File groups by number range**:
  - `000-099`: Globals, Logger, Coroutine, Mist shim, Matrix math
  - `100-199`: Databases (DCS units, mods, config)
  - `200-299`: Utilities, TTS, Event Handler
  - `300-399`: Contact model (Base, Estimator, Datapoint, Emitter, Site, plus _comms variants)
  - `400-499`: Comms (Manager, InformationSystem, Controller, Notifier)
  - `500-599`: Worker, ContactManager, Sector, Sector menu
  - `800-899`: HoundElint main entry point and subsystems
  - `999`: Footer (post-init cleanup)
- **No cross-file circular dependencies** at require/load level; all cross-references go through the global `HOUND` namespace table.
- **All public API** is documented via LDoc annotations and extracted by `tools/generate_md_docs.py`.
- **Single global**: The `HOUND` table. Everything else is local or nested under `HOUND`.

### Data Model

- `HOUND.ElintWorker.contacts[unitName] = Emitter` — master list of detected radar emitters
- `HOUND.ElintWorker.sites[groupId] = Site` — logical grouping by DCS Group
- `Site.emitters[]` are **references** into `contacts`, not copies
- `Site.typeAssigned` computed by **set intersection** of its emitters' `typeAssigned` arrays

### Processing Cycles (default intervals)

| Cycle | Interval | Detail |
|-------|----------|--------|
| Scan | 10s | Coroutine, discovery yields every 128 groups |
| Process | 30s | Per-emitter: Kalman fast path or triangulate datapoints |
| Menu | 60s | Atomic F10 radio menu rebuild, sorted by distance |
| Markers | 120s | Coroutine, yields every 3 sites |
| ATIS | 180s | Refresh broadcast text (transmission scheduler 4s) |

Coroutine scheduler pump interval: **50ms** (`src/011 - HoundCoroutine.lua`).

### Emitter State Machine

`NEW → DETECTED|UPDATED → ASLEEP (15 min idle) → SITE_ALIVE → UPDATED`, plus `DESTROYED`.

## Work Guidance

- Follow existing numbered prefix convention for new files.
- Add LDoc annotations for any new public function.
- Run `hound_builder.sh` to verify the build concatenates without errors after source changes.
- Keep the Kalman filter math in `HoundContactEmitter` and matrix ops in `HoundMatrix` separated from business logic.

### Key Conventions

- New files go between existing numeric prefixes (e.g. `115 - Foo.lua` after `110`)
- Don't gate production logic on `HOUND.DEBUG` — compile flips it to `false`
- Don't put logic in `StopWatch` / `:Stop()` / `HOUND.Logger.trace("` lines — stripped at compile
- `DATAPOINTS_NUM = 30` hard FIFO cap per platform per emitter
- Pre-briefed contacts (`preBriefedContact`) bypass triangulation but still drive state machine

## Verification

- Build: `hound_builder.sh` produces `include/HoundElint.lua`
- Lint: `luacheck src/` (via builder)
- Unit tests: `demo_mission/hound_unit_test/extras/` using luaunit
- Static analysis: LDoc annotations checked during doc generation

## Child DOX Index

No subdirectories -- all source files are flat in this folder.
