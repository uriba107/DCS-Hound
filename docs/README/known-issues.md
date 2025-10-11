# Known Issues

Current known limitations and quirks in Hound.

---

## Detection Behavior

### Initial Position Inaccuracy

**Issue:**
On initial detection, position estimate is often far from actual location.

**Why:**
First triangulation with limited datapoints produces poor solution.

**Expected Behavior:**

- Initial position may be wildly inaccurate
- Corrects within 1-2 minutes as more datapoints collected
- Final accuracy depends on geometry and platforms

**Recommendation:**

- Wait 2-3 minutes before acting on new contact
- Look for "High" or "Very High" accuracy rating
- Don't trust initial position for strikes

---

## Platform Limitations

### Low Resolution Platforms

**Issue:**
Adding low-resolution platforms (fighters, helicopters) can degrade solution.

**Why:**
Hound rejects readings > 10° error, but lower resolution still impacts quality.

**Affected Platforms:**

- F-16 (Min Band D)
- Helicopters (lower accuracy)
- Small aircraft

**Recommendation:**

- Use high-precision platforms when possible (C-130, C-17, static towers)
- Don't rely solely on low-resolution platforms
- Mix high and low precision for best results

**See:** [Platforms Guide](platforms.md) for platform specifications

---

## Sector Limitations

### Sector Overlap

**Issue:**
Overlapping sectors not well tested, may produce unexpected behavior.

**Tested Configuration:**

- Small high-priority sector within larger sector: OK
- Adjacent non-overlapping sectors: OK

**Not Recommended:**

- Multiple overlapping equal-priority sectors
- Complex overlapping geometries
- Arbitrary overlaps

**Recommendation:**

- Keep sectors distinct with clear boundaries
- Small overlap acceptable for edge cases
- Test thoroughly if overlap needed

---

## Performance

### Large Radar Counts

**Issue:**
Missions with 50+ radars can experience performance degradation.

**Cause:**

- Large number of map markers
- Marker update overhead
- DCS marker processing limits

**Symptoms:**

- FPS drops
- Stuttering on marker updates
- Server lag (multiplayer)

**Solutions:**

- Use simpler marker types (POINT, CIRCLE)
- Increase marker update interval
- Disable markers entirely (voice-only)
- Reduce number of platforms

📖 See: [Performance Tuning](performance.md)

---

## Compatibility

### MIST Versions

**Issue:**
Very old MIST versions (< 4.4) not compatible.

**Status:**

- MIST no longer required as of Hound 0.4.1
- If using MIST, use 4.5+ for full compatibility

### Marker ID Conflicts

**Issue:**
Other scripts using markers may conflict with Hound marker IDs.

**Solutions:**

- Hound automatically uses MOOSE/MIST marker management if available
- Force internal counter: `HOUND.FORCE_MANAGE_MARKERS = true`
- Change starting ID: `HOUND.Utils.setInitialMarkId(20000)`

📖 See: [Installation Guide](installation.md#marker-id-management)

---

## Scripting Limitations

### RADAR_DESTROYED Event

**Issue:**
Unit is already dead when event fires.

**Impact:**

- `event.initiator` is contact object, not DCS unit
- `contact.DcsObjectName` is unit NAME (string), not unit object
- Cannot query dead unit

**Recommendation:**

- Use `contact.DcsGroupName` when possible
- Store unit information before destruction if needed
- Event provides contact data, not unit data

---

## TTS Limitations

### Windows TTS Quality

**Issue:**
Default Windows TTS voices may sound robotic.

**Solutions:**

- Use Google TTS (requires setup)
- Use gRPC with cloud providers (AWS, Azure, Google)
- Install additional Windows voices

📖 See: [TTS Configuration](tts-configuration.md)

### SRS Requirements

**Issue:**
Voice communications require external SRS application.

**This is expected:**

- DCS does not provide built-in TTS
- SRS is standard for DCS voice comms
- No workaround available

---

## Map Marker Behavior

### Marker Persistence

**Issue:**
Markers remain on map for short time after radar destroyed (BDA enabled).

**Why:**
Intentional - allows players to see location of destroyed radar.

**Duration:**

- Marker opacity fades
- Eventually removed from map
- Timeout typically 10-15 minutes

**Not an issue if:**

- This is desired behavior for situational awareness

### Marker Update Delay

**Issue:**
Markers don't update immediately, up to 2 minutes delay.

**Why:**
Performance - updating hundreds of markers is expensive.

**Solutions:**

- Reduce update interval: `setTimerInterval("markers", 60)`
- Accept delay as trade-off for performance
- Use voice communications for real-time info

---

## Mission Editor Limitations

### Dynamic Slots Without Template

**Issue:**
Using callsign override wildcard `["*"] = "*"` with dynamic slots (no template) can cause issues.

**Why:**
Aircraft may spawn with wildcard callsign and random group name.

**Recommendation:**

- Use templates for dynamic slots
- Or avoid wildcard override
- Or accept potential confusion

---

## Platform Detection Range

### Beyond ~400nm

**Issue:**
Platforms beyond approximately 400nm from radar may not detect.

**Why:**
DCS API limitations and performance considerations.

**Recommendation:**

- Keep platforms within 400nm of expected radar locations
- Not usually an issue in practice
- Use multiple platforms to extend coverage

---

## CSV Export

### Requires Desanitization

**Issue:**
CSV export fails without desanitizing DCS scripting engine.

**Why:**
Requires `io` and `lfs` Lua modules for file operations.

**Solution:**

- Desanitize `io` and `lfs` in `MissionScripting.lua`
- Restart DCS after changes

📖 See: [Installation Guide](installation.md#desanitizing-scripting-engine)

**Security Note:**
Only desanitize if you need file export features and understand the risks.

---

## Multiplayer Specific

### Marker Synchronization

**Issue:**
All clients receive all marker updates, can cause network overhead.

**Impact:**

- Large player counts with many radars
- Frequent marker updates multiply network traffic

**Solutions:**

- Use simpler markers
- Increase update interval
- Consider voice-only for very large servers

---

## Not Issues

These are sometimes reported but are **expected behavior:**

### Detection Takes Time

**Expected:** 30-60 seconds for initial detection, 1-2 minutes for accurate position.

### Position Changes

**Expected:** Position refines over time as more datapoints collected.

### Radar Not Detected

**Expected if:**

- Radar is off
- No line of sight
- Platform out of range

### No Voice Without TTS

**Expected:** Voice requires STTS/gRPC installation and configuration.

### Markers Update Slowly

**Expected:** Default 2-minute update cycle for performance.

---

## Reporting Issues

If you encounter an issue not listed here:

1. **Check troubleshooting:** [Troubleshooting Guide](troubleshooting.md)
2. **Verify configuration:** Review your setup
3. **Check dcs.log:** Look for error messages
4. **Test minimal setup:** Isolate the issue
5. **Report on GitHub:** With details and dcs.log excerpts

---

## Planned Improvements

Check GitHub repository for:

- Planned features
- Known bug fixes in progress
- Feature requests
- Development roadmap

---

## Next Steps

- **[Troubleshooting](troubleshooting.md)** - Solutions to common problems
- **[Breaking Changes](breaking-changes.md)** - Version upgrade info
- **[Performance Tuning](performance.md)** - Optimization guide
