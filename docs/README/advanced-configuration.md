# Advanced Configuration

Complex setups for experienced mission builders.

---

## Multi-Sector Mission

```lua
do
  -- Create Hound instance
  HoundBlue = HoundElint:create(coalition.side.BLUE)

  -- Add ELINT platforms
  HoundBlue:addPlatform("ELINT_C130_North")
  HoundBlue:addPlatform("ELINT_C130_South")
  HoundBlue:addPlatform("ELINT_C17_High")
  HoundBlue:addPlatform("Tower_Hermon")
  HoundBlue:addPlatform("Tower_Meron")

  -- Create sectors
  HoundBlue:addSector("North Syria")
  HoundBlue:addSector("Lebanon")
  HoundBlue:addSector("South Syria")

  -- Configure zones
  HoundBlue:setZone("North Syria", "Zone_NorthSyria")
  HoundBlue:setZone("Lebanon", "Zone_Lebanon")
  HoundBlue:setZone("South Syria", "Zone_SouthSyria")

  -- Set custom callsigns
  HoundBlue:setCallsign("North Syria", "DARKSTAR")
  HoundBlue:setCallsign("Lebanon", "WIZARD")
  HoundBlue:setCallsign("South Syria", "MAGIC")

  -- Configure transmitters (realistic radio)
  HoundBlue:setTransmitter("North Syria", "Tower_Hermon")
  HoundBlue:setTransmitter("Lebanon", "AWACS_Lebanon")
  HoundBlue:setTransmitter("South Syria", "Tower_Meron")

  -- North Syria: 251.000 / 253.000
  HoundBlue:enableController("North Syria", {
    freq = "251.000,35.000",
    modulation = "AM,FM",
    gender = "male",
    culture = "en-US"
  })
  HoundBlue:enableAtis("North Syria", {
    freq = "253.000",
    modulation = "AM",
    gender = "female",
    speed = 1
  })

  -- Lebanon: 255.000 / 257.000
  HoundBlue:enableController("Lebanon", {
    freq = "255.000",
    modulation = "AM",
    gender = "male"
  })
  HoundBlue:enableAtis("Lebanon", {
    freq = "257.000",
    modulation = "AM",
    gender = "female",
    speed = 1
  })

  -- South Syria: 259.000 / 261.000
  HoundBlue:enableController("South Syria", {
    freq = "259.000",
    modulation = "AM",
    gender = "male"
  })
  HoundBlue:enableAtis("South Syria", {
    freq = "261.000",
    modulation = "AM",
    gender = "female",
    speed = 1
  })

  -- Enable text for all sectors
  HoundBlue:enableText("all")

  -- Global notifier on guard
  HoundBlue:enableNotifier({
    freq = "243.000,121.500",
    modulation = "AM,AM",
    gender = "male"
  })

  -- Configure map markers
  HoundBlue:setMarkerType(HOUND.MARKER.CIRCLE)
  HoundBlue:enableMarkers()
  HoundBlue:enableSiteMarkers()

  -- Enable BDA and launch alerts
  HoundBlue:enableBDA()
  HoundBlue:setAlertOnLaunch(true)

  -- Add pre-briefed contacts
  HoundBlue:preBriefedContact("Known_SAM_1", "ANVIL")
  HoundBlue:preBriefedContact("Known_SAM_2", "HAMMER")

  -- Optional: realistic position errors
  -- HoundBlue:enablePlatformPosErrors()

  -- Activate system
  HoundBlue:systemOn()
end
```

---

## Performance Optimization

```lua
-- Large missions (50+ radars)
HoundBlue:setMarkerType(HOUND.MARKER.POINT)  -- Simple markers
HoundBlue:setTimerInterval("markers", 180)   -- 3 min updates
HoundBlue:setTimerInterval("process", 45)    -- 45s processing
```

📖 Full guide: [Performance Tuning](performance.md)

---

## Dynamic Mission Events

```lua
-- Add/remove platforms dynamically
HoundBlue:addPlatform("Reinforcement_ELINT")
HoundBlue:removePlatform("Lost_Platform")

-- Add sectors mid-mission
HoundBlue:addSector("New Area")
HoundBlue:setZone("New Area", "Zone_New")
HoundBlue:enableController("New Area", {freq = "259.000", modulation = "AM"})
```

📖 Event handlers: [Event Handlers Guide](event-handlers.md)

---

## Multiple Coalition

```lua
HoundBlue = HoundElint:create(coalition.side.BLUE)
HoundBlue:addPlatform("Blue_ELINT_1")
HoundBlue:enableController({freq = "251.000", modulation = "AM"})
HoundBlue:systemOn()

HoundRed = HoundElint:create(coalition.side.RED)
HoundRed:addPlatform("Red_ELINT_1")
HoundRed:enableController({freq = "251.000", modulation = "AM"})
HoundRed:systemOn()
```

Filter events by coalition in handlers: `if event.coalition == coalition.side.BLUE then`

---

## Global Settings

```lua
-- Set BEFORE creating instances
HOUND.setMgrsPresicion(5)                     -- MGRS precision
HOUND.showExtendedInfo(false)                 -- Shorter reports
HOUND.TTS_ENGINE = {'GRPC', 'STTS'}          -- TTS priority
HOUND.FORCE_MANAGE_MARKERS = true             -- Force internal marker IDs
HOUND.Utils.setInitialMarkId(20000)

HoundBlue = HoundElint:create(coalition.side.BLUE)
HoundBlue:useNATOCallsignes(true)             -- NATO callsigns
HoundBlue:enableNATO()                        -- NATO Lowdown format
```

---

## Custom F10 Menu Location

```lua
local IntelMenu = missionCommands.addSubMenuForCoalition(coalition.side.BLUE, "Intelligence")

HoundBlue = HoundElint:create(coalition.side.BLUE)
HoundBlue:setRadioMenuParent(IntelMenu)  -- BEFORE enableController
HoundBlue:enableController()
```

---

## Periodic CSV Export

```lua
function periodicExport()
  HoundBlue:dumpIntelBrief("intel_" .. os.date("%Y%m%d_%H%M%S") .. ".csv")
  timer.scheduleFunction(periodicExport, nil, timer.getTime() + 300)
end

timer.scheduleFunction(periodicExport, nil, timer.getTime() + 60)
```
