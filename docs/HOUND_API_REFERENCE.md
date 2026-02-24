# HOUND ELINT System - Public API Documentation

This document provides public API documentation for the HOUND ELINT system, focusing on functions and classes intended for external use.

*Generated on: 2026-02-25 00:19:36*

## Overview

The HOUND ELINT system provides a public API for mission builders and other scripts to interact with the radar detection system.

## HoundElint

Hound Main interface Elint system for DCS

**Author:** uri_ba
**Copyright:** uri_ba 2020-2021

### Tables and Types

### `HoundElint`

Main entry point

**Type:** HoundElint

### Public Methods and Functions

### `HoundElint:create(platformName)`

create HoundElint instance.

**Parameters:**
- `platformName` (type=int): Platform name or coalition enum

**Returns:**
- (type=tab): HoundElint Instance

### `HoundElint:destroy()`

destructor function initiates cleanup

### `HoundElint:getId()`

get Hound instance ID

**Returns:**
- (type=Int): Int Hound ID

### `HoundElint:getCoalition()`

get Hound instance Coalition

**Returns:**
- (type=int): coalition enum of current hound instance

### `HoundElint:setCoalition(side)`

set coalition for Hound Instance (Internal)

**Parameters:**
- `side` (type=int): coalition side enum

**Returns:**
- (type=bool): Bool. True if coalition was set

### `HoundElint:onScreenDebug(value)`

set onScreenDebug

**Parameters:**
- `value` (type=bool): to set

**Returns:**
- (type=Bool): True if chaned

### `HoundElint:addPlatform(platformName)`

add platform from hound instance

**Returns:**
- (type=bool): True if successfuly added

### `HoundElint:removePlatform(platformName)`

Remove platform from hound instance

**Returns:**
- (type=bool): True if successfuly removed

### `HoundElint:countPlatforms()`

count Platforms

**Returns:**
- (type=int): number of assigned platforms

### `HoundElint:listPlatforms()`

list platforms

**Returns:**
- (type=tab): list of platfoms

### `HoundElint:countContacts(sectorName)`

count contacts

**Parameters:**
- `sectorName` (type=?string): String name or sector to filter by

**Returns:**
- (type=int): number of contacts currently tracked

### `HoundElint:countActiveContacts(sectorName)`

count Active contacts

**Parameters:**
- `sectorName` (type=?string): String name or sector to filter by

**Returns:**
- (type=Int): number of contacts currently Transmitting

### `HoundElint:countPreBriefedContacts(sectorName)`

count preBriefed contacts

**Parameters:**
- `sectorName` (type=?string): String name or sector to filter by

**Returns:**
- (type=int): number of contacts currently in PB status

### `HoundElint:preBriefedContact(DCS_Object_Name, codeName)`

set/create a pre Briefed contacts

**Parameters:**
- `DCS_Object_Name` (type=string): name of DCS Unit or Group to add
- `codeName` (opt): Optional name for site created

### `HoundElint:markDeadContact(radarUnit)`

Mark Radar as dead

**Parameters:**
- `radarUnit` (type=string|tab): DCS Unit, DCS Group or Unit/Group name to mark as dead

### `HoundElint:AlertOnLaunch(fireUnit)`

Issue a Launch Alert

**Parameters:**
- `fireUnit` (type=string|tab): DCS Unit, DCS Group or Unit/Group name currently Launching

### `HoundElint:countSites(sectorName)`

count sites

**Parameters:**
- `sectorName` (type=?string): name or sector to filter by

**Returns:**
- (type=int): number of contacts currently tracked

### `HoundElint:addSector(sectorName, sectorSettings, priority)`

Add named sector

**Parameters:**
- `sectorName` (type=string): name of sector to add
- `sectorSettings` (opt): table of sector settings
- `priority` (opt): Sector priority (lower is higher)

**Returns:**
- (type=bool): True if sector successfully added

### `HoundElint:removeSector(sectorName)`

Remove Named sector

**Parameters:**
- `sectorName` (type=string): name of sector to add

**Returns:**
- (type=bool): True if sector successfully added

### `HoundElint:updateSectorSettings(sectorName, sectorSettings, subSettingName)`

Update named sector settings

**Parameters:**
- `sectorName` (type=string|nil): name of sector (nil == "default")
- `subSettingName` (type=?string): update specific setting ("controller", "atis", "notifier")

**Returns:**
- (type=bool): False if an error occurred, true otherwise

### `HoundElint:listSectors(element)`

list all sectors

**Parameters:**
- `element` (type=?string): list only sectors with specified element. Valid options are "controller", "atis", "notifier" and "zone"

**Returns:**
- (list): of sector names

### `HoundElint:getSectors(element)`

get all sectors

**Parameters:**
- `element` (type=?string): list only sectors with specified element. Valid options are "controller", "atis", "notifier" and "zone"

**Returns:**
- (list): of HOUND.Sector instances

### `HoundElint:countSectors(element)`

return number of sectors

**Parameters:**
- `element` (type=?string): count only sectors with specified element ("controller"/"atis"/"notifier"/"zone")

**Returns:**
- (type=int): . number of sectors

### `HoundElint:getSector(sectorName)`

return HOUND.Sector instance

**Returns:**
- (HOUND.Secto): r

### `HoundElint:enableController(sectorName, settings)`

enable controller in sector

**Parameters:**
- `sectorName` (type=?string): name of sector in which a controller is enabled (default is "default") - "all" enable controller on all sectors

### `HoundElint:disableController(sectorName)`

disable controller in sector

**Parameters:**
- `sectorName` (type=?string): Name of sector to act on. default is "default". all will disable all controllers

### `HoundElint:removeController(sectorName)`

remove controller in sector

**Parameters:**
- `sectorName` (type=?string): Name of sector to act on. default is "default". all will disable all controllers

### `HoundElint:configureController(sectorName, settings)`

configure controller in sector

**Parameters:**
- `sectorName` (type=?string): name of sector to configure

### `HoundElint:getControllerFreq(sectorName)`

get controller freq

**Parameters:**
- `sectorName` (type=?string): name of sector to configure

**Returns:**
- (frequncies): table for sector's controller

### `HoundElint:getControllerState(sectorName)`

get controller state

**Parameters:**
- `sectorName` (type=?string): name of sector to probe

**Returns:**
- (type=Bool): True = enabled. False is disable or not configured

### `HoundElint:transmitOnController(sectorName, msg, priority)`

Transmit custom TTS message on controller freqency

**Parameters:**
- `sectorName` (type=string): name of the sector to transmit on.
- `msg` (type=string): message to broadcast
- `priority` (type=?number): message priority

### `HoundElint:enableAtis(sectorName, settings)`

enable ATIS in sector

**Parameters:**
- `sectorName` (type=?string): name of sector in which a controller is enabled (default is "default") - "all" enable ATIS on all sectors

### `HoundElint:disableAtis(sectorName)`

disable ATIS in sector

**Parameters:**
- `sectorName` (type=?string): Name of sector to act on. default is "default". all will disable all ATIS

### `HoundElint:removeAtis(sectorName)`

remove ATIS in sector

**Parameters:**
- `sectorName` (type=?string): Name of sector to act on. default is "default". all will disable all ATIS

### `HoundElint:configureAtis(sectorName, settings)`

configure ATIS in sector

**Parameters:**
- `sectorName` (type=?string): name of sector to configure

### `HoundElint:getAtisFreq(sectorName)`

get ATIS freq

**Parameters:**
- `sectorName` (type=?string): name of sector to query

**Returns:**
- (frequncies): table for sector's controller

### `HoundElint:reportEWR(name, state)`

set ATIS EWR report state for sector

**Parameters:**
- `name` (type=?string): sector name. valid inputs are sector name, "all". nothing will default to "default"

### `HoundElint:getAtisState(sectorName)`

get ATIS state

**Parameters:**
- `sectorName` (type=?string): name of sector to probe

**Returns:**
- (type=Bool): True = enabled. False is disable or not configured

### `HoundElint:enableNotifier(sectorName, settings)`

enable Notifier in sector Only one notifier is required as it will broadcast on a global frequency (default is guard) controller will also handle alerts for per sector notifications

**Parameters:**
- `sectorName` (type=?string): name of sector in which a Notifier is enabled (default is "default")

### `HoundElint:disableNotifier(sectorName)`

disable Notifier in sector

**Parameters:**
- `sectorName` (type=?string): Name of sector to act on. default is "default". all will disable all Notifiers

### `HoundElint:removeNotifier(sectorName)`

remove controller in sector

**Parameters:**
- `sectorName` (type=?string): Name of sector to act on. default is "default". all will disable all Notifiers

### `HoundElint:configureNotifier(sectorName, settings)`

configure Notifier in sector

**Parameters:**
- `sectorName` (type=?string): name of sector to configure

### `HoundElint:getNotifierFreq(sectorName)`

get Notifier freq

**Parameters:**
- `sectorName` (type=?string): name of sector to query

**Returns:**
- (frequncies): table for sector's Notifier

### `HoundElint:getNotifierState(sectorName)`

get Notifier state

**Parameters:**
- `sectorName` (type=?string): name of sector to probe

**Returns:**
- (type=Bool): True = enabled. False is disable or not configured

### `HoundElint:transmitOnNotifier(sectorName, msg, priority)`

Transmit custom TTS message on Notifier freqency

**Parameters:**
- `sectorName` (type=string): name of the sector to transmit on.
- `msg` (type=string): message to broadcast
- `priority` (type=?number): message priority

### `HoundElint:enableText(sectorName)`

enable Text notification for controller

**Parameters:**
- `sectorName` (type=?string): name of sector to enable (default is "default", "all" will enable on all sectors)

### `HoundElint:disableText(sectorName)`

disable Text notification for controller

**Parameters:**
- `sectorName` (type=?string): name of sector to disable (default is "default", "all" will enable on all sectors)

### `HoundElint:enableTTS(sectorName)`

enable Text-To-Speach notification for controller

**Parameters:**
- `sectorName` (type=?string): name of sector to enable (default is "default", "all" will enable on all sectors)

### `HoundElint:disableTTS(sectorName)`

disable Text-to-speach notification for controller

**Parameters:**
- `sectorName` (type=?string): name of sector to disable (default is "default", "all" will enable on all sectors)

### `HoundElint:enableAlerts(sectorName)`

enable Alert notification for controller

**Parameters:**
- `sectorName` (type=?string): name of sector to enable (default is "default", "all" will enable on all sectors)

### `HoundElint:disableAlerts(sectorName)`

disable Alert notification for controller

**Parameters:**
- `sectorName` (type=?string): name of sector to disable (default is "default", "all" will enable on all sectors)

### `HoundElint:setCallsign(sectorName, sectorCallsign)`

Set sector callsign

**Returns:**
- (type=bool): True if callsign was changes. False otherwise

### `HoundElint:getCallsign(sectorName)`

get sector callsign

**Returns:**
- (String): - callsign for sector. will return empty string if err

### `HoundElint:setTransmitter(sectorName, transmitter)`

set transmitter to named sector valid values are name of sector, "all" or nil (will change default)

**Parameters:**
- `sectorName` (type=string): name of sector to apply to.
- `DCS` (transmitter): unit name which will be the transmitter

### `HoundElint:removeTransmitter(sectorName)`

remove transmitter to named sector valid values are name of sector, "all" or nil (will change default)

**Parameters:**
- `sectorName` (type=string): name of sector to apply to.

### `HoundElint:getZone(sectorName)`

get zone of sector

**Parameters:**
- `sectorName` (type=string): to act on

**Returns:**
- (table): of points or nil if no sector set

### `HoundElint:setZone(sectorName, zoneCandidate)`

add zone to sector same as MOOSE. use late activation invisible helicopter group is recommended.

**Parameters:**
- `sectorName` (type=string): to act on
- `DCS` (zoneCandidate): Group name. Group's waypoints will be used.

### `HoundElint:removeZone(sectorName)`

remove zone from sector

**Parameters:**
- `sectorName` (type=string): to act on

### `HoundElint:updateSectorMembership()`

update sector membership for all contacts

*Note: This is a local function*

### `HoundElint:enableMarkers(markerType)`

enable Markers for Hound Instance (default)

**Parameters:**
- `markerType` (opt): change marker type to use

**Returns:**
- (type=Bool): True if changed

### `HoundElint:disableMarkers()`

disable Markers for Hound Instance

**Returns:**
- (type=Bool): True if changed

### `HoundElint:enableSiteMarkers()`

enable Site Markers for Hound Instance (default)

**Returns:**
- (type=Bool): True if changed

### `HoundElint:disableSiteMarkers()`

disable Site Markers for Hound Instance

**Returns:**
- (type=Bool): True if changed

### `HoundElint:setMarkerType(markerType)`

Set marker type for Hound instance

**Parameters:**
- `valid` (markerType): marker type enum

**Returns:**
- (type=Bool): True if changed

**See also:** HOUND.MARKER

### `HoundElint:setTimerInterval(setIntervalName, setValue)`

set intervals

**Parameters:**
- `interval` (setIntervalName): name to change (scan,process,menu,markers)
- `interval` (setValue): in seconds to set.

**Returns:**
- (type=Bool): True if changed

### `HoundElint:enablePlatformPosErrors()`

enable platforms INS position errors

**Returns:**
- (type=bool): if settings was updated

### `HoundElint:disablePlatformPosErrors()`

disable platforms INS position errors

**Returns:**
- (type=bool): if settings was updated

### `HoundElint:getCallsignOverride()`

get current callsign override table

**Returns:**
- (table): current state

### `HoundElint:setCallsignOverride(overrides)`

set callsign override table

**Parameters:**
- `Table` (overrides): of overrides

**Returns:**
- (type=Bool): True if setting has been updated

### `HoundElint:getBDA()`

get current BDA setting state

**Returns:**
- (type=bool): current state

### `HoundElint:enableBDA()`

enable BDA for Hound Instance Hound will notify on radar destruction

**Returns:**
- (type=Bool): True if setting has been updated

### `HoundElint:disableBDA()`

disable BDA for Hound Instance

**Returns:**
- (type=Bool): True if setting has been updated

### `HoundElint:getNATO()`

Get current state of NATO brevity setting

**Returns:**
- (type=bool): current state

### `HoundElint:enableNATO()`

enable NATO brevity for Hound Instance

**Returns:**
- (type=Bool): True if setting has been updated

### `HoundElint:disableNATO()`

disable NATO brevity for Hound Instance

**Returns:**
- (type=Bool): True if setting has been updated

### `HoundElint:getAlertOnLaunch()`

get Alert on launch for Hound Instance

**Returns:**
- (type=Bool): Current state

### `HoundElint:setAlertOnLaunch(value)`

set Alert on Launch for Hound instance

**Returns:**
- (type=Bool): True if setting has been updated

### `HoundElint:useNATOCallsignes(value)`

set flag if callsignes for sectors under Callsignes would be from the NATO pool

**Returns:**
- (type=Bool): True if setting has been updated

### `HoundElint:setAtisUpdateInterval(value)`

set Atis Update interval

**Parameters:**
- `desired` (value): interval in seconds

**Returns:**
- (true): if change was made

### `HoundElint:setRadioMenuParent(parent)`

Set Main parent menu for hound Instace must be set <b>BEFORE</b> calling <code>enableController()</code>

**Parameters:**
- `desired` (parent): parent menu (pass nil to clear)

**Returns:**
- (type=Bool): True if no errors

### `HoundElint.runCycle(self)`

Scheduled function that runs the main Instance loop

**Returns:**
- (time): of next run

*Note: This is a local function*

### `HoundElint:purgeRadioMenu()`

Purge the root radio menu

*Note: This is a local function*

### `HoundElint:populateRadioMenu()`

Trigger building of radio menu in all sectors

*Note: This is a local function*

### `HoundElint.updateSystemState(params)`

Update the system state (on/off) TODO: remove?

**Parameters:**
- `table` (params): {self=&ltHoundInstance&gt,state=&ltBool&gt}

*Note: This is a local function*

### `HoundElint:systemOn(notify)`

Turn Hound system on

### `HoundElint:systemOff(notify)`

Turn Hound system off

### `HoundElint:isRunning()`

is Instance on

**Returns:**
- (type=bool): , True if system is running

### `HoundElint:getContacts()`

get an exported list of all contacts tracked by the instance

**Returns:**
- (table): of all contact tracked for integration with external tools

### `HoundElint:getSites()`

get an exported list of all sites tracked by the instance

**Returns:**
- (table): of all contact tracked for integration with external tools

### `HoundElint:dumpIntelBrief(filename)`

dump Intel Brief to csv will dump intel summery to CSV in the DCS saved games folder requires desanitization of lfs and io modules

**Parameters:**
- `filename` (opt): target filename. (default: hound_contacts_%d.csv)

### `HoundElint:printDebugging()`

return Debugging information

**Returns:**
- (strin): g

---

## HoundElint

Hound Main interface Elint system for DCS

**Author:** uri_ba
**Copyright:** uri_ba 2020-2021

### Public Methods and Functions

### `HoundElint:onHoundEvent(houndEvent)`

builtin prototype for onHoundEvent function this function does NOTHING out of the box. put you own code here if needed

**Parameters:**
- `incoming` (houndEvent): event

### `HoundElint:onHoundInternalEvent(houndEvent)`

built in onHoundEvent function

**Parameters:**
- `incoming` (houndEvent): event

*Note: This is a local function*

### `HoundElint:onEvent(DcsEvent)`

built in dcs onEvent

**Parameters:**
- `incoming` (DcsEvent): dcs event

*Note: This is a local function*

### `HoundElint:defaultEventHandler(remove)`

enable/disable Hound instance internal event handling

*Note: This is a local function*

---

## HOUND - Global Functions

Hound Elint system for DCS

### Global Configuration and Enums

### `HOUND`

Global settings and paramters

**Fields:**
- `VERSION`: Hound Version
- `DEBUG`: Hound will do extended debug output to log (for development)
- `ELLIPSE_PERCENTILE`: Defines the percentile of datapoints used to calculate uncertenty ellipse
- `DATAPOINTS_NUM`: Number of datapoints per platform a contact keeps (FIFO)
- `DATAPOINTS_INTERVAL`: Time between stored data points
- `CONTACT_TIMEOUT`: Timout for emitter to be silent before being dropped from contacts
- `MAX_ANGULAR_RES_DEG`: The maximum (worst) platform angular resolution acceptable
- `ANTENNA_FACTOR`: Global factor of antenna size (bigger antenna == better accuracy). Allows mission builder to quickly nerf or boost hound performace (default 1.0).
- `MGRS_PRECISION`: Number of digits in MGRS conversion
- `EXTENDED_INFO`: Hound will add more in depth uncertenty info to controller messages (default is true)
- `FORCE_MANAGE_MARKERS`: Force Hound to use internal counter for markIds (default is true).
- `USE_LEGACY_MARKERS`: Force Hound to use normal markers for radar positions (default is true)
- `MARKER_MIN_ALPHA`: Minimum opacity for area markers
- `MARKER_MAX_ALPHA`: Maximum opacity for area markers
- `MARKER_LINE_OPACITY`: Opacity of the line around the area markers
- `MARKER_TEXT_POINTER`: Char/string used as pointer on text markers
- `TTS_ENGINE`: Hound will use the table to determin TTS engine priority
- `MENU_PAGE_LENGTH`: Number of Items Hound will put in a menu before starting a new menu page
- `REF_DIST`: Reference distance for contact scoring. Used to calculate the weight of datap
- `ENABLE_KALMAN`: If true, will use Kalman filter for contact scoring (currently not implemented, default is false)
- `AUTO_ADD_PLATFORM_BY_PAYLOAD`: If true, will automatically add platforms that have ELINT payloads (currently, due to DCS limits, only works for units spawning with the required pods)

### `HOUND.MARKER`

Map Markers ENUM

**Fields:**
- `NONE`: no markers are drawn
- `SITE_ONLY`: only site markers are drawn
- `POINT`: only draw point marker for emitters
- `CIRCLE`: a circle of uncertenty will be drawn
- `DIAMOND`: a diamond will be drawn with 4 points representing uncertenty ellipse
- `OCTAGON`: ellipse will be drawn with 8 points (diamon with midpoints)
- `POLYGON`: ellipse will be drawn as a 16 sides polygon

### `HOUND.EVENTS`

Hound Events

**Fields:**
- `NO_CHANGE`: nothing changed in the object
- `HOUND_ENABLED`: Hound Event
- `HOUND_DISABLED`: Hound Event
- `PLATFORM_ADDED`: Hound Event
- `PLATFORM_REMOVED`: Hound Event
- `PLATFORM_DESTROYED`: Hound Event
- `RADAR_NEW`: Hound Event
- `RADAR_DETECTED`: Hound Event
- `RADAR_UPDATED`: Hound Event
- `RADAR_DESTROYED`: Hound Event
- `RADAR_ALIVE`: Hound Event
- `RADAR_ASLEEP`: Hound Event
- `SITE_NEW`: Hound Event
- `SITE_CREATED`: Hound Event
- `SITE_UPDATED`: Hound Event
- `SITE_CLASSIFIED`: Hound Event
- `SITE_REMOVED`: Hound Event
- `SITE_ALIVE`: Hound Event
- `SITE_ASLEEP`: Hound Event
- `SITE_LAUNCH`: Hound Event

### `HOUND.INSTANCES`

Hound Instances every instance created will be added to this list with it's HoundId as key.

### `HOUND.Contact`

setup for inheritance classes

### Global Utility Functions

### `HOUND.getInstance(InstanceId)`

Get instance get hound instance by ID

**Parameters:**
- `InstanceId` (type=number): instance ID to get

**Returns:**
- (Hound): Instance object or nil

### `HOUND.setMgrsPresicion(value)`

set default MGRS presicion for grid calls

**Parameters:**
- `(Int)` (value): Requested value. allowed values 1-5, default is 3

### `HOUND.showExtendedInfo(value)`

set detailed messages to include or exclude extended tracking data if true, will read and display extended ellipse info and tracking times. (default) if false, will skip that information. only the shortened info will be used

**Parameters:**
- `(Bool)` (value): Requested state

### `HOUND.addEventHandler(handler)`

register new event handler (global)

**Parameters:**
- `handler` (handler): to register

**See also:** HOUND.EVENTS

### `HOUND.removeEventHandler(handler)`

deregister event handler (global)

**Parameters:**
- `handler` (handler): to remove

**See also:** HOUND.EVENTS

---
