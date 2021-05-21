do
    if STTS ~= nil then
        STTS.DIRECTORY = "C:\\Program Files\\DCS-SimpleRadio-Standalone"
    end
end

do
    
    Elint_blue = HoundElint:create()
    Elint_blue:addPlatform("ELINT_C17")
    Elint_blue:addPlatform("ELINT_C130")
    -- Elint_blue:addPlatform("Kokotse_Elint")
    -- Elint_blue:addPlatform("Khvamli_Elint")
    Elint_blue:addPlatform("Migariya_Elint")


    Elint_blue:addAdminRadioMenu()


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

    Elint_blue:enableController(true)
    Elint_blue:enableATIS()

    Elint_blue:systemOn()

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
    end

    testing.Menu = missionCommands.addSubMenu("Hound Testing")
    missionCommands.addCommand("Destroy Radar",testing.Menu,Unit.destroy,Unit.getByName("SA-3 P-19"))
    missionCommands.addCommand("Destroy C17",testing.Menu,Unit.destroy,Unit.getByName("ELINT_C17"))
    missionCommands.addCommand("Remove C17",testing.Menu,testing.removePlatform,{houndInstance=Elint_blue,unit_name="ELINT_C17"})
    missionCommands.addCommand("Add transmitter",testing.Menu,testing.addTransmitter,{houndCommsInstance=Elint_blue.controller,unit_name="Migariya_Elint"})
    missionCommands.addCommand("Destroy transmitter",testing.Menu,Unit.destroy,	Unit.getByName("Migariya_Elint"))
    missionCommands.addCommand("Remove transmitter",testing.Menu,testing.removeTransmitter,Elint_blue.controller)
    missionCommands.addCommand("Get Contacts",testing.Menu,testing.getContacts,Elint_blue)

end