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