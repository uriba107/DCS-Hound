# Text-To-Speech Configuration

Guide to configuring voice communications. **TTS is optional** - Hound works without voice (map markers + text only).

---

## TTS Providers

| Provider     | Setup | Voices                                                                                   | Best For                        |
| ------------ | ----- | ---------------------------------------------------------------------------------------- | ------------------------------- |
| **HoundTTS** | Easy  | SAPI (Windows built-in), Piper (local), Supertonic (local), Google, Azure, AWS, ElevenLabs, OpenAI (and compatible) | **All users (default)**         |
| **STTS**     | Easy  | Windows TTS, Google Cloud (opt.)                                                         | Legacy — HoundTTS supersedes it |

HoundTTS is a native C++ DLL that connects directly to SRS — no PowerShell, no focus stealing, fully parallel. If HoundTTS is installed, it automatically takes over from STTS transparently.

STTS requires desanitizing DCS scripting engine (see [installation.md](installation.md#3-desanitize-scripting-engine-if-using-tts)).

---

## TTS Provider Priority

Hound automatically detects and uses available TTS:

**Default order:**

1. HoundTTS (if present) ← **default**
2. STTS (if present — HoundTTS takes over transparently even if STTS is specified)
3. None (no voice)

> **Note:** gRPC TTS support was removed in 0.5.1. Only HoundTTS and STTS are dispatched.

### Override Default Order:

```lua
-- Set before creating Hound instance
HOUND.TTS_ENGINE = {'HoundTTS', 'STTS'}  -- Default

-- STTS only
HOUND.TTS_ENGINE = {'STTS'}

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
| **SAPI**       | `"sapi"`, `"win"`      | No               | Yes     | Windows system voices                 |
| **Piper**      | `"piper"`              | No               | Yes     | Bundled voices, fastest for long text |
| **Supertonic** | `"supertonic"`         | No               | Yes     | 10 bundled voices (5 male + 5 female), multilingual (31 languages) |
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

#### Piper (offline, HoundTTS add-on)

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

#### Supertonic 3 (Offline, HoundTTS add-on)
No internet or API key required. Bundled voices included.

```lua
local tts_config = {
    freq = "251.000",
    modulation = "AM",
    provider = "supertonic",
    colture = "en", -- language of message (optional - also accepts "en_US" or "en-US")
    -- Specify voice literraly (also supports non-free custom voices)
    voice = "F3",     -- supertonic voice name (optional)
    -- select voice by specifying gender and speaker ID 
    gender = "female", -- Speaker gender (male/female - optional)
    speaker = 3,    -- speaker ID (optional)
}
```

supertonic is multi-lingual by default (supports 31 languages) - best when using inline translation

```lua
local de_tts_config = {
    freq = "251.000",
    modulation = "AM",
    provider = "supertonic",
    colture = "de", -- language of message (optional - also accepts "en_US" or "en-US")
    -- select voice by specifying gender and speaker ID 
    gender = "female", -- Speaker gender (male/female - optional)
    speaker = 4,    -- speaker ID (optional)
    translate = {
        provider = "libre", 
        language = "de"
    }
}

```

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

- **Controller:** 1.0 to 1.05 (clear, understandable)
- **ATIS:** 1.1 to 1.3 (slightly faster, less boring)
- **Notifier:** 0.9 to 1.05 (clear alerts)

### Volume

```lua
volume = "0.5"  -- 50% volume
volume = "1.0"  -- 100% volume (default)
```

### Inline Translation (HoundTTS)

HoundTTS supports inline translation of Hound messages. Pass a `translate` table with HoundTTS translation parameters in the TTS config. Translation is applied on the HoundTTS side before synthesis.

**Supported parameters:**

- `provider` — Translation service (`"google"`, `"azure"`, `"openai"`, etc.)
- `language` — Target language code (`"fr"`, `"de"`, `"es"`, `"ru"`, etc.)
- Other provider-specific options (API keys, model, etc.)

**Example:**

```lua
-- Translate all Controller messages to French
HoundBlue:enableController({
    freq = "251.000",
    modulation = "AM",
    provider = "sapi",
    translate = {
        provider = "google",
        language = "fr"
    }
})

-- Different languages per system
HoundBlue:enableController({freq = "251.000", modulation = "AM", translate = {provider = "google", language = "fr"}})
HoundBlue:enableAtis({freq = "253.000", modulation = "AM", translate = {provider = "google", language = "de"}})
HoundBlue:enableNotifier({freq = "243.000", modulation = "AM"})  -- No translation
```

**Notes:**

- Translation requires internet (cloud provider)
- Credentials for translation provider must be in `HoundTTS-credentials.ini`
- Translation adds latency before synthesis
- Omit `translate` table to disable translation

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

```

---

## Troubleshooting

**No voice:** Check TTS installed/loaded before Hound, desanitized, SRS running, correct frequency.  
**Speed issues:** HoundTTS uses `1.0` (normal), STTS uses `-5` to `5`.  
**Wrong voice:** HoundTTS uses `provider` + `voice`, STTS uses `voice = "David"`.  
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

| Provider | freq        | modulation | speed          | voice param       | provider param      | translate param                                      |
| -------- | ----------- | ---------- | -------------- | ----------------- | ------------------- | ---------------------------------------------------- |
| HoundTTS | `"251.000"` | `"AM"`     | `0.5` to `2.0` | `voice = "name"`  | `provider = "sapi"` | `translate = {provider = "google", language = "fr"}` |
| STTS     | `"251.000"` | `"AM"`     | `-10` to `+10` | `voice = "David"` | N/A                 | N/A (not supported)                                  |

All use `volume = "1.0"` (string), `gender = "male"/"female"`, `culture = "en-US"`

**Translate:** HoundTTS only, optional. Translates messages before synthesis using specified provider.
