do
    if STTS ~= nil then
        STTS.DIRECTORY = "C:\\Program Files\\DCS-SimpleRadio-Standalone"
    end
    HOUND.USE_LEGACY_MARKS = false

end

do
    Elint_blue = HoundElint:create(coalition.side.BLUE)

    Elint_blue:preBriefedContact('PB-test-1')
    Elint_blue:systemOn()

    -- Elint_blue:addPlatform("ELINT_C17")
    -- Elint_blue:addPlatform("ELINT_C130")
    Elint_blue:addPlatform("Kokotse_Elint")
    Elint_blue:addPlatform("Khvamli_Elint")
    Elint_blue:addPlatform("Migariya_Elint")
    -- Elint_blue:addPlatform("Cow")

    tts_args = {
        freq = "251.000,35.000",
        modulation = "AM,FM",
        gender = "male"
    }
    atis_args = {
        freq = 251.500,
        NATO = false,
    }

    Elint_blue:configureController(tts_args)
    Elint_blue:configureAtis(atis_args)

    Elint_blue:enableController()
    Elint_blue:enableText()
    Elint_blue:enableAtis()
    -- Elint_blue:disableBDA()
    -- Elint_blue:setMarkerType(HOUND.MARKER.DIAMOND)

    Elint_blue:addSector("Fake")
    Elint_blue:setZone("Fake")
    -- Elint_blue:onScreenDebug(true)
    -- Elint_blue:enablePlatformPosErrors()

    local callsignOverride = {
        Uzi = "Tulip",
        Chevy = "*"
    }

    Elint_blue:setCallsignOverride(callsignOverride)
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
        env.info(mist.utils.tableShow(hound:getSites()))
        hound:dumpIntelBrief()
    end

    function testing.spawnPlatform(hound)
        env.info("No. platforms before: " .. HOUND.Length(hound.platform))
        local newGrp = mist.cloneGroup("ELINT_C17_SPAWN",true)
        local newUnit = newGrp.units[1].name
        env.info("MIST Spawn - Grp:" .. newGrp.name .. " Unit: " .. newUnit)
        hound:addPlatform(newUnit)
        env.info("No. platforms after: " .. HOUND.Length(hound.platform))
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
    function testing.changeVolume(hound,entity,volume)
        if type(entity) ~= "String" and type(volume) ~= "number" then return end
        if entity:lower() == "atis" then
            if type(hound.configureAtis) == "function" then
                hound:configureAtis({volume = volume})
            end
        end
        if entity:lower() == "controller" then
            if type(hound.configureController) == "function" then
                hound:configureController({volume = volume})
            end
        end
    end
    function testing.increaseAtisVolume(hound)
        testing.changeVolume(hound,"atis",1.5)
    end
    function testing.decreaseAtisVolume(hound)
        testing.changeVolume(hound,"atis",0.6)
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

    function testing.UnitDrawArgs(unitName)
        local unit = Unit.getByName(unitName)
        local args = {}
        for i=1,1100 do
            local v = unit:getDrawArgumentValue(i)
            if v ~= nil and v ~= 0 then
                args[i] = v
            end
        end
        env.info(mist.utils.tableShow(args))

    end

    function testing.GRPCtts(msg)
        local ssml = msg or "balh  blah"
        local frequency = 250*1000000
        local options = {
            srsClientName = "DCS-gRPC"
        }
        GRPC.tts(ssml, frequency, options)
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

end

do
    -- local valid = mist.getGroupRoute('KC135_no_task')
    -- local invalid = mist.getGroupRoute('KC135_tanker')

    -- env.info("Valid tasks:\n")
    -- env.info(mist.utils.tableShow(valid)) -- ['tasks']))
    -- env.info("invalid tasks:\n")
    -- env.info(mist.utils.tableShow(invalid)) -- ['tasks']))


    -- for k,v in pairs(valid) do
    --     env.info("valid - " .. k)
    --     env.info(mist.utils.tableShow(v))
    -- end
    -- env.info("Valid waypoints:\n")
    -- env.info(mist.utils.tableShow(valid["units"][1]))
    -- env.info("invalid waypoints:\n")
    -- env.info(mist.utils.tableShow(invalid["units"][1]))

    -- for _,data in pairs({valid,invalid}) do
    --     if type(data) == "table" and type(data['tasks']) == "table" then
    --         env.info(mist.utils.tableShow(data['tasks']))
    --     end
    -- end
    -- local validController = Unit.getByName('KC135_no_task'):getController()
    -- env.info(mist.utils.tableShow(validController))

    -- local invalidController = Unit.getByName('KC135_tanker'):getController()
    -- env.info(mist.utils.tableShow(invalidController))


    -- env.info(Unit.getByName('P8'):getTypeName())
    -- env.info(Unit.getByName('P3'):getTypeName())
 
    -- for grpName,grp in pairs( HOUND.Utils.Filter.groupsByPrefix("F-1")) do
    --     env.info(grpName.." | "..grp:getUnit(1):getTypeName())
    -- end
    -- for grpName,grp in pairs( HOUND.Utils.Filter.groupsByPrefix("S-3")) do
    --     env.info(grpName.." | "..grp:getUnit(1):getTypeName())
    -- end
    -- mist.debug.dump_G('hound_post_rename_G.lua')
    -- mist.debug.dumpDBs()

    -- for _,unit in ipairs({StaticObject.getByName('Kokotse_Elint'),StaticObject.getByName('TV_TOWER'),StaticObject.getByName('COMMAND_CENTER')}) do
    --     local data = unit:getDesc()
    --     local pos = unit:getPosition().p
    --     env.info("Hight of ".. unit:getTypeName() .. " is " .. unit:getDesc()["box"]["max"]["y"])
    -- end
    -- local balloon = StaticObject.getByName('BALLOON_ANCHOR')
    -- env.info(mist.utils.tableShow(balloon:getDesc()))
    
    -- for cid,v in pairs(_G.env.mission.coalition.blue.country) do
    --     if cid ~= nil and type(v) == "table" then
    --         env.info("CID: " .. cid)
    --         for k,v1 in pairs(v) do
    --             if k == "name" then
    --                 env.info("name: " .. v1)
    --             end
    --             -- if k == "static" then
    --             --     for _,obj in pairs(v1) do
    --             --         env.info(mist.utils.tableShow(obj))
    --             --     end
    --             -- end
    --         end
    --     end
    -- end
end