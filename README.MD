# Hound ELINT System for DCS

## What is Hound?

**Hound ELINT** is a DCS mission script that simulates realistic electronic intelligence gathering. Using ELINT platforms (aircraft, ground stations, or static objects), it triangulates the position of enemy radars and provides that information through map markers, voice communications, and automated broadcasts.

### Key Features

- **Realistic Triangulation** - Position accuracy improves with more platforms and better geometry
- **Visual Feedback** - F10 map markers show estimated positions with uncertainty ellipses
- **Voice Communications** - ATIS broadcasts and interactive SAM controller via SRS
- **Asset-Based System** - Destroy the ELINT platforms, lose the intelligence
- **Flexible Configuration** - Simple setup for beginners, powerful features for advanced users

### Video Introduction

[![Watch on YouTube](https://i.ytimg.com/vi/S4xxtKOqGqU/hq720.jpg)](https://www.youtube.com/watch?v=S4xxtKOqGqU)

---

## 🚀 Getting Started (5 Minutes)

### Step 1: Install

1. Download `HoundElint.lua`
2. In Mission Editor, create trigger: **ONCE** type, **TIME MORE 1** condition
3. Add action: **DO SCRIPT FILE** → `HoundElint.lua`

### Step 2: Configure (Minimal)

```lua
do
  HoundBlue = HoundElint:create(coalition.side.BLUE)
  HoundBlue:addPlatform("ELINT_C130")  -- Use exact unit name
  HoundBlue:addPlatform("ELINT_Tower") -- At least 2 recommended
  HoundBlue:systemOn()
end
```

### Step 3: Fly and Monitor

- Platforms automatically detect radars when they transmit
- Check F10 map for markers (updates every 2 minutes)
- Position accuracy improves over time

**📖 For detailed setup:** [Quick Start Guide](docs/quick-start.md)

---

## 📚 Documentation Structure

### For New Users - Start Here

| Document                                                      | What You'll Learn                             |
| ------------------------------------------------------------- | --------------------------------------------- |
| **[Quick Start](docs/quick-start.md)**                 | Get Hound running in your mission immediately |
| **[Installation](docs/installation.md)**               | Detailed installation and requirements        |
| **[Basic Configuration](docs/basic-configuration.md)** | Essential settings and simple examples        |

### Core Concepts

| Document                                            | What You'll Learn                                              |
| --------------------------------------------------- | -------------------------------------------------------------- |
| **[Available Platforms](docs/platforms.md)** | Complete list of supported ELINT assets and their capabilities |
| **[How Hound Works](docs/how-it-works.md)**  | Understanding triangulation, accuracy, and system behavior     |
| **[Map Markers](docs/map-markers.md)**       | Visual feedback, marker types, and customization               |

### Communication Systems

| Document                                                   | What You'll Learn                              |
| ---------------------------------------------------------- | ---------------------------------------------- |
| **[Communication Overview](docs/communication.md)** | Understanding ATIS, Controller, and Notifier   |
| **[ATIS Setup](docs/atis.md)**                      | Automated threat broadcasts                    |
| **[Controller Setup](docs/controller.md)**          | Interactive SAM controller with voice and text |
| **[TTS Configuration](docs/tts-configuration.md)**  | Configuring HoundTTS or STTS for voice     |

### Advanced Features

| Document                                                            | What You'll Learn                                     |
| ------------------------------------------------------------------- | ----------------------------------------------------- |
| **[Sectors and Zones](docs/sectors.md)**                     | Organizing multiple regions with separate controllers |
| **[Advanced Configuration](docs/advanced-configuration.md)** | Complex setups, multi-sector missions                 |
| **[Event Handlers](docs/event-handlers.md)**                 | Custom scripting and automation triggers              |
| **[Exports](docs/exports.md)**                               | Exporting data (LUA tables, CSV files)                |

### Reference & Troubleshooting

| Document                                                    | What You'll Learn                          |
| ----------------------------------------------------------- | ------------------------------------------ |
| **[Settings Reference](docs/settings-reference.md)** | Complete list of all configuration options |
| **[Troubleshooting](docs/troubleshooting.md)**       | Common issues and solutions                |
| **[Performance Tuning](docs/performance.md)**        | Optimizing for large missions              |
| **[Breaking Changes](docs/breaking-changes.md)**     | Version upgrade guide                      |

---

## 🎯 Quick Links for Common Tasks

- **[Adding ELINT platforms](docs/basic-configuration.md#adding-platforms)** - How to assign units
- **[Enabling voice communications](docs/controller.md#basic-setup)** - Set up SAM controller
- **[Configuring map markers](docs/map-markers.md#marker-types)** - Customizing visual feedback
- **[Creating sectors](docs/sectors.md#creating-sectors)** - Multiple geographic regions
- **[Pre-briefed contacts](docs/basic-configuration.md#pre-briefed-contacts)** - Fixed SAM sites
- **[Troubleshooting detection issues](docs/troubleshooting.md#detection-issues)** - Common problems

---

## 🔧 System Requirements

**Base Requirements:**

- DCS World (any modern version)
- No external dependencies required (as of v0.4.1)

**Optional (for Text-To-Speech):**

- Choose ONE of:
  - [HoundTTS](https://github.com/uriba107/HoundTTS)
  - [DCS-SimpleTextToSpeech (STTS)](https://github.com/ciribob/DCS-SimpleTextToSpeech) - Recommended

**Compatibility:**

- ✅ MOOSE Framework
- ✅ Skynet IADS
- ✅ High-Digit SAMs
- ✅ Most mission scripts

---

## 📖 Complete API Documentation

For experienced users and developers:

- **[Main Script Documentation](https://uriba107.github.io/DCS-Hound/)** - All available functions
- **[Developer Documentation](https://uriba107.github.io/DCS-Hound/dev/)** - Internal API and architecture
- **[Scripting Ideas](docs/scripting-ideas.md)** - Community examples and creative uses

---

## 💡 Example Configurations

### Minimal Setup

```lua
HoundBlue = HoundElint:create(coalition.side.BLUE)
HoundBlue:addPlatform("ELINT_1")
HoundBlue:addPlatform("ELINT_2")
HoundBlue:systemOn()
```

### With Voice Controller

```lua
HoundBlue = HoundElint:create(coalition.side.BLUE)
HoundBlue:addPlatform("ELINT_C130_North")
HoundBlue:addPlatform("ELINT_C130_South")
HoundBlue:enableController({freq = "251.000", modulation = "AM"})
HoundBlue:systemOn()
```

### Multi-Sector Mission

```lua
HoundBlue = HoundElint:create(coalition.side.BLUE)
HoundBlue:addPlatform("ELINT_C130")
HoundBlue:addPlatform("ELINT_Tower")

HoundBlue:addSector("North Syria")
HoundBlue:addSector("Lebanon")

HoundBlue:enableController("North Syria", {freq = "251.000", modulation = "AM"})
HoundBlue:enableController("Lebanon", {freq = "253.000", modulation = "AM"})

HoundBlue:setZone("North Syria", "Zone_NorthSyria")
HoundBlue:setZone("Lebanon", "Zone_Lebanon")

HoundBlue:systemOn()
```

**📖 More examples:** [Advanced Configuration](docs/advanced-configuration.md)

---

## 🤝 Credits and Thanks

- **Grimes** - [MIST](https://github.com/mrSkortch/MissionScriptingTools) and [Hoggit Wiki](https://wiki.hoggitworld.com/)
- **[flywaldair](https://github.com/walder)** - [Skynet IADS](https://github.com/walder/Skynet-IADS) inspiration
- **[Ciribob](https://github.com/ciribob)** - STTS and invaluable support
- **[Pene](https://github.com/Penecruz)** & **[DCS ANZUS](https://discord.gg/mCQw9Wm5Qq)** - Testing and feedback
- **[rkusa](https://github.com/rkusa)** & **[rurounijones](https://github.com/rurounijones)** - [DCS-gRPC](https://github.com/DCS-gRPC/rust-server)
- **Nikos**, **[Jester](https://github.com/hbjonsson)**, **[davidp57](https://github.com/davidp57)** - Feedback and suggestions

[![Support via PayPal](https://www.paypalobjects.com/en_US/i/btn/btn_donate_LG.gif)](https://www.paypal.com/donate?business=RDGX965BT5MT4&no_recurring=1&item_name=Thank+you+for+choosing+this+way+to+show+your+appreciation%21+&currency_code=USD)

---

## 📋 Version Information

- [Breaking Changes Between Versions](docs/breaking-changes.md)
- [Known Issues](docs/known-issues.md)
