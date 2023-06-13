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
data structure of each record will follow this pattern.
```lua
{
    typeName = <String ("straight flush","P-19")> 
    uid = <int (2 digits)> 
    DCSobjectName = <String (Name of actual DCS Unit)>
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
TrackId,NatoDesignation,RadarType,State,Bullseye,Latitude,Longitude,MGRS,Accuracy,lastSeen,DCStype,DCSunit,DCSgroup,ReportGenerated
```

Sample data
```csv
TrackId,NatoDesignation,RadarType,State,Bullseye,Latitude,Longitude,MGRS,Accuracy,lastSeen,DCStype,DCSunit,DCSgroup,ReportGenerated
I-1,2,Fan-song,Down,187/78,33.721733,35.800634,36S YC 5951 3482,Precise,1700,SNR_75V,SYR_SA-2_TR,SYR_SA-2,1705
I-2,2 or 3,Flat Face,Active,187/78,33.723213,35.799935,36S YC 5944 3498,Precise,1705,p-19 s-125 sr,SYR_SA-2_SR,SYR_SA-2,1705
E-12,11 or 17,Snow Drift,Active,186/77,33.734985,35.821898,36S YC 6144 3634,High,1705,SA-11 Buk SR 9S18M1,SYRIA gnd 3 unit1,SYRIA gnd 3,1705
E-10,6,Straight Flush,Active,189/84,33.622484,35.727605,36S YC 5303 2363,High,1705,Kub 1S91 str,SYRIA gnd 2 unit1,SYRIA gnd 2,1705
E-11,6,Straight Flush,Active,181/71,33.845855,35.952393,36S YC 7318 4898,Very High,1705,Kub 1S91 str,SYRIA gnd 1 unit1,SYRIA gnd 1,1705
E-9,EWR,Box Spring,Active,185/96,33.418094,35.864466,36S YC 6636 130,Very Low,1705,1L13 EWR,EWR-SKYNET-1,EWR-SKYNET-0,1705
I-3,EWR,Box Spring,Active,147/60,34.207544,36.618624,37S BT 8059 8773,Precise,1705,1L13 EWR,EWR-SKYNET-4-1,EWR-SKYNET-4,1705
I-4,EWR,Box Spring,Active,191/81,33.678493,35.704000,36S YC 5068 2979,Precise,1705,1L13 EWR,EWR-SKYNET-1-1,EWR-SKYNET-1,1705
I-5,EWR,Box Spring,Active,170/44,34.301650,36.114852,37S BT 3446 9937,Precise,1705,1L13 EWR,EWR-SKYNET-5-1,EWR-SKYNET-5,1705
I-6,EWR,Box Spring,Active,200/75,33.820852,35.486437,36S YC 3012 4507,Precise,1705,1L13 EWR,EWR-SKYNET-6-1,EWR-SKYNET-6,1705
I-7,EWR,Box Spring,Active,185/64,33.950048,35.878007,36S YC 6597 6034,Precise,1705,1L13 EWR,EWR-SKYNET-2-1,EWR-SKYNET-2,1705
I-8,EWR,Box Spring,Active,183/52,34.151685,35.911686,36S YC 6845 8280,Precise,1705,1L13 EWR,EWR-SKYNET-3-1,EWR-SKYNET-3,17050
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
