# DOX: demo_mission/hound_unit_test/ — Unit Test Suite

## Purpose

Validate Hound ELINT runtime behavior inside DCS World. Tests exercise Lua source loaded via the dev loader (`HoundElint_devel.lua`) inside a real DCS mission, covering unit-level utilities, emitter contact processing, full system lifecycle, delayed time-dependent behavior, and human-player radio comms.

## Ownership

- **`hound-unit-tests.lua`** — Batch orchestrator; schedules 6 test batches via `timer.scheduleFunction`
- **`hound-unit-test-devel.miz`** + **`hound-unit-test-devel/`** — DCS mission files (Mariana Islands)
- **`extras/test-*.lua`** — Per-domain test files loaded via `loadfile`
- **`extras/luaunit.lua`** — Test framework (vendored from `tools/testing/`, ~120KB, treat as read-only)
- **`README.md`** — Primary reference: timeline, per-file method tables, mission layout, running instructions, discrepancies

## Local Contracts

### Test Execution Model

- All tests run in the same DCS Lua state. **State persists across batches** — group states, Hound instances, contacts, settings carry forward. There is no reset between batches.
- Tests use `lu.LuaUnit.run('--pattern', 'PATTERN')` to select test methods by name pattern (e.g. `'02_base'`, `'Comms'`, `'2mDelay'`, `'6mDelay'`).
- Delayed assertions use `timer.scheduleFunction` — never blocking `timer.getTime()` loops. Use the polling pattern for assertions after events that have unpredictable timing.
- The Comms batch (pattern `Comms`) only runs after a human joins BLUE. It registers a `S_EVENT_BIRTH` handler and waits.

### DCS Lua Constraints

- No `require()` — use `loadfile()` with backslash paths for Windows.
- No `io` library — all diagnostics go through `env.info()` or `trigger.action.outText()`.
- `HOUND.Length` uses `pairs()`-based counting, not `#` operator (Lua 5.1 table length is unreliable for sparse tables).
- `populateRadioMenu()` creates **new table objects** each call — any reference to `.items` captured before a checkIn/checkOut is stale.

### Known Patterns & Gotchas

- **Comms menu state** (`test-hound-comms.lua`): `populateRadioMenu()` rebuilds the menu as a fresh table on each call — old references to `grpMenu.items.check_in` are stale after checkIn/checkOut. Always get a fresh reference from `saipan.comms.menu[player]` after state changes. `getRadioItemsText()` returns an array of site-data tables with `typeAssigned`, `dcsName`, `txt`, `pos`, and `emitters[]` keys.
- **Controller queue access**: `controller._queue` is a 3-element array for priority levels 1-3. Messages are plain tables with `coalition`, `priority`, `gid` (wrapped as `{groupId}` by addMessageObj), `contactId`, `tts`, and `txt` keys. Use `ipairs(controller._queue[N])` to iterate — `HOUND.Length` and `#` both work for this standard array. Messages are transient; the scheduler dequeues them asynchronously.
- **Flaky assertions** prefer **polling**: schedule a closure every 5s for 6 attempts (~30s window). On timeout, call `lu.assertStrContains(debugStr, expected)` with the current state to get a useful failure message.
- **Contact timing**: `CONTACT_TIMEOUT` = 900s; contact processing cycle runs every 30s.
- **BDA/destroyObject**: Repeated explosions with `pwr = life0 * 2` until `life <= 1`. Track radar (unit 2) is destroyed first because unit 1 is the search radar.
- **`printDebugging()` format**: `| Sites: %d | Contacts: %d (A:%d ,PB:%d)` — the `-1` adjustments track site removal, contact timeout, active loss, and pre-briefed count changes.

### Adding New Tests

1. Create or edit `extras/test-hound-<domain>.lua` with methods on the appropriate test class (`TestHoundFunctional`, `TestHoundUtils`, `TestHoundContact`, etc.).
2. Method names determine which batch runs them (pattern matching in `hound-unit-tests.lua`).
3. Register the file in the appropriate batch function in `hound-unit-tests.lua`.
4. If the test needs delayed assertions, use the polling pattern (see above).
5. Update `README.md` method tables and discrepancies.

## Work Guidance

- The README is the high-level reference (timeline, per-file method docs, mission layout). Keep it in sync with test changes.
- The AGENTS.md is the operational knowledge store (gotchas, patterns, TODO context, constraints). Update it when you discover a new gotcha or fix a longstanding one.
- `test-hound-worker.lua` covers `HOUND.ElintWorker` (500) and `HOUND.ElintWorker_queries` (501) with 49 test methods.
- Verify against `dcs.log` output — luaunit prints pass/fail/skip counts per batch.
- When debugging a single batch, you can comment out other batches in `hound-unit-tests.lua` to shorten the loop.

## Verification

- Load `hound-unit-test-devel.miz` in DCS and observe `dcs.log` for luaunit output.
- Each batch prints `Starting <name> testing (N/6)` and `Finished <name> Testing. Please check logs`.
- For Comms tests, join BLUE in an F-16C or Su-25T slot.
- No automated verification outside DCS — the tests depend on the DCS runtime (group/unit API, world events, timer).

## Child DOX Index

(none — files directly in this directory are the leaf level)
