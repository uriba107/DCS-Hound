# Installation Guide

Complete installation instructions for Hound ELINT.

---

## Requirements

### Base Requirements (Always Needed)

- **DCS World** - Any modern version
- **HoundElint.lua** - The main script file

### Optional Requirements (For Voice)

Choose **ONE** of these Text-To-Speech solutions:

- **[DCS-SimpleTextToSpeech (STTS)](https://github.com/ciribob/DCS-SimpleTextToSpeech)** - Recommended, easiest
- **[DCS-gRPC](https://github.com/DCS-gRPC/rust-server)** - Advanced, requires Rust server

---

## Installation Steps

### 1. Download Hound

1. Download the latest release from the repository
2. Extract `HoundElint.lua` to a convenient location
3. Recommended: `Saved Games\DCS\Scripts\` or `Saved Games\DCS.openbeta\Scripts\`

### 2. Install Text-To-Speech (Optional)

If you want voice communications, install ONE TTS solution:

#### Option A: STTS (Recommended)

1. Download from: https://github.com/ciribob/DCS-SimpleTextToSpeech
2. Follow STTS installation instructions
3. Requires desanitizing DCS scripting engine (see below)

#### Option B: gRPC

1. Download from: https://github.com/DCS-gRPC/rust-server
2. Follow gRPC installation and setup
3. More complex but offers cloud TTS providers

### 3. Desanitize Scripting Engine (If Using TTS)

**⚠️ WARNING:** This modifies DCS core files and allows additional Lua functions. Only needed for TTS features.

#### What to Modify:

Edit: `DCS World\Scripts\MissionScripting.lua`

Find these lines:

```lua
sanitizeModule('os')
sanitizeModule('io')
sanitizeModule('lfs')
```

Comment them out:

```lua
-- sanitizeModule('os')
-- sanitizeModule('io')
-- sanitizeModule('lfs')
```

#### Which Modules to Enable:

| Feature          | Requires          |
| ---------------- | ----------------- |
| STTS             | `os`, `io`, `lfs` |
| gRPC             | `os`, `io`, `lfs` |
| CSV Export       | `io`, `lfs`       |
| Map markers only | None              |

**Note:** This change is reverted with every DCS update and must be reapplied.

---

## Adding to Mission

### Mission Editor Setup

1. Open your mission in the **Mission Editor**
2. Go to **Triggers** section
3. Create initialization trigger

#### Trigger Configuration:

**Trigger 1: Load Scripts**

- **TYPE:** ONCE
- **CONDITION:** TIME MORE 1
- **ACTIONS:**
  1. DO SCRIPT FILE: `DCS-SimpleTextToSpeech.lua` (if using STTS)
  2. DO SCRIPT FILE: `HoundElint.lua`

**Trigger 2: Configure Hound**

- **TYPE:** ONCE
- **CONDITION:** TIME MORE 2
- **ACTIONS:**
  1. DO SCRIPT: (paste your configuration)

### Script Load Order (Important!)

```
1. STTS/gRPC (if using)
2. HoundElint.lua
3. Your configuration code
```

**❌ Wrong Order:**

```
HoundElint.lua
DCS-SimpleTextToSpeech.lua  ← Too late!
Configuration
```

**✅ Correct Order:**

```
DCS-SimpleTextToSpeech.lua
HoundElint.lua
Configuration  ← Hound is ready to use
```

---

## Verification

### Test Basic Installation:

Add this simple test configuration:

```lua
do
  env.info("Hound: Starting test")

  -- This should not error if Hound loaded correctly
  if HoundElint then
    env.info("Hound: HoundElint found!")

    -- Try to create instance
    local test = HoundElint:create(coalition.side.BLUE)
    if test then
      env.info("Hound: Instance created successfully!")
    end
  else
    env.info("Hound: ERROR - HoundElint not found!")
  end
end
```

Check `Saved Games\DCS\Logs\dcs.log` for these messages after mission loads.

### Test Voice (If Installed):

```lua
do
  -- Test STTS
  if STTS then
    env.info("Hound: STTS found!")
  end

  -- Test if desanitized
  if io then
    env.info("Hound: IO module available")
  end

  if lfs then
    env.info("Hound: LFS module available")
  end
end
```

---

## Common Installation Issues

### "HoundElint is nil" Error

**Cause:** Script not loaded or loaded in wrong order

**Fix:**

1. Verify `HoundElint.lua` file path is correct
2. Check script loads on TIME MORE 1
3. Ensure configuration runs on TIME MORE 2 (after Hound loads)

### "attempt to call global 'STTS'" Error

**Cause:** STTS not loaded before Hound

**Fix:**

1. Load `DCS-SimpleTextToSpeech.lua` first
2. Then load `HoundElint.lua`
3. Check both load in same trigger

### Voice Not Working

**Cause:** Scripting engine not desanitized

**Fix:**

1. Edit `DCS World\Scripts\MissionScripting.lua`
2. Comment out sanitize lines (see above)
3. Restart DCS World completely
4. Verify with test code above

### "cannot open file" Error (CSV Export)

**Cause:** `io` or `lfs` modules not enabled

**Fix:**

1. Desanitize scripting engine
2. Enable `io` and `lfs` modules
3. Restart DCS

---

## Installation Paths

### DCS Installation Locations:

**Steam:**

```
C:\Program Files (x86)\Steam\steamapps\common\DCSWorld\
```

**Standalone:**

```
C:\Program Files\Eagle Dynamics\DCS World\
```

**OpenBeta:**

```
C:\Program Files\Eagle Dynamics\DCS World OpenBeta\
```

### Saved Games Locations:

**Default:**

```
C:\Users\<YourName>\Saved Games\DCS\
C:\Users\<YourName>\Saved Games\DCS.openbeta\
```

### Key Files:

| File                 | Location                                    |
| -------------------- | ------------------------------------------- |
| MissionScripting.lua | `<DCS Install>\Scripts\`                    |
| Mission files (.miz) | `<Saved Games>\Missions\`                   |
| Log files            | `<Saved Games>\Logs\`                       |
| Scripts (custom)     | `<Saved Games>\Scripts\` (create if needed) |

---

## Network/Server Considerations

### Dedicated Server Setup:

1. Install Hound on server machine
2. Desanitize server's scripting engine
3. Include all scripts in .miz file using **DO SCRIPT FILE**
4. Server needs TTS software if using voice (STTS/gRPC)

### Client Requirements:

- **Nothing!** Clients need no installation
- SRS required for voice communications (standard for any SRS mission)
- Map markers show for all clients automatically

### Performance Notes:

- Hound runs server-side only
- No client-side performance impact
- Marker updates sent to all clients every 2 minutes
- For large missions, see [Performance Tuning](performance.md)

---

## Upgrading from Previous Versions

### From 0.3.x to 0.4.x

**Breaking Changes:**

- Marker ENUMs changed: `HOUND.MARKER.NONE` now draws nothing
- Site markers toggle separately
- Contact class refactored to Contact.Emitter

**Migration:**

```lua
-- Old (0.3.x)
HoundInstance:setMarkerType(HOUND.MARKER.NONE)  -- Drew points

-- New (0.4.x)
HoundInstance:setMarkerType(HOUND.MARKER.POINT)  -- Draws points
HoundInstance:setMarkerType(HOUND.MARKER.NONE)   -- Draws nothing
```

### From 0.2.x to 0.3.x

- `HoundEventHandler` → `HOUND.EventHandler`
- Most classes wrapped into `HOUND` namespace

### From 0.1.x to 0.2.x

- `enableController()` no longer accepts boolean for text
- Use `enableText()` instead
- All ATIS functions capitalized: `ATIS` → `Atis`

📖 **Full details:** [Breaking Changes](breaking-changes.md)

---

## Compatibility

### Works With:

| System              | Compatible | Notes                                             |
| ------------------- | ---------- | ------------------------------------------------- |
| MOOSE               | ✅ Yes     | Fully compatible, will use MOOSE utils if present |
| Skynet IADS         | ✅ Yes     | No conflicts                                      |
| High-Digit SAMs     | ✅ Yes     | Tracks all radars                                 |
| MIST (old versions) | ✅ Yes     | No longer required as of 0.4.1                    |
| Custom scripts      | ✅ Usually | See marker ID management below                    |

### Marker ID Management:

Hound manages marker IDs carefully to avoid conflicts:

1. **With MOOSE:** Uses `UTILS.GetMarkID()`
2. **With MIST 4.5+:** Uses `mist.marker.getNextId()`
3. **Standalone:** Uses internal counter starting at 10,000

**Force Internal Counter:**

```lua
HOUND.FORCE_MANAGE_MARKERS = true  -- Set before creating instance
```

**Change Starting ID:**

```lua
HOUND.Utils.setInitialMarkId(20000)  -- Use different range
```

---

## Next Steps

✅ Installation complete!

- **Quick setup:** [Quick Start Guide](quick-start.md)
- **Configuration:** [Basic Configuration](basic-configuration.md)
- **Platform selection:** [Available Platforms](platforms.md)
- **Troubleshooting:** [Troubleshooting Guide](troubleshooting.md)
