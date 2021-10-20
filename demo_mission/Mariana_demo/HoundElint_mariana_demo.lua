do
    HOUND_DEMO = {}
    function HOUND_DEMO:setupSams()
        local tor_golf = Group.getByName("TOR_SAIPAN")
        tor_golf:enableEmission(false)
        local control = tor_golf:getController()
        control:setOnOff(true)
        control:setOption(0,2) -- ROE, Open_file
        control:setOption(9,2) -- Alarm_State, RED
        control:setOption(20,false) -- ENGAGE_AIR_WEAPONS, false

        local sa5 = Group.getByName('SA-5_SAIPAN')
        sa5:enableEmission(false)

        control = sa5:getController()
        control:setOnOff(true)
        control:setOption(0,2) -- ROE, Open_file
        control:setOption(9,2) -- Alarm_State, RED
        control:setOption(20,false) -- ENGAGE_AIR_WEAPONS, false

        local ewr = Group.getByName('EWR_SAIPAN')
        ewr:enableEmission(false)

        control = ewr:getController()
        control:setOnOff(true)
        control:setOption(0,2) -- ROE, Open_file
        control:setOption(9,2) -- Alarm_State, RED
        control:setOption(20,false) -- ENGAGE_AIR_WEAPONS, false

        local kirov = Group.getByName('KIROV_NORTH')
        kirov:enableEmission(false)

        control = kirov:getController()
        control:setOnOff(true)
        control:setOption(0,2) -- ROE, Open_file
        control:setOption(9,2) -- Alarm_State, RED
        control:setOption(20,false) -- ENGAGE_AIR_WEAPONS, false
    end

    function HOUND_DEMO:ActivateSams()
        local tor = Group.getByName("TOR_SAIPAN")
        tor:enableEmission(true)

        local sa5 = Group.getByName('SA-5_SAIPAN')
        sa5:enableEmission(true)

        local ewr = Group.getByName('EWR_SAIPAN')
        sa5:enableEmission(true)

        local kirov = Group.getByName('KIROV_NORTH')
        kirov:enableEmission(true)
    end


    function HOUND_DEMO:setupHound()
        houndBlue = HoundElint:create(coalition.side.BLUE)
        houndBlue:setMarkerType(HOUND.MARKER.POLYGON)
        houndBlue:setSectorCallsign("default","MULDER")

        houndBlue:addPlatform("ELINT_BLUE_C17_EAST")
        houndBlue:addPlatform("ELINT_BLUE_C17_WEST")
        houndBlue:systemOn()      
        
        local tts_args = {
            freq = "251.000,35.000",
            modulation = "AM,FM",
            gender = "male"
        }
        local atis_args = {
            freq = "251.500",
            NATO = true
        }
    
        houndBlue:configureController(tts_args)
        houndBlue:configureAtis(atis_args)


        houndBlue:enableAtis()
        houndBlue:enableController()

        houndBlue:enableText()
    end

    function HOUND_DEMO:setupMenus()
        self.menu = {}
        self.menu.root = missionCommands.addSubMenuForCoalition(houndBlue:getCoalition(),"Hound Testing")
        self.menu.cmd = {}
        table.insert(self.menu.cmd,missionCommands.addCommandForCoalition(houndBlue:getCoalition(),"Activate SAMs",self.menu.root,HOUND_DEMO.ActivateSams))
    end
end