do
    if STTS ~= nil then
        STTS.DIRECTORY = "C:\\Program Files\\DCS-SimpleRadio-Standalone"
    end
    HOUND.USE_KALMAN = true

end

do
    Elint_blue = HoundElint:create(coalition.side.BLUE)

    Elint_blue:preBriefedContact('PB-test-1')
    Elint_blue:systemOn()

    Elint_blue:addPlatform("ELINT_C17")
    Elint_blue:addPlatform("ELINT_C130")
    -- Elint_blue:addPlatform("Kokotse_Elint")
    -- Elint_blue:addPlatform("Khvamli_Elint")
    -- Elint_blue:addPlatform("Migariya_Elint")
    -- Elint_blue:addPlatform("Cow")

    tts_args = {
        freq = "251.000,35.000",
        modulation = "AM,FM",
        gender = "male"
    }
    atis_args = {
        freq = 251.500,
        NATO = false
    }

    Elint_blue:configureController(tts_args)
    Elint_blue:configureAtis(atis_args)

    Elint_blue:enableController()
    Elint_blue:enableText()
    Elint_blue:enableAtis()
    -- Elint_blue:disableBDA()
    -- Elint_blue:setMarkerType(HOUND.MARKER.NONE)

    Elint_blue:addSector("Fake")
    Elint_blue:setZone("Fake")


end

do
    testing = {}
    testing.idx = 10
    function testing.addTransmitter(args)
        args["houndCommsInstance"]:setTransmitter(args["unit_name"])
    end

    function testing.removeTransmitter(houndCommsInstance)
        houndCommsInstance:removeTransmitter()
    end

    function testing.removePlatform(args)
        args["houndInstance"]:removePlatform(args["unit_name"])
    end

    function testing.getContacts(hound)
        env.info(mist.utils.tableShow(hound:getContacts()))
        hound:dumpIntelBrief()
    end

    function testing.spawnPlatform(hound)
        env.info("No. platforms before: " .. Length(hound.platform))
        local newGrp = mist.cloneGroup("ELINT_C17_SPAWN",true)
        local newUnit = newGrp.units[1].name
        env.info("MIST Spawn - Grp:" .. newGrp.name .. " Unit: " .. newUnit)
        hound:addPlatform(newUnit)
        env.info("No. platforms after: " .. Length(hound.platform))
    end

    function testing.AddMarker()
        local pos = Unit.getByName("ELINT_C17"):getPosition()
        trigger.action.circleToAll(coalition.side.BLUE,testing.idx, pos.p,(pos.p.y/10),{0,255,0,100},{0,255,0,20},2,true)
        testing.idx = testing.idx + 1
    end

    function testing.toggleMarkers()
        HOUND.FORCE_MANAGE_MARKERS = not HOUND.FORCE_MANAGE_MARKERS
    end

    function testing.boom(unit)
        local pos = unit:getPoint()
        local life0 = unit:getLife0()
        local life = unit:getLife()
        local ittr = 1
        while life > 1 and ittr < 10 do
            local pwr = math.max(0.0055,(life-1)/life0)
            env.info(ittr .. " | unit has " .. unit:getLife() .. " started with " .. life0 .. "explody power: " .. pwr)
            trigger.action.explosion(pos,pwr)
            life = unit:getLife()
            ittr = ittr+1
        end 
    end

    function testing.badaBoom(pos)
        trigger.action.explosion(pos,1000)
    end

    function testing.markDead(unit)
        Elint_blue:markDeadContact(unit)
    end
    function testing.markPB(unit)
        Elint_blue:preBriefedContact(unit)
    end

    function testing.toggleGroup(groupName)
        local grp = Group.getByName(groupName)
        if grp and grp:isExist() then
            trigger.action.deactivateGroup(grp)
            env.info("after destroy")
            for _,unit in pairs(grp:getUnits()) do
                env.info(string.format("%s (%d) - %d",unit:getName(),unit:getID(),unit:getLife()))
            end
        else
            mist.respawnGroup(groupName)
            env.info("after respawn")
            for _,unit in pairs(grp:getUnits()) do
                env.info(string.format("%s (%d) - %d",unit:getName(),unit:getID(),unit:getLife()))
            end
        end
    end

    function testing.GrpData(groupName)
        local grp = Group.getByName(groupName)
        for k,v in pairs(grp) do
            env.info("Group['".. k .. "'] is " .. type(v))
            if type(v) == "table" then
                env.info("Group['".. k .. "']")
                env.info(mist.utils.tableShow(v))
            end
        end
        local unit = grp:getUnits()[1]
        for k,v in pairs(grp) do
            env.info("Unit['".. k .. "'] is " .. type(v))
            if type(v) == "table" then
                env.info("Unit['".. k .. "']")
                env.info(mist.utils.tableShow(v))
            end
        end
    end

    testing.Menu = missionCommands.addSubMenu("Hound Testing")
    missionCommands.addCommand("Poke Radar",testing.Menu,testing.boom,Unit.getByName("PB-test-3"))
    -- missionCommands.addCommand("Poke Radar",testing.Menu,testing.boom,Unit.getByName("SA-3 P-19"))
    missionCommands.addCommand("Mark dead Radar",testing.Menu,testing.markDead,"SA-3 P-19")
    missionCommands.addCommand("Mark PB",testing.Menu,testing.markPB,"PB-test-3")

    missionCommands.addCommand("Toggle SA-3 Activation",testing.Menu,testing.toggleGroup,"SA-3_late")
    -- missionCommands.addCommand("Destroy C17",testing.Menu,Unit.destroy,Unit.getByName("ELINT_C17"))
    -- missionCommands.addCommand("Remove C17",testing.Menu,testing.removePlatform,{houndInstance=Elint_blue,unit_name="ELINT_C17"})
    missionCommands.addCommand("Spawn platform",testing.Menu,testing.spawnPlatform,Elint_blue)
    -- missionCommands.addCommand("Add transmitter",testing.Menu,testing.addTransmitter,{houndCommsInstance=Elint_blue.controller,unit_name="Migariya_Elint"})
    -- missionCommands.addCommand("Destroy transmitter",testing.Menu,Unit.destroy,	Unit.getByName("Migariya_Elint"))
    -- missionCommands.addCommand("Remove transmitter",testing.Menu,testing.removeTransmitter,Elint_blue.controller)
    missionCommands.addCommand("Get Contacts",testing.Menu,testing.getContacts,Elint_blue)
    missionCommands.addCommand("Add test Marker",testing.Menu,testing.AddMarker)
    missionCommands.addCommand("Toggle marker Counter",testing.Menu,testing.toggleMarkers)
    missionCommands.addCommand("unit data",testing.Menu,testing.GrpData,'Elint')
end

do
    -- local valid = mist.getCurrentGroupData('KC135_no_task')
    -- local invalid = mist.getCurrentGroupData('KC135_tanker')

    -- env.info("Valid tasks:\n")
    -- env.info(mist.utils.tableShow(valid)) -- ['tasks']))
    -- env.info("invalid tasks:\n")
    -- env.info(mist.utils.tableShow(invalid)) -- ['tasks']))


    -- for k,v in pairs(valid) do
    --     env.info("valid - " .. k)
    -- end
    -- env.info("Valid waypoints:\n")
    -- env.info(mist.utils.tableShow(valid['route']['points']))
    -- env.info("invalid waypoints:\n")
    -- env.info(mist.utils.tableShow(invalid['route']['points']))

    -- for _,data in pairs({valid,invalid}) do
    --     if type(data) == "table" and type(data['tasks']) == "table" then
    --         env.info(mist.utils.tableShow(data['tasks']))
    --     end
    -- end
    -- local validController = Unit.getByName('KC135_no_task'):getController()
    -- env.info(mist.utils.tableShow(validController))

    -- local invalidController = Unit.getByName('KC135_tanker'):getController()
    -- env.info(mist.utils.tableShow(invalidController))

    -- mist.debug.dump_G('hound_post_rename_G.lua')
    -- mist.debug.dumpDBs()
end