# Troubleshooting Guide

---

## Detection Issues

**No contacts detected:**

- Radars active? (AI waypoint activation, static SAMs set "On")
- Platforms added correctly? (`addPlatform("EXACT_UNIT_NAME")` - use unit name, not group, case-sensitive)
- System activated? (`systemOn()`)
- Line of sight? (higher altitude = better, terrain blocks signals)
- Waited 30-60 seconds for initial detection, 1-2 minutes for positions

**Test:**

```lua
HoundBlue = HoundElint:create(coalition.side.BLUE)
HoundBlue:addPlatform("Test_C130")
HoundBlue:onScreenDebug(true)  -- Check dcs.log for "Hound:" messages
HoundBlue:systemOn()
```

---

## Map Marker Issues

**No markers:**

- Enabled? (`enableMarkers()`)
- Type not NONE? (`setMarkerType(HOUND.MARKER.CIRCLE)`)
- Radars detected? (see Detection Issues above)
- Waited for update cycle? (default: 2 minutes)
- F10 map open?

**Wrong positions (initially NORMAL):**

- First triangulation often inaccurate, corrects after 1-2 minutes
- If persists: check platform positions, verify ≥2 platforms detecting

**Not updating:**

- Radars still transmitting? System running? (`systemOn()`)
- Update interval: `setTimerInterval("markers", 120)` -- default: 120 seconds

**Performance issues:**

```lua
HoundBlue:setMarkerType(HOUND.MARKER.POINT)  -- or CIRCLE, SITE_ONLY
HoundBlue:setTimerInterval("markers", 180)   -- Increase interval
HoundBlue:disableMarkers()                   -- or disable
```

📖 [performance.md](performance.md)

---

## Voice / TTS Issues

**No voice:**

- TTS installed? (STTS or gRPC required, loaded BEFORE HoundElint.lua)
- Desanitized? (`MissionScripting.lua` uncomment `sanitizeModule('os')`, `'io'`, `'lfs'`, restart DCS)
- SRS connected, correct frequency/modulation tuned?
- Transmitter alive (if used)?

**Test STTS:**

```lua
if STTS then trigger.action.outText("STTS available", 10)
else trigger.action.outText("STTS NOT available", 10) end
```

**Speech issues:**

```lua
-- Adjust speed: -10 to +10 (STTS) or 50-250 (gRPC)
HoundBlue:enableController({freq = "251.000", modulation = "AM", speed = -2})

-- Change voice/accent
HoundBlue:enableController({culture = "en-US", gender = "male"})  -- Check Control Panel → Speech Recognition

-- Volume (also check SRS/DCS/Windows volume)
HoundBlue:enableController({volume = "1.0"})  -- Maximum (string!)
```

---

## F10 Menu Issues

**No menu:**

- Controller enabled? (`enableController()`)
- System running? (`systemOn()`)
- Correct coalition? (menu only visible to matching coalition)
- Try reslotting aircraft

**Not updating:**

- Check interval: `setTimerInterval("menus", 60)` -- default: 60 seconds
- Menu updates when contacts change and system running

**Wrong location:**

```lua
local CustomMenu = missionCommands.addSubMenuForCoalition(coalition.side.BLUE, "Intelligence")
HoundBlue:setRadioMenuParent(CustomMenu)  -- Before enableController()
```

---

## Script Errors

**"HoundElint is nil":** Script not loaded or wrong trigger order (HoundElint.lua on TIME MORE 1, config on TIME MORE 2)

**"attempt to call method":** Config running before Hound loaded (separate triggers, Hound first)

**"STTS is nil":** Load DCS-SimpleTextToSpeech.lua BEFORE HoundElint.lua

**Lua errors:** Check `Saved Games\DCS\Logs\dcs.log` for error details. Common: missing comma, curly quotes, missing `end`, typos.

---

## Export Issues

**CSV not working:** Desanitize `io` and `lfs` in `MissionScripting.lua`, restart DCS

**CSV empty:** Wait 2-3 minutes for contacts/positions to calculate

**CSV not found:** Check `Saved Games\DCS\` or `Saved Games\DCS.openbeta\` (permissions, disk space, antivirus)

---

## Performance Issues

**Stuttering/Low FPS:**

```lua
HoundBlue:setMarkerType(HOUND.MARKER.CIRCLE)  -- or POINT, or disableMarkers()
HoundBlue:setTimerInterval("markers", 180)    -- Increase intervals
HoundBlue:setTimerInterval("process", 45)
HoundBlue:disableSiteMarkers()
```

📖 [performance.md](performance.md)

**Multiplayer lag:** Same solutions, consider impact on all clients

---

## Sector Issues

**Radar not in expected sector:**

- Zone set correctly? (`getZone("SectorName")` to verify boundaries)
- Radar inside zone? (check coordinates, remember ~10-20nm buffer)
- Sector enabled? (`enableController("SectorName", {...})`)

**Sector menu missing:**

- Sector created? (`addSector("SectorName")`)
- Controller enabled for sector?
- System running? (`systemOn()`)

---

## Contact Detection Quirks

**Pre-briefed contact not showing:** Valid radar unit (see [platforms.md](platforms.md)), unit exists/activated, system running

**Positions "jumping" (NORMAL initially):**

- Poor platform geometry (in line), platform movement, or first few minutes
- Stabilizes after 2-3 minutes, add more platforms for stability

**EWRs not reported:** By design. Enable: `reportEWR("sectorName", true)`

---

## Multiplayer Issues

**Markers:** Server-side, all clients see them (try reopening F10 map)

**Voice:** Check per client: SRS connected, correct frequency, volume, coalition

**Text:** Player must "Check In" via F10 menu, text enabled, correct coalition

---

## Common Mistakes

1. **Group name instead of unit name:** Use `addPlatform("ELINT Unit #001")` not `"ELINT_Group"`
2. **Wrong script load order:** Load DCS-SimpleTextToSpeech.lua BEFORE HoundElint.lua
3. **Forgetting `systemOn()`:** Always call after configuration
4. **Expecting instant results:** Initial detection 30-60s, accurate positions 1-2min, first markers up to 2min

---

## Debug & Test

**Enable debug:**

```lua
HoundBlue:onScreenDebug(true)  -- Check dcs.log for status/errors
```

**Minimal test mission:**

```lua
HoundBlue = HoundElint:create(coalition.side.BLUE)
HoundBlue:addPlatform("Test_C130")
HoundBlue:onScreenDebug(true)
HoundBlue:systemOn()
```

Place C-130 high, SA-6 nearby, both active.

**Still having issues?** Check `dcs.log`, verify prerequisites, test minimal config, check GitHub issues, ask in forums.
