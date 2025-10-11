# Available ELINT Platforms

Complete list of units capable of ELINT operations in Hound.

---

## Platform Selection Guide

### Quick Recommendations:

**Best Overall:**

- 🥇 **TV Tower** (static) - Exceptional accuracy
- 🥇 **C-130** - Excellent airborne platform
- 🥇 **C-17** - Stand-in for RC-135, very accurate

**Best By Role:**

- **Long-range picket:** C-17, Tu-95, IL-76
- **Medium range:** C-130, An-30M, An-26B
- **Ground stations:** Comms Tower M, TV Tower, Command Center
- **Mobile ground:** SPK-11, Patriot CR
- **Low observable:** Smaller aircraft (worse accuracy trade-off)

---

## Understanding Platform Specs

### Accuracy Columns:

**C Band / H Band Resolution** - Angular accuracy in degrees against specific band.

- Lower = Better
- Most SAM radars operate in C/H bands
- Example: `0.65° / 0.07°` is excellent

**Minimum Band** - Lowest frequency band the platform can detect with some accuracy

- **A** = Can detect everything (best)
- **C** = Struggles with low-frequency radars
- **D** = Only effective against high-frequency radars

**Note:** Hound rejects datapoints with >10° error automatically.

---

## Airborne Platforms

### Large Aircraft (Best)

| Platform    | C Band / H Band Accuracy | Min. Band | Notes                                 |
| ----------- | ------------------------ | --------- | ------------------------------------- |
| **C-130**   | 0.65° / 0.07°            | A         | Excellent all-around, common          |
| **C-17**    | 0.57° / 0.06°            | A         | Best large aircraft (RC-135 stand-in) |
| **IL-76MD** | 0.60° / 0.06°            | A         | Russian equivalent to C-130           |
| **Tu-95**   | 0.46° / 0.05°            | A         | Excellent accuracy, large size        |
| **Tu-142**  | 0.46° / 0.05°            | A         | Maritime patrol version of Tu-95      |
| **An-30M**  | 0.92° / 0.10°            | A         | Good accuracy, smaller platform       |
| **An-26B**  | 0.98° / 0.10°            | A         | Similar to An-30M                     |

### Medium Aircraft

| Platform        | C Band / H Band Accuracy | Min. Band | Notes                         |
| --------------- | ------------------------ | --------- | ----------------------------- |
| **C-47**        | 1.91° / 0.20°            | A         | Vintage but capable           |
| **S-3B Viking** | 1.59° / 0.17°            | A         | Carrier-based ASW, good ELINT |

### AEW / AWACS

| Platform         | C Band / H Band Accuracy | Min. Band | Notes                                 |
| ---------------- | ------------------------ | --------- | ------------------------------------- |
| **E-2D Hawkeye** | 6.54° / 0.70°            | C         | Minimum Band C limits low-freq        |
| **E-3A Sentry**  | 5.09° / 0.55°            | C         | Better than E-2D but still C-band min |
| **A-50**         | 5.09° / 0.55°            | C         | Russian AWACS                         |

### Tactical Aircraft (Fighter/Attack)

| Platform           | C Band / H Band Accuracy | Min. Band | Notes                     |
| ------------------ | ------------------------ | --------- | ------------------------- |
| **F-16C Block 50** | 15.79° / 1.69°           | D         | HTS pod, limited accuracy |
| **JF-17**          | 7.05° / 0.76°            | C         | KG-600 SPJ pod            |
| **Mirage F1**      | 6.19° / 0.66°            | C         | Cyril pod                 |
| **AJ-37 Viggen**   | 5.09° / 0.55°            | C         | U22 pod                   |
| **Su-25T**         | 6.54° / 0.70°            | C         | Fantasmagoria pod         |
| **Su-25TM**        | 6.54° / 0.70°            | C         | Fantasmagoria pod         |
| **Su-24M**         | 6.54° / 0.70°            | C         | Fantasmagoria             |
| **Su-24MR**        | 5.09° / 0.55°            | C         | Tangazh system            |

**Note:** Tactical aircraft have smaller antennas = lower accuracy. Best used as gap-fillers or when precision platforms unavailable.

### Special Aircraft

| Platform | C Band / H Band Accuracy | Min. Band | Notes                         |
| -------- | ------------------------ | --------- | ----------------------------- |
| **H-6J** | 6.54° / 0.70°            | C         | Chinese bomber, Fantasmagoria |

---

## Helicopters

**Generally lower accuracy than fixed-wing due to smaller size.**

| Platform           | C Band / H Band Accuracy | Min. Band | Notes                             |
| ------------------ | ------------------------ | --------- | --------------------------------- |
| **Mi-26**          | 1.15° / 0.12°            | A         | Largest helicopter, best accuracy |
| **CH-47D Chinook** | 1.91° / 0.20°            | A         | Good for transport + ELINT        |
| **CH-53E**         | 2.29° / 0.25°            | A         | Large cargo helo                  |
| **UH-60A**         | 2.86° / 0.31°            | B         | Medium transport                  |
| **SH-60B**         | 2.86° / 0.31°            | B         | Naval variant                     |
| **Mi-8MT**         | 2.86° / 0.31°            | B         | Russian medium transport          |
| **UH-1H Huey**     | 5.73° / 0.61°            | C         | Small, lower accuracy             |
| **Ka-27**          | 5.73° / 0.61°            | C         | Naval helicopter                  |

**Use Cases:**

- Mountain-top deployment
- Quick-reaction ELINT
- Transport + intelligence dual role
- Low-altitude operations

---

## Ground Units

| Platform           | C Band / H Band Accuracy | Min. Band | Notes                |
| ------------------ | ------------------------ | --------- | -------------------- |
| **SPK-11**         | 1.53° / 0.16°            | A         | Mobile ELINT vehicle |
| **SAM Patriot CR** | 1.53° / 0.16°            | A         | Control room, mobile |

**Advantages:**

- Can be positioned on high terrain
- No fuel/endurance limits
- Can accompany ground forces

**Disadvantages:**

- Fixed or slow-moving
- Limited by terrain line of sight
- Vulnerable to ground attack

---

## Static Objects (Best Ground-Based)

| Platform           | C Band / H Band Accuracy | Min. Band | Notes                     |
| ------------------ | ------------------------ | --------- | ------------------------- |
| **TV Tower**       | 0.10° / 0.01°            | A         | **Best overall accuracy** |
| **Comms Tower M**  | 0.21° / 0.02°            | A         | Excellent, very tall      |
| **Command Center** | 0.37° / 0.04°            | A         | Building, high accuracy   |

**Advantages:**

- Exceptional accuracy (largest "antennas")
- Unlimited endurance
- Can be on mountains/hills
- Cheap in terms of mission resources

**Disadvantages:**

- Completely fixed
- Single point of failure
- Can be destroyed
- Terrain dependent

**Best Practice:**

- Place on highest terrain available
- Provides excellent baseline for airborne platforms
- Acts as reference point for triangulation

---

## Community Mods

Supported third-party aircraft:

| Platform                | C Band / H Band Accuracy | Min. Band | Notes                          |
| ----------------------- | ------------------------ | --------- | ------------------------------ |
| **RC-135W** (SSS)       | 0.57° / 0.06°            | A         | Real ELINT aircraft, excellent |
| **EC-130H** (SSS)       | 0.65° / 0.07°            | A         | Compass Call variant           |
| **P-3C Orion** (MAM)    | 0.92° / 0.10°            | A         | Maritime patrol                |
| **P-8A Poseidon** (CLP) | 0.65° / 0.07°            | A         | Modern P-3 replacement         |
| **TU-214R** (CLP)       | 0.57° / 0.06°            | A         | Russian recon aircraft         |
| **Shavit** (IDF)        | 0.76° / 0.08°            | A         | Israeli ELINT                  |
| **Anubis C-130J**       | 0.65° / 0.07°            | A         | Modern C-130                   |
| **EF-18G** (CJS)        | 1.64° / 0.18°            | A         | Growler equivalent, excellent  |
| **EA-6B Prowler** (VSN) | 2.54° / 0.27°            | B         | Electronic warfare             |
| **UH-60L**              | 2.86° / 0.31°            | B         | Modernized Blackhawk           |

**Note:** Requires respective mods installed. Hound will work without mods but won't detect these units.

---

## Platform Selection Strategy

### For Maximum Accuracy:

1. **Primary:** 2-3 high-altitude large aircraft (C-130, C-17, IL-76)
2. **Baseline:** 1-2 static towers on high ground
3. **Backup:** Additional platforms for redundancy

### For Wide Coverage:

1. **Pickets:** Aircraft at different cardinal directions
2. **Altitude separation:** Some high (30k ft), some medium (20k ft)
3. **Static anchors:** Ground stations at corners of AO

### For Survivability:

1. **Standoff distance:** Keep platforms outside threat range
2. **Redundancy:** More platforms = can afford losses
3. **Mix types:** Air + ground = harder to eliminate all

### Budget/Limited Resources:

1. **Minimum:** 2 x C-130 in racetracks
2. **Better:** 2 x C-130 + 1 x Comms Tower
3. **Optimal:** 3 x C-130 + 2 x Static objects

---

## Mission Planning Examples

### Large Theater (Syria/Caucasus):

```
- C-130 "ELINT North" - Racetrack north at 28,000 ft
- C-130 "ELINT South" - Racetrack south at 28,000 ft
- C-17 "ELINT East" - Racetrack east at 32,000 ft
- TV Tower "ELINT Hermon" - Mt. Hermon (high terrain)
- Comms Tower "ELINT Meron" - Mt. Meron (high terrain)
```

### Small Theater (Persian Gulf):

```
- C-130 "ELINT Overwatch" - Figure-8 pattern at 25,000 ft
- SPK-11 "ELINT Ground" - High ground west side
- Comms Tower "ELINT Tower" - Fixed position east
```

### Low-Observable Mission:

```
- Viggen "ELINT 1" - Dash in, collect, dash out
- JF-17 "ELINT 2" - Different axis
- SPK-11 "ELINT Ground" - Maintain baseline when aircraft egress
```

### Ground Force Support:

```
- UH-60A "ELINT Helo 1" - Deployed to mountain-top
- UH-60A "ELINT Helo 2" - Deployed to different mountain
- SPK-11 "ELINT Mobile" - Travels with ground force
```

---

## Platform Positioning Tips

### Altitude Considerations:

**Fixed-Wing:**

- **Minimum:** 15,000 ft (survival vs detection trade-off)
- **Optimal:** 25,000-30,000 ft (range + safety)
- **Maximum:** 35,000+ ft if capable (best range)

**Helicopters:**

- **On ground:** Mountain-tops, hilltops
- **Hovering:** High terrain positions (fuel permitting)
- **Limited altitude ceiling:** Don't expect high-altitude performance

**Ground/Static:**

- **Elevation matters:** Every foot helps
- **Check line-of-sight:** Use DCS mission editor terrain view
- **Clear horizons:** Avoid valleys and depressions

### Spacing:

**Minimum Separation:** 20-30 nm for nearby targets
**Optimal Separation:** 50-100+ nm for long-range coverage
**Avoid:** Straight lines (poor geometry)

### Patterns:

**Racetracks:** Constant coverage, predictable
**Orbits:** Focused on area, changing geometry
**Figure-8:** Good aspect variation
**Static Grid:** Multiple fixed positions

---

## Adding Platforms in Code

### Automatic Platform Detection

**Default Behavior (Enabled):**

Hound automatically detects and adds units with ELINT payloads when they spawn:

```lua
-- No code needed! Hound automatically adds:
-- - F-16C with HTS pod
-- - Su-25T/TM with Fantasmagoria
-- - JF-17 with KG-600
-- - Viggen with U22
-- - Any other unit spawning with ELINT equipment
```

**How It Works:**

1. Unit spawns with ELINT payload (HTS, Fantasmagoria, etc.)
2. DCS triggers `S_EVENT_WEAPON_ADD` event
3. Hound validates unit type + weapon against internal database
4. If valid, unit is automatically added as ELINT platform

**DCS Limitation:** Only works for units **spawning** with pods. Adding pods to already-spawned units will NOT trigger detection.

**Player Aircraft:**

This enables player-based ELINT missions without manual configuration:

```lua
HoundBlue = HoundElint:create(coalition.side.BLUE)
HoundBlue:enableController({freq = "251.000", modulation = "AM"})
HoundBlue:systemOn()

-- Players spawn in F-16C with HTS → Automatically become ELINT platforms
-- Radio menu automatically updates when players spawn/leave
```

**Disable Automatic Detection:**

```lua
-- Set BEFORE creating Hound instance
HOUND.AUTO_ADD_PLATFORM_BY_PAYLOAD = false

HoundBlue = HoundElint:create(coalition.side.BLUE)
-- Now you must manually add all platforms
HoundBlue:addPlatform("ELINT_C130")
```

---

### Manual Platform Addition

### Basic:

```lua
HoundInstance:addPlatform("ELINT_C130")
```

### Multiple:

```lua
HoundInstance:addPlatform("ELINT_C130_1")
HoundInstance:addPlatform("ELINT_C130_2")
HoundInstance:addPlatform("ELINT_Tower")
```

### Dynamic (Add Later):

```lua
-- Add after system is already running
HoundInstance:addPlatform("Reinforcement_ELINT")
```

### Remove:

```lua
HoundInstance:removePlatform("ELINT_C130_1")
```

**Note:** Use exact unit/pilot name, NOT group name!

---

### Radio Menu Behavior

**Automatic Menu Updates:**

Hound automatically refreshes F10 radio menus when:

**Player Events:**

- Player spawns (`S_EVENT_BIRTH`)
- Player leaves aircraft (`S_EVENT_PLAYER_LEAVE_UNIT`)
- Pilot dies (`S_EVENT_PILOT_DEAD`)
- Pilot ejects (`S_EVENT_EJECTION`)

**Contact Events:**

- New SAM site created (`SITE_CREATED`)
- Site type classified (`SITE_CLASSIFIED`)

**BDA Events** (only when BDA enabled):

- Site destroyed (`SITE_REMOVED`)
- Radar destroyed (`RADAR_DESTROYED`)

**Why This Matters:**

- **Player Events:** Menus stay current as players join/leave
- **Contact Events:** New threats immediately appear in menu for reporting
- **BDA Events:** Destroyed contacts removed from menu to avoid clutter
- No stale menu items

**Performance Notes:**

- Player events only trigger for aircraft/helicopters (ground vehicles/ships ignored)
- Contact/BDA events update menu for all players simultaneously
- Menu updates are lightweight and don't impact performance

---

## Platform Limitations

### What Doesn't Work:

❌ Units without proper ELINT equipment (Hound checks unit type)
❌ Destroyed/dead units (removed automatically)
❌ Units with line-of-sight blocked by terrain
❌ Units > ~400nm from radar (even if LOS exists)

### Performance Notes:

Each platform scans every radar every cycle (5 seconds default):

- **10 platforms x 50 radars = 500 checks every 5 seconds**
- Usually not a problem
- For huge missions, see [Performance Tuning](performance.md)

---

## Summary

**Choosing Platforms:**

- **Accuracy matters:** Use best available
- **Geometry matters:** Wide separation, different angles
- **Redundancy matters:** Lose one, keep working
- **Height matters:** Higher = better range

**Best Bang for Buck:**

- 2 x C-130 (airborne)
- 1 x Comms Tower or TV Tower (ground reference)

**Next Steps:**

- **Configure in mission:** [Basic Configuration](basic-configuration.md)
- **Understand detection:** [How Hound Works](how-it-works.md)
- **Optimize setup:** [Advanced Configuration](advanced-configuration.md)
