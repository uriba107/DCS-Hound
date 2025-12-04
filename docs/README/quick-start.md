# Quick Start Guide

Get Hound ELINT running in your mission in 5 minutes.

---

## 🎮 Try the Demo Missions First! (Recommended)

**The fastest way to understand Hound is to fly a pre-built mission.**

Hound includes ready-to-fly demo missions with everything configured:

### Available Demos

| Demo              | Map      | Features                                                                  | Best For                        |
| ----------------- | -------- | ------------------------------------------------------------------------- | ------------------------------- |
| **Caucasus Demo** | Caucasus | Basic development mission                                                 | Testing new radars/mods         |
| **Syria**         | Syria    | Dynamic mission, many aircraft options, runs on public demo server        | Learning and playing with Hound |
| **Syria GCI**     | Syria    | Stress testing, many radars, complex setup, auto-spawns strike formations | Advanced setups and reference   |

### Using Demo Missions

1. **Download Hound** (includes `/demo_mission/` folder)
2. **Open a `.miz` file** in DCS
3. **Fly and observe**:
   - Check F10 map for markers
   - Tune controller frequency (see mission briefing)
   - Use F10 radio menu to query radars
4. **Open in Mission Editor** to see how it's configured

**Location:** `HoundElint/demo_mission/`

📖 **After flying a demo**, come back here to build your own mission.

---

## Building Your Own Mission

### Prerequisites

- DCS World Mission Editor
- `HoundElint.lua` file
- Optional: STTS or gRPC for voice communications

---

## Step 1: Add Script to Mission

### In Mission Editor:

1. Open your mission in the Mission Editor
2. Go to **Triggers** panel
3. Create a new trigger:
   - **TYPE:** ONCE
   - **CONDITION:** TIME MORE 1
4. Add **DO SCRIPT FILE** action
5. Select `HoundElint.lua`

### If Using Text-To-Speech (Optional):

If you want voice communications, add STTS **before** HoundElint:

1. First action: **DO SCRIPT FILE** → `DCS-SimpleTextToSpeech.lua`
2. Second action: **DO SCRIPT FILE** → `HoundElint.lua`

![Script Load Order](/images/hound_setup.jpg)

📖 **More details:** [Installation Guide](installation.md)

---

## Step 2: Add ELINT Platforms to Mission

Place units in your mission that will act as ELINT collectors:

### Example Setup:

- **Unit 1:** C-130 named "ELINT North" - Patrol route at 25,000 ft
- **Unit 2:** C-130 named "ELINT South" - Patrol route at 25,000 ft
- **Unit 3:** Comms Tower M (static) named "ELINT Tower" - On high ground

**Important:**

- Note the exact **unit names** (not group names)
- Use names without special characters
- At least 2 platforms recommended for triangulation

📖 **See all available platforms:** [Platforms Guide](platforms.md)

---

## Step 3: Configure Hound (Minimal)

Add another trigger with your Hound configuration:

1. Create new trigger:
   - **TYPE:** ONCE
   - **CONDITION:** TIME MORE 2
2. Add **DO SCRIPT** action (not file)
3. Paste this code:

```lua
do
  -- Create Hound instance for Blue coalition
  HoundBlue = HoundElint:create(coalition.side.BLUE)

  -- Add your ELINT platforms (use exact unit names from your mission)
  HoundBlue:addPlatform("ELINT North")
  HoundBlue:addPlatform("ELINT South")
  HoundBlue:addPlatform("ELINT Tower")

  -- Activate the system
  HoundBlue:systemOn()
end
```

### That's It!

With this minimal setup, Hound will:

- ✅ Detect enemy radars automatically
- ✅ Calculate positions via triangulation
- ✅ Display F10 map markers with uncertainty ellipses
- ✅ Update every 2 minutes

---

## Step 4: Fly and Test

1. **Start Mission** in DCS
2. **Wait 30-60 seconds** for initial detection
3. **Open F10 Map** to see radar markers
4. **Monitor updates** as position accuracy improves

### What You'll See:

- **Radar markers** with type information (e.g., "SA-6 Straight Flush")
- **Uncertainty ellipses** showing position accuracy
- **Site markers** grouping related radars together
- Markers update every 2 minutes by default

---

## Adding Voice Communications (Optional)

If you installed STTS and desanitized the scripting engine, add voice:

```lua
do
  HoundBlue = HoundElint:create(coalition.side.BLUE)
  HoundBlue:addPlatform("ELINT North")
  HoundBlue:addPlatform("ELINT South")

  -- Enable interactive SAM Controller on 251.000 AM
  HoundBlue:enableController({
    freq = "251.000",
    modulation = "AM"
  })

  -- Enable ATIS broadcast on 253.000 AM (optional)
  -- HoundBlue:enableAtis({
  --   freq = "253.000",
  --   modulation = "AM"
  -- })

  HoundBlue:systemOn()
end
```

### Using the Controller:

1. Tune radio to **251.000 AM**
2. Open **F10 Radio Menu** → **ELINT** → **HOUND**
3. Select options to request information about specific radars

📖 **More on communications:** [Controller Guide](controller.md) | [ATIS Guide](atis.md)

---

## Next Steps

### Basic Improvements:

- **[Add more platforms](platforms.md)** - Improve coverage and accuracy
- **[Configure markers](map-markers.md)** - Customize visual display
- **[Pre-brief sites](basic-configuration.md#pre-briefed-contacts)** - Add known SAM locations

### Advanced Features:

- **[Create sectors](sectors.md)** - Divide map into regions with separate controllers
- **[Add event handlers](event-handlers.md)** - Script custom responses to detections
- **[Export data](exports.md)** - Save intelligence to files

---

## Troubleshooting

### Not Detecting Radars?

- Ensure enemy radars are **turned on** (AI groups must have waypoint actions)
- Platforms need **line of sight** to radars
- Higher altitude = better detection range
- Wait 30-60 seconds for initial processing

### No Map Markers?

- Check that markers aren't disabled: `HoundBlue:enableMarkers()`
- Verify Hound is activated: `HoundBlue:systemOn()`
- Wait for marker update cycle (default: 2 minutes)

### Voice Not Working?

- STTS installed and loaded before HoundElint?
- DCS scripting engine desanitized? See [Installation](installation.md#desanitizing-scripting-engine)
- SRS running and connected?
- Correct frequency tuned?

📖 **Full troubleshooting guide:** [Troubleshooting](troubleshooting.md)

---

## Complete Examples

### Mission with Everything:

```lua
do
  -- Create instance
  HoundBlue = HoundElint:create(coalition.side.BLUE)

  -- Add platforms
  HoundBlue:addPlatform("ELINT_C130_1")
  HoundBlue:addPlatform("ELINT_C130_2")
  HoundBlue:addPlatform("Ground_Station")

  -- Configure markers
  HoundBlue:setMarkerType(HOUND.MARKER.POLYGON)
  HoundBlue:enableMarkers()

  -- Enable communications
  HoundBlue:enableController({
    freq = "251.000,35.000",  -- Multiple frequencies
    modulation = "AM,FM",
    gender = "male"
  })

  HoundBlue:enableAtis({
    freq = "253.000",
    modulation = "AM"
  })

  -- Enable alerts
  HoundBlue:enableBDA()  -- Battle damage assessment
  HoundBlue:setAlertOnLaunch(true)  -- Launch warnings

  -- Activate
  HoundBlue:systemOn()
end
```

### Red Coalition:

```lua
do
  HoundRed = HoundElint:create(coalition.side.RED)
  HoundRed:addPlatform("Red_ELINT_1")
  HoundRed:addPlatform("Red_ELINT_2")
  HoundRed:enableController({freq = "251.000", modulation = "AM"})
  HoundRed:systemOn()
end
```

---

## Video Tutorial

Watch the basic setup video:

[![Hound Setup Tutorial](https://i.ytimg.com/vi/gmJmFR7UCfo/hqdefault.jpg)](https://www.youtube.com/watch?v=gmJmFR7UCfo)

---

## Demo Mission Details

### Caucasus Demo - Development Mission

**File:** `demo_mission/Caucasus_demo/HoundElint_demo.miz`

**Purpose:** Basic development mission for testing

- Allows testing new radars and mods
- Ensures everything works as expected
- Simple setup for validation

### Syria - Dynamic Play Mission

**File:** `demo_mission/Syria_HARM/Hound_Demo_syria.miz`

**Purpose:** Dynamic mission with lots of player options

- Many aircraft to choose from
- Great for learning and experimenting with Hound
- **Runs on public demo server most of the time**
- Perfect for trying out Hound features

### Syria GCI - Stress Test Mission

**File:** `demo_mission/Syria_POC/Hound_Demo_SyADFGCI.miz`

**Purpose:** Stress testing and advanced reference

Based on [Pikey's Syrian Air Defence Network 2012](https://forum.dcs.world/topic/243078-syrian-air-defence-network-2012-full-bonus-content/), modified to include Hound

- **A LOT of radars** (~900 SAM units) for performance testing
- **Skynet IADS integration** - Shows Hound working alongside Skynet
- **MOOSE framework integration** - Demonstrates compatibility
- Very wide and complicated setup
- **Automatic strike formations spawn for every detected radar**
- Use as reference for huge setups and multi-system integration

**These missions are your best learning resource!** Fly them to see Hound in action.

---

## What's Next?

- **Try demos first:** See `/demo_mission/` folder
- **Learn more:** [How Hound Works](how-it-works.md)
- **Configure advanced:** [Basic Configuration](basic-configuration.md)
- **Add sectors:** [Sectors and Zones](sectors.md)
- **Optimize:** [Performance Tuning](performance.md)
