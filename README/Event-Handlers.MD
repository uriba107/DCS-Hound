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
`RADAR_DESTROYED event is delayed from the DCS Unit destroyed event, so unit is gone by then. unit field in a dead contact is unitName not unit object like on other events. Try and use initiator.DCSgroupName whenever possible`
