do
    if STTS ~= nil then
        STTS.DIRECTORY = "C:\\Program Files\\DCS-SimpleRadio-Standalone"
    end
end

do
    
    env.info("configuring Hound")    
    Elint_blue = HoundElint:create(coalition.side.BLUE)
    Elint_blue:addPlatform("Mt_Hermon_ELINT")
    Elint_blue:addPlatform("Mt_Meron_ELINT")

    Elint_blue:addPlatform("ELINT_C130_south")
    Elint_blue:addPlatform("ELINT_C130_north")
    -- Elint_blue:addPlatform("ELINT_C17_NORTH")
    -- elint:addPlatform("HELI_ELINT")

    
    -- elint:sensorAccurecy(0.5)
    -- Elint_blue:addAdminRadioMenu()
    -- tts_args = {
    --     freq = 251,
    -- }
    -- atis_args = {
    --     freq = 251.500
    -- }
    -- Elint_blue:configureTTS(tts_args)
    -- Elint_blue:configureAtis(atis_args)

    Elint_blue:enableController()
    Elint_blue:enableText()

    Elint_blue:enableAtis()

    Elint_blue:systemOn()
    env.info("Hound - End of config")    

end