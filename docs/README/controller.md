# SAM Controller

Interactive controller providing detailed radar intelligence on-demand via F10 menu and radio.

---

## Basic Setup

```lua
-- Default sector (250.000 AM)
HoundInstance:enableController()

-- Custom frequency
HoundInstance:enableController({freq = "251.000", modulation = "AM"})

-- Specific sector
HoundInstance:addSector("North")
HoundInstance:enableController("North", {freq = "251.000", modulation = "AM"})

-- Disable
HoundInstance:disableController("sectorName")
```

---

## Configuration

```lua
local controller_config = {
    freq = "251.000",            -- Single or comma-separated
    modulation = "AM",           -- "AM" or "FM", comma-separated if multiple
    -- TTS options (see tts-configuration.md for details)
    gender = "male",
    culture = "en-US",
    speed = 0,                   -- -10 to +10 (STTS) or 50-250 (gRPC)
    volume = "1.0"
}

HoundInstance:enableController(controller_config)
```

📖 **TTS configuration:** [tts-configuration.md](tts-configuration.md)

---

## F10 Radio Menu

```
F10 Other → ELINT → HOUND (or sector callsign)
├─ Check In (required for text messages)
├─ Request BRAA (nearest threat bearing/range/altitude/aspect)
├─ Declare (detailed single-contact report)
├─ Request Picture (sector threat summary)
├─ Sites (SAM site reports)
├─ Contacts (individual radar reports)
└─ Settings (enable/disable text per player)
```

---

## Report Format

Full report includes: Type, Track ID, Status, Bullseye position, Accuracy, Lat/Lon (repeated), MGRS, Elevation, Ellipse (size/orientation), Tracking duration.

**Example:**

```
SA-6 Straight Flush India One-Two,
Active at Bullseye One-Eight-Zero for Four-Five, accuracy High,
position North Three-Four point Two-One-Five, East Zero-Three-Five point Eight-Zero-Three,
I repeat, North Three-Four point Two-One-Five, East Zero-Three-Five point Eight-Zero-Three,
MGRS Three-Six Sierra Lima One-Two-Three-Four-Five Six-Seven-Eight-Nine-Zero,
elevation Two-Three-Zero-Zero feet MSL,
ellipse is Eight-Hundred by Four-Hundred, aligned bearing Zero-Nine-Zero,
tracked for Three minutes, last seen Thirty seconds ago.
```

**Disable extended info** (ellipse/tracking):

```lua
HOUND.showExtendedInfo(false)  -- Global setting
```

---

## Text Messages

Text messages sent to "checked in" players only (F10 menu "Check In" once per mission).

```lua
-- Enable text
HoundInstance:enableText("sectorName")  -- or "all"

-- Disable text
HoundInstance:disableText("sectorName")

-- Text only (no voice)
HoundInstance:enableController()  -- No frequency
HoundInstance:enableText("default")
```

Text includes: information responses, new radar alerts, destroyed radar alerts, launch alerts (if enabled).

---

## Alerts

Controller provides automatic alerts: new radars detected, radars destroyed (BDA), SAM launches (optional).

```lua
-- Control all alerts
HoundInstance:enableAlerts("sectorName")   -- or "all" (default: on)
HoundInstance:disableAlerts("sectorName")

-- BDA (destroyed radars)
HoundInstance:enableBDA()   -- Default: on
HoundInstance:disableBDA()

-- Launch alerts
HoundInstance:setAlertOnLaunch(true)   -- Default: false
```

---

## Additional Configuration

**MGRS precision** (global):

```lua
HOUND.setMgrsPresicion(5)  -- 10-digit (default)
HOUND.setMgrsPresicion(4)  -- 8-digit
HOUND.setMgrsPresicion(3)  -- 6-digit
```

**Radio menu position:**

```lua
local CustomMenu = missionCommands.addSubMenuForCoalition(coalition.side.BLUE, "Intelligence")
HoundInstance:setRadioMenuParent(CustomMenu)  -- Before enabling controller
HoundInstance:enableController()
```

**Transmitter** (realistic radio range/LOS):

```lua
HoundInstance:setTransmitter("sectorName", "AWACS_Unit")  -- or "all"
HoundInstance:removeTransmitter("sectorName")
```

**Player callsigns:**

```lua
HoundInstance:setCallsignOverride({
    Uzi = "Viper",
    Enfield = "Raptor",
    ["*"] = "*"  -- Use group names
})
```

---

## Examples

```lua
-- Basic
HoundBlue:enableController({freq = "251.000", modulation = "AM"})

-- With text messages
HoundBlue:enableText("default")

-- Multiple sectors with different frequencies
HoundBlue:addSector("North")
HoundBlue:addSector("South")
HoundBlue:enableController("North", {freq = "251.000", modulation = "AM"})
HoundBlue:enableController("South", {freq = "255.000", modulation = "AM"})

-- With transmitter
HoundBlue:setTransmitter("default", "AWACS")
HoundBlue:enableController({freq = "251.000", modulation = "AM"})

-- No alerts (reports only)
HoundBlue:disableAlerts("default")
HoundBlue:disableBDA()
```

---

## Troubleshooting

**No voice:** Check TTS installed, scripting desanitized, SRS connected, transmitter alive (if used).  
**No F10 menu:** Verify controller enabled, system active (`systemOn()`), or reslot aircraft.  
**No text:** Enable text (`enableText`), player must "Check In" via F10 menu.  
**Menu wrong location:** Use `setRadioMenuParent()` before enabling controller.

See [troubleshooting.md](troubleshooting.md) for detailed diagnostics.
