# System Architecture

Technical reference for Hound ELINT internals.

---

## Overview

Hound is a **framework** allowing unlimited independent instances per mission. Each instance has its own coalition, platforms, contacts, and sectors.

```lua
HoundBlue1 = HoundElint:create(coalition.side.BLUE)
HoundBlue2 = HoundElint:create(coalition.side.BLUE)  -- Independent system
HoundRed = HoundElint:create(coalition.side.RED)
```

---

## Component Hierarchy

```
HoundElint Instance
├─ ElintWorker (ContactManager)
│  ├─ Platforms[]
│  ├─ Emitters{}  [unitName]
│  └─ Sites{}     [groupId]
└─ Sectors{}      [sectorName]
   ├─ Controller  (optional)
   ├─ ATIS        (optional)
   └─ Notifier    (optional)
```

---

## HoundElint Instance

Main interface object.

**Data:**

```lua
HoundId              -- Unique identifier
Coalition            -- BLUE, RED, NEUTRAL
contacts             -- HOUND.ContactManager (wraps ElintWorker)
sectors              -- {default = Sector, ...}
settings             -- Instance configuration
```

**Key Methods:**

- `addPlatform()` / `removePlatform()`
- `addSector()` / `removeSector()`
- `enableController()` / `enableAtis()` / `enableNotifier()`
- `systemOn()` / `systemOff()`

Instances are completely independent - no data sharing.

---

## ElintWorker

Core intelligence processor accessed via `HOUND.ContactManager.get(HoundId)`.

**Data:**

```lua
ElintWorker.platforms = {}  -- Array of DCS units
ElintWorker.contacts = {}   -- {[unitName] = Emitter}
ElintWorker.sites = {}      -- {[groupId] = Site}
```

**Processing Cycles:**

### Scan (~5 sec)

1. Query DCS for active enemy radars
2. For each radar + platform pair:
   - Check LOS
   - Calculate azimuth/elevation bearing
   - Create Datapoint with angular resolution
   - Add to Emitter.\_dataPoints[platformId]

### Process (~15 sec)

1. For each Emitter:
   - Triangulate from Datapoints
   - Calculate uncertainty ellipse
   - Update state (NEW → DETECTED → UPDATED → ASLEEP)
   - Update markers
2. For each Site:
   - Update from Emitters
   - Update markers
3. Cleanup timeouts

---

## Platforms

DCS units (aircraft, ground, static) assigned for detection.

**Detection:**

- **LOS required** - Terrain blocking applies
- **Angular resolution** - From antenna size in HOUND.DB
- **Bearing** - Azimuth + elevation (aerial only)
- **Passive only** - No emissions

Platform loss = lose future bearings, existing data remains.

---

## Emitters

`HOUND.Contact.Emitter` - One per detected radar unit.

**Key Fields:**

```lua
-- Identification
uid                 -- Track ID (ContactId or Unit ID)
DcsObject           -- DCS unit reference
DcsGroupName        -- For site grouping
typeName            -- Radar name

-- Classification (from HOUND.DB)
typeAssigned        -- Array: {"SA-2", "SA-3", "SA-5"}
isPrimary           -- Primary tracking radar?
radarRoles          -- {SEARCH, TRACK, ...}
isEWR               -- Early warning radar?

-- Detection
_dataPoints         -- {[platformId] = {Datapoint[]}}
detected_by         -- Platform names[]
state               -- NEW|DETECTED|UPDATED|ASLEEP|DESTROYED
first_seen          -- Timestamp
last_seen           -- Timestamp

-- Position
pos                 -- {p, LL, grid, be, elev}
uncertenty_data     -- {major, minor, theta, az, r}
preBriefed          -- Exact position known?

-- Capabilities
maxWeaponsRange     -- SAM range
detectionRange      -- Radar range
band                -- Frequency band
frequency           -- {[false]=search, [true]=track}
```

**Lifecycle:**

```
NEW → DETECTED → UPDATED → ASLEEP (15min timeout) → DESTROYED
  ↑________________↓
```

**Triangulation:**

- Intersect bearing lines from multiple platforms
- Weight by: angular resolution, signal strength, geometry, time
- Uncertainty from: platform count, geometry, resolution, distance

**Pre-Briefed:**

```lua
HoundInstance:preBriefedContact("SA6_Site", "Alpha")
```

Position known exactly, no uncertainty, still tracks state.

---

## Sites

`HOUND.Contact.Site` - SAM batteries/radar groups.

Created when first Emitter from a DCS Group detected.

**Key Fields:**

```lua
-- Identification
gid                  -- DCS Group ID
DcsObject            -- DCS Group reference
DcsGroupName         -- Group name
DcsRadarUnits        -- Radar units in group (BDA only)

-- Emitters (detected radars ONLY)
emitters             -- Emitter[]
primaryEmitter       -- Best radar (tracking preferred)
typeAssigned         -- SAM types[] (via intersection)

-- Status
state                -- SITE_NEW|SITE_UPDATED|SITE_ASLEEP|...
first_seen           -- Timestamp
last_seen            -- Max of emitters
last_launch_notify   -- Launch alert cooldown
preBriefed           -- Any emitter pre-briefed?

-- Position (from emitters)
pos                  -- From available emitters

-- Capabilities (max from emitters)
maxWeaponsRange      -- Engagement range
detectionRange       -- Detection range
isEWR                -- From primary emitter
```

**Type Refinement via Intersection:**

```lua
-- From Site:updateTypeAssigned()
local type = self.primaryEmitter.typeAssigned
if HOUND.Length(type) > 1 then
    for _,emitter in ipairs(self.emitters) do
        type = HOUND.setIntersection(type, emitter.typeAssigned)
    end
end
Site.typeAssigned = type
```

**Example:**

```
P-19 detected:
  → typeAssigned = {"SA-2", "SA-3", "SA-5"}
  → Display: "SA-2 or SA-3 or SA-5"

Fan Song added:
  → typeAssigned = intersection({"SA-2", "SA-3", "SA-5"}, {"SA-2"})
  → typeAssigned = {"SA-2"}
  → Display: "SA-2"
```

**DCS Group Usage:**

- Group ID for emitter grouping
- `hasRadarUnits()` for BDA checks
- Reference only - does NOT auto-track all radars in group

Sites contain ONLY detected Emitters.

---

## Sectors

Geographic/organizational subdivisions within instance.

Every instance creates "default" sector automatically.

**Structure:**

```lua
Sector.name          -- "default", "North", etc.
Sector.callsign      -- Radio callsign
Sector.zone          -- DCS trigger zone (optional)
Sector.comms         -- {controller, atis, notifier}
```

**Zone Behavior:**

- No zone = all contacts visible
- With zone = only contacts inside
- Multiple zones = highest priority

**Communications per sector (must enable):**

```lua
HoundInstance:enableController("North", {freq = "251.000", modulation = "AM"})
HoundInstance:enableAtis("North", {freq = "253.000", modulation = "AM"})
HoundInstance:enableNotifier("North", {freq = "243.000", modulation = "AM"})
```

---

## Communication Systems

All inherit from `HOUND.Comms.Manager`. Per-sector, must be enabled.

### Controller

F10 radio menu for on-demand queries. Player requests radar info, gets TTS+text response with type, position, status, accuracy.

### ATIS

Broadcasts continuously in loop on frequency. Message content updates every 120 sec (configurable via `setAtisUpdateInterval()`).

**Timing:**

- Transmission scheduler: 4 sec interval (readTime + 4 sec)
- Content refresh: 120 sec (or configured)

Players tune in anytime for current threat summary.

### Notifier

Real-time alerts: launch warnings, BDA, new threats. Typically on guard frequency.

---

## System Timing

| Process     | Default | Purpose                          |
| ----------- | ------- | -------------------------------- |
| **Scan**    | 5 sec   | Query DCS for radars             |
| **Process** | 15 sec  | Triangulate, update state        |
| **Markers** | 120 sec | Refresh F10 markers              |
| **Menu**    | 30 sec  | Rebuild F10 menus                |
| **ATIS**    | 120 sec | Update message (broadcasts loop) |

Configure via `setTimerInterval("scan", 10)` etc.

---

## Detection Data Flow

```
1. Radar active
   ↓
2. Scan: Query DCS, find radar
   ↓
3. For each platform: Check LOS → Calculate bearing → Create Datapoint → Add to Emitter
   ↓
4. Emitter created (NEW) or updated → Triggers HOUND.EVENTS.RADAR_NEW
   ↓
5. Site created (first radar in group) → Triggers HOUND.EVENTS.SITE_NEW
   ↓
6. Process: Triangulate → Calculate uncertainty → State: NEW → DETECTED → Triggers HOUND.EVENTS.RADAR_DETECTED
   ↓
7. Assign to sector based on position/zones
   ↓
8. Output: Markers, Controller menu, ATIS (next cycle), Notifier alert, Events
```

---

## Key Behaviors

**Geometry Impact:**

- Perpendicular platforms: small uncertainty
- Parallel platforms: large uncertainty

**Accuracy Progression:**

- Initial: ±2 km
- 2 min: ±800 m
- 5 min: ±300 m
- 10 min: ±150 m

**Platform Loss:**

- Lose future bearings from destroyed platform
- Existing data persists
- Creates strategic value for ELINT assets

**Framework Design:**

- Multiple instances supported (no limit per coalition)
- Instances independent (separate platforms, contacts, sectors)
- Sectors optional (default only for simple missions)
- Communications optional (works with markers only)

---

## Performance

| Scenario        | Instances      | Platforms                        | Radars |
| --------------- | -------------- | -------------------------------- | ------ |
| **PvE**         | 1              | 2-4 dedicated + dynamic fighters | Varies |
| **PvP**         | 2 (Blue + Red) | 2-4 dedicated + dynamic fighters | Varies |
| **Stress test** | 1+             | 2-4 dedicated + dynamic fighters | ~900   |

**Notes:**

- Datapoint cap (`HOUND.DATAPOINTS_NUM = 30`) limits memory per Emitter
- **Radar count is primary performance factor**, not platform count
- Hound core processing: ~2ms per position update cycle (even with ~900 radars)
- **MP performance bottlenecks:**
  - STTS transmission handling
  - DCS script execution
  - Map marker updates (DCS limitation)
  - May cause lags in some scenarios

**Optimization:**

- Increase scan/process intervals
- Reduce marker update frequency (biggest impact in MP)
- Disable unnecessary communications
- Use sectors to divide workload

---

## See Also

- [API Index](api-index.md) - All methods and parameters
- [How It Works](how-it-works.md) - Triangulation deep dive
- [Event Handlers](event-handlers.md) - Custom scripting
