do
    if STTS ~= nil then
        STTS.DIRECTORY = "C:\\Program Files\\DCS-SimpleRadio-Standalone"
    end

    --------------------------- MISSION LOGIC ---------------------------
    HOUND_MISSION = {}
    function HOUND_MISSION.randomTemplate(templates)
        if type(templates) ~= "table" then return nil end
        return templates[math.random(1,#templates)]
    end
--------------------------- Skynet and Mobile stuff ---------------------------
    redIADS = SkynetIADS:create('lebanonIADS')
    redIADS:addEarlyWarningRadarsByPrefix('EWR-SKYNET')
    redIADS:activate()
    -- TODO: itterate over SHORAD units activate some and add to skynet
    for grpName,grp in pairs( HOUND.Utils.Filter.groupsByPrefix("SHORAD-")) do
        grp:enableEmission(false)
        if math.random() < 0.4 then
            grp:activate()
            redIADS:addSAMSite(grpName)
        end
    end

----- Hound Demo Logic -----
    HOUND_MISSION.SA6 = {}
    HOUND_MISSION.SA6.North = nil
    HOUND_MISSION.SA6.South = nil
    HOUND_MISSION.SA6.template = "SYR_SA6"
    HOUND_MISSION.SA6.spawnJoker = function() return (math.random() < 0.4) end

    function HOUND_MISSION.SA6.destroyRadar(group)
        if type(group) == "string" and HOUND_MISSION.SA6[group] then
            group =  HOUND_MISSION.SA6[group]
        end
        for _, data in pairs(group:getUnits()) do
            if setContainsValue({"Kub 1S91 str","SA-11 Buk SR 9S18M1","Osa 9A33 ln"},Unit.getTypeName(data)) then
                HOUND_MISSION.SA6.destroyPos(Unit.getPoint(data))
            end
        end
    end

    function HOUND_MISSION.SA6.destroyPos(pos)
        if HOUND.Utils.Geo.isDcsPoint(pos) then
            trigger.action.explosion(pos,250)
        end
    end

    function HOUND_MISSION.SA6.destroy(GroupName)
        local destroy = true
        if not GroupName then return destroy end
        env.info("check " .. GroupName)

        local SAM = Group.getByName(GroupName)
        for _,data in pairs(SAM:getUnits()) do
            if setContainsValue({"Kub 1S91 str","SA-11 Buk SR 9S18M1","Osa 9A33 ln"},Unit.getTypeName(data)) and (Unit.getLife(data) > 1 or Unit.isExist(data) or (Unit.getLife(data)/Unit.getLife0(data)) > 0.55) then
                destroy = false
            end
        end
        if destroy then
            HOUND_MISSION.SA6.destroyRadar(SAM)
        end
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

    -- activate SA6 and keep trigerring it
    mist.scheduleFunction(HOUND_MISSION.SA6.GoLive,nil,timer.getTime()+120,600)

----- Apache playground -----
    HOUND_MISSION.PLAYGROUND = {
        unitCounter = 0,
        ranges = {
            Hula = {zone='PlayGround_Hula',level='EASY'},
            Golan = {zone='PlayGround_Golan',level='EASY'}
        },
        vehicleTypes = {
            EASY = {
                'T-72B3','T-55',
                'BMP-2','BMP-2','BTR-80','BTR-80',
                'Ural-375','Ural-375','Ural-375',
                'ZIL-135','ZIL-135'
            },
            MEDIUM = {
                'T-72B3','T-80UD','T-72B3','T-80UD',
                'BMP-2','BMP-2','BTR-80','BTR-80',
                'Strela-10M3','Strela-1 9P31',
                'ZSU-23-4 Shilka','ZSU-23-4 Shilka'
            },
            HARD = {
                'T-72B3','T-80UD','T-72B3','T-80UD',
                'BTR-80','BTR-80',
                'Strela-10M3','Strela-10M3',
                'ZSU-23-4 Shilka','ZSU-23-4 Shilka',
                '2S6 Tunguska'
            },
        }
    }

    function HOUND_MISSION.PLAYGROUND.getId()
        HOUND_MISSION.PLAYGROUND.unitCounter = HOUND_MISSION.PLAYGROUND.unitCounter + 1
        return HOUND_MISSION.PLAYGROUND.unitCounter
    end

    function HOUND_MISSION.PLAYGROUND.updateRangeLevel(args)
        if #args < 2 then return end
        local rangeName = args[1]
        local level = args[2]
        if not HOUND_MISSION.PLAYGROUND.ranges[rangeName] or type(level) ~= "string" then return end
        level = level:upper()
        if HOUND_MISSION.PLAYGROUND.vehicleTypes[level] then
            HOUND_MISSION.PLAYGROUND.ranges[rangeName].level = level
        end
        HOUND_MISSION.PLAYGROUND.buildRangeMenu()
    end

    function HOUND_MISSION.PLAYGROUND.buildRangeMenu()
        if not MAIN_MENU.apache then
            MAIN_MENU.apache = {}
            MAIN_MENU.apache.root = missionCommands.addSubMenuForCoalition(coalition.side.BLUE,"Spawn Apache Targets")
        end

        for rangeName,rangeData in pairs(HOUND_MISSION.PLAYGROUND.ranges) do
            if not MAIN_MENU.apache[rangeName] then
                MAIN_MENU.apache[rangeName] = {}
            end
            if MAIN_MENU.apache[rangeName].main then
                MAIN_MENU.apache[rangeName].main = missionCommands.removeItemForCoalition(coalition.side.BLUE,MAIN_MENU.apache[rangeName].main)
            end
            MAIN_MENU.apache[rangeName].main = missionCommands.addSubMenuForCoalition(coalition.side.BLUE,rangeName .. " Range (" .. rangeData.level:upper() .. ")",MAIN_MENU.apache.root)
            MAIN_MENU.apache[rangeName].spawn = missionCommands.addCommandForCoalition(coalition.side.BLUE,"Spawn Group",MAIN_MENU.apache[rangeName].main,HOUND_MISSION.PLAYGROUND.spawnGroup,rangeName)

            MAIN_MENU.apache[rangeName].level = {}
            MAIN_MENU.apache[rangeName].level.main = missionCommands.addSubMenuForCoalition(coalition.side.BLUE,"Set difficulty",MAIN_MENU.apache[rangeName].main)
            for _,level in ipairs({'EASY','MEDIUM','HARD'}) do
                MAIN_MENU.apache[rangeName].level[level] = missionCommands.addCommandForCoalition(coalition.side.BLUE,level,MAIN_MENU.apache[rangeName].level.main,HOUND_MISSION.PLAYGROUND.updateRangeLevel,{rangeName,level})
            end
        end
    end

    function HOUND_MISSION.PLAYGROUND.createUnitList(pos,radius,innerradius,difficulty)
        local unitList = {}
        local level = difficulty or "EASY"
        if type(radius) == "number" and type(pos) == "table" then
            for i=1,math.random(4,8) do
                local unitPos = mist.getRandPointInCircle(pos,radius,innerradius)
                local unitType = HOUND_MISSION.randomTemplate(HOUND_MISSION.PLAYGROUND.vehicleTypes[level])
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

    function HOUND_MISSION.PLAYGROUND.spawnGroup(rangeName)
        local rangeData = HOUND_MISSION.PLAYGROUND.ranges[rangeName] or HOUND_MISSION.randomTemplate(HOUND_MISSION.PLAYGROUND.ranges)
        local zone = rangeData.zone
        local level = rangeData.level
        local pos = mist.getRandomPointInZone(zone, 750)
        local grpData = {
            units = HOUND_MISSION.PLAYGROUND.createUnitList(pos,200,25,level),
            country = 'syria',
            category = 'VEHICLE'
        }
        local grp = mist.dynAdd(grpData)
        if type(grp) == "table" and type(grp['name']) == "string" then
            local control = Group.getByName(grp['name']):getController()
            if control then
                control:setOnOff(true)
                control:setOption(0,2) -- ROE, Open_file
                control:setOption(9,2) -- Alarm_State, RED
            end
            trigger.action.outText("Apache Targets group has spawned in " .. rangeName , 15)
        end
    end

----- Radio Menues
    MAIN_MENU = {
        root = missionCommands.addSubMenuForCoalition(coalition.side.BLUE,"Mission Actions"),
    }
    MAIN_MENU.activateSa6 = missionCommands.addCommandForCoalition(coalition.side.BLUE,"Activate SA-6",MAIN_MENU.root,HOUND_MISSION.SA6.GoLive)
    MAIN_MENU.debug = {}
    MAIN_MENU.debug.main = missionCommands.addSubMenuForCoalition(coalition.side.BLUE,"Debug")
    MAIN_MENU.debug.north = missionCommands.addCommandForCoalition(coalition.side.BLUE,"blowup north",MAIN_MENU.debug.main,HOUND_MISSION.SA6.destroyRadar,"North")
    MAIN_MENU.debug.south = missionCommands.addCommandForCoalition(coalition.side.BLUE,"blowup south",MAIN_MENU.debug.main,HOUND_MISSION.SA6.destroyRadar,"South")
    MAIN_MENU.debug.p19 = missionCommands.addCommandForCoalition(coalition.side.BLUE,"blowup p-19",MAIN_MENU.debug.main,HOUND_MISSION.SA6.destroyPos,Group.getByName('SYR_SA-2'):getUnit(10):getPoint())
    MAIN_MENU.debug.fs = missionCommands.addCommandForCoalition(coalition.side.BLUE,"blowup FanSong",MAIN_MENU.debug.main,HOUND_MISSION.SA6.destroyPos,Group.getByName('SYR_SA-2'):getUnit(1):getPoint())


    HOUND_MISSION.PLAYGROUND.buildRangeMenu()

----- Lebanon MANPADS -----

    HOUND_MISSION.MANPADS = {}
    HOUND_MISSION.MANPADS.state = false

    function HOUND_MISSION.MANPADS.toggle(state)
        for _,manpadGrp in pairs(HOUND.Utils.Filter.groupsByPrefix("MANPAD-")) do
            if state then
                if math.random() < 0.5 then
                    manpadGrp:activate()
                end
            else
                manpadGrp:destroy()
            end
        end
        HOUND_MISSION.MANPADS.state = state
        HOUND_MISSION.MANPADS.updateMenu()
    end

    function HOUND_MISSION.MANPADS.updateMenu()
        if HOUND_MISSION.MANPADS.menu then
            HOUND_MISSION.MANPADS.menu = missionCommands.removeItemForCoalition(coalition.side.BLUE,HOUND_MISSION.MANPADS.menu)
        end
        HOUND_MISSION.MANPADS.menu = missionCommands.addCommandForCoalition(coalition.side.BLUE,"Toggle MANPADS (Now: " .. tostring(HOUND_MISSION.MANPADS.state):upper() ..")",MAIN_MENU.root,HOUND_MISSION.MANPADS.toggle,(not HOUND_MISSION.MANPADS.state))
    end

    HOUND_MISSION.MANPADS.updateMenu()


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
    HoundBlue:systemOn()

    HoundBlue:preBriefedContact('SYR_SA-2')

    for ewrUnitName,_ in pairs(HOUND.Utils.Filter.unitsByPrefix("EWR-")) do
        HoundBlue:preBriefedContact(ewrUnitName)
    end

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
                env.info("HoundEvent for group " .. contact:getGroupName() )
                local SAM = Group.getByName(contact:getGroupName())
                if SAM and SAM:getSize() > 0 and
                    setContainsValue({HOUND_MISSION.SA6.North,HOUND_MISSION.SA6.South,HOUND_MISSION.SA6.Joker},SAM)
                    then
                        timer.scheduleFunction(Group.destroy, SAM, timer.getTime() + math.random(30,60))
                end
            end
        end
    end
    HOUND.addEventHandler(HoundTriggers)
end