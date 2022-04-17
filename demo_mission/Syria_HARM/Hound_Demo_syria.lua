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
    function HOUND_MISSION.SA6.destroy(GroupName)
        env.info("check " .. GroupName)

        local SAM = Group.getByName(GroupName)
        local destroy = true
        for _,data in pairs(SAM:getUnits()) do
            if setContainsValue({"Kub 1S91 str","SA-11 Buk SR 9S18M1","Osa 9A33 ln"},Unit.getTypeName(data)) and (Unit.getLife(data) > 1 or Unit.isExist(data) or (Unit.getLife(data)/Unit.getLife0(data)) > 0.55) then
                destroy = false
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

    -- activate SA6 and keep trigerring it
    mist.scheduleFunction(HOUND_MISSION.SA6.GoLive,nil,timer.getTime()+120,600)

----- Apache playground -----
    HOUND_MISSION.PLAYGROUND = {
        unitCounter = 0,
        zoneNames = {'PlayGround_Hula','PlayGround_Golan'},
        zoneLevel = {
            PlayGround_Hula = "EASY",
            PlayGround_Golan = "EASY"
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
            }
        }
    }

    function HOUND_MISSION.PLAYGROUND.getId()
        HOUND_MISSION.PLAYGROUND.unitCounter = HOUND_MISSION.PLAYGROUND.unitCounter + 1
        return HOUND_MISSION.PLAYGROUND.unitCounter
    end

    function HOUND_MISSION.PLAYGROUND.updateZoneLevel(zone,level)
        if not setContainsValue(HOUND_MISSION.PLAYGROUND.zoneNames,zone) or type(level) ~= "string" then return end
        if type(level) ~= "string" then return end
        level = level:upper()
        if setContainsValue({"EASY","MEDUIM","HARD"},level) then
            HOUND_MISSION.PLAYGROUND.zoneLevel[zone] = level
        end
    end

    function HOUND_MISSION.PLAYGROUND.setHulaDifficulty(level)
        HOUND_MISSION.PLAYGROUND.updateZoneLevel("PlayGround_Hula",level)
        HOUND_MISSION.PLAYGROUND.buildRangeMenu()
    end
    function HOUND_MISSION.PLAYGROUND.setGolanDifficulty(level)
        HOUND_MISSION.PLAYGROUND.updateZoneLevel("PlayGround_Golan",level)
        HOUND_MISSION.PLAYGROUND.buildRangeMenu()
    end

    function HOUND_MISSION.PLAYGROUND.buildRangeMenu()
        if not MAIN_MENU.apache then
            MAIN_MENU.apache = {}
            MAIN_MENU.apache.root = missionCommands.addSubMenuForCoalition(coalition.side.BLUE,"Spawn Apache Targets")
        end

        if not MAIN_MENU.apache.spawnTankGroup then
            MAIN_MENU.apache.spawnTankGroup = missionCommands.addCommandForCoalition(coalition.side.BLUE,"Spawn Random Target",MAIN_MENU.apache.root,HOUND_MISSION.PLAYGROUND.spawnGroup)
        end
        HOUND_MISSION.PLAYGROUND.buildHulaMenu()
        HOUND_MISSION.PLAYGROUND.buildGolanMenu()
    end

    function HOUND_MISSION.PLAYGROUND.buildHulaMenu()
        if not MAIN_MENU.apache.hula then
            MAIN_MENU.apache.hula = {}
        end
        if MAIN_MENU.apache.hula.main then
            MAIN_MENU.apache.hula.main = missionCommands.removeItemForCoalition(coalition.side.BLUE,MAIN_MENU.apache.hula.main)
        end
        MAIN_MENU.apache.hula.main = missionCommands.addSubMenuForCoalition(coalition.side.BLUE,"Hula Range (" .. HOUND_MISSION.PLAYGROUND.zoneLevel.PlayGround_Hula .. ")",MAIN_MENU.apache.root)
        MAIN_MENU.apache.hula.spawn = missionCommands.addCommandForCoalition(coalition.side.BLUE,"Spawn Group",MAIN_MENU.apache.hula.main,HOUND_MISSION.PLAYGROUND.spawnGroup,"PlayGround_Hula")

        MAIN_MENU.apache.hula.level = {}
        MAIN_MENU.apache.hula.level.main = missionCommands.addSubMenuForCoalition(coalition.side.BLUE,"Set difficulty",MAIN_MENU.apache.hula.main)
        MAIN_MENU.apache.hula.level.easy = missionCommands.addCommandForCoalition(coalition.side.BLUE,"EASY",MAIN_MENU.apache.hula.level.main,HOUND_MISSION.PLAYGROUND.setHulaDifficulty,"EASY")
        MAIN_MENU.apache.hula.level.medium = missionCommands.addCommandForCoalition(coalition.side.BLUE,"MEDIUM",MAIN_MENU.apache.hula.level.main,HOUND_MISSION.PLAYGROUND.setHulaDifficulty,"MEDIUM")
        MAIN_MENU.apache.hula.level.hard = missionCommands.addCommandForCoalition(coalition.side.BLUE,"HARD",MAIN_MENU.apache.hula.level.main,HOUND_MISSION.PLAYGROUND.setHulaDifficulty,"HARD")
    end

    function HOUND_MISSION.PLAYGROUND.buildGolanMenu()
        if not MAIN_MENU.apache.golan then
            MAIN_MENU.apache.golan = {}
        end
        if MAIN_MENU.apache.golan.main then
            MAIN_MENU.apache.golan.main = missionCommands.removeItemForCoalition(coalition.side.BLUE,MAIN_MENU.apache.golan.main)
        end
        MAIN_MENU.apache.golan.main = missionCommands.addSubMenuForCoalition(coalition.side.BLUE,"Golan Range (" .. HOUND_MISSION.PLAYGROUND.zoneLevel.PlayGround_Golan .. ")",MAIN_MENU.apache.root)
        MAIN_MENU.apache.golan.spawn = missionCommands.addCommandForCoalition(coalition.side.BLUE,"Spawn Group",MAIN_MENU.apache.golan.main,HOUND_MISSION.PLAYGROUND.spawnGroup,"PlayGround_Golan")

        MAIN_MENU.apache.golan.level = {}
        MAIN_MENU.apache.golan.level.main = missionCommands.addSubMenuForCoalition(coalition.side.BLUE,"Set difficulty",MAIN_MENU.apache.golan.main)
        MAIN_MENU.apache.golan.level.easy = missionCommands.addCommandForCoalition(coalition.side.BLUE,"EASY",MAIN_MENU.apache.golan.level.main,HOUND_MISSION.PLAYGROUND.setGolanDifficulty,"EASY")
        MAIN_MENU.apache.golan.level.medium = missionCommands.addCommandForCoalition(coalition.side.BLUE,"MEDIUM",MAIN_MENU.apache.golan.level.main,HOUND_MISSION.PLAYGROUND.setGolanDifficulty,"MEDIUM")
        MAIN_MENU.apache.golan.level.hard = missionCommands.addCommandForCoalition(coalition.side.BLUE,"HARD",MAIN_MENU.apache.golan.level.main,HOUND_MISSION.PLAYGROUND.setGolanDifficulty,"HARD")
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

    function HOUND_MISSION.PLAYGROUND.spawnGroup(location)
        local zone = location or HOUND_MISSION.randomTemplate(HOUND_MISSION.PLAYGROUND.zoneNames)
        local level = HOUND_MISSION.PLAYGROUND.zoneLevel[zone] or "EASY"
        local pos = mist.getRandomPointInZone(zone, 750)
        local grpData = {
            units = HOUND_MISSION.PLAYGROUND.createUnitList(pos,200,25,level),
            country = 'syria',
            category = 'VEHICLE'
        }
        local grp = mist.dynAdd(grpData)
        if type(grp) == "table" and type(grp['name']) == "string" then
            local control = grp:getController()
            if control then
                control:setOnOff(true)
                control:setOption(0,2) -- ROE, Open_file
                control:setOption(9,2) -- Alarm_State, RED
            end
            trigger.action.outText("Apache Targets group has spawned in " .. zone , 15)
        end
    end

----- Radio Menues
    MAIN_MENU = {
        root = missionCommands.addSubMenuForCoalition(coalition.side.BLUE,"Mission Actions"),
    }
    MAIN_MENU.activateSa6 = missionCommands.addCommandForCoalition(coalition.side.BLUE,"Activate SA-6",MAIN_MENU.root,HOUND_MISSION.SA6.GoLive)


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

    HoundBlue:preBriefedContact('SYR_SA-2')

    for ewrUnitName,_ in pairs(HOUND.Utils.Filter.unitsByPrefix("EWR-")) do
        HoundBlue:preBriefedContact(ewrUnitName)
    end

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
                local SAM = Group.getByName(contact.DCSgroupName)
                if SAM:isExist() and
                    setContainsValue({HOUND_MISSION.SA6.North,HOUND_MISSION.SA6.South,HOUND_MISSION.SA6.Joker},SAM)
                    then
                        timer.scheduleFunction(Group.destroy, SAM, timer.getTime() + math.random(30,60))
                end
            end
        end
    end
    HOUND.addEventHandler(HoundTriggers)
end