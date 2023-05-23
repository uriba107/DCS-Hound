## Global settings
Global settings are best set early, which is why I'm listing them here. However they might effect resources that will only be explained later in this document. So if something looks out of place, don't worry about it.

---
### Map markers
Hound uses Map markers to indicate the estimated position of the radar tracket. It's a product of the system, and only contains data user can get from the system in other ways (equvilant to making marks on a paper map).
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

the available marker types are:
|  HOUND.MARKER | Description |
| ---- | ------------|
| NONE | no ellipse is drawn (only position marker)|
| CIRCLE | a circle of uncertenty will be drawn |
| DIAMOND | a diamond will be drawn with 4 points representing uncertenty ellipse (Default) |
| OCTAGON | ellipse will be drawn with 8 points (diamon with midpoints) |
| POLYGON | ellipse will be drawn as a 16 sides polygon |

`Note: More points causes higher CPU usage. DIAMOND is default`

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