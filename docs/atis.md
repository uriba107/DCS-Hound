# ATIS - Automated Information System

Continuous voice loop providing threat summaries every 5 minutes (configurable).

---

## Basic Setup

```lua
-- Default sector (250.500 AM, updates every 5 minutes)
HoundInstance:enableAtis()

-- Custom frequency
HoundInstance:enableAtis({freq = "253.000", modulation = "AM"})

-- Specific sector
HoundInstance:addSector("North")
HoundInstance:enableAtis("North", {freq = "253.000", modulation = "AM"})

-- Disable
HoundInstance:disableAtis("sectorName")
```

---

## Configuration

```lua
local atis_config = {
    freq = "253.000",            -- Single or comma-separated
    modulation = "AM",           -- "AM" or "FM", comma-separated if multiple
    -- TTS options (see tts-configuration.md for details)
    gender = "female",
    culture = "en-US",
    speed = 1,                   -- Slightly faster for ATIS (default: 1)
    volume = "1.0"
}

HoundInstance:enableAtis(atis_config)
```

📖 **TTS configuration:** [tts-configuration.md](tts-configuration.md)

---

## Message Format

**Normal (default):** Type, Track ID, Grid zone, Accuracy  
**NATO Lowdown:** NATO designation, Status, Bullseye position, Accuracy

Both include: Information identifier (Alpha/Bravo/...), EWR count, sign-off.

```lua
-- Enable NATO Lowdown
HoundInstance:enableNATO()

-- Disable (revert to normal)
HoundInstance:disableNATO()
```

---

## Update Interval

```lua
HoundInstance:setAtisUpdateInterval(120)  -- 2 minutes
HoundInstance:setAtisUpdateInterval(300)  -- 5 minutes (default)
HoundInstance:setAtisUpdateInterval(600)  -- 10 minutes
```

Shorter = more current, more radio traffic. Typical: 3-5 minutes.

---

## EWR Reporting

By default, EWRs are counted but not reported individually. Enable to report each EWR:

```lua
HoundInstance:reportEWR("sectorName", true)   -- or "all"
HoundInstance:reportEWR("sectorName", false)  -- Default
```

---

## Transmitter

Add transmitter for realistic radio range/LOS behavior:

```lua
HoundInstance:setTransmitter("sectorName", "AWACS_Unit")  -- or "all"
HoundInstance:removeTransmitter("sectorName")
```

If transmitter destroyed, ATIS stops until new transmitter assigned.

---

## Examples

```lua
-- Basic
HoundBlue:enableAtis({freq = "253.000", modulation = "AM"})

-- NATO Lowdown format
HoundBlue:enableNATO()

-- With EWR reporting
HoundBlue:reportEWR("default", true)

-- Fast update (2 minutes)
HoundBlue:setAtisUpdateInterval(120)

-- Multiple sectors
HoundBlue:addSector("North")
HoundBlue:addSector("South")
HoundBlue:enableAtis("North", {freq = "253.000", modulation = "AM"})
HoundBlue:enableAtis("South", {freq = "257.000", modulation = "AM"})

-- With transmitter
HoundBlue:setTransmitter("default", "AWACS")
```

---

## Troubleshooting

**No transmission:** Check TTS installed, ATIS enabled, system active (`systemOn()`), transmitter alive (if used), radars detected.  
**Not updating:** Verify interval setting, listen for information identifier change (Alpha→Bravo→Charlie...).  
**Can't hear:** Check frequency tuned, SRS connected, transmitter range/LOS (if used).

See [troubleshooting.md](troubleshooting.md) for detailed diagnostics.
