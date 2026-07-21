# Hound ELINT Unit Test Suite

Tests the Hound ELINT system for DCS World. Runs inside the `hound-unit-test-devel.miz` mission on the **Mariana Islands** map using `luaunit` (at `tools/testing/luaunit.lua`, vendored to `extras/luaunit.lua`).

## How It Runs

The mission trigger loads `hound_loader.lua` 1s after start, which loads `HoundElint_devel.lua` (dev-mode source), then `hound-unit-tests.lua`. The orchestrator schedules six sequential test batches via `timer.scheduleFunction`.

## Timeline

Batches run in order; each sets a `next_test_delay` before the next fires.

| # | Batch | Pattern | Test File(s) | Delay to Next |
|---|-------|---------|-------------|---------------|
| 1 | **Modules** | (all) | `test-houndUtils.lua`, `test-HoundContactEmitter.lua`, `test-HoundContactSite.lua`, `test-HoundSector.lua`, `test-hound-worker.lua`, `test-HoundCommsManager.lua`, `test-HoundCoroutine.lua` | 10s |
| 2 | **Init** | `01_init` | `test-hound-init.lua` | 15s |
| 3 | **Base** | `02_base` | `test-hound-base.lua` | 2 min |
| 4 | **2m Delay** | `2mDelay` | `test-hound-delayed.lua` | 2 min |
| 5 | **UI/Comms** | `Comms` | `test-hound-comms.lua` | 2 min |
| 6 | **6m Delay** | `6mDelay` | `test-hound-delayed.lua` | 0 |

Total wall-clock time: ~6 minutes plus test execution. Batches share the same Lua state — group states, Hound instances, contacts, and settings persist across batches.

The **UI/Comms** batch (5) is special: it registers a `world.event` handler for `S_EVENT_BIRTH` and prints a message asking the player to jump into an aircraft slot. Once a human client spawns, the Comms tests fire after a 10s delay. Without a player slot, this batch never runs.

## Test Files

### `test-houndUtils.lua` — TestHoundUtils

147 test methods covering utility functions, mapping, geo, elint, vector, marker, polygon/cluster, TTS, text, zone, Hound globals, sort, and filter. Runs in batch 1.

**Timing & General**

| Method | What It Tests |
|--------|--------------|
| `TestabsTimeDelta` | `HOUND.Utils.absTimeDelta` accuracy |
| `TestangleDeltaRad` | Shortest-angle delta in radians (nil guard, general cases, wrap-around) |
| `TestAzimuthAverage` | Circular mean of azimuth lists (quadrant transitions, 0/360 wrap) |
| `TestAzimuthAverageEmpty` | Empty/nil input → nil |
| `TestRandomAngle` | Non-determinism and `[0, 2π)` bounds |
| `TestNormalizeAngle` | `normalizeAngle` across all quadrants and negatives |
| `TestGetCoalitionString` | `getCoalitionString` returns "BLUE"/"RED" etc. |
| `TestGetControllerResponse` | `getControllerResponse` guard/invalid cases |
| `TestGetNormalAngularError` | `getNormalAngularError` returns value |

**IDs, Counters, Formatting**

| Method | What It Tests |
|--------|--------------|
| `TestGetHoundId` | Sequential ID increment |
| `TestGetMarkId` | Sequential mark ID increment |
| `TestSetInitialMarkId` | Guard: non-number/nil → false |
| `TestGetMarkIdIncrement` | Marker creation increments ID |
| `TestGetReportId` | Phonetic-alphabet cycling through Z→A wrap |
| `TestGetRoundedElevationFt` | Meter-to-feet rounding (50 m → 150 ft, 8848 m → 29050 ft) |
| `TestRoundToNearest` | Rounding to granularity (5, 10, 50, 100, 500, 1000) |
| `TestDecToDMS` | Decimal degrees → DMS + hemisphere |
| `TestUseDMM` / `TestUseMGRS` | DMM/MGRS formatting booleans |

**Mapping**

| Method | What It Tests |
|--------|--------------|
| `TestGetMappingClamp` | `clamp` min/max behavior |
| `TestMappingLinear` | `linear` interpolation and extrapolation |
| `TestMappingLinearClamp` | Linear with clamp, min>max swapped |
| `TestMappingNonLinearDefaults` | NonLinear table defaults |
| `TestMappingNonLinearOutRange` | Out-of-range x values |
| `TestMappingNonLinearSensitivity` | Sensitivity param variations |
| `TestMappingNonLinearCurves` | All 7 curve types return correct values |

**DCS Accessors**

| Method | What It Tests |
|--------|--------------|
| `TestDcs` | `isPoint`, `isGroup`, `isUnit`, `isStaticObject` type guards on live units |
| `TestDcsIsHuman` | Non-human unit → false |
| `TestDcsIsRadarTracking` | Non-tracking → nil/empty |
| `TestDcsGetGroupNames` | Group list with prefix match |
| `TestDcsGetGroupNamesNoPrefix` | Group list without prefix |
| `TestDcsGetUnitNames` | Unit list |
| `TestDcsGetStaticObjectNames` | Static object list |
| `TestDcsGetPlayersInvalid` | Invalid coalition → nil |
| `TestDcsGetPlayersInGroupInvalid` | Invalid group → nil |
| `TestGetFormationCallsign` | Guard/invalid/empty cases |
| `TestGetFormationCallsignEmpty` | Empty callsign fallback |
| `TestGetFormationCallsignInvalid` | Invalid input → nil |
| `TestGetFormationCallsignNoCallsign` | No callsign set → nil |
| `TestGetHoundCallsign` | `getHoundCallsign` returns expected |
| `TestHasPayload` | `hasPayload` guard |
| `TestHasTask` | `hasTask` guard |

**Copy & Geo**

| Method | What It Tests |
|--------|--------------|
| `TestCopyPoint` | Normal point copy |
| `TestCopyPointInvalid` | Nil → nil |
| `TestCopyPointXY` | Swap z→y |
| `TestCopyPointZY` | Swap x→z, y→x |
| `TestSqDist2D` | Squared 2D distance (valid + invalid) |
| `TestSqDist2DInvalid` | Invalid inputs → nil |
| `TestGet2DDistance` | 2D distance between two points |
| `TestGet3DDistance` | 3D distance (valid + invalid) |
| `TestGeoDistanceInvalid` | Nil → 0 |
| `TestGeoSetPointHeight` | Set height on {x,z} point |
| `TestGeoSetPointHeightWithOffset` | Height + offset |
| `TestGeoSetHeight` | Table of {x,z} points |
| `TestGeoSetHeightSingle` | Single {x,z} point |
| `TestGeoSetHeightNonPoint` | Non-point table → unchanged |
| `TestEarthLOS` | All LoS visible (mariana coords) |
| `TestEarthLOSNoArgs` | No args → nil |
| `TestEarthLOSPartial` | Mixed visible/obscured |
| `TestGetMagVar` | Magnetic variation (valid + invalid) |
| `TestGetMagVarInvalid` | Bad coords → 0 |
| `TestGetBR` | Bearing/range (valid + invalid) |
| `TestGetBRInvalid` | Invalid → nil |

**Elint / Radar**

| Method | What It Tests |
|--------|--------------|
| `TestGenerateAngularError` | Non-zero angular error |
| `TestGenerateAngularErrorZero` | Zero-precision → zero error |
| `TestGetSignalStrength` | Positive signal strength |
| `TestGetSignalStrengthInvalid` | Nil → nil |
| `TestElintDB` | DB band lookup, frequency ranges, aperture, diffraction, sensor precision, callsign pools |
| `TestGetEmitterBand` | Band enum lookup |
| `TestGetEmitters` | Emitter list from DB |
| `TestElintGetAzimuth` | Azimuth between ELINT plane and emitter |
| `TestGetActiveRadarsInGroup` | Active radar units (valid + invalid) |
| `TestGetRadarDetectionRange` | Detection range from live units |
| `TestGetRadarUnitsInGroup` | Radar units in group |
| `TestGetSamMaxRange` | SAM max range from live units |
| `TestGetSamRange` | SAM range from live units |

**Vector**

| Method | What It Tests |
|--------|--------------|
| `TestGetUnitVector` | Horizontal unit vector |
| `TestGetUnitVectorNoArgs` | No args → nil |
| `TestGetUnitVectorWithElevation` | 3D unit vector with elevation |
| `TestGetRandomVec2` | Random 2D vec in bounds |
| `TestGetRandomVec2Invalid` | Invalid → nil |
| `TestGetRandomVec3` | Random 3D vec in bounds |
| `TestGetRandomVec3Invalid` | Invalid → nil |

**Marker**

| Method | What It Tests |
|--------|--------------|
| `TestMarkerCreate` | Create, id = -1, isDrawn false, remove |
| `TestMarkerCreateWithArgs` | Create with text/pos/coalition, isDrawn true, remove |

**Polygon / Cluster**

| Method | What It Tests |
|--------|--------------|
| `TestGaussianKernel` | `gaussianKernel` single point |
| `TestPolygonGaussianKernelMulti` | Multiple gaussianKernel calls |
| `TestPointClusterTilt` | Cluster tilt calculation |
| `TestPointClusterTiltInvalid` | Invalid → 0 |
| `TestPointClusterTiltWithRef` | Tilt relative to reference |
| `TestThreatOnSectorInvalidPolygon` | `threatOnSector` with bad polygon → nil |
| `TestThreatOnSectorInvalidPoint` | `threatOnSector` with bad point → nil |
| `TestThreatOnSectorInside` | Point inside polygon → true, true |
| `TestThreatOnSectorOutside` | Point outside polygon → false, false |
| `TestThreatOnSectorWithRadius` | Point near polygon with radius overlap |
| `TestAzMinMaxInvalidRef` | `azMinMax` with bad ref → nil |
| `TestAzMinMaxInvalidPoly` | `azMinMax` with bad poly → nil |
| `TestAzMinMaxRefInside` | Ref inside polygon → nil |
| `TestAzMinMaxValid` | Valid poly + ref → returns deltaMinMax, minAz, maxAz |
| `TestGetDeltaSubsetPercent` | Percentile subset from point list |
| `TestGetDeltaSubsetPercentEmpty` | Empty table → empty |
| `TestGetDeltaSubsetPercentSingle` | Single point → same point |
| `TestWeightedCentroid` | Weighted average of scored positions |
| `TestWeightedCentroidNoScores` | Zero-score points → origin |
| `TestWeightedCentroidEmpty` | Empty list → origin |

**Hound Globals**

| Method | What It Tests |
|--------|--------------|
| `TestHoundLength` | `pairs`-based table length |
| `TestHoundSetContains` | Set membership |
| `TestHoundSetContainsValue` | Value in set |
| `TestHoundShallowCopy` | Table shallow copy |
| `TestHoundSetIntersection` | Set intersection |
| `TestHoundReverseLookup` | Value-to-key reverse |
| `TestHoundGaussian` | Gaussian PDF output |
| `TestHoundClamp` | Numeric clamp |
| `TestHoundMixedGaussian` | Mixed Gaussian sum |
| `TestHoundSetMgrsPresicion` | MGRS precision setter |
| `TestHoundShowExtendedInfo` | Extended info toggle |
| `TestHoundGetInstance` | Instance registry lookup |
| `TestStringSplit` | `string.split` delimiter parsing |

**Sort**

| Method | What It Tests |
|--------|--------------|
| `TestSortContactsById` | Ascending ID sort |
| `TestSortContactsByRange` | Ascending range sort |
| `TestSortContactsByPrio` | Priority sort (all fields populated) |
| `TestSortContactsByPrioDetectFallback` | Priority sort with fallback tiebreaker |
| `TestSortSectorsByPriority` | Sector priority low-first and low-last |

**Filter**

| Method | What It Tests |
|--------|--------------|
| `TestFilterFunctions` | `groupsByPrefix`, `unitsByPrefix`, `staticObjectsByPrefix` (incl non-string guard) |

**TTS**

| Method | What It Tests |
|--------|--------------|
| `TestTTSAvailable` | `isAvailable` returns false (empty engine) |
| `TestTTSDecToDMS` | Decimal → DMS with N/S/E/W |
| `TestTTSDecToDMSMinDec` | Minute decimals |
| `TestTTSDecToDMSPadDeg` | Zero-padded degrees |
| `TestTTSGetCardinalDirection` | All 8 cardinal directions |
| `TestTTSGetCardinalDirectionWrap` | Wrap-around at 360° |
| `TestTTSGetReadTime` | String read time estimate |
| `TestTTSGetReadTimeNil` | Nil → 0 |
| `TestTTSGetReadTimeSpeed` | Speed multiplier affects time |
| `TestTTSGetReadTimeString` | String vs table input |
| `TestTTSGetReadTimeGoogle` | Google TTS rate |
| `TestTTSGetVerbalConfidenceEdge` | Edge cases (0/0.5/1.0) |
| `TestTTSGetVerbalContactAge` | Seconds/minutes/hours verbal |
| `TestTTSGetVerbalContactAgeEdge` | Boundary transitions |
| `TestTTSGetVerbalLLNorthEast` | N/E hemisphere verbal LL |
| `TestTTSGetVerbalLLSouth` | S/W hemisphere verbal LL |
| `TestTTSGetVerbalLLVariants` | Format variants |
| `TestSimplifyDistance` | Distance rounding for TTS output |
| `TestToPhonetic` | NATO phonetic alphabet |
| `TestTtsTime` | Time-of-day verbal format |
| `TestGetDefaultModulation` | Default AM/FM |
| `TestGetDefaultModulationFallback` | Invalid → AM |
| `TestGetVerbalConfidenceLevel` | Confidence string lookup |

**Text**

| Method | What It Tests |
|--------|--------------|
| `TestTextGetLL` | DMS/DMM coordinate formatting |
| `TestTextGetTime` | 24h time formatting |

**Zone**

| Method | What It Tests |
|--------|--------------|
| `TestZone` | Drawn-zone polygon + group-route-as-zone |
| `TestZoneInvalid` | Invalid name → nil |

### `test-HoundContactEmitter.lua` — TestHoundContact, TestHoundContactEmitter, TestHoundEmitterComms

Contact model unit tests for `HOUND.Contact.Emitter` — integration tests with real DCS units, unit-level emitter logic, folded Base sector/event/queue tests, and mocked comms helpers. Runs in batch 1.

**TestHoundContact** — Integration-style emitter tests with TOR_SAIPAN-1:

| Method | What It Tests |
|--------|--------------|
| `TestLocation` | Create Emitter from TOR_SAIPAN-1, get azimuth/elevation from two C-17 platforms, compute signal strength, add datapoints, triangulate position within 0.75 m accuracy |
| `TestLocationErr` | Same geometry but includes sensor-precision error in azimuth, checks wavelength range |
| `TestPreBriefed` | `isAccurate`/`getPreBriefed`/`setPreBriefed` toggle |
| `TestExport` | `export()` returns table with typeName, uid, pos, LL, accuracy, uncertenty, maxWeaponsRange |

**TestHoundContactEmitter** — `HOUND.Contact.Emitter` + folded Base sector/event/queue coverage:

| Method | What It Tests |
|--------|--------------|
| `TestConstructorInvalid` | Nil, wrong types → nil |
| `TestEmitterTypes` | Tor, 55G6 EWR, KIROV ship, SA-5 search/track — all create valid Emitter with correct typeAssigned, isEWR, name |
| `TestLife` | `getLife` returns positive HP and percentage ≤ 1.0 |
| `TestSetDead` | `setDead` flips `isAlive` false, preserves state |
| `TestDestroy` | `destroy` sets RADAR_DESTROYED and queues event |
| `TestWavelength` | `getWavelenght` returns search and track frequency numbers |
| `TestElevNoPos` | `getElev` returns 0 when no position set |
| `TestGetIdMod` | `getId` returns uid % 100; custom ContactId respected |
| `TestTrackId` | `getTrackId` returns "E" (estimated) or "I" (accurate/pre-briefed) |
| `TestCleanTimedout` | Stale contact (`last_seen` > CONTACT_TIMEOUT) → RADAR_ASLEEP, datapoints cleared |
| `TestCleanTimedoutFresh` | Fresh contact → state unchanged, datapoints preserved |
| `TestCountPlatformsEmpty` | New contact: 0 platforms, 0 datapoints |
| `TestUseUnitPos` | `useUnitPos` sets RADAR_DETECTED, accurate, uncertenty=(0.1,0.1,0,0.1), pos set |
| `TestCalculatePolyInvalid` | Nil/missing uncertenty fields → empty polygon |
| `TestCalculatePoly` | 8-point ellipse from {major=200,minor=100,az=45} — all points have x,z,y |
| `TestCalculatePolyRefPosDefault` | `calculatePoly` with no refPos defaults to origin |
| `TestTriangulatePoints` | Two synthetic datapoints at 45°/135° → intersection with x,z,y,score |
| `TestCalculateExtrasPosData` | `calculateExtrasPosData` fills LL, elev, grid, be from a DCS point |
| `TestProcessDataPreBriefed` | Pre-briefed + active + not moved → processData returns nil (early exit) |
| `TestExportWithPos` | `export` includes pos, LL, accuracy, uncertenty |
| `TestExportWithoutPos` | `export` without position → pos and accuracy nil |
| `TestProcessIntersection` | Two non-overlapping datapoints → one intersection result |
| `TestProcessIntersectionSkipSamePos` | Same-position datapoints → no intersection (early exit) |
| `TestProcessDataWithDatapoints` | Two mobile datapoints added via `AddPoint` → `processData` returns some state |
| `TestDcsAccessors` | `getDcsObject`, `getDcsName`, `getDcsGroupName` on Emitter |
| `TestEventQueue` | `queueEvent` stores events, `getEventQueue` returns them (folded from Base) |
| `TestQueueNoChange` | `NO_CHANGE` events are discarded (folded from Base) |
| `TestSectorDefaults` | Primary sector "default", `isInSector` true for default, one sector total (folded from Base) |
| `TestAddRemoveSector` | `addSector`/`removeSector`, `isThreatsSector` (folded from Base) |
| `TestUpdateSector` | `updateSector` changes primary sector, threat flags, fallback to next sector (folded from Base) |
| `TestSectorNilArgs` | Nil inSector/threatsSector → no-op, no sector created (folded from Base) |
| `TestDefaultSectorFallback` | Removing all named sectors restores default (folded from Base) |
| `TestRemoveMarkers` | Smoke test — `removeMarkers` runs without error (folded from Base) |
| `TestGetTextDataNoPos` | `getTextData`/`getTtsData` return nil when no position (folded from Base) |

**TestHoundEmitterComms** — `HOUND.Contact.Emitter` comms helpers (mocked):

| Method | What It Tests |
|--------|--------------|
| `testTtsBriefNoPos` | TTS brief with no position |
| `testTtsBriefNoUncertenty` | TTS brief with position but no uncertenty |
| `testTtsBriefNonNATO` | TTS brief non-NATO designation |
| `testTtsBriefNATO` | TTS brief NATO designation |
| `testTtsBriefAccurate` | TTS brief accurate position |
| `testTtsBriefAccurateNATO` | TTS brief accurate + NATO |
| `testTtsBriefNotAccurateIncludesAge` | TTS brief adds age for non-accurate |
| `testTtsReportNoPos` | TTS report with no position |
| `testTtsReportNotAccurate` | TTS report not accurate |
| `testTtsReportAccurate` | TTS report accurate |
| `testTtsReportWithRefPos` | TTS report with ref pos |
| `testTtsReportPreferMGRS` | TTS report prefers MGRS format |
| `testTtsReportUseDMM` | TTS report uses DMM format |
| `testTtsReportEndsWithControllerResponse` | TTS report ends with controller response |
| `testTextReportNoPos` | Text report with no position |
| `testTextReportNotAccurate` | Text report not accurate |
| `testTextReportAccurate` | Text report accurate |
| `testTextReportWithRefPos` | Text report with ref pos |
| `testTextReportUseDMM` | Text report uses DMM format |
| `testPopUpReportAccurate` | Pop-up report accurate |
| `testPopUpReportNotAccurate` | Pop-up report not accurate |
| `testPopUpReportWithSector` | Pop-up report with sector label |
| `testPopUpReportTTSPos` | Pop-up report TTS with position |
| `testPopUpReportTextPos` | Pop-up report text with position |
| `testPopUpReportNoPos` | Pop-up report with no position |
| `testDeathReport` | Death report |
| `testDeathReportWithSector` | Death report with sector label |
| `testDeathReportTTSPos` | Death report TTS with position |
| `testDeathReportTextPos` | Death report text with position |
| `testDeathReportNoPos` | Death report with no position |
| `testGetRadioItemText` | Radio item text for emitter |
| `testGetRadioItemTextNoPos` | Radio item text with no position |
| `testIntelBrief` | Intel brief |
| `testIntelBriefNoPos` | Intel brief with no position |

**TestHoundContactDatapoint** — `HOUND.Contact.Datapoint` coverage (10 methods):

| Method | What It Tests |
|--------|--------------|
| `TestConstructorInvalid` | Datapoint.New with bad args gracefully handled |
| `TestConstructorValid` | All args, metatable, field values |
| `TestConstructorStatic` | `isPlatformStatic=true` → kalman created, az updated |
| `TestIsStaticFalse` | Non-static → false |
| `TestIsStaticTrue` | Static → true |
| `TestGetAge` | `getAge` returns number >= 0 |
| `TestUpdateStatic` | Static datapoint `update` returns new az |
| `TestUpdateNonStaticNoPrecision` | No precision → update returns nil |
| `TestGetPosNoAzNoEl` | No az/el → nil |
| `TestGetPosStatic` | Static datapoint → kalman value (may be nil without terrain) |

### `test-HoundContactSite.lua` — TestHoundContactSite, TestHoundSiteComms

Contact model unit tests for `HOUND.Contact.Site` — unit-level site logic with real DCS units, and mocked site comms helpers. Runs in batch 1.

**TestHoundContactSite** — `HOUND.Contact.Site` coverage:

| Method | What It Tests |
|--------|--------------|
| `TestConstructorInvalid` | Nil, wrong types → nil |
| `TestConstructorValid` | Valid construction, metatable, SITE_NEW state |
| `TestConstructorWithId` | Custom SiteId → `getId` returns id % 1000 |
| `TestName` | Default "T" + id, `setName` custom, `setName(nil)` clears |
| `TestEWRName` | EWR-based Site uses "S" prefix |
| `TestTypeAndId` | `getType`, `getId` return strings/numbers |
| `TestDcsAccessors` | `getDcsObject` returns Group, `getDcsGroupName`, `getDcsName` |
| `TestInitialState` | SITE_NEW, not accurate, alive, not timedout, active, recent |
| `TestEmitterMgmt` | `countEmitters`=1, `getPrimary`=torContact, `getEmitters` list |
| `TestAddSameGroupEmitter` | Duplicate add → NO_CHANGE, count unchanged |
| `TestRemoveEmitter` | Remove emitter → count 0 |
| `TestRemoveNonMemberEmitter` | Remove non-member → count unchanged |
| `TestHasRadarUnits` | `hasRadarUnits` true for Tor group |
| `TestUpdateTypeAssigned` | `updateTypeAssigned` returns a string |
| `TestUpdatePos` | After emitter `useUnitPos`, `updatePos` copies pos |
| `TestEnsurePrimaryHasPos` | No emitter pos, no refPos → no site pos; after emitter `useUnitPos`, pos propagates |
| `TestEnsurePrimaryHasPosRefPos` | No emitter pos, valid refPos → site pos set from refPos |
| `TestUpdate` | `update` aggregates last_seen, maxWeaponsRange, detectionRange |
| `TestProcessData` | `processData` calls `update` without error |
| `TestDestroy` | `destroy` runs without error |

**TestHoundSiteComms** — `HOUND.Contact.Site` comms helpers (mocked):

| Method | What It Tests |
|--------|--------------|
| `TestGetRadioItemTextNoPos` | Radio item text with no position |
| `TestGetRadioItemTextWithPos` | Radio item text with position |
| `TestGetRadioItemsText` | Multi-emitter radio items list |
| `TestGetRadioItemsTextSkipsEmittersNoPos` | Emitters without position skipped |
| `TestGetRadioItemsTextPrimaryPrefix` | Primary emitter marked in output |
| `TestGeneratePopUpReportNoPosNoSector` | Pop-up report no position, no sector |
| `TestGeneratePopUpReportWithSector` | Pop-up report with sector label |
| `TestGeneratePopUpReportTTSWithPos` | Pop-up report TTS with position |
| `TestGeneratePopUpReportTextWithPos` | Pop-up report text with position |
| `TestGeneratePopUpReportWithSectorNoPos` | Pop-up report sector but no position |
| `TestGeneratePopUpReportNoSectorNoPosLocation` | Pop-up report no sector, no pos, no location |
| `TestGenerateDeathReport` | Death report |
| `TestGenerateDeathReportWithSector` | Death report with sector label |
| `TestGenerateDeathReportTTSWithPos` | Death report TTS with position |
| `TestGenerateDeathReportTextWithPos` | Death report text with position |
| `TestGenerateDeathReportNoPos` | Death report with no position |
| `TestGenerateAsleepReport` | Asleep report |
| `TestGenerateAsleepReportWithSector` | Asleep report with sector label |
| `TestGenerateAsleepReportTTSWithPos` | Asleep report TTS with position |
| `TestGenerateAsleepReportNoPos` | Asleep report with no position |
| `TestGenerateLaunchAlert` | Launch alert |
| `TestGenerateLaunchAlertWithSector` | Launch alert with sector label |
| `TestGenerateLaunchAlertTTS` | Launch alert TTS |
| `TestGenerateIdentReport` | Ident report |
| `TestGenerateIdentReportWithSector` | Ident report with sector label |
| `TestGenerateIdentReportTTSWithPos` | Ident report TTS with position |
| `TestGenerateIdentReportNoPos` | Ident report with no position |
| `TestGetDesignationNATO` | Site designation with NATO flag |
| `TestGetDesignationNoNATO` | Site designation without NATO |
| `TestGenerateTtsBriefNoPos` | TTS brief no position |
| `TestGenerateTtsBriefAccurate` | TTS brief accurate position |
| `TestGenerateTtsBriefNotAccurate` | TTS brief not accurate |
| `TestGenerateTtsBriefNATO` | TTS brief NATO designation |
| `TestGenerateTtsBriefNaval` | TTS brief naval site |
| `TestGenerateIntelBrief` | Intel brief with emitters |
| `TestGenerateIntelBriefEmptyEmitters` | Intel brief with no emitters |
| `TestExport` | Site export with emitters |
| `TestExportNoEmitters` | Site export with no emitters |

### `test-hound-init.lua` — TestHoundFunctional (init)

HoundElint instance lifecycle, singleton config, platform management. Runs in batch 2 (pattern `01_init`).

| Method | What It Tests |
|--------|--------------|
| `Test_01_init_00_unitSetup` | Configure all red groups: emission off, ROE open fire, alarm state RED, engage air weapons off. Groups: TOR_SAIPAN (1), SA-5_SAIPAN (8), EWR_SAIPAN (1), SHIPS_NORTH (2), SA-6_TINIAN (5), SA-3_TINIAN (6) |
| `Test_01_init_01_BadInit` | `HoundElint:create()` with no coalition returns nil |
| `Test_01_init_02_BlueInit` | Create BLUE instance, verify id=1, coalition, immutability, instance registry |
| `Test_01_init_03_RedInit` | Create RED instance, verify id=2, both instances registered |
| `Test_01_init_04_ConfigSingelton` | Instances have independent settings; `settings` is same object across subsystems; `setMarkerType` propagates |
| `Test_01_init_05_HoundStartup` | `systemOn()`/`isRunning()` lifecycle |
| `Test_01_init_06_PlatformMgmt` | `addPlatform`/`removePlatform` with validation, `listPlatforms`, `countPlatforms` |
| `Test_01_init_06_destroy` | `destroy()` removes from registry, clears references, stops running |

### `test-hound-base.lua` — TestHoundFunctional (base)

Full system initialization, comms, sectors, zones, sites, event handler. Runs in batch 3 (pattern `02_base`). Builds on state from batch 2.

| Method | What It Tests |
|--------|--------------|
| `Test_02_base_00_unitSetup` | Re-configure groups (same as init, but SA-3_TINIAN is **not** included here) |
| `Test_02_base_01_Init` | Create BLUE instance, add 2 C-17 platforms + StaticTower (then remove it), set marker type, systemOn |
| `Test_02_base_02_controllers` | ATIS (15s interval), TTS controller (251.000/35.000 MHz), Notifier, text enable, NATO toggle, white-box ATIS message text |
| `Test_02_base_03_turnRadarsOn` | Enable emission on all red groups (TOR, SA-5, EWR, SHIPS, SA-6), verify radar state |
| `Test_02_base_04_Multi_Sector` | Add "Saipan" sector with separate controller/ATIS frequencies, disable default controller/ATIS, enable notifier, set callsign to "OPTIMUS", configure transmitter |
| `Test_02_base_05_Multi_Sector_zone` | Add "Tinian" sector, set zone from automatic drawing or manual route, remove/reset zones |
| `Test_02_base_06_radio_menu` | Radio menu parenting, purge, populate, restore |
| `Test_02_base_07_prebriefed` | `preBriefedContact` single unit and bad name |
| `Test_02_base_08_sites` | Site grouping via pre-briefed contacts: SA-3_TINIAN search radar + track radar + launchers become a Site; type identification ("SA-2 or SA-3" → "SA-3"); custom site naming; popup report generation |
| `Test_02_base_09_eventHandler` | User-overridable `onHoundEvent` callback |
| `Test_02_base_10_human_elint` | Register event handler for `S_EVENT_BIRTH` to auto-add human aircraft as ELINT platforms |

### `test-hound-delayed.lua` — TestHoundFunctional (delayed)

Time-dependent behavior: BDA, site lifecycle, ATIS content, launch detection. Two sub-batches.

**2m Delay** (runs at ~2 min, pattern `2mDelay`):

| Method | What It Tests |
|--------|--------------|
| `Test_2mDelay_00_updateBaseline` | Capture `baseUnitCount` from `printDebugging()` |
| `Test_2mDelay_01_debugOutput` | Prebrief more contacts (TOR, EWR), toggle emission on SA-5 + TOR, schedule delayed assertions at +90s for contact state changes |
| `Test_2mDelay_02_Sector` | List all sites, verify metatable |
| `Test_2mDelay_03_EventHandler` | Wire `onHoundEvent` for RADAR_DESTROYED, SITE_ASLEEP, SITE_REMOVED, verify group/site lifecycle |
| `Test_2mDelay_04_destroy` | Enable BDA mode, destroy SA-5_SAIPAN-2 (track radar) via repeated explosions |
| `Test_2mDelay_05_ships` | Enable emission on SHIPS_NORTH |

**6m Delay** (runs at ~6 min, pattern `6mDelay`):

| Method | What It Tests |
|--------|--------------|
| `Test_6mDelay_00_updateBaseline` | Re-capture baseline after 2m-delay events |
| `Test_6mDelay_01_preBriefed` | Enable TOR emission, on-screen debug, verify contact count changes |
| `Test_6mDelay_02_exports` | `dumpIntelBrief()` smoke test |
| `Test_6mDelay_03_boats` | ATIS message contains ship names "Kirov (CG)" and "Moskva (CG)" |
| `Test_6mDelay_04_shoot` | Activate MQ-9 UAV, enable SA-6 emission, force SAM brain to know target via `knowTarget()`, verify `S_EVENT_SHOT` and `SITE_LAUNCH` events |

### `test-hound-comms.lua` — TestHoundFunctional (comms)

Human-player radio comms. Only runs after a human spawns (batch 5, pattern `Comms`).

| Method | What It Tests |
|--------|--------------|
| `Test_Comms_00_HumanUnitsFunctions` | `updateHumanDb`, `getPlayersInGroup`, player lookup |
| `Test_Comms_01_CheckIn` | Check-in flow: verify menu items, `Sector.checkIn`, enrollment count |
| `Test_Comms_02_MenuItems` | List radio items for sector, verify keys `{'SA-3', 'Naval'}` |
| `Test_Comms_03_CommsMenu` | Menu structure: verify grpMenu.items/objs/pages, check_in shows "Check out", type-assigned submenus exist |
| `Test_Comms_04_RequestReport` | `TransmitSamReport`: verify message added to controller queue with correct coalition, priority, contactId, tts |
| `Test_Comms_05_TinianCheckIn` | Tinian sector: enable controller, check in, verify enrollment and menu items |
| `Test_Comms_06_DefaultSector` | Default sector fallback: verify contacts, no zone, `isNotifiying` state |
| `Test_Comms_07_TransmitAck` | `TransmitCheckInAck`/`TransmitCheckOutAck`: verify queue messages have correct fields |
| `Test_Comms_09_CheckOut` | Check-out flow: verify menu updates, enrollment cleared |

### `test-HoundSector.lua` — TestHoundSector

Sector model unit tests covering construction, callsign, zone, child sectors, transmitter, notifications, radio menu helpers, and contact/site delegation. Runs in batch 1.

**Constructor & Basic Getters:**

| Method | What It Tests |
|--------|--------------|
| `TestConstructorInvalid` | Nil, wrong types, missing args → nil |
| `TestConstructorValid` | Valid construction, metatable, name, default priority 10, initial callsign "HOUND", empty childSectors, nil settings |
| `TestConstructorWithPriority` | Custom priority 5 |
| `TestConstructorWithSettings` | Settings table `{foo = "bar"}` stored on instance |
| `TestGetName` | `getName` returns constructor name |
| `TestGetPriority` | `getPriority` returns 10 (default) |
| `TestGetCallsignDefault` | `getCallsign` returns "HOUND" for default sector |

**Callsign:**

| Method | What It Tests |
|--------|--------------|
| `TestSetCallsign` | `setCallsign("ALPHA")` updates callsign and registers in settings pool |
| `TestSetCallsignNATO` | `setCallsign("BRAVO", true)` with NATO flag |
| `TestSetCallsignBoolArg` | `setCallsign(true)` treats bool as NATO flag, generates random callsign |
| `TestSetCallsignNoDuplicate` | Duplicate callsign generates a new one from the pool |
| `TestSetCallsignNil` | `setCallsign()` with no args generates random callsign |

**Zone:**

| Method | What It Tests |
|--------|--------------|
| `TestZoneDefaults` | New sector: getZone nil, hasZone false, getCenter nil |
| `TestSetGetZone` | Manually set zone → hasZone true, getZone returns zone |
| `TestRemoveZone` | `removeZone` clears zone, hasZone false |
| `TestGetCenter` | `getCenter` returns zoneCenter when set |

**Child Sectors:**

| Method | What It Tests |
|--------|--------------|
| `TestChildSectorAddRemove` | Add multiple children, verify has/get, remove one, verify state |
| `TestChildSectorReserved` | `addChildSector` works on default sector (no reserved-name restriction) |
| `TestHasNoChildSectors` | Empty childSectors: hasChildSectors false, hasChildSector false |

**Transmitter:**

| Method | What It Tests |
|--------|--------------|
| `TestSetRemoveTransmitter` | `setTransmitter` stores name, `removeTransmitter` clears it |

**Notification Routing:**

| Method | What It Tests |
|--------|--------------|
| `TestShouldNotifyForDefault` | "default" sector with non-default primary → true + label |
| `TestShouldNotifyForDefaultDefault` | "default" sector with "default" primary → true, no label |
| `TestShouldNotifyForSelf` | Same name → true, no label |
| `TestShouldNotifyForChild` | Child sector in list → true + label |
| `TestShouldNotifyForNoMatch` | No match → false, nil |
| `TestShouldNotifyForDifferentSector` | Different name, no child → false |

**Effective Sector Names:**

| Method | What It Tests |
|--------|--------------|
| `TestEffectiveSectorNamesDefault` | No zone, no children → `{"default"}` |
| `TestEffectiveSectorNamesWithZone` | Zone set → `{self.name}` |
| `TestEffectiveSectorNamesWithChildSectors` | Children present → list of child names |

**Contact/Site Delegation (with mock ContactManager):**

| Method | What It Tests |
|--------|--------------|
| `TestContactSiteHelpersEmpty` | `getContacts`, `countContacts`, `getSites`, `countSites` with empty mock |
| `TestContactSiteHelpersNoContacts` | Mock contact manager returns tables without errors |

**Radio Menu Helpers:**

| Method | What It Tests |
|--------|--------------|
| `TestFindGrpInPlayerList` | `findGrpInPlayerList` filters by groupId with explicit player list |
| `TestFindGrpInPlayerListNoList` | `findGrpInPlayerList` uses `enrolled` when no list provided |
| `TestGetSubscribedGroups` | `getSubscribedGroups` extracts unique group IDs from enrolled |
| `TestGetSubscribedGroupsEmpty` | Empty enrolled → empty list |
| `TestRemoveRadioMenu` | `removeRadioMenu` clears root and enrolled |

**Transmission:**

| Method | What It Tests |
|--------|--------------|
| `TestGetTransmissionAnnounce` | `getTransmissionAnnounce` returns a non-empty string |
| `TestGetTransmissionAnnounceByIndex` | Specific index returns message containing callsign |
| `TestTransmitOnControllerNoController` | No controller → no-op, returns nil |
| `TestTransmitOnNotifierNoNotifier` | No notifier → no-op, returns nil |

**isNotifiying:**

| Method | What It Tests |
|--------|--------------|
| `TestIsNotifiyingNoComms` | No controller or notifier → false |
| `TestIsNotifiyingWithControllerNoSettings` | Controller without enabled settings → false |

**Settings & Services:**

| Method | What It Tests |
|--------|--------------|
| `TestUpdateServicesNoOps` | `updateServices` with no comms/zone/transmitter set → no crash |
| `TestUpdateSettings` | `updateSettings({priority = 3})` stores value |
| `TestUpdateSettingsCommsKeys` | `updateSettings` creates controller/atis/notifier sub-tables with freq and name |
| `TestUpdateSettingsAtisNotifier` | `updateSettings` with atis + notifier creates both sub-tables |
| `TestValidateEnrolledEmpty` | `validateEnrolled` with empty enrolled → no crash |

**Notify Guards (no controller → no-op):**

| Method | What It Tests |
|--------|--------------|
| `TestNotifyGuardsNoNotifier` | All 6 notify methods (dead/new/identified/launching) return early without crashing |

**Destroy:**

| Method | What It Tests |
|--------|--------------|
| `TestDestroy` | `destroy` clears radio menu and enrolled list |

### `test-hound-worker.lua` — TestHoundWorker

Worker and query unit tests covering `HOUND.ElintWorker` (500) and `HOUND.ElintWorker_queries` (501). Runs in batch 1.

**Constructor & Properties:**

| Method | What It Tests |
|--------|--------------|
| `TestCreate` | Valid construction, metatable, default fields |
| `TestCreateWithId` | Instance gets unique sequential ID |
| `TestGetNewTrackId` | `getNewTrackId` counter increments |
| `TestGetId` | `getId` returns instance ID |

**Coalition:**

| Method | What It Tests |
|--------|--------------|
| `TestSetCoalition` | `setCoalition` stores coalition integer |
| `TestSetCoalitionTwice` | Idempotent — second call is no-op |
| `TestSetCoalitionInvalid` | Invalid/nil input → returns without setting |
| `TestGetCoalitionDefault` | `getCoalition` returns nil before set |

**Platforms:**

| Method | What It Tests |
|--------|--------------|
| `TestCountPlatformsZero` | New worker: 0 platforms |
| `TestCountPlatformsAfterInsert` | `countPlatforms` returns platform table length |
| `TestListPlatforms` | `listPlatforms` returns table with `getName` iteration |

**Tracked/Contact/Site Lookups:**

| Method | What It Tests |
|--------|--------------|
| `TestIsTrackedNil` | `isTracked(nil)` → false |
| `TestIsTrackedByString` | `isTracked` by unit name string |
| `TestIsTrackedByTable` | `isTracked` by table with `DcsObject:getName()` |
| `TestIsContactNil` | `isContact(nil)` → false |
| `TestIsContactByString` | `isContact` by unit name string |
| `TestIsContactByTable` | `isContact` by table with `DcsObject:getName()` |
| `TestIsSiteNil` | `isSite(nil)` → false |
| `TestIsSiteByString` | `isSite` by group name string |
| `TestGetContactNil` | `getContact(nil)` → nil |
| `TestGetContactByString` | `getContact` by unit name |
| `TestGetSiteNil` | `getSite(nil)` → nil |

**Remove Contact/Site:**

| Method | What It Tests |
|--------|--------------|
| `TestRemoveContactByString` | Remove by unit name (table or string) |
| `TestRemoveContactByEmitterTable` | Remove by emitter object reference |
| `TestRemoveContactInvalidType` | Invalid type (number, nil) → no-op, returns false |
| `TestRemoveSiteByString` | Remove site by group name string |
| `TestRemoveSiteBySiteTable` | Remove site by site object reference |
| `TestRemoveSiteInvalidType` | Invalid type → no-op, returns false |

**Query — Contacts (501):**

| Method | What It Tests |
|--------|--------------|
| `TestCountContacts` | Total contact count via `HOUND.Length` (pairs-based) |
| `TestCountContactsWithSector` | Sector-filtered count |
| `TestGetContacts` | `getContacts` returns unordered table |
| `TestGetContactsEmpty` | Empty contacts → empty table |
| `TestGetContactsWithSector` | Sector-filtered get returns table |
| `TestListAllContacts` | `listAllContacts` converts table to sequential list |
| `TestListAllContactsByRange` | `listAllContactsByRange` removes, sorts, re-inserts |
| `TestListAllContactsWithSector` | Sector-filtered list |
| `TestListContactsInSector` | `listContactsInSector` returns table for sector |
| `TestListContactsInSectorEmpty` | Unknown sector → empty table |
| `TestSortContacts` | `sortContacts` sorts list by comparator |
| `TestSortContactsInvalidFunc` | Invalid comparator → no-op |

**Query — Sites (501):**

| Method | What It Tests |
|--------|--------------|
| `TestCountSites` | Total site count |
| `TestCountSitesWithSector` | Sector-filtered site count |
| `TestGetSites` | `getSites` returns unordered table |
| `TestGetSitesWithSector` | Sector-filtered get returns table |
| `TestListAllSites` | `listAllSites` converts to sequential list |
| `TestListAllSitesByRange` | `listAllSitesByRange` removes, sorts, re-inserts |
| `TestListAllSitesWithSector` | Sector-filtered list |
| `TestSortSites` | `sortSites` sorts list by comparator |
| `TestSortSitesInvalidFunc` | Invalid comparator → no-op |

### `test-HoundCommsManager.lua` — TestHoundCommsManager, TestHoundCommsInformationSystem

Comms infrastructure unit tests for `HOUND.Comms.Manager` (400) and `HOUND.Comms.InformationSystem`/ATIS (410). Runs in batch 1.

**TestHoundCommsManager** — `HOUND.Comms.Manager` coverage (48 methods):

| Method | What It Tests |
|--------|--------------|
| `TestCreateNilConfig` | Nil houndConfig → nil |
| `TestCreateNilSector` | Nil sector → nil |
| `TestCreateWithSettings` | Settings merged on create |
| `TestCreateDefaultFreq` | Default freq 250.000 |
| `TestIsEnabledDefault` | Enabled false by default |
| `TestEnable` | Enable sets enabled true, schedules pump |
| `TestDisable` | Disable clears scheduler, sets enabled false |
| `TestUpdateSettings` | `updateSettings` merges freq/name into settings |
| `TestUpdateSettingsPreferences` | `updateSettings` routes enabletts/alerts to preferences |
| `TestSetSettings` | `setSettings` by key |
| `TestGetSettings` | Unknown key returns nil |
| `TestEnableText` | `enableText` → preferences.enabletext true |
| `TestDisableText` | `disableText` → preferences.enabletext false |
| `TestEnableTTS` | `enableTTS` no-op (TTS unavailable) |
| `TestEnableAlerts` | `enableAlerts` → preferences.alerts true |
| `TestDisableAlerts` | `disableAlerts` → preferences.alerts false |
| `TestGetCallsignDefault` | Default "Hound" |
| `TestSetCallsign` | `setCallsign("BRAVO")` → getCallsign "BRAVO" |
| `TestSetCallsignInvalid` | Non-string → unchanged |
| `TestGetFreqDefault` | `getFreq` returns formatted string |
| `TestGetFreqs` | `getFreqs` returns table with freq + modulation |
| `TestGetFreqsMulti` | Multiple freqs/modulations |
| `TestAddMessageObj` | `addMessageObj` adds to queue |
| `TestAddMessageObjDisabled` | No-op when disabled |
| `TestAddMessageObjNoCoalition` | No-op without coalition |
| `TestAddMessageObjNoContent` | No-op without tts/txt |
| `TestAddMessageObjPriorityClamp` | Priority > 3 clamped to 3 |
| `TestAddMessageObjPriorityZero` | Priority 0 → 1, push=true |
| `TestAddMessageObjPriorityLoop` | Priority "loop" → stored in self.loop.msg |
| `TestAddMessageObjContactIdDedup` | Same gid+contactId updates existing |
| `TestAddMessageObjGidTable` | gid number → wrapped in table |
| `TestAddMessageObjGidTableAlready` | gid table kept as table |
| `TestAddMessageObjPush` | push flag → inserted at position 1 |
| `TestAddMessage` | `addMessage` adds tts message at priority 3 |
| `TestAddMessageNil` | Nil msg → no-op |
| `TestAddTxtMsg` | `addTxtMsg` adds txt message |
| `TestAddTxtMsgEmpty` | Empty msg → no-op |
| `TestGetNextMsg` | Returns highest priority first |
| `TestGetNextMsgEmpty` | Empty queue → nil |
| `TestTransmitterDefault` | Transmitter nil by default |
| `TestSetRemoveTransmitter` | Set/remove transmitter by name |
| `TestSetTransmitterInvalid` | Unknown name → unchanged |
| `TestGetAliasDefault` | Alias nil by default |
| `TestSetAlias` | `setAlias("Guard")` → getAlias "Guard" |
| `TestStartCallbackLoop` | Abstract → returns nil |
| `TestStopCallbackLoop` | Abstract → returns nil |
| `TestSetMsgCallback` | Abstract → returns nil |
| `TestRunCallback` | Abstract → returns nil |

**TestHoundCommsInformationSystem** — `HOUND.Comms.InformationSystem`/ATIS coverage (10 methods):

| Method | What It Tests |
|--------|--------------|
| `TestCreateValid` | Metatable, inherits Manager, freq 250.500, interval 4, reportewr false |
| `TestCreateWithSettings` | Settings passed through to create |
| `TestReportEWR` | `reportEWR(true/false)` toggles setting |
| `TestReportEWRInvalid` | Non-boolean → unchanged |
| `TestStopCallbackLoop` | Clears loop state and callback |
| `TestSetMsgCallback` | Stores func/args, starts callback scheduler |
| `TestSetMsgCallbackNoFunc` | Nil func → no-op |
| `TestRunCallback` | Calls func, returns next time |
| `TestGetNextMsgOverride` | Calls runCallback if no loop.msg |
| `TestGetNextMsgNoMsg` | No callback → returns nil |

### `test-HoundCoroutine.lua` — TestHoundCoroutine

Coroutine scheduler unit tests for `HOUND.Coroutine` (011). Runs in batch 1.

| Method | What It Tests |
|--------|--------------|
| `TestAddInvalidFunc` | Nil func → returns nil |
| `TestAddValid` | Valid func → returns id, _list has entry, _running true |
| `TestAddWithOpts` | Name/interval opts stored in _list |
| `TestAddWithArgs` | Extra args passed to func |
| `TestAddMultiple` | 3 coroutines → count is 3 |
| `TestCancelNil` | Nil id → false |
| `TestCancelValid` | Add then cancel → true, count decreases |
| `TestCancelUnknown` | Unknown id → false |
| `TestCancelByNameInvalid` | Non-string name → 0 removed |
| `TestCancelByNameValid` | 2 with name "A", 1 with name "B" → cancelByName("A") returns 2 |
| `TestCancelByNameNone` | Name not found → 0 |
| `TestIsRunningFalse` | No coroutines → false |
| `TestIsRunningTrue` | Active coroutine → true |
| `TestIsRunningDead` | Finished coroutine → false |
| `TestCountZero` | Empty → 0 |
| `TestCountNonZero` | Add 2 → 2 |
| `TestHasWorkFalse` | Empty → false |
| `TestHasWorkTrue` | Has entries → true |
| `TestShutdown` | Clear all state |

## Mission Layout

All red-force units on Saipan and Tinian islands (Mariana Islands map).

| Group | Type | Size | Location |
|-------|------|------|----------|
| TOR_SAIPAN | Tor 9A331 | 1 | Saipan |
| SA-5_SAIPAN | S-200 (1x RLS_19J6, 1x RPC_5N62V, 6x S-200_Launcher) | 8 | Saipan |
| EWR_SAIPAN | 55G6 EWR | 1 | Saipan |
| SA-6_TINIAN | Kub (1x 1S91 str, 4x 2P25 ln) | 5 | Tinian |
| SA-3_TINIAN | S-125 (1x P-19 sr, 1x SNR S-125 tr, 4x 5P73 ln) | 6 | Tinian |
| SHIPS_NORTH | PIOTR + MOSKVA | 2 | NE of Saipan |

Blue ELINT platforms: C-17A `ELINT_BLUE_C17_EAST` and `ELINT_BLUE_C17_WEST` (orbiting at 35,000 ft), plus E-3A AWACS (`ELINT_BLUE_E3_EAST`, `ELINT_BLUE_E3_WEST`). Client aircraft: F-16C (`Aerial-1`) and Su-25T (`Aerial-2`) at Andersen AFB. Late-activated MQ-9 `MQ-9_TGT` used as SA-6 target. Static TV tower `StaticTower` at south Saipan. CH-47D `Sector_Saipan` route defines sector boundaries.

Drawn zone: **"Tinian Sector"** polygon (Author layer).

## Running the Tests

1. Copy the `.miz` to your DCS `Missions` folder (or symlink).
2. Set `HoundWorkDir` in `hound_loader.lua` and `hound-unit-tests.lua` to your project path (backslashes for Lua on Windows).
3. Load the mission in DCS as a multiplayer server (or SP with a second client for Comms tests).
4. Watch `dcs.log` for LuaUnit output. Each batch prints start/finish and pass/fail/skip counts.
5. For Comms tests, a human player must join BLUE in an F-16C or Su-25T slot.

## Discrepancies and Notes

1. **Tinian Sector point count** (`test-houndUtils.lua:263`): Asserts `HOUND.Length(zone) == 15`. The raw mission file has 16 points (keys 1–16, with points 1 and 16 at `{x=0,y=0}`). Whether DCS runtime exposes 15 or 16 points depends on how `trigger.misc.getUserDrawings()` handles the origin-matching start/end points. Verify at runtime.

2. **Empty test stubs**: (none — all fillable stubs are now implemented)

3. **Commented-out assertions**:
   - `test-HoundContactEmitter.lua` — Polygon clipping and `posPolygon` assertions (`TestLocationErr` body) remain commented out.
   - `test-houndUtils.lua:26` — An azimuth-average test case is commented out.

4. **`test-hound-comms.lua:Test_Comms_02_MenuItems`**: Uses `for k,v in menuItems do` (not `pairs()`/`ipairs()`) which may not work as expected in standard Lua — rely on `Test_Comms_03` for menu structure coverage.

5. **Redundant class**: `TestHoundFunctionalBase` in `test-hound-base.lua` has the same setUp/tearDown as `TestHoundFunctional` and only one exclusive test method (`Test_02_base_00_unitSetup`). All other `02_base` tests are on `TestHoundFunctional`.

6. **Contact file restructuring**: `test-HoundContact.lua` was split into `test-HoundContactEmitter.lua` (TestHoundContact + TestHoundContactEmitter + TestHoundEmitterComms + Base sector/event/queue tests folded into Emitter) and `test-HoundContactSite.lua` (TestHoundContactSite + TestHoundSiteComms). The TestHoundContactBase class was eliminated — its sector/event/queue tests moved to TestHoundContactEmitter. `test-HoundEmitterComms.lua` and `test-HoundSiteComms.lua` were folded into the respective class files.

## Fixes Applied

| Issue | File | Change |
|-------|------|--------|
| EWR emission not turned on | `test-hound-base.lua:176` | Changed `sa5:enableEmission(true)` to `ewr:enableEmission(true)` |
| SA-3_TINIAN missing from base batch | `test-hound-base.lua:55–59` | Added SA-3_TINIAN group setup to `Test_02_base_00_unitSetup` |
| Comms checkin/checkout stale menu refs | `test-hound-comms.lua:42,100` | Re-fetch `grpMenu.items.check_in` after `populateRadioMenu()` creates new tables |
| Flaky printDebugging assertions | `test-hound-delayed.lua` | Replaced single-shot `delayTest` with polling (5s retry, 6 attempts ≈ 30s window) in `Test_2mDelay_01_debugOutput`, `Test_6mDelay_01_preBriefed`, `Test_6mDelay_04_shoot`, and the `SITE_REMOVED` handler |
| SITE_REMOVED wrong field mapping | `test-hound-delayed.lua:140–144` | Format args used `platforms`/`sectors`/`zones`/`controllers` instead of `sites`/`contacts`/`active`/`preBriefed`; `-1` adjustments were appended past the 4th `%d` and silently ignored |
| Filename case mismatch | `hound-unit-tests.lua:45` | `test-houndContact.lua` → `test-HoundContact.lua` to match actual filename (case-insensitive on NTFS, but inconsistent) |
| Contact file restructuring | `test-HoundContact.lua`, `test-HoundEmitterComms.lua`, `test-HoundSiteComms.lua` | Split into `test-HoundContactEmitter.lua` + `test-HoundContactSite.lua`; obsolete files deleted |
