# TTS Decision Guide - Which Provider Should I Use?

Quick comparison to help you choose the right Text-To-Speech solution for your mission.

---

## Quick Decision Tree

```
Do you need voice communications?
│
├─ NO  → Skip TTS entirely (Hound works great with markers + text only!)
│
└─ YES → Use HoundTTS (default, recommended)
    │
    ├─ Want offline, zero-config voices?
    │   └─ SAPI (Windows system voices) or Piper (add-on) or Supertonic (add-on)
    │
    ├─ Want premium cloud voices?
    │   └─ Google, Azure, AWS Polly, or ElevenLabs
    │
    └─ Already using STTS?
        └─ HoundTTS takes over transparently — no changes needed
```

**Bottom line: Use HoundTTS.** It's the default and recommended provider for Hound.

---

## Provider Comparison

### At a Glance

| Feature                       | **HoundTTS** ⭐                                 | **STTS**            | **gRPC**                        | **No TTS**      |
| ----------------------------- | ----------------------------------------------- | ------------------- | ------------------------------- | --------------- |
| **Setup Difficulty**          | ⭐ Easy                                         | ⭐ Easy             | ⭐⭐⭐ Advanced                 | ✅ None         |
| **Voice Quality**             | ⭐⭐⭐⭐⭐ Best                                 | ⭐⭐⭐⭐ Good       | ⭐⭐⭐⭐ Good                   | N/A             |
| **Parallel Transmissions**    | ✅ Native, non-blocking                         | ✅ Works well       | ⚠️ Known issues                 | N/A             |
| **TTS Providers**             | 6 (Piper, SAPI, Google, Azure, AWS, ElevenLabs) | 2 (Windows, Google) | 4 (Windows, AWS, Azure, Google) | N/A             |
| **Offline Voices**            | ✅ Piper + SAPI                                 | ✅ Windows TTS      | ✅ Windows TTS                  | N/A             |
| **No PowerShell/Focus Steal** | ✅                                              | ❌ Uses PowerShell  | ✅                              | N/A             |
| **Recommended for Hound**     | ✅ **Default**                                  | ✅ Legacy fallback  | ❌ Known issues                 | ✅ For no voice |
| **Maintenance**               | Low                                             | Low                 | Medium                          | None            |
| **Cost**                      | Free (cloud = paid)                             | Free (cloud = paid) | Free (cloud = paid)             | Free            |
| **Best For**                  | **All Hound users**                             | Legacy missions     | Not recommended                 | Simple missions |

---

## Detailed Comparison

### HoundTTS ⭐ **DEFAULT & RECOMMENDED**

**✅ Pros:**

- **Default for Hound** — automatically detected and used when installed
- **Native C++ DLL** — no PowerShell overhead, no focus stealing, no visible windows
- **Fully parallel** — every TTS request is fire-and-forget in background threads
- **7 TTS providers** — SAPI (Windows), Piper (offline, bundled), Supertonic (offline, bundled add-on), Google Cloud, Azure, AWS Polly, ElevenLabs
- **Offline voices included** — Piper voices bundled, SAPI uses Windows system voices, no API key needed
- **Secure credentials** — API keys stored in INI file, never exposed in mission scripts or DCS logs
- **Auto-detects SRS** — reads SRS path from Windows registry, no manual configuration
- **Drop-in STTS replacement** — transparently takes over if STTS is also loaded
- **Supports inline translation** - want hound in Danish? just add translation params

**❌ Cons:**

- **Windows only** — native DLL requires Windows 10 (1903+) or later
- **Cloud providers require API keys** — configured in `HoundTTS-credentials.ini`

**Best For:**

- **All Hound users** — this is the default and recommended choice
- New users getting started
- Users who want multiple voice provider options
- Offline/LAN missions (SAPI or Piper or Supertonic)
- Production missions needing reliable, parallel voice

**Setup Time:** ~5 minutes  
**Links:** [HoundTTS README](https://github.com/uriba107/HoundTTS)

---

### STTS (DCS-SimpleTextToSpeech) — Legacy Fallback

> **Note:** If HoundTTS is installed, it transparently takes over from STTS — **no configuration changes are needed**. Your existing STTS settings (`googleTTS`, Azure credentials, voice, gender, culture, speed, etc.) are automatically mapped to the corresponding HoundTTS providers. Just install HoundTTS and everything keeps working.

**✅ Pros:**

- **Widely used** — large community, well-known
- **Simple Lua script** — easy to understand
- **Windows TTS + Google Cloud** — two voice backends

**❌ Cons:**

- **PowerShell overhead** — spawns PowerShell processes, can steal focus
- **Fewer providers** — only Windows TTS and Google Cloud
- **Superseded by HoundTTS** — HoundTTS provides all STTS features and more

**Best For:**

- **Legacy missions** that haven't installed HoundTTS yet
- Fallback if HoundTTS is not installed

**Setup Time:** ~5 minutes  
**Links:** https://github.com/ciribob/DCS-SimpleTextToSpeech

---

### gRPC (DCS-gRPC) ⚠️ **NOT RECOMMENDED FOR HOUND**

**DCS-gRPC is no longer maintained**

**⚠️ Known Issues:**

- **Parallel transmission limitations** — problems when multiple radios transmit simultaneously (DCS gRPC project limitation)
- **Not ideal for Hound** — ATIS, Controller, and Notifier may conflict

**✅ Pros:**

- **Multiple backends** — Windows TTS, AWS, Azure, Google
- **Multi-tool integration** — works with Tacview, external apps

**❌ Cons:**
- **Parallel transmission issues** — main reason to avoid for Hound
- **Complex setup** — requires more technical knowledge

**Best For:**

- **Existing missions already using gRPC** — if you're already using it
- **Not recommended for new missions** — use HoundTTS instead

**Setup Time:** ~30-60 minutes  
**Links:** https://github.com/DCS-gRPC/rust-server

---

### No TTS (Map Markers + Text Only)

**✅ Pros:**

- **Zero setup** — works immediately
- **No dependencies** — nothing to install
- **No desanitization** — safer for multiplayer servers
- **Perfect reliability** — no voice issues possible

**❌ Cons:**

- **No voice** — must read F10 messages or markers
- **Less immersive** — no radio communications

**Best For:**

- Quick testing missions
- Multiplayer servers that forbid desanitization
- Users who prefer visual-only intelligence

**Setup Time:** 0 minutes

---

## HoundTTS Provider Comparison

Since HoundTTS supports 6 providers, here's a quick guide to choosing one:

| Provider       | Quality          | Latency    | Cost               | Best For                                                        |
| -------------- | ---------------- | ---------- | ------------------ | --------------------------------------------------------------- |
| **Piper**      | ⭐⭐⭐ Good      | ⚡ Instant | Free               | Offline, long ATIS reports                                      |
| **Supertonic**      | ⭐⭐⭐ Good      | ⚡ Instant | Free               | Offline, long ATIS reports, multi-lingual                                      |
| **SAPI**       | ⭐⭐ Robotic     | ⚡ Instant | Free               | Offline, Windows default                                        |
| **Google**     | ⭐⭐⭐⭐ Natural | 🌐 Network | ~$4/1M chars       | Natural cloud voices                                            |
| **AWS Polly**  | ⭐⭐⭐⭐⭐ Pro   | 🌐 Network | $4-16/1M chars     | Professional grade                                              |
| **Azure**      | ⭐⭐⭐⭐⭐ Top   | 🌐 Network | ~$4/1M chars       | Neural voices                                                   |
| **ElevenLabs** | ⭐⭐⭐⭐⭐ AI    | 🌐 Network | Paid plan required | Highest quality AI voices (⚠️ free tier not suitable for Hound) |

**Tip:** For long transmissions (ATIS), use local providers (**Piper**, **Supertonic** or **SAPI**) — save your money to where it really counts.

---

## Voice Quality Comparison

### Sample Scenario: SA-6 Detection Report

**Piper (HoundTTS, offline):**

> "Contact Alpha. SA six. Grid Bravo Tango one two three four five six. Threat is active."

- **Quality:** ⭐⭐⭐ Clear and natural-sounding
- **Cost:** Free (bundled)

**SAPI / Windows TTS (HoundTTS or STTS):**

> "Contact Alpha. SA six. Grid Bravo Tango one two three four five six. Threat is active."

- **Quality:** ⭐⭐ Robotic but clear
- **Cost:** Free (included with Windows)

**Google Cloud (HoundTTS or STTS):**

> "Contact Alpha. SA six. Grid Bravo Tango one two three four five six. Threat is active."

- **Quality:** ⭐⭐⭐⭐ Natural and clear
- **Cost:** ~$4 per 1M characters

**AWS Polly (HoundTTS):**

> "Contact Alpha. SA six. Grid Bravo Tango one two three four five six. Threat is active."

- **Quality:** ⭐⭐⭐⭐⭐ Professional grade
- **Cost:** ~$4-16 per 1M characters

**Azure Neural (HoundTTS):**

> "Contact Alpha. SA six. Grid Bravo Tango one two three four five six. Threat is active."

- **Quality:** ⭐⭐⭐⭐⭐ Top tier
- **Cost:** ~$4 per 1M characters

**ElevenLabs (HoundTTS only):**

> "Contact Alpha. SA six. Grid Bravo Tango one two three four five six. Threat is active."

- **Quality:** ⭐⭐⭐⭐⭐ AI-generated, most natural
- **Cost:** Paid plan required (free tier only allows one concurrent request — not suitable for Hound)

---

## Setup Complexity

### HoundTTS Setup Steps

1. Copy `dist\base\` into DCS Saved Games folder
2. (Optional) Copy `dist\piper-addon\` for Piper voices
3. Add one line to `MissionScripting.lua`
4. Copy config examples and edit as needed
5. Configure Hound controller with frequency

**Desanitization:** Not required (DLL loads before sanitization)  
**Cloud providers:** Configure API keys in `HoundTTS-credentials.ini`

### STTS Setup Steps (Legacy)

1. Download STTS from GitHub
2. Place `.lua` file in mission folder
3. Load in mission editor before Hound
4. Configure Hound controller with frequency
5. **Optional:** Set up Google Cloud for better voices

**Desanitization:** Required (MissionScripting.lua edit)

### gRPC Setup Steps

1. Download and install gRPC Rust server
2. Configure gRPC settings (ports, providers)
3. **Optional:** Set up cloud provider accounts
4. Start gRPC server before launching DCS
5. Configure Hound controller with frequency

**Desanitization:** Required (MissionScripting.lua edit)

### No TTS Setup Steps

1. Load Hound
2. **Done!**

**Desanitization:** Not required

---

## Cost Analysis

### HoundTTS

| Component            | Cost                                                                              |
| -------------------- | --------------------------------------------------------------------------------- |
| **Software**         | Free (open source)                                                                |
| **Piper**            | Free (bundled offline voices)                                                     |
| **Supertonic**            | Free (bundled offline voices)                                                     |
| **SAPI**             | Free (included with Windows)                                                      |
| **Google Cloud TTS** | ~$4 per 1 million characters                                                      |
| **AWS Polly**        | $4 per 1 million characters (standard), $16 (neural)                              |
| **Azure Cognitive**  | ~$4 per 1 million characters                                                      |
| **ElevenLabs**       | Paid plan required (free tier not suitable for Hound — single concurrent request) |
| **Typical Mission**  | $0 - $0.20 per mission                                                            |

**Verdict:** Free with Piper or SAPI, minimal cost for cloud providers

### STTS (Legacy)

| Component            | Cost                         |
| -------------------- | ---------------------------- |
| **Software**         | Free (open source)           |
| **Windows TTS**      | Free (included with Windows) |
| **Google Cloud TTS** | ~$4 per 1 million characters |
| **Typical Mission**  | $0 - $0.10 per mission       |

### No TTS

**Cost:** $0

---

## Performance Comparison

All TTS solutions have **minimal performance impact** on modern systems.

| Aspect           | HoundTTS              | STTS       | gRPC                  | No TTS    |
| ---------------- | --------------------- | ---------- | --------------------- | --------- |
| **DCS FPS**      | No impact             | No impact  | No impact             | No impact |
| **Memory**       | +50-100 MB            | +50-100 MB | +100-200 MB           | 0 MB      |
| **CPU**          | <1%                   | <1%        | <1%                   | 0%        |
| **Network**      | SRS + cloud (if used) | SRS only   | SRS + cloud (if used) | None      |
| **Mission Load** | +1-2 sec              | +1-2 sec   | +1-2 sec              | 0 sec     |

**Verdict:** All options perform well; choose based on features, not performance

---

## Feature Comparison

| Feature                  | HoundTTS                          | STTS            | gRPC                | No TTS       |
| ------------------------ | --------------------------------- | --------------- | ------------------- | ------------ |
| **Controller**           | ✅ Voice + Text                   | ✅ Voice + Text | ✅ Voice + Text     | ✅ Text only |
| **ATIS**                 | ✅ Voice + Text                   | ✅ Voice + Text | ✅ Voice + Text     | ✅ Text only |
| **Notifier**             | ✅ Voice + Text                   | ✅ Voice + Text | ✅ Voice + Text     | ✅ Text only |
| **Multiple Frequencies** | ✅                                | ✅              | ✅                  | N/A          |
| **Voice Selection**      | ✅ Per-provider                   | ✅              | ✅                  | N/A          |
| **Cloud Voices**         | ✅ Google, Azure, AWS, ElevenLabs | ✅ Google only  | ✅ AWS/Azure/Google | N/A          |
| **Offline Operation**    | ✅ Piper + SAPI                   | ✅              | ✅                  | ✅           |
| **Speed Control**        | ✅                                | ✅              | ✅                  | N/A          |
| **Volume Control**       | ✅                                | ✅              | ✅                  | N/A          |
| **Culture/Language**     | ✅                                | ✅              | ✅                  | N/A          |

---

## Multiplayer Considerations

### HoundTTS

- **Server installs DLL once** — no per-mission Lua script loading
- **Clients need SRS** — standard requirement
- **Voice quality** — server-side provider config applies to all
- **Parallel transmissions** — native non-blocking, no conflicts

### STTS (Legacy)

- **Server must desanitize** — not all servers allow this
- **Clients need SRS** — standard requirement
- **Voice quality** — server-side TTS config applies to all
- **Compatibility** — widely supported

### gRPC

- **Server must desanitize** — same as STTS
- **Clients need SRS** — standard requirement
- **Server setup** — more complex for mission hosts

### No TTS

- **Server setup** — no special requirements
- **Client requirements** — none
- **Compatibility** — 100% compatible

**Verdict:** HoundTTS is the recommended multiplayer choice; No TTS is the most compatible

---

## Switching Providers

You can change TTS providers at any time by:

1. **Installing HoundTTS** — it automatically takes priority over STTS
2. **Setting provider priority:**
   ```lua
   HOUND.TTS_ENGINE = {'HoundTTS', 'STTS'}  -- Default
   HOUND.TTS_ENGINE = {'STTS'}               -- STTS only (legacy)
   HOUND.TTS_ENGINE = {'GRPC'}               -- gRPC only
   ```
3. **Changing HoundTTS provider** per-system:
   ```lua
   HoundBlue:enableController({freq = "251.000", provider = "piper"})
   HoundBlue:enableAtis({freq = "253.000", provider = "sapi"})
   ```

**Hound automatically detects available providers** — if your first choice isn't available, it falls back to the next.

---

## Recommendations by Scenario

### Solo Player, Immersion Focused

**→ HoundTTS with Azure, AWS Polly, or ElevenLabs**

- Best audio quality with cloud voices
- Piper for offline fallback

### Solo Player, Just Getting Started

**→ HoundTTS with Piper or SAPI**

- Easy setup, no API keys needed
- Upgrade to cloud providers later if desired

### Multiplayer Mission Builder

**→ HoundTTS with Piper or SAPI**

- Standard choice, easy for server hosts
- No PowerShell focus-stealing issues
- Good balance of quality and compatibility

### Competition/Training Server

**→ HoundTTS with cloud provider**

- Professional voice quality helps with clarity
- Consider cost if high usage

### LAN Party / Quick Mission

**→ No TTS or HoundTTS with Piper**

- No TTS: Zero setup
- HoundTTS + Piper: Quick setup, offline, no API keys

### Testing/Development

**→ No TTS**

- Fastest iteration
- Add voice in final mission

---

## Migration Guide

### From No TTS → HoundTTS

1. Copy HoundTTS files into DCS Saved Games folder
2. Add one line to `MissionScripting.lua`
3. (Optional) Copy config examples and edit
4. Add `enableController()` call
5. Test with SRS

**Time:** ~10 minutes

### From STTS → HoundTTS

1. Install HoundTTS (see above)
2. **Done** — HoundTTS automatically takes over from STTS, no changes needed

Your existing STTS settings (`googleTTS`, Azure credentials, voice, gender, culture, etc.) are automatically mapped to the corresponding HoundTTS providers. Everything keeps working as before.

We recommend eventually adopting the new `provider`-based configuration to access all HoundTTS features (Piper, AWS Polly, ElevenLabs, per-call provider selection).

**Time:** ~10 minutes (zero config changes required)

### From gRPC → HoundTTS

1. Install HoundTTS
2. Set `HOUND.TTS_ENGINE = {'HoundTTS'}` or let auto-detect
3. (Optional) Configure cloud providers in `HoundTTS-credentials.ini`
4. Restart mission

**Time:** ~10 minutes

### From No TTS → STTS (Legacy)

1. Install STTS
2. Desanitize `MissionScripting.lua`
3. Add STTS load in mission before Hound
4. Add `enableController()` call
5. Test with SRS

**Time:** 15-20 minutes

---

## Common Questions

### "Which provider sounds best?"

It depends on the HoundTTS backend you choose:

- **ElevenLabs** > **Azure/AWS Polly/Google Cloud** > **Piper/Supertonic** > **SAPI (Windows TTS)**
- Cloud voices cost money; Piper, Supertonic and SAPI are free and offline

### "Which is easiest to set up?"

**No TTS** > **HoundTTS** > **STTS** > **gRPC**

### "Which should I use for Hound?"

**HoundTTS** — it's the default. Written to directly address Hound needs, native C++ DLL, fully parallel, 7 TTS providers, no PowerShell.

### "Why not gRPC?"

gRPC has known limitations with parallel transmissions in DCS, which causes issues when Hound's Controller, ATIS, and Notifier need to talk simultaneously.

### "I already use STTS — do I need to change anything?"

No. Install HoundTTS and it transparently takes over from STTS. Your existing configuration still works.

### "Can I use different providers for different systems?"

Yes! With HoundTTS you can set `provider` per-system:

```lua
HoundBlue:enableController({freq = "251.000", provider = "sapi", gender = "male"})
HoundBlue:enableAtis({freq = "253.000", provider = "piper", voice = "en_US-lessac-low"})
```

### "Do I need TTS?"

No! Hound's map markers and text system work excellently without voice.

### "Can I change mid-mission?"

No, TTS provider is determined at mission start. You can change frequencies or disable/enable systems.

---

## Bottom Line Recommendations

| Your Situation           | Recommended Provider                              |
| ------------------------ | ------------------------------------------------- |
| **New to Hound**         | **HoundTTS** with Piper, Supertonic or SAPI                   |
| **New to DCS scripting** | No TTS first, add HoundTTS later                  |
| **Want best quality**    | **HoundTTS** with Azure, AWS Polly, or ElevenLabs |
| **Multiplayer mission**  | **HoundTTS** with Piper or SAPI                   |
| **Quick testing**        | No TTS                                            |
| **Already use STTS**     | Install HoundTTS — takes over automatically       |
| **Already use gRPC**     | **Switch to HoundTTS**                            |
| **Limited time**         | **HoundTTS** with local provider (zero-config voice)       |
| **Budget conscious**     | **HoundTTS** with Piper, Supertonic or SAPI (free)            |
| **Professional mission** | **HoundTTS** with AWS/Azure/ElevenLabs            |
| **Any Hound mission**    | **HoundTTS (always recommended)**                 |

**gRPC is NOT recommended for Hound** due to parallel transmission limitations.

---

## Next Steps

### Chose HoundTTS? (recommended)

→ [TTS Configuration Guide](tts-configuration.md#houndtts-configuration--default)

### Chose STTS? (legacy)

→ [TTS Configuration Guide](tts-configuration.md#stts-configuration-legacy)

### Chose gRPC?

→ [TTS Configuration Guide](tts-configuration.md#grpc-configuration)

### Chose No TTS?

→ [Quick Start Guide](quick-start.md) (skip voice setup)

### Still unsure?

→ Start with **No TTS** to learn Hound basics, add **HoundTTS** when ready for voice

---

## External Resources

- **HoundTTS:** https://github.com/uriba107/HoundTTS
- **STTS GitHub:** https://github.com/ciribob/DCS-SimpleTextToSpeech
- **gRPC GitHub:** https://github.com/DCS-gRPC/rust-server
- **SRS (Required for voice):** https://github.com/ciribob/DCS-SimpleRadioStandalone
- **Piper TTS Voices:** https://rhasspy.github.io/piper-samples/
- **AWS Polly Pricing:** https://aws.amazon.com/polly/pricing/
- **Azure TTS Pricing:** https://azure.microsoft.com/en-us/pricing/details/cognitive-services/speech-services/
- **Google Cloud TTS Pricing:** https://cloud.google.com/text-to-speech/pricing
- **ElevenLabs:** https://elevenlabs.io/

---

## See Also

- **[TTS Configuration](tts-configuration.md)** - Detailed setup for all providers
- **[Controller Guide](controller.md)** - Using the interactive SAM controller
- **[ATIS Guide](atis.md)** - Automated broadcasts
- **[Troubleshooting](troubleshooting.md#voice-tts-issues)** - Voice problems and solutions
