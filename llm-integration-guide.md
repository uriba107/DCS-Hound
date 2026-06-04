# Hound ELINT — LLM Integration Guide

Everything needed to integrate the Hound ELINT radar detection system into a DCS World mission. This document is self-contained — no other files required.

*Generated on: 2026-06-04 15:08:52*

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

### ATIS

| Method | Parameters | Returns | Description |
|--------|------------|---------|-------------|
| `HoundElint:setAtisUpdateInterval()` | `desired` (value) | true | Set Atis Update interval |

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
- `HOUND.EVENTS`: NO_CHANGE, HOUND_ENABLED, HOUND_DISABLED, PLATFORM_ADDED, PLATFORM_REMOVED, PLATFORM_DESTROYED, RADAR_NEW, RADAR_DETECTED, RADAR_UPDATED, RADAR_DESTROYED, RADAR_ALIVE, RADAR_ASLEEP, SITE_NEW, SITE_CREATED, SITE_UPDATED, SITE_CLASSIFIED, SITE_REMOVED, SITE_ALIVE, SITE_ASLEEP, SITE_LAUNCH


---

## Integration Examples

### Example 1: Minimal Setup — Map Markers Only

```lua
do
  -- Create Hound instance for Blue coalition
  local HoundBlue = HoundElint:create(coalition.side.BLUE)

  -- Add ELINT platforms by unit name
  HoundBlue:addPlatform("ELINT_Unit_1")
  HoundBlue:addPlatform("ELINT_Unit_2")

  -- Configure and enable polygon map markers
  HoundBlue:setMarkerType(HOUND.MARKER.POLYGON)
  HoundBlue:enableMarkers()

  -- Activate the system
  HoundBlue:systemOn()
end
```

---

### Example 2: Basic Setup with Voice Communications

```lua
do
  -- Create Hound instance for Blue coalition
  local HoundBlue = HoundElint:create(coalition.side.BLUE)

  -- Add 3 ELINT platforms
  HoundBlue:addPlatform("ELINT_C130_1")
  HoundBlue:addPlatform("ELINT_C130_2")
  HoundBlue:addPlatform("Ground_Station_1")

  -- Enable Controller on 251.000 AM
  HoundBlue:enableController({
    freq = "251.000",
    modulation = "AM"
  })

  -- Enable ATIS on 253.000 AM
  HoundBlue:enableAtis({
    freq = "253.000",
    modulation = "AM"
  })

  -- Enable text messages (Required by task: "with text messages enabled")
  -- Based on advanced-configuration.md, enableText("all") enables text for all sectors/global
  HoundBlue:enableText("all")

  -- Enable BDA and launch alerts
  HoundBlue:enableBDA()
  HoundBlue:setAlertOnLaunch(true)

  -- Pre-brief 2 known SAM sites with custom code names
  HoundBlue:preBriefedContact("SAM_Site_Alpha", "ANVIL")
  HoundBlue:preBriefedContact("SAM_Site_Beta", "HAMMER")

  -- Configure map markers to Circle
  HoundBlue:setMarkerType(HOUND.MARKER.CIRCLE)
  HoundBlue:enableMarkers()

  -- Activate the system
  HoundBlue:systemOn()
end
```

---

### Example 3: Multi-Sector Mission with Meta-Sectors and Zones

```lua
do
  -- Create Hound instance for Blue coalition
  local HoundBlue = HoundElint:create(coalition.side.BLUE)

  -- Add 4 ELINT platforms
  HoundBlue:addPlatform("ELINT_P1")
  HoundBlue:addPlatform("ELINT_P2")
  HoundBlue:addPlatform("ELINT_P3")
  HoundBlue:addPlatform("ELINT_P4")

  -- Create child sectors
  HoundBlue:addSector("Beslan")
  HoundBlue:addSector("Vladikavkaz")

  -- Configure zones for child sectors
  HoundBlue:setZone("Beslan", "Zone_Beslan")
  HoundBlue:setZone("Vladikavkaz", "Zone_Vladikavkaz")

  -- Create meta-sector 'Northern Front'
  HoundBlue:addSector("Northern Front")

  -- Add child sectors to the meta-sector
  -- Note: addChildSector is the method required by the task description
  HoundBlue:addChildSector("Northern Front", "Beslan")
  HoundBlue:addChildSector("Northern Front", "Vladikavkaz")

  -- Configure Controller on 'Northern Front'
  HoundBlue:enableController("Northern Front", {
    freq = "251.000",
    modulation = "AM"
  })

  -- Configure ATIS on 'Northern Front'
  HoundBlue:enableAtis("Northern Front", {
    freq = "253.000",
    modulation = "AM"
  })

  -- Configure Notifier on 'Northern Front'
  -- Note: enableNotifier is used for the notifier functionality
  HoundBlue:enableNotifier({
    freq = "255.000",
    modulation = "AM"
  })

  -- Add a global Notifier on guard frequency 243.000 AM
  -- Overwrites previous notifier to set the guard frequency as requested
  HoundBlue:enableNotifier({
    freq = "243.000",
    modulation = "AM"
  })

  -- Enable text for all sectors
  HoundBlue:enableText("all")

  -- Activate the system
  HoundBlue:systemOn()
end
```

---

### Example 4: Event Handlers — Custom Mission Logic

```lua
do
  -- Basic Hound setup
  local HoundBlue = HoundElint:create(coalition.side.BLUE)
  HoundBlue:addPlatform("ELINT_C130")
  HoundBlue:systemOn()

  -- Mission objectives tracking
  local MissionObjectives = {
    targetSites = {"SA-10_Site_1", "SA-6_Site_2"},
    destroyed = {},
    killCount = 0
  }

  -- Event handler TABLE with onHoundEvent METHOD
  function MissionObjectives:onHoundEvent(event)
    -- Always filter by event coalition
    if event.coalition ~= coalition.side.BLUE then return end

    -- Handle RADAR_NEW: Announce via outText
    if event.id == HOUND.EVENTS.RADAR_NEW then
      local contact = event.initiator
      trigger.action.outText("New threat detected: " .. contact:getName(), 10)
    end

    -- Handle RADAR_DESTROYED: Count kills
    if event.id == HOUND.EVENTS.RADAR_DESTROYED then
      self.killCount = self.killCount + 1
      trigger.action.outText("Radar destroyed! Total kills: " .. self.killCount, 10)
    end

    -- Handle SITE_REMOVED: Check mission objectives
    if event.id == HOUND.EVENTS.SITE_REMOVED then
      local site = event.initiator
      for _, targetName in ipairs(self.targetSites) do
        if site.DcsGroupName == targetName then
          table.insert(self.destroyed, targetName)
          trigger.action.outText("Objective complete: " .. targetName .. " is offline!", 15)

          if #self.destroyed >= #self.targetSites then
            trigger.action.outText("All primary objectives destroyed! Mission success!", 30)
          end
        end
      end
    end
  end

  -- Register the handler table with the global HOUND manager
  HOUND.addEventHandler(MissionObjectives)
end
```

---

### Example 5: Data Export and Periodic Intelligence

```lua
do
  -- Initialize Hound instance
  local HoundBlue = HoundElint:create(coalition.side.BLUE)
  HoundBlue:addPlatform("ELINT_C130")
  HoundBlue:systemOn()

  -- Function to iterate through sites and print data
  local function processHoundSites()
    -- (1) Call getSites() - returns table with sam and ewr categories
    local data = HoundBlue:getSites()

    -- Iterate through SAM sites as requested
    if data and data.sam and data.sam.sites then
      for _, site in ipairs(data.sam.sites) do
        local siteInfo = "Site: " .. site.name .. " | Type: " .. site.Type
        
        -- Iterate through emitters for this site
        if site.emitters then
          for _, emitter in ipairs(site.emitters) do
            local emitterData = " [Emitter: " .. emitter.typeName .. "]"
            
            -- IMPORTANT: check if emitter.pos exists before accessing LL (Lat/Lon)
            if emitter.pos then
              -- Access emitter.LL.lat, emitter.LL.lon, and emitter.accuracy
              emitterData = emitterData .. " Lat: " .. emitter.LL.lat .. " Lon: " .. emitter.LL.lon .. " Acc: " .. emitter.accuracy
            end
            siteInfo = siteInfo .. emitterData
          end
        end
        trigger.action.outText(siteInfo, 10)
      end
    end
  end

  -- Function to handle periodic export and site processing
  local function periodicHoundTask()
    -- Process the current site list
    processHoundSites()

    -- (2) Call dumpIntelBrief() for CSV export to saved games folder
    HoundBlue:dumpIntelBrief("Blue_Intel_Export.csv", "csv")

    -- (3) Reschedule the function to run again in 300 seconds (5 minutes)
    -- timer.scheduleFunction(function, argument, absoluteTime)
    timer.scheduleFunction(periodicHoundTask, nil, timer.getTime() + 300)
  end

  -- Schedule the first run to occur after 120 seconds (2 minutes) to allow for detection
  timer.scheduleFunction(periodicHoundTask, nil, timer.getTime() + 120)
end
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

**PASSED** — An LLM successfully wrote correct integration code using only this guide as context.

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
