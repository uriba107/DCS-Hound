# Hound ELINT — LLM Integration Guide

Everything needed to integrate the Hound ELINT radar detection system into a DCS World mission. This document is self-contained — no other files required.

*Generated on: 2026-02-25 00:20:46*

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
| **Sector** | Geographic region with separate comms channels |
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
| `HoundElint:enableAtis()` | `sectorName` (string) | — | Enable ATIS in sector |
| `HoundElint:disableAtis()` | `sectorName` (string) | — | Disable ATIS in sector |
| `HoundElint:removeAtis()` | `sectorName` (string) | — | Remove ATIS in sector |
| `HoundElint:configureAtis()` | `sectorName` (string) | — | Configure ATIS in sector |
| `HoundElint:getAtisFreq()` | `sectorName` (string) | frequncies | Get ATIS freq |
| `HoundElint:reportEWR()` | `name` (string) | — | Set ATIS EWR report state for sector |
| `HoundElint:getAtisState()` | `sectorName` (string) | Bool | Get ATIS state |
| `HoundElint:setAtisUpdateInterval()` | `desired` (value) | true | Set Atis Update interval |

### Notifier

| Method | Parameters | Returns | Description |
|--------|------------|---------|-------------|
| `HoundElint:enableNotifier()` | `sectorName` (string) | — | Enable Notifier in sector Only one notifier is required as it will broadcast ... |
| `HoundElint:disableNotifier()` | `sectorName` (string) | — | Disable Notifier in sector |
| `HoundElint:removeNotifier()` | `sectorName` (string) | — | Remove controller in sector |
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
| `HoundElint:useNATOCallsignes()` | — | Bool | Set flag if callsignes for sectors under Callsignes would be from the NATO pool |
| `HoundElint:setRadioMenuParent()` | `desired` (parent) | Bool | Set Main parent menu for hound Instace must be set <b>BEFORE</b> calling <cod... |

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
| `HoundElint:dumpIntelBrief()` | `filename` (opt) | — | Dump Intel Brief to csv will dump intel summery to CSV in the DCS saved games... |

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

*Validation skipped: LLM call failed.*

---

## Further Reading

- `docs/README/quick-start.md` — Step-by-step setup guide
- `docs/README/basic-configuration.md` — All basic options
- `docs/README/controller.md` — Controller details
- `docs/README/sectors.md` — Multi-sector setup
- `docs/README/event-handlers.md` — Event system details
- `docs/README/exports.md` — Data export formats
- `docs/HOUND_API_REFERENCE.md` — Complete public API reference
- `demo_mission/` — Ready-to-fly demo missions
