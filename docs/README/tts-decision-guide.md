# TTS Decision Guide - Which Provider Should I Use?

Quick comparison to help you choose the right Text-To-Speech solution for your mission.

---

## Quick Decision Tree

```
Do you need voice communications?
│
├─ NO  → Skip TTS entirely (Hound works great with markers + text only!)
│
└─ YES → Use STTS (recommended)
    │
    └─ Only use gRPC if:
        - You're already using it in existing missions
        - You understand and accept its parallel transmission limitations
```

**Bottom line: Use STTS.** It's the recommended provider for Hound.

---

## Provider Comparison

### At a Glance

| Feature                    | **STTS**            | **gRPC**             | **No TTS**      |
| -------------------------- | ------------------- | -------------------- | --------------- |
| **Setup Difficulty**       | ⭐ Easy             | ⭐⭐⭐ Advanced      | ✅ None         |
| **Voice Quality**          | ⭐⭐⭐⭐ Same       | ⭐⭐⭐⭐ Same        | N/A             |
| **Parallel Transmissions** | ✅ Works well       | ⚠️ Known issues      | N/A             |
| **Recommended for Hound**  | ✅ Yes              | ❌ No (known issues) | ✅ For no voice |
| **Maintenance**            | Low                 | Medium               | None            |
| **Cost**                   | Free                | Free (cloud = paid)  | Free            |
| **Best For**               | **All Hound users** | Not recommended      | Simple missions |

**Note:** Both STTS and gRPC use the same TTS backends (Windows TTS, Google, AWS, Azure). Voice quality is identical - the difference is in how they handle transmission to SRS.

---

## Detailed Comparison

### STTS (DCS-SimpleTextToSpeech) ⭐ **RECOMMENDED**

**✅ Pros:**

- **Recommended for Hound** - Best compatibility and performance
- **Handles parallel transmissions** - Multiple radios can talk simultaneously
- **Easiest to set up** - 10 minute installation
- **Most popular** - Largest community support
- **All voice backends** - Windows TTS, Google Cloud, AWS, Azure
- **Actively maintained** - Regular updates from Ciribob
- **Simple configuration** - Straightforward Lua setup

**❌ Cons:**

- **Windows TTS voices** - Built-in voices are robotic (use cloud for better quality)
- **Desanitization required** - Must modify MissionScripting.lua

**Best For:**

- **All Hound users** - This is the recommended choice
- New users getting started
- Mission builders who want "set and forget"
- Offline/LAN missions (Windows TTS)
- Production missions needing reliable voice

**Setup Time:** ~10-15 minutes  
**Links:** https://github.com/ciribob/DCS-SimpleTextToSpeech

---

### gRPC (DCS-gRPC) ⚠️ **NOT RECOMMENDED FOR HOUND**

**⚠️ Known Issues:**

- **Parallel transmission limitations** - Problems when multiple radios transmit simultaneously (DCS gRPC project limitation)
- **Not ideal for Hound** - ATIS, Controller, and Notifier may conflict
- **Supported but not recommended** - Implementation exists but has technical issues

**✅ Pros:**

- **Same voice quality as STTS** - Uses identical backends (Windows TTS, AWS, Azure, Google)
- **Multiple backends** - Can configure cloud providers
- **Advanced features** - More customization options
- **Multi-tool integration** - Works with Tacview, external apps

**❌ Cons:**

- **Parallel transmission issues** - Main reason to avoid for Hound
- **Complex setup** - Requires more technical knowledge
- **Cloud costs** - Premium voices require paid accounts
- **More troubleshooting** - Harder to diagnose issues

**Best For:**

- **Existing missions already using gRPC** - If you're already using it
- **Not recommended for new missions** - Use STTS instead

**Note:** gRPC was added as a newer feature to Hound but encountered technical limitations in the DCS gRPC project regarding parallel transmissions. STTS (the original implementation) remains the recommended choice.

**Setup Time:** ~30-60 minutes (more for cloud setup)  
**Links:** https://github.com/DCS-gRPC/rust-server

---

### No TTS (Map Markers + Text Only)

**✅ Pros:**

- **Zero setup** - Works immediately
- **No dependencies** - Nothing to install
- **No desanitization** - Safer for multiplayer servers
- **Perfect reliability** - No voice issues possible
- **Faster** - No TTS processing overhead

**❌ Cons:**

- **No voice** - Must read F10 messages or markers
- **Less immersive** - No radio communications
- **Manual queries** - Must check map frequently
- **Workload** - More heads-down time

**Best For:**

- Quick testing missions
- Simple scenarios
- Multiplayer servers that forbid desanitization
- Users who prefer visual-only intelligence

**Setup Time:** 0 minutes

---

## Voice Quality Comparison

**Important:** STTS and gRPC use the **same TTS backends**. Quality depends on which backend you configure, not which provider you use.

### Sample Scenario: SA-6 Detection Report

**Windows TTS (STTS or gRPC with Windows backend):**

> "Contact Alpha. S-A dash six. Grid Bravo Tango one two three four five six. Threat is active."

- **Quality:** ⭐⭐ Robotic but clear
- **Usability:** ⭐⭐⭐ Perfectly understandable
- **Immersion:** ⭐⭐ Functional but not realistic
- **Cost:** Free (included with Windows)

**Google Cloud (STTS or gRPC with Google backend):**

> "Contact Alpha. S-A dash six. Grid Bravo Tango one two three four five six. Threat is active."

- **Quality:** ⭐⭐⭐⭐ Natural and clear
- **Usability:** ⭐⭐⭐⭐ Excellent
- **Immersion:** ⭐⭐⭐⭐ Very realistic
- **Cost:** ~$4 per 1M characters

**AWS Polly (STTS or gRPC with AWS backend):**

> "Contact Alpha. S-A dash six. Grid Bravo Tango one two three four five six. Threat is active."

- **Quality:** ⭐⭐⭐⭐⭐ Professional grade
- **Usability:** ⭐⭐⭐⭐⭐ Perfect clarity
- **Immersion:** ⭐⭐⭐⭐⭐ Indistinguishable from radio
- **Cost:** ~$4-16 per 1M characters

**Azure Neural (STTS or gRPC with Azure backend):**

> "Contact Alpha. S-A dash six. Grid Bravo Tango one two three four five six. Threat is active."

- **Quality:** ⭐⭐⭐⭐⭐ Top tier
- **Usability:** ⭐⭐⭐⭐⭐ Exceptional
- **Immersion:** ⭐⭐⭐⭐⭐ Movie-quality
- **Cost:** ~$4 per 1M characters

**The quality depends on the voice backend, not STTS vs gRPC!**

---

## Setup Complexity

### STTS Setup Steps

1. Download STTS from GitHub
2. Place `.lua` file in mission folder
3. Load in mission editor before Hound
4. Configure Hound controller with frequency
5. **Optional:** Set up Google Cloud for better voices

**Desanitization:** Required (MissionScripting.lua edit)

### gRPC Setup Steps

1. Download and install gRPC Rust server
2. Configure gRPC settings (ports, providers)
3. **Optional:** Set up cloud provider accounts (AWS/Azure/Google)
4. **Optional:** Configure API keys and regions
5. Start gRPC server before launching DCS
6. Configure Hound controller with frequency

**Desanitization:** Required (MissionScripting.lua edit)

### No TTS Setup Steps

1. Load Hound
2. **Done!**

**Desanitization:** Not required

---

## Cost Analysis

### STTS

| Component            | Cost                         |
| -------------------- | ---------------------------- |
| **Software**         | Free (open source)           |
| **Windows TTS**      | Free (included with Windows) |
| **Google Cloud TTS** | ~$4 per 1 million characters |
| **Typical Mission**  | $0 - $0.10 per mission       |

**Verdict:** Essentially free for most users

### gRPC

| Component            | Cost                                                 |
| -------------------- | ---------------------------------------------------- |
| **Software**         | Free (open source)                                   |
| **Windows TTS**      | Free (included with Windows)                         |
| **AWS Polly**        | $4 per 1 million characters (standard), $16 (neural) |
| **Azure Cognitive**  | $4 per 1 million characters                          |
| **Google Cloud TTS** | $4 per 1 million characters                          |
| **Typical Mission**  | $0 - $0.20 per mission                               |

**Verdict:** Free for Windows TTS, minimal cost for cloud

### No TTS

**Cost:** $0

---

## Performance Comparison

All TTS solutions have **minimal performance impact** on modern systems.

| Aspect           | STTS       | gRPC                  | No TTS    |
| ---------------- | ---------- | --------------------- | --------- |
| **DCS FPS**      | No impact  | No impact             | No impact |
| **Memory**       | +50-100 MB | +100-200 MB           | 0 MB      |
| **CPU**          | <1%        | <1%                   | 0%        |
| **Network**      | SRS only   | SRS + cloud (if used) | None      |
| **Mission Load** | +1-2 sec   | +1-2 sec              | 0 sec     |

**Verdict:** All options perform well; choose based on features, not performance

---

## Feature Comparison

| Feature                  | STTS            | gRPC                | No TTS       |
| ------------------------ | --------------- | ------------------- | ------------ |
| **Controller**           | ✅ Voice + Text | ✅ Voice + Text     | ✅ Text only |
| **ATIS**                 | ✅ Voice + Text | ✅ Voice + Text     | ✅ Text only |
| **Notifier**             | ✅ Voice + Text | ✅ Voice + Text     | ✅ Text only |
| **Multiple Frequencies** | ✅              | ✅                  | N/A          |
| **Voice Selection**      | ✅              | ✅                  | N/A          |
| **Cloud Voices**         | ✅ Google only  | ✅ AWS/Azure/Google | N/A          |
| **Offline Operation**    | ✅              | ✅                  | ✅           |
| **Speed Control**        | ✅              | ✅                  | N/A          |
| **Volume Control**       | ✅              | ✅                  | N/A          |
| **Culture/Language**     | ✅              | ✅                  | N/A          |

---

## Multiplayer Considerations

### STTS

- **Server must desanitize** - Not all servers allow this
- **Clients need SRS** - Standard requirement
- **Voice quality** - Server-side TTS config applies to all
- **Compatibility** - Widely supported

### gRPC

- **Server must desanitize** - Same as STTS
- **Clients need SRS** - Standard requirement
- **Server setup** - More complex for mission hosts
- **Compatibility** - Less common, may require client explanation

### No TTS

- **Server setup** - No special requirements
- **Client requirements** - None
- **Compatibility** - 100% compatible
- **Accessibility** - Works on any server

**Verdict:** STTS is the multiplayer standard; No TTS is the most compatible

---

## Switching Providers

You can change TTS providers at any time by:

1. **Loading different TTS before Hound** in mission editor
2. **Setting provider priority:**
   ```lua
   HOUND.TTS_ENGINE = {'STTS'}       -- STTS only
   HOUND.TTS_ENGINE = {'GRPC'}       -- gRPC only
   HOUND.TTS_ENGINE = {'GRPC', 'STTS'} -- Prefer gRPC, fallback to STTS
   ```

**Hound automatically detects available providers** - if your first choice isn't available, it falls back to the next.

---

## Recommendations by Scenario

### Solo Player, Immersion Focused

**→ gRPC with cloud voices**

- Best audio quality
- Worth the setup time for immersion

### Solo Player, Just Getting Started

**→ STTS with Windows TTS**

- Easy setup
- Upgrade to Google Cloud later if desired

### Multiplayer Mission Builder

**→ STTS with Windows TTS**

- Standard choice
- Easy for server hosts
- Good balance of quality and compatibility

### Competition/Training Server

**→ STTS or gRPC (server choice)**

- Professional voice quality helps with clarity
- Consider cost if high usage

### LAN Party / Quick Mission

**→ No TTS or STTS**

- No TTS: Zero setup
- STTS: Quick setup if host has it

### Testing/Development

**→ No TTS**

- Fastest iteration
- Add voice in final mission

---

## Migration Guide

### From No TTS → STTS

1. Install STTS
2. Desanitize `MissionScripting.lua`
3. Add STTS load in mission before Hound
4. Add `enableController()` call
5. Test with SRS

**Time:** 15-20 minutes

### From STTS → gRPC

1. Install DCS-gRPC server
2. Optional: Configure cloud providers
3. Start gRPC server
4. Set `HOUND.TTS_ENGINE = {'GRPC'}`
5. Restart mission

**Time:** 30-60 minutes

### From gRPC → STTS

1. Remove gRPC-specific config
2. Ensure STTS is loaded
3. Set `HOUND.TTS_ENGINE = {'STTS'}` or let auto-detect
4. Restart mission

**Time:** 5 minutes

---

## Common Questions

### "Which provider sounds best?"

Voice quality is **the same** for both - it depends on the backend:

- **Cloud voices** (AWS/Azure/Google) > **Windows TTS**
- STTS and gRPC can both use any backend

### "Which is easiest to set up?"

**No TTS** > **STTS** > **gRPC**

### "Which should I use for Hound?"

**STTS** - Recommended. Better handling of parallel transmissions.

### "Why not gRPC?"

gRPC has known limitations with parallel transmissions in DCS, which causes issues when Hound's Controller, ATIS, and Notifier need to talk simultaneously.

### "Can I use both STTS and gRPC?"

Technically yes with `HOUND.TTS_ENGINE = {'STTS', 'GRPC'}`, but **use STTS only** for best results.

### "Do I need TTS?"

No! Hound's map markers and text system work excellently without voice

### "Can I change mid-mission?"

No, TTS provider is determined at mission start. You can change frequencies or disable/enable systems.

---

## Bottom Line Recommendations

| Your Situation           | Recommended Provider           |
| ------------------------ | ------------------------------ |
| **New to Hound**         | **STTS**                       |
| **New to DCS scripting** | No TTS first, add STTS later   |
| **Want best quality**    | **STTS + cloud backend**       |
| **Multiplayer mission**  | **STTS**                       |
| **Quick testing**        | No TTS                         |
| **Already use gRPC**     | **Switch to STTS** if possible |
| **Limited time**         | **STTS**                       |
| **Budget conscious**     | **STTS** with Windows TTS      |
| **Professional mission** | **STTS** with AWS/Azure        |
| **Any Hound mission**    | **STTS (always recommended)**  |

**gRPC is NOT recommended for Hound** due to parallel transmission limitations.

---

## Next Steps

### Chose STTS?

→ [TTS Configuration Guide](tts-configuration.md#stts-configuration)

### Chose gRPC?

→ [TTS Configuration Guide](tts-configuration.md#grpc-configuration)

### Chose No TTS?

→ [Quick Start Guide](quick-start.md) (skip voice setup)

### Still unsure?

→ Start with **No TTS** to learn Hound basics, add **STTS** when ready for voice

---

## External Resources

- **STTS GitHub:** https://github.com/ciribob/DCS-SimpleTextToSpeech
- **gRPC GitHub:** https://github.com/DCS-gRPC/rust-server
- **SRS (Required for voice):** https://github.com/ciribob/DCS-SimpleRadioStandalone
- **AWS Polly Pricing:** https://aws.amazon.com/polly/pricing/
- **Azure TTS Pricing:** https://azure.microsoft.com/en-us/pricing/details/cognitive-services/speech-services/
- **Google Cloud TTS Pricing:** https://cloud.google.com/text-to-speech/pricing

---

## See Also

- **[TTS Configuration](tts-configuration.md)** - Detailed setup for both providers
- **[Controller Guide](controller.md)** - Using the interactive SAM controller
- **[ATIS Guide](atis.md)** - Automated broadcasts
- **[Troubleshooting](troubleshooting.md#voice-issues)** - Voice problems and solutions
