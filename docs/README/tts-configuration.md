# Text-To-Speech Configuration

Guide to configuring voice communications. **TTS is optional** - Hound works without voice (map markers + text only).

---

## TTS Providers

| Provider     | Setup    | Voices                                                          | Best For                                       |
| ------------ | -------- | --------------------------------------------------------------- | ---------------------------------------------- |
| **HoundTTS** | Easy     | Piper (offline), SAPI (Windows), Google, Azure, AWS, ElevenLabs | **All users (default)**                        |
| **STTS**     | Easy     | Windows TTS, Google Cloud (opt.)                                | Legacy — HoundTTS supersedes it                |
| **gRPC**     | Advanced | Cloud (AWS/Azure/Google), Local                                 | Not recommended due to concurrency limitations |

HoundTTS is a native C++ DLL that connects directly to SRS — no PowerShell, no focus stealing, fully parallel. If HoundTTS is installed, it automatically takes over from STTS transparently.

STTS and gRPC both require desanitizing DCS scripting engine (see [installation.md](installation.md#3-desanitize-scripting-engine-if-using-tts)).

---

## TTS Provider Priority

Hound automatically detects and uses available TTS:

**Default order:**

1. HoundTTS (if present) ← **default**
2. STTS (if present — HoundTTS takes over transparently even if STTS is specified)
3. gRPC (if present)
4. None (no voice)

### Override Default Order:

```lua
-- Set before creating Hound instance
HOUND.TTS_ENGINE = {'HoundTTS', 'STTS'}  -- Default

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

## HoundTTS Configuration ⭐ DEFAULT

**Installation:** See the [HoundTTS README](https://github.com/uriba107/HoundTTS) — install the DLL into your DCS Saved Games folder and add one line to `MissionScripting.lua`.

**Key advantages over STTS:**

- **No PowerShell** — native C++ DLL, no visible windows, no focus stealing
- **Fully parallel** — every TTS request is fire-and-forget, no blocking
- **Multiple providers** — Piper (offline, bundled), SAPI, Google, Azure, AWS Polly, ElevenLabs
- **Credentials stay out of Lua** — API keys are read from an INI file, never exposed in logs

### Provider Selection

HoundTTS supports multiple TTS providers per-call via the `provider` parameter:

| Provider       | Aliases                | Requires API Key | Offline | Notes                                 |
| -------------- | ---------------------- | ---------------- | ------- | ------------------------------------- |
| **Piper**      | `"piper"`              | No               | Yes     | Bundled voices, fastest for long text |
| **SAPI**       | `"sapi"`, `"win"`      | No               | Yes     | Windows system voices                 |
| **Google**     | `"google"`, `"gcloud"` | Yes              | No      | Google Cloud TTS                      |
| **AWS Polly**  | `"aws"`, `"polly"`     | Yes              | No      | Amazon Polly                          |
| **Azure**      | `"azure"`              | Yes              | No      | Azure Cognitive Services              |
| **ElevenLabs** | `"elevenlabs"`         | Yes              | No      | High-quality AI voices                |

### Basic Configuration

```lua
-- Minimal — uses default provider (SAPI)
HoundBlue:enableController({freq = "251.000", modulation = "AM"})

-- Full HoundTTS options
local tts_config = {
    freq = "251.000",              -- String or number
    modulation = "AM",              -- "AM" or "FM", comma-separated for multiple
    volume = "1.0",                 -- "0.0" to "1.0"
    speed = 1.0,                    -- 0.5 (half speed) to 2.0 (double speed), 1.0 = normal
    provider = "sapi",              -- TTS provider (see table above)
    gender = "female",              -- "male" or "female" (SAPI, Google)
    culture = "en-US",              -- Voice culture/language
    voice = "David",                -- Specific voice name (optional, provider-dependent)
}
```

### Provider-Specific Options

#### Piper (offline, bundled)

No internet or API key required. Bundled voices included.

```lua
local tts_config = {
    freq = "251.000",
    modulation = "AM",
    provider = "piper",
    voice = "en_US-lessac-low",     -- Piper model name
    speaker = nil,                  -- Multi-speaker model: speaker name or ID (optional)
}
```

**Bundled voices:**

| Model              | Gender | Sample rate |
| ------------------ | ------ | ----------- |
| `en_US-lessac-low` | Male   | 16 kHz      |
| `en_US-ryan-low`   | Male   | 16 kHz      |

Browse all voices at [rhasspy.github.io/piper-samples](https://rhasspy.github.io/piper-samples/). Download additional models from [HuggingFace](https://huggingface.co/rhasspy/piper-voices) and place them in the `voices\` folder.

#### SAPI (Windows system voices)

Uses Windows Speech API 5.4 — the same engine as Windows Narrator. No internet required.

```lua
local tts_config = {
    freq = "251.000",
    modulation = "AM",
    provider = "sapi",              -- or "win"
    gender = "female",              -- "male" or "female"
    culture = "en-US",              -- Voice culture
    voice = "David",                -- Specific voice name (overrides gender/culture)
}
```

Voice selection priority: `voice` name match → `culture` + `gender` query → system default.

Additional voices can be installed via **Windows Settings → Time & Language → Speech → Add voices**.

#### Google Cloud TTS

Requires a Google Cloud service-account JSON file configured in `HoundTTS-credentials.ini`.

```lua
local tts_config = {
    freq = "251.000",
    modulation = "AM",
    provider = "google",            -- or "gcloud"
    voice = "en-US-Standard-C",     -- Google voice name (default: "google-auto")
    culture = "en-US",
    gender = "female",
}
```

#### AWS Polly

Requires AWS credentials in `HoundTTS-credentials.ini`.

```lua
local tts_config = {
    freq = "251.000",
    modulation = "AM",
    provider = "polly",             -- or "aws"
    voice = "Joanna",               -- Polly voice name (default: "Joanna")
    engine = "standard",            -- "standard", "neural", or "generative"
}
```

#### Azure Cognitive Services

Requires Azure Speech subscription key and region in `HoundTTS-credentials.ini`.

```lua
local tts_config = {
    freq = "251.000",
    modulation = "AM",
    provider = "azure",
    voice = "en-US-JennyNeural",    -- Azure voice name
    culture = "en-US",
}
```

#### ElevenLabs

Requires an ElevenLabs API key in `HoundTTS-credentials.ini`.

```lua
local tts_config = {
    freq = "251.000",
    modulation = "AM",
    provider = "elevenlabs",
    voice = "pNInz6obpgDQGcFmaJgB", -- ElevenLabs voice ID (default: "Adam")
}
```

> **⚠️ Free-tier not suitable for Hound:** ElevenLabs free accounts allow only one concurrent WebSocket connection. Hound routinely sends parallel transmissions (Controller, ATIS, Notifier), so overlapping requests will be rejected and produce no audio. **A paid ElevenLabs plan is required for use with Hound.**

### Multiple Frequencies

```lua
local tts_config = {
    freq = "251.000,35.000,121.500",  -- Comma-separated
    modulation = "AM,FM,AM"            -- Matching order
}
```

### Available Cultures

Common installed voices:

- `en-US` - English (United States)
- `en-GB` - English (United Kingdom)
- `en-AU` - English (Australia)
- `de-DE` - German (Germany)
- `fr-FR` - French (France)
- `es-ES` - Spanish (Spain)
- `it-IT` - Italian (Italy)
- `ru-RU` - Russian (Russia)

### Speech Speed

HoundTTS uses a **ratio scale** (not the -10 to +10 STTS scale):

```lua
speed = 0.5   -- Half speed (very slow)
speed = 1.0   -- Normal (default)
speed = 1.5   -- 50% faster
speed = 2.0   -- Double speed
```

**Recommendations:**

- **Controller:** 1.0 (clear, understandable)
- **ATIS:** 1.1 to 1.3 (slightly faster, less boring)
- **Notifier:** 0.9 to 1.0 (clear alerts)

### Volume

```lua
volume = "0.5"  -- 50% volume
volume = "1.0"  -- 100% volume (default)
```

### Credentials Configuration

API keys for cloud providers are stored in `HoundTTS-credentials.ini` (in `Saved Games\DCS\Config\`), **never** in mission scripts or DCS logs.

```ini
[Piper]
exe =                    ; Path to piper.exe (blank = bundled)
voice_path =             ; Path to .onnx voice models (blank = bundled)

[Google]
credentials_file =       ; Path to Google Cloud service-account JSON

[Azure]
key =                    ; Azure Speech subscription key
region =                 ; Azure region (e.g. eastus, westeurope)

[ElevenLabs]
api_key =                ; ElevenLabs API key
model_id = eleven_turbo_v2

[AWS]
access_key =             ; AWS access key
secret_key =             ; AWS secret key
region =                 ; AWS region (e.g. us-east-1)
```

### Performance Tip

For lengthy transmissions (e.g. ATIS reports), local providers like **Piper** or **SAPI** start speaking almost immediately with no network round-trip. Cloud providers add latency because the entire audio must be generated and downloaded first.

---

## STTS Configuration (Legacy)

> **Note:** HoundTTS is now the default and recommended TTS provider. If HoundTTS is installed, it transparently takes over from STTS — **no configuration changes are needed**. Your existing STTS settings (including `googleTTS` and Azure credentials) are automatically mapped to the corresponding HoundTTS providers. While this backward compatibility works seamlessly, we recommend adopting the new `provider`-based configuration for access to all HoundTTS features (Piper, AWS Polly, ElevenLabs, per-call provider selection, etc.).

**Installation:** https://github.com/ciribob/DCS-SimpleTextToSpeech → Load `DCS-SimpleTextToSpeech.lua` BEFORE `HoundElint.lua`

**Key distinctions:**

- `speed` uses **-10 to +10** range (not percentage or ratio)
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
-- HoundTTS: Piper (offline, no API key)
HoundBlue:enableController({
    freq = "251.000",
    modulation = "AM",
    provider = "piper",
    voice = "en_US-lessac-low",
    speed = 1.0
})

-- HoundTTS: SAPI with custom voice
HoundBlue:enableController({
    freq = "251.000,35.000",  -- Multiple frequencies
    modulation = "AM,FM",
    provider = "sapi",
    gender = "female",
    culture = "en-GB",
    speed = 1.0
})

-- HoundTTS: AWS Polly cloud provider
HoundBlue:enableController({
    freq = "251.000",
    modulation = "AM",
    provider = "polly",
    voice = "Matthew",
    engine = "neural"
})

-- Different voices per system
HoundBlue:enableController({freq = "251.000", modulation = "AM", provider = "sapi", gender = "male", speed = 1.0})
HoundBlue:enableAtis({freq = "253.000", modulation = "AM", provider = "piper", voice = "en_US-ryan-low", speed = 1.2})
HoundBlue:enableNotifier({freq = "243.000", modulation = "AM", provider = "sapi", gender = "female", speed = 0.9})

-- STTS (legacy): Custom voice
HoundBlue:enableController({
    freq = "251.000,35.000",
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
```

---

## Troubleshooting

**No voice:** Check TTS installed/loaded before Hound, desanitized, SRS running, correct frequency.  
**Speed issues:** HoundTTS uses `1.0` (normal), STTS uses `-5` to `5`, gRPC uses `75` to `150`.  
**Wrong voice:** HoundTTS uses `provider` + `voice`, STTS uses `voice = "David"`, gRPC uses `name = "Full Name"`.  
**Volume:** `volume = "1.0"` (string!), also check SRS/DCS/system volume.  
**Cloud not working:** Check `HoundTTS-credentials.ini` has correct API keys/paths.

See [troubleshooting.md](troubleshooting.md) for detailed diagnostics.

---

## Recommendations

**Provider:** HoundTTS with Piper or SAPI for offline, cloud providers for premium quality  
**Speed:** Controller 1.0, ATIS 1.1–1.3, Notifier 0.9–1.0  
**Voices:** Controller (clear/professional), ATIS (slightly faster), Notifier (clear/slow)  
**Culture:** Match mission setting (`en-US`, `en-GB`, `ru-RU`, etc.)

---

## Quick Reference

| Provider | freq        | modulation | speed          | voice param          | provider param           |
| -------- | ----------- | ---------- | -------------- | -------------------- | ------------------------ |
| HoundTTS | `"251.000"` | `"AM"`     | `0.5` to `2.0` | `voice = "name"`     | `provider = "sapi"`      |
| STTS     | `"251.000"` | `"AM"`     | `-10` to `+10` | `voice = "David"`    | N/A                      |
| gRPC     | `"251.000"` | `"AM"`     | `50` to `250`  | `name = "Full Name"` | `provider = {aws={...}}` |

All use `volume = "1.0"` (string), `gender = "male"/"female"`, `culture = "en-US"`
