do
    if STTS ~= nil then
        STTS.DIRECTORY = "C:\\Program Files\\DCS-SimpleRadio-Standalone"
    end

    -- SA-6 activation logic

    SA6 = {}
    SA6.North = nil
    SA6.South = nil
    SA6.template = "SYR_SA6"
    function SA6.destroy(GroupName)
        env.info("check " .. GroupName)

        local SAM = Group.getByName(GroupName)
        local destroy = true
        for index, data in pairs(SAM:getUnits()) do
            if Unit.getTypeName(data) == "Kub 1S91 str" and (Unit.getLife(data) > 1 or Unit.isExist(data) or (Unit.getLife(data)/Unit.getLife0(data)) > 0.55) then
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
        local control = SAM:getController()
        control:setOnOff(true)
        control:setOption(0,2) -- ROE, Open_file
        control:setOption(9,2) -- Alarm_State, RED
        control:setOption(20,false) -- ENGAGE_AIR_WEAPONS, false
        SAM:activate()
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




    HoundBlue = HoundElint:create()
    HoundBlue:addPlatform("ELINT North") -- C-130
    HoundBlue:addPlatform("ELINT South") -- C-130
    HoundBlue:addPlatform("ELINT Galil") -- C-130
    HoundBlue:addPlatform("ELINT HERMON") -- Ground Station
    HoundBlue:addPlatform("ELINT MERON") -- Ground Station


    local controller_args = {
        freq = "251.000,122.000,35.000",
        modulation = "AM,AM,FM",
        gender = "male"
    }
    local atis_args = {
        freq = "253.000,124.000",
        modulation = "AM,AM"
    }

    HoundBlue:configureController(controller_args)
    HoundBlue:configureAtis(atis_args)

    HoundBlue.controller:setTransmitter("ELINT MERON")
    HoundBlue.atis:setTransmitter("ELINT MERON")

    HoundBlue:enableController(true)
    HoundBlue:enableATIS()

    HoundBlue:systemOn()
end