# Settings Reference

Complete reference for all Hound configuration options.

---

## Quick Reference

| Setting            | Scope    | Default        | Reference                                            |
| ------------------ | -------- | -------------- | ---------------------------------------------------- |
| Marker Type        | Instance | CIRCLE         | [Markers](#markers)                                  |
| Timer Intervals    | Instance | Various        | [Timers](#timer-intervals)                           |
| BDA                | Instance | Enabled        | [Alerts](#alerts)                                    |
| Launch Alerts      | Instance | Disabled       | [Alerts](#alerts)                                    |
| Platform Errors    | Instance | Disabled       | [Platforms](#platforms)                              |
| MGRS Precision     | Global   | 5              | [Global](#global-settings)                           |
| TTS Engine         | Global   | HoundTTS, STTS | [TTS](#tts-configuration)                            |
| Extended Info      | Global   | Enabled        | [Global](#global-settings)                           |
| Auto Add Platforms | Global   | Enabled        | [Automatic Detection](#automatic-platform-detection) |
| Antenna Factor     | Global   | 1.0            | [Antenna Factor](#antenna-factor)                    |
| Menu Pagination    | Global   | 9              | [Menu Pagination](#menu-pagination)                  |
| Contact Tracking   | Global   | Various        | [Tracking Parameters](#contact-tracking-parameters)  |
| Marker Appearance  | Global   | Various        | [Marker Appearance](#marker-appearance)              |

---

## Instance Settings

Settings specific to each Hound instance.

### Markers

**Enable/Disable:**

```lua
HoundInstance:enableMarkers()
HoundInstance:disableMarkers()
```

**Marker Type:**

```lua
HoundInstance:setMarkerType(HOUND.MARKER.CIRCLE)
```

Options:

- `HOUND.MARKER.NONE` - No uncertainty ellipse
- `HOUND.MARKER.SITE_ONLY` - Site markers only
- `HOUND.MARKER.POINT` - Point markers only
- `HOUND.MARKER.CIRCLE` - Circular approximation (default)
- `HOUND.MARKER.DIAMOND` - 4-point diamond
- `HOUND.MARKER.OCTAGON` - 8-point octagon
- `HOUND.MARKER.POLYGON` - 16-point polygon

**Site Markers:**

```lua
HoundInstance:enableSiteMarkers()
HoundInstance:disableSiteMarkers()
```

📖 [Map Markers Guide](map-markers.md)

---

### Timer Intervals

**Set Intervals (seconds):**

```lua
HoundInstance:setTimerInterval("scan", 5)      -- Platform scan
HoundInstance:setTimerInterval("process", 30)  -- Position calc
HoundInstance:setTimerInterval("menus", 60)    -- Menu update
HoundInstance:setTimerInterval("markers", 120) -- Marker update
```

Defaults:

- scan: 5s
- process: 30s
- menus: 60s
- markers: 120s

📖 [Performance Tuning](performance.md)

---

### Alerts

**BDA (Destroyed Alerts):**

```lua
HoundInstance:enableBDA()
HoundInstance:disableBDA()
local enabled = HoundInstance:getBDA()
```

**Launch Alerts:**

```lua
HoundInstance:setAlertOnLaunch(true)
HoundInstance:setAlertOnLaunch(false)
local enabled = HoundInstance:getAlertOnLaunch()
```

**Controller Alerts:**

```lua
HoundInstance:enableAlerts("sectorName")
HoundInstance:disableAlerts("sectorName")
HoundInstance:enableAlerts("all")
HoundInstance:disableAlerts("all")
```

---

### Platforms

**Add/Remove:**

```lua
HoundInstance:addPlatform("UnitName")
HoundInstance:removePlatform("UnitName")
```

**Position Errors:**

```lua
HoundInstance:enablePlatformPosErrors()
HoundInstance:disablePlatformPosErrors()
```

📖 [Platforms Guide](platforms.md)

---

### Pre-Briefed Contacts

**Add Contacts:**

```lua
HoundInstance:preBriefedContact("UnitName")
HoundInstance:preBriefedContact("GroupName")
HoundInstance:preBriefedContact("GroupName", "CodeName")
```

📖 [Basic Configuration](basic-configuration.md#pre-briefed-contacts)

---

### Debug

**On-Screen Debug:**

```lua
HoundInstance:onScreenDebug(true)
HoundInstance:onScreenDebug(false)
```

---

## Sector Settings

Settings applied per sector.

### Sector Management

**Create/Remove:**

```lua
HoundInstance:addSector("SectorName")
HoundInstance:removeSector("SectorName")
local sectors = HoundInstance:listSectors()
```

**Zones:**

```lua
HoundInstance:setZone("SectorName", "ZoneName")
HoundInstance:setZone("SectorName")  -- Auto-name
HoundInstance:removeZone("SectorName")
local zone = HoundInstance:getZone("SectorName")
```

📖 [Sectors Guide](sectors.md)

---

### Sector Communications

**Controller:**

```lua
HoundInstance:enableController("SectorName", {config})
HoundInstance:disableController("SectorName")
HoundInstance:configureController("SectorName", {config})
```

**ATIS:**

```lua
HoundInstance:enableAtis("SectorName", {config})
HoundInstance:disableAtis("SectorName")
HoundInstance:configureAtis("SectorName", {config})
```

**Notifier:**

```lua
HoundInstance:enableNotifier("SectorName", {config})
HoundInstance:removeNotifier("SectorName")
HoundInstance:configureNotifier("SectorName", {config})
```

📖 [Communication Guide](communication.md)

---

### Sector Text/Voice

**Text Messages:**

```lua
HoundInstance:enableText("SectorName")
HoundInstance:disableText("SectorName")
HoundInstance:enableText("all")
HoundInstance:disableText("all")
```

**TTS:**

```lua
HoundInstance:enableTTS("SectorName")
HoundInstance:disableTTS("SectorName")
HoundInstance:enableTTS("all")
HoundInstance:disableTTS("all")
```

---

### Sector Transmitter

**Set/Remove:**

```lua
HoundInstance:setTransmitter("SectorName", "UnitName")
HoundInstance:removeTransmitter("SectorName")
HoundInstance:setTransmitter("all", "UnitName")
```

---

### Sector Callsigns

**Get/Set:**

```lua
local callsign = HoundInstance:getCallsign("SectorName")
HoundInstance:setCallsign("SectorName", "CALLSIGN")
HoundInstance:setCallsign("SectorName")  -- Random
HoundInstance:setCallsign("SectorName", "NATO")  -- NATO pool
HoundInstance:setCallsign("SectorName", true)    -- NATO pool
```

**NATO Callsigns:**

```lua
HoundInstance:useNATOCallsignes(true)
HoundInstance:useNATOCallsignes(false)
```

---

### Sector Settings

**EWR Reporting:**

```lua
HoundInstance:reportEWR("SectorName", true)
HoundInstance:reportEWR("SectorName", false)
HoundInstance:reportEWR("all", true)
```

**ATIS Format:**

```lua
HoundInstance:enableNATO()
HoundInstance:disableNATO()
local enabled = HoundInstance:getNATO()
```

**ATIS Interval:**

```lua
HoundInstance:setAtisUpdateInterval(300)  -- Seconds
```

---

## TTS Configuration

### TTS Settings (HoundTTS) ⭐ Default

```lua
local config = {
    freq = "251.000",              -- String or number
    modulation = "AM",              -- "AM" or "FM"
    volume = "1.0",                 -- "0.0" to "1.0"
    speed = 1.0,                    -- 0.5 (slow) to 2.0 (fast), 1.0 = normal
    provider = "sapi",              -- "piper", "sapi"/"win", "google"/"gcloud", "aws"/"polly", "azure", "elevenlabs"
    gender = "female",              -- "male" or "female" (SAPI, Google)
    culture = "en-US",              -- Voice culture
    voice = "David",                -- Specific voice (optional, provider-dependent)
}
```

### TTS Settings (STTS) — Legacy

```lua
local config = {
    freq = "251.000",
    modulation = "AM",
    volume = "1.0",                 -- "0.0" to "1.0" (string)
    speed = 0,                      -- -10 to +10
    gender = "male",
    culture = "en-US",
    voice = "David",                -- Specific voice (optional)
    googleTTS = false               -- Use Google TTS
}
```

> **Note:** If HoundTTS is installed, it transparently takes over from STTS. Existing STTS settings (including `googleTTS` and Azure credentials) are automatically mapped to HoundTTS providers.

### TTS Settings (gRPC)

```lua
local config = {
    freq = "251.000",
    modulation = "AM",
    volume = "1.0",
    speed = 100,                    -- 50 to 250 (percentage)
    gender = "male",
    culture = "en-US",
    name = "Microsoft David Desktop",  -- Full voice name
    provider = {}                   -- Provider settings
}
```

📖 [TTS Configuration Guide](tts-configuration.md)

---

## Global Settings

Settings that affect all Hound instances.

### MGRS Precision

```lua
HOUND.setMgrsPresicion(5)  -- 10-digit (default)
HOUND.setMgrsPresicion(4)  -- 8-digit
HOUND.setMgrsPresicion(3)  -- 6-digit
```

---

### Extended Info

```lua
HOUND.showExtendedInfo(true)   -- Full reports (default)
HOUND.showExtendedInfo(false)  -- Shorter reports
```

Affects controller report verbosity.

---

### TTS Engine Priority

```lua
HOUND.TTS_ENGINE = {'HoundTTS', 'STTS'}  -- Default
HOUND.TTS_ENGINE = {'STTS'}               -- STTS only (legacy)
HOUND.TTS_ENGINE = {'GRPC'}               -- gRPC only (not recommended)
HOUND.TTS_ENGINE = {}                      -- Disable TTS
```

**Set before creating Hound instances.**

---

### Automatic Platform Detection

```lua
HOUND.AUTO_ADD_PLATFORM_BY_PAYLOAD = true   -- Automatic (default)
HOUND.AUTO_ADD_PLATFORM_BY_PAYLOAD = false  -- Manual only
```

When enabled, Hound automatically detects and adds units with ELINT payloads (HTS pod, Fantasmagoria, etc.) when they spawn.

**DCS Limitation:** Only works for units **spawning** with the required pods. Adding pods to already-spawned units will not trigger automatic detection.

**Player-based ELINT:** This feature enables player aircraft to be automatically added as ELINT platforms without manual configuration.

📖 See: [Platforms Guide](platforms.md#automatic-platform-detection)

**Set before creating Hound instances.**

---

### Antenna Factor

```lua
HOUND.ANTENNA_FACTOR = 1.0   -- Normal (default)
HOUND.ANTENNA_FACTOR = 1.5   -- 50% better accuracy
HOUND.ANTENNA_FACTOR = 0.5   -- 50% worse accuracy
```

Global multiplier for all platform antenna sizes. Affects triangulation accuracy for the entire system.

**Use Cases:**

- **Increase (1.5-2.0):** Make Hound easier/more forgiving
- **Decrease (0.5-0.8):** Increase mission difficulty
- **Fine-tuning:** Balance accuracy for specific scenarios

**Set before creating Hound instances.**

---

### Menu Pagination

```lua
HOUND.MENU_PAGE_LENGTH = 9    -- Default
HOUND.MENU_PAGE_LENGTH = 12   -- More items per page
HOUND.MENU_PAGE_LENGTH = 6    -- Fewer items per page
```

Number of items per F10 radio menu page before pagination.

**Considerations:**

- Lower values = More pages but easier to scan
- Higher values = Fewer pages but longer menus
- DCS has a practical limit around 10-12 for readability

**Set before creating Hound instances.**

---

### Contact Tracking Parameters

Advanced tuning for triangulation behavior:

```lua
-- Number of datapoints per platform that each contact stores
HOUND.DATAPOINTS_NUM = 30        -- Default (30 points, FIFO)
HOUND.DATAPOINTS_NUM = 50        -- More history, smoother tracking

-- Time between stored datapoints
HOUND.DATAPOINTS_INTERVAL = 30   -- Default (30 seconds)
HOUND.DATAPOINTS_INTERVAL = 15   -- More frequent samples

-- Timeout for silent emitters
HOUND.CONTACT_TIMEOUT = 900      -- Default (15 minutes)
HOUND.CONTACT_TIMEOUT = 600      -- 10 minutes (less memory)
HOUND.CONTACT_TIMEOUT = 1800     -- 30 minutes (longer tracking)

-- Uncertainty ellipse calculation
HOUND.ELLIPSE_PERCENTILE = 0.6   -- Default (60th percentile)
HOUND.ELLIPSE_PERCENTILE = 0.7   -- Tighter ellipses (70%)

-- Maximum acceptable angular resolution
HOUND.MAX_ANGULAR_RES_DEG = 20   -- Default (20 degrees)
HOUND.MAX_ANGULAR_RES_DEG = 15   -- Stricter platform requirements
```

**Recommended:** Leave at defaults unless you have specific performance or accuracy requirements.

**Set before creating Hound instances.**

---

### Marker Appearance

Customize F10 map marker visual appearance:

```lua
-- Marker opacity (0.0 to 1.0)
HOUND.MARKER_MIN_ALPHA = 0.05      -- Minimum opacity (aged contacts)
HOUND.MARKER_MAX_ALPHA = 0.2       -- Maximum opacity (fresh contacts)
HOUND.MARKER_LINE_OPACITY = 0.3    -- Ellipse border opacity

-- Text marker pointer symbol
HOUND.MARKER_TEXT_POINTER = "⇙ "   -- Default arrow
HOUND.MARKER_TEXT_POINTER = "► "   -- Alternative pointer
HOUND.MARKER_TEXT_POINTER = "• "   -- Simple bullet
```

**Use Cases:**

- Increase opacity for better visibility
- Decrease opacity to reduce map clutter
- Change pointer symbol for personal preference

**Set before creating Hound instances.**

---

### Marker Management

```lua
HOUND.FORCE_MANAGE_MARKERS = true  -- Force internal counter
HOUND.Utils.setInitialMarkId(20000)  -- Starting marker ID
```

**Set before creating Hound instances.**

---

## Player Callsigns

### Callsign Override

```lua
local callsigns = {
    Uzi = "Viper",
    Enfield = "Raptor",
    ["*"] = "*"  -- Wildcard: use group name
}
HoundInstance:setCallsignOverride(callsigns)
```

---

## Radio Menu

### Menu Parent

```lua
local CustomMenu = missionCommands.addSubMenuForCoalition(
    coalition.side.BLUE,
    "Intelligence"
)
HoundInstance:setRadioMenuParent(CustomMenu)
```

**Set before enabling controller.**

---

## System Control

### Activation

```lua
HoundInstance:systemOn()
HoundInstance:systemOff()
```

---

## Data Export

### LUA Tables

```lua
local sites = HoundInstance:getSites()
local contacts = HoundInstance:getContacts()  -- Legacy
```

### CSV Export

```lua
HoundInstance:dumpIntelBrief()
HoundInstance:dumpIntelBrief("filename.csv")
```

Requires desanitized `io` and `lfs`.

📖 [Exports Guide](exports.md)

---

## Event Handlers

### Register/Remove

```lua
HOUND.addEventHandler(MyHandler)
HOUND.removeEventHandler(MyHandler)
```

### Handler Structure

```lua
MyHandler = {}
function MyHandler:onHoundEvent(event)
    -- Handle event
end
```

📖 [Event Handlers Guide](event-handlers.md)

---

## Function Reference

### Instance Creation

| Function              | Parameters            | Returns  |
| --------------------- | --------------------- | -------- |
| `HoundElint:create()` | coalition or unitName | Instance |

### Platform Management

| Function              | Parameters            | Returns |
| --------------------- | --------------------- | ------- |
| `addPlatform()`       | unitName              | -       |
| `removePlatform()`    | unitName              | -       |
| `preBriefedContact()` | unitName [, codeName] | -       |

### Sector Management

| Function         | Parameters              | Returns       |
| ---------------- | ----------------------- | ------------- |
| `addSector()`    | sectorName              | -             |
| `removeSector()` | sectorName              | -             |
| `listSectors()`  | -                       | table         |
| `setZone()`      | sectorName [, zoneName] | -             |
| `removeZone()`   | sectorName              | -             |
| `getZone()`      | sectorName              | string or nil |

### Communications

| Function                | Parameters             | Returns |
| ----------------------- | ---------------------- | ------- |
| `enableController()`    | [sectorName,] [config] | -       |
| `disableController()`   | [sectorName]           | -       |
| `configureController()` | [sectorName,] config   | -       |
| `enableAtis()`          | [sectorName,] [config] | -       |
| `disableAtis()`         | [sectorName]           | -       |
| `configureAtis()`       | [sectorName,] config   | -       |
| `enableNotifier()`      | [sectorName,] [config] | -       |
| `removeNotifier()`      | [sectorName]           | -       |
| `configureNotifier()`   | [sectorName,] config   | -       |

### Settings

| Function                     | Parameters          | Returns |
| ---------------------------- | ------------------- | ------- |
| `enableMarkers()`            | [markerType]        | -       |
| `disableMarkers()`           | -                   | -       |
| `setMarkerType()`            | markerType          | -       |
| `enableSiteMarkers()`        | -                   | -       |
| `disableSiteMarkers()`       | -                   | -       |
| `enableBDA()`                | -                   | -       |
| `disableBDA()`               | -                   | -       |
| `getBDA()`                   | -                   | boolean |
| `setAlertOnLaunch()`         | boolean             | -       |
| `getAlertOnLaunch()`         | -                   | boolean |
| `enablePlatformPosErrors()`  | -                   | -       |
| `disablePlatformPosErrors()` | -                   | -       |
| `setTimerInterval()`         | timerName, seconds  | -       |
| `setAtisUpdateInterval()`    | seconds             | -       |
| `enableText()`               | sectorName          | -       |
| `disableText()`              | sectorName          | -       |
| `enableTTS()`                | sectorName          | -       |
| `disableTTS()`               | sectorName          | -       |
| `enableAlerts()`             | sectorName          | -       |
| `disableAlerts()`            | sectorName          | -       |
| `reportEWR()`                | sectorName, boolean | -       |
| `enableNATO()`               | -                   | -       |
| `disableNATO()`              | -                   | -       |
| `getNATO()`                  | -                   | boolean |
| `onScreenDebug()`            | boolean             | -       |

### Callsigns & Menu

| Function                | Parameters              | Returns |
| ----------------------- | ----------------------- | ------- |
| `setCallsign()`         | sectorName [, callsign] | -       |
| `getCallsign()`         | sectorName              | string  |
| `useNATOCallsignes()`   | boolean                 | -       |
| `setCallsignOverride()` | table                   | -       |
| `setRadioMenuParent()`  | menu                    | -       |

### Transmitter

| Function              | Parameters           | Returns |
| --------------------- | -------------------- | ------- |
| `setTransmitter()`    | sectorName, unitName | -       |
| `removeTransmitter()` | sectorName           | -       |

### System Control

| Function      | Parameters | Returns |
| ------------- | ---------- | ------- |
| `systemOn()`  | -          | -       |
| `systemOff()` | -          | -       |

### Data Export

| Function           | Parameters | Returns |
| ------------------ | ---------- | ------- |
| `getSites()`       | -          | table   |
| `getContacts()`    | -          | table   |
| `dumpIntelBrief()` | [filename] | -       |

---

## Enums

### HOUND.MARKER

- `HOUND.MARKER.NONE`
- `HOUND.MARKER.SITE_ONLY`
- `HOUND.MARKER.POINT`
- `HOUND.MARKER.CIRCLE`
- `HOUND.MARKER.DIAMOND`
- `HOUND.MARKER.OCTAGON`
- `HOUND.MARKER.POLYGON`

### HOUND.EVENTS

See [Event Handlers Guide](event-handlers.md#available-events)

---

## Next Steps

- **[Basic Configuration](basic-configuration.md)** - Common settings
- **[Advanced Configuration](advanced-configuration.md)** - Complex setups
- **[API Documentation](https://uriba107.github.io/DCS-Hound/)** - Full API reference
