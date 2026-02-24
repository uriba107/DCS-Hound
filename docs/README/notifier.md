# Notifier

Voice alerts for new radars, destroyed radars, and SAM launches. Typically broadcast on guard frequencies.

---

## Alert Types

### New Threat Detected:

```
Attention all aircraft! This is HOUND.
New threat detected!
SA-6 Straight Flush India One-Two is now active, Bullseye One-Eight-Zero for Four-Five.
```

### Threat Destroyed:

```
Attention all aircraft! This is HOUND.
Contact destroyed!
SA-6 Straight Flush India One-Two has been eliminated.
```

### SAM Launch:

```
Attention all aircraft! This is HOUND.
SAM launch detected!
SA-6 Site Tango-Zero-Zero-Three, Bullseye One-Eight-Zero for Four-Five.
```

---

## Basic Setup

### Enable Notifier (Default):

```lua
HoundInstance:enableNotifier()
```

**Defaults:**

- Frequency: 243.000 AM and 121.500 AM (guard frequencies)
- All alerts enabled
- Generic voice

### Enable with Configuration:

```lua
HoundInstance:enableNotifier({
    freq = "243.000",
    modulation = "AM"
})
```

### Enable on Specific Sector:

```lua
HoundInstance:addSector("North")
HoundInstance:enableNotifier("North", {
    freq = "243.000",
    modulation = "AM"
})
```

### Remove Notifier:

```lua
HoundInstance:removeNotifier()
-- Or specific sector
HoundInstance:removeNotifier("North")
```

**Note:** Notifier uses "remove" not "disable" (unlike Controller/ATIS).

---

## Configuration Options

### Basic Configuration:

```lua
local notifier_config = {
    freq = "243.000",
    modulation = "AM"
}

HoundInstance:enableNotifier(notifier_config)
```

### Multiple Frequencies:

```lua
local notifier_config = {
    freq = "243.000,121.500",  -- Both guard frequencies
    modulation = "AM,AM"
}

HoundInstance:enableNotifier(notifier_config)
```

### Advanced Configuration:

```lua
local notifier_config = {
    freq = "243.000",
    modulation = "AM",
    gender = "male",
    culture = "en-US",
    volume = "1.0",
    speed = 0
}
```

### Advanced Configuration (gRPC):

```lua
local notifier_config = {
    freq = "243.000",
    modulation = "AM",
    gender = "male",
    culture = "en-US",
    speed = 100,
    volume = "1.0"
}
```

📖 **Full TTS options:** [TTS Configuration](tts-configuration.md)

---

## Notification Triggers

### What Triggers Notifications:

**New Radar:**

- First detection of enemy radar
- Radar comes back online after being silent

**Radar Destroyed:**

- Radar unit destroyed (requires BDA enabled)
- Manual marking as dead

**SAM Launch:**

- Tracked SAM fires missile (requires launch alerts enabled)

### Controlling Triggers:

**BDA (Destroyed Notifications):**

```lua
-- Enable (default)
HoundInstance:enableBDA()

-- Disable
HoundInstance:disableBDA()
```

**Launch Alerts:**

```lua
-- Enable
HoundInstance:setAlertOnLaunch(true)

-- Disable (default)
HoundInstance:setAlertOnLaunch(false)
```

**Note:** New radar alerts always active when Notifier enabled.

---

## Sector Behavior

### Default Sector:

When Notifier enabled on "default" sector:

**Radar in geofenced sector:**

```
Attention all aircraft! This is HOUND.
New threat detected!
SA-6 Straight Flush India One-Two is now active in North Syria.
```

**Radar not in any sector:**

```
Attention all aircraft! This is HOUND.
New threat detected!
SA-6 Straight Flush India One-Two is now active, Bullseye One-Eight-Zero for Four-Five, Grid Golf-Golf One-Four.
```

### Specific Sector:

Notifier on specific sector only reports that sector's radars:

```lua
HoundInstance:addSector("North")
HoundInstance:setZone("North", "Zone_North")
HoundInstance:enableNotifier("North", {freq = "243.000", modulation = "AM"})
```

**Only radars in "North" zone trigger notifications.**

### Global vs Local:

**Global Notifier (Default Sector):**

- Reports all radars
- Good for single-frequency monitoring
- Typically on guard

**Per-Sector Notifiers:**

- Each sector has own notifier
- Different frequencies per sector
- More organized for large missions

---

## Transmitter

Add transmitter for realistic radio:

```lua
HoundInstance:setTransmitter("sectorName", "Transmitter_Unit")
```

**Effects:**

- Notifications transmitted from unit position
- Line-of-sight required
- Radio range limits apply
- Transmitter destruction = no notifications

**Remove:**

```lua
HoundInstance:removeTransmitter("sectorName")
```

---

## Notification Examples

### Guard Frequency Alert:

```lua
HoundBlue:enableNotifier({
    freq = "243.000",
    modulation = "AM"
})
```

### Both Guard Frequencies:

```lua
HoundBlue:enableNotifier({
    freq = "243.000,121.500",
    modulation = "AM,AM"
})
```

### Strike Frequency Alert:

```lua
HoundBlue:enableNotifier({
    freq = "265.000",  -- Strike package frequency
    modulation = "AM"
})
```

### With All Alerts Enabled:

```lua
HoundBlue:enableBDA()
HoundBlue:setAlertOnLaunch(true)
HoundBlue:enableNotifier({
    freq = "243.000",
    modulation = "AM"
})
```

### Multi-Sector:

```lua
HoundBlue:addSector("North")
HoundBlue:addSector("South")

-- North notifier on 243.000
HoundBlue:enableNotifier("North", {freq = "243.000", modulation = "AM"})

-- South notifier on 265.000
HoundBlue:enableNotifier("South", {freq = "265.000", modulation = "AM"})
```

### With Transmitter:

```lua
HoundBlue:setTransmitter("default", "GCI_Bunker")
HoundBlue:enableNotifier({freq = "243.000", modulation = "AM"})
```

### Custom Voice:

```lua
HoundBlue:enableNotifier({
    freq = "243.000",
    modulation = "AM",
    gender = "female",
    culture = "en-US",
    speed = 0
})
```

---

## Frequency Planning

### Recommended Frequencies:

**Guard Frequencies (Common):**

- 243.000 AM (Military guard)
- 121.500 AM (Civil guard)

**Package/Flight Frequencies:**

- Monitor on strike package common
- Monitor on CAP frequency
- Monitor on tanker frequency

**Separate Alert Frequency:**

- Dedicated frequency for alerts
- Everyone monitors in addition to primary

### Why Guard Frequencies?

**Pros:**

- Everyone monitors anyway
- Standard practice
- Immediate awareness

**Cons:**

- Can be cluttered (multiplayer)
- Not always appropriate (immersion)

### Alternative Approaches:

**Dedicated Alert Frequency:**

```lua
HoundBlue:enableNotifier({freq = "260.000", modulation = "AM"})
-- Brief: "Monitor 260.000 for threat alerts"
```

**Package-Specific:**

```lua
-- Strike package on 265.000
HoundBlue:enableNotifier({freq = "265.000", modulation = "AM"})
```

**Multiple Frequencies:**

```lua
-- Guard + package + CAP
HoundBlue:enableNotifier({
    freq = "243.000,265.000,270.000",
    modulation = "AM,AM,AM"
})
```

---

## Notifier vs Controller vs ATIS

| Feature         | Notifier    | Controller       | ATIS            |
| --------------- | ----------- | ---------------- | --------------- |
| **Type**        | Alerts      | Detailed reports | Summary         |
| **Trigger**     | Events      | On-demand        | Timed loop      |
| **Length**      | Brief       | Long             | Medium          |
| **Interaction** | None        | F10 menu         | None            |
| **Frequency**   | Often guard | Intel frequency  | Intel frequency |
| **Purpose**     | Awareness   | Targeting        | Monitoring      |

### Using Together:

**Typical setup:**

```lua
-- Notifier: Guard frequency, alerts
HoundBlue:enableNotifier({freq = "243.000", modulation = "AM"})

-- ATIS: Intel frequency, continuous
HoundBlue:enableAtis({freq = "253.000", modulation = "AM"})

-- Controller: Intel frequency, detailed
HoundBlue:enableController({freq = "251.000", modulation = "AM"})
```

**Player experience:**

1. Monitor guard (243) - Hear new threat alert from Notifier
2. Switch to ATIS (253) - Get general threat picture
3. Use Controller (251) - Request specific targeting data

---

## Operational Use

### When to Use Notifier:

**✅ Good scenarios:**

- Multiple flights need awareness
- Guard frequency monitoring enforced
- Dynamic threat environment
- Strike packages
- Large multiplayer missions

**❌ Less useful:**

- Single player
- Small missions
- Static threat environment
- Controller/ATIS sufficient

### Alert Fatigue:

**High activity missions:**

- Many new radars = frequent alerts
- Consider disabling new radar alerts
- Keep only BDA/launch alerts

```lua
-- Only BDA and launches (no new radar alerts)
-- Requires custom event handler to filter
-- (Advanced, see event-handlers.md)
```

### Training Value:

**Notifier teaches:**

- Guard monitoring discipline
- Threat awareness
- Communication protocols
- Situational awareness

---

## Troubleshooting

### No Notifications:

**Check 1:** Notifier enabled?

```lua
HoundInstance:enableNotifier({freq = "243.000", modulation = "AM"})
```

**Check 2:** Events occurring?

- New radars being detected?
- BDA/launches enabled if expecting those?

**Check 3:** TTS working?

- HoundTTS/STTS installed?
- SRS connected?

**Check 4:** Transmitter alive?

- If using transmitter, verify unit exists

### Too Many Notifications:

**Solution 1:** Per-sector notifiers

```lua
-- Instead of global, use specific sectors
HoundInstance:enableNotifier("CriticalSector", {freq = "243.000", modulation = "AM"})
```

**Solution 2:** Disable some alerts

```lua
-- Disable BDA if too many destroyed radars
HoundInstance:disableBDA()
```

**Solution 3:** Use different frequency

```lua
-- Off guard, on dedicated frequency
HoundInstance:enableNotifier({freq = "260.000", modulation = "AM"})
```

### Can't Hear Notifications:

**Check frequency:**

- Correct frequency tuned?
- SRS on correct radio?

**Check range (if transmitter):**

- Within radio range?
- Line-of-sight?

---

## Tips and Best Practices

### Keep It Simple:

Notifier should be **brief and clear**:

- ✅ "New threat detected, SA-6, Bullseye 180/45"
- ❌ Long, detailed reports (use Controller)

### Frequency Discipline:

**Guard frequency:**

- Keep clear for emergencies
- Notifier alerts are appropriate
- Don't clutter with other comms

### Briefing:

**Mission briefing should include:**

- Notifier frequency
- What alerts to expect
- How to get detailed info (Controller)

### Testing:

**Test notifier before mission:**

```lua
-- Trigger test alert via event handler
-- Or ensure initial detection happens early
```

---

## Next Steps

- **[Controller](controller.md)** - Detailed intelligence
- **[ATIS](atis.md)** - Continuous monitoring
- **[TTS Configuration](tts-configuration.md)** - Voice setup
- **[Sectors](sectors.md)** - Multiple notifiers for regions
- **[Event Handlers](event-handlers.md)** - Custom alert logic
