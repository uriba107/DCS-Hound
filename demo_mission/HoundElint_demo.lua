do
    
    Elint_blue = HoundElint:create()
    Elint_blue:addPlatform("ELINT_C17")
    -- Elint_blue:addPlatform("ELINT_C130")
    -- Elint_blue:addPlatform("Kokotse_Elint")
    -- Elint_blue:addPlatform("Khvamli_Elint")
    -- Elint_blue:addPlatform("Migariya_Elint")


    Elint_blue:addAdminRadioMenu()
    tts_args = {
        freq = "251.000,35.000",
		modulation = "AM,FM"
    }
    atis_args = {
        freq = 251.500,
    }
    Elint_blue:configureController(tts_args)
    Elint_blue:configureAtis(atis_args)

    Elint_blue:enableController(true)
    Elint_blue:enableATIS()

    Elint_blue:platformOn()

end