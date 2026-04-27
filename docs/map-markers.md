# Map Markers

Configure visual feedback on F10 map.

---

## Marker Types

**Radar Markers:** Individual emitter positions with uncertainty ellipses  
**Site Markers:** Grouped radars by SAM system

### Enable/Disable

```lua
HoundInstance:enableMarkers()
HoundInstance:disableMarkers()
```

---

## Uncertainty Ellipse Types

```lua
HoundInstance:setMarkerType(HOUND.MARKER.CIRCLE)
```

| Type        | Markers          | Performance | Description                     |
| ----------- | ---------------- | ----------- | ------------------------------- |
| `NONE`      | 0                | ★★★★★       | No markers                      |
| `SITE_ONLY` | 1/site           | ★★★★★       | Site marker only                |
| `POINT`     | 1/radar + 1/site | ★★★★★       | Position point + site           |
| `CIRCLE`    | 2/radar + 1/site | ★★★★☆       | Point + circle + site (default) |
| `DIAMOND`   | 2/radar + 1/site | ★★★☆☆       | Point + 4-point polygon + site  |
| `OCTAGON`   | 2/radar + 1/site | ★★☆☆☆       | Point + 8-point polygon + site  |
| `POLYGON`   | 2/radar + 1/site | ★☆☆☆☆       | Point + 16-point polygon + site |

Site markers included by default unless `disableSiteMarkers()` called.

```lua
HoundInstance:enableMarkers(HOUND.MARKER.CIRCLE)
```

---

## Marker Appearance

| State  | Opacity | Description            |
| ------ | ------- | ---------------------- |
| Active | 100%    | Currently transmitting |
| Recent | 90%     | Off < 2 minutes        |
| Stale  | 70%     | Off 2-5 minutes        |
| Aged   | 40%     | Off 5-10 minutes       |
| Asleep | 20%     | Off > 10 minutes       |

**Ellipse size:** Smaller = higher confidence, larger = wider search area

---

## Site Markers

Groups related radars into SAM systems. **Enabled by default** for all marker types except `NONE`.

```lua
HoundInstance:enableSiteMarkers()   -- Enable (default)
HoundInstance:disableSiteMarkers()  -- Disable
```

---

## Marker Update Cycle

Default: Markers update every 2 minutes (120s)

```lua
HoundInstance:setTimerInterval("markers", 180)  -- 3 minutes
```

Shorter intervals = more responsive but worse performance

---

## Marker ID Management

Hound auto-detects MOOSE/MIST and uses their marker management. Standalone uses internal counter starting at 10,000.

**Manual override:**

```lua
-- Set BEFORE creating Hound instance
HOUND.FORCE_MANAGE_MARKERS = true
HOUND.Utils.setInitialMarkId(20000)  -- Custom starting ID
```

---

## Performance

**Optimization:**

1. Use `SITE_ONLY` (1/site) or `POINT` (1/radar)
2. Increase update interval: `setTimerInterval("markers", 180)`
3. Disable: `disableMarkers()`

Polygon types (DIAMOND/OCTAGON/POLYGON) are expensive to render - avoid in large missions.

📖 [performance.md](performance.md)

---

## MGRS Precision

```lua
HOUND.setMgrsPresicion(5)  -- 10-digit (default)
HOUND.setMgrsPresicion(4)  -- 8-digit
HOUND.setMgrsPresicion(3)  -- 6-digit
```

---

## Troubleshooting

**Markers not appearing:** Verify `enableMarkers()`, `systemOn()`, marker type not `NONE`, wait up to 2 minutes for first update

**Wrong positions initially:** Normal - first triangulation is inaccurate, corrects within 1-2 minutes

**Marker conflicts:** Set `HOUND.FORCE_MANAGE_MARKERS = true` and `HOUND.Utils.setInitialMarkId(20000)` before creating instance

---

## Examples

```lua
-- High performance
HoundInstance:setMarkerType(HOUND.MARKER.SITE_ONLY)

-- Balanced (default)
HoundInstance:setMarkerType(HOUND.MARKER.CIRCLE)

-- Maximum detail
HoundInstance:setMarkerType(HOUND.MARKER.POLYGON)
```
