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
- **TTS availability**: The test env loads no TTS engine, so `HOUND.Utils.TTS.isAvailable()` returns false and `enableTTS()`/TTS-transmit paths are no-ops. Tests exercising those paths must stub `HOUND.Utils.TTS.isAvailable = function() return true end` in `setUp` and restore the original in `tearDown` (pattern in `test-HoundCommsManager.lua` and `test-HoundContactSite.lua`).
- **Controller queue access**: `controller._queue` is a 3-element array for priority levels 1-3. Messages are plain tables with `coalition`, `priority`, `gid` (wrapped as `{groupId}` by addMessageObj), `contactId`, `tts`, and `txt` keys. Use `ipairs(controller._queue[N])` to iterate — `HOUND.Length` and `#` both work for this standard array. Messages are transient; the scheduler dequeues them asynchronously.
- **Flaky assertions** prefer **polling**: schedule a closure every 5s for 6 attempts (~30s window). On timeout, call `lu.assertStrContains(debugStr, expected)` with the current state to get a useful failure message.
- **Contact timing**: `CONTACT_TIMEOUT` = 900s; contact processing cycle runs every 30s.
- **Contact mocks**: `Base:hasPosData()` runs `ensurePosData()`, which calls `coalition.getMainRefPoint(self._platformCoalition)` and touches `pos.grid`/`pos.be`. Mock contacts that only stub `pos`/`hasPos` must also override `hasPosData` (e.g. `return self:hasPos()`), or set `_platformCoalition` plus `pos.grid`/`pos.be` — otherwise comms functions error with `Parameter #1 (coalition id) missed` or `attempt to index field 'pos' (a nil value)`.
- **`HoundUtils` is not a global**: src files alias it file-locally (`local HoundUtils = HOUND.Utils`). Tests must call `HOUND.Utils.*` (e.g. `HOUND.Utils.Dcs.copyPoint`) — bare `HoundUtils` is nil in the test state.
- **Dead DCS handles**: `coalition.getGroups` / `coalition.getStaticObjects` / `Group.getByName` can return objects that were already destroyed, and a live group can still contain destroyed units. Calling any method on such a handle raises `Group doesn't exist` (the error line points at the unguarded call). Use `HOUND.Utils.Dcs.isGroupAlive` / `isUnitAlive` / `isStaticObjectAlive` / `getGroupUnits` — not the bare `isGroup` / `isUnit` / `isStaticObject` type checks, which are for type tests only. `test-houndUtils.lua` mocks a dead handle with `deadHandle()`: metatable set to the DCS class (so `getmetatable` matches) and every method raising, so a bypassed guard fails loudly instead of silently passing.
- **Not every type check is a liveness check**: `HoundUtils.TTS.getTransmitterPos` returns `nil` (wrong type), `false` (destroyed transmitter) or a position — it must keep the bare `isUnit`/`isStaticObject` checks so the three-state contract survives. Same for `Emitter:isAlive()` and `onEvent`'s `S_EVENT_UNIT_LOST` gate, where the initiator is dead by definition.
- **BDA/destroyObject**: Repeated explosions with `pwr = life0 * 2` until `life <= 1`. Track radar (unit 2) is destroyed first because unit 1 is the search radar.
- **luaunit aliases**: the vendored luaunit exposes `assertNotNil` (alias of `assertNotIsNil`), `assertIsNil`, `assertTrue`, `assertFalse`, `assertTable`. `assertIsNotNil` does not exist and fails as `attempt to call field 'assertIsNotNil' (a nil value)`.
- **`__call` constructors**: production uses `HOUND.Matrix(...)` and `HOUND.Contact.Estimator.UPLKF(...)`. Cover the `__call` path in tests, not only `:new`/`:create` — a dropped receiver in `__call` is invisible to direct-method tests and only fails at runtime.
- **Fresh contact timing**: `last_seen`/`first_seen` are absolute `timer.getAbsTime()` stamps, copied from the primary emitter at `Site:New`. A just-created emitter/site is `isActive()`, `isRecent()` and not `isTimedout()`.
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
- `test-hound-worker.lua` covers `HOUND.ElintWorker` (500) and `HOUND.ElintWorker_queries` (501) with 62 test methods.
- **Constructor stubs**: `HOUND.Contact.Emitter.New` / `HOUND.Contact.Site.New` can be replaced with a nil-returning stub to test the "constructor bailed out" path of `addContact`/`addSite`. Always restore the original in the same test body (or `tearDown`) -- the suite shares one Lua state across batches.
- `HOUND.DB.getPlatformData` returns `nil` for invalidated DCS objects (not a Unit/StaticObject, or `isExist()` false). Callers must check the result before accessing platform fields (e.g. `pos`).
- Verify against `dcs.log` output — luaunit prints pass/fail/skip counts per batch.
- When debugging a single batch, you can comment out other batches in `hound-unit-tests.lua` to shorten the loop.

## Verification

- Load `hound-unit-test-devel.miz` in DCS and observe `dcs.log` for luaunit output.
- Each batch prints `Starting <name> testing (N/6)` and `Finished <name> Testing. Please check logs`.
- For Comms tests, join BLUE in an F-16C or Su-25T slot.
- No automated verification outside DCS — the tests depend on the DCS runtime (group/unit API, world events, timer).

## Child DOX Index

(none — files directly in this directory are the leaf level)
