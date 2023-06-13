## Text-To-Speech
---
In addition to the map markers described above. Hound is utilizing Text-To-Speech to provide the player with information via SRS.
The three communication types are:
  * Automated Information System [ATIS system](#atis-system)
  * User interactable [SAM controller](#sam-controller)
  * Alert Agency dubbed [Notifier](#notifier)

they are all configureable as will be described the [Text-To-Speach configuration](#text-to-speach-configuration) segment below.

### ATIS system
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

#### **additional settings**
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
### SAM controller
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
 #### ***Additional settings***
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

 #### ***Controller message format***
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

 ### Notifier
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
    HoundInstace:enableNotifier("Qeshem",{freq=254,modulation="AM",gender="male"})
  ```

### Text-To-Speach configuration
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

#### STTS settings
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

#### gRPC.tts settings
```lua
        args = {
            freq = 250.000,
            speed = <speed> -- optional, range is -10 to +10 on windows TTS. you can also specify a number between 50 and 250 which will be treated as speech speeed (100% is normal)
            volume = "1.0", -- optional
            gender = "male"|"female", -- optional
            culture = "en-US"|"en-UK" -- (must be available on you system)
            name = "name_of_voice", -- optional (overrides gender/culture settings)
            provider = {} -- optional gRPC.tts provider settings (consult DCS-gRPC). for example ATIS works with windows TTS. controller via a cloud provider (like AWS or Azure)
      
#### applying the settings
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
