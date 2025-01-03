# Hound ELINT System for DCS

## Overview
**Hound ELINT** is a mission script for DCS. It uses one or more assigned ELINT platforms to approximate the location of transmitting enemy radars using triangulation. Platforms are pre-assigned or dynamically assigned assets; they can be airborne, ground units, or stationary objects from a set list of available assets.

Hound presents data in several methods:
1. F10 map markers indicate the estimated position of the radar, with type and accuracy information for tactical decisions. This works best with "My AC" or "Map only" modes.
2. Hound offers a Text-To-Speech (TTS) ATIS system using SRS. This feature provides a radio channel with constantly updated information about current threats.
3. Detailed information by a "SAM controller" can be provided as TTS (via SRS) and as text messages.

The system can gather information about enemy radar deployments and help understand the tactical situation or penetrate enemy defenses. Because the system is asset-based, you also need to protect these assets, as if they are destroyed, you lose your tactical data.

Hound requires MIST and is compatible with MOOSE, Skynet IADS, High-Digit SAMs, and more.

### Video Intro (YouTube)
[![Hound Cinematic Intro Video](https://i.ytimg.com/vi/S4xxtKOqGqU/hq720.jpg?sqp=-oaymwEcCNAFEJQDSFXyq4qpAw4IARUAAIhCGAFwAcABBg==&rs=AOn4CLAAa-SdnDgNiWTKc0YNSvm5RRMa7g)](https://www.youtube.com/watch?v=S4xxtKOqGqU)


Table of Contents
=================

* [Hound ELINT System for DCS](#hound-elint-system-for-dcs)
  * [Overview](#overview)
    * [Video Intro (YouTube)](#video-intro-youtube)
* [Full Documentation](#full-documentation)
* [Adding Hound to a Mission](#adding-hound-to-a-mission)
  * [Required External Scripts](#required-external-scripts)
    * [Adding Scripts in Mission Editor](#adding-scripts-in-mission-editor)
    * [Some Screenshots as Hints](#some-screenshots-as-hints)
  * [Minimum Hound setup](#minimum-hound-setup)
    * [Basic Hound setup (YouTube)](#basic-hound-setup-youtube)
  * [Advanced config](#advanced-config)
  * [Available assets](#available-assets)
    * [Airborn assets](#airborn-assets)
      * [Airplanes](#airplanes)
      * [Helicopters](#helicopters)
      * [Community Mods](#community-mods)
    * [Ground Units](#ground-units)
    * [Static Objects](#static-objects)
  * [On\-screen Debug](#on-screen-debug)
* [Deep Dive](#deep-dive)
  * [Hound Structure](#hound-structure)
  * [Instance initialization](#instance-initialization)
  * [Platforms](#platforms)
  * [Activate Hound](#activate-hound)
    * [Handling Pre\-briefed Contacts](#handling-pre-briefed-contacts)
* [Global and per instance Settings](#global-and-per-instance-settings)
  * [Per\-instance Settings](#per-instance-settings)
    * [Map Markers](#map-markers)
      * [Living with Other Marker Spawning Scripts](#living-with-other-marker-spawning-scripts)
    * [Platform Position Errors](#platform-position-errors)
    * [DBA reports](#dba-reports)
    * [Launch Alerts](#launch-alerts)
    * [Reposition The Controller radio menu](#reposition-the-controller-radio-menu)
    * [DCS callsign overrides](#dcs-callsign-overrides)
  * [NOTE: Be cautios when using a callsign override wildcard with Dynamic slots without a template\. As aircraft might spwan with the wildcard DCS callsign and a random group name](#note-be-cautios-when-using-a-callsign-override-wildcard-with-dynamic-slots-without-a-template-as-aircraft-might-spwan-with-the-wildcard-dcs-callsign-and-a-random-group-name)
    * [NATO callsigns](#nato-callsigns)
    * [NATO Lowdown](#nato-lowdown)
    * [ATIS update interval](#atis-update-interval)
    * [System timers Intervals](#system-timers-intervals)
  * [Sectors](#sectors)
    * [Managing sectors](#managing-sectors)
    * [Sector configuration](#sector-configuration)
      * [Text messages](#text-messages)
      * [TTS transmissions](#tts-transmissions)
      * [Zones](#zones)
      * [Transmitter](#transmitter)
      * [Callsigns](#callsigns)
* [Communication](#communication)
  * [ATIS system](#atis-system)
    * [additional settings](#additional-settings)
  * [SAM controller](#sam-controller)
    * [Additional settings](#additional-settings-1)
    * [Controller message format](#controller-message-format)
  * [Notifier](#notifier)
  * [Text\-To\-Speach configuration](#text-to-speach-configuration)
    * [STTS settings](#stts-settings)
    * [MOOSE\.MSRS settings](#moosemsrs-settings)
    * [gRPC\.tts settings](#grpctts-settings)
* [Event handlers](#event-handlers)
  * [Available events](#available-events)
* [Appendix](#appendix)
  * [Performance Tuning](#performance-tuning)
  * [Exports](#exports)
    * [LUA Export](#lua-export)
      * [Site export](#site-export)
      * [Contacts export (legacy)](#contacts-export-legacy)
    * [CSV export](#csv-export)
  * [Desanitize DCS Scripting Engine](#desanitize-dcs-scripting-engine)
* [Known Issues](#known-issues)
* [Breaking changes](#breaking-changes)
  * [0\.1\.X to 0\.2\.X](#01x-to-02x)
  * [0\.2\.X to 0\.3\.X](#02x-to-03x)
  * [0\.3\.x to 0\.4\.x](#03x-to-04x)
* [Special thanks](#special-thanks)

# Full Documentation
For those fimiliar with Hound and looking for a cheat sheet or just q quick reference (and some scripting ideas).
If you are new to Hound, you might benifit more from the more detailed explenations in this document.

  * [Main script Documentation](https://uriba107.github.io/DCS-Hound/) - all the options available for the average mission builder, even those I didn't write here
  * [Developers Documentation](https://uriba107.github.io/DCS-Hound/dev_docs/) - this is actually everything. You don't need this unless you intend to hack your way to glory.
  * [Scripting Ideas](SCRIPTING_IDEAS.MD) - A random bunch of scripting ideas. Most are half-baked and not working, They are here to inspire. feel free to suggest more via an issue or Pull-Request.

# Adding Hound to a Mission
***If upgrading from a previous version of Hound, please see [Breaking Changes](#breaking-changes).***

The Hound system triangulates the positions of radars. It does this by taking bearing readings at set times while recording the platform position. Using these plotted data points, the system can estimate the position. The more points you have, with greater intersection angles between them, there is a better chance of estimating the position correctly. You will never get a perfect "hit," but you may be able to get a position within a 200-meter radius, where you can use other sensors to pinpoint the location for a strike or know where you need to avoid flying.

Only specific units are ELINT capable. To get the best positional accuracy, you want your best precision platforms positioned as close as possible and as high as possible. Remember, the higher you go, the longer you can see, simple physics.

Placing two C-17s in a race-track holding pattern at 30,000 ft can get you positional data on radars more than 200 nm away, though not the best accuracy, of course. Using a Comms Tower placed on a high mountain will provide a very accurate baseline on which aircraft data can be triangulated. However, tall mountains are not very common, and clear line-of-sight is a thing.

Helicopters may be of some use, but they can, using existing mission scripts, transport ground units to tall mountains deep inside enemy territory. The same goes for fast movers like the Viggen, F-16, JF-17, or the Su-25T. They can dash into enemy territory and help you find the radars trying to hide.

Remember that the system is using simulated DF to determine the bearing of the radar from the platform. Low-precision systems will cause the calculated position to be within a higher ellipse of uncertainty for radar position. Below you can find the list of working units and their sensor precision.

The resolution of platforms is derived from antenna size and emitter frequency. A shout-out to [TLTeo](https://forum.dcs.world/profile/66270-tlteo/) for explaining the physics of this.

Hound currently has a 10-degree angular resolution cutoff point to avoid introducing "bad data." The first band that is valid for a platform is denoted in the `Minimum Band` column.

```Note: While currently not implemented, the intention of including both the Viggen and the Su-25T is that they will only be able to participate if they are carrying their ELINT pods.```

## Required External Scripts
Starting from version 0.4.1 Hound no longer require [MIST](https://github.com/mrSkortch/MissionScriptingTools/releases/latest) as a dependency. Thanks to @mrSkortch, all required mist functions were incorporated into HOUND.

Optional scripts required for TTS (only one of them is required, based on your preference):
- [DCS-SimpleTextToSpeech (by Ciribob)](https://github.com/ciribob/DCS-SimpleTextToSpeech)
- [MOOSE.MSRS](https://flightcontrol-master.github.io/MOOSE_DOCS_DEVELOP/Documentation/Sound.SRS.html)
- [DCS-gRPC](https://github.com/DCS-gRPC/rust-server)


For installation of STTS or DCS-gRPC, please consult the project of choice repo. Both require you to modify "DCS World/Scripts/MissionScripting.lua".

For more information on the de-sanitization process, look [here](#desanitize-dcs-scripting-engine).

### Adding Scripts in Mission Editor
```Note: The order of scripts - it's important.```  
On a "ONCE" type action with a "time more 1" condition, add the scripts in the following order:
1. `MIST`
2. `DCS-SimpleTextToSpeech` (if TTS via STTS is desired - gRPC is implemented globally. If the mission includes the MOOSE Framework, it includes STTS internally)
3. `HoundElint.lua`

### Some Screenshots as Hints
![Add Scripts](/images/hound_setup.jpg)


## Minimum Hound setup
---
The bare minimum, with more customization options available.
```lua
do
  Elint_blue = HoundElint:create(coalition.side.BLUE)
  Elint_blue:addPlatform("NAME_OF_UNIT_1")
  -- it's recommended to have at least two active platform to make system faster and more accurate
  Elint_blue:addPlatform("NAME_OF_UNIT_2")
  Elint_blue:systemOn()
  -- This is a basic setup with map markers only
  -- additional stuff (uncomment if desired)
  Elint_blue:enableController() -- This will enable Voice+text controller messages
  -- Elint_blue:enableAtis() -- ATIS requires STTS/GRPC, as it is voice only
end
```

### Basic Hound setup (YouTube)
[![Hound mission editor video](https://i.ytimg.com/vi/gmJmFR7UCfo/hqdefault.jpg)](https://www.youtube.com/watch?v=gmJmFR7UCfo)

## Advanced config
This is an example of a more complex configuration.
There is more drill down further ahead in the document, so some settings may not be immediately clear. 

More examples are available in the [demo missions](./demo_mission/).
```lua
    HoundBlue = HoundElint:create(coalition.side.BLUE)
    HoundBlue:addPlatform("ELINT North") -- C-130
    HoundBlue:addPlatform("ELINT South") -- C-130
    HoundBlue:addPlatform("ELINT Galil") -- C-130
    HoundBlue:addPlatform("ELINT HERMON") -- Ground Station
    HoundBlue:addPlatform("ELINT MERON") -- Ground Station

    HoundBlue:addSector("Lebanon")
    -- HoundBlue:addSector("North Syria")
    -- HoundBlue:addSector("South Syria")

    local controller_args = {
        freq = "251.000,122.000,35.000",
        modulation = "AM,AM,FM",
        gender = "male"
    }

    local atis_args = {
        freq = "253.000,124.000",
        modulation = "AM,AM"
    }

    HoundBlue:enableController("Lebanon",controller_args)
    HoundBlue:enableAtis("Lebanon",atis_args)
    HoundBlue:enableNotifier("default")

    HoundBlue:setTransmitter("all","ELINT MERON")
    HoundBlue:enableText("all")

    HoundBlue:setZone("Lebanon","Sector_Lebanon")

    HoundBlue:setMarkerType(HOUND.MARKER.POLYGON)
    HoundBlue:enableMarkers()
    HoundBlue:enableBDA()
    HoundBlue:systemOn()
```

## Available assets
### Airborn assets
#### Airplanes
---
| Platform  | Accuracy Deg. (C/H Bands)| Min. Band | Remarks |
| --------  | ----------- | - | - |
| C-130     | 0.65 / 0.07 | A ||
| C-17      | 0.57 / 0.06 | A | Stand-in for RC-135 |
| An-30M    | 0.92 / 0.10 | A ||
| Tu-95     | 0.46 / 0.05 | A ||
| Tu-142    | 0.46 / 0.05 | A ||
| IL-76MD   | 0.60 / 0.06 | A ||
| H-6J      | 6.54 / 0.70 | C | Fantasmagoria |
| Su-24M    | 6.54 / 0.70 | C | Fantasmagoria | 
| Su-24MR   | 5.09 / 0.55 | C | Tangazh |  
| C-47      | 1.91 / 0.20 | A ||
| S-3B      | 1.59 / 0.17 | A ||
| E-2D      | 6.54 / 0.70 | C ||
| E-3A      | 5.09 / 0.55 | C ||
| An-26B    | 0.98 / 0.10 | A ||
| A-50      | 5.09 / 0.55 | C ||
| Viggen    | 5.09 / 0.55 | C | U22 |
| Su-25T    | 6.54 / 0.70 | C | Fantasmagoria |  
| Su-25TM   | 6.54 / 0.70 | C | Fantasmagoria |  
| JF-17     | 7.05 / 0.76 | C | KG-600 SPJ |
| F-16C     | 15.79 / 1.69| D | Block 50 w/HTS |
| Mirage F1 |  6.19 / 0.66  | C | Cyril pod |

<sup>*</sup> Data with angular resolution below 10 deg is rejected. That is a rudimentary way to drop very bad data.
  
#### Helicopters
---
| Platform  | Accuracy Deg. (C/H Bands)| Min. Band |
| --------  | ----------  | - |
| CH-47D    | 1.91 / 0.20 | A |
| CH-53E    | 2.29 / 0.25 | A |
| MIL-26    | 1.15 / 0.12 | A |
| UH-60A    | 2.86 / 0.31 | B |
| SH-60B    | 2.86 / 0.31 | B |
| Mi-8MT    | 2.86 / 0.31 | B |
| UH-1H     | 5.73 / 0.61 | C |
| Ka-27     | 5.73 / 0.61 | C | 

#### Community Mods
| Platform  | Accuracy Deg. (C/H Bands)| Min. Band |
| --------  | -------- | -------- 
| Anubis C-130J | 0.65 / 0.07 | A |
| EF-18G (CJS)   |  1.64 / 0.18  | A |
| VSN EA-6B Prowler   |  2.54 / 0.27  | B |
| UH-60L    | 2.86 / 0.31 | B |
| RC-135W (SSS)   |  0.57 / 0.06  | A |
| EC-130H (SSS)   |  0.65 / 0.07 | A |
| P-3C (MAM)   |  0.92 / 0.10  | A |
| P-8A (CLP)   |  0.65 / 0.07  | A |
| TU-214R (CLP)  |  0.57 / 0.06  | A |
| Shavit (IDF)   |  0.76 / 0.08  | A |

### Ground Units
| Platform  | Accuracy Deg. (C/H Bands) | Min. Band |
| --------  | --------    | - |
| SPK-11    | 1.53 / 0.16 | A |
| SAM Patriot CR | 1.53 / 0.16 | A | 

### Static Objects
| Platform  | Accuracy Deg. (C/H Bands) | Min. Band |
| --------  | --------  | --------  |
| Comms tower M | 0.21 / 0.02 | A |
| Command Center | 0.37 / 0.04 | A |
| TV Tower | 0.10 / 0.01 | A |

## On-screen Debug
When this setting is enabled, Hound will print a short status report after each update cycle. (every ~15 seconds by default)
it is controlled by the `onScreenDebug` function. this output is disabled by default
```lua
-- to enable
    HoundBlue:onScreenDebug(true)
-- to disable
    HoundBlue:onScreenDebug(false)
```

# Deep Dive
## Hound Structure
Hound is composed of several elements that work together:

* **HOUND** - the global entity created by loading the script
  * **Global Settings**: Settings that affect all instances running (e.g., TTS engine to use, number of data points, contact timeout, etc.).
  * **[HoundInstance](#instance-initialization)** - the basic working component. You can define multiple instances, but only one is required per coalition.
    * **[Settings](#per-instance-settings)** - Each HoundInstance has a set of settings specific to it and not shared between instances (unlike global settings).
    * **[Platforms](#platforms)** - Units from the [assets list](#available-assets) that will collect information. They can be added and removed at any time.
    * **Contacts** - Radars detected by the system.
    * **[Sectors](#sectors)** - A logical grouping of control elements. An instance can have multiple sectors.
      * [Zone](#zones) - Geographic zone defining the sector borders (Optional).
      * [Controller](#sam-controller) - Main interaction point for the user. It will provide text and TTS information on radars in the sector.
      * [ATIS](#atis-system) - Automated repeating TTS-only summary of all contacts in the sector.
      * [Notifier](#notifier) - Automated TTS-only alerts provider. It will duplicate the alerts sent by the controller to increase situational awareness of players not listening on the controller frequency.
  * **HoundInstance** - A second instance for the other team if needed.
  * **[EventHandler](#event-handlers)** - Hound event handler (global).
  
## Instance initialization
To initialize a Hound instance, we first create it. Upon creation, a Hound instance must have a coalition assigned. This can be done in several ways:
```lua
    -- direct coalition assignment
    HoundInstance = HoundElint:create(coalition.side.BLUE)
```
This creates an instance without any platforms.

Alternatively, you can create a Hound instance with an initial platform. The coalition will be taken from the unit assigned. Hound adds units by using their names (or pilot name) not by a group name.

```lua
    -- create with platform (static object in this case)
    HoundInstance = HoundElint:create("Migariya_Elint")
```
## Platforms
Platforms can be added at any time, before or after system activation.
```lua
    HoundInstance:addPlatform("ELINT_C17")
```
And if needed, the opposite is also available.

```lua
    HoundInstance:removePlatform("ELINT_C17")
```

Please make sure you go over the [available assets list](#available-assets) to determine what would work best for your mission.

## Activate Hound

That's it! All you need to do now is to activate the system.

```lua
    HoundInstance:systemOn()
```
Once activated, the system will use all available platforms to locate transmitting radars. Information about these radars is updated periodically on the F10 map.

` Note: during this first implementation, markers are updated every 2 minutes`

You can, of course, turn it off for any reason with:

```lua
    HoundInstance:systemOff()
```

### Handling Pre-briefed Contacts

In some cases, you would want to always provide accurate positional information on a contact, for example, a stationary SAM site for which you provided strike coordinates in the briefing. You can sync Hound to use the actual unit data as position. The contact will be treated as "Pre-Briefed" and will not update its position like the others. However, if a pre-briefed contact moves more than 100m from its original position, and is detected by Hound in its shifted location, the special "pre-briefed" flag will be removed, and the radar will be processed as a normal contact from that point on.

You can mark a unit or group as pre-briefed. Only valid Hound radars will be added (it will not add units it will not normally track). If a group is passed and it contains more than one valid radar, all of the radars will be added.

In addition, you can provide an optional "code name" for a pre-briefed site, which will be its name in reports and in the comms menu.


```lua
    HoundInstance:preBriefedContact('UNIT_NAME')
    HoundInstance:preBriefedContact('GROUP_NAME')
    HoundInstance:preBriefedContact('GROUP2_NAME',"ANTELOPE")
```
---
# Global and per instance Settings

## Per-instance Settings
These are settings that are configurable per Hound instance.

### Map Markers

Hound uses Map markers to indicate the estimated position of the tracked radar. It's a product of the system and only contains data the user can get from the system in other ways (equivalent to making marks on a paper map).

Map markers are enabled by default. Additionally, if a radar goes offline, the marker fill will fade slowly over time until it reaches a minimum value on contact timeout (the time in which all past contact data points are deleted).

However, some mission designers may want to disable the markers.
```lua
    HoundInstance:disableMarkers()
```
They can be turned back on with:
```lua
    HoundInstance:enableMarkers()
```
Hound supports a few different marker types for the uncertainty ellipse that can be selected. The type of marker is set per Hound instance.

```lua
    HoundInstance:setMarkerType(HOUND.MARKER.POLYGON)
```
You can save a line and change the marker type while enabling the markers:
```lua
    HoundInstance:enableMarkers(HOUND.MARKER.POLYGON)
```

The available marker types are:

|  HOUND.MARKER | Description |
| ---- | ------------|
| NONE | Nothing is drawn |
| SITE_ONLY | only draw site markers |
| POINT | Draw position marker for radars (and Site markers)
| CIRCLE | a circle of uncertainty will be drawn (Default) |
| DIAMOND | a diamond will be drawn with 4 points representing uncertainty ellipse |
| OCTAGON | an ellipse will be drawn with 8 points (diamond with midpoints) |
| POLYGON | an ellipse will be drawn as a 16-sided polygon |

`NOTE: More points cause higher CPU usage. CIRCLE is the default.`

In addition to the radar markers, there is an additional simpler site marker. The site marker only adds the site designation and current SAM classification. It is used in conjunction with the Map markers to help locate the radar you want in the menu system.

The site markers are enabled by default and are disabled separately from the normal map markers.

```lua
    HoundInstance:disableSiteMarkers()
    HoundInstance:enableSiteMarkers()
```

#### Living with Other Marker Spawning Scripts

Hound does its best to play nice with other Marker-generating scripts. If MOOSE is loaded, Hound will default to using `UTILS.GetMarkID()` to get the next marker ID. If that is not available and MIST is in version 4.5 and above, Hound will attempt to use MIST's `mist.marker.getNextId()` method. If none of those options is available, it will use an internal counter to track mark IDs.

If for any reason you still encounter issues, you can force Hound to use the internal counter by setting  `HOUND.FORCE_MANAGE_MARKERS` to true.
```lua
HOUND.FORCE_MANAGE_MARKERS = true
```

By default, the internal counter starts from 10,000. You can change the initial value to avoid conflicts with other numbering things (which are not MOOSE or MIST) by using the method `HOUND.Utils.setInitialMarkId()`. As mentioned earlier, if MOOSE or MIST v4.5 are present, their numbering engine will take priority over Hound's internal numbering. It is highly recommended that you use one of them (or `HOUND.Utils.getMarkId()`) for all other scripted Map markers.

In addition to all that, Hound will only delete its own markers (by tracking every Marker ID it's placing).

---
### Platform Position Errors

The position of the platform is a baseline used for triangulation. In the real world, however, the position on the platform is always inaccurate. Older aircraft have INS systems that drift over time unless updated periodically, while newer aircraft have a less "drifty" system updated automatically from GPS.

To simulate this, you can enable position errors. When this setting is enabled, a random error is introduced to the platform's position when stored.
```lua
    HoundInstance:enablePlatformPosErrors()

    -- disable (default)
    HoundInstance:disablePlatformPosErrors()
```
---
### DBA reports

By default, the [Controller](#sam-controller)](#sam-controller) and [Notifier](#notifier) will push alerts when a radar is destroyed when the track is dropped.
you may choose to disable this behavior
```lua
    HoundInstance:disableBDA()

-- enable (default)
    HoundInstance:enableBDA()

-- get current value
local bool = HoundInstance:getBDA()
```

This setting only affects the automatic marking of dead contacts. you can manually mark a contact as dead (and notifications will be transmitted) regardless of BDA settings.  
To mark a contact as dead use ```HoundInstance:markDeadContact(radarUnit)``` see [extended docs](#more-docs) for more information.

---
### Launch Alerts
In past conflicts, ELINT platform would issue a SAM launch alerts on comms to improve situational awareness of aircraft in the battle space. 
Hound can issue these alerts with the [Controller](#sam-controller)](#sam-controller) and [Notifier](#notifier). By default this is disabled on Hound
You may choose to enable this feature
```lua
    -- Enable
    HoundInstance:setAlertOnLaunch(true)

    -- Disable (default)
    HoundInstance:setAlertOnLaunch(true)

    -- get current value
    HoundInstance:getAlertOnLaunch()
```

---

### Reposition The Controller radio menu

By default, the [Controller](#sam-controller) will generate the "ELINT" root menu in the base F10 menu.
You may choose to change this to a different base location in some cases.  

```lua
-- target menu MUST be created BEFORE it's assigned to Radio menu
    SuperDuperMenu = missionCommands.addSubMenuForCoalition(coalition.side.BLUE,"Fantastic functionality")

-- it is highly recommended to set the new parent menu BEFORE calling enableController (but can be after configureController if called separately). 
-- If set after "enableController()" is called, in some cases a user will be required to retake his slot.
    HoundInstance:setRadioMenuParent(SuperDuperMenu)

-- after parent has been assinged you can enable controller
    HoundInstance:enableController()
```
---
### DCS callsign overrides
The menu system uses user callsigns in responses. DCS has a limited set of callsigns, but a mission designer may wish to use custom callsigns.
Hound supports 3 types of callsigns in this order
`Manually set override` > `Overlord style user selected` > `default DCS`

```lua
    -- Use callsign "Tulip" to all flights set to Uzi
    -- '*' is a reserverd case. every formation with '*' callsign used will be group name. useful if you plan to have multiple overrides and limited number of DCS callsignes
    local callsignOverride = {
        Uzi = "Tulip",
        Enfield = "*"
    }
    HoundInstance:setCallsignOverride(callsignOverride)
```

`NOTE: Be cautios when using a callsign override wildcard with Dynamic slots without a template. As aircraft might spwan with the wildcard DCS callsign and a random group name`
---
### NATO callsigns
[Sectors](#sectors) get automatically assigned [callsigns](#callsigns). The callsignes are picked from a pool of names. However, there is an alternate list, taken from callsigns used by RC-135 squadrons. To use this alternate callsign list by default, you'll need to set the following.
```lua
-- enable use of alternate pool
    HoundInstance:useNATOCallsignes(true)
-- disable this setting (return to use default pool)
    HoundInstance:useNATOCallsignes(false)
```
---
### NATO Lowdown
The [ATIS system](#atis-system) has two modes, Normal and NATO lowdown, the same report in both will look slightly different.
In the Normal default format, ATIS will also call out radar names and Grid positions.  
`Straight Flush 17, grid GG20, accuracy very high`

it is possible to switch it to NATO LOWDOWN format.  
`6, ACTIVE, BULLSEYE 012 13, accuracy very high`

This change is global and performed via the use of the following:
```lua
-- enable Lowdown
    HoundInstance:enableNATO()
-- disable lowdown (revert to default)
    HoundInstance:disableNATO()

-- get current setting
    local bool = HoundInstance:getNATO()
```
---
### ATIS update interval
The [ATIS system](#atis-system) by default will generate a new message every 5 minutes. you can change the update rate if desired.
```lua
-- pass desired update interval in seconds
    HoundInstance:setAtisUpdateInterval(120)

-- Default setting is
    HoundInstance:setAtisUpdateInterval(5*60)
```
---
### System timers Intervals
Hound works with multiple timers that will control the frequency of internal tasks. The four timers and their default values are:
  * scan: 5s
  * process: 30s
  * menus: 60s
  * markers: 120s

`scan` controls the interval in which platforms are tested against radars and data points are added.  
`process` is the position calculation interval.  
`menus` is the interval in which the comms menus will be computed.  
`markers` is the interval in which all map markers will be updated.  
you can change the default value if you wish by passing the interval name and new value.
this is normally done to tune performance impact. 

for example: increasing the scan interval to 20 seconds and the process interval to 60 seconds might help when a very large number of radars are present in the missions and there is suspicion Hound is the cause.

```lua
HoundInstance:setTimerInterval("display",180)
```

---
## Sectors
Sectors are the next big building block of Hound. 
Introduced in 0.2 this aims to solve a problem in large servers. in the past, there was only one "default" sector that everyone contacted for information. In practice, in large missions, it was just unmanageable. 

A "Sector" is a named object that manages communication with players. each sector is assigned a name and a callsign.
when initilizing Hound a "default" sector is created with the callsign "HOUND". when not passing any sector name argument, the "default" sector is the sector that would be affected.

A Sector can be geofenced, if such geofencing is set (more on this later) only radars in and around the sector will be reported. see more under [Zone management](#zones)

There are two reserved sector names:
  * `default` - default sector name created with hound instance. it cannot be removed and some features such as geofencing are not available on it
  * `all` - all sectors. some settings can be changed across all sectors using the "all" keyword. "All" is only available on generic config functions.

### Managing sectors
The most basic command is to add a sector. you will need to provide a name for the sector (not a callsign), this name will be used in the comms menu for example. so you can make it human-descriptive or match your SOP.

```lua 
-- Sector name must be provided
-- here are a few random examples
    HoundInstance:addSector("Sukhumi")
    HoundInstance:addSector("Abkazia")
    HoundInstance:addSector("North Syria")
    HoundInstance:addSector("RANGE 13")
```
You can request a list of all sector names
```lua
    HoundInstance:listSectors()
```

or if for some bizarre reason, you would like to remove a sector
```lua
    HoundInstance:removeSector("sectorName")
``` 

### Sector configuration
Sectors have a few options worth knowing.
#### Text messages
By default, Hound will only broadcast using SRS. You can optionally enable Text messages of all controller messages (ATIS and notifier will remain Voice only). Text notification will only show up for groups that are currently checked in with a controller. enable and disable is per-sector
```lua
    HoundInstance:enableText("sectorName")
    HoundInstance:disableText("anotherSector")
```
or to all of them using the "all" keyword
```lua
    HoundInstance:enableText("all")
```
#### TTS transmissions
Hound is primarily built to use Text-to-speech messages to communicate. However if for any reason you wish to disable this feature. (which is strictly enabled by default)
you can use the following
```lua
    HoundInstance:disableTTS("sectorName")
-- to re-enable
    HoundInstance:enableTTS("sectorName")
```
or to all of them using the "all" keyword
```lua
    HoundInstance:disableTTS("all")
```
#### Zones
Geofencing a sector will be achieved by assigning a "Zone".
There are two valid polygon inputs to the Sector.
  * Draw tool freeform polygon
  * DCS Group waypoints (standard method - best practice is to use a late activation helicopter group)

it is then added to the sector using the following:
```lua
    HoundInstance:setZone("sectorName","drawToolPolygon")
    -- or 
    HoundInstance:setZone("sectorName","GroupName")
```
if both polygon and group share the same name. Polygon will take precedence. 

There is also a special case, if "sectorName Sector" is a valid draw polygon you can use it without passing any arguments.
```lua
    -- This will try and use a polygon called "sectorName Sector" if one exists.
    HoundInstance:setZone("sectorName")
```

You can also get the currently set zone on the sector (nil means no zone is set)
```lua
    HoundInstance:getZone("sectorName")
```

To remove a zone from sector use:
```lua
    HoundInstance:removeZone("sectorName")
```

#### Transmitter
A sector can have a transmitter that will broadcast all the TTS messages for the sector.
Once a transmitter is set, the transmitter position will be used, forcing line-of-sight, maximum radio range and any other limitations and effects the TTS provider enforces.
when no transmitter is assigned, everyone on the frequency will be able to hear the transmissions, without any limitations, a "Magic Satlink" if you wish.

If the transmitter unit is destroyed, no TTS transmissions will occur until a new transmitter is assigned.

you can also remove the transmitter at any time to return to the default "Magic Satlink" state.
The transmitter can be a Unit or a static object, and it's called by Unit/Pilot name
```lua
    HoundInstance:setTransmitter("sectorName","AWACS_Unit")
```

Remove a transmitter is done using:
```lua
    HoundInstance:removeTransmitter("sectorName")
```

you can also use the "all" keyword to apply the transmitter to all sectors
```lua
    HoundInstance:setTransmitter("all","GCI_bunker")
```
#### Callsigns
each sector has a randomly assigned callsign. these callsigns are selected from a pool of callsigns.
you can get currently assigned callsign using 
```lua
local assignedCallsign = HoundInstance:getCallsign("sectorName")
```

If you wish you can also assign a new callsign
```lua
-- choose random callsign from the "generic" pool (default behaviour, not need to use this)
    HoundInstance:setCallsign("sectorName")

-- assign the callsign "CALLSIGN" to the sector "sectorName"
    HoundInstance:setCallsign("sectorName","CALLSIGN")
```
there are two callsign pools, one is generic the other is a list of callsignes for RC-135s in the USAF. 
if you with for a specific sector to use a callsign from the NATO list you can call
```lua
    HoundInstance:setCallsign("sectorName",true)
-- or
    HoundInstance:setCallsign("sectorName","NATO")
```
if you want ALL sectors to use callsigns from this pool there is a global setting for this. See [Global settings -> NATO callsigns](#nato-callsigns)

---
# Communication
---
In addition to the map markers described above. Hound is utilizing Text-To-Speech to provide the player with information via SRS.
The three communication types are:
  * Automated Information System [ATIS system](#atis-system)
  * User-interactable [SAM controller](#sam-controller)
  * Alert Agency dubbed [Notifier](#notifier)

they are all configurable as will be described in the [Text-To-Speach configuration](#text-to-speach-configuration) segment below.

## ATIS system
---
The Automated Tactical Information System (ATIS). Will provide an automated information message loop on a set frequency.
The default frequency for ATIS is 250.500 AM.
This feature can be activated in the default sector with default config using:
```lua
    HoundInstance:enableAtis()
```
and turned off with
```lua
    HoundInstance:disableAtis()
```
this however is just the very very basic way to configure it and will only affect the "default" sector.
The better way to use it would be to enable it on a non-default [sector](#sectors)
```lua
    HoundInstance:enableAtis("Lebanon")
    HoundInstance:disableAtis("Lebanon")
```
However, having all the ATIS in all the sectors broadcast on the same frequency isn't really useful. so you can pass [a configuration](#text-to-speach-configuration) table then enable
```lua
    HoundInstance:configureAtis("Sukhumi",atis_conf)
    HoundInstance:enableAtis("Sukhumi")
```
or you can pass the configuration on enable
```lua
    HoundInstance:enableAtis("Sukhumi",atis_conf)
```

### additional settings
  * ATIS by default will not report EWR radars as threats, but will only notify you of their presence (and how many of them are tracked in the sector). If for some reason you prefer to get a normal brief on them as well you can enable it using the following:
```lua
    HoundInstance:reportEWR("Sukhumi",true)
-- disable again with
    HoundInstance:reportEWR("Sukhumi",false)

-- and set for all of them with
    HoundInstance:reportEWR("all",true)
```
  * NATO Lowdown format is available as a global setting. see [Global Settings -> NATO Lowdown](#nato-lowdown)
  * Changing the ATIS update interval is available via global settings. see [Global Settings -> ATIS update interval](#atis-update-interval)
## SAM controller
---
The SAM controller is the main user interface with the system. Via the F10 menu, you can request detailed information about specific tracked radars. the controller defaults to 250.00 AM

basic enable is done via 
```lua
    HoundInstance:enableController()
```

as with the ATIS, it's recommended to activate on a non-default sector and pass [configuration](#text-to-speach-configuration):
```lua
    HoundInstance:configureController("Saipan",controller_config)
    HoundInstance:enableController("Saipan")
```
or the one-liner form:
```lua 
    HoundInstance:enableController("Saipan",controller_config)
```
A controller can be disabled by calling: 

```lua
    HoundInstance:disableController()
    --- or the named sector
    HoundInstance:disableController("Saipan")
```
 ### Additional settings
 By default, a controller will alert you on new radars detected and on dead emitters.
 you can disable all controller alerts (does not affect the [Notifier](#notifier)).
 ```lua
    HoundInstance:disableAlerts("Sukhumi")
-- enable again (default behaviour)
    HoundInstance:enableAlerts("Sukhumi")

-- and set for all of them with
    HoundInstance:disableAlerts("all")
```

By default, the controller will provide you with MGRS in 10 digits format (5 for easting and 5 northing).
this is set by a global variable 
you can override this to get different precision (i.e 3 will give you 6 digits MGRS)  
```lua
    HOUND.setMgrsPresicion(3)
```

 ### Controller message format
 The controller has a fixed message structure as follows.
   * Radar UID (unique for every radar)
  * Roughly WHEN this radar was last seen
  * Roughly WHERE this radar is (using bullseye)
  * Roughly HOW ACCURATE the system is estimating the solution to be
  * Precise estimated position - using LL (repeated twice for readback/VR)
  * Precise estimated position - using MGRS
  * Elevation of Radar above sea level (in 50ft increments)
  * Extended uncertainty ellipse information (Major axis, Minor Axis, rotation of major axis)
  * Extended Tracking time information (How long is tracked, when last seed)

This Reads like this:
 ```
 <Radar Type> <Radar UID>, [Active/Recent/stale etc.] at Bullseye XXX YY, accuracy [Very High/High/Medium/Low etc.], 
 position <LL in Aircraft format>, I repeate <LL in Aircraft format>,
 MGRS <MGRS with HOUND.MGRS_PRECISION>,
 elevation XXXX feet MSL,
 ellipse is XX by YY, aligned bearing ZZ,
 Tracked for XX [minutes/seconds], last seen YY [minutes/seconds] ago.
 ```

An advanced users who wish to change this structure, this can be done in several ways.
If you are satisfied by only suppressing the Extended uncertainty and the Extended Tracking time info you can do so by invoking `HOUND.showExtendedInfo()` function. This will have an effect globally.
```lua
  HOUND.showExtendedInfo(false)
```
If a more extensive change is desired, The recommended way to achieve it is to `COPY` the `HOUND.Contact.Emitter:generateTtsReport` and `HOUND.Contact.Emitter:generateTextReport` functions from `src/311 - HoundContact_comms.lua` file in this repo to a new file. In that new file perform the changes you want. To activate load the new file to the mission using `Do script file` **AFTER** the main Hound script is loaded. this will replace the original implementation without editing the original file. allowing a simpler upgrade to newer Hound versions without losing your changes.  

 ## Notifier
 ---
 This, as the name suggests is a notification-only agent. It functions independently of the controller or ATIS and will only report a pop-up, and if enabled, radar destruction alerts. this is intended to be operated on a different frequency than the controller (which has the same alerting capacity). This may be used for improving SA on Air-To-Air frequency or on general strike channels.
 
 Notifier has a special case when used under the "default" sector and when the radar is inside a geofenced sector. In this scenario, the notifier will report using sector name rather than with location. for example:
  * Normal: `Attention All Aircraft! This is HOUND. New threat detected! Straight flush 11 is now Alive, bullseye XXX YY, Grid ZZ 1 4.`<br>
  * Special case: `Attention All Aircraft! this is HOUND. New thread detected! Straight` flush 11` is now Alive in Bander Abbas.`

  by default, the notifier will broadcast on 243.000AM and 121.500AM, the Guard frequencies. It also accepts [TTS configuration](#text-to-speach-configuration).

  Example snippets:
  ```lua
    -- enable on default sector with default settings
    HoundInstance:enableNotifier()
    -- enable with custom config on seperate sector
    HoundInstace:enableNotifier("Bander Abbas",notifier_config)

    -- configure and set frequency inline without enabling
    HoundInstace:configureNotifier("Qeshem",{freq=254,modulation="AM",gender="male"})
    -- remove Notifier from sector
    HoundInstace:removeNotifier("Homs")
  ```

## Text-To-Speach configuration
---
Obviously, you may want to tweak the radio to better work for your mission.
this can be done using an arguments table and passing it to the configuration function.

possible settings are slightly different based on your TTS provider of choice.

by default, Hound is using STTS. However it does support gRPC, and will fallback to use it if STTS is not present.

You can supply explicit order or completly disable one TTS engine or the other. To do that you need to modify a global variable.

```lua
  HOUND.TTS_ENGINE = {'STTS','GRPC'} -- this is the default value
```

### STTS settings
```lua
        args = {
            freq = 250.000,
            modulation = "AM", -- optional
            volume = "1.0", -- optional
            speed = <speed> -- number default is 0/1 for controller/atis. range is -10 to +10 on windows TTS. for google it's 0.25 to 4.0
            gender = "male"|"female",
            culture = "en-US"|"en-UK" -- (any installed on your system)
            googleTTS = true/false -- use google TTS (requires additional STTS config)
        }
```
### MOOSE.MSRS settings
```lua
    args = {
        freq = {3.0,255.0}
        modulation = {radio.modulation.FM,radio.modulation.AM}
        
    }
```
### gRPC.tts settings
```lua
        args = {
            freq = 250.000,
            speed = <speed> -- optional, range is -10 to +10 on windows TTS. you can also specify a number between 50 and 250 which will be treated as speech speeed (100% is normal)
            volume = "1.0", -- optional
            gender = "male"|"female", -- optional
            culture = "en-US"|"en-UK" -- (must be available on you system)
            name = "name_of_voice", -- optional (overrides gender/culture settings)
            provider = {} -- optional gRPC.tts provider settings (consult DCS-gRPC). for example ATIS works with windows TTS. controller via a cloud provider (like AWS or Azure)
      
### applying the settings
you can override one or more, and you can also have mutiple frequencies.
you then pass the table into the appropriet functions
```lua
    HoundInstance:configureController(args)
    HoundInstance:configureAtis(args)
```
for example:
```lua
    controller_args = {
        freq = "251,35"
        modulation = "AM,FM"
    }
    atis_args = {
        freq = 251.500,
    }
    HoundInstance:configureController(controller_args)
    HoundInstance:configureAtis(atis_args)

    HoundInstance:enableController()
    HoundInstance:enableAtis()
```
This will change ATIS frequency to 251.5 and enable ATIS. This will also enable a Controller both in Text and in Voice and will set it to transmit on two frequencies 251.0 AM and 35 FM

---
# Event handlers
Introduced with Hound 0.2 you now have Hound event handling. This for example allows you to perform scripted actions on specific events.
## Available events
`NOTE: reserved events are not yet emitted`
| name | id |
| ---|-----|
| NO_CHANGE | 0 |
| HOUND_ENABLED |  1 |
| HOUND_DISABLED |  2 |
| PLATFORM_ADDED |  3 |
| PLATFORM_REMOVED |  4 |
| PLATFORM_DESTROYED |  5 |
| TRANSMITTER_ADDED |  6 |
| TRANSMITTER_REMOVED |  7 |
| TRANSMITTER_DESTROYED |  8 |
| RADAR_NEW |  9 |
| RADAR_DETECTED  | 10 |
| RADAR_UPDATED  | 11 |
| RADAR_DESTROYED  | 12 |
| RADAR_ALIVE  | 13 |
| RADAR_ASLEEP  | 14 |
| SITE_NEW  | 15 |
| SITE_CREATED  | 16 |
| SITE_UPDATED  | 17 |
| SITE_CLASSIFIED | 18 |
| SITE_REMOVED  | 19 |
| SITE_ALIVE  | 20  |
| SITE_ASLEEP |  21  |
| SITE_LAUNCH | 22 |

An event structure is as follows:
```lua
houndEvent = {
    id = <HOUND.EVENT> enum,
    coalition = <coalition.side> enum of coalition emitting the event,
    houndId = Hound Instance ID that emitted the event,
    initiator = DCS unit or HoundContact
    time = time of the event (timer.getTimer())
}
```
to use them you need to create a table with the function `onHoundEvent(event)` and register it.
```lua

    FakeEventHandler = {}
    function FakeEventHandler:onHoundEvent(event)
        if event.coalition == coalition.side.BLUE then
            if event.id == HOUND.EVENTS.RADAR_DETECTED then
                local contact = event.initiator
                trigger.action.outTextForCoalition(event.coalition,"Let's pretend a SEAD flight was fragged to strike " .. contact:getName())
            end
            if event.id == HOUND.EVENTS.PLATFROM_DESTROYED  then
                trigger.action.outTextForCoalition(event.coalition,initiator:getName() .. "has been destroyed")
            end
        end
    end

    HOUND.addEventHandler(FakeEventHandler)
```
to remove use
```lua
    HOUND.removeEventHandler(CustomHoundScript)
```
`NOTE: Event handlers are global so make sure you validate coalition or houndId as the event might be from a different Instance from a different coalition`
`RADAR_DESTROYED event is delayed from the DCS Unit destroyed event, so unit is gone by then. unit field in a dead contact is unitName not unit object like on other events. Try and use initiator.DcsGroupName whenever possible`

---
# Appendix
## Performance Tuning
when running a large mission with a huge Air defense network it is not uncommon to encounter some performance issues.  
These issues are caused by the huge number of markers needed to be created and DCS' ability to manage them.
Here are some tips to help you mitigate this.

1. Disable Markers! if you don't need them, just disable them altogether. 
```lua
 HoundInstance:disableMarkers()
```
2. if you want some markers, then disable just the uncertainty markers, this will cut down the number of markers needed by half. the information will still be included in the description on the point marker.
```lua
HoundInstance:setMarkerType(HOUND.MARKER.NONE)
```
3. in addition, you can lower the update rate of the markers. The default refresh is 120 seconds, you can set it to 180 or 240 to further cut down on the amount of markers needed.
```lua
HoundInstance:setTimerInterval("display",180)
```
---
## Exports
The current implementation supports two types of exports, LUA and CSV.
### LUA Export
#### Site export
```lua
HoudnInstace:getSites()
```
Calling this function will return a LUA table
```lua
 {
    ewr = { 
            count = 0,
            sites = {}
          },
    sam = {
            count = 0,
            sites = {}
          }
}
```

each site entry is a Lua table
```lua
{
    name = <String (Hound Site Name)>,
    DcsObjectName = MString (Dcs Group Name)>,
    gid = <int (3 digits)> ,
    Type = <String>,
    last_seen = <float (time last spotted by platform in seconds, timer.getAbsTime)>,
    emitters = { <Table (emitter entries, see below)}
}
```

Each emitter entry will follow the following structure.
```lua
{
    typeName = <String ("straight flush","P-19")> 
    uid = <int (2 digits)> 
    DcsObjectName = <String (Name of actual DCS Unit)>
    maxWeaponsRange = <Int (Max range of group weapons in Meters)>
    last_seen = <float (time last spotted by platform in seconds, timer.getAbsTime)>
    detected_by = <table (list of platform names that detected contact)>
    if contact has position then
        pos = <table (DCS point of estimated position)>
        LL = {
            lat = <Float>,
            lon = <Float>
        }
        accuracy = <String>
        uncertenty = {
            major = <Int (meters)>,
            minor = <Int (meters)>,
            heading = <Float (deg)>
        }
    end
}
```

#### Contacts export (legacy)
This function will dump a table only containing contacts with no actual grouping 
```lua
HoudnInstace:getContacts()
```
Calling this function will return a LUA table
```lua
 {
    ewr = { 
            count = 0,
            contacts = {}
          },
    sam = {
            count = 0,
            contacts = {}
          }
}
```
Each contact will be added to the appropriate category and the count will be updated to match the number of contacts in each category.
entry structure will look the same as the emitter entry of SiteExport


### CSV export
```lua
HoundInstance:dumpIntelBrief()
```
this will create a file in the DCS saved games folder. The default filename is "hound_contacts_XX.csv" (where 'XX' is the Hound instance UID)
you can specify a filename if desired:
```lua
HoundInstance:dumpIntelBrief("custom_name.csv")
```
CSV structure:
```
SiteId,SiteNatoDesignation,TrackId,RadarType,State,Bullseye,Latitude,Longitude,MGRS,Accuracy,lastSeen,DcsType,DcsUnit,DcsGroup,ReportGenerated
```

Sample data
```csv
SiteId,SiteNatoDesignation,TrackId,RadarType,State,Bullseye,Latitude,Longitude,MGRS,Accuracy,lastSeen,DcsType,DcsUnit,DcsGroup,ReportGenerated
T002,2,I-1,Fan-song,Asleep,187/78,33.721733,35.800634,36S YC 5951 3482,Precise,1700,SNR_75V,SYR_SA-2_TR,SYR_SA-2,1730
T002,2,I-3,Flat Face,Active,187/78,33.723213,35.799935,36S YC 5944 3498,Precise,1730,p-19 s-125 sr,SYR_SA-2_SR,SYR_SA-2,1730
T021,6,E-20,Straight Flush,Active,018/0,35.022129,35.900628,36S YD 6465 7934,Unactionable,1730,Kub 1S91 str,SYRIA gnd 2 unit1,SYRIA gnd 2,1730
T019,6,E-18,Straight Flush,Active,217/0,35.020751,35.899614,36S YD 6456 7918,Unactionable,1730,Kub 1S91 str,SYRIA gnd 3 unit1,SYRIA gnd 3,1730
T023,6,E-22,Straight Flush,Active,032/0,35.021980,35.900600,36S YD 6465 7932,Unactionable,1730,Kub 1S91 str,SYRIA gnd 1 unit1,SYRIA gnd 1,1730
S009,EWR,I-8,Box Spring,Active,170/44,34.301650,36.114852,37S BT 3446 9937,Precise,1730,1L13 EWR,EWR-SKYNET-5-1,EWR-SKYNET-5,1730
S015,EWR,I-14,Box Spring,Active,183/52,34.151685,35.911686,36S YC 6845 8280,Precise,1730,1L13 EWR,EWR-SKYNET-3-1,EWR-SKYNET-3,1730
S007,EWR,I-6,Box Spring,Active,191/81,33.678493,35.704000,36S YC 5068 2979,Precise,1730,1L13 EWR,EWR-SKYNET-1-1,EWR-SKYNET-1,1730
S011,EWR,I-10,Box Spring,Active,200/75,33.820852,35.486437,36S YC 3012 4507,Precise,1730,1L13 EWR,EWR-SKYNET-6-1,EWR-SKYNET-6,1730
S005,EWR,I-4,Box Spring,Active,147/60,34.207544,36.618624,37S BT 8059 8773,Precise,1730,1L13 EWR,EWR-SKYNET-4-1,EWR-SKYNET-4,1730
S017,EWR,E-16,Box Spring,Active,054/0,35.023404,35.902730,36S YD 6484 7949,Unactionable,1730,1L13 EWR,EWR-SKYNET-1,EWR-SKYNET-0,1730
S013,EWR,I-12,Box Spring,Active,185/64,33.950048,35.878007,36S YC 6597 6034,Precise,1730,1L13 EWR,EWR-SKYNET-2-1,EWR-SKYNET-2,1730
```

**NOTE**: This function requires you to [de-sanitize](#desanitize-dcs-scripting-engine) `io` and `lfs` modules in the DCS scripting engine.

---

## Desanitize DCS Scripting Engine
By default, the DCS scripting engine blocks all access to the OS to avoid potential security risks.
some functions, most notably anything that needs to be written to disk, will not work in this default state.
You'll need to "De-sanitize" the DCS Scripting Engine and allow these LUA core modules to be used.

`NOTE: This is DCS core file change, that will grant DCS access to functions that allow it to run potentially malicious code.
USE WITH CAUTION`

This is done by editing a single core DCS lua file. this change will be reverted on every DCS update and will need to be re-applied.
open the file `<DCS_ROOT_FOLDER>/scripts/MissionScripting.lua` in your favorite text editor (NodePad++ for example)
in that file you'll see the following 3 lines.
```lua
sanitizeModule('os')
sanitizeModule('io')
sanitizeModule('lfs')
```
Each of these lines represents a core lua module that is disabled by DCS Scripting Engine. To enable them just comment out the line that corresponds to the module needed. when all 3 are enabled, that part of the file will look like this
```lua
-- sanitizeModule('os')
-- sanitizeModule('io')
-- sanitizeModule('lfs')
```
For example, STTS requires all 3 to be available. 
[dumpIntelBrief](#csv-export) requires `io` and `lfs` to be available

---
# Known Issues
  * On initial detection, accuracy will usually be very high with the solution nowhere near the radar's actual position. This is sorted by the system as more data points are gathered. allow at least 2 minutes for contact to stabilize.Adding low-resolution platforms will degrade the solution as Hound currently does not reject "bad data". Hound will drop readings that have more than 10 degrees of error. but if the resolution is above the threshold, but very far away, it may still degrade the resolution.
  * Overlapping of sectors is currently not recommended. you can add a small high-priority sector on top of a larger sector, but this is the ONLY tested overlap, and there might be some unexpected behavior with that.
  * MIST 4.4 is REQUIRED. However, if used with MIST 4.5.103+ some additional functionality is enabled. (e.g SAM that threatens sectors )

# Breaking changes
## 0.1.X to 0.2.X
If you are upgrading from 0.1 please note that some changes will be required.
  * `enableController()` no longer accepts boolean to enable or disable text. please use [`enableText()`](#text-messages) call.
  * Every function that has `ATIS` in it needs to be changed to have `Atis` - note the capitalization.
  * "name" argument passed in the TTS config table is no longer used. (silent failure)
  * `setTransmitter()` is now a sector function. in general, passing everything directly to `Instance.controller` or `Instance.atis` will no longer work due to changes in the internal architecture. 
## 0.2.X to 0.3.X 
From 0.2 to 0.3 there was an internal change and all classes (except form `HoundElint`) were wrapped into `HOUND` class (rather then several independent classes).
  *  HoundEventHandler is now called HOUND.EventHandler please make sure to update your scripts
## 0.3.x to 0.4.x
  * Marker ENUMs have changes. `HOUND.MARKER.NONE` will draw nothing. Original behaviour is now `HOUND.MARKER.POINT`.
  * [Site markers](#map-markers) are toggled separately then the normal map markers. If you really want nothing, you need to add `HoundInstance:disableSiteMarkers()` to your Hound setup, or select 
  * HOUND.Contact class has been refactored and split into multiple classes. if you call HOUND.Contact directly in custom scripts you'll need to rename it to HOUND.Contact.Emitter
  * Export has been refactored to support new site groupings, see [exports](#exports)

# Special thanks
  * __Grimes__ - For [MIST](https://github.com/mrSkortch/MissionScriptingTools) and because Without the [Hoggit Wiki](https://wiki.hoggitworld.com/) we would all be fumbling in the dark.
  * __[flywaldair](https://github.com/walder)__ - Author of [Skynet IADS](https://github.com/walder/Skynet-IADS), which was a massive inspiration for creating Hound. 
  * __[Ciribob](https://github.com/ciribob)__ - without his help, support and acceptance of weird merge requests. Hound would have never been possible.
  *  __[Pene](https://github.com/Penecruz)__, for being a sport and trying out all manner of builds. And to the rest of the __[DCS ANZUS](https://discord.gg/mCQw9Wm5Qq)__ for allowing him to keep doing that :)
  * __[rkusa](https://github.com/rkusa)__,__[rurounijones](https://github.com/rurounijones)__ and everyone involved for [DCS-gRPC](https://github.com/DCS-gRPC/rust-server).
  * __Nikos__, __[Jester](https://github.com/hbjonsson)__, __[davidp57](https://github.com/davidp57)__ and all the rest - For the feedback and suggestions pushing Hound even further

And a very special thanks is (and will always be) reserved for those who choose to click the button below :) 
[![Donate with PayPal](https://www.paypalobjects.com/en_US/i/btn/btn_donate_LG.gif)](https://www.paypal.com/donate?business=RDGX965BT5MT4&no_recurring=1&item_name=Thank+you+for+choosing+this+way+to+show+your+appreciation%21+&currency_code=USD)  
