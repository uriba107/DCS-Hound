# Syria_POC — Hound ELINT + MOOSE + Skynet IADS Integration (Proof of Concept)

Scale proof-of-concept DCS World mission on the Syria map showing Hound ELINT operating at scale (dozens to hundreds of SAM/EWR radars) alongside MOOSE (MANTIS IADS, EASYGCICAP GCI/CAP). Based on Pikey's Syrian Air Defense 2012 template. SEAD flights spawn automatically against Hound-identified sites. **Work in progress** — see Known Issues.

## How It Runs

1. Load `Hound_Demo_SyADFGCI.miz` in DCS (Syria map required).
2. BLUE ELINT platforms (C-130s off Lebanon, COMM towers on Mt. Hermon/Mt. Meron, a Turkish site) begin sweeping RED radar emissions.
3. Hound identifies SAM/EWR sites and creates contacts. The `SITE_CREATED` event triggers SEAD spawns from the nearest of three pre-placed flight groups.
4. Meta-sector controllers (South AO / OPTIMUS, North AO / JAZZ, East AO / BUMBLEBEE) announce contacts via SRS voice on 306.000/306.500/307.000 AM. ATIS loops on sector frequencies.
5. An invincible MQ-9 near Damascus acts as bait to provoke RED radar emissions.
6. RED IADS (MANTIS by MOOSE) and GCI/CAP (EASYGCICAP by MOOSE) run autonomously. SAM availability is randomized per Pikey's template (default 75%).

## File Descriptions

| File | Lines | Role |
|------|-------|------|
| `Hound_Demo_SyADFGCI.lua` | 209 | Main mission script: SRS config, Hound setup (5 platforms, 8 sectors, 3 meta-sectors), controller/ATIS/notifier, EWR import via MOOSE as prebriefed contacts, BDA, marker management, SEAD spawn handler (MOOSE AUFTRAG/SPAWN) |
| `SydADF2012.lua` | 184 | Pikey's Syria AD 2012 template (external, not project code): SAM availability randomization (SA-2/3/6/10, EWR), MANTIS IADS (MOOSE), EASYGCICAP GCI, CAS/CAP spawning — all pure MOOSE APIs |
| `Hound_Demo_SyADFGCI.miz` | 2.8 MB | Compiled DCS mission (binary) |
| `extras/Moose.lua` | 9.3 MB | MOOSE framework (third-party, gitignored, do not edit) |

## Mission Layout

### BLUE Platforms (ELINT sensors)

| Platform | Type | Location |
|----------|------|----------|
| `Mt_Hermon_ELINT` | COMM tower (ground) | Mt. Hermon, Israel |
| `Mt_Meron_ELINT` | COMM tower (ground) | Mt. Meron, Israel |
| `ELINT_C130_south` | C-130 (maritime) | Off Lebanon coast, south |
| `ELINT_C130_north` | C-130 (maritime) | Off Lebanon coast, north |
| `ELINT_TURKEY` | Ground site | Turkey |

All transmitters route through `Mt_Meron_ELINT`.

### RED Forces (Pikey AD 2012 Template)

SAM batteries (SA-2, SA-3, SA-6, SA-10) and EWRs placed across Syria. At mission start, each SAM/EWR type is randomly reduced to `XXpc` percent (default 75%) of its full complement. Integrated via MOOSE's MANTIS IADS with EWR prefix filtering (`EWR`). GCI/CAP via MOOSE's EASYGCICAP with MiG-23, MiG-29A, Su-30 squadrons.

### Auto-SEAD Mechanics

When Hound fires `SITE_CREATED`, `HoundEventHandler:onHoundEvent` selects the nearest of three flight groups (`SEAD_NORTH`, `SEAD_WEST`, `SEAD_SOUTH`) by 2D distance to the contact. An A-10C or F-16 flight spawns with a SEAD `AUFTRAG` mission targeting the site group. Loadouts use whatever is pre-configured in the miz templates. An outText coalition message announces the fragging.

### Bait

Invincible MQ-9 in the Damascus area — intended to provoke RED SAM/EWR emissions for Hound detection.

## Dependencies

| Dependency | Bundled? | Notes |
|------------|----------|-------|
| **MOOSE** (`extras/Moose.lua`) | Yes (gitignored, 9.3 MB) | Full framework — MANTIS IADS, EASYGCICAP, AUFTRAG, SPAWN, SET_GROUP, etc. Loaded inside miz. Do not edit. |
| **Hound ELINT** | Yes (embedded in miz) | Built from `src/*.lua`. |
| **DCS-SRS** | Optional | SRS directory configured in script; all voice/ATIS uses SRS. Works without it but no audio. |

## Known Issues

- Mission is labeled as "still suffering from some issues to be resolved." This is an integration POC, not a polished release.
- SEAD spawning has a 300-second cooldown gate to prevent unbounded task accumulation — ensure this interval suits your mission pacing.
- `ELINT_TURKEY` platform is defined but its location and operational status in the miz are unverified.
- Marker cleanup behavior (Hound-controlled via `HOUND.FORCE_MANAGE_MARKERS = true`) may interact unpredictably with SEAD RTB/deletion timing.
- SRS voice provider `supertonic` with random voice selection may produce inconsistent audio quality per session.

## Comparison with Syria_HARM

`demo_mission/Syria_HARM/` is a small-scale demo with a handful of SAMs — intended for a player to fly and "feel" the system. It runs on the developer's server. This directory (`Syria_POC/`) is the scale POC: dozens to hundreds of SAM/EWR radars across the full Syria AD network, proving Hound can handle large emitter counts alongside MOOSE.
