
# Hound Scripting Ideas.
This document contains ideas that might be intresting to try and implement in missions.
Having a full implementation is not important, Ideas may contain snippets, or psudo code, but it's not madetory.
This section is primarly here to inspire new ideas and concepts. so feel free to submit PR or open an issue with you ideas.

`NOTE: Unless specifically stated, assume all code here to be un-tested`

## Add radars detected by UAV/Recon flight
Hound has "Pre-briefed" target accasition mode. This can be added in RT. 
For example. an "assigned" recon platform for example a UAV.  
Every once in a while perform [getDetectedTargets](https://wiki.hoggitworld.com/view/DCS_func_getDetectedTargets), and add Visually detected radar units as pre-briefed targets to Hound.

##### extended version
Use Hound's RADAR_DETECTED event to change the route of some unit that will perform the visual detection of the radar to add it as bre-briefed contact.
something along the lines of
```lua
function PBviaUnit(HoundInstance,unitName)
    local IntelUnit = Unit.getByName(unitName)
    if not IntelUnit then return end
    local controller = IntelUnit:getController()
    if not controller then retun end
    local visTargets = IntelUnit:getDetectedTargets(Conroller.Detection.VISUAL,Conroller.Detection.OPTIC)
    for _,contact in pairs(visTargets) do
        if contact.visible and contact.type then
            local candidate = contact.object
            local type = candidate:getTypeName()
            if  HOUND.DB.Radars[type] then
                HoundInstance:preBriefedContact(candidate:getName())
            end
        end
    end
```

## Send Hound events to DCS-gRPC
Emit all radar related hound events to DCS-gRPC in a serilized form
```lua
    FakeEventHandler = {}
    function FakeEventHandler:onHoundEvent(HoundEvent)
        if (GRPC ~= nil) then
        if HoundEvent.id == if houndEvent.id == HOUND.EVENTS.RADAR_DETECTED or
           HoundEvent.id == HOUND.EVENTS.RADAR_DESTROYED or
           HoundEvent.id == HOUND.EVENTS.RADAR_UPDATED
        then

        local hound_serializeable = {
            id = HoundEvent.id,
            houndId = HoundEvent.houndId,
            coalition = HoundEvent.coalition,
            initiator = HoundEvent.initiator:export()
        }
        local RPCevent = {
            type = "scriptEvent",
            publisher = "hound",
            name = "HoundEvent_"..HoundEvent.id,
            details = hound_serializeable

        GRPC.event({
            time = HoundEvent.time,
            event = RPCevent
        })
        end
    end

    HOUND.addEventHandler(FakeEventHandler)
```

## Restricted Area warning
This was originally done by PeneCruz for the ANZUS community.
When an aircraft violates a restricted airspace, you can use the Notifier or Controller to issue a verbal warning using TTS.
```lua
    function violatedAirspace(unit,last_warning)
        local callsign = HOUND.Utils.getFormationCallsign(unit)
        local msg = callsign .. " You are violating restricted airspace! please reverse course immidiatly!"
        if last_warning then
        msg = msg .. callsign .. " This is your last warning! Change course Immidiatly!"
        end
        HoundInstance:transmitOnNotifier("all",msg,0)
        return HOUND.Utils.TTS.getReadTime(msg)
    end
```