do
    TestHoundFunctionalBase = {}

    
    function TestHoundFunctionalBase:setUp()
        collectgarbage("collect")
    end

    function TestHoundFunctionalBase:tearDown()
        collectgarbage("collect")
    end

    function TestHoundFunctionalBase:Test_02_base_00_unitSetup()

        local function setupGroup(grp)
            grp:enableEmission(false)
            local control = grp:getController()
            control:setOnOff(true)
            control:setOption(0,2) -- ROE, Open_file
            control:setOption(9,2) -- Alarm_State, RED
            control:setOption(20,false) -- ENGAGE_AIR_WEAPONS, false
        end

        local tor_golf = Group.getByName("TOR_SAIPAN")
        lu.assertIsTrue(HOUND.Utils.Dcs.isGroup(tor_golf))
        lu.assertEquals(tor_golf:getSize(),1)
        tor_golf:enableEmission(false)
        local control = tor_golf:getController()
        setupGroup(tor_golf)

        local sa5 = Group.getByName('SA-5_SAIPAN')
        lu.assertIsTrue(HOUND.Utils.Dcs.isGroup(sa5))
        lu.assertEquals(sa5:getSize(),8)
        sa5:enableEmission(false)
        setupGroup(sa5)

        local ewr = Group.getByName('EWR_SAIPAN')
        lu.assertIsTrue(HOUND.Utils.Dcs.isGroup(ewr))
        lu.assertEquals(ewr:getSize(),1)
        ewr:enableEmission(false)
        setupGroup(ewr)

        local ships = Group.getByName('SHIPS_NORTH')
        lu.assertIsTrue(HOUND.Utils.Dcs.isGroup(ships))
        lu.assertEquals(ships:getSize(),2)
        ships:enableEmission(false)
        setupGroup(ships)

        local sa6 = Group.getByName('SA-6_TINIAN')
        lu.assertIsTrue(HOUND.Utils.Dcs.isGroup(sa6))
        lu.assertEquals(sa6:getSize(),5)
        sa6:enableEmission(false)
        setupGroup(sa6)

    end
    function TestHoundFunctional:Test_02_base_01_Init()
        -- make sure nothing is currently active
        lu.assertIsNil(self.houndBlue)
        self.houndBlue = HoundElint:create(coalition.side.BLUE)
        lu.assertIsTable(self.houndBlue)
        lu.assertIsNumber(self.houndBlue:getId())
        lu.assertEquals(HOUND.Length(HOUND.INSTANCES),1)
        lu.assertIsTrue(HOUND.setContainsValue(HOUND.INSTANCES,self.houndBlue))
        -- ensure not running and add platforms
        lu.assertIsFalse(self.houndBlue:isRunning())
        lu.assertEquals(self.houndBlue:countPlatforms(),0)
        lu.assertIsTrue(self.houndBlue:addPlatform("ELINT_BLUE_C17_EAST"))
        lu.assertIsTrue(self.houndBlue:addPlatform("ELINT_BLUE_C17_WEST"))

        lu.assertEquals(self.houndBlue:countPlatforms(),2)
        lu.assertItemsEquals(self.houndBlue:listPlatforms(),{"ELINT_BLUE_C17_WEST","ELINT_BLUE_C17_EAST"})
        lu.assertIsFalse(self.houndBlue:removePlatform("StaticTower"))

        lu.assertIsTrue(self.houndBlue:addPlatform("StaticTower"))
        lu.assertEquals(self.houndBlue:countPlatforms(),3)
        lu.assertItemsEquals(self.houndBlue:listPlatforms(),{"ELINT_BLUE_C17_WEST","ELINT_BLUE_C17_EAST","StaticTower"})

        lu.assertIsTrue(self.houndBlue:setMarkerType(HOUND.MARKER.POLYGON))
        lu.assertEquals(self.houndBlue.settings.preferences.markerType,HOUND.MARKER.POLYGON)

        lu.assertIsTrue(self.houndBlue:removePlatform("StaticTower"))
        lu.assertEquals(self.houndBlue:countPlatforms(),2)
        lu.assertItemsEquals(self.houndBlue:listPlatforms(),{"ELINT_BLUE_C17_WEST","ELINT_BLUE_C17_EAST"})
        self.houndBlue:systemOn()
        lu.assertIsTrue(self.houndBlue:isRunning())
    end

    function TestHoundFunctional:Test_02_base_02_controllers()
        lu.assertIsTrue(self.houndBlue:isRunning())
        lu.assertEquals(self.houndBlue:countPlatforms(),2)
        lu.assertEquals(self.houndBlue:countContacts(),0)
        lu.assertItemsEquals(self.houndBlue:listSectors(),{"default"})
        lu.assertEquals(self.houndBlue:getCallsign("default"),"HOUND")
        self.houndBlue:setAtisUpdateInterval(15)

        local tts_args = {
            freq = "251.000,35.000",
            modulation = "AM,FM",
            gender = "male"
        }
        local atis_args = {
            freq = "251.500",
            NATO = false
        }

        self.houndBlue:configureController(tts_args)
        self.houndBlue:configureAtis(atis_args)
        lu.assertEquals(self.houndBlue.sectors.default.comms.atis.callback.interval,300)
        lu.assertItemsEquals(self.houndBlue:getControllerFreq(),{"251.000 AM","35.000 FM"})
        lu.assertItemsEquals(self.houndBlue:getAtisFreq(),{"251.500 AM"})

        self.houndBlue:enableController()

        lu.assertIsTrue(self.houndBlue.sectors.default:isControllerEnabled())
        lu.assertIsFalse(self.houndBlue.sectors.default.comms.controller:getSettings("enableText"))

        self.houndBlue:enableText()
        lu.assertIsTrue(self.houndBlue.sectors.default.comms.controller:getSettings("enableText"))

        self.houndBlue:enableAtis()
        lu.assertIsTrue(self.houndBlue.sectors.default:isAtisEnabled())
        lu.assertEquals(self.houndBlue.sectors.default.comms.atis.callback.interval,15)


        lu.assertItemsEquals(self.houndBlue:getControllerFreq(),{"251.000 AM","35.000 FM"})
        lu.assertItemsEquals(self.houndBlue:getAtisFreq(),{"251.500 AM"})
        lu.assertIsTrue(self.houndBlue.sectors.default.comms.controller:getSettings("enableText"))

        -- Some whitebox shananigans
        -- force ATIS refresh
        self.houndBlue.sectors.default.comms.atis:runCallback()
        lu.assertEquals(self.houndBlue.sectors.default.comms.atis.loop.msg.tts,"HOUND SAM information Alpha 08 hundred Local. No threats had been detected you have Alpha.")

        -- change ATIS to NATO and force refresh
        lu.assertIsFalse(self.houndBlue:getNATO())
        self.houndBlue:enableNATO()
        lu.assertIsTrue(self.houndBlue:getNATO())
        self.houndBlue:disableNATO()
        lu.assertIsFalse(self.houndBlue:getNATO())


        lu.assertIsTrue(self.houndBlue:getControllerState("default"))
        lu.assertIsTrue(self.houndBlue:getAtisState("default"))
        lu.assertIsFalse(self.houndBlue:getNotifierState("default"))

        lu.assertIsFalse(self.houndBlue:getAlertOnLaunch())
        lu.assertIsTrue(self.houndBlue:setAlertOnLaunch(true))
        lu.assertIsTrue(self.houndBlue:getAlertOnLaunch())

    end

    function TestHoundFunctional:Test_02_base_03_turnRadarsOn()
        lu.assertIsTrue(self.houndBlue:isRunning())
        lu.assertEquals(self.houndBlue:countPlatforms(),2)
        lu.assertEquals(self.houndBlue:countContacts(),0)

        local tor = Group.getByName("TOR_SAIPAN")
        lu.assertIsTrue(HOUND.Utils.Dcs.isGroup(tor))
        lu.assertEquals(tor:getSize(),1)
        tor:enableEmission(true)

        local sa5 = Group.getByName('SA-5_SAIPAN')
        lu.assertIsTrue(HOUND.Utils.Dcs.isGroup(sa5))
        lu.assertEquals(sa5:getSize(),8)
        sa5:enableEmission(true)

        local ewr = Group.getByName('EWR_SAIPAN')
        lu.assertIsTrue(HOUND.Utils.Dcs.isGroup(ewr))
        lu.assertEquals(ewr:getSize(),1)
        sa5:enableEmission(true)

        local ships = Group.getByName('SHIPS_NORTH')
        lu.assertIsTrue(HOUND.Utils.Dcs.isGroup(ships))
        lu.assertEquals(ships:getSize(),2)
        ships:enableEmission(true)

        local sa6 = Group.getByName('SA-6_TINIAN')
        lu.assertIsTrue(HOUND.Utils.Dcs.isGroup(sa6))
        lu.assertEquals(sa6:getSize(),5)
        sa6:enableEmission(true)

        lu.assertIsTrue(sa5:getUnits()[1]:getRadar())
        lu.assertIsFalse(sa5:getUnits()[2]:getRadar())
        lu.assertIsTrue(ewr:getUnits()[1]:getRadar())
        lu.assertIsTrue(ships:getUnits()[1]:getRadar())
        lu.assertIsTrue(tor:getUnits()[1]:getRadar())
        lu.assertIsTrue(sa6:getUnits()[1]:getRadar())
    end

    function TestHoundFunctional:Test_02_base_04_Multi_Sector()
        lu.assertIsTrue(self.houndBlue:isRunning())
        lu.assertEquals(self.houndBlue:countPlatforms(),2)
        self.houndBlue:setAtisUpdateInterval(60)


        self.houndBlue:enableNotifier({freq="251.000", modulation="AM"})
        self.houndBlue:disableController()
        self.houndBlue:disableAtis()

        local saipan = self.houndBlue:addSector("Saipan")
        lu.assertEquals(saipan:getPriority(),50)
        self.houndBlue:enableController("Saipan")
        self.houndBlue:configureController("Saipan",{
            freq = "252.000,35.000",
            modulation = "AM,FM",
            gender = "male"
        })
        self.houndBlue:enableAtis("Saipan",{freq = 252.500, modulation="AM"})
        lu.assertEquals(self.houndBlue.sectors.Saipan.comms.atis.callback.interval,60)

        lu.assertIsFalse(self.houndBlue:getNATO())
        self.houndBlue:enableNATO()
        lu.assertIsTrue(self.houndBlue:getNATO())


        lu.assertIsFalse(self.houndBlue:getControllerState("default"))
        lu.assertIsFalse(self.houndBlue:getAtisState("default"))
        lu.assertIsTrue(self.houndBlue:getNotifierState("default"))

        lu.assertIsTrue(self.houndBlue:getControllerState("Saipan"))
        lu.assertIsTrue(self.houndBlue:getAtisState("Saipan"))
        lu.assertIsFalse(self.houndBlue:getNotifierState("Saipan"))

        lu.assertItemsEquals(self.houndBlue:getNotifierFreq("default"),{"251.000 AM"})

        lu.assertItemsEquals(self.houndBlue:getControllerFreq("Saipan"),{"252.000 AM","35.000 FM"})
        lu.assertItemsEquals(self.houndBlue:getAtisFreq("Saipan"),{"252.500 AM"})

        lu.assertItemsEquals(saipan:getControllerFreq(),{"252.000 AM","35.000 FM"})
        lu.assertItemsEquals(saipan:getAtisFreq(),{"252.500 AM"})
        self.houndBlue:enableText("all")
        self.houndBlue:setMarkerType(HOUND.MARKER.POLYGON)

        local testCallsign = "OPTIMUS"
        lu.assertNotEquals(self.houndBlue:getCallsign("Saipan"),testCallsign)
        self.houndBlue:setCallsign("Saipan","OPTIMUS")
        lu.assertEquals(self.houndBlue:getCallsign("Saipan"),testCallsign)
        self.houndBlue:setTransmitter("all","StaticTower")
    end

    function TestHoundFunctional:Test_02_base_05_Multi_Sector_zone()
        lu.assertItemsEquals(self.houndBlue:listSectors(),{"default","Saipan"})
        self.houndBlue:addSector("Tinian")
        lu.assertItemsEquals(self.houndBlue:listSectors(),{"default","Saipan","Tinian"})

        lu.assertIsNil(self.houndBlue:getZone("default"))
        lu.assertIsNil(self.houndBlue:getZone("Saipan"))
        lu.assertIsNil(self.houndBlue:getZone("Tinian"))
        self.houndBlue:setZone("Tinian")
        lu.assertIsTable(self.houndBlue:getZone("Tinian"))

        local zoneAutomatic = HOUND.Mist.utils.deepCopy(self.houndBlue:getZone("Tinian"))

        self.houndBlue:removeZone("Tinian")
        lu.assertIsNil(self.houndBlue:getZone("Tinian"))


        self.houndBlue:setZone("Saipan","Sector_Saipan")
        self.houndBlue:setZone("Tinian","Tinian Sector")

        lu.assertIsNil(self.houndBlue:getZone("default"))
        lu.assertIsTable(self.houndBlue:getZone("Saipan"))
        lu.assertIsTable(self.houndBlue:getZone("Tinian"))
        local zoneManual = HOUND.Mist.utils.deepCopy(self.houndBlue:getZone("Tinian"))

        lu.assertItemsEquals(zoneManual,zoneAutomatic)
    end

    function TestHoundFunctional:Test_02_base_06_radio_menu()
        lu.assertIsTable(self.houndBlue.settings:getRadioMenu())
        local originalMenu = HOUND.Mist.utils.deepCopy(self.houndBlue.settings:getRadioMenu())
        self.houndBlue:purgeRadioMenu()
        local test_root = missionCommands.addSubMenu("new root")
        self.houndBlue:setRadioMenuParent(test_root)
        lu.assertIsTable(self.houndBlue.settings:getRadioMenu())
        local shiftedRoot = HOUND.Mist.utils.deepCopy(self.houndBlue.settings:getRadioMenu())

        lu.assertNotEquals(originalMenu,shiftedRoot)
        self.houndBlue:purgeRadioMenu()

        self.houndBlue:setRadioMenuParent(nil)
        local postRootMenu = HOUND.Mist.utils.deepCopy(self.houndBlue.settings:getRadioMenu())
        lu.assertIsTable(self.houndBlue.settings:getRadioMenu())
        lu.assertItemsEquals(originalMenu,postRootMenu)
        self.houndBlue:purgeRadioMenu()
        lu.assertIsTable(self.houndBlue.settings:getRadioMenu())
        self.houndBlue:populateRadioMenu()
        missionCommands.removeItem(test_root)
    end

    function TestHoundFunctional:Test_02_base_07_prebriefed()
        lu.assertEquals(self.houndBlue:countPreBriefedContacts(),0)
        self.houndBlue:preBriefedContact('SA-5_SAIPAN-1')
        lu.assertEquals(self.houndBlue:countPreBriefedContacts(),1)
        self.houndBlue:preBriefedContact('fakeUnitName')
        lu.assertEquals(self.houndBlue:countPreBriefedContacts(),1)
    end

    function TestHoundFunctional:Test_02_base_08_sites()
        lu.assertEquals(self.houndBlue:countPreBriefedContacts(),1)
        local elint = self.houndBlue.contacts
        lu.assertIsTrue(getmetatable(elint)==HOUND.ElintWorker)
        self.houndBlue:preBriefedContact('SA-3_TINIAN-1')
        local sa3_sr = elint:getContact('SA-3_TINIAN-1',true)
        local sa3_tr = elint:getContact('SA-3_TINIAN-2',true)
        lu.assertEquals(self.houndBlue:countPreBriefedContacts(),2)
        lu.assertIsTrue(getmetatable(sa3_sr)==HOUND.Contact.Emitter)
        lu.assertIsNil(sa3_tr)
        local sa3_site = elint:getSite('SA-3_TINIAN')
        lu.assertIsTrue(getmetatable(sa3_site)==HOUND.Contact.Site)
        lu.assertEquals(sa3_sr,sa3_site:getPrimary())
        lu.assertEquals("SA-2 or SA-3",sa3_site:getTypeAssigned())
        lu.assertEquals(sa3_site:getName(),"T004")
        lu.assertEquals(sa3_site:generatePopUpReport(false,"Tinian"),"T004, identified as 2 or 3, is active in Tinian.")
        self.houndBlue:preBriefedContact('SA-3_TINIAN',"Non La")
        lu.assertEquals(self.houndBlue:countPreBriefedContacts(),3)
        lu.assertEquals(sa3_site:getName(),"Non La")
        sa3_tr = elint:getContact('SA-3_TINIAN-2',true)
        lu.assertIsTrue(getmetatable(sa3_tr)==HOUND.Contact.Emitter)
        lu.assertNotEquals(sa3_sr,sa3_site:getPrimary())
        lu.assertEquals(sa3_tr,sa3_site:getPrimary())
        lu.assertEquals("SA-3",sa3_site:getTypeAssigned())
        lu.assertEquals(sa3_site:generatePopUpReport(false,"Tinian"),"Non La, identified as 3, is active in Tinian.")
        lu.assertNotEquals(sa3_site:getName(),"T004")
    end

    function TestHoundFunctional:Test_02_base_09_eventHandler()
            lu.assertEquals(type(self.houndBlue.onHoundEvent),"function")
            lu.assertIsNil(self.houndBlue:onHoundEvent({HoundId = self.houndBlue:getId(),id = "success"}))

            function self.houndBlue:onHoundEvent(event)
                if event.id == "success" then return true end
            end

            lu.assertEquals(type(self.houndBlue.onHoundEvent),"function")
            lu.assertIsTrue(self.houndBlue:onHoundEvent({HoundId = self.houndBlue:getId(),id = "success"}))
    end

    function TestHoundFunctional:Test_02_base_10_human_elint()
        humanElint = {}
        humanElint.HoundInstance = self.houndBlue
        function humanElint:onEvent(DcsEvent)
            if DcsEvent.id == world.event.S_EVENT_BIRTH and self.HoundInstance then
                if self.HoundInstance and DcsEvent.initiator and DcsEvent.initiator:getCoalition() == self.HoundInstance:getCoalition()
                and HOUND.setContainsValue({"AJS37","Su-25T","F-16C_50"},DcsEvent.initiator:getTypeName()) and DcsEvent.initiator:getPlayerName()
                then
                    env.info(self.HoundInstance:countPlatforms())
                    env.info("Adding Human " .. DcsEvent.initiator:getPlayerName() .. " (" .. DcsEvent.initiator:getTypeName() ..")")
                    self.HoundInstance:addPlatform(DcsEvent.initiator:getName())
                    env.info(self.HoundInstance:countPlatforms())
                end
            end
        end
    
        world.addEventHandler(humanElint)
    end
end