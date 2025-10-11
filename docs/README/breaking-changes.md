# Breaking Changes

Important changes between Hound versions that may break existing missions.

---

## Version 0.4.x (Current)

### From 0.3.x to 0.4.x

#### Marker ENUMs Changed

**Breaking Change:**
`HOUND.MARKER.NONE` now draws nothing.

**Old Behavior (0.3.x):**

```lua
HoundInstance:setMarkerType(HOUND.MARKER.NONE)  -- Drew point markers
```

**New Behavior (0.4.x):**

```lua
HoundInstance:setMarkerType(HOUND.MARKER.NONE)  -- Draws nothing
HoundInstance:setMarkerType(HOUND.MARKER.POINT)  -- Draws point markers
```

**Migration:**

```lua
-- If you want point markers, change:
HoundInstance:setMarkerType(HOUND.MARKER.NONE)
-- To:
HoundInstance:setMarkerType(HOUND.MARKER.POINT)
```

#### Site Markers Separate

**Breaking Change:**
Site markers now toggle separately from uncertainty markers.

**Old Behavior (0.3.x):**

- All markers controlled together

**New Behavior (0.4.x):**

```lua
HoundInstance:enableSiteMarkers()   -- Site markers
HoundInstance:disableSiteMarkers()

HoundInstance:enableMarkers()        -- Uncertainty markers (independent)
```

**Migration:**
If you disabled markers and want to keep site markers:

```lua
HoundInstance:setMarkerType(HOUND.MARKER.NONE)  -- No uncertainty
HoundInstance:enableSiteMarkers()                -- Keep site markers
```

If you want NO markers at all:

```lua
HoundInstance:disableMarkers()
HoundInstance:disableSiteMarkers()
```

#### Contact Class Refactored

**Breaking Change:**
`HOUND.Contact` split into multiple classes.

**Old (0.3.x):**

```lua
local contact = HOUND.Contact  -- Direct reference
```

**New (0.4.x):**

```lua
local emitter = HOUND.Contact.Emitter  -- Radar contact
local site = HOUND.Contact.Site        -- SAM site
```

**Impact:**
Only affects custom scripts that directly reference `HOUND.Contact`.

**Migration:**
Replace `HOUND.Contact` with `HOUND.Contact.Emitter` in custom event handlers.

#### Export Structure Changed

**Breaking Change:**
Export functions now return site-grouped data.

**Old Export (0.3.x):**

```lua
local data = HoundInstance:getContacts()
-- Returns flat list of radars
```

**New Export (0.4.x):**

```lua
local data = HoundInstance:getSites()
-- Returns radars grouped by sites
```

**Migration:**

- Use `getSites()` for new code (recommended)
- `getContacts()` still available for legacy support

📖 See: [Exports Guide](exports.md)

---

## Version 0.3.x

### From 0.2.x to 0.3.x

#### Class Namespace Change

**Breaking Change:**
Classes wrapped into `HOUND` namespace.

**Old (0.2.x):**

```lua
HoundEventHandler = {}
-- Direct global classes
```

**New (0.3.x):**

```lua
HOUND.EventHandler = {}
-- All within HOUND namespace
```

**Migration:**
Update event handlers:

```lua
-- Old
HoundEventHandler = {}
function HoundEventHandler:onHoundEvent(event)
    -- ...
end
HOUND.addEventHandler(HoundEventHandler)

-- New (any name works)
MyHandler = {}
function MyHandler:onHoundEvent(event)
    -- ...
end
HOUND.addEventHandler(MyHandler)
```

---

## Version 0.2.x

### From 0.1.x to 0.2.x

#### enableController() Text Parameter Removed

**Breaking Change:**
`enableController()` no longer accepts boolean for text.

**Old (0.1.x):**

```lua
HoundInstance:enableController(true)  -- Enable with text
```

**New (0.2.x):**

```lua
HoundInstance:enableController()
HoundInstance:enableText("default")  -- Separate call
```

**Migration:**

```lua
-- Old
HoundInstance:enableController(true)

-- New
HoundInstance:enableController()
HoundInstance:enableText("default")
```

#### ATIS Function Capitalization

**Breaking Change:**
All ATIS functions changed capitalization.

**Old (0.1.x):**

```lua
HoundInstance:enableATIS()
HoundInstance:disableATIS()
HoundInstance:configureATIS()
```

**New (0.2.x):**

```lua
HoundInstance:enableAtis()   -- Lowercase 'tis'
HoundInstance:disableAtis()
HoundInstance:configureAtis()
```

**Migration:**
Find and replace: `ATIS` → `Atis` in your mission scripts.

#### TTS Config "name" Parameter

**Breaking Change:**
TTS config `name` parameter no longer used.

**Old (0.1.x):**

```lua
local config = {
    freq = "251.000",
    name = "Controller"  -- No longer used
}
```

**New (0.2.x):**

```lua
local config = {
    freq = "251.000",
    voice = "David"  -- Use 'voice' instead
}
```

**Migration:**

- Remove `name` parameter (silent failure, won't break)
- Use `voice` or `gender`/`culture` instead

#### setTransmitter() Now Per-Sector

**Breaking Change:**
`setTransmitter()` is now a sector-level function.

**Old (0.1.x):**

```lua
HoundInstance.controller:setTransmitter("UnitName")
HoundInstance.atis:setTransmitter("UnitName")
```

**New (0.2.x):**

```lua
HoundInstance:setTransmitter("sectorName", "UnitName")
```

**Migration:**

```lua
-- Old
HoundInstance.controller:setTransmitter("AWACS")

-- New
HoundInstance:setTransmitter("default", "AWACS")
```

---

## Version 0.1.x

Original release, no breaking changes.

---

## Migration Checklist

### Upgrading to 0.4.x:

- [ ] Replace `HOUND.MARKER.NONE` with `HOUND.MARKER.POINT` if you want point markers
- [ ] Check custom scripts for `HOUND.Contact` references
- [ ] Update export calls if using `getContacts()` internally
- [ ] Decide if you want site markers enabled or disabled
- [ ] Test marker behavior in mission

### Upgrading to 0.3.x:

- [ ] Rename `HoundEventHandler` to custom name in `HOUND` namespace
- [ ] Verify event handlers still work
- [ ] Test mission functionality

### Upgrading to 0.2.x:

- [ ] Replace `enableController(true)` with separate `enableText()` calls
- [ ] Replace all `ATIS` with `Atis` in function names
- [ ] Update transmitter calls to use sector-based syntax
- [ ] Remove `name` from TTS config (or replace with `voice`)
- [ ] Test all communication systems

---

## Version Compatibility

| Version   | Compatible With | Notes                           |
| --------- | --------------- | ------------------------------- |
| **0.4.x** | 0.4.x           | Current                         |
| **0.3.x** | 0.3.x           | Minor breaking changes from 0.2 |
| **0.2.x** | 0.2.x           | Major breaking changes from 0.1 |
| **0.1.x** | 0.1.x           | Original                        |

**Not backward compatible across major versions.**

---

## Future Breaking Changes

Check GitHub for:

- Planned breaking changes
- Deprecation warnings
- Migration guides for upcoming versions

---

## Best Practices

### When Upgrading:

1. **Read breaking changes** for your version
2. **Backup your mission** before upgrading
3. **Test in separate mission** first
4. **Update incrementally** (0.2 → 0.3 → 0.4, not 0.2 → 0.4)
5. **Check dcs.log** for errors
6. **Test all features** before deployment

### Version Pinning:

**For production missions:**

- Pin specific Hound version
- Don't auto-update
- Test upgrades thoroughly
- Keep backup of working version

**For development:**

- Stay current with latest
- Test breaking changes early
- Adapt as development progresses

---

## Need Help?

### Migration Issues:

1. Check this document for your version jump
2. Review [Troubleshooting Guide](troubleshooting.md)
3. Check `dcs.log` for specific errors
4. Test with minimal configuration
5. Ask in community forums with version info

### Finding Version:

Check Hound script header:

```lua
-- HoundElint vX.Y.Z
```

Or GitHub releases page.

---

## Next Steps

- **[Known Issues](known-issues.md)** - Current limitations
- **[Troubleshooting](troubleshooting.md)** - Problem solving
- **[Installation](installation.md)** - Clean installation guide
