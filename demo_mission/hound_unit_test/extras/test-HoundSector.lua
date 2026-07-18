
do
    TestHoundSector = {}

    local mockSettings = {
        callsigns = {},
        getUseNATOCallsigns = function() return false end,
        getCoalition = function() return coalition.side.BLUE end,
        getCallsignOverride = function() return nil end,
        getNATO = function() return false end,
        getAlertOnLaunch = function() return false end,
    }

    local mockContacts = {
        listAllContactsByRange = function() return {} end,
        countContacts = function() return 0 end,
        listAllContacts = function() return {} end,
        listAllSitesByRange = function() return {} end,
        listAllSites = function() return {} end,
        countSites = function() return 0 end,
        getSite = function() return nil end,
        getContact = function() return nil end,
    }

    function TestHoundSector:setUp()
        self.sector = HOUND.Sector.create(1, "default")
        lu.assertNotNil(self.sector)
    end

    function TestHoundSector:tearDown()
        self.sector = nil
        mockSettings.callsigns = {}
    end

    function TestHoundSector:TestConstructorInvalid()
        lu.assertIsNil(HOUND.Sector.create())
        lu.assertIsNil(HOUND.Sector.create(nil))
        lu.assertIsNil(HOUND.Sector.create(1, nil))
        lu.assertIsNil(HOUND.Sector.create("1", "test"))
        lu.assertIsNil(HOUND.Sector.create({}, "test"))
        lu.assertIsNil(HOUND.Sector.create(1, {}))
    end

    function TestHoundSector:TestConstructorValid()
        local s = HOUND.Sector.create(1, "default")
        lu.assertNotNil(s)
        lu.assertIsTrue(getmetatable(s) == HOUND.Sector)
        lu.assertEquals(s:getName(), "default")
        lu.assertEquals(s:getPriority(), 10)
        lu.assertEquals(s.callsign, "HOUND")
        lu.assertIsTable(s.childSectors)
        lu.assertEquals(HOUND.Length(s.childSectors), 0)
        lu.assertIsNil(s.settings.zone)
        lu.assertIsNil(s.settings.controller)
        lu.assertIsNil(s.settings.atis)
        lu.assertIsNil(s.settings.notifier)
        lu.assertIsNil(s.settings.transmitter)
    end

    function TestHoundSector:TestConstructorWithPriority()
        local s = HOUND.Sector.create(1, "default", nil, 5)
        lu.assertEquals(s:getPriority(), 5)
    end

    function TestHoundSector:TestConstructorWithSettings()
        local s = HOUND.Sector.create(1, "default", {foo = "bar"})
        lu.assertEquals(s.settings.foo, "bar")
    end

    function TestHoundSector:TestGetName()
        lu.assertEquals(self.sector:getName(), "default")
    end

    function TestHoundSector:TestGetPriority()
        lu.assertEquals(self.sector:getPriority(), 10)
    end

    function TestHoundSector:TestGetCallsignDefault()
        lu.assertEquals(self.sector:getCallsign(), "HOUND")
    end

    function TestHoundSector:TestSetCallsign()
        self.sector._hSettings = mockSettings
        self.sector:setCallsign("ALPHA")
        lu.assertEquals(self.sector:getCallsign(), "ALPHA")
        lu.assertIsTrue(HOUND.setContainsValue(mockSettings.callsigns, "ALPHA"))
    end

    function TestHoundSector:TestSetCallsignNATO()
        self.sector._hSettings = mockSettings
        self.sector:setCallsign("BRAVO", true)
        lu.assertEquals(self.sector:getCallsign(), "BRAVO")
    end

    function TestHoundSector:TestSetCallsignBoolArg()
        self.sector._hSettings = mockSettings
        self.sector:setCallsign(true)
        local cs = self.sector:getCallsign()
        lu.assertIsString(cs)
        lu.assertNotEquals(cs, "HOUND")
        lu.assertIsTrue(#cs > 0)
    end

    function TestHoundSector:TestSetCallsignNoDuplicate()
        self.sector._hSettings = mockSettings
        table.insert(mockSettings.callsigns, "ALPHA")
        self.sector:setCallsign("ALPHA")
        -- should generate a new callsign since ALPHA is taken
        lu.assertNotEquals(self.sector:getCallsign(), "HOUND")
        lu.assertIsString(self.sector:getCallsign())
    end

    function TestHoundSector:TestZoneDefaults()
        lu.assertIsNil(self.sector:getZone())
        lu.assertIsFalse(self.sector:hasZone())
        lu.assertIsNil(self.sector:getCenter())
    end

    function TestHoundSector:TestSetGetZone()
        local zone = {{x=0,z=0,y=0},{x=1,z=0,y=0},{x=1,z=1,y=0},{x=0,z=1,y=0}}
        self.sector.settings.zone = zone
        lu.assertIsTrue(self.sector:hasZone())
        lu.assertEquals(self.sector:getZone(), zone)
    end

    function TestHoundSector:TestRemoveZone()
        self.sector.settings.zone = {{x=0,z=0}}
        lu.assertIsTrue(self.sector:hasZone())
        self.sector:removeZone()
        lu.assertIsNil(self.sector:getZone())
        lu.assertIsFalse(self.sector:hasZone())
    end

    function TestHoundSector:TestGetCenter()
        lu.assertIsNil(self.sector:getCenter())
        self.sector.zoneCenter = {x=100,z=200,y=0}
        lu.assertEquals(self.sector:getCenter().x, 100)
        lu.assertEquals(self.sector:getCenter().z, 200)
    end

    function TestHoundSector:TestChildSectorAddRemove()
        self.sector:addChildSector("saipan")
        self.sector:addChildSector("tinian")
        lu.assertIsFalse(self.sector:hasChildSector("saipan"))
        lu.assertIsFalse(self.sector:hasChildSector("tinian"))
        lu.assertIsFalse(self.sector:hasChildSectors())
        local children = self.sector:getChildSectors()
        lu.assertNil(children.saipan)
        lu.assertNil(children.tinian)

        self.sector:removeChildSector("saipan")
        lu.assertIsFalse(self.sector:hasChildSector("saipan"))
        lu.assertIsFalse(self.sector:hasChildSector("tinian"))
        self.sector:removeChildSector("tinian")
        lu.assertIsFalse(self.sector:hasChildSectors())
    end

    function TestHoundSector:TestChildSectorReserved()
        local s = HOUND.Sector.create(1, "default")
        s:addChildSector("test")
        lu.assertIsFalse(s:hasChildSector("test"))
    end

    function TestHoundSector:TestHasNoChildSectors()
        lu.assertIsFalse(self.sector:hasChildSectors())
        lu.assertIsFalse(self.sector:hasChildSector("nonexistent"))
    end

    function TestHoundSector:TestSetRemoveTransmitter()
        self.sector:setTransmitter("Unit1")
        lu.assertEquals(self.sector.settings.transmitter, "Unit1")
        self.sector:removeTransmitter()
        lu.assertIsNil(self.sector.settings.transmitter)
    end

    function TestHoundSector:TestShouldNotifyForDefault()
        local should, label = self.sector:shouldNotifyFor("saipan")
        lu.assertIsTrue(should)
        lu.assertEquals(label, "saipan")
    end

    function TestHoundSector:TestShouldNotifyForDefaultDefault()
        local should, label = self.sector:shouldNotifyFor("default")
        lu.assertIsTrue(should)
        lu.assertIsNil(label)
    end

    function TestHoundSector:TestShouldNotifyForSelf()
        local s = HOUND.Sector.create(1, "default")
        s.name = "saipan"
        local should, label = s:shouldNotifyFor("saipan")
        lu.assertIsTrue(should)
        lu.assertIsNil(label)
    end

    function TestHoundSector:TestShouldNotifyForChild()
        local s = HOUND.Sector.create(1, "default")
        s.name = "meta"
        s:addChildSector("tinian")
        local should, label = s:shouldNotifyFor("tinian")
        lu.assertIsTrue(should)
        lu.assertEquals(label, "tinian")
    end

    function TestHoundSector:TestShouldNotifyForNoMatch()
        local s = HOUND.Sector.create(1, "default")
        s.name = "saipan"
        local should, label = s:shouldNotifyFor("tinian")
        lu.assertIsFalse(should)
        lu.assertIsNil(label)
    end

    function TestHoundSector:TestEffectiveSectorNamesDefault()
        local names = self.sector:getEffectiveSectorNames()
        lu.assertIsTable(names)
        lu.assertEquals(#names, 1)
        lu.assertEquals(names[1], "default")
    end

    function TestHoundSector:TestEffectiveSectorNamesWithZone()
        self.sector.name = "saipan"
        self.sector.settings.zone = {{x=0,z=0},{x=1,z=1}}
        local names = self.sector:getEffectiveSectorNames()
        lu.assertEquals(#names, 1)
        lu.assertEquals(names[1], "saipan")
    end

    function TestHoundSector:TestEffectiveSectorNamesWithChildSectors()
        self.sector:addChildSector("tinian")
        self.sector:addChildSector("saipan")
        local names = self.sector:getEffectiveSectorNames()
        lu.assertEquals(#names, 1)
        lu.assertEquals(names[1], "default")
    end

    function TestHoundSector:TestContactSiteHelpersEmpty()
        self.sector._contacts = mockContacts
        local contacts = self.sector:getContacts()
        lu.assertIsTable(contacts)
        lu.assertEquals(#contacts, 0)
        lu.assertEquals(self.sector:countContacts(), 0)
        local sites = self.sector:getSites()
        lu.assertIsTable(sites)
        lu.assertEquals(#sites, 0)
        lu.assertEquals(self.sector:countSites(), 0)
    end

    function TestHoundSector:TestContactSiteHelpersNoContacts()
        -- without _contacts, getContacts/countContacts etc would error
        -- but with _contacts mock they work
        self.sector._contacts = mockContacts
        local contacts = self.sector:getContacts()
        lu.assertIsTable(contacts)
        local sites = self.sector:getSites()
        lu.assertIsTable(sites)
    end

    function TestHoundSector:TestFindGrpInPlayerList()
        local players = {
            {unitName = "P1", groupId = 1, groupName = "BLUE1"},
            {unitName = "P2", groupId = 1, groupName = "BLUE1"},
            {unitName = "P3", groupId = 2, groupName = "BLUE2"},
        }
        local grp1 = self.sector:findGrpInPlayerList(1, players)
        lu.assertEquals(#grp1, 2)
        local grp2 = self.sector:findGrpInPlayerList(2, players)
        lu.assertEquals(#grp2, 1)
        local grp3 = self.sector:findGrpInPlayerList(3, players)
        lu.assertEquals(#grp3, 0)
    end

    function TestHoundSector:TestFindGrpInPlayerListNoList()
        self.sector.comms.enrolled = {
            P1 = {unitName = "P1", groupId = 1, groupName = "BLUE1"},
            P2 = {unitName = "P2", groupId = 1, groupName = "BLUE1"},
        }
        local grp1 = self.sector:findGrpInPlayerList(1)
        lu.assertEquals(#grp1, 2)
    end

    function TestHoundSector:TestGetSubscribedGroups()
        self.sector.comms.enrolled = {
            P1 = {unitName = "P1", groupId = 1},
            P2 = {unitName = "P2", groupId = 1},
            P3 = {unitName = "P3", groupId = 2},
        }
        local groups = self.sector:getSubscribedGroups()
        lu.assertEquals(#groups, 2)
        lu.assertIsTrue(HOUND.setContainsValue(groups, 1))
        lu.assertIsTrue(HOUND.setContainsValue(groups, 2))
    end

    function TestHoundSector:TestGetSubscribedGroupsEmpty()
        self.sector.comms.enrolled = {}
        local groups = self.sector:getSubscribedGroups()
        lu.assertIsTable(groups)
        lu.assertEquals(#groups, 0)
    end

    function TestHoundSector:TestRemoveRadioMenu()
        self.sector.comms.menu.root = "fake_menu_ref"
        self.sector.comms.enrolled = {P1 = {unitName = "P1"}}
        self.sector._hSettings = {getCoalition = function() return 2 end}
        self.sector:removeRadioMenu()
        lu.assertIsNil(self.sector.comms.menu.root)
        lu.assertEquals(HOUND.Length(self.sector.comms.enrolled), 0)
    end

    function TestHoundSector:TestGetTransmissionAnnounce()
        local msg = self.sector:getTransmissionAnnounce()
        lu.assertIsString(msg)
        lu.assertNotEquals(msg, "")
    end

    function TestHoundSector:TestGetTransmissionAnnounceByIndex()
        lu.assertStrContains(self.sector:getTransmissionAnnounce(1), "HOUND")
        lu.assertStrContains(self.sector:getTransmissionAnnounce(2), "HOUND")
        lu.assertStrContains(self.sector:getTransmissionAnnounce(3), "HOUND")
    end

    function TestHoundSector:TestTransmitOnControllerNoController()
        -- no controller → no crash, returns nil
        local result = self.sector:transmitOnController("test", 1)
        lu.assertIsNil(result)
    end

    function TestHoundSector:TestTransmitOnNotifierNoNotifier()
        local result = self.sector:transmitOnNotifier("test", 1)
        lu.assertIsNil(result)
    end

    function TestHoundSector:TestIsNotifiyingNoComms()
        lu.assertIsFalse(self.sector:isNotifiying())
    end

    function TestHoundSector:TestNotifyGuardsNoNotifier()
        -- all notify methods should be no-ops when no controller/notifier
        self.sector:notifyEmitterDead(nil)
        self.sector:notifyEmitterNew(nil)
        self.sector:notifySiteIdentified(nil)
        self.sector:notifySiteNew(nil)
        self.sector:notifySiteDead(nil, false)
        self.sector:notifySiteLaunching(nil)
    end

    function TestHoundSector:TestDestroy()
        self.sector.comms.menu.root = "fake_menu_ref"
        self.sector.comms.enrolled = {P1 = {unitName = "P1"}}
        self.sector._hSettings = {getCoalition = function() return 2 end}
        self.sector:destroy()
        lu.assertIsNil(self.sector.comms.menu.root)
        lu.assertEquals(HOUND.Length(self.sector.comms.enrolled), 0)
    end

    function TestHoundSector:TestUpdateServicesNoOps()
        self.sector._hSettings = mockSettings
        -- no controller/atis/notifier/zone/transmitter set
        -- updateServices should not crash
        self.sector:updateServices()
    end

    function TestHoundSector:TestUpdateSettings()
        self.sector:updateSettings({priority = 3})
        lu.assertEquals(self.sector.settings.priority, 3)
    end

    function TestHoundSector:TestUpdateSettingsCommsKeys()
        self.sector:updateSettings({
            controller = {freq = 251.0},
        })
        lu.assertIsTable(self.sector.settings.controller)
        lu.assertEquals(self.sector.settings.controller.freq, 251.0)
        lu.assertEquals(self.sector.settings.controller.name, self.sector.callsign)
    end

    function TestHoundSector:TestUpdateSettingsAtisNotifier()
        self.sector:updateSettings({
            atis = {freq = 123.45},
            notifier = {freq = 300.0},
        })
        lu.assertIsTable(self.sector.settings.atis)
        lu.assertEquals(self.sector.settings.atis.freq, 123.45)
        lu.assertIsTable(self.sector.settings.notifier)
        lu.assertEquals(self.sector.settings.notifier.freq, 300.0)
    end

    function TestHoundSector:TestValidateEnrolledEmpty()
        self.sector.comms.enrolled = {}
        self.sector:validateEnrolled()
        -- should not crash on empty
    end

    function TestHoundSector:TestIsNotifiyingWithControllerNoSettings()
        local commsController = {
            isEnabled = function() return false end,
            getSettings = function() return {} end,
        }
        self.sector.comms.controller = commsController
        lu.assertIsFalse(self.sector:isNotifiying())
    end

    function TestHoundSector:TestShouldNotifyForDifferentSector()
        self.sector.name = "saipan"
        local should, label = self.sector:shouldNotifyFor("default")
        lu.assertIsFalse(should)
        lu.assertIsNil(label)
    end

    function TestHoundSector:TestSetCallsignNil()
        self.sector._hSettings = mockSettings
        self.sector:setCallsign()
        local cs = self.sector:getCallsign()
        lu.assertIsString(cs)
        lu.assertNotEquals(cs, "HOUND")
    end
end
