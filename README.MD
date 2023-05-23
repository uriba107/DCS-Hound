# Hound ELINT system for DCS
## Overview
**Hound ELINT** is a mission script for DCS. it uses one or more assigned ELINT platforms to approximates location of transmitting enemy radars using triangulation. Platforms are pre-assigned or dynamicly assgined asstes, they can be Airborn, ground units or stationary objects from a set list of assets avialable. 

Hound presents data in sevral methods.

1. F10 map markers indicating estimated position of the Radar, with type and accuracy information for tactical decisions. this works best with "My AC" or "Map only" modes
2. Hound offers a Text-To-Speech ATIS system using SRS. This feature provides a radio channel with constantly updated information about current threats.
3. Detailed information by a "SAM controller" can be provided as TTS (via SRS) and as text messages. 

System can gather information about Enemy radar deployments and help understand the tactical situation or penetrate enemy defences. Because the System is asset based, you also need to be protecting these assets, as if they are destroyed, you loose your tactical data.

Hound requires MIST and is compatible with MOOSE, Skynet IADS and High-Digit SAMs and more.

## Video Intro (YouTube)
[![Hound Cinematic Intro video](https://i.ytimg.com/vi/S4xxtKOqGqU/hq720.jpg?sqp=-oaymwEcCNAFEJQDSFXyq4qpAw4IARUAAIhCGAFwAcABBg==&rs=AOn4CLAAa-SdnDgNiWTKc0YNSvm5RRMa7g)](https://www.youtube.com/watch?v=S4xxtKOqGqU)

## Putting this to work
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

### Ground Units
| Platform  | Accuracy Deg. (C/H Bands) | Min. Band |
| --------  | --------    | - |
| SPK-11    | 1.53 / 0.16 | A |
| MLRS FDDM | 1.53 / 0.16 | A | 

### Static Objects
| Platform  | Accuracy Deg. (C/H Bands) | Min. Band |
| --------  | --------  | --------  |
| Comms tower M | 0.29 / 0.03 | A |

### Community Mods
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
## Can I haz syntax pls?
Yes you can.
if upgrading from Hound 0.1 please see [Breaking changes](#breaking-changes)

# Adding Hound to a Mission
### Required external scripts
[MIST (by mrSkortch)](https://github.com/mrSkortch/MissionScriptingTools/releases/latest)  

Optional scripts - required for TTS (only one of them is required, based on your preference)
[DCS-gRPC](https://github.com/DCS-gRPC/rust-server)
[DCS-SimpleTextToSpeech (by ciribob)](https://github.com/ciribob/DCS-SimpleTextToSpeech)

`For installation of STTS or DCS-gRPC please consult project of choice repo. Both require you to modify "DCS World/Scripts/MissionScripting.lua"
`  
for more information of desanitization process, look [here](README/Appendix.MD#desanitize-dcs-scripting-engine).
### adding scripts in mission editor
``` NOTE the order of scripts - it's important ```  
on a "ONCE" type action with "time more 1" condition, add the scripts in the following order
1. `MIST`
2. `DCS-SimpleTextToSpeech` (if TTS via STTS is desired - gRPC is implemented globally)
3. `HoundElint.lua`

#### some screenshot as hints

![Add scripts](/images/hound_setup.jpg)

### Minimum required Code to get Hound working
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
  -- Elint_blue:enableAtis() -- ATIS requires STTS, as it is voice only
  -- Elint_blue:enableController() -- This will enable Voice+text controller messages
end
```

### Basic Hound setup (YouTube)
[![Hound mission editor video](https://i.ytimg.com/vi/gmJmFR7UCfo/hqdefault.jpg)](https://www.youtube.com/watch?v=gmJmFR7UCfo)

### Advanced config
It doesn't need to make sense to you, there is actually more explenations ahead.
But this is an example of a more compex configuration.
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

### On screen Debug
when this setting is enabled, Hound will print a short status report after each update cycle. (every ~15 seconds by default)
it is controlled by the `onScreenDebug` function. this output is disabled by default
```lua
-- to enable
    HoundBlue:onScreenDebug(true)
-- to disable
    HoundBlue:onScreenDebug(false)
```


# Deep Dive

## Initialization
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
please make sure you go over the [available assets list](#available-assets) of each to determin what would work best for your mission.

## Enrgize

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

```lua
    HoundInstance:preBriefedContact('UNIT_NAME')
    HoundInstance:preBriefedContact('GROUP_NAME')

```
---
## Additional Settings and examples
### [Global Settings](README/Global-settings.MD)
---
### [Sectors](README/Sectors.MD)
---
### [Text-To-Speech](README/Text-To-Speach.MD)
---
### [Event Handlers](README/Event-Handlers.MD)
---
### [Performace Tuning](README/Appendix.MD#performace-tuning)
---
### [Exports](README/Appendix.MD#exports)
#### [LUA Export](README/Appendix.MD#lua-export)
#### [CSV export](README/Appendix.MD#csv-export)
---
### [Desanitize DCS Scripting Engine](README/Appendix.MD#desanitize-dcs-scripting-engine)
---
## Known Issues
  * On initial detection accuracy will usually be very high with solution nowhere near the radar actual position. This is sorted by the system as more datapoints are gathered. allow at least 2 minutes for contact to stablize.
  * Adding low resolution platforms will degrade the solution as Hound currently does not reject "bad data". Hound will drop readings that have more then 10 degrees of error. but if resolution is above the threashold, but very far away, it may still degrate the resolution.
  * Overlapping of sectors is currently not recommended. you can add a small high priority sector on top of a larger sector, but this is the ONLY tested overlap, and there might be some un-expected behavour with that.
  * MIST 4.4 is REQUIRED. However if used with MIST 4.5.103+ some a additional functionality is enabled. (e.g SAM that threaten sectors )

## Breaking changes
### 0.1.X to 0.2.X
If you are upgrading from 0.1 please note that some changes will be required.
  * `enableController()` no longer accepts boolean to enable or disable text. please use [`enableText()`](#text-messages) call.
  * Every function that has `ATIS` in it needs to be changesd to have `Atis` - note the capitalization.
  * "name" argument passed in the TTS config table is no longer used. (silent failure)
  * `setTransmitter()` is now a sector function. in general passing everything directly to `Instance.controller` or `Instance.atis` will no longer work due to changes in the internal architecture. 
### 0.2.X to 0.3.X 
From 0.2 to 0.3 there was an internal change and all classes (except form `HoundElint`) where wrapped into `HOUND` class (rather then several independent classes).
  *  HoundEventHandler now called HOUND.EventHandler please make sure to update you scripts

## More Docs
  * [Main script Documentation](https://uriba107.github.io/DCS-Hound/) - all the options available for the avarage mission builder, even those I didn't write here
  * [Developers Documentation](https://uriba107.github.io/DCS-Hound/dev_docs/) - this is actually everything. You don't need this unless you intend to hack your way to glory.
  * [Scripting Ideas](SCRIPTING_IDEAS.MD) - A random bunch of scripting ideas. feel free to suggest more via an issue or Pull-Request.


## Special thanks
  * __Grimes__ - For [MIST](https://github.com/mrSkortch/MissionScriptingTools) and because Without the [Hoggit Wiki](https://wiki.hoggitworld.com/) we would all be fumbling in the dark.
  * __[flywaldair](https://github.com/walder)__ - Hound was initially inspired by [Skynet IADS](https://github.com/walder/Skynet-IADS).
  * __[Ciribob](https://github.com/ciribob)__ - without his help, support and acceptence of wierd merge requests. none of this would have been possible.
  * __[rkusa](https://github.com/rkusa)__,__[rurounijones](https://github.com/rurounijones)__,__[Binary](https://discord.com/users/Binary#0001)__ and everyone involved for [DCS-gRPC](https://github.com/DCS-gRPC/rust-server).
  *  __[Pene](https://github.com/Penecruz)__, for being a sport and trying out all manner of builds. And to the rest of the __[DCS ANZUS](https://discord.gg/mCQw9Wm5Qq)__ for allowing him to keep doing that :)
  * __Nikos__, __[Jester](https://github.com/hbjonsson)__, __[davidp57](https://github.com/davidp57)__ and all the rest - For the feeback and suggestions pushing Hound even further

And a very special thanks is (and will always be) reserved to those who choose to click the button below :) 

[![Toss A coin to your witcher](https://www.paypalobjects.com/en_US/i/btn/btn_donate_LG.gif)](https://www.paypal.com/donate?business=RDGX965BT5MT4&no_recurring=1&item_name=Thank+you+for+choosing+this+way+to+show+your+appreciation%21+&currency_code=USD)  
[Bonus track](https://www.youtube.com/watch?v=waMkFIzvDpE)
