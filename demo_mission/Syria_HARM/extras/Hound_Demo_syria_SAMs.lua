    --------------------------- MISSION LOGIC ---------------------------
    HOUND_MISSION = {}
    function HOUND_MISSION.randomTemplate(templates)
        if type(templates) ~= "table" then return nil end
        return templates[math.random(1,#templates)]
    end
--------------------------- Skynet and Mobile stuff ---------------------------
    redIADS = SkynetIADS:create('lebanonIADS')
    redIADS:addEarlyWarningRadarsByPrefix('EWR-SKYNET')
    -- redIADS:addSAMSitesByPrefix("SHORAD-")

        -- TODO: itterate over SHORAD units activate some and add to skynet
        for grpName,grp in pairs( HOUND.Utils.Filter.groupsByPrefix("SHORAD-")) do
            grp:enableEmission(false)
            if math.random() < 0.3 then
                grp:activate()
                grp:enableEmission(false)
                redIADS:addSAMSite(grpName)
            end
        end

    redIADS:activate()

    -- local iadsDebug = redIADS:getDebugSettings()  
    -- iadsDebug.IADSStatus = true
    -- iadsDebug.contacts = true
    -- iadsDebug.addedEWRadar = true
    -- iadsDebug.addedSAMSite = true
    -- iadsDebug.warnings = true
    -- iadsDebug.radarWentLive = true
    -- iadsDebug.radarWentDark = true
    -- iadsDebug.samSiteStatusEnvOutput = true
    -- iadsDebug.earlyWarningRadarStatusEnvOutput = true

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
            if HOUND.setContainsValue({"Kub 1S91 str","SA-11 Buk SR 9S18M1","Osa 9A33 ln"},Unit.getTypeName(data)) then
                HOUND_MISSION.SA6.destroyPos(Unit.getPoint(data))
            end
        end
    end

    function HOUND_MISSION.SA6.destroyPos(pos)
        if HOUND.Utils.Dcs.isPoint(pos) then
            trigger.action.explosion(pos,50)
        end
    end

    function HOUND_MISSION.SA6.destroy(GroupName)
        local destroy = true
        if not GroupName then return destroy end
        env.info("check " .. GroupName)

        local SAM = Group.getByName(GroupName)
        for _,data in pairs(SAM:getUnits()) do
            if HOUND.setContainsValue({"Kub 1S91 str","SA-11 Buk SR 9S18M1","Osa 9A33 ln"},Unit.getTypeName(data)) and (Unit.getLife(data) > 1 or Unit.isExist(data) or (Unit.getLife(data)/Unit.getLife0(data)) > 0.55) then
                destroy = false
            end
        end
        if destroy then
            HOUND_MISSION.SA6.destroyRadar(SAM)
        end
        return destroy
    end

    function HOUND_MISSION.SA6.cleanup(dcsGroup)
        for _,key in ipairs({"North","South","Joker"}) 
        do
            if HOUND_MISSION.SA6[key] == dcsGroup then
                Group.destroy(dcsGroup)
                HOUND_MISSION.SA6[key] = nil
            end
        end    end

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
