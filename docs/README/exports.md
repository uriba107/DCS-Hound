# Data Exports

Exporting Hound intelligence data for analysis and integration.

---

## Overview

Hound can export detected radar information in two formats:

1. **LUA Tables** - For script integration
2. **CSV Files** - For external analysis

---

## LUA Table Exports

Export data as LUA tables for use in scripts.

### Two Export Methods:

1. **Site Export** (Recommended) - Grouped by SAM sites
2. **Contact Export** (Legacy) - Individual radars only

---

## Site Export

Returns structured data with radars grouped into SAM sites.

### Usage:

```lua
local data = HoundInstance:getSites()
```

### Return Structure:

```lua
{
    ewr = {
        count = <number>,
        sites = {
            [1] = <site object>,
            [2] = <site object>,
            ...
        }
    },
    sam = {
        count = <number>,
        sites = {
            [1] = <site object>,
            [2] = <site object>,
            ...
        }
    }
}
```

### Site Object Structure:

```lua
{
    name = "<Site Name>",                -- e.g., "T-003"
    DcsObjectName = "<DCS Group Name>",  -- e.g., "SAM_SA6_Group"
    gid = <3-digit number>,              -- Group ID
    Type = "<SAM Type>",                 -- e.g., "SA-6"
    last_seen = <timestamp>,             -- timer.getAbsTime()
    emitters = {
        [1] = <emitter object>,
        [2] = <emitter object>,
        ...
    }
}
```

### Emitter Object Structure:

```lua
{
    typeName = "<Radar Type>",           -- e.g., "Straight Flush"
    uid = <2-digit number>,              -- Track ID
    DcsObjectName = "<DCS Unit Name>",   -- DCS unit name
    maxWeaponsRange = <number>,          -- Max range in meters
    last_seen = <timestamp>,             -- timer.getAbsTime()
    detected_by = {<platform names>},    -- List of detecting platforms

    -- If position available:
    pos = {x = <number>, y = <number>, z = <number>},
    LL = {
        lat = <number>,
        lon = <number>
    },
    accuracy = "<accuracy rating>",
    uncertainty = {
        major = <number>,                -- Meters
        minor = <number>,                -- Meters
        heading = <number>               -- Degrees
    }
}
```

### Example Usage:

```lua
local data = HoundBlue:getSites()

-- SAM sites
env.info("SAM sites detected: " .. data.sam.count)
for _, site in ipairs(data.sam.sites) do
    env.info("Site: " .. site.name .. " Type: " .. site.Type)
    env.info("  Emitters: " .. #site.emitters)

    for _, emitter in ipairs(site.emitters) do
        env.info("    " .. emitter.typeName .. " (" .. emitter.uid .. ")")
        if emitter.pos then
            env.info(string.format("      Position: %.2f, %.2f", emitter.LL.lat, emitter.LL.lon))
            env.info("      Accuracy: " .. emitter.accuracy)
        end
    end
end

-- EWR sites
env.info("EWR sites detected: " .. data.ewr.count)
```

---

## Contact Export (Legacy)

Returns individual radars without site grouping.

### Usage:

```lua
local data = HoundInstance:getContacts()
```

### Return Structure:

```lua
{
    ewr = {
        count = <number>,
        contacts = {
            [1] = <emitter object>,
            [2] = <emitter object>,
            ...
        }
    },
    sam = {
        count = <number>,
        contacts = {
            [1] = <emitter object>,
            [2] = <emitter object>,
            ...
        }
    }
}
```

Emitter objects have same structure as in Site Export.

### Example Usage:

```lua
local data = HoundBlue:getContacts()

-- All SAM radars
for _, contact in ipairs(data.sam.contacts) do
    env.info(contact.typeName .. " at " .. contact.DcsObjectName)
end

-- All EWR radars
for _, contact in ipairs(data.ewr.contacts) do
    env.info(contact.typeName .. " (EWR)")
end
```

---

## CSV Export

Export data to CSV file for external analysis.

### Requirements:

**Must desanitize:**

- `io` module
- `lfs` module

📖 See: [Installation Guide](installation.md#3-desanitize-scripting-engine-if-using-tts)

### Usage:

```lua
-- Default filename: hound_contacts_XX.csv (XX = instance ID)
HoundInstance:dumpIntelBrief()

-- Custom filename
HoundInstance:dumpIntelBrief("mission_intel.csv")
```

### Output Location:

```
<Saved Games>\DCS\hound_contacts_XX.csv
```

or

```
<Saved Games>\DCS.openbeta\hound_contacts_XX.csv
```

### CSV Structure:

```csv
SiteId,SiteNatoDesignation,TrackId,RadarType,State,Bullseye,Latitude,Longitude,MGRS,Accuracy,lastSeen,DcsType,DcsUnit,DcsGroup,ReportGenerated
```

### CSV Columns:

| Column                  | Description                          |
| ----------------------- | ------------------------------------ |
| **SiteId**              | Site identifier (T-001, S-005, etc.) |
| **SiteNatoDesignation** | NATO designation or EWR              |
| **TrackId**             | Radar track ID (I-12, E-05, etc.)    |
| **RadarType**           | Radar type name                      |
| **State**               | Active, Asleep, Recent, etc.         |
| **Bullseye**            | Bearing/Range from bullseye          |
| **Latitude**            | Decimal degrees                      |
| **Longitude**           | Decimal degrees                      |
| **MGRS**                | MGRS grid                            |
| **Accuracy**            | Accuracy rating                      |
| **lastSeen**            | Timestamp (seconds)                  |
| **DcsType**             | DCS unit type                        |
| **DcsUnit**             | DCS unit name                        |
| **DcsGroup**            | DCS group name                       |
| **ReportGenerated**     | Export timestamp                     |

### Example CSV Data:

```csv
SiteId,SiteNatoDesignation,TrackId,RadarType,State,Bullseye,Latitude,Longitude,MGRS,Accuracy,lastSeen,DcsType,DcsUnit,DcsGroup,ReportGenerated
T002,2,I-1,Fan-song,Asleep,187/78,33.721733,35.800634,36S YC 5951 3482,Precise,1700,SNR_75V,SAM_SA2_TR,SAM_SA2,1730
T002,2,I-3,Flat Face,Active,187/78,33.723213,35.799935,36S YC 5944 3498,Precise,1730,p-19 s-125 sr,SAM_SA2_SR,SAM_SA2,1730
S009,EWR,I-8,Box Spring,Active,170/44,34.301650,36.114852,37S BT 3446 9937,Precise,1730,1L13 EWR,EWR-5-1,EWR-5,1730
```

---

## Export Examples

### Example 1: Count Active Threats

```lua
local data = HoundBlue:getSites()
local activeSAMs = 0

for _, site in ipairs(data.sam.sites) do
    for _, emitter in ipairs(site.emitters) do
        if emitter.last_seen > (timer.getAbsTime() - 120) then  -- Active in last 2 minutes
            activeSAMs = activeSAMs + 1
        end
    end
end

trigger.action.outText("Active SAM radars: " .. activeSAMs, 10)
```

### Example 2: Find Nearest Threat

```lua
local playerPos = myAircraft:getPoint()
local data = HoundBlue:getSites()
local nearest = nil
local nearestDist = math.huge

for _, site in ipairs(data.sam.sites) do
    for _, emitter in ipairs(site.emitters) do
        if emitter.pos then
            local dist = mist.utils.get2DDist(playerPos, emitter.pos)
            if dist < nearestDist then
                nearestDist = dist
                nearest = emitter
            end
        end
    end
end

if nearest then
    trigger.action.outText(string.format("Nearest threat: %s at %.1f nm",
        nearest.typeName,
        mist.utils.metersToNM(nearestDist)), 10)
end
```

### Example 3: Export on Mission End

```lua
-- Trigger at mission end
function ExportIntelOnEnd()
    HoundBlue:dumpIntelBrief("mission_" .. os.date("%Y%m%d_%H%M%S") .. ".csv")
    trigger.action.outText("Intelligence report saved.", 10)
end

-- Call from mission trigger or script
```

### Example 4: Track Detection Coverage

```lua
local data = HoundBlue:getContacts()
local platformStats = {}

for _, contact in ipairs(data.sam.contacts) do
    for _, platformName in ipairs(contact.detected_by) do
        if not platformStats[platformName] then
            platformStats[platformName] = 0
        end
        platformStats[platformName] = platformStats[platformName] + 1
    end
end

-- Display platform effectiveness
for platform, count in pairs(platformStats) do
    env.info(platform .. ": " .. count .. " detections")
end
```

### Example 5: Integration with External Tools

```lua
-- Export every 5 minutes for live monitoring
local function periodicExport()
    HoundBlue:dumpIntelBrief("live_intel.csv")

    -- Schedule next export
    timer.scheduleFunction(periodicExport, nil, timer.getTime() + 300)
end

-- Start periodic export
periodicExport()
```

---

## Data Analysis Use Cases

### CSV Export Good For:

1. **Mission Debrief**
   - Analyze threat distribution
   - Review platform effectiveness
   - Assess mission success

2. **Mission Planning**
   - Import to mapping software
   - Plan strike routes
   - Identify coverage gaps

3. **Training Analysis**
   - Student performance review
   - Threat detection patterns
   - Timing analysis

4. **Integration**
   - External mapping tools
   - Database import
   - Automated processing

### LUA Export Good For:

1. **Real-Time Integration**
   - Dynamic mission scripting
   - Automated responses
   - Live overlays

2. **Mission Logic**
   - Win/loss conditions
   - Dynamic tasking
   - Objective tracking

3. **Custom Displays**
   - Custom UI elements
   - Real-time dashboards
   - Player feedback

---

## Export Best Practices

### Timing:

**CSV Export:**

- Mission end
- Key milestones
- Periodic snapshots
- On-demand (F10 menu trigger)

**LUA Export:**

- Real-time queries
- Event-driven
- High-frequency OK (lightweight)

### File Management:

**CSV files accumulate:**

- Automatically timestamped filenames
- Regular cleanup recommended
- Consider archiving old reports

```lua
-- Auto-timestamped export
HoundBlue:dumpIntelBrief(string.format("intel_%s.csv", os.date("%Y%m%d_%H%M%S")))
```

### Performance:

**LUA exports:**

- Very fast, minimal impact
- Can call frequently

**CSV exports:**

- Disk I/O involved
- Don't call every frame
- Recommended: ≥60 second intervals

---

## Troubleshooting Exports

### CSV Export Fails:

**Error: "attempt to call nil value"**

**Cause:** `io` or `lfs` not desanitized

**Fix:**

1. Edit `DCS World\Scripts\MissionScripting.lua`
2. Uncomment sanitize lines for `io` and `lfs`
3. Restart DCS

### File Not Created:

**Check:**

1. Desanitization complete?
2. Check `dcs.log` for errors
3. File permissions in Saved Games folder?

### Empty/Partial Data:

**Cause:** No radars detected or positioned yet

**Wait for:**

- Initial detection (30-60 seconds)
- Position calculation (1-2 minutes)
- Then export

### LUA Export Returns Empty:

**Check:**

1. System activated? `HoundInstance:systemOn()`
2. Platforms added?
3. Enemy radars present and ON?
4. Sufficient time for detection?

---

## Advanced: Custom Export Format

For advanced users needing different format:

```lua
function customExport()
    local data = HoundBlue:getSites()
    local output = {}

    for _, site in ipairs(data.sam.sites) do
        for _, emitter in ipairs(site.emitters) do
            if emitter.pos then
                table.insert(output, {
                    type = emitter.typeName,
                    lat = emitter.LL.lat,
                    lon = emitter.LL.lon,
                    accuracy = emitter.accuracy,
                    threat_range = emitter.maxWeaponsRange
                })
            end
        end
    end

    -- Convert to JSON or other format
    -- Your export code here

    return output
end
```

---

## Integration Examples

### Google Earth KML Export:

```lua
function exportToKML()
    local data = HoundBlue:getSites()
    local kml = '<?xml version="1.0" encoding="UTF-8"?>\n'
    kml = kml .. '<kml xmlns="http://www.opengis.net/kml/2.2">\n<Document>\n'

    for _, site in ipairs(data.sam.sites) do
        for _, emitter in ipairs(site.emitters) do
            if emitter.pos then
                kml = kml .. string.format(
                    '<Placemark>\n<name>%s</name>\n<Point>\n<coordinates>%.6f,%.6f,0</coordinates>\n</Point>\n</Placemark>\n',
                    emitter.typeName,
                    emitter.LL.lon,
                    emitter.LL.lat
                )
            end
        end
    end

    kml = kml .. '</Document>\n</kml>'

    -- Write to file
    local file = io.open(lfs.writedir() .. "hound_export.kml", "w")
    file:write(kml)
    file:close()
end
```

### JSON Export:

```lua
function exportToJSON()
    local data = HoundBlue:getSites()
    local json = '{"sam_sites":['

    for i, site in ipairs(data.sam.sites) do
        if i > 1 then json = json .. ',' end
        json = json .. string.format(
            '{"name":"%s","type":"%s","emitters":%d}',
            site.name,
            site.Type,
            #site.emitters
        )
    end

    json = json .. ']}'

    local file = io.open(lfs.writedir() .. "hound_export.json", "w")
    file:write(json)
    file:close()
end
```

---

## Summary

### Export Types:

| Method               | Format    | Use Case           | Requirements       |
| -------------------- | --------- | ------------------ | ------------------ |
| **getSites()**       | LUA Table | Script integration | None               |
| **getContacts()**    | LUA Table | Legacy scripts     | None               |
| **dumpIntelBrief()** | CSV File  | External analysis  | Desanitized io/lfs |

### Best Practices:

1. **Use getSites()** for new scripts (better organization)
2. **CSV for post-mission** analysis
3. **Timestamp CSV files** to avoid overwrites
4. **Check data availability** before exporting
5. **Don't export too frequently** (CSV)

---

## Next Steps

- **[Event Handlers](event-handlers.md)** - Real-time data processing
- **[Advanced Configuration](advanced-configuration.md)** - Complex setups
- **[Installation](installation.md)** - Desanitization guide
