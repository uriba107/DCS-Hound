do
    if STTS ~= nil then
        STTS.DIRECTORY = "C:\\Program Files\\DCS-SimpleRadio-Standalone"
    end


--------------------------- HOUND EventHandler SETUP ---------------------------
-- starting with events because I want to catch the Hound enable event normally, this will be done later

    HoundTriggers = {}
    function HoundTriggers.dumpCsv(interval)
        HoundBlue:dumpIntelBrief()
        if interval then
            return timer.getTime() + interval
        end
    end
    -- HoundTriggers.taskId = timer.scheduleFunction( HoundTriggers.dumpCsv, 300, timer.getTime() + 30 )
    HoundTriggers.taskId = nil

    function HoundTriggers:onHoundEvent(event)
        if event.coalition == coalition.side.BLUE then
            if event.id == HOUND.EVENTS.RADAR_DESTROYED then
                local contact = event.initiator
                local SAM = Group.getByName(contact:getDcsGroupName())
                if SAM and SAM:getSize() > 0 and
                    HOUND.setContainsValue({HOUND_MISSION.SA6.North,HOUND_MISSION.SA6.South,HOUND_MISSION.SA6.Joker},SAM)
                    then
                        timer.scheduleFunction(HOUND_MISSION.SA6.cleanup, SAM, timer.getTime() + math.random(30,60))
                end
            end
            if event.id == HOUND.EVENTS.HOUND_ENABLED then
                HoundTriggers.taskId = timer.scheduleFunction( HoundTriggers.dumpCsv, 300, timer.getTime() + 30 )
            end
            if event.id == HOUND.EVENTS.HOUND_DISABLED then
                if HoundTriggers.taskId then
                    timer.removeFunction(HoundTriggers.taskId)
                end
            end
        end
    end

    HOUND.addEventHandler(HoundTriggers)


--------------------------- HOUND SETUP ---------------------------

    HoundBlue = HoundElint:create(coalition.side.BLUE)

    -- HoundBlue:addPlatform("ELINT North") -- C-130
    -- HoundBlue:addPlatform("ELINT South") -- C-130
    -- HoundBlue:addPlatform("ELINT Galil") -- C-130
    for elintUnitName,_ in pairs(HOUND.Utils.Filter.unitsByPrefix("ELINT ")) do
        HoundBlue:addPlatform(elintUnitName)
    end

    -- HoundBlue:addPlatform("ELINT HERMON") -- Ground Station
    -- HoundBlue:addPlatform("ELINT MERON") -- Ground Station
    for elintObjectName,_ in pairs(HOUND.Utils.Filter.staticObjectsByPrefix("ELINT ")) do
        HoundBlue:addPlatform(elintObjectName)
    end

    HoundBlue:addSector("Lebanon")
    HoundBlue:addSector("Northern Israel")
    -- HoundBlue:addSector("North Syria")
    -- HoundBlue:addSector("South Syria")

    local controller_args = {
        freq = "251.000,122.000,35.000,3.500",
        modulation = "AM,AM,FM,AM",
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
    HoundBlue:setZone("Northern Israel","Sector_Israel")

    HoundBlue:setMarkerType(HOUND.MARKER.POLYGON)
    HoundBlue:enableMarkers()
    HoundBlue:enableBDA()

    HoundBlue:preBriefedContact('SYR_SA-2')
    HoundBlue:setAlertOnLaunch(true)

    for ewrUnitName,_ in pairs(HOUND.Utils.Filter.unitsByPrefix("EWR-")) do
        HoundBlue:preBriefedContact(ewrUnitName)
    end

    HoundBlue:setCallsignOverride({
        Colt = '*',
        Chaos = '*'
    })
    HoundBlue:systemOn()

    humanElint = {}
    function humanElint:onEvent(DcsEvent)
        if DcsEvent.id == world.event.S_EVENT_BIRTH then
            if HoundBlue and DcsEvent.initiator and DcsEvent.initiator:getCoalition() == HoundBlue:getCoalition()
            and DcsEvent.initiator:getTypeName() == "AJS37" and DcsEvent.initiator:getPlayerName()
            then
                env.info("Adding Human Viggen " .. DcsEvent.initiator:getPlayerName())
                HoundBlue:addPlatform(DcsEvent.initiator:getName())

                -- Remove the C-130s
                -- HoundBlue:removePlatform("ELINT North") -- C-130
                -- HoundBlue:removePlatform("ELINT South") -- C-130
                -- HoundBlue:removePlatform("ELINT Galil") -- C-130
            end
        end
        if DcsEvent.id == world.event.S_EVENT_PLAYER_LEAVE_UNIT then
            if HoundBlue and DcsEvent.initiator and DcsEvent.initiator:getCoalition() == HoundBlue:getCoalition()
                and DcsEvent.initiator:getTypeName() == "AJS37" and HOUND.setContainsValue(HoundBlue:listPlatforms(),DcsEvent.initiator:getName())
            then
                HoundBlue:removePlatform(DcsEvent.initiator:getName())
            end
        end
    end

    world.addEventHandler(humanElint)
end