do
    if STTS ~= nil then
        STTS.DIRECTORY = "C:\\Program Files\\DCS-SimpleRadio-Standalone"
    end
end

do
    env.info("configuring Hound")
    HOUND.FORCE_MANAGE_MARKERS = true
    Elint_blue = HoundElint:create(coalition.side.BLUE)
    Elint_blue:addPlatform("Mt_Hermon_ELINT")
    Elint_blue:addPlatform("Mt_Meron_ELINT")

    Elint_blue:addPlatform("ELINT_C130_south")
    Elint_blue:addPlatform("ELINT_C130_north")

    -- sectors
    Elint_blue:addSector("Damascus",10)
    Elint_blue:addSector("South Syria")
    Elint_blue:addSector("Homs")
    Elint_blue:addSector("Latakya")

    Elint_blue:addSector("Palmyra")
    Elint_blue:addSector("Saykal")
    Elint_blue:addSector("Haleb")
    Elint_blue:addSector("Tabqua")

    Elint_blue:addSector("Lebanon")

    -- Assets
    Elint_blue:enableNotifier("default",{freq = "251.000,35.000", modulation = "AM,FM", speed=1})
    
    Elint_blue:enableController("Damascus",{freq="306.000", modulation = "AM"})
    Elint_blue:enableAtis("Damascus",{freq="306.250", modulation = "AM"})
    Elint_blue:setCallsign("Damascus","OPTIMUS")
    Elint_blue:setZone("Damascus","Damascus")

    Elint_blue:enableController("South Syria",{freq="306.500", modulation = "AM"})
    Elint_blue:enableAtis("South Syria",{freq="306.750", modulation = "AM"})
    Elint_blue:setCallsign("South Syria","JAZZ")
    Elint_blue:setZone("South Syria","South Syria")

    Elint_blue:enableController("Homs",{freq="307.000", modulation = "AM"})
    -- Elint_blue:enableAtis("Homs",{freq="307.250", modulation = "AM"})
    Elint_blue:setCallsign("Homs","BUMBLEBEE")
    Elint_blue:setZone("Homs","Homs")

    Elint_blue:enableController("Latakya",{freq="307.500", modulation = "AM"})
    Elint_blue:enableAtis("Latakya",{freq="307.750", modulation = "AM"})
    Elint_blue:setCallsign("Latakya","WHEELJACK")
    Elint_blue:setZone("Latakya","Latakya")

    Elint_blue:enableController("Lebanon",{freq="308.000", modulation = "AM"})
    Elint_blue:enableAtis("Lebanon",{freq="308.250", modulation = "AM"})
    Elint_blue:setCallsign("Lebanon","GRIMLOK")
    Elint_blue:setZone("Lebanon","Lebanon")

    Elint_blue:enableController("Palmyra",{freq="308.500", modulation = "AM"})
    -- Elint_blue:enableAtis("Palmyra",{freq="308.750", modulation = "AM"})
    Elint_blue:setCallsign("Palmyra","SWOOP")
    Elint_blue:setZone("Palmyra","Palmyra")

    Elint_blue:enableController("Saykal",{freq="309.000", modulation = "AM"})
    -- Elint_blue:enableAtis("Saykal",{freq="309.250", modulation = "AM"})
    Elint_blue:setCallsign("Saykal","RATCHET")
    Elint_blue:setZone("Saykal","Saykal")

    Elint_blue:enableController("Haleb",{freq="309.500", modulation = "AM"})
    Elint_blue:enableAtis("Haleb",{freq="309.750", modulation = "AM"})
    Elint_blue:setCallsign("Haleb","SLAG")
    Elint_blue:setZone("Haleb","Haleb")

    Elint_blue:enableController("Tabqa",{freq="310.000", modulation = "AM"})
    -- Elint_blue:enableAtis("Tabqa",{freq="310.250", modulation = "AM"})
    Elint_blue:setCallsign("Tabqa","IRONHIDE")
    Elint_blue:setZone("Tabqa","Tabqa")

    Elint_blue:enableText("all")

    Elint_blue:setTransmitter("all","Mt_Meron_ELINT")
    Elint_blue:systemOn()

    -- faking Satellite intel, add all enemy IADS EW radars as prebriefed.
    env.info("importing Skynet IADS EWRs")
    for _,ewRadar in pairs(redIADS:getEarlyWarningRadars()) do

        local ewRadarName = nil
        if type(ewRadar.getDCSName) == "function" then
            ewRadarName = ewRadar:getDCSName()
        end
        if ewRadarName then
            Elint_blue:preBriefedContact(ewRadarName)
        end
    end

    env.info("Hound - End of config")
end

do
    FakeEventHandler = {}
    function FakeEventHandler:onHoundEvent(event)
        if event.coalition == coalition.side.BLUE then
            if event.id == HOUND.EVENTS.RADAR_DETECTED then
                local contact = event.initiator
                trigger.action.outTextForCoalition(event.coalition,"Let's pretend a SEAD flight was fragged to strike " .. contact:getName(),10)
            end
        end
    end

    HOUND.addEventHandler(FakeEventHandler)
end