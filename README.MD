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
Same goes to Fast movers like the Viggen or the Su-25T. they can dash into enemy teritory and help you find the radars trying to hide. 

Remember that the system is using a simulated DF to determin the bearing of the radar from the platform. Low precision systems will cause the calculated position to be with a higher ellipse of uncertenty for radar position. below you can find the list of working units and their sensor precision.

Resolution of platforms are derrived from antenna size and emitter frequency. shout out to TLTeo for explaining the physics of this.

``` Note: While currently not implemented. Intention of including both Viggen and the Su-25T is that they will only be able to participate if they are carrying their ELINT and SEAD pods respectivly ```  


## Available assets
### Airborn assets
#### Airplanes
---
| Platform  | Accuracy (C/H Bands degrees)|
| --------  | -------- |
| C-130     | 0.65 / 0.07 |
| C-17      | 0.46 / 0.05 |
| An-30M    | 0.92 / 0.10 |
| Tu-95     | 0.46 / 0.05 |
| Tu-142    | 0.46 / 0.05 |
| IL-76MD   | 0.60 / 0.06 |
| S-3B      | 1.59 / 0.17 |
| E-2D      | 6.54 / 0.70 |
| E-3A      | 5.09 / 0.55 |
| An-26B    | 0.98 / 0.10 |
| A-50      | 5.09 / 0.55 |
| Viggen    | 14.31 / 1.53 |
| Su-25T    | 14.31 / 1.53 |  

<sup>*</sup> Data with resolution below 15 deg is rejected
  
#### Helicopters
---
| Platform  | Accuracy (C/H Bands degrees)|
| --------  | --------  |
| CH-47D    | 1.91 / 0.20 |
| CH-53E    | 2.29 / 0.25 |
| MIL-26    | 1.15 / 0.12 |
| UH-60A    | 2.86 / 0.31 |
| SH-60B    | 2.86 / 0.31 |
| Mi-8MT    | 2.86 / 0.31 |
| UH-1H     | 5.73 / 0.61 |
| Ka-27     | 5.73 / 0.61 |  

### Ground Units
| Platform  | Accuracy (C/H Bands degrees)|
| --------  | --------  |
| SPK-11    | 1.53 / 0.16 |
| MLRS FDDM | 1.53 / 0.16 |  

### Static Objects
| Platform  | Accuracy (C/H Bands degrees)|
| --------  | --------  |
| Comms tower M | 0.29 / 0.03 |

### Community Mods
| Platform  | Accuracy (C/H Bands degrees)|
| --------  | -------- |
| Anubis C-130J | 0.65 / 0.07 |
| VSN EA-6B Prowler   |  2.54 / 0.27  |

## Can I haz syntax pls?
Yes you can.
if upgrading from Hound 0.1 please see [Breaking changes](#breaking-changes)

# Adding Hound to a Mission
### Required external scripts
[MIST (by mrSkortch)](https://github.com/mrSkortch/MissionScriptingTools/releases/latest)  
[DCS-SimpleTextToSpeech (by ciribob)](https://github.com/ciribob/DCS-SimpleTextToSpeech) - Optional (required for TTS)

`
for TTS you'll need to set up STTS properly. consult Ciribob's repo for that. You will require you to comment out the sanitation in "DCS World/Scripts/MissionScripting.lua"
`

### adding scripts in mission editor
``` NOTE the order of scripts - it's important ```  
on a "ONCE" type action with "time more 1" condition, add the scripts in the following order
1. `MIST`
2. `DCS-SimpleTextToSpeech` (if TTS is desired)
3. `HoundElint.lua`

#### some screenshot as hints

![Add scripts](/images/hound_setup.jpg)

### Minimum required Code to get Hound working
---
The bare minumum, more customization optionas are available.
```lua
do
  Elint_blue = HoundElint:create(coalition.side.blue)
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
# Deep Dive
---
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
## Global settings
Global settings are bet set early, which is why I'm listing them here. However they might effect resources that will only be explained later in this document. So if something looks out of place, don't worry about it.

---
### Map markers
Hound uses Map markers to indicate the estimated position of the radar tracket. It's a product of the system, and only contains data user can get from the system in other ways. (equvilant to making marks on a paper map)
Map markers are enabled by default

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

the available marker types are:
|  HOUND.MARKER | Description |
| ---- | ------------|
| NONE | no ellipse is drawn (only position marker)|
| CIRCLE | a circle of uncertenty will be drawn |
| DIAMOND | a diamond will be drawn with 4 points representing uncertenty ellipse |
| OCTAGON | ellipse will be drawn with 8 points (diamon with midpoints) |
| POLYGON | ellipse will be drawn as a 16 sides polygon |

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
---
### Reposition Controller radio menu
By default the [Controller](#sam-controller) will generate the "ELINT" root menu in the base F10 menu.
You may choose to change this to a different base location in some cases.  
`NOTE: there a needs to be a very clear order of events for this to function properly` 
```lua
-- target menu MUST be created BEFORE it's assigned to Radio menu
    SuperDuperMenu = missionCommands.addSubMenuForCoalition(coalition.side.BLUE,"Fantastic functionality")

-- new parent menu must be called BEFORE calling enableController (but can be after configureController if called separately)
    HoundInstance:setRadioMenuParent(SuperDuperMenu)

-- after parent has been assinged you can enable controller
    HoundInstance:enableController()
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
`6, ACTIVE, BULLSEYE 012 of 13, accuracy very high`

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
#### ***Text messages***
By default Hound will only broadcast using SRS. You can optionally enable Text messages of all controller messages (ATIS and notifier will remain Voice only). Text notification will only show up for groups that are currently checked in with a controller. enable and disable is per-sector
```lua
    HoundInstance:enableText("sectorName")
    HoundInstance:disableText("anotherSector")
```
or to all of them using the "all" keyword
```lua
    HoundInstance:enableText("all")
```
#### ***TTS transmissions***
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
#### ***Zones***
Geofencing a sector will be achived by assigning a "Zone".
It's following the standard DCS method of using a group waypoints. it's recommended to add a helicopter group set for late activation.
it is then added to the sector using the following:
```lua
    HoundInstance:setZone("sectorName","GroupName")
```

You can also get the currently set zone on the sector (nil means not zone is set)
```lua
    HoundInstance:getZone("sectorName")
```

To remove a zone from sector use:
```lua
    HoundInstance:removeZone("sectorName")
```

#### ***Transmitter***
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
#### ***Callsigns***
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
## Text-To-Speech
In addition to the map markers described above. Hound is utilizing Text-To-Speech to provide the player with information via SRS.
The three communication types are:
  * Automated Information System [ATIS system](#atis-system)
  * User interactable [SAM controller](#sam-controller)
  * Alert Agency dubbed [Notifier](#notifier)

they are all configureable as will be described the [Text-To-Speach configuration](#text-to-speach-configuration) segment below.

#### ATIS system
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

##### **additional settings**
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
#### SAM controller
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
 ##### ***Additional settings***
 By default a controller will alert you on new radars detected and on dead emitters.
 you can disable all controller alerts (does not affect the [Notifier](#notifier)).
 ```lua
    HoundInstance:disableAlerts("Sukhumi")
-- enable again (default behaviour)
    HoundInstance:enableAlerts("Sukhumi")

-- and set for all of them with
    HoundInstance:disableAlerts("all")
```
 #### Notifier
 ---
 This, as the name suggests is notification only agent. it functions independently of controller or ATIS and will only report pop-up and if enable radar destruction alerts. this is intended to be operated on a different freqency then the controller (which has the same alerting capacity). This may be used for improving SA on Air-To-Air frequency or on general strike channels.
 
 Notifier has a special case when used under "default" sector when radar is inside a geofenced sector. In this scenario it will report using sector name rather then with location. for example:
  * Normal: `Attention All Aircraft! This is HOUND. New threat detected! Straight flush 11 is now Alive, bullseye XXX for YY, Grid ZZ 1 4.`<br>
  * Special case: `Attention All Aircraft! this is HOUND. New thread detected! Straigh flush 11 is now Alive in Bander Abbas.`

  by default it will broadcast on 243.000AM and 121.500AM, i.e Guard frequency. but will accept [TTS configuration](#text-to-speach-configuration).

  Example snippets:
  ```lua
    -- enable on default sector with default settings
    HoundInstance:enableNotifier()
    -- enable with custom config on seperate sector
    HoundInstace:enableNotifier("Bander Abbas",notifier_config)

    -- configure and set frequency inline without enabling
    HoundInstace:enableNotifier("Qeshem",{freq=254,modulation="AM",gender="male"})
  ```

#### Text-To-Speach configuration
---
Oviously, you may want to tweak the radio to better work with you mission.
this can be done using an arguments table and passing it to the configuration funtion.

possible settings are:
```lua
        args = {
            freq = 250.000,
            modulation = "AM",
            volume = "1.0",
            speed = <speed> -- number default is 0/1 for controller/atis. range is -10 to +10 on windows TTS. for google it's 0.25 to 4.0
            gender = "male"|"female",
            culture = "en-US"|"en-UK" -- (any installed on your system)
            isGoogle = true/false -- use google TTS (requires additional STTS config)
        }
```
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

## Event handlers
Introduced with Hound 0.2 you now have Hound event handling. This for example allows you to preform scripted actions on specific events.
available events are (Note that reserved events are not yet emitted):
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
| SITE_NEW  | 15 (RESERVED)|
| SITE_CREATED  | 16 (RESERVED)|
| SITE_UPDATED  | 17 (RESERVED)|
| SITE_REMOVED  | 18 (RESERVED)|
| SITE_ALIVE  | 19 (RESERVED) |
| SITE_ASLEEP |  20 (RESERVED) |

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
CustomHoundScript = {}
function CustomHoundScript:onHoundEvent(houndEvent)
    if houndEvent.id == HOUND.EVENTS.PLATFROM_DESTROYED and houndEvent.coalition == coalition.side.BLUE then
       trigger.action.outTextForCoalition(houndEvent.coalition,initiator:getName() .. "has been destroyed")
    end
end

HoundInstace:addEventHandler(CustomHoundScript)
```
to remove use
```lua
HoundInstace:removeEventHandler(CustomHoundScript)
```
`NOTE: Event handlers are global so make sure you validate coalition or houndId as the event might be from a different Instance from a different coalition`

---
## Known Issues
  * On initial detection accuracy will usually be very high with solution nowhere near the radar actual position. This is sorted by the system as more datapoints are gathered. allow at least 2 minutes for contact to stablize.
  * Adding low resolution platforms will degrade the solution as Hound currently does not reject "bad data".
  * Demo missions have not been updated (except for `Syria_HARM`)

## Breaking changes
If you are upgrading from 0.1 please note that some changes will be required.
  * `enableController()` no longer accepts boolean to enable or disable text. please use [`enableText()`](#text-messages) call.
  * every function that has `ATIS` in it needs to be changesd to have `Atis` - note the capitalization.

## More Docs
  * [Main script Documentation](https://uriba107.github.io/DCS-Hound/) - all the options available, even those I didn't write here
  * [Developers Documentation](https://uriba107.github.io/DCS-Hound/dev_docs/) - this is actually everything. You don't need this unless you intend to hack your way to glory.

## Special thanks
  * __[Ciribob](https://github.com/ciribob)__ - without his help, support and acceptence of wierd merge requests. none of this would have been possible.
  * __Grimes__ - For [MIST](https://github.com/mrSkortch/MissionScriptingTools) and because Without the [Hoggit Wiki](https://wiki.hoggitworld.com/) we would all be fumbling in the dark.
  * __flywaldair__ - Hound was initially inspired by [Skynet IADS](https://github.com/walder/Skynet-IADS).
  * __Nikos__, __[Jester](https://github.com/hbjonsson)__,__[davidp57](https://github.com/davidp57)__ and all the rest - For the feeback and suggestions pushing Hound even further

