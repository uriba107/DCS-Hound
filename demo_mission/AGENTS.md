# DOX: demo_mission/ -- Demo Missions & Testing

## Purpose

Provide ready-to-use DCS World demo missions showcasing Hound ELINT features, plus a unit test harness for development validation.

## Ownership

This subtree owns all .miz demo missions, demo Lua scripts, unit test files, and supporting assets (CSV data, knee board images, MOOSE/IADS libraries).

## Local Contracts

### Mission Directories

- **`Caucasus_demo/`**: Basic demo on Caucasus map. Contains `HoundElint_demo.lua` (embedded script) and `HoundElint_demo.miz`.
- **`Syria_HARM/`**: Small-scale HARM-targeting demo on Syria (handful of SAMs, fly-and-feel). Includes CSV contact data, Apache scripts, knee board imagery. Runs on the developer's server.
- **`Syria_POC/`**: Scale POC Syrian Air Defense / GCI demo (dozens to hundreds of radars). Includes MOOSE library (`extras/Moose.lua`, ~9.5MB, gitignored) providing MANTIS IADS + EASYGCICAP + AUFTRAG/SPAWN.
- **`hound_unit_test/`**: Unit test suite using luaunit (`extras/luaunit.lua`). Tests cover init, comms, contacts, utils, delayed operations, sector, and worker. Owns `AGENTS.md` with operational knowledge (gotchas, patterns, constraints).

### Test Harness

- `hound_unit_test/extras/luaunit.lua` -- Lua unit testing framework (upstream, ~120KB).
- Test files are named `test-hound-*.lua` and loaded from `hound-unit-tests.lua`.
- Tests are run against source scripts loaded via `HoundElint_devel.lua` path conventions.
- `hound-unit-test-devel.miz` -- DCS mission that loads and runs the test suite.

## Work Guidance

- Demo missions should represent realistic use cases that users can load and fly immediately.
- Unit tests must not depend on DCS runtime features that can't be mocked.
- When adding new features to `src/`, add corresponding tests in `hound_unit_test/extras/`.
- .miz files are binary -- update the corresponding `.lua` script alongside the `.miz`.
- Large third-party libraries (MOOSE) in `extras/` should be documented but not edited.

## Verification

- Run `hound-unit-tests.lua` in a DCS environment or with a Lua 5.1 interpreter with DCS stubs.
- Tests use luaunit assertions (`assertEquals`, `assertTrue`, `assertNil`, etc.).
- Test count and pass/fail summary printed on completion.

## Child DOX Index

| Path | Scope | Owner |
|------|-------|-------|
| `hound_unit_test/` | Unit test suite — test files, orchestrator, README, miz mission, test framework | Developer |
| `Syria_HARM/` | HARM targeting demo — ELINT + Skynet IADS + Apache range, CSV contact data, kneeboard | Developer |
| `Syria_POC/` | Syria AD POC — Hound + MOOSE integration (MANTIS IADS, EASYGCICAP, AUFTRAG), Pikey's AD 2012 template, SEAD spawns | Developer |

### What stays owned by this doc

- Demo mission directory: `Caucasus_demo/` (flat, no child docs)
- Test harness metadata (naming conventions, loading mechanics, dev workflow)
