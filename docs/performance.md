# Performance Tuning

Optimizing Hound for large missions and servers.

---

## Understanding Performance Impact

### What Affects Performance:

**High Impact:**

- Number of map markers
- Marker update frequency
- Marker complexity (polygon points)

**Medium Impact:**

- Number of active enemy radars
- Number of ELINT platforms
- Menu update frequency

**Low Impact:**

- Position calculations
- Detection cycles
- Event handlers (if lightweight)

---

## Quick Optimization

For immediate performance improvement:

```lua
HoundBlue = HoundElint:create(coalition.side.BLUE)
HoundBlue:addPlatform("ELINT_1")
HoundBlue:addPlatform("ELINT_2")

-- Use simple markers
HoundBlue:setMarkerType(HOUND.MARKER.CIRCLE)  -- or POINT

-- Increase marker update interval
HoundBlue:setTimerInterval("markers", 180)  -- 3 minutes instead of 2

HoundBlue:enableController({freq = "251.000", modulation = "AM"})
HoundBlue:systemOn()
```

---

## Marker Optimization

### Marker Complexity:

| Type        | Markers          | Polygon Points | Performance     |
| ----------- | ---------------- | -------------- | --------------- |
| `NONE`      | 0                | -              | ★★★★★ Best      |
| `SITE_ONLY` | 1/site           | -              | ★★★★★ Excellent |
| `POINT`     | 1/radar + 1/site | -              | ★★★★★ Excellent |
| `CIRCLE`    | 2/radar + 1/site | circle         | ★★★★☆ Good      |
| `DIAMOND`   | 2/radar + 1/site | 4-point        | ★★★☆☆ Fair      |
| `OCTAGON`   | 2/radar + 1/site | 8-point        | ★★☆☆☆ Moderate  |
| `POLYGON`   | 2/radar + 1/site | 16-point       | ★☆☆☆☆ Poor      |

Site markers included by default. Polygon types are expensive for DCS to update and render.

```lua
-- High performance
HoundBlue:setMarkerType(HOUND.MARKER.SITE_ONLY)

-- Default (balanced)
HoundBlue:setMarkerType(HOUND.MARKER.CIRCLE)

-- Small missions only
HoundBlue:setMarkerType(HOUND.MARKER.POLYGON)
```

### Site Markers:

Site markers add minimal overhead:

```lua
-- Keep site markers, disable uncertainty
HoundBlue:setMarkerType(HOUND.MARKER.NONE)
HoundBlue:enableSiteMarkers()
```

**Good compromise:**

- Shows general threat locations
- Minimal marker count
- Use Controller for details

---

## Timer Interval Optimization

### Default Intervals:

- **scan:** 5s - Platform/radar checks
- **process:** 30s - Position calculations
- **menus:** 60s - F10 menu updates
- **markers:** 120s - Map marker updates

### Optimization Strategy:

**Increase marker update:**

```lua
HoundBlue:setTimerInterval("markers", 180)  -- 3 minutes
-- or
HoundBlue:setTimerInterval("markers", 240)  -- 4 minutes
```

**Increase processing interval:**

```lua
HoundBlue:setTimerInterval("process", 45)  -- 45 seconds
-- or
HoundBlue:setTimerInterval("process", 60)  -- 1 minute
```

**Increase menu update:**

```lua
HoundBlue:setTimerInterval("menus", 90)  -- 90 seconds
```

**Increase scan interval (careful!):**

```lua
HoundBlue:setTimerInterval("scan", 10)  -- 10 seconds
-- Default 5s is usually fine
```

### Complete Performance Config:

```lua
HoundBlue = HoundElint:create(coalition.side.BLUE)
HoundBlue:addPlatform("ELINT_1")

-- Optimize all intervals
HoundBlue:setTimerInterval("scan", 10)
HoundBlue:setTimerInterval("process", 60)
HoundBlue:setTimerInterval("menus", 90)
HoundBlue:setTimerInterval("markers", 240)

-- Simple markers
HoundBlue:setMarkerType(HOUND.MARKER.POINT)

HoundBlue:systemOn()
```

---

## Voice-Only Configuration

Maximum performance: No markers at all.

```lua
HoundBlue = HoundElint:create(coalition.side.BLUE)
HoundBlue:addPlatform("ELINT_1")
HoundBlue:addPlatform("ELINT_2")

-- No markers
HoundBlue:disableMarkers()
HoundBlue:disableSiteMarkers()

-- Voice communications only
HoundBlue:enableController({freq = "251.000", modulation = "AM"})
HoundBlue:enableAtis({freq = "253.000", modulation = "AM"})

HoundBlue:systemOn()
```

**Benefits:**

- Zero marker overhead
- Maximum performance
- Forces players to use voice (immersion)

**Drawbacks:**

- No visual reference
- Harder for new players
- Must copy coordinates manually

---

## Sector Optimization

### Zone Size Matters:

Smaller zones = fewer radars per sector = better performance.

**Instead of:**

```lua
-- One huge sector covering everything
HoundBlue:enableController({freq = "251.000", modulation = "AM"})
```

**Consider:**

```lua
-- Multiple smaller sectors
HoundBlue:addSector("North")
HoundBlue:addSector("South")
HoundBlue:setZone("North", "Zone_North")
HoundBlue:setZone("South", "Zone_South")

HoundBlue:enableController("North", {freq = "251.000", modulation = "AM"})
HoundBlue:enableController("South", {freq = "255.000", modulation = "AM"})
```

**Benefits:**

- Smaller menus (faster)
- Fewer markers per area
- Better organization

---

## Platform Count

### More Platforms = More Processing:

Each platform checks every radar every scan cycle.

**Formula:**

```
Checks per cycle = Platforms × Radars
```

**Examples:**

- 3 platforms × 20 radars = 60 checks every 5s (fine)
- 5 platforms × 50 radars = 250 checks every 5s (OK)
- 10 platforms × 100 radars = 1000 checks every 5s (heavy)

### Recommendations:

**Typical missions:**

- 2-5 platforms sufficient

**Large missions:**

- 3-6 platforms maximum
- Quality over quantity
- Use high-precision platforms

**Huge missions:**

- Consider limiting to 3-4 platforms
- Use static towers for baselines
- Increase scan interval if needed

---

## Server Considerations

### Multiplayer Impact:

**Markers sent to all clients:**

- Every marker update = network traffic
- All clients must process markers
- Affects all players, not just server

**Recommendations:**

1. **Use simple markers** (POINT or CIRCLE)
2. **Increase update interval** (3-4 minutes)
3. **Consider voice-only** for large player counts

### Dedicated Server:

**Server resources:**

- Hound runs server-side only
- No client performance impact (except markers)
- Server CPU handles all processing

**Optimize server config:**

```lua
-- Server-optimized setup
HoundBlue:setMarkerType(HOUND.MARKER.POINT)
HoundBlue:setTimerInterval("markers", 240)
HoundBlue:setTimerInterval("process", 60)
```

---

## Measuring Performance

### On-Screen Debug:

```lua
HoundBlue:onScreenDebug(true)
```

Shows Hound cycle time and contact count.

### DCS Performance:

Monitor:

- FPS (Shift+Ctrl+Pause)
- Task Manager (CPU usage)
- dcs.log (warnings/errors)

### Identifying Hound Impact:

**Test without Hound:**

1. Note baseline FPS
2. Load mission with Hound
3. Compare FPS

**Test marker impact:**

1. Run with markers
2. Note FPS
3. Disable markers: `HoundBlue:disableMarkers()`
4. Compare FPS

---

## Extreme Optimization

For missions with 100+ radars:

```lua
HoundBlue = HoundElint:create(coalition.side.BLUE)

-- Minimal platforms
HoundBlue:addPlatform("ELINT_1")
HoundBlue:addPlatform("ELINT_2")

-- No markers at all
HoundBlue:disableMarkers()
HoundBlue:disableSiteMarkers()

-- Maximum intervals
HoundBlue:setTimerInterval("scan", 15)
HoundBlue:setTimerInterval("process", 60)
HoundBlue:setTimerInterval("menus", 120)
HoundBlue:setTimerInterval("markers", 300)  -- Doesn't matter, disabled

-- Voice only
HoundBlue:enableController({freq = "251.000", modulation = "AM"})

HoundBlue:systemOn()
```

---

## Performance Checklist

**For all large missions:**

- [ ] Use CIRCLE or POINT markers
- [ ] Increase marker interval to 3+ minutes
- [ ] Limit platforms to 3-5
- [ ] Consider disabling site markers
- [ ] Test with expected radar count

**For huge missions (50+ radars):**

- [ ] Use POINT or NONE markers
- [ ] Marker interval 4+ minutes
- [ ] Maximum 3 platforms
- [ ] Consider voice-only
- [ ] Increase all timer intervals

**For multiplayer servers:**

- [ ] Simple markers (POINT)
- [ ] Long marker intervals (4+ minutes)
- [ ] Test with expected player count
- [ ] Monitor server performance
- [ ] Consider voice-only

---

## Comparison

### Default vs Optimized:

**Default (30 radars):**

```lua
HoundBlue:setMarkerType(HOUND.MARKER.CIRCLE)    -- 3 markers each
HoundBlue:setTimerInterval("markers", 120)       -- Every 2 min
-- 90 markers total, updated every 2 min
```

**Optimized (30 radars):**

```lua
HoundBlue:setMarkerType(HOUND.MARKER.POINT)     -- 1 marker each
HoundBlue:setTimerInterval("markers", 240)       -- Every 4 min
-- 30 markers total, updated every 4 min
-- 70% fewer markers, 50% less frequent
```

**Voice-Only (30 radars):**

```lua
HoundBlue:disableMarkers()
-- 0 markers, 100% reduction
```

---

## Real-World Examples

### Example 1: 20 Radars (Standard)

```lua
HoundBlue = HoundElint:create(coalition.side.BLUE)
HoundBlue:addPlatform("ELINT_1")
HoundBlue:addPlatform("ELINT_2")
HoundBlue:addPlatform("ELINT_3")

HoundBlue:setMarkerType(HOUND.MARKER.CIRCLE)
HoundBlue:setTimerInterval("markers", 120)

HoundBlue:enableController({freq = "251.000", modulation = "AM"})
HoundBlue:systemOn()

-- Works well, no optimization needed
```

### Example 2: 50 Radars (Optimized)

```lua
HoundBlue = HoundElint:create(coalition.side.BLUE)
HoundBlue:addPlatform("ELINT_1")
HoundBlue:addPlatform("ELINT_2")

HoundBlue:setMarkerType(HOUND.MARKER.POINT)
HoundBlue:setTimerInterval("markers", 180)
HoundBlue:setTimerInterval("process", 45)

HoundBlue:enableController({freq = "251.000", modulation = "AM"})
HoundBlue:systemOn()

-- Good balance
```

### Example 3: 100 Radars (Extreme)

```lua
HoundBlue = HoundElint:create(coalition.side.BLUE)
HoundBlue:addPlatform("ELINT_1")
HoundBlue:addPlatform("ELINT_2")

HoundBlue:disableMarkers()
HoundBlue:setTimerInterval("process", 60)
HoundBlue:setTimerInterval("menus", 120)

HoundBlue:enableController({freq = "251.000", modulation = "AM"})
HoundBlue:systemOn()

-- Voice-only, maximum performance
```

---

## Summary

### Performance Priority:

1. **Marker complexity** - Biggest impact
2. **Marker update frequency** - Significant impact
3. **Timer intervals** - Moderate impact
4. **Platform count** - Low impact (until extreme)

### Quick Wins:

- Change POLYGON → CIRCLE (saves 80% markers)
- Change CIRCLE → POINT (saves 66% markers)
- Increase marker interval 2 → 3 min (saves 33% updates)

### When to Optimize:

- **< 20 radars:** No optimization needed
- **20-40 radars:** Light optimization (CIRCLE, 3 min)
- **40-70 radars:** Moderate optimization (POINT, 4 min)
- **70+ radars:** Heavy optimization (NONE or voice-only)

---

## Next Steps

- **[Map Markers](map-markers.md)** - Marker options
- **[Troubleshooting](troubleshooting.md)** - Performance issues
- **[Advanced Configuration](advanced-configuration.md)** - Complex setups
