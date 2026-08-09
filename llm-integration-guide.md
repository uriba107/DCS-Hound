# Hound ELINT — LLM Integration Guide

Everything needed to integrate the Hound ELINT radar detection system into a DCS World mission. This document is self-contained — no other files required.

*Generated on: 2026-08-09 23:24:52*

---

## What is Hound ELINT?

Hound is a radar detection and tracking system for DCS World. It detects enemy radar emitters using ELINT platforms (aircraft, ground stations), triangulates their positions, and provides intelligence via:

- **F10 map markers** with uncertainty ellipses
- **Voice radio** (TTS via SRS) — interactive Controller and automated ATIS
- **Text messages** — in-game text popups
- **Data exports** — Lua tables and CSV files

**Key concepts:**

| Concept | Description |
|---------|-------------|
| **Instance** | One Hound system per coalition (`HoundBlue`, `HoundRed`) |
| **Platform** | DCS unit that collects radar signals (C-130, tower, etc.) |
| **Contact** | Detected radar emitter with estimated position |
| **Site** | Group of related radars (e.g., SA-6 with TR + SR) |
| **Sector** | Geographic region with separate comms channels; can be nested as meta-sectors |
| **Controller** | Interactive F10 radio menu for on-demand intel |
| **ATIS** | Automated periodic threat broadcast |
| **Notifier** | Alert broadcasts (new threats, launches, BDA) |

---

## Setup Requirements

### Mission Editor Triggers

**Trigger 1** (TYPE: ONCE, CONDITION: TIME MORE 1):
1. DO SCRIPT FILE: `DCS-SimpleTextToSpeech.lua` *(only if using voice)*
2. DO SCRIPT FILE: `HoundElint.lua`

**Trigger 2** (TYPE: ONCE, CONDITION: TIME MORE 2):
1. DO SCRIPT: *(your Hound configuration code)*

### Mission Units

Place at least 2 ELINT platform units (for triangulation):
- Aircraft: C-130, C-17, EA-6B, EA-18G, RC-135, etc.
- Ground: Comms Tower M (static object on high ground)
- Use the exact **unit name** (not group name) when calling `addPlatform()`

---

## API Quick Reference

### Instance Management

| Method | Parameters | Returns | Description |
|--------|------------|---------|-------------|
| `HoundElint:create()` | `platformName` (int) | tab | Create HoundElint instance. |
| `HoundElint:destroy()` | — | — | Destructor function initiates cleanup |
| `HoundElint:getId()` | — | Int | Get Hound instance ID |
| `HoundElint:getCoalition()` | — | int | Get Hound instance Coalition |
| `HoundElint:setCoalition()` | `side` (int) | bool | Set coalition for Hound Instance (Internal) |
| `HoundElint:onScreenDebug()` | `value` (bool) | Bool | Set onScreenDebug |
| `HoundElint:systemOn()` | — | — | Turn Hound system on |
| `HoundElint:systemOff()` | — | — | Turn Hound system off |
| `HoundElint:isRunning()` | — | bool | Is Instance on |

### Platform Management

| Method | Parameters | Returns | Description |
|--------|------------|---------|-------------|
| `HoundElint:addPlatform()` | — | bool | Add platform from hound instance |
| `HoundElint:removePlatform()` | — | bool | Remove platform from hound instance |
| `HoundElint:countPlatforms()` | — | int | Count Platforms |
| `HoundElint:listPlatforms()` | — | tab | List platforms |

### Detection & Contacts

| Method | Parameters | Returns | Description |
|--------|------------|---------|-------------|
| `HoundElint:countContacts()` | `sectorName` (string) | int | Count contacts |
| `HoundElint:countActiveContacts()` | `sectorName` (string) | Int | Count Active contacts |
| `HoundElint:countPreBriefedContacts()` | `sectorName` (string) | int | Count preBriefed contacts |
| `HoundElint:preBriefedContact()` | `DCS_Object_Name` (string), `codeName` (opt) | — | Set/create a pre Briefed contacts |
| `HoundElint:markDeadContact()` | `radarUnit` (string|tab) | — | Mark Radar as dead |
| `HoundElint:AlertOnLaunch()` | `fireUnit` (string|tab) | — | Issue a Launch Alert |
| `HoundElint:countSites()` | `sectorName` (string) | int | Count sites |

### Sector Management

| Method | Parameters | Returns | Description |
|--------|------------|---------|-------------|
| `HoundElint:addSector()` | `sectorName` (string), `sectorSettings` (opt), `priority` (opt) | bool | Add named sector |
| `HoundElint:removeSector()` | `sectorName` (string) | bool | Remove Named sector |
| `HoundElint:updateSectorSettings()` | `sectorName` (string|nil), `subSettingName` (string) | bool | Update named sector settings |
| `HoundElint:listSectors()` | `element` (string) | list | List all sectors |
| `HoundElint:getSectors()` | `element` (string) | list | Get all sectors |
| `HoundElint:countSectors()` | `element` (string) | int | Return number of sectors |
| `HoundElint:getSector()` | — | HOUND.Secto | Return HOUND.Sector instance |
| `HoundElint:getZone()` | `sectorName` (string) | table | Get zone of sector |
| `HoundElint:setZone()` | `sectorName` (string), `DCS` (zoneCandidate) | — | Add zone to sector same as MOOSE. use late activation invisible helicopter gr... |
| `HoundElint:removeZone()` | `sectorName` (string) | — | Remove zone from sector |
| `HoundElint:addChildSector()` | `metaSectorName` (string), `childSectorName` (string) | — | Add a child sector to a meta-sector |
| `HoundElint:removeChildSector()` | `metaSectorName` (string), `childSectorName` (string) | — | Remove a child sector from a meta-sector |
| `HoundElint:updateSectorMembership()` | — | — | Update sector membership for all contacts |

### Controller

| Method | Parameters | Returns | Description |
|--------|------------|---------|-------------|
| `HoundElint:enableController()` | `sectorName` (string) | — | Enable controller in sector |
| `HoundElint:disableController()` | `sectorName` (string) | — | Disable controller in sector |
| `HoundElint:removeController()` | `sectorName` (string) | — | Remove controller in sector |
| `HoundElint:configureController()` | `sectorName` (string) | — | Configure controller in sector |
| `HoundElint:getControllerFreq()` | `sectorName` (string) | frequncies | Get controller freq |
| `HoundElint:getControllerState()` | `sectorName` (string) | Bool | Get controller state |
| `HoundElint:transmitOnController()` | `sectorName` (string), `msg` (string), `priority` (number) | — | Transmit custom TTS message on controller freqency |

### ATIS

| Method | Parameters | Returns | Description |
|--------|------------|---------|-------------|
| `HoundElint:setAtisUpdateInterval()` | `desired` (value) | true | Set Atis Update interval |
| `HoundElint:enableAtis()` | `sectorName` (string) | — | Enable ATIS in sector |
| `HoundElint:disableAtis()` | `sectorName` (string) | — | Disable ATIS in sector |
| `HoundElint:removeAtis()` | `sectorName` (string) | — | Remove ATIS in sector |
| `HoundElint:configureAtis()` | `sectorName` (string) | — | Configure ATIS in sector |
| `HoundElint:getAtisFreq()` | `sectorName` (string) | frequncies | Get ATIS freq |
| `HoundElint:reportEWR()` | `name` (string) | — | Set ATIS EWR report state for sector |
| `HoundElint:getAtisState()` | `sectorName` (string) | Bool | Get ATIS state |

### Notifier

| Method | Parameters | Returns | Description |
|--------|------------|---------|-------------|
| `HoundElint:enableNotifier()` | `sectorName` (string) | — | Enable Notifier in sector Only one notifier is required as it will broadcast ... |
| `HoundElint:disableNotifier()` | `sectorName` (string) | — | Disable Notifier in sector |
| `HoundElint:removeNotifier()` | `sectorName` (string) | — | Remove Notifier in sector |
| `HoundElint:configureNotifier()` | `sectorName` (string) | — | Configure Notifier in sector |
| `HoundElint:getNotifierFreq()` | `sectorName` (string) | frequncies | Get Notifier freq |
| `HoundElint:getNotifierState()` | `sectorName` (string) | Bool | Get Notifier state |
| `HoundElint:transmitOnNotifier()` | `sectorName` (string), `msg` (string), `priority` (number) | — | Transmit custom TTS message on Notifier freqency |

### Map Markers

| Method | Parameters | Returns | Description |
|--------|------------|---------|-------------|
| `HoundElint:enableMarkers()` | `markerType` (opt) | Bool | Enable Markers for Hound Instance (default) |
| `HoundElint:disableMarkers()` | — | Bool | Disable Markers for Hound Instance |
| `HoundElint:enableSiteMarkers()` | — | Bool | Enable Site Markers for Hound Instance (default) |
| `HoundElint:disableSiteMarkers()` | — | Bool | Disable Site Markers for Hound Instance |
| `HoundElint:setMarkerType()` | `valid` (markerType) | Bool | Set marker type for Hound instance |

### Settings & Configuration

| Method | Parameters | Returns | Description |
|--------|------------|---------|-------------|
| `HoundElint:setTimerInterval()` | `interval` (setIntervalName), `interval` (setValue) | Bool | Set intervals |
| `HoundElint:enablePlatformPosErrors()` | — | bool | Enable platforms INS position errors |
| `HoundElint:disablePlatformPosErrors()` | — | bool | Disable platforms INS position errors |
| `HoundElint:getCallsignOverride()` | — | table | Get current callsign override table |
| `HoundElint:setCallsignOverride()` | `Table` (overrides) | Bool | Set callsign override table |
| `HoundElint:getBDA()` | — | bool | Get current BDA setting state |
| `HoundElint:enableBDA()` | — | Bool | Enable BDA for Hound Instance Hound will notify on radar destruction |
| `HoundElint:disableBDA()` | — | Bool | Disable BDA for Hound Instance |
| `HoundElint:getNATO()` | — | bool | Get current state of NATO brevity setting |
| `HoundElint:enableNATO()` | — | Bool | Enable NATO brevity for Hound Instance |
| `HoundElint:disableNATO()` | — | Bool | Disable NATO brevity for Hound Instance |
| `HoundElint:getAlertOnLaunch()` | — | Bool | Get Alert on launch for Hound Instance |
| `HoundElint:setAlertOnLaunch()` | — | Bool | Set Alert on Launch for Hound instance |
| `HoundElint:useNATOCallsigns()` | — | Bool | Set flag if callsignes for sectors under Callsignes would be from the NATO pool |
| `HoundElint:setRadioMenuParent()` | `desired` (parent) | Bool | Set Main parent menu for hound Instace must be set <b>BEFORE</b> calling <cod... |
| `HoundElint:enableText()` | `sectorName` (string) | — | Enable Text notification for controller |
| `HoundElint:disableText()` | `sectorName` (string) | — | Disable Text notification for controller |
| `HoundElint:enableTTS()` | `sectorName` (string) | — | Enable Text-To-Speach notification for controller |
| `HoundElint:disableTTS()` | `sectorName` (string) | — | Disable Text-to-speach notification for controller |
| `HoundElint:enableAlerts()` | `sectorName` (string) | — | Enable Alert notification for controller |
| `HoundElint:disableAlerts()` | `sectorName` (string) | — | Disable Alert notification for controller |
| `HoundElint:setCallsign()` | — | bool | Set sector callsign |
| `HoundElint:getCallsign()` | — | String | Get sector callsign |
| `HoundElint:setTransmitter()` | `sectorName` (string), `DCS` (transmitter) | — | Set transmitter to named sector valid values are name of sector, "all" or nil... |
| `HoundElint:removeTransmitter()` | `sectorName` (string) | — | Remove transmitter to named sector valid values are name of sector, "all" or ... |

### Event System

| Method | Parameters | Returns | Description |
|--------|------------|---------|-------------|
| `HoundElint:onHoundEvent()` | `incoming` (houndEvent) | — | Builtin prototype for onHoundEvent function this function does NOTHING out of... |
| `HoundElint:onEvent()` | `incoming` (DcsEvent) | — | Built in dcs onEvent |
| `HoundElint:defaultEventHandler()` | — | — | Enable/disable Hound instance internal event handling |

### Data Export

| Method | Parameters | Returns | Description |
|--------|------------|---------|-------------|
| `HoundElint:getContacts()` | — | table | Get an exported list of all contacts tracked by the instance |
| `HoundElint:getSites()` | — | table | Get an exported list of all sites tracked by the instance |
| `HoundElint:dumpIntelBrief()` | `filename` (opt), `format` (opt) | — | Dump Intel Brief to CSV or JSON will dump intel summary to the DCS saved game... |

### Global Utilities

| Method | Parameters | Returns | Description |
|--------|------------|---------|-------------|
| `HOUND.getInstance()` | `InstanceId` (number) | Hound | Get instance get hound instance by ID |
| `HOUND.setMgrsPresicion()` | `(Int)` (value) | — | Set default MGRS presicion for grid calls |
| `HOUND.showExtendedInfo()` | `(Bool)` (value) | — | Set detailed messages to include or exclude extended tracking data if true, w... |
| `HOUND.addEventHandler()` | `handler` (handler) | — | Register new event handler (global) |
| `HOUND.removeEventHandler()` | `handler` (handler) | — | Deregister event handler (global) |

### Enums

- `HOUND.MARKER`: NONE, SITE_ONLY, POINT, CIRCLE, DIAMOND, OCTAGON, POLYGON
- `HOUND.EVENTS`: NO_CHANGE, HOUND_ENABLED, HOUND_DISABLED, PLATFORM_ADDED, PLATFORM_REMOVED, PLATFORM_DESTROYED, RADAR_NEW, RADAR_DETECTED, RADAR_UPDATED, RADAR_DESTROYED, RADAR_ALIVE, RADAR_ASLEEP, SITE_NEW, SITE_CREATED, SITE_UPDATED, SITE_CLASSIFIED, SITE_REMOVED, SITE_ALIVE, SITE_ASLEEP, SITE_LAUNCH, RADAR_LAUNCH


---

## Integration Examples

### Example 1: Minimal Setup — Map Markers Only

```lua
do
  -- Create Hound instance for Blue coalition
  local houndBlue = HoundElint:create(coalition.side.BLUE)

  -- Add ELINT platforms by DCS unit name
  houndBlue:addPlatform("ELINT_North")
  houndBlue:addPlatform("ELINT_South")

  -- Enable polygon map markers
  houndBlue:setMarkerType(HOUND.MARKER.POLYGON)
  houndBlue:enableMarkers()

  -- Activate the system
  houndBlue:systemOn()
end
```

---

### Example 2: Basic Setup with Voice Communications

```lua
do
  -- Set globals BEFORE creating the instance
  HOUND.FORCE_MANAGE_MARKERS = true

  -- Create Hound instance for Blue coalition
  local houndBlue = HoundElint:create(coalition.side.BLUE)

  -- Add 3 ELINT platforms by DCS unit name
  houndBlue:addPlatform("ELINT_C130_1")
  houndBlue:addPlatform("ELINT_C130_2")
  houndBlue:addPlatform("ELINT_Tower")

  -- Enable Controller on multi-frequency (VHF/UHF/FM)
  houndBlue:enableController({
    freq = "251.000,35.000",
    modulation = "AM,FM",
    gender = "male"
  })

  -- Enable text messages on controller
  houndBlue:enableText()

  -- Enable ATIS broadcast on 253.000 AM
  houndBlue:enableAtis({
    freq = "253.000",
    modulation = "AM",
    gender = "female"
  })

  -- Use ELINT_C130_1 as transmitter for all sectors
  houndBlue:setTransmitter("all", "ELINT_C130_1")

  -- Enable BDA (radar destruction notifications) and launch alerts
  houndBlue:enableBDA()
  houndBlue:setAlertOnLaunch(true)

  -- Pre-brief 2 known SAM sites with custom code names
  houndBlue:preBriefedContact("Known_SAM_1", "ANVIL")
  houndBlue:preBriefedContact("Known_SAM_2", "HAMMER")

  -- Use circle map markers
  houndBlue:setMarkerType(HOUND.MARKER.CIRCLE)
  houndBlue:enableMarkers()

  -- Activate the system
  houndBlue:systemOn()
end
```

---

### Example 3: Multi-Sector Mission with Meta-Sectors and Zones

```lua
do
  -- Create Hound instance for Blue coalition
  local houndBlue = HoundElint:create(coalition.side.BLUE)

  -- Add 4 ELINT platforms by DCS unit name
  houndBlue:addPlatform("ELINT_C130_1")
  houndBlue:addPlatform("ELINT_C130_2")
  houndBlue:addPlatform("ELINT_C17")
  houndBlue:addPlatform("ELINT_Tower")

  -- Add child sectors with priority (lower = higher priority)
  houndBlue:addSector("Beslan", 10)
  houndBlue:addSector("Vladikavkaz", 20)

  -- Assign DCS zones to sectors
  houndBlue:setZone("Beslan", "Zone_Beslan")
  houndBlue:setZone("Vladikavkaz", "Zone_Vladikavkaz")

  -- Create meta-sector and attach children
  houndBlue:addSector("Northern Front")
  houndBlue:addChildSector("Northern Front", "Beslan")
  houndBlue:addChildSector("Northern Front", "Vladikavkaz")

  -- Configure (store) Controller/ATIS settings for the meta-sector
  houndBlue:configureController("Northern Front", {
    freq = "251.000,35.000",
    modulation = "AM,FM",
    gender = "male"
  })
  houndBlue:configureAtis("Northern Front", {
    freq = "253.000",
    modulation = "AM",
    gender = "female"
  })

  -- Activate Controller and ATIS for the meta-sector
  houndBlue:enableController("Northern Front")
  houndBlue:enableAtis("Northern Front")

  -- Enable Notifier on the meta-sector with inline settings
  houndBlue:enableNotifier("Northern Front", {
    freq = "251.000",
    modulation = "AM",
    gender = "male"
  })

  -- Add a global Notifier on guard frequency 243.000 AM
  houndBlue:enableNotifier({
    freq = "243.000",
    modulation = "AM",
    gender = "male"
  })

  -- Use ELINT_C130_1 as transmitter for the meta-sector
  houndBlue:setTransmitter("Northern Front", "ELINT_C130_1")

  -- Enable text for all sectors
  houndBlue:enableText("all")

  -- Activate the system
  houndBlue:systemOn()
end
```

---

### Example 4: Event Handlers — Custom Mission Logic

```lua
do
  -- Create Hound instance for Blue coalition
  local houndBlue = HoundElint:create(coalition.side.BLUE)

  -- Add ELINT platforms
  houndBlue:addPlatform("ELINT_C130_1")
  houndBlue:addPlatform("ELINT_C130_2")

  -- Activate the system
  houndBlue:systemOn()
end

-- Event handler TABLE with onHoundEvent METHOD
local MissionIntel = {
  radarKills = 0,
  targetSites = { "SA-10_Site_1", "SA-6_Site_2" },
  destroyed = {}
}

function MissionIntel:onHoundEvent(event)
  -- Filter by coalition
  if event.coalition ~= coalition.side.BLUE then return end

  -- New radar detected
  if event.id == HOUND.EVENTS.RADAR_NEW then
    local contact = event.initiator
    trigger.action.outText("New threat: " .. contact:getName(), 10)
  end

  -- Radar destroyed - count kills
  if event.id == HOUND.EVENTS.RADAR_DESTROYED then
    self.radarKills = self.radarKills + 1
    trigger.action.outText("Radars destroyed: " .. self.radarKills, 10)
  end

  -- Site removed - check mission objectives
  if event.id == HOUND.EVENTS.SITE_REMOVED then
    local site = event.initiator
    for _, targetName in ipairs(self.targetSites) do
      if site.DcsGroupName == targetName then
        table.insert(self.destroyed, targetName)
        trigger.action.outText("Objective complete!", 15)

        if #self.destroyed >= #self.targetSites then
          trigger.action.outText("Mission success!", 30)
        end
      end
    end
  end
end

-- Register the handler globally
HOUND.addEventHandler(MissionIntel)
```

---

### Example 5: Data Export and Periodic Intelligence

```lua
do
  -- Create Hound instance for Blue coalition
  local houndBlue = HoundElint:create(coalition.side.BLUE)

  -- Add ELINT platforms
  houndBlue:addPlatform("ELINT_C130_1")
  houndBlue:addPlatform("ELINT_C130_2")

  -- Enable on-screen debug for diagnostics
  houndBlue:onScreenDebug(true)

  -- Activate the system
  houndBlue:systemOn()

  -- Periodic intel collection (detection takes 1-2 minutes, so schedule)
  local function collectIntel()
    local data = houndBlue:getSites()

    -- Iterate SAM sites
    for _, site in ipairs(data.sam.sites) do
      env.info("SAM site: " .. site.name .. " Type: " .. site.Type)

      -- Iterate emitters on each site
      for _, emitter in ipairs(site.emitters) do
        env.info("  Emitter: " .. emitter.typeName)
        env.info("  Accuracy: " .. tostring(emitter.accuracy))

        -- Emitter LL is nested under pos - check before access
        if emitter.pos then
          env.info("  Lat: " .. emitter.pos.LL.lat)
          env.info("  Lon: " .. emitter.pos.LL.lon)
        end
      end
    end

    -- Iterate EWR sites
    for _, site in ipairs(data.ewr.sites) do
      env.info("EWR site: " .. site.name .. " Type: " .. site.Type)
    end

    -- Dump intel brief to CSV in DCS saved games folder
    houndBlue:dumpIntelBrief()
  end

  -- Schedule periodic collection every 120 seconds
  timer.scheduleFunction(collectIntel, nil, timer.getTime() + 120)
end
```

---

### Example 6: Advanced Configuration — Batch Discovery, Multi-Frequency, and Globals

```lua
do
  -- Set globals BEFORE creating the instance
  HOUND.FORCE_MANAGE_MARKERS = true
  HOUND.USE_LEGACY_MARKERS = false
  HOUND.MARKER_TEXT_POINTER = "❖ « "

  -- Create Hound instance for Blue coalition
  local houndBlue = HoundElint:create(coalition.side.BLUE)

  -- Batch-discover all ELINT platforms by name prefix
  local platforms = HOUND.Utils.Filter.unitsByPrefix("ELINT ")
  for name, unit in pairs(platforms) do
    houndBlue:addPlatform(name)
  end

  -- Add a sector with priority and assign a zone
  houndBlue:addSector("North", 10)
  houndBlue:setZone("North", "Zone_North")

  -- Enable Controller on multi-frequency with piper TTS
  houndBlue:enableController({
    freq = "251.000,35.000",
    modulation = "AM,FM",
    provider = "piper",
    voice = "en_US-ryan-low"
  })

  -- Use ELINT_Main as transmitter for all sectors
  houndBlue:setTransmitter("all", "ELINT_Main")

  -- Enable text and BDA
  houndBlue:enableText()
  houndBlue:enableBDA()

  -- Enable on-screen debug for diagnostics
  houndBlue:onScreenDebug(true)

  -- Activate the system
  houndBlue:systemOn()
end

-- Event handler TABLE with type-checked onHoundEvent
local SiteIntel = {}

function SiteIntel:onHoundEvent(event)
  -- Filter by coalition
  if event.coalition ~= coalition.side.BLUE then return end

  -- SITE_CREATED - process before accessing initiator fields
  if event.id == HOUND.EVENTS.SITE_CREATED then
    local site = event.initiator

    -- Check isEWR flag before processing EWR data
    if site.isEWR then
      trigger.action.outText("New EWR site detected: " .. site:getName(), 10)
    else
      trigger.action.outText("New SAM site detected: " .. site:getName(), 10)
    end
  end
end

-- Register the handler globally
HOUND.addEventHandler(SiteIntel)
```

---

## Common Patterns and Pitfalls

### Controller/ATIS Settings Table

```lua
local settings = {
    freq = "251.000",        -- frequency string; comma-separated for multiple
    modulation = "AM",       -- "AM" or "FM"; comma-separated if multiple freqs
    gender = "male",         -- TTS voice gender: "male" or "female"
    culture = "en-US",       -- TTS culture code
    speed = 0,               -- TTS speed (-10 to +10 for STTS)
    volume = "1.0"           -- TTS volume
}

-- Default sector:
HoundInstance:enableController(settings)

-- Named sector:
HoundInstance:enableController("North", settings)
```

### Event Handler Pattern

```lua
-- Handler is a TABLE with an onHoundEvent METHOD
MyHandler = {}
function MyHandler:onHoundEvent(event)
    if event.coalition ~= coalition.side.BLUE then return end
    if event.id == HOUND.EVENTS.RADAR_NEW then
        trigger.action.outText("New: " .. event.initiator:getName(), 10)
    end
end
HOUND.addEventHandler(MyHandler)
```

### Export Data Iteration

```lua
local data = HoundInstance:getSites()
-- Structure: data.sam.count, data.sam.sites[], data.ewr.count, data.ewr.sites[]
for _, site in ipairs(data.sam.sites) do
    env.info("Site: " .. site.name .. " Type: " .. site.Type)
    for _, emitter in ipairs(site.emitters) do
        if emitter.pos then
            env.info(string.format("  %s at %.4f, %.4f (%s)",
                emitter.typeName, emitter.LL.lat, emitter.LL.lon, emitter.accuracy))
        end
    end
end
```

### Important Rules

- `HoundElint:create()` takes `coalition.side.BLUE`/`RED` or a unit name string
- `addPlatform()` takes **one** string: the exact DCS unit name
- `setRadioMenuParent()` must be called **before** `enableController()`
- Call `systemOn()` **after** all configuration
- Marker types: `HOUND.MARKER.NONE`, `.SITE_ONLY`, `.POINT`, `.CIRCLE`, `.DIAMOND`, `.OCTAGON`, `.POLYGON`
- At least 2 platforms recommended for triangulation
- Platforms auto-removed if destroyed; can add dynamically during mission
- Sector name `"default"` always exists; `"all"` applies settings globally

---

## Documentation Quality Check

LLM quality/effectiveness check skipped for opencode path.

---

## Further Reading

- `docs/quick-start.md` — Step-by-step setup guide
- `docs/basic-configuration.md` — All basic options
- `docs/controller.md` — Controller details
- `docs/sectors.md` — Multi-sector setup
- `docs/event-handlers.md` — Event system details
- `docs/exports.md` — Data export formats
- `HOUND_API_REFERENCE.md` — Complete public API reference
- `demo_mission/` — Ready-to-fly demo missions
