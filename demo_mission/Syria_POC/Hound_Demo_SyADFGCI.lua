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
    Elint_blue:addPlatform("ELINT_TURKEY")


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
    HoundEventHandler = {}
    function HoundEventHandler:onHoundEvent(event)
        if event.coalition == coalition.side.BLUE then
            if event.id == HOUND.EVENTS.RADAR_DETECTED then
                local contact = event.initiator
                trigger.action.outTextForCoalition(event.coalition,"Fragging a SEAD flight to strike " .. contact:getName(),10)
                local grp = contact:getUnit():getGroup()
                if not grp then return end
                -- select SEAD flight
                local pos = contact:getPos()
                local seadFlights = {'SEAD_NORTH','SEAD_WEST','SEAD_SOUTH'}
                table.sort(seadFlights,
                            function (f1,f2) 
                                local p1 = Group.getByName(f1):getUnit(1):getPoint()
                                local p2 = Group.getByName(f2):getUnit(1):getPoint()
                                return mist.utils.get2DDist(pos,p1) < mist.utils.get2DDist(pos,p2)
                            end)
                -- initilize mission
                local mooseGroup = GROUP:FindByName(contact:getUnit():getGroup():getName())
                local mission = AUFTRAG:NewSEAD(mooseGroup, 20000)
                local sector = Elint_blue:getSector(contact:getPrimarySector())
                env.info(tostring(sector:hasController()))
                local controllerFreq = nil
                if sector:hasController() then
                    controllerFreq = string.split(sector:getControllerFreq()[1]," ")
                    if controllerFreq[2] == "FM" then controllerFreq[3] = 1 else controllerFreq[3] = 0 end
                    mission:SetRadio(tonumber(controllerFreq[1]),controllerFreq[3])
                end
                local seadStrike = SPAWN:NewWithAlias(seadFlights[1],"SEAD ".. contact:getName()):OnSpawnGroup( 
                    function( SeadGroup )
                        local fg=FLIGHTGROUP:New(SeadGroup)
                        fg:AddMission(mission)
                    end
                  )
                if controllerFreq then
                    seadStrike:InitRadioFrequency(controllerFreq[1])
                    seadStrike:InitRadioModulation(controllerFreq[2])
                end
                seadStrike:Spawn()
            end
        end
    end

    HOUND.addEventHandler(HoundEventHandler)
end