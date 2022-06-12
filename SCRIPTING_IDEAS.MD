
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
Emit all hound events to DCS-gRPC
```lua
    FakeEventHandler = {}
    function FakeEventHandler:onHoundEvent(HoundEvent)
        if (GRPC != nil) then
        local RPCevent = {
            type = "scriptEvent",
            publisher = "hound",
            name = "HoundEvent_"..HoundEvent.id,
            details = HoundEvent

        GRPC.event({
            time = HoundEvent.time,
            event = RPCevent
        })
        end
    end

    HOUND.addEventHandler(FakeEventHandler)
```