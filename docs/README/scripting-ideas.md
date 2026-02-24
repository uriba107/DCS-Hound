# Hound Scripting Ideas

This document contains ideas that might be interesting to try and implement in missions.
Having a full implementation is not important. Ideas may contain snippets or pseudo code, but it's not mandatory.
This section is primarily here to inspire new ideas and concepts, so feel free to submit a PR or open an issue with your ideas.

`NOTE: Unless specifically stated, assume all code here to be untested`

## Add radars detected by UAV/Recon flight

Hound has "Pre-briefed" target acquisition mode. This can be added in real-time.
For example, an "assigned" recon platform such as a UAV can periodically perform [getDetectedTargets](https://wiki.hoggitworld.com/view/DCS_func_getDetectedTargets) and add visually detected radar units as pre-briefed targets to Hound.

### Extended Version

Use Hound's `RADAR_DETECTED` event to change the route of a unit that will perform visual detection of the radar to add it as a pre-briefed contact:

```lua
function PBviaUnit(HoundInstance, unitName)
    local IntelUnit = Unit.getByName(unitName)
    if not IntelUnit then return end
    local controller = IntelUnit:getController()
    if not controller then return end
    local visTargets = IntelUnit:getDetectedTargets(Controller.Detection.VISUAL, Controller.Detection.OPTIC)
    for _, contact in pairs(visTargets) do
        if contact.visible and contact.type then
            local candidate = contact.object
            local type = candidate:getTypeName()
            if HOUND.DB.Radars[type] then
                HoundInstance:preBriefedContact(candidate:getName())
            end
        end
    end
end
```

## Send Hound events to DCS-gRPC

Emit all radar-related Hound events to DCS-gRPC in a serialized form:

```lua
FakeEventHandler = {}

function FakeEventHandler:onHoundEvent(HoundEvent)
    if GRPC ~= nil then
        if HoundEvent.id == HOUND.EVENTS.RADAR_DETECTED or
           HoundEvent.id == HOUND.EVENTS.RADAR_DESTROYED or
           HoundEvent.id == HOUND.EVENTS.RADAR_UPDATED
        then
            local hound_serializable = {
                id = HoundEvent.id,
                houndId = HoundEvent.houndId,
                coalition = HoundEvent.coalition,
                initiator = HoundEvent.initiator:export()
            }

            local RPCevent = {
                type = "scriptEvent",
                publisher = "hound",
                name = "HoundEvent_" .. HoundEvent.id,
                details = hound_serializable
            }

            GRPC.event({
                time = HoundEvent.time,
                event = RPCevent
            })
        end
    end
end

HOUND.addEventHandler(FakeEventHandler)
```

## Restricted Area Warning

This was originally done by PeneCruz for the ANZUS community.
When an aircraft violates a restricted airspace, you can use the Notifier or Controller to issue a verbal warning using TTS:

```lua
function violatedAirspace(unit, last_warning)
    local callsign = HOUND.Utils.getFormationCallsign(unit)
    local msg = callsign .. " You are violating restricted airspace! Please reverse course immediately!"
    if last_warning then
        msg = msg .. callsign .. " This is your last warning! Change course immediately!"
    end
    HoundInstance:transmitOnNotifier("all", msg, 0)
    return HOUND.Utils.TTS.getReadTime(msg)
end
```

---

## Player-Based ELINT with Waypoint Alerts

Players with ELINT pods automatically provide coverage. Alerts broadcast on Guard using waypoint sectors as references.

**Key Feature:** Hound's `AUTO_ADD_PLATFORM_BY_PAYLOAD` (enabled by default) automatically detects units with ELINT payloads when they spawn - no manual `addPlatform()` calls needed!

**Setup:** Draw zones around waypoints → Run script → Players spawn with ELINT pods → Automatic detection

```lua
-- =================================================================
-- Player-Based ELINT with Waypoint Sector Alerts
-- =================================================================

-- Configuration
local PLAYER_COALITION = coalition.side.BLUE
local GUARD_FREQ = "243.000"  -- Guard frequency

-- Define waypoint zones (Draw tool polygon names from Mission Editor)
local WAYPOINT_ZONES = {
    {name = "Waypoint 1", zone = "WP1_Zone"},
    {name = "Waypoint 2", zone = "WP2_Zone"},
    {name = "Waypoint 3", zone = "WP3_Zone"},
    {name = "Waypoint 4", zone = "WP4_Zone"},
    {name = "Waypoint 5", zone = "WP5_Zone"}
}

-- =================================================================
-- Create and Configure Hound Instance
-- =================================================================

HoundBlue = HoundElint:create(PLAYER_COALITION)

-- Enable Guard frequency notifier with launch alerts
HoundBlue:enableNotifier({
    freq = GUARD_FREQ,
    modulation = "AM"
})

-- Enable BDA and launch alerts (Hound's default messages)
HoundBlue:enableBDA()
HoundBlue:setAlertOnLaunch(true)

-- Disable markers (optional - remove this line if you want markers)
HoundBlue:disableMarkers()

-- =================================================================
-- Setup Waypoint Sectors
-- =================================================================

for _, wp in ipairs(WAYPOINT_ZONES) do
    -- Add sector with waypoint name
    HoundBlue:addSector(wp.name)

    -- Set zone using Draw tool polygon
    local success = HoundBlue:setZone(wp.name, wp.zone)

    if success then
        env.info("HOUND Player ELINT: Sector '" .. wp.name .. "' created with zone '" .. wp.zone .. "'")
    else
        env.warning("HOUND Player ELINT: Failed to create zone for '" .. wp.name .. "' using polygon '" .. wp.zone .. "'")
    end
end

-- =================================================================
-- Start Hound System
-- =================================================================

-- Hound will automatically detect and add player aircraft with ELINT pods
-- via AUTO_ADD_PLATFORM_BY_PAYLOAD (enabled by default)

HoundBlue:systemOn()

env.info("HOUND Player ELINT: System initialized with " .. #WAYPOINT_ZONES .. " waypoint sectors on " .. GUARD_FREQ)
```

### Mission Editor Setup

Use **DCS Draw Tool** to create zones around waypoints:

1. Open Drawing panel (toolbar or F10 map)
2. Select Freeform Polygon or Circle
3. Draw zone around waypoint area (2-5 NM radius)
4. Name it: `WP1_Zone`, `WP2_Zone`, etc.
5. Save mission

### Requirements

- Players must **spawn with ELINT pods loaded** (F-16 HTS, Su-25T Fantasmagoria, etc.)
- HoundTTS or STTS for voice (optional)

### Example Alert

```
"Attention all aircraft! This is HOUND. New threat detected!
SA-6 Straight Flush is now active in Waypoint 3."
```

### Troubleshooting

- **Players not added?** Must spawn with pods loaded (DCS limitation - can't add after spawn)
- **No sector names?** Check Draw tool polygon names match `WAYPOINT_ZONES` table
- **No voice?** Install HoundTTS or enable STTS
