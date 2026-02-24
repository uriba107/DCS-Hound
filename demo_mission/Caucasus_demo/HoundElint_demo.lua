do
    l_stts = HoundTTS or STTS
    if l_stts ~= nil then
        l_stts.DIRECTORY = "C:\\Program Files\\DCS-SimpleRadio-Standalone\\ExternalAudio"
        l_stts.GOOGLE_CREDENTIALS = "E:\\Dropbox\\uri\\Dropbox\\DCS\\Mission Building\\googletts.json"
    end
    HOUND.USE_LEGACY_MARKS = false
    -- HOUND.TTS_ENGINE = {'STTS','GRPC'}
    -- HOUND.ENABLE_KALMAN = true
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
    -- Elint_blue:addPlatform("ELINT_CR")


    tts_args = {
        freq = "251.000,127.500,35.000",
        modulation = "AM,AM,FM",
        gender = "female"
        -- voice = "en-US-Standard-F",
        -- googleTTS = true
        -- provider = "piper",
    }
    atis_args = {
        freq = 251.500,
        NATO = false,

    }

    notifier_args = {
        freq = "305.000,127.000",
        modulation = "AM,AM",
        provider = "piper",
        voice = "en_US-ryan-low",
    }
    Elint_blue:configureController(tts_args)
    Elint_blue:configureAtis(atis_args)
    Elint_blue:configureNotifier(notifier_args)

    Elint_blue:enableController()
    Elint_blue:enableText()
    Elint_blue:enableAtis()
    Elint_blue:enableNotifier()
    -- Elint_blue:disableBDA()
    Elint_blue:setMarkerType(HOUND.MARKER.POLYGON)
    -- Elint_blue:setMarkerType(HOUND.MARKER.DIAMOND)

    -- Elint_blue:setMarkerType(HOUND.MARKER.POINT)

    -- Elint_blue:setMarkerType(HOUND.MARKER.SITE_ONLY)


    Elint_blue:addSector("Fake")
    Elint_blue:setZone("Fake")
    Elint_blue:setAlertOnLaunch(true)
    -- Elint_blue:onScreenDebug(true)
    -- Elint_blue:enablePlatformPosErrors()

    local callsignOverride = {
        Uzi = "Tulip",
        Pontiac = "*"
    }

    Elint_blue:setCallsignOverride(callsignOverride)

    -- test death
    Elint_blue.onHoundEvent = function(self,event)
        if event.id == HOUND.EVENTS.RADAR_DESTROYED or event.id == HOUND.EVENTS.SITE_ASLEEP or event.id == HOUND.EVENTS.SITE_REMOVED then
            HOUND.Logger.debug("Event triggered! " .. HOUND.reverseLookup(HOUND.EVENTS,event.id) .. " for " .. event.initiator:getName())
        end
    end
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

    function testing.destroyEWR()
        local unit = Unit.getByName("EWR-20-1")  or Unit.getByName("EWR-3-1") or Unit.getByName("EWR-9-1")
        if HOUND.Utils.Dcs.isUnit(unit) then
            testing.boom(unit)
        end
    end

    function testing.spawnPlatform(hound)
        env.info("No. platforms before: " .. hound:countPlatforms())
        local newGrp = mist.cloneGroup("ELINT_C17_SPAWN",true)
        local newUnit = newGrp.units[1].name
        env.info("MIST Spawn - Grp:" .. newGrp.name .. " Unit: " .. newUnit)
        hound:addPlatform(newUnit)
        env.info("No. platforms after: " .. hound:countPlatforms())
    end

    function testing.AddMarker()
        local pos = Unit.getByName("ELINT_C17"):getPosition()
        trigger.action.circleToAll(coalition.side.BLUE,testing.idx, pos.p,(pos.p.y/10),{0,255,0,100},{0,255,0,20},2,true)
        testing.idx = testing.idx + 1
    end

    function testing.toggleMarkers()
        HOUND.FORCE_MANAGE_MARKERS = not HOUND.FORCE_MANAGE_MARKERS
    end

    function testing.boom(DcsObject)
        local units = {}
        if getmetatable(DcsObject) == Unit then
            table.insert(units,DcsObject)
        end
        if getmetatable(DcsObject) == Group then
            units = DcsObject:getUnits()
        end

        for i=#units,1,-1 do
            local unit = units[i]
            if unit:hasSensors(Unit.SensorType.RADAR) and HOUND.setContains(HOUND.DB.Radars,unit:getTypeName()) then
                local pos = unit:getPoint()
                local life0 = unit:getLife0()
                local life = unit:getLife()
                local ittr = 1
                while life > 1 and ittr < 10 do
                    local pwr = math.max(0.0055,(life-1)/life0)
                    env.info(ittr .. " | unit has " .. unit:getLife() .. " HP, started with " .. life0 .. " explody power: " .. pwr)
                    trigger.action.explosion(pos,pwr)
                    life = unit:getLife()
                    ittr = ittr+1
                end
                if ittr > 1 then
                    return -- only destroy one unit
                end
            end
        end
    end

    function testing.testHasRadar(DcsObject)
        local units = {}
        if getmetatable(DcsObject) == Unit then
            table.insert(units,DcsObject)
        end
        if getmetatable(DcsObject) == Group then
            units = DcsObject:getUnits()
        end
        local lastUnit = units[#units]
        env.info("*** BEFORE ***")
        env.info(lastUnit:getName() .. " has radar? " .. tostring(lastUnit:hasSensors(Unit.SensorType.RADAR)))
        env.info(mist.utils.tableShow(lastUnit:getSensors()))
        env.info("*************")
        for idx,unit in ipairs(units) do
            if idx <=4 then
                local pos = unit:getPoint()
                local life0 = unit:getLife0()
                local life = unit:getLife()
                local ittr = 1
                while life > 1 and ittr < 10 do
                    trigger.action.explosion(pos,5)
                    life = unit:getLife()
                    ittr = ittr+1
                end
            end
        end
        env.info("*** AFTER ***")
        env.info(lastUnit:getName() .. " has radar? " .. tostring(lastUnit:hasSensors(Unit.SensorType.RADAR)))
        env.info(mist.utils.tableShow(lastUnit:getSensors()))
        env.info("*************")
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
    missionCommands.addCommand("BlowUp SA3",testing.Menu,testing.boom,Group.getByName("SA-3"))
    missionCommands.addCommand("BlowUp SA10",testing.Menu,testing.testHasRadar,Group.getByName("SA10_1"))

    -- missionCommands.addCommand("Destroy C17",testing.Menu,Unit.destroy,Unit.getByName("ELINT_C17"))
    -- missionCommands.addCommand("Remove C17",testing.Menu,testing.removePlatform,{houndInstance=Elint_blue,unit_name="ELINT_C17"})
    missionCommands.addCommand("Spawn platform",testing.Menu,testing.spawnPlatform,Elint_blue)
    -- missionCommands.addCommand("Add transmitter",testing.Menu,testing.addTransmitter,{houndCommsInstance=Elint_blue.controller,unit_name="Migariya_Elint"})
    -- missionCommands.addCommand("Destroy transmitter",testing.Menu,Unit.destroy,	Unit.getByName("Migariya_Elint"))
    -- missionCommands.addCommand("Remove transmitter",testing.Menu,testing.removeTransmitter,Elint_blue.controller)
    -- missionCommands.addCommand("Get Contacts",testing.Menu,testing.getContacts,Elint_blue)
    missionCommands.addCommand("Blow up EWR",testing.Menu,testing.destroyEWR)


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
    HOUND.Logger.debug("Weapon.Category: " .. HOUND.Mist.utils.tableShow(Weapon.Category))


end
