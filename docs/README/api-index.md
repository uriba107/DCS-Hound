# API Index - Quick Reference

Complete listing of all **public Hound methods** for mission builders, organized by category.

This is the **Public API** for everyday mission builders. For internal/developer functions, see [Developer API](../dev/).

*Generated with LLM assistance*

---

## Table of Contents

- [Instance Management](#instance-management)
- [Platform Management](#platform-management)
- [Detection & Contacts](#detection-contacts)
- [Sector Management](#sector-management)
- [Controller](#controller)
- [ATIS](#atis)
- [Notifier](#notifier)
- [Map Markers](#map-markers)
- [Settings & Configuration](#settings-configuration)
- [Event System](#event-system)
- [Data Export](#data-export)
- [Global Utilities](#global-utilities)

---

## Instance Management

| Method | Parameters | Returns | Description |
|--------|------------|---------|-------------|
| `HoundElint:create()` | `platformName` (int) | table | Create HoundElint instance. |
| `HoundElint:destroy()` | - | - | Destructor function initiates cleanup. |
| `HoundElint:systemOn()` | - | - | Turn Hound system on. |
| `HoundElint:systemOff()` | - | - | Turn Hound system off. |
| `HoundElint:isRunning()` | - | bool | Is Instance on. |

**Example:**

```lua
-- Create Hound instances for both coalitions
HoundBlue = HoundElint:create("ELINT_C130")
HoundRed = HoundElint:create("Growler_1")

-- Turn on the ELINT system for Blue coalition
HoundBlue:systemOn()

-- Check if the Red coalition's ELINT system is running
if HoundRed:isRunning() then
    print("Red ELINT system is active.")
else
    print("Red ELINT system is not active.")
end

-- Destroy the Blue coalition's ELINT instance when no longer needed
HoundBlue:destroy()
```

---

## Platform Management

| Method | Parameters | Returns | Description |
|--------|------------|---------|-------------|
| `HoundElint:addPlatform()` | - | bool | Add platform from hound instance. |
| `HoundElint:removePlatform()` | - | bool | Remove platform from hound instance. |
| `HoundElint:countPlatforms()` | - | int | Count Platforms. |
| `HoundElint:listPlatforms()` | - | table | List platforms. |

**Example:**

```lua
-- Add platforms to Hound instances
HoundBlue:addPlatform("ELINT_C130", "default")
HoundRed:addPlatform("Growler_1", "North")

-- List all platforms in a specific sector for Blue coalition
local bluePlatforms = HoundBlue:listPlatforms("South")
for _, platform in ipairs(bluePlatforms) do
    print("Blue Platform: " .. platform)
end

-- Count platforms managed by Red coalition
local redPlatformCount = HoundRed:countPlatforms()
print("Red Platforms Count: " .. redPlatformCount)

-- Remove a platform from Blue coalition
HoundBlue:removePlatform("ELINT_Tower")
```

---

## Detection & Contacts

| Method | Parameters | Returns | Description |
|--------|------------|---------|-------------|
| `HoundElint:countContacts()` | `sectorName` (string) | int | Count contacts. |
| `HoundElint:countActiveContacts()` | `sectorName` (string) | int | Count Active contacts. |
| `HoundElint:countPreBriefedContacts()` | `sectorName` (string) | int | Count preBriefed contacts. |
| `HoundElint:preBriefedContact()` | `DCS_Object_Name` (string), `codeName` (opt) | - | Set/create a pre Briefed contacts. |
| `HoundElint:markDeadContact()` | `radarUnit` (string|tab) | - | Mark Radar as dead. |
| `HoundElint:getContacts()` | - | table | Get an exported list of all contacts tracked by the instance. |

**Example:**

```lua
-- Pre-brief a contact for the ELINT_C130 in the North sector
HoundBlue:preBriefedContact("ELINT_C130", "Friendlies")

-- Count all contacts in the default sector
local totalContacts = HoundRed:countContacts("default")
env.info("Total Contacts in Default Sector: " .. totalContacts)

-- Mark a contact as dead for the Growler_1 unit
HoundBlue:markDeadContact("Growler_1")
```

---

## Sector Management

| Method | Parameters | Returns | Description |
|--------|------------|---------|-------------|
| `HoundElint:addSector()` | `sectorName` (string), `sectorSettings` (opt), `priority` (opt) | bool | Add named sector. |
| `HoundElint:removeSector()` | `sectorName` (string) | bool | Remove Named sector. |
| `HoundElint:updateSectorSettings()` | `sectorName` (string|nil), `subSettingName` (string) | bool | Update named sector settings. |
| `HoundElint:listSectors()` | `element` (string) | list | List all sectors. |
| `HoundElint:getSectors()` | `element` (string) | list | Get all sectors. |
| `HoundElint:countSectors()` | `element` (string) | int | Return number of sectors. |
| `HoundElint:getSector()` | - | HOUND.Secto | Return HOUND.Sector instance. |
| `HoundElint:updateSectorMembership()` | - | - | Update sector membership for all contacts. |

**Example:**

```lua
-- Add a sector for the Blue coalition's ELINT C130
HoundBlue:addSector("North", {frequency="251.000"}, 1)

-- Update settings of an existing sector for the Red coalition's Growler
HoundRed:updateSectorSettings("South", "frequency=253.000")

-- List all sectors associated with a specific ELINT platform unit
HoundBlue:listSectors("ELINT_C130")
```

---

## Controller

| Method | Parameters | Returns | Description |
|--------|------------|---------|-------------|
| `HoundElint:enableController()` | `sectorName` (string) | - | Enable controller in sector. |
| `HoundElint:disableController()` | `sectorName` (string) | - | Disable controller in sector. |
| `HoundElint:removeController()` | `sectorName` (string) | - | Remove controller in sector. |
| `HoundElint:configureController()` | `sectorName` (string) | - | Configure controller in sector. |
| `HoundElint:getControllerFreq()` | `sectorName` (string) | frequncies | Get controller freq. |
| `HoundElint:getControllerState()` | `sectorName` (string) | bool | Get controller state. |
| `HoundElint:transmitOnController()` | `sectorName` (string), `msg` (string), `priority` (number) | - | Transmit custom TTS message on controller freqency. |
| `HoundElint:setRadioMenuParent()` | `desired` (parent) | bool | Set Main parent menu for hound Instace must be set <b>BEFORE</b> calling <cod... |
| `HoundElint.runCycle()` | - | time | Scheduled function that runs the main Instance loop. |
| `HoundElint:purgeRadioMenu()` | - | - | Purge the root radio menu. |
| `HoundElint:populateRadioMenu()` | - | - | Trigger building of radio menu in all sectors. |

**Example:**

```lua
-- Enable controller for the "North" sector on HoundBlue instance
HoundBlue:enableController("North")

-- Configure the "South" sector with a specific frequency on HoundRed instance
HoundRed:configureController("South")
HoundRed:setControllerFreq("South", "253.000")

-- Disable controller for the "default" sector on HoundBlue instance
HoundBlue:disableController("default")
```

---

## ATIS

| Method | Parameters | Returns | Description |
|--------|------------|---------|-------------|
| `HoundElint:enableAtis()` | `sectorName` (string) | - | Enable ATIS in sector. |
| `HoundElint:disableAtis()` | `sectorName` (string) | - | Disable ATIS in sector. |
| `HoundElint:removeAtis()` | `sectorName` (string) | - | Remove ATIS in sector. |
| `HoundElint:configureAtis()` | `sectorName` (string) | - | Configure ATIS in sector. |
| `HoundElint:getAtisFreq()` | `sectorName` (string) | frequncies | Get ATIS freq. |
| `HoundElint:reportEWR()` | `name` (string) | - | Set ATIS EWR report state for sector. |
| `HoundElint:getAtisState()` | `sectorName` (string) | bool | Get ATIS state. |
| `HoundElint:setAtisUpdateInterval()` | `desired` (value) | true | Set Atis Update interval. |

**Example:**

```lua
-- Enable ATIS for the default sector on HoundBlue
HoundBlue:enableAtis("default")

-- Configure ATIS frequency for the North sector on HoundRed
HoundRed:configureAtis("North")
HoundRed:getAtisFreq("North")  -- Assuming this returns and prints the current frequency

-- Remove ATIS from the South sector on HoundBlue
HoundBlue:removeAtis("South")
```

---

## Notifier

| Method | Parameters | Returns | Description |
|--------|------------|---------|-------------|
| `HoundElint:enableNotifier()` | `sectorName` (string) | - | Enable Notifier in sector Only one notifier is required as it will broadcast ... |
| `HoundElint:disableNotifier()` | `sectorName` (string) | - | Disable Notifier in sector. |
| `HoundElint:removeNotifier()` | `sectorName` (string) | - | Remove controller in sector. |
| `HoundElint:configureNotifier()` | `sectorName` (string) | - | Configure Notifier in sector. |
| `HoundElint:getNotifierFreq()` | `sectorName` (string) | frequncies | Get Notifier freq. |
| `HoundElint:getNotifierState()` | `sectorName` (string) | bool | Get Notifier state. |
| `HoundElint:transmitOnNotifier()` | `sectorName` (string), `msg` (string), `priority` (number) | - | Transmit custom TTS message on Notifier freqency. |

**Example:**

```lua
-- Enable notifier for the 'North' sector on HoundBlue instance
HoundBlue:enableNotifier("North")

-- Configure notifier for the 'South' sector with a specific frequency
HoundRed:configureNotifier("South")
HoundRed:setNotifierFreq("South", "253.000")

-- Disable notifier for the 'default' sector on HoundRed instance
HoundRed:disableNotifier("default")
```

---

## Map Markers

| Method | Parameters | Returns | Description |
|--------|------------|---------|-------------|
| `HoundElint:enableMarkers()` | `markerType` (opt) | bool | Enable Markers for Hound Instance (default). |
| `HoundElint:disableMarkers()` | - | bool | Disable Markers for Hound Instance. |
| `HoundElint:enableSiteMarkers()` | - | bool | Enable Site Markers for Hound Instance (default). |
| `HoundElint:disableSiteMarkers()` | - | bool | Disable Site Markers for Hound Instance. |
| `HoundElint:setMarkerType()` | `valid` (markerType) | bool | Set marker type for Hound instance. |

**Example:**

```lua
-- Enable markers of type "radar" for HoundBlue
HoundBlue:enableMarkers("radar")

-- Disable all markers for HoundRed
HoundRed:disableMarkers()

-- Set marker type to "threat" for HoundBlue
HoundBlue:setMarkerType("threat")
```

---

## Settings & Configuration

| Method | Parameters | Returns | Description |
|--------|------------|---------|-------------|
| `HoundElint:onScreenDebug()` | `value` (bool) | bool | Set onScreenDebug. |
| `HoundElint:AlertOnLaunch()` | `fireUnit` (string|tab) | - | Issue a Launch Alert. |
| `HoundElint:enableText()` | `sectorName` (string) | - | Enable Text notification for controller. |
| `HoundElint:disableText()` | `sectorName` (string) | - | Disable Text notification for controller. |
| `HoundElint:enableTTS()` | `sectorName` (string) | - | Enable Text-To-Speach notification for controller. |
| `HoundElint:disableTTS()` | `sectorName` (string) | - | Disable Text-to-speach notification for controller. |
| `HoundElint:enableAlerts()` | `sectorName` (string) | - | Enable Alert notification for controller. |
| `HoundElint:disableAlerts()` | `sectorName` (string) | - | Disable Alert notification for controller. |
| `HoundElint:setCallsign()` | - | bool | Set sector callsign. |
| `HoundElint:getCallsign()` | - | String | Get sector callsign. |
| `HoundElint:setTransmitter()` | `sectorName` (string), `DCS` (transmitter) | - | Set transmitter to named sector valid values are name of sector, "all" or nil... |
| `HoundElint:removeTransmitter()` | `sectorName` (string) | - | Remove transmitter to named sector valid values are name of sector, "all" or ... |
| `HoundElint:getZone()` | `sectorName` (string) | table | Get zone of sector. |
| `HoundElint:setZone()` | `sectorName` (string), `DCS` (zoneCandidate) | - | Add zone to sector same as MOOSE. use late activation invisible helicopter gr... |
| `HoundElint:removeZone()` | `sectorName` (string) | - | Remove zone from sector. |
| `HoundElint:setTimerInterval()` | `interval` (setIntervalName), `interval` (setValue) | bool | Set intervals. |
| `HoundElint:enablePlatformPosErrors()` | - | bool | Enable platforms INS position errors. |
| `HoundElint:disablePlatformPosErrors()` | - | bool | Disable platforms INS position errors. |
| `HoundElint:getCallsignOverride()` | - | table | Get current callsign override table. |
| `HoundElint:setCallsignOverride()` | `Table` (overrides) | bool | Set callsign override table. |
| `HoundElint:getBDA()` | - | bool | Get current BDA setting state. |
| `HoundElint:enableBDA()` | - | bool | Enable BDA for Hound Instance Hound will notify on radar destruction. |
| `HoundElint:disableBDA()` | - | bool | Disable BDA for Hound Instance. |
| `HoundElint:getNATO()` | - | bool | Get current state of NATO brevity setting. |
| `HoundElint:enableNATO()` | - | bool | Enable NATO brevity for Hound Instance. |
| `HoundElint:disableNATO()` | - | bool | Disable NATO brevity for Hound Instance. |
| `HoundElint:getAlertOnLaunch()` | - | bool | Get Alert on launch for Hound Instance. |
| `HoundElint:setAlertOnLaunch()` | - | bool | Set Alert on Launch for Hound instance. |
| `HoundElint:useNATOCallsignes()` | - | bool | Set flag if callsignes for sectors under Callsignes would be from the NATO pool. |

**Example:**

```lua
-- Enable screen debug for HoundRed instance
HoundRed:onScreenDebug(true)

-- Enable text alerts in the "North" sector for HoundBlue
HoundBlue:enableText("North")

-- Disable TTS alerts in the "default" sector for HoundRed
HoundRed:disableTTS("default")
```

---

## Event System

| Method | Parameters | Returns | Description |
|--------|------------|---------|-------------|
| `HOUND.addEventHandler()` | `handler` (handler) | - | Register new event handler (global). |
| `HOUND.removeEventHandler()` | `handler` (handler) | - | Deregister event handler (global). |
| `HoundElint:onHoundEvent()` | `incoming` (houndEvent) | - | Builtin prototype for onHoundEvent function this function does NOTHING out of... |
| `HoundElint:onHoundInternalEvent()` | `incoming` (houndEvent) | - | Built in onHoundEvent function. |
| `HoundElint:onEvent()` | `incoming` (DcsEvent) | - | Built in dcs onEvent. |
| `HoundElint:defaultEventHandler()` | - | - | Enable/disable Hound instance internal event handling. |

**Example:**

```lua
-- Define an event handler function
local function handleEvent(incoming)
    -- Process the incoming event
    env.info("Handling event: " .. incoming.type)
end

-- Add the event handler to HoundBlue instance
HoundBlue:addEventHandler(handleEvent)

-- Define a sector-specific event handler
local function handleSectorEvent(incoming)
    if incoming.sector == "North" then
        -- Process events specific to the North sector
        env.info("Handling North sector event: " .. incoming.type)
    end
end

-- Add the sector-specific event handler to HoundBlue instance
HoundBlue:addEventHandler(handleSectorEvent)

-- Define an internal event handler for Blue coalition
local function handleInternalEvent(incoming)
    -- Process internal events for Blue coalition
    env.info("Handling internal event: " .. incoming.type)
end

-- Add the internal event handler to HoundBlue instance
HoundBlue:addEventHandler(handleInternalEvent)
```

---

## Data Export

| Method | Parameters | Returns | Description |
|--------|------------|---------|-------------|
| `HoundElint:getContacts()` | - | table | Get an exported list of all contacts tracked by the instance. |
| `HoundElint:getSites()` | - | table | Get an exported list of all sites tracked by the instance. |
| `HoundElint:dumpIntelBrief()` | `filename` (opt) | - | Dump Intel Brief to csv will dump intel summery to CSV in the DCS saved games... |
| `HoundElint:printDebugging()` | - | strin | Return Debugging information. |

**Example:**

```lua
-- Export intelligence data to a file for the Blue coalition
HoundBlue:dumpIntelBrief("blue_intel_brief.txt")

-- Print debugging information for the Red coalition
HoundRed:printDebugging()

-- Get contacts detected by the ELINT system in the default sector
local blueContacts = HoundBlue:getContacts()
```

---

## Global Utilities

| Method | Parameters | Returns | Description |
|--------|------------|---------|-------------|
| `HOUND.getInstance()` | `InstanceId` (number) | Hound | Get instance get hound instance by ID. |
| `HOUND.showExtendedInfo()` | `(Bool)` (value) | - | Set detailed messages to include or exclude extended tracking data if true, w... |

**Example:**

```lua
-- Get an instance of HOUND for the Blue coalition
local houndBlueInstance = HOUND.getInstance("HoundBlue")

-- Show extended information for the Blue HOUND instance
houndBlueInstance:showExtendedInfo(true)

-- Create a new HOUND instance for the Red coalition
HoundRed = HoundElint:create(coalition.side.RED)
HoundRed:systemOn()
```

---

## See Also

- **[System Architecture](architecture.md)** - How components work together
- **[Quick Start](quick-start.md)** - Get started with Hound
- **[Full API Documentation](../HOUND_API_REFERENCE.md)** - Complete public API reference
- **[Developer API](../dev/)** - Internal functions for advanced users
