# Text-To-Speech Configuration

Guide to configuring voice communications. **TTS is optional** - Hound works without voice (map markers + text only).

---

## TTS Providers

| Provider | Setup    | Voices                           | Best For            |
| -------- | -------- | -------------------------------- | ------------------- |
| **STTS** | Easy     | Windows TTS, Google Cloud (opt.) | Most users          |
| **gRPC** | Advanced | Cloud (AWS/Azure/Google), Local  | High-quality voices |

Both require desanitizing DCS scripting engine (see [installation.md](installation.md#desanitizing-scripting-engine)).

---

## TTS Provider Priority

Hound automatically detects and uses available TTS:

**Default order:**

1. STTS (if present)
2. gRPC (if present)
3. None (no voice)

### Override Default Order:

```lua
-- Set before creating Hound instance
HOUND.TTS_ENGINE = {'STTS', 'GRPC'}  -- Default

-- Prefer gRPC over STTS
HOUND.TTS_ENGINE = {'GRPC', 'STTS'}

-- STTS only
HOUND.TTS_ENGINE = {'STTS'}

-- gRPC only
HOUND.TTS_ENGINE = {'GRPC'}

-- Disable TTS
HOUND.TTS_ENGINE = {}
```

---

## STTS Configuration

**Installation:** https://github.com/ciribob/DCS-SimpleTextToSpeech → Load `DCS-SimpleTextToSpeech.lua` BEFORE `HoundElint.lua`

**Key distinctions:**

- `speed` uses **-10 to +10** range (not percentage)
- `volume` is **string** `"1.0"` (not number)
- Uses `voice` parameter (not `name`)
- Supports `googleTTS` option

```lua
-- Basic
HoundBlue:enableController({freq = "251.000", modulation = "AM"})

-- Full STTS options
local tts_config = {
    freq = "251.000",              -- String or number
    modulation = "AM",              -- "AM" or "FM", comma-separated for multiple
    volume = "1.0",                 -- "0.0" to "1.0" (STRING)
    speed = 0,                      -- -10 (very slow) to +10 (very fast)
    gender = "male",                -- "male" or "female"
    culture = "en-US",              -- Voice culture/language
    voice = "David",                -- Specific voice name (optional, overrides gender)
    googleTTS = false               -- Use Google TTS (requires setup)
}
```

### Multiple Frequencies:

```lua
local tts_config = {
    freq = "251.000,35.000,121.500",  -- Comma-separated
    modulation = "AM,FM,AM"            -- Matching order
}
```

### Available Cultures (Windows TTS):

Common installed voices:

- `en-US` - English (United States)
- `en-GB` - English (United Kingdom)
- `en-AU` - English (Australia)
- `de-DE` - German (Germany)
- `fr-FR` - French (France)
- `es-ES` - Spanish (Spain)
- `it-IT` - Italian (Italy)
- `ru-RU` - Russian (Russia)

**Check your system:**

- Control Panel → Speech → Text-to-Speech
- Lists installed voices and cultures

### Gender and Voice:

**Gender:**

```lua
gender = "male"   -- Default male voice for culture
gender = "female" -- Default female voice for culture
```

**Specific Voice:**

```lua
voice = "David"   -- Microsoft David (US English male)
voice = "Zira"    -- Microsoft Zira (US English female)
voice = "Hazel"   -- Microsoft Hazel (UK English female)
```

**Note:** `voice` overrides `gender`. Use one or the other.

### Speech Speed:

```lua
speed = -10  -- Very slow
speed = -5   -- Slow
speed = 0    -- Normal (default)
speed = 5    -- Fast
speed = 10   -- Very fast
```

**Recommendations:**

- **Controller:** 0 or -2 (clear, understandable)
- **ATIS:** 1 or 2 (slightly faster, less boring)
- **Notifier:** 0 (clear alerts)

### Volume:

```lua
volume = "0.5"  -- 50% volume
volume = "1.0"  -- 100% volume (default)
```

**Note:** String value, not number!

### Google TTS (STTS):

**Requires:**

- Google Cloud account
- STTS configured for Google TTS
- API key setup

```lua
local tts_config = {
    freq = "251.000",
    modulation = "AM",
    googleTTS = true,
    voice = "en-US-Wavenet-D",  -- Google voice name
    gender = "male"
}
```

📖 **Google TTS setup:** See STTS documentation

---

## gRPC Configuration

**Installation:** https://github.com/DCS-gRPC/rust-server → Configure cloud providers if needed

**Key distinctions:**

- `speed` uses **50-250 percentage** (not -10 to +10) - or converts STTS-style values
- `volume` is **string** `"1.0"` (same as STTS)
- Uses `name` parameter (not `voice`) for full voice specification
- Supports `provider` block for cloud TTS (AWS/Azure/Google)

```lua
-- Basic
HoundBlue:enableController({freq = "251.000", modulation = "AM"})

-- Full gRPC options
local tts_config = {
    freq = "251.000",
    modulation = "AM",
    volume = "1.0",                          -- "0.0" to "1.0" (STRING)
    speed = 100,                             -- 50 (slow) to 250 (fast), percentage
    gender = "male",                         -- "male" or "female"
    culture = "en-US",                       -- Voice culture
    name = "Microsoft David Desktop",        -- Full voice name (overrides gender/culture)
    provider = {                             -- Provider settings (optional)
        aws = {voice = "Matthew", region = "us-east-1"},
        azure = {voice = "en-US-GuyNeural", region = "westus"},
        gcloud = {voice = "en-US-Neural2-D"},
        windows = {}
    }
}
```

**Speed examples:** `50` (slow), `100` (normal), `150` (fast), `200` (very fast)

📖 **Cloud setup:** See DCS-gRPC documentation for provider configuration

---

## Configuration Examples

```lua
-- STTS: Custom voice
HoundBlue:enableController({
    freq = "251.000,35.000",  -- Multiple frequencies
    modulation = "AM,FM",
    gender = "female",
    culture = "en-GB",
    speed = -2                -- STTS: -10 to +10
})

-- gRPC: Cloud provider
HoundBlue:enableController({
    freq = "251.000",
    modulation = "AM",
    speed = 125,              -- gRPC: 50-250 percentage
    provider = {aws = {voice = "Matthew"}}
})

-- Different voices per system
HoundBlue:enableController({freq = "251.000", modulation = "AM", gender = "male", speed = 0})
HoundBlue:enableAtis({freq = "253.000", modulation = "AM", gender = "female", speed = 2})
HoundBlue:enableNotifier({freq = "243.000", modulation = "AM", gender = "male", speed = 0})
```

---

## Troubleshooting

**No voice:** Check TTS installed/loaded before Hound, desanitized, SRS running, correct frequency.  
**Speed issues:** STTS uses `-5` to `5`, gRPC uses `75` to `150`.  
**Wrong voice:** STTS uses `voice = "David"`, gRPC uses `name = "Microsoft David Desktop"`.  
**Volume:** `volume = "1.0"` (string!), also check SRS/DCS/system volume.

See [troubleshooting.md](troubleshooting.md) for detailed diagnostics.

---

## Recommendations

**Speed:** Controller 0 to -2, ATIS 0 to +2, Notifier -2 to 0  
**Voices:** Controller (clear/professional), ATIS (slightly faster), Notifier (clear/slow)  
**Culture:** Match mission setting (`en-US`, `en-GB`, `ru-RU`, etc.)

---

## Quick Reference

| Provider | freq        | modulation | speed          | voice param          |
| -------- | ----------- | ---------- | -------------- | -------------------- |
| STTS     | `"251.000"` | `"AM"`     | `-10` to `+10` | `voice = "David"`    |
| gRPC     | `"251.000"` | `"AM"`     | `50` to `250`  | `name = "Full Name"` |

Both use `volume = "1.0"` (string), `gender = "male"/"female"`, `culture = "en-US"`
