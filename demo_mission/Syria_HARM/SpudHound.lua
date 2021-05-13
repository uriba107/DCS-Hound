do
    STTS.DIRECTORY = "C:\\Program Files\\DCS-SimpleRadio-Standalone"

    -- SA-6 activation logic
    SA6_North = Group.getByName("SYR_SA-6_N")
    SA6_South = Group.getByName("SYR_SA-6_S")
    SEAD_PLAYER_GRP = Group.getByName("SEAD_USER")

    -- SA6_North:enableEmission(false)
    -- SA6_South:enableEmission(false)


    SA6GoLive = function ()
        -- SA6_North:enableEmission(true)
        -- SA6_South:enableEmission(true)
        trigger.action.activateGroup(SA6_North)
        trigger.action.activateGroup(SA6_South)
    end

    RestartMission = function()
        local filename = DCS.getMissionFilename()
        net.load_mission(filename)
    end

    mgmt_menu = {
        root = missionCommands.addSubMenuForCoalition(coalition.side.BLUE,"Mission Actions")
    }
    mgmt_menu.activateSa6 = missionCommands.addCommandForCoalition(coalition.side.BLUE,"Activate SA-6",mgmt_menu.root,SA6GoLive)
    mgmt_menu.activateSa6 = missionCommands.addCommandForCoalition(coalition.side.BLUE,"Restart Mission",mgmt_menu.root,RestartMission)




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

    HoundBlue:enableController(true)
    HoundBlue:enableATIS()

    HoundBlue:systemOn()
end