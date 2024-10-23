do
    TestHoundFunctional = {}

    function TestHoundFunctional:setUp()
        collectgarbage("collect")
    end

    function TestHoundFunctional:tearDown()
        collectgarbage("collect")
    end
    function TestHoundFunctional:Test_01_init_00_unitSetup()
        local function setupGroup(grp)
            grp:enableEmission(false)
            local control = grp:getController()
            control:setOnOff(true)
            control:setOption(0,2) -- ROE, Open_file
            control:setOption(9,2) -- Alarm_State, RED
            control:setOption(20,false) -- ENGAGE_AIR_WEAPONS, false
        end

        local tor_golf = Group.getByName("TOR_SAIPAN")
        lu.assertIsTable(tor_golf)
        lu.assertEquals(tor_golf:getSize(),1)
        setupGroup(tor_golf)

        local sa5 = Group.getByName('SA-5_SAIPAN')
        lu.assertIsTable(sa5)
        lu.assertEquals(sa5:getSize(),8)
        setupGroup(sa5)

        local ewr = Group.getByName('EWR_SAIPAN')
        lu.assertIsTable(ewr)
        lu.assertEquals(ewr:getSize(),1)
        setupGroup(ewr)

        local ships = Group.getByName('SHIPS_NORTH')
        lu.assertIsTrue(HOUND.Utils.Dcs.isGroup(ships))
        lu.assertEquals(ships:getSize(),2)
        setupGroup(ships)

        local sa6 = Group.getByName('SA-6_TINIAN')
        lu.assertIsTable(sa6)
        lu.assertEquals(sa6:getSize(),5)
        setupGroup(sa6)

        local sa3 = Group.getByName('SA-3_TINIAN')
        lu.assertIsTrue(HOUND.Utils.Dcs.isGroup(sa3))
        lu.assertEquals(sa3:getSize(),6)
        setupGroup(sa3)

    end

    function TestHoundFunctional:Test_01_init_01_BadInit()
        lu.assertIsNil(self.houndBlue)
        self.houndBlue = HoundElint:create()
        lu.assertIsNil(self.houndBlue)
    end

    function TestHoundFunctional:Test_01_init_02_BlueInit()
        -- Test blue init
        lu.assertIsNil(self.houndBlue)
        self.houndBlue = HoundElint:create(coalition.side.BLUE)
        lu.assertIsTable(self.houndBlue)
        lu.assertEquals(self.houndBlue:getId(),1)
        -- Test coalition logic
        lu.assertEquals(self.houndBlue:getCoalition(),coalition.side.BLUE)
        lu.assertIsFalse(self.houndBlue:setCoalition(coalition.side.RED))
    end

    function TestHoundFunctional:Test_01_init_03_RedInit()
        -- Test Red init
        lu.assertIsNil(self.houndRed)
        self.houndRed = HoundElint:create(coalition.side.RED)
        lu.assertIsTable(self.houndRed)
        lu.assertEquals(self.houndRed:getId(),2)
    end

    function TestHoundFunctional:Test_01_init_04_ConfigSingelton()
         -- make sure setting singletons are different between instances
        lu.assertNotEquals(self.houndBlue.settings,self.houndRed.settings)
        -- make sure setting singelton is same in in same instance
        lu.assertIs(self.houndBlue.settings,self.houndBlue.contacts.settings)
        lu.assertIsTrue(self.houndBlue:setMarkerType(HOUND.MARKER.CIRCLE))
        -- direct check of change
        lu.assertEquals(self.houndBlue.settings.preferences.markerType,HOUND.MARKER.CIRCLE)
        -- check again that configs are the same
        lu.assertEquals(self.houndBlue.settings,self.houndBlue.contacts.settings)
        -- check via internal function on inheritance
        lu.assertEquals(self.houndBlue.contacts.settings:getMarkerType(),HOUND.MARKER.CIRCLE)
    end

    function TestHoundFunctional:Test_01_init_05_HoundStartup()
        -- make sure system is not running and no platforms are present
        lu.assertEquals(self.houndBlue:getId(),1)
        lu.assertIsFalse(self.houndBlue:isRunning())
        -- Make sure system starts with no platforms but with coalition
        lu.assertIsTrue(self.houndBlue:systemOn())
        lu.assertIsTrue(self.houndBlue:isRunning())
    end

    function TestHoundFunctional:Test_01_init_06_PlatformMgmt()
        -- Verify initial state
        lu.assertIsTrue(self.houndBlue:isRunning())
        lu.assertEquals(self.houndBlue:countPlatforms(),0)
        -- try and add platforms
        lu.assertIsFalse(self.houndBlue:addPlatform("bad_Unit_name"))
        lu.assertEquals(self.houndBlue:countPlatforms(),0)
        lu.assertIsTrue(self.houndBlue:addPlatform("ELINT_BLUE_C17_EAST"))
        lu.assertEquals(self.houndBlue:countPlatforms(),1)
        lu.assertItemsEquals(self.houndBlue:listPlatforms(),{"ELINT_BLUE_C17_EAST"})
        -- Test remve platform
        lu.assertIsFalse(self.houndBlue:removePlatform("bad_Unit_name"))
        lu.assertIsTrue(self.houndBlue:removePlatform("ELINT_BLUE_C17_EAST"))
        lu.assertEquals(self.houndBlue:countPlatforms(),0)
        lu.assertEquals(self.houndBlue:listPlatforms(),{})
    end

    function TestHoundFunctional:Test_01_init_06_destroy()
        lu.assertIsTable(self.houndBlue)
        lu.assertIsTable(self.houndRed)

        self.houndBlue = self.houndBlue:destroy()
        lu.assertIsNil(self.houndBlue)

        lu.assertIsNil(self.houndRed:destroy())
        lu.assertIsTable(self.houndRed)
        lu.assertIsFalse(self.houndRed:isRunning())
        self.houndRed = nil
        lu.assertIsNil(self.houndRed)
    end
end