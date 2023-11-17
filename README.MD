# Hound ELINT system for DCS
## Overview
**Hound ELINT** is a mission script for DCS. it uses one or more assigned ELINT platforms to approximates location of transmitting enemy radars using triangulation. Platforms are pre-assigned or dynamicly assgined asstes, they can be Airborn, ground units or stationary objects from a set list of assets avialable. 

Hound presents data in sevral methods.

1. F10 map markers indicating estimated position of the Radar, with type and accuracy information for tactical decisions. this works best with "My AC" or "Map only" modes
2. Hound offers a Text-To-Speech ATIS system using SRS. This feature provides a radio channel with constantly updated information about current threats.
3. Detailed information by a "SAM controller" can be provided as TTS (via SRS) and as text messages. 

System can gather information about Enemy radar deployments and help understand the tactical situation or penetrate enemy defences. Because the System is asset based, you also need to be protecting these assets, as if they are destroyed, you loose your tactical data.

Hound requires MIST and is compatible with MOOSE, Skynet IADS and High-Digit SAMs and more.

### Video Intro (YouTube)
[![Hound Cinematic Intro video](https://i.ytimg.com/vi/S4xxtKOqGqU/hq720.jpg?sqp=-oaymwEcCNAFEJQDSFXyq4qpAw4IARUAAIhCGAFwAcABBg==&rs=AOn4CLAAa-SdnDgNiWTKc0YNSvm5RRMa7g)](https://www.youtube.com/watch?v=S4xxtKOqGqU)


Table of Contents
=================

* [Hound ELINT system for DCS](#hound-elint-system-for-dcs)
  * [Overview](#overview)
    * [Video Intro (YouTube)](#video-intro-youtube)
* [Adding Hound to a Mission](#adding-hound-to-a-mission)
  * [Required external scripts](#required-external-scripts)
    * [adding scripts in mission editor](#adding-scripts-in-mission-editor)
    * [some screenshot as hints](#some-screenshot-as-hints)
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
  * [On screen Debug](#on-screen-debug)
* [Deep Dive](#deep-dive)
  * [Hound structure](#hound-structure)
  * [Instance initialization](#instance-initialization)
  * [Platforms](#platforms)
  * [Activate Hound](#activate-hound)
    * [Hadnling pre\-briefed contacts](#hadnling-pre-briefed-contacts)
    * [<a href="README/settings\.MD">Global and per instance Settings</a>](#global-and-per-instance-settings)
  * [Per\-instance Settings](#per-instance-settings)
    * [Map markers](#map-markers)
      * [Living with other marker spawning scripts](#living-with-other-marker-spawning-scripts)
    * [Platform position errors](#platform-position-errors)
    * [DBA reports](#dba-reports)
    * [Reposition Controller radio menu](#reposition-controller-radio-menu)
    * [DCS callsign overrides](#dcs-callsign-overrides)
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
    * [gRPC\.tts settings](#grpctts-settings)
* [Event handlers](#event-handlers)
  * [Available events](#available-events)
* [Appendix](#appendix)
  * [Performace Tuning](#performace-tuning)
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
* [Full Documentation](#full-documentation)
* [Special thanks](#special-thanks)

# Adding Hound to a Mission
***if upgrading from previous version of Hound please see [Breaking changes](#breaking-changes)***

Hound system triangulates positions of radars. It does this by taking bearing readings at set times, while recording the platform position. 
using these plotted data points system can estimate the position. the more points you have, with greater intersection angles between them, there is a better chance of estimating the position correctly. you will never get a perfect "hit" but you may be able to get a position within a 200 meter radius, where you can can use other sensors to poinpoint for a strike, or know where you need to avoid flying.

Only specific units are ELINT capable. In order to get the best positional accuracy you want your best precision platforms positioned as close as possible and as high as possible. Rememeber the higher you go the longer you can see, simple physics.

placing two C-17s going race-track holding patterns at 30,000 ft can get you positional data on radars more then 200nm away, not the best accuracy of course. 
using a Comms Tower placed on a high mountain will provide very accurate baseline on which aircraft data can be triangulated.
However, tall mountains are not very common, and clear line-of-site is a thing. 

Helicopters may be of some use, but they can, using existing mission scripts, transport ground units to tall mountains deep inside enemy terirory.
Same goes to Fast movers like the Viggen, F-16, JF-17 or the Su-25T. they can dash into enemy teritory and help you find the radars trying to hide. 

Remember that the system is using a simulated DF to determin the bearing of the radar from the platform. Low precision systems will cause the calculated position to be with a higher ellipse of uncertenty for radar position. below you can find the list of working units and their sensor precision.

Resolution of platforms are derrived from antenna size and emitter frequency. shout out to TLTeo for explaining the physics of this.

Hound Currently has a 10 degrees angular resolution cutoff point to avoid introduing "bad data". The the first band that is valid for a platform is denoted in the `Minimum Band` column.

``` Note: While currently not implemented. Intention of including both Viggen and the Su-25T is that they will only be able to participate if they are carrying their ELINT pods ```  

## Required external scripts
[MIST (by mrSkortch)](https://github.com/mrSkortch/MissionScriptingTools/releases/latest)  

Optional scripts - required for TTS (only one of them is required, based on your preference)
[DCS-gRPC](https://github.com/DCS-gRPC/rust-server)
[DCS-SimpleTextToSpeech (by ciribob)](https://github.com/ciribob/DCS-SimpleTextToSpeech)

`For installation of STTS or DCS-gRPC please consult project of choice repo. Both require you to modify "DCS World/Scripts/MissionScripting.lua"
`  
for more information of desanitization process, look [here](#desanitize-dcs-scripting-engine).
### adding scripts in mission editor
``` NOTE the order of scripts - it's important ```  
on a "ONCE" type action with "time more 1" condition, add the scripts in the following order
1. `MIST`
2. `DCS-SimpleTextToSpeech` (if TTS via STTS is desired - gRPC is implemented globally. I mission Includes MOOSE Framework, it includes STTS internally)
3. `HoundElint.lua`

### some screenshot as hints

![Add scripts](/images/hound_setup.jpg)

## Minimum Hound setup
---
The bare minumum, more customization optionas are available.
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
It doesn't need to make sense to you, there is actually more explenations ahead.
But this is an example of a more compex configuration.

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
| H-6J      | 6.54 / 0.70 | C ||
| C-47      | 1.91 / 0.20 | A ||
| S-3B      | 1.59 / 0.17 | A ||
| E-2D      | 6.54 / 0.70 | C ||
| E-3A      | 5.09 / 0.55 | C ||
| An-26B    | 0.98 / 0.10 | A ||
| A-50      | 5.09 / 0.55 | C ||
| Viggen    | 5.09 / 0.55 | C | U22 |
| Su-25T    | 6.54 / 0.70 | C | Fantasmagoria |  
| JF-17     | 7.05 / 0.76 | C | KG-600 SPJ |
| F-16C     | 15.79 / 1.69| D | Block 50 w/HTS |
| Mirage F1 |  6.19 / 0.66  | C | Cyril pod |

<sup>*</sup> Data with angular resolution below 10 deg is rejected. That is a roudementry way to drop very bad data.
  
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
| MLRS FDDM | 1.53 / 0.16 | A | 

### Static Objects
| Platform  | Accuracy Deg. (C/H Bands) | Min. Band |
| --------  | --------  | --------  |
| Comms tower M | 0.21 / 0.02 | A |
| Command Center | 0.37 / 0.04 | A |
| TV Tower | 0.10 / 0.01 | A |

## On screen Debug
when this setting is enabled, Hound will print a short status report after each update cycle. (every ~15 seconds by default)
it is controlled by the `onScreenDebug` function. this output is disabled by default
```lua
-- to enable
    HoundBlue:onScreenDebug(true)
-- to disable
    HoundBlue:onScreenDebug(false)
```

# Deep Dive
## Hound structure
Hound is made out of several elements that work togeather.

  * HOUND - the global entity created by loading the script
    * __Global Settings__: Settings that effect all instances running. (eg. TTS engine to use, number of datapoints, contact timeout, etc.)
    * __[HoundInstance](#instance-initialization)__ - the basic working componenet, you can define multiple instances, but only one is required per coallition
      * _[Settings](#per-instance-settings)_ - Each HoundInstance has a set of settings that are for it and are not shared between instances (unlike global settings)
      * _[Platforms](#platforms)_ - Units from the [assets list](#available-assets) that will collect information. Can be added and removed at any time.
      * _Contacts_ - Radars detected by the system
      * _[Sectors](#sectors)_ - A logical grouping of control elements, an instance can have multiple sectors.
        * [Zone](#zones) - Geographic zone defining the sector borders (Optional)
        * [Controller](#sam-controller) - Main interaction point for the user. will provide Text and TTS information on radars in the sector.
        * [ATIS](#atis-system) - Automated repeating TTS only summery of all contacts in the sector.
        * [Notifier](#notifier) - Automated TTS only Alerts only provider. it will duplicate the alerts sent by the controller. for increasing SA of players not listening on the controller freq.
    * __HoundInstance__ - A second instance for the other team if needed
    * __[EventHandler](#event-handlers)__ - Hound event handler (global)
  
## Instance initialization
First we create hound instance. on creation Hound must have a coalition assigned. this can be done in several ways.
```lua
    -- direct coalition assignment
    HoundInstance = HoundElint:create(coalition.side.BLUE)
```
An instance without any platforms would be created.

you can also create Hound with an initial platform. coalition will be taken from the Unit assigned.
Hound adds units by using their names (or pilot name) not by a group name.

```lua
    -- create with platform (static object in this case)
    HoundInstance = HoundElint:create("Migariya_Elint")
```
## Platforms
Platforms can be added at any time (before or after system activation)
```lua
    HoundInstance:addPlatform("ELINT_C17")
```
and if need be the oposite is also available
```lua
    HoundInstance:removePlatform("ELINT_C17")
```
please make sure you go over the [available assets list](#available-assets) to determin what would work best for your mission.

## Activate Hound

Thats it, all you need to do now is to activate the system
```lua
    HoundInstance:systemOn()
```
Once activated the system will use all avaliable platforms to locate transmitting radars. 
Information about these radars is updated periodicly onto the F10 map.

` Note: during this first implementation, markers are updated every 2 minutes`

You can of course turn it off for any reason with:
```lua
    HoundInstance:systemOff()
```

### Hadnling pre-briefed contacts
In some cases you would want to always provide accurate positional information on a contact. for exmpale a stationaty SAM site you provided strike coordianted for in the Briefing.
you can sync Hound to use the actual unit data as position. The contact will be treated as "Pre-Briefed" and will not update position like the others.
However if a PB concat moves more then 100m from it's original position the special "pre-brifed" flag will be removed and radar will be processed as a normal contact from that point on.

you can mark Unit or Group, only valid Hound Radars will be added (it will not add units it will not normally track). if a group was passed and in contains more then one valid radar, all of the radars will be added

In addition, you can provide an optional "code name" for a PB site, which will be it's name in reports and in comms menu.

```lua
    HoundInstance:preBriefedContact('UNIT_NAME')
    HoundInstance:preBriefedContact('GROUP_NAME')
    HoundInstance:preBriefedContact('GROUP2_NAME',"ANTELOPE")

```
---
### [Global and per instance Settings](README/settings.MD)
---
## Per-instance Settings
These are settings that are configurable per Hound instance.
### Map markers
Hound uses Map markers to indicate the estimated position of the tracked radar. It's a product of the system, and only contains data user can get from the system in other ways (equvilant to making marks on a paper map).
Map markers are enabled by default. In addition, if radar went offline, the marker fill will fade slowly over time until it reaches a minimum value on contact timeout (thee time in which all past contact datapoints are deleted).

However, some mission designers may want to disable the markers. 
```lua
    HoundInstance:disableMarkers()
```
they can be turned back on with
```lua
    HoundInstance:enableMarkers()
```
Hound Supports a few different marker types for the uncertenty ellipse that can be selected. 
The type of marker is set per Hound instance.
```lua
    HoundInstance:setMarkerType(HOUND.MARKER.POLYGON)
```
You can save a line and change marker type while enabling the markers
```lua
    HoundInstance:enableMarkers(HOUND.MARKER.POLYGON)
```

the available marker types are:
|  HOUND.MARKER | Description |
| ---- | ------------|
| NONE | no ellipse is drawn (only position marker)|
| CIRCLE | a circle of uncertenty will be drawn |
| DIAMOND | a diamond will be drawn with 4 points representing uncertenty ellipse (Default) |
| OCTAGON | ellipse will be drawn with 8 points (diamon with midpoints) |
| POLYGON | ellipse will be drawn as a 16 sides polygon |

`Note: More points causes higher CPU usage. CIRCLE is default`

In addition to the radar markers there is an additional simpler site marker. The site marker only adds the site designation and current SAM classification.
it is used in conjunction with the Map markers to help locate the radar you want in the menu system.
The site markers are enabled by default and are disabled seperatly from the normal map markers.

```lua
    HoundInstance:disableSiteMarkers()
    HoundInstance:enableSiteMarkers()
```

#### Living with other marker spawning scripts
Hound does it best to play nice with other Marker generating scripts.
if MOOSE is loaded Hound will default to use `UTILS.GetMarkID()` to get the next marker ID. 
if that is not available, and MIST is in version 4.5 and above. Hound will attempt to use MIST's `mist.marker.getNextId()` method.
if none of those options is available it will use an internal counter to track mark IDs. 

if from any reason you still encounter issues you can force Hound to use the internal counter by setting
```lua
HOUND.FORCE_MANAGE_MARKERS = true
```

By default the internal counter starts from 10,000. You can change the initial value to avoid conflicts with other numbering things (which are not MOOSE or MIST) by using the method `HOUND.Utils.setInitialMarkId()`. As mentioned earlier, if MOOSE or MIST v4.5 are present their numbering engine will take priority over Hound's internal Numbering.
It is highly recommended that you use one of them (or `HOUND.Utils.getMarkId()`) for all other scripted Map markers.

In addition to all that Hound will only delete its own markers (by tracking every Marker ID it's placing)

---
### Platform position errors
Position of the platform is a baseline used for the triangulation. In the real world however position on the platform is always never accurate. Older aircraft have INS systems that drift overtime unless updated periodically, while in newer Aircraft a less "drifty" system is updated automatically from GPS.
To simulate this you can enable position errors. When this setting is enabled, a random error is introduced to platform's position when stored. 
```lua
    HoundInstance:enablePlatformPosErrors()

    -- disable (default)
    HoundInstance:disablePlatformPosErrors()
```

---
### DBA reports
By default the [Controller](#sam-controller) and [Notifier](#notifier) will push alerts when a radar is destroyed when track is dropped.
you may choose to disable this behaviour
```lua
    HoundInstance:disableBDA()

-- enable (default)
    HoundInstance:enableBDA()

-- get current value
local bool = HoundInstance:getBDA()
```

This setting only affects automatic marking of dead contacts. you can manually mark a contact as dead (and notifications will be transmitted) regardless of BDA settings.  
To mark a contact as dead use ```HoundInstance:markDeadContact(radarUnit)``` see [extended docs](#more-docs) for more information.

---
### Reposition Controller radio menu
By default the [Controller](#sam-controller) will generate the "ELINT" root menu in the base F10 menu.
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
The menu system uses user callsigns in responces. DCS has a limited set of callsignes, but Mission designer may wish to do something else.
Hound supports 3 types of callsignes in this order
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
---
### NATO callsigns
[Sectors](#sectors) get automatically assigned [callsigns](#callsigns). The callsignes are picked from a pool of names. Howwever there is an alternate list, taken from callsignes used by RC-135 squadrons. to use this alternate callsign list by default, you'll need to set the following.
```lua
-- enable use of alternate pool
    HoundInstance:useNATOCallsignes(true)
-- disable this setting (return to use default pool)
    HoundInstance:useNATOCallsignes(false)
```
---
### NATO Lowdown
The [ATIS system](#atis-system) has two modes, Normal and NATO lowdown.
same report in both will look slightly different.
in the Normal default format, ATIS will also call out radar names and Grid position.  
`Straight Flush 17, grid GG20, accuracy very high`

it is possible to switch it to NATO LOWDOWN format.  
`6, ACTIVE, BULLSEYE 012 13, accuracy very high`

This change is global and preformed via the use of the following:
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
Hound works with multiple timers that will control the frequency of internal tasks.
the four timers and their default values are:
  * scan: 5s
  * process: 30s
  * menus: 60s
  * markers: 120s

`scan` controls the interval in which platforms are tested agains radars and datapoints are added.  
`process` is the position calculation interval.  
`menus` is the interval in which the comms menues will be computed.  
`markers` is the interval in which all map markers will be updated.  
you can change the default value if you wish by passing interval name and new value.
this is normally done to tune performance impact. 

for example: increasing the scan interval to 20 seconds and the process interval to 60 seconds might help when a very large number of radars are present in the missions and there is suspicion Hound is the cause.

```lua
HoundInstance:setTimerInterval("display",180)
```

---
## Sectors
The next big building block of Hound are the sectors. 
Introduced in 0.2 this aims to solve a problem in large servers. in the past there was only one "default" sector that everyone contacted for information. In practice in large missions it was just un-manageable. 

A "Sector" is a internal named object that manages communication with players. each sector is assigned a name and a callsing.
when initilizing Hound a "default" sector is created with the callsign "HOUND". when not passing any sector name argument, "default" sector is the sector that would be affected.

A Sector can be geofenced, if such geofencing is is set (more on this later) only radars in and around the sector will be reported. see more under [Zone managment](#zones)

There are two reserved sector names:
  * `default` - default sector name created with hound instance. it cannot be removed and some features such as geofencing is not available on it
  * `all` - all sectors. some settings can be changes accross all sectors using the "all" keyword. this is available on generic config functions not on 

### Managing sectors
The most basic command is to add a sector. you will need to provide a name for the sector (not a callsign), this name will be used in the comms menu for example. so you can make it human descriptive or match your SOP .

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

or if from some bizzare reason you would like to remove a sector
```lua
    HoundInstance:removeSector("sectorName")
``` 

### Sector configuration
Sectors have a few options worth knowing.
#### Text messages
By default Hound will only broadcast using SRS. You can optionally enable Text messages of all controller messages (ATIS and notifier will remain Voice only). Text notification will only show up for groups that are currently checked in with a controller. enable and disable is per-sector
```lua
    HoundInstance:enableText("sectorName")
    HoundInstance:disableText("anotherSector")
```
or to all of them using the "all" keyword
```lua
    HoundInstance:enableText("all")
```
#### TTS transmissions
Hound is primary built to use Text-To-Speach messages to communicate. However if from any reason you wish to disable this feature. (which is strictly enabled by default)
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
Geofencing a sector will be achived by assigning a "Zone".
There are two valid polygon inputs to the Sector.
  * Draw tool freeform polygon
  * DCS Group waypoints (standard method - best practis is to use a late activation helicopter group)

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

You can also get the currently set zone on the sector (nil means not zone is set)
```lua
    HoundInstance:getZone("sectorName")
```

To remove a zone from sector use:
```lua
    HoundInstance:removeZone("sectorName")
```

#### Transmitter
A sector can have a transmitter which will broadcast all the TTS messages for the sector.
when no transmitter is assigned, everyone on the frequency will be able to hear then transmissions, without any limitations, a "Magic Satlink" if you wish.

Once transmitter is set, SRS will use transmitter's current position for the transmition forcing line-of-sight, maximum radio range and any other SRS limitation that comes with it.  
If transmitter unit is destroyed, no TTS transmissions will occure. To resolve it you would either need to set a new transmitter to take over.

you can also remove the transmitter at any time to return to the default "Magic Satlink" state.

Transmitter can be a Unit or a static object, and it's called by Unit/Pilot name
```lua
    HoundInstance:setTransmitter("sectorName","AWACS_Unit")
```

Remove transmitter using
```lua
    HoundInstance:removeTransmitter("sectorName")
```

you can also use the "all" keyword for apply the transmitter to all sectors
```lua
    HoundInstance:setTransmitter("all","GCI_bunker")
```
#### Callsigns
each sector has a randomly assigned callsign. these callsignes are selected from a pool of callsignes.
you can get currenly assigned callsign using 
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
if you want ALL sectors to use callsignes from this pool there is a global setting for this. See [Global settings -> NATO callsigns](#nato-callsigns)

---
# Communication
---
In addition to the map markers described above. Hound is utilizing Text-To-Speech to provide the player with information via SRS.
The three communication types are:
  * Automated Information System [ATIS system](#atis-system)
  * User interactable [SAM controller](#sam-controller)
  * Alert Agency dubbed [Notifier](#notifier)

they are all configureable as will be described the [Text-To-Speach configuration](#text-to-speach-configuration) segment below.

## ATIS system
---
The Automated Tactical Information System (ATIS). Will provide an automated information message loop on a set frequency.
Default frequency for ATIS is 250.500 AM.
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
However, having all the ATIS in all the sectors broadcast on the same frequency isn't really useful. so you can pass [configuration](#text-to-speach-configuration) table then enable
```lua
    HoundInstance:configureAtis("Sukhumi",atis_conf)
    HoundInstance:enableAtis("Sukhumi")
```
or you can pass the configuration on enable
```lua
    HoundInstance:enableAtis("Sukhumi",atis_conf)
```

### additional settings
  * ATIS by default will not report EWR radars as threat, but will only notify you on their presence (and how many of them are tracket in the sector). If from some reason you prefer to get a normal brief on them as well you can enable it using the following:
```lua
    HoundInstance:reportEWR("Sukhumi",true)
-- disable again with
    HoundInstance:reportEWR("Sukhumi",false)

-- and set for all of them with
    HoundInstance:reportEWR("all",true)
```
  * NATO Lowdown format is available as global setting. see [Global Settings -> NATO Lowdown](#nato-lowdown)
  * Changing the ATIS update interval is avilable via global settings. see [Global Settings -> ATIS update interval](#atis-update-interval)
## SAM controller
---
The SAM controller is the main user interface with the system. Via the F10 menu, you can request detailed information about specific tracked radars. the controller defaults to 250.00 AM

basic enable is done via 
```lua
    HoundInstance:enableController()
```

as with the ATIS, it's recommended to activate on a non-default sector and pass [configuration](#text-to-speach-configuration)
```lua
    HoundInstance:configureController("Saipan",controller_config)
    HoundInstance:enableController("Saipan")
```
or the one liner
```lua 
    HoundInstance:enableController("Saipan",controller_config)
```
disable is done via 

```lua
    HoundInstance:disableController()
    --- or the named sector
    HoundInstance:disableController("Saipan")
```
 ### Additional settings
 By default a controller will alert you on new radars detected and on dead emitters.
 you can disable all controller alerts (does not affect the [Notifier](#notifier)).
 ```lua
    HoundInstance:disableAlerts("Sukhumi")
-- enable again (default behaviour)
    HoundInstance:enableAlerts("Sukhumi")

-- and set for all of them with
    HoundInstance:disableAlerts("all")
```

By default the controller will provide you with MGRS in 10 digits format (5 for easting and 5 northing).
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
  * Elevation of Radar above Sea-level (in 50ft increments)
  * Extended uncertenty ellipse information (Major axis, Minor Axis, rotation of major axis)
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

Advanced users what wish to change this structure may do it. 
If you are satisfied by only supressing the Extended uncertenty and the Extended Tracking time info you can do so by invoking `HOUND.showExtendedInfo()` function. This will have an affect globally.
```lua
  HOUND.showExtendedInfo(false)
```
If a more extensive change is desired, The recommended way to achieve it is to `COPY` the `HOUND.Contact.Emitter:generateTtsReport` and `HOUND.Contact.Emitter:generateTextReport` functions from `src/311 - HoundContact_comms.lua` file in this repo to a new file. In that new file perform the changes you want. To activate load the new file to the mission using `Do script file` **AFTER** the main Hound script is loaded. this will replace the original implementation without  editing the original file. allowing a simpler upgrades to newer Hound versions without loosing you changes.  

 ## Notifier
 ---
 This, as the name suggests is notification only agent. it functions independently of controller or ATIS and will only report pop-up and if enable radar destruction alerts. this is intended to be operated on a different freqency then the controller (which has the same alerting capacity). This may be used for improving SA on Air-To-Air frequency or on general strike channels.
 
 Notifier has a special case when used under "default" sector when radar is inside a geofenced sector. In this scenario it will report using sector name rather then with location. for example:
  * Normal: `Attention All Aircraft! This is HOUND. New threat detected! Straight flush 11 is now Alive, bullseye XXX YY, Grid ZZ 1 4.`<br>
  * Special case: `Attention All Aircraft! this is HOUND. New thread detected! Straigh flush 11 is now Alive in Bander Abbas.`

  by default it will broadcast on 243.000AM and 121.500AM, i.e Guard frequency. but will accept [TTS configuration](#text-to-speach-configuration).

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
Oviously, you may want to tweak the radio to better work with you mission.
this can be done using an arguments table and passing it to the configuration funtion.

possible settings are slightly different based on your TTS provider of choice.

by default, if correct gRPC version is present, Hound will use it over STTS
to change it and use STTS regardless. you need to set a global variable.
```lua
  HOUND.TTS_ENGINE = {'GRPC','STTS'} -- this is the default value
```
Completly disabling one engine of the two is also possible.

### STTS settings
```lua
        args = {
            freq = 250.000,
            modulation = "AM", -- optional
            volume = "1.0", -- optional
            speed = <speed> -- number default is 0/1 for controller/atis. range is -10 to +10 on windows TTS. for google it's 0.25 to 4.0
            gender = "male"|"female",
            culture = "en-US"|"en-UK" -- (any installed on your system)
            isGoogle = true/false -- use google TTS (requires additional STTS config)
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
This will change ATIS freqency to 251.5 and enable ATIS
and will enable Controller both in Text and in Voice, while transmitting on two frequencies 251.0 AM and 35 FM

---
# Event handlers
Introduced with Hound 0.2 you now have Hound event handling. This for example allows you to preform scripted actions on specific events.
## Available events
`NOTE: reserved events are not yet emitted`
| name | id |
| ---|-----|
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
| SITE_REMOVED  | 18 |
| SITE_ALIVE  | 19  |
| SITE_ASLEEP |  20  |

Event structure is as follows
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
## Performace Tuning
when running a large mission with a huge Air defence network it is not uncommon to encounter some peformance issues.  
These issues are caused by the huge number of markers needed to be created and DCS' ability to manage them.
Here are some tips to help you mitigate this.

1. Disable Markers! if you don't need them, just disable them altogeather. 
```lua
 HoundInstance:disableMarkers()
```
2. if you want some markers, then disable just the uncertenty markers, this will cut down the number of markers needed by half. the information will still be included in the description on the point marker.
```lua
HoundInstance:setMarkerType(HOUND.MARKER.NONE)
```
3. in addition, you can lower the update rate of the markers. Default refresh is 120 seconds, you can set it to 180 or 240 to further cut down on the amount of markers needed.
```lua
HoundInstance:setTimerInterval("display",180)
```
---
## Exports
Current implementation suports two types of export. LUA and CSV.
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

each site entry is a lua table
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

Each emitter entry will follow the following struct.
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
Each contact will be added to the apropriate category and count will be updated to match number of contacts in each categoty.
entry structure will look the same as emitter entry of SiteExport


### CSV export
```lua
HoundInstance:dumpIntelBrief()
```
this will crate a file in the DCS saved games folder. default filename is "hound_contacts_XX.csv" (where 'XX' is the Hound instance UID)
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

**NOTE**: This function requires you do [de-sanitize](#desanitize-dcs-scripting-engine) `io` and `lfs` modules in DCS scripting engine.

---

## Desanitize DCS Scripting Engine
By default the DCS scripting engine blocks all access to the OS to avoid potential security risks.
some functions, most notably anything that needs to write to disk, will not work in this default state.
You'll need to "De-sanitize" the DCS Scripting Engine and allow these LUA core modules to be used.

`NOTE: This is DCS core files changes, that grants DCS access to functions that allows it to run potential malicious code.
USE WITH CAUTION`

This is done by editing a single core DCS lua file. this change will be reverted on every DCS update and will need to be re-applied.
open the file `<DCS_ROOT_FOLDER>/scripts/MissionScripting.lua` in your favorite text editor (NodePad++ for example)
in that file you'll see the following 3 lines.
```lua
sanitizeModule('os')
sanitizeModule('io')
sanitizeModule('lfs')
```
Each of these lines reprisent a core lua module that is disabled by DCS Scripting Engine. to enable them just comment out the line that corresponds to the module needed. when all 3 are enabled, that part of the file will look like this
```lua
-- sanitizeModule('os')
-- sanitizeModule('io')
-- sanitizeModule('lfs')
```
for example, STTS require all 3 to be available. 
[dumpIntelBrief](#csv-export) requires `io` and `lfs` to be available

---
# Known Issues
  * On initial detection accuracy will usually be very high with solution nowhere near the radar actual position. This is sorted by the system as more datapoints are gathered. allow at least 2 minutes for contact to stablize.
  * Adding low resolution platforms will degrade the solution as Hound currently does not reject "bad data". Hound will drop readings that have more then 10 degrees of error. but if resolution is above the threashold, but very far away, it may still degrate the resolution.
  * Overlapping of sectors is currently not recommended. you can add a small high priority sector on top of a larger sector, but this is the ONLY tested overlap, and there might be some un-expected behavour with that.
  * MIST 4.4 is REQUIRED. However if used with MIST 4.5.103+ some a additional functionality is enabled. (e.g SAM that threaten sectors )

# Breaking changes
## 0.1.X to 0.2.X
If you are upgrading from 0.1 please note that some changes will be required.
  * `enableController()` no longer accepts boolean to enable or disable text. please use [`enableText()`](#text-messages) call.
  * Every function that has `ATIS` in it needs to be changesd to have `Atis` - note the capitalization.
  * "name" argument passed in the TTS config table is no longer used. (silent failure)
  * `setTransmitter()` is now a sector function. in general passing everything directly to `Instance.controller` or `Instance.atis` will no longer work due to changes in the internal architecture. 
## 0.2.X to 0.3.X 
From 0.2 to 0.3 there was an internal change and all classes (except form `HoundElint`) where wrapped into `HOUND` class (rather then several independent classes).
  *  HoundEventHandler now called HOUND.EventHandler please make sure to update you scripts
## 0.3.x to 0.4.x
  * [Site markers](#map-markers) are toggled seperatly then the normal map markers. If you really want nothing, you need to add `HoundInstance:disableSiteMarkers()` to your Hound setup.
  * HOUND.Contact class has been refactord and split to multiple classes. if you call HOUND.Contact directly in custom scripts you'll need to rename it to HOUND.Contact.Emitter
  * Export has been refactord to suport new site groupings, see [exports](#exports)

# Full Documentation
  * [Main script Documentation](https://uriba107.github.io/DCS-Hound/) - all the options available for the avarage mission builder, even those I didn't write here
  * [Developers Documentation](https://uriba107.github.io/DCS-Hound/dev_docs/) - this is actually everything. You don't need this unless you intend to hack your way to glory.
  * [Scripting Ideas](SCRIPTING_IDEAS.MD) - A random bunch of scripting ideas. Most are half baked and not working, They are here to inspire. feel free to suggest more via an issue or Pull-Request.


# Special thanks
  * __Grimes__ - For [MIST](https://github.com/mrSkortch/MissionScriptingTools) and because Without the [Hoggit Wiki](https://wiki.hoggitworld.com/) we would all be fumbling in the dark.
  * __[flywaldair](https://github.com/walder)__ - Hound was initially inspired by [Skynet IADS](https://github.com/walder/Skynet-IADS).
  * __[Ciribob](https://github.com/ciribob)__ - without his help, support and acceptence of wierd merge requests. Hound would have never been possible.
  * __[rkusa](https://github.com/rkusa)__,__[rurounijones](https://github.com/rurounijones)__ and everyone involved for [DCS-gRPC](https://github.com/DCS-gRPC/rust-server).
  *  __[Pene](https://github.com/Penecruz)__, for being a sport and trying out all manner of builds. And to the rest of the __[DCS ANZUS](https://discord.gg/mCQw9Wm5Qq)__ for allowing him to keep doing that :)
  * __Nikos__, __[Jester](https://github.com/hbjonsson)__, __[davidp57](https://github.com/davidp57)__ and all the rest - For the feeback and suggestions pushing Hound even further

And a very special thanks is (and will always be) reserved to those who choose to click the button below :) 
[![Donate with PayPal](https://www.paypalobjects.com/en_US/i/btn/btn_donate_LG.gif)](https://www.paypal.com/donate?business=RDGX965BT5MT4&no_recurring=1&item_name=Thank+you+for+choosing+this+way+to+show+your+appreciation%21+&currency_code=USD)  
