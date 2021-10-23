do
    if STTS ~= nil then
        STTS.DIRECTORY = "C:\\Program Files\\DCS-SimpleRadio-Standalone"
    end

end

do
    Elint_blue = HoundElint:create(coalition.side.BLUE)
    
    Elint_blue:systemOn()

    Elint_blue:addPlatform("ELINT_C17")
    Elint_blue:addPlatform("ELINT_C130")
    -- Elint_blue:addPlatform("Kokotse_Elint")
    -- Elint_blue:addPlatform("Khvamli_Elint")
    -- Elint_blue:addPlatform("Migariya_Elint")

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

    Elint_blue:addSector("Fake")    
    Elint_blue:setZone("Fake")


end

do
    testing = {}
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
        env.info(net.lua2json(hound:getContacts()))
    end

    function testing.spawnPlatform(hound)
        env.info("No. platforms before: " .. Length(hound.platform))
        local newGrp = mist.cloneGroup("ELINT_C17_SPAWN",true)
        local newUnit = newGrp.units[1].name
        env.info("MIST Spawn - Grp:" .. newGrp.name .. " Unit: " .. newUnit)
        hound:addPlatform(newUnit)
        env.info("No. platforms after: " .. Length(hound.platform))
    end

    testing.Menu = missionCommands.addSubMenu("Hound Testing")
    missionCommands.addCommand("Destroy Radar",testing.Menu,Unit.destroy,Unit.getByName("SA-3 P-19"))
    missionCommands.addCommand("Destroy C17",testing.Menu,Unit.destroy,Unit.getByName("ELINT_C17"))
    missionCommands.addCommand("Remove C17",testing.Menu,testing.removePlatform,{houndInstance=Elint_blue,unit_name="ELINT_C17"})
    missionCommands.addCommand("Spawn platform",testing.Menu,testing.spawnPlatform,Elint_blue)
    missionCommands.addCommand("Add transmitter",testing.Menu,testing.addTransmitter,{houndCommsInstance=Elint_blue.controller,unit_name="Migariya_Elint"})
    missionCommands.addCommand("Destroy transmitter",testing.Menu,Unit.destroy,	Unit.getByName("Migariya_Elint"))
    missionCommands.addCommand("Remove transmitter",testing.Menu,testing.removeTransmitter,Elint_blue.controller)
    missionCommands.addCommand("Get Contacts",testing.Menu,testing.getContacts,Elint_blue)
end