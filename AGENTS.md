# Hound ELINT — Agent Guide

## Project

Lua mission script for DCS World. Triangulates enemy radar positions from passive ELINT platforms.
Runs in DCS sandbox (Lua 5.1): no `require`, no `io.*`/`os.*` (except `os.time`/`os.date`).
All APIs are DCS globals (`timer`, `coalition`, `Unit`, `world`, `env`).

## Build

Artifact: `include/HoundElint.lua` — `cat src/*` concatenation.
Numeric prefixes in `src/` ARE load order — preserve when adding files.

**`./hound_builder.sh`:**
| Flag | What it does |
|------|-------------|
| `-t` | Lint `src/*.lua` + DB validation |
| `-c` | Compile → `include/HoundElint.lua`, then lint result |
| `-c --minify` | Also produce `include/minified/HoundElint_.lua` (luasrcdiet) |
| `-d` | Build LDoc HTML docs (public → `docs/web/`, dev → `docs/web/dev/`) |
| `-m` | Rebuild demo `.miz` files |
| `--release` | Compile + docs + missions, strips `-TRUNK` version suffix |
| `--all` | Lint + docs + compile + missions |

**Lint:** `luacheck -g --no-self --no-max-line-length src/<file>.lua`
`.luacheckrc` silences all warning classes **except** whitespace and warnings `011`/`511` — lint is a syntax/undefined-call gate, not style enforcement.

**Compile-time stripping** (don't put logic on these lines):
- `StopWatch` / `:Stop()` lines removed
- `HOUND.Logger.trace("` lines removed
- `--` comment lines removed
- `DEBUG = true` flipped to `false`
- `-TRUNK` version suffix rewritten

## Dev Loop

Edit `HoundWorkDir` in both `hound_loader.lua` + `HoundElint_devel.lua`, then:
`DCS mission → loadfile hound_loader.lua → HoundElint_devel.lua → loadfile` each `src/*.lua`
This preserves per-file stack frames. Compiled `include/HoundElint.lua` works but loses them.

## Architecture

Single global `HOUND` table. No module system — files mutate `HOUND` in load order.

### File layers (by numeric prefix):
`000–021` Globals, logger, coroutine scheduler, mist port, matrix math
`100–103` Radar/platform DB (DCS units + mods, lookup helpers)
`110`     `HoundConfig` (per-instance settings)
`200–210` Utils (general, TTS, advanced), event handler
`300–321` Contact model: `Base` → `Estimator`/`Datapoint`/`Emitter`/`Site` (+ `_comms` mixins)
`400–421` `Comms.Manager` base, `InformationSystem`, `Controller`, `Notifier`
`500–510` `ElintWorker` (core scan/process), `ContactManager`
`550–551` `Sector` + menu
`800–804` `HoundElint` public API (`_properties`, `_sector_mgmt`, `_comms`, `Events`)
`999`     Footer

### Critical relationships:
- `ElintWorker.contacts[unitName] = Emitter` — master list of detected radars
- `ElintWorker.sites[groupId] = Site` — logical grouping by DCS Group
- `Site.emitters[]` are **references** into `contacts`, not copies — don't deep-copy
- `Site.typeAssigned` computed by **set intersection** of its emitters' `typeAssigned` arrays

### Processing cycles (default intervals):
- **Scan** 10s — coroutine, discovery yields every **128 groups** (`src/200 - HoundUtils.lua:1322`)
- **Process** 30s — per-emitter: Kalman fast path or triangulate accumulated datapoints
- **Menu** 60s — atomic F10 radio menu rebuild, sorted by distance
- **Markers** 120s — coroutine, yields every **3 sites** (`src/500 - HoundElintWorker.lua:402`)
- **ATIS** 180s — refresh broadcast text (transmission scheduler 4s)

Coroutine scheduler: `src/011 - HoundCoroutine.lua`, pump interval **50ms**.

### Emitter state machine:
`NEW → DETECTED|UPDATED → ASLEEP (15 min idle) → SITE_ALIVE → UPDATED`, plus `DESTROYED`.

## Verification

- Single-file lint: `luacheck -g --no-self --no-max-line-length src/<file>.lua`
- DB validation: `tools/validate_db.sh` (needs `lua5.1` + `luaunit` + `lfs` + `dcs-lua-datamine` clone)
- Doc gen: `tools/generate_docs.sh` (Python; `pip install -r tools/requirements.txt`)
- CI: `.github/workflows/deploy-pages.yml` — deploys `docs/web/` on push to main only

## Key Conventions

- New files go between existing numeric prefixes (e.g. `115 - Foo.lua` after `110`)
- Don't gate production logic on `HOUND.DEBUG` — compile flips it to `false`
- Don't put logic in `StopWatch` / `:Stop()` / `HOUND.Logger.trace("` lines — stripped at compile
- `DATAPOINTS_NUM = 30` hard FIFO cap per platform per emitter
- Pre-briefed contacts (`preBriefedContact`) bypass triangulation but still drive state machine

## Reference Docs (in repo root)

- `docs/architecture.md` — cycles, state machine, data flow
- `llm-integration-guide.md` — self-contained API + integration patterns
- `HOUND_API_REFERENCE.md` / `DEVELOPER_API_REFERENCE.md` — generated from source
- `llms.txt` — index of the above
