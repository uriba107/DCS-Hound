do
    if STTS ~= nil then
        STTS.DIRECTORY = "C:\\Program Files\\DCS-SimpleRadio-Standalone"
    end

    SA6 = {}
    -- SA-6 activation logic
    SA6.North = Group.getByName("SYR_SA-6_N")
    SA6.South = Group.getByName("SYR_SA-6_S")

    function SA6.activate(SAM)
        local control = SAM:getController()
        control:setOnOff(true)
        control:setOption(0,2) -- ROE, Open_file
        control:setOption(9,2) -- Alarm_State, RED
        control:setOption(20,false) -- ENGAGE_AIR_WEAPONS, false
        -- trigger.action.activateGroup(SAM)

        SAM:activate()
    end
    -- SA6_North:enableEmission(false)
    -- SA6_South:enableEmission(false)


    function SA6.GoLive()
        -- SA6_North:enableEmission(true)
        -- SA6_South:enableEmission(true)
        -- trigger.action.activateGroup(SA6_North)
        -- trigger.action.activateGroup(SA6_South)
        SA6.activate(SA6.North)
        SA6.activate(SA6.South)
    end

    -- RestartMission = function()
    --     local filename = DCS.getMissionFilename()
    --     net.load_mission(filename)
    -- end

    mgmt_menu = {
        root = missionCommands.addSubMenuForCoalition(coalition.side.BLUE,"Mission Actions")
    }
    mgmt_menu.activateSa6 = missionCommands.addCommandForCoalition(coalition.side.BLUE,"Activate SA-6",mgmt_menu.root,SA6.GoLive)
    -- mgmt_menu.restartMission = missionCommands.addCommandForCoalition(coalition.side.BLUE,"Restart Mission",mgmt_menu.root,RestartMission)



    HoundBlue = HoundElint:create()
    HoundBlue:addPlatform("ELINT North") -- C-130
    HoundBlue:addPlatform("ELINT South") -- C-130
    HoundBlue:addPlatform("ELINT Galil") -- C-130
    HoundBlue:addPlatform("ELINT HERMON") -- Ground Station
    HoundBlue:addPlatform("ELINT MERON") -- Ground Station


    controller_args = {
        freq = "251.000,122.000,35.000",
        modulation = "AM,AM,FM",
        gender = "male"
    }
    atis_args = {
        freq = "253.000,124.000",
        modulation = "AM,AM"
    }

    HoundBlue:configureController(controller_args)
    HoundBlue:configureAtis(atis_args)

    HoundBlue.controller:setTransmitter("ELINT MERON")
    HoundBlue.atis:setTransmitter("ELINT MERON")

    HoundBlue:enableController(false)
    -- HoundBlue:enableATIS()

    HoundBlue:systemOn()
end