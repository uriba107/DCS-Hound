do
    if STTS ~= nil then
        STTS.DIRECTORY = "C:\\Program Files\\DCS-SimpleRadio-Standalone"
    end
end

do
    
    env.info("configuring Hound")    
    Elint_blue = HoundElint:create("Mt_Meron_ELINT")
    Elint_blue:addPlatform("Mt_Hermon_ELINT")

    Elint_blue:addPlatform("ELINT_C130_south")
    Elint_blue:addPlatform("ELINT_C130_north")
    -- elint:addPlatform("ELINT_3")
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

    Elint_blue:enableController(true)
    Elint_blue:enableATIS()

    Elint_blue:systemOn()
    env.info("Hound - End of config")    

end