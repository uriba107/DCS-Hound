do
    if STTS ~= nil then
        STTS.DIRECTORY = "C:\\Program Files\\DCS-SimpleRadio-Standalone"
    end

    HOUND_MISSION = {}
    function HOUND_MISSION.randomTemplate(templates)
        if type(templates) ~= "table" then return nil end
        return templates[math.random(1,#templates)]
    end

    -- SA-6 activation logic
    HOUND_MISSION.SA6 = {}
    HOUND_MISSION.SA6.North = nil
    HOUND_MISSION.SA6.South = nil
    HOUND_MISSION.SA6.template = "SYR_SA6"
    HOUND_MISSION.SA6.spawnJoker = function() return (math.random() < 0.4) end
    function HOUND_MISSION.SA6.destroy(GroupName)
        env.info("check " .. GroupName)

        local SAM = Group.getByName(GroupName)
        local destroy = true
        for index, data in pairs(SAM:getUnits()) do
            if setContainsValue({"Kub 1S91 str","SA-11 Buk SR 9S18M1","Osa 9A33 ln"},Unit.getTypeName(data)) and (Unit.getLife(data) > 1 or Unit.isExist(data) or (Unit.getLife(data)/Unit.getLife0(data)) > 0.55) then
                destroy = false
                -- local pos = Unit.getPoint(data)
                -- if HOUND.Utils.Geo.isDcsPoint(pos) then
                --     trigger.action.explosion(pos,250)
                -- end
            end
        end
        if destroy then
            -- SAM:destroy()
            for _, data in pairs(SAM:getUnits()) do
                if setContainsValue({"Kub 1S91 str","SA-11 Buk SR 9S18M1","Osa 9A33 ln"},Unit.getTypeName(data)) then
                    local pos = Unit.getPoint(data)
                    trigger.action.explosion(pos,250)
                end
            end
        end
        -- env.info(GroupName .. " destroy " .. tostring(destroy))
        return destroy
    end

    function HOUND_MISSION.SA6.activate(SAM)
        SAM:enableEmission(false)
        local control = SAM:getController()
        control:setOnOff(true)
        control:setOption(0,2) -- ROE, Open_file
        control:setOption(9,2) -- Alarm_State, RED
        control:setOption(20,false) -- ENGAGE_AIR_WEAPONS, false
        SAM:activate()
        SAM:enableEmission(true)
    end

    function HOUND_MISSION.SA6.GoLive()
        env.info("GoLive")
        if HOUND_MISSION.SA6.North == nil or HOUND_MISSION.SA6.destroy(HOUND_MISSION.SA6.North:getName()) then
            HOUND_MISSION.SA6.North = Unit.getByName(mist.cloneInZone(HOUND_MISSION.SA6.template,"SA6_North")["units"][1]["name"]):getGroup()
            HOUND_MISSION.SA6.activate(HOUND_MISSION.SA6.North)
        end

        if HOUND_MISSION.SA6.South == nil or HOUND_MISSION.SA6.destroy(HOUND_MISSION.SA6.South:getName()) then
            -- HOUND_MISSION.SA6.South = mist.cloneInZone(HOUND_MISSION.SA6.template,"SA6_South")
            HOUND_MISSION.SA6.South = Unit.getByName(mist.cloneInZone(HOUND_MISSION.SA6.template,"SA6_South")["units"][1]["name"]):getGroup()
            HOUND_MISSION.SA6.activate(HOUND_MISSION.SA6.South)
        end

        if HOUND_MISSION.SA6.spawnJoker and (HOUND_MISSION.SA6.Joker == nil or HOUND_MISSION.SA6.destroy(HOUND_MISSION.SA6.Joker:getName())) then
            HOUND_MISSION.SA6.Joker = Unit.getByName(mist.cloneInZone(HOUND_MISSION.SA6.randomTemplate(),"Joker_SAM")["units"][1]["name"]):getGroup()
            HOUND_MISSION.SA6.activate(HOUND_MISSION.SA6.Joker)
        end
    end

    function HOUND_MISSION.SA6.randomTemplate()
        return HOUND_MISSION.randomTemplate({"SYR_SA6","SYR_SA11","SYR_SA8"})
    end

    HOUND_MISSION.PLAYGROUND = {
        unitCounter = 0,
        zoneNames = {'PlayGround_Hula','PlayGround_Golan'},
        vehicleTypes = {
                        'T-72B3','T-55',
                        'BMP-2','BMP-2','BTR-80','BTR-80',
                        'Ural-375','Ural-375','Ural-375',
                        'ZIL-135','ZIL-135'
                    }
    }

    function HOUND_MISSION.PLAYGROUND.getId()
        HOUND_MISSION.PLAYGROUND.unitCounter = HOUND_MISSION.PLAYGROUND.unitCounter + 1
        return HOUND_MISSION.PLAYGROUND.unitCounter
    end

    function HOUND_MISSION.PLAYGROUND.createUnitList(pos,radius,innerradius)
        local unitList = {}
        if type(radius) == "number" and type(pos) == "table" then
            for i=1,math.random(4,8) do
                local unitPos = mist.getRandPointInCircle(pos,radius,innerradius)
                local unitType = HOUND_MISSION.randomTemplate(HOUND_MISSION.PLAYGROUND.vehicleTypes)
                local unitData = {
                    ["type"] = unitType,
                    ["transportable"] =
                    {
                        ["randomTransportable"] = false,
                    }, -- end of ["transportable"]
                    ["unitId"] = i,
                    ["skill"] = "Random",
                    ["y"] = unitPos.y,
                    ["x"] = unitPos.x,
                    ["name"] = unitType .. HOUND_MISSION.PLAYGROUND.getId(),
                    ["playerCanDrive"] = true,
                    ["heading"] = math.random() * math.pi * 2,
                }
                table.insert(unitList,unitData)
            end
        end
        return unitList
    end

    function HOUND_MISSION.PLAYGROUND.spawnGroup()
        local zone = HOUND_MISSION.randomTemplate(HOUND_MISSION.PLAYGROUND.zoneNames)
        local pos = mist.getRandomPointInZone(zone, 750)
        local grpData = {
            units = HOUND_MISSION.PLAYGROUND.createUnitList(pos,200,25),
            country = 'syria',
            category = 'VEHICLE'
        }
        local grp = mist.dynAdd(grpData)
        if type(grp) == "table" and type(grp['name']) == "string" then
            trigger.action.outText("Apache Targets group has spawned in " .. zone , 15)
        end
    end

    MAIN_MENU = {
        root = missionCommands.addSubMenuForCoalition(coalition.side.BLUE,"Mission Actions")
    }
    MAIN_MENU.activateSa6 = missionCommands.addCommandForCoalition(coalition.side.BLUE,"Activate SA-6",MAIN_MENU.root,HOUND_MISSION.SA6.GoLive)
    MAIN_MENU.spawnTankGroup = missionCommands.addCommandForCoalition(coalition.side.BLUE,"Spawn Apache Targets",MAIN_MENU.root,HOUND_MISSION.PLAYGROUND.spawnGroup)
    -- MAIN_MENU.activateSa6 = missionCommands.addCommandForCoalition(coalition.side.BLUE,"Restart Mission",MAIN_MENU.root,RestartMission)

    -- activate SA6 and keep trigerring it
    mist.scheduleFunction(HOUND_MISSION.SA6.GoLive,nil,timer.getTime()+120,600)



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
                HoundBlue:removePlatform("ELINT Galil") -- C-130

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

    HoundTriggers = {}
    function HoundTriggers:onHoundEvent(event)
        if event.coalition == coalition.side.BLUE then
            if event.id == HOUND.EVENTS.RADAR_DESTROYED then
                local contact = event.initiator
                local SAM = contact.unit:getGroup()
                if SAM:isExist() then
                    timer.scheduleFunction(Group.destroy, SAM, timer.getTime() + math.random(30,60))
                end
            end
        end
    end

    HOUND.addEventHandler(HoundTriggers)
end