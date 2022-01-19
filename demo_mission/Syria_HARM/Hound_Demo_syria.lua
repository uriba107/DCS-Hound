do
    if STTS ~= nil then
        STTS.DIRECTORY = "C:\\Program Files\\DCS-SimpleRadio-Standalone"
    end

    -- SA-6 activation logic

    SA6 = {}
    SA6.North = nil
    SA6.South = nil
    SA6.template = "SYR_SA6"
    SA6.spawnJoker = function() return (math.random() < 0.4) end
    function SA6.destroy(GroupName)
        env.info("check " .. GroupName)

        local SAM = Group.getByName(GroupName)
        local destroy = true
        for index, data in pairs(SAM:getUnits()) do
            if setContainsValue({"Kub 1S91 str","SA-11 Buk SR 9S18M1","Osa 9A33 ln"},Unit.getTypeName(data)) and (Unit.getLife(data) > 1 or Unit.isExist(data) or (Unit.getLife(data)/Unit.getLife0(data)) > 0.55) then
                destroy = false
            end 
        end
        if destroy then
            SAM:destroy()
        end
        env.info(GroupName .. " destroy " .. tostring(destroy))

        return destroy
    end

    function SA6.activate(SAM)
        SAM:enableEmission(false)
        local control = SAM:getController()
        control:setOnOff(true)
        control:setOption(0,2) -- ROE, Open_file
        control:setOption(9,2) -- Alarm_State, RED
        control:setOption(20,false) -- ENGAGE_AIR_WEAPONS, false
        SAM:activate()
        SAM:enableEmission(true)
    end

    function SA6.GoLive()
        env.info("GoLive")
        if SA6.North == nil or SA6.destroy(SA6.North:getName()) then
            SA6.North = Unit.getByName(mist.cloneInZone(SA6.template,"SA6_North")["units"][1]["name"]):getGroup()
            SA6.activate(SA6.North)
        end

        if SA6.South == nil or SA6.destroy(SA6.South:getName()) then
            -- SA6.South = mist.cloneInZone(SA6.template,"SA6_South")
            SA6.South = Unit.getByName(mist.cloneInZone(SA6.template,"SA6_South")["units"][1]["name"]):getGroup()
            SA6.activate(SA6.South)
        end

        if SA6.spawnJoker and (SA6.Joker == nil or SA6.destroy(SA6.Joker:getName())) then
            SA6.Joker = Unit.getByName(mist.cloneInZone(SA6.randomTemplate(),"Joker_SAM")["units"][1]["name"]):getGroup()
            SA6.activate(SA6.Joker)
        end
    end

    function SA6.randomTemplate()
        local templates = {"SYR_SA6","SYR_SA11","SYR_SA8"}
        return templates[math.random(1,#templates)]
    end

    -- RestartMission = function()
    --     local filename = DCS.getMissionFilename()
    --     net.load_mission(filename)
    -- end

    MAIN_MENU = {
        root = missionCommands.addSubMenuForCoalition(coalition.side.BLUE,"Mission Actions")
    }
    MAIN_MENU.activateSa6 = missionCommands.addCommandForCoalition(coalition.side.BLUE,"Activate SA-6",MAIN_MENU.root,SA6.GoLive)
    -- MAIN_MENU.activateSa6 = missionCommands.addCommandForCoalition(coalition.side.BLUE,"Restart Mission",MAIN_MENU.root,RestartMission)

    -- activate SA6 and keep trigerring it
    mist.scheduleFunction(SA6.GoLive,nil,timer.getTime()+120,600)



    HoundBlue = HoundElint:create(coalition.side.BLUE)
    HoundBlue:addPlatform("ELINT North") -- C-130
    HoundBlue:addPlatform("ELINT South") -- C-130
    HoundBlue:addPlatform("ELINT Galil") -- C-130
    HoundBlue:addPlatform("ELINT HERMON") -- Ground Station
    HoundBlue:addPlatform("ELINT MERON") -- Ground Station

    HoundBlue:addSector("Lebanon")
    -- HoundBlue:addSector("North Syria")
    -- HoundBlue:addSector("South Syria")

    local controller_args = {
        freq = "251.000,122.000,35.000",
        modulation = "AM,AM,FM",
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

    HoundBlue:preBriefedContact('SYR_SA-2')

    HoundBlue:setMarkerType(HOUND.MARKER.POLYGON)
    HoundBlue:enableMarkers()
    HoundBlue:enableBDA()
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
                HoundBlue:removePlatform("ELINT North") -- C-130
                HoundBlue:removePlatform("ELINT South") -- C-130
            end
        end
        if DcsEvent.id == world.event.S_EVENT_PLAYER_LEAVE_UNIT then
            if HoundBlue and DcsEvent.initiator and DcsEvent.initiator:getCoalition() == HoundBlue:getCoalition()
                and DcsEvent.initiator:getTypeName() == "AJS37" and setContainsValue(HoundBlue:listPlatforms(),DcsEvent.initiator:getName())
            then
                HoundBlue:removePlatform(DcsEvent.initiator:getName())
            end
        end
    end

    world.addEventHandler(humanElint)
end