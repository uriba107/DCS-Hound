# Basic Configuration

Essential configuration options for getting Hound working in your mission.

---

## Minimum Configuration

The absolute minimum needed to run Hound:

```lua
do
  HoundBlue = HoundElint:create(coalition.side.BLUE)
  HoundBlue:addPlatform("ELINT_Unit_1")
  HoundBlue:addPlatform("ELINT_Unit_2")
  HoundBlue:systemOn()
end
```

This provides:

- ✅ Automatic radar detection
- ✅ F10 map markers
- ✅ Position triangulation
- ❌ No voice communications
- ❌ No text messages

---

## Creating a Hound Instance

### Method 1: Direct Coalition Assignment

```lua
HoundBlue = HoundElint:create(coalition.side.BLUE)
HoundRed = HoundElint:create(coalition.side.RED)
```

**Use when:** You want explicit control over coalition

### Method 2: Platform-Based Creation

```lua
-- Coalition taken from unit's coalition
HoundBlue = HoundElint:create("ELINT_C130")
```

**Use when:** You have a unit ready and want shorthand

---

## Adding Platforms

### Basic Platform Addition:

```lua
HoundInstance:addPlatform("Unit_Name")
```

**Important:** Use exact **unit name** or **pilot name**, NOT group name!

### Finding Unit Names:

In Mission Editor:

1. Select the unit
2. Check "Pilot" field for aircraft
3. Check "Name" field for ground units/statics
4. Use that exact string

### Multiple Platforms:

```lua
HoundBlue:addPlatform("ELINT_North")
HoundBlue:addPlatform("ELINT_South")
HoundBlue:addPlatform("ELINT_Tower_1")
HoundBlue:addPlatform("ELINT_Tower_2")
```

### Dynamic Addition (During Mission):

```lua
-- Add platform after system is running
HoundBlue:addPlatform("Reinforcement_ELINT")
```

**Use cases:**

- Triggered reinforcements
- Mission events
- Dynamic slot spawning

### Removing Platforms:

```lua
HoundBlue:removePlatform("ELINT_North")
```

**Note:** Platforms automatically removed if destroyed

📖 **Platform selection guide:** [Available Platforms](platforms.md)

---

## Activating the System

### Start Hound:

```lua
HoundBlue:systemOn()
```

This starts all timers and begins detection.

### Stop Hound:

```lua
HoundBlue:systemOff()
```

**Use cases:**

- Mission events (intel blackout)
- Testing/debugging
- Performance management

### Restart:

```lua
HoundBlue:systemOff()
-- ... some time later ...
HoundBlue:systemOn()
```

---

## Pre-Briefed Contacts

Add known SAM sites with exact positions:

### Single Unit:

```lua
HoundBlue:preBriefedContact("SAM_SA6_TR")
```

### Entire Group:

```lua
-- All valid radars in group added
HoundBlue:preBriefedContact("SAM_Group_1")
```

### With Custom Name:

```lua
HoundBlue:preBriefedContact("SAM_SA10_Group", "ANVIL")
```

### Behavior:

**Advantages:**

- Exact position (no uncertainty)
- Immediate availability (no wait for detection)
- Marked as "Pre-Briefed" in reports

**Special Case:**

- If radar moves >100m from original position AND is detected by Hound
- "Pre-Briefed" status removed
- Treated as normal contact thereafter

**Use Cases:**

- Known enemy positions from intel
- Strike packages with briefed coordinates
- Training missions with fixed sites

---

## Map Markers

### Enable/Disable Markers:

```lua
-- Enable (default)
HoundBlue:enableMarkers()

-- Disable completely
HoundBlue:disableMarkers()
```

### Marker Types:

```lua
HoundBlue:setMarkerType(HOUND.MARKER.CIRCLE)
```

**Available Types:**

| Type                     | Description                      | Performance |
| ------------------------ | -------------------------------- | ----------- |
| `HOUND.MARKER.NONE`      | No ellipse drawn                 | Best        |
| `HOUND.MARKER.SITE_ONLY` | Only site markers                | Excellent   |
| `HOUND.MARKER.POINT`     | Position points only             | Excellent   |
| `HOUND.MARKER.CIRCLE`    | Circular approximation (default) | Good        |
| `HOUND.MARKER.DIAMOND`   | 4-point ellipse                  | Good        |
| `HOUND.MARKER.OCTAGON`   | 8-point ellipse                  | Fair        |
| `HOUND.MARKER.POLYGON`   | 16-point ellipse (most accurate) | Moderate    |

**Trade-offs:**

- More points = more accurate ellipse representation
- More points = more map markers = worse performance
- For large missions, use CIRCLE or NONE

### Quick Setup:

```lua
-- Enable with specific type in one call
HoundBlue:enableMarkers(HOUND.MARKER.POLYGON)
```

### Site Markers:

Site markers show grouped radars (e.g., "SA-6 Site 3").

```lua
-- Enabled by default
HoundBlue:enableSiteMarkers()

-- Disable separately
HoundBlue:disableSiteMarkers()
```

**Note:** Site markers and uncertainty markers are independent!

📖 **Full marker documentation:** [Map Markers Guide](map-markers.md)

---

## Debug Output

### On-Screen Debug:

```lua
-- Enable
HoundBlue:onScreenDebug(true)

-- Disable (default)
HoundBlue:onScreenDebug(false)
```

**Shows:**

- Hound status after each update cycle (~15 seconds)
- Number of contacts
- Platform status
- Processing information

**Use for:**

- Debugging detection issues
- Monitoring system health
- Development/testing

---

## Battle Damage Assessment (BDA)

### Enable/Disable:

```lua
-- Enable (default)
HoundBlue:enableBDA()

-- Disable
HoundBlue:disableBDA()

-- Check current setting
local bdaEnabled = HoundBlue:getBDA()
```

**What BDA Does:**

- Announces when radars are destroyed
- Sends notifications via Controller and Notifier
- Updates markers to show destroyed status

**When to Disable:**

- Training missions where persistence desired
- Missions with respawning SAMs
- Custom destruction handling via events

---

## Launch Alerts

### Enable/Disable:

```lua
-- Enable
HoundBlue:setAlertOnLaunch(true)

-- Disable (default)
HoundBlue:setAlertOnLaunch(false)

-- Check current setting
local launchAlerts = HoundBlue:getAlertOnLaunch()
```

**What This Does:**

- ELINT platforms report when tracked SAMs launch missiles
- Broadcasts on Controller and Notifier frequencies
- Improves situational awareness

**Example Alert:**

> "Attention all aircraft! SAM launch detected! SA-6 Site 3, Bullseye 180 for 45."

---

## Platform Position Errors (Realism)

### Enable/Disable:

```lua
-- Enable realistic position errors
HoundBlue:enablePlatformPosErrors()

-- Disable (default, perfect positions)
HoundBlue:disablePlatformPosErrors()
```

**What This Simulates:**

- INS drift over time
- GPS accuracy variations
- Position reporting errors

**Effect:**

- Slightly larger uncertainty ellipses
- More realistic training
- Less "perfect" solutions

**Recommended for:**

- Realistic training missions
- Testing SEAD tactics
- Missions emphasizing ELINT limitations

---

## Callsign Overrides

DCS has limited callsigns. You can override them:

```lua
local callsignOverride = {
    Uzi = "Tulip",
    Enfield = "Blade",
    ["*"] = "*"  -- Use group name for wildcard
}

HoundBlue:setCallsignOverride(callsignOverride)
```

**Wildcard (`*`):**

- Any flight with wildcard DCS callsign uses group name instead
- Useful for multiple custom callsigns with limited DCS options

**⚠️ Warning:** Be cautious with wildcard + dynamic slots without templates!

---

## Radio Menu Position

Move the F10 radio menu to a different location:

```lua
-- Create parent menu FIRST
local CustomMenu = missionCommands.addSubMenuForCoalition(
    coalition.side.BLUE,
    "Custom Intel Menu"
)

-- THEN assign to Hound
HoundBlue:setRadioMenuParent(CustomMenu)

-- THEN enable controller
HoundBlue:enableController()
```

**Important:** Set parent menu before calling `enableController()`!

**Default:** ELINT menu in F10 root

---

## MGRS Precision

Set MGRS coordinate precision:

```lua
-- Default: 5 digits (10-digit MGRS: 12345 67890)
HOUND.setMgrsPresicion(5)

-- Lower precision: 3 digits (6-digit MGRS: 123 678)
HOUND.setMgrsPresicion(3)

-- Higher precision: 6 digits (12-digit MGRS: 123456 678901)
HOUND.setMgrsPresicion(6)
```

**Note:** This is a global setting (affects all instances).

---

## Complete Basic Example

```lua
do
  -- Create instance
  HoundBlue = HoundElint:create(coalition.side.BLUE)

  -- Add platforms
  HoundBlue:addPlatform("ELINT_C130_North")
  HoundBlue:addPlatform("ELINT_C130_South")
  HoundBlue:addPlatform("ELINT_Tower_Hermon")

  -- Add pre-briefed sites
  HoundBlue:preBriefedContact("Known_SAM_1", "ANVIL")
  HoundBlue:preBriefedContact("Known_SAM_2", "HAMMER")

  -- Configure markers
  HoundBlue:setMarkerType(HOUND.MARKER.CIRCLE)
  HoundBlue:enableMarkers()
  HoundBlue:enableSiteMarkers()

  -- Enable features
  HoundBlue:enableBDA()
  HoundBlue:setAlertOnLaunch(true)

  -- Optional: Realism
  HoundBlue:enablePlatformPosErrors()

  -- Optional: Debug
  -- HoundBlue:onScreenDebug(true)

  -- Activate system
  HoundBlue:systemOn()
end
```

---

## Configuration Tips

### For Beginners:

Start with minimal config, add features as needed:

1. Add platforms + `systemOn()`
2. Test detection with map markers
3. Add voice communications
4. Add advanced features

### For Mission Builders:

Consider your audience:

- **Casual players:** Keep it simple, full alerts
- **Realistic ops:** Position errors, limited alerts
- **Training:** Pre-briefed contacts for practice

### Performance Considerations:

Large missions with many radars:

- Use `HOUND.MARKER.CIRCLE` or `HOUND.MARKER.NONE`
- Disable site markers if not needed
- See [Performance Tuning](performance.md)

---

## Next Steps

### Add Communications:

- **[Controller Setup](controller.md)** - Interactive voice/text
- **[ATIS Setup](atis.md)** - Automated broadcasts
- **[TTS Configuration](tts-configuration.md)** - Voice setup

### Advanced Features:

- **[Sectors](sectors.md)** - Multiple regions
- **[Events](event-handlers.md)** - Custom scripting
- **[Advanced Configuration](advanced-configuration.md)** - Complex setups

### Reference:

- **[Settings Reference](settings-reference.md)** - All options
- **[Troubleshooting](troubleshooting.md)** - Common issues
