# Event Handlers

Script custom behavior using Hound events (detections, destructions, launches, platform changes).

---

## Available Events

| Category        | Event                                                             | ID    | Description        |
| --------------- | ----------------------------------------------------------------- | ----- | ------------------ |
| **System**      | `HOUND_ENABLED/DISABLED`                                          | 1-2   | System activation  |
| **Platform**    | `PLATFORM_ADDED/REMOVED/DESTROYED`                                | 3-5   | Platform status    |
| **Transmitter** | `TRANSMITTER_ADDED/REMOVED/DESTROYED`                             | 6-8   | Transmitter status |
| **Radar**       | `RADAR_NEW/DETECTED/UPDATED/DESTROYED/ALIVE/ASLEEP`               | 9-14  | Radar tracking     |
| **Site**        | `SITE_NEW/CREATED/UPDATED/CLASSIFIED/REMOVED/ALIVE/ASLEEP/LAUNCH` | 15-22 | SAM site tracking  |

---

## Event Structure

```lua
event = {
    id = HOUND.EVENTS.<enum>,
    coalition = coalition.side.<BLUE/RED>,
    houndId = <instance ID>,
    initiator = <DCS unit or Hound contact>,
    time = <timestamp>
}
```

---

## Creating Handler

```lua
MyHandler = {}

function MyHandler:onHoundEvent(event)
    if event.coalition ~= coalition.side.BLUE then return end

    if event.id == HOUND.EVENTS.RADAR_NEW then
        local contact = event.initiator
        trigger.action.outText("New threat: " .. contact:getName(), 10)
    end
end

HOUND.addEventHandler(MyHandler)
```

---

## Handler Examples

### Mission Objectives

```lua
MissionObjectives = {
    targetSites = {"SA-10_Site_1", "SA-6_Site_2"},
    destroyed = {}
}

function MissionObjectives:onHoundEvent(event)
    if event.coalition ~= coalition.side.BLUE then return end

    if event.id == HOUND.EVENTS.SITE_REMOVED then
        local site = event.initiator
        for _, targetName in ipairs(self.targetSites) do
            if site.DcsGroupName == targetName then
                table.insert(self.destroyed, targetName)
                trigger.action.outText("Objective complete!", 15)

                if #self.destroyed >= #self.targetSites then
                    trigger.action.outText("Mission success!", 30)
                end
            end
        end
    end
end

HOUND.addEventHandler(MissionObjectives)
```

### Score Tracking

```lua
ScoreTracker = {radarKills = 0}

function ScoreTracker:onHoundEvent(event)
    if event.coalition ~= coalition.side.BLUE then return end

    if event.id == HOUND.EVENTS.RADAR_DESTROYED then
        self.radarKills = self.radarKills + 1
        trigger.action.outText("Radars destroyed: " .. self.radarKills, 10)
    end
end

HOUND.addEventHandler(ScoreTracker)
```

---

## Contact Methods

```lua
function MyHandler:onHoundEvent(event)
    if event.id == HOUND.EVENTS.RADAR_NEW then
        local contact = event.initiator

        local name = contact:getName()
        local pos = contact:getPos()
        local accuracy = contact:getAccuracy()
        local dcsName = contact.DcsObjectName
        local isAlive = contact:isAlive()
    end

    if event.id == HOUND.EVENTS.SITE_NEW then
        local site = event.initiator

        local name = site:getName()
        local type = site:getType()
        local emitters = site:getEmitters()
        local pos = site:getPos()
    end
end
```

---

## Important Notes

**Always filter by coalition** - handlers are global and receive events from all instances:

```lua
if event.coalition ~= coalition.side.BLUE then return end
```

**RADAR_DESTROYED caveat** - Unit is dead, `contact.DcsObjectName` is string (name) not object

**Keep handlers lightweight** - fast execution, avoid blocking operations

---

## Managing Handlers

```lua
HOUND.addEventHandler(MyHandler)
HOUND.removeEventHandler(MyHandler)
```

Multiple handlers can be registered and all receive events.
