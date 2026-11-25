
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

    -- run body, then always restore state its assertions may skip
    local function restoreAfter(restore, body)
        local ok, err = pcall(body)
        restore()
        if not ok then error(err, 0) end
    end

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
        lu.assertIsNil(s.zoneCenter)
        lu.assertIsNil(s._zonePoly)
        lu.assertIsNil(s._zoneHexCache)
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

    function TestHoundSector:TestSetCallsignReleasesPrevious()
        self.sector._hSettings = mockSettings
        self.sector:setCallsign("HOUND")
        lu.assertIsTrue(HOUND.setContainsValue(mockSettings.callsigns, "HOUND"))
        self.sector:setCallsign("ALPHA")
        lu.assertIsFalse(HOUND.setContainsValue(mockSettings.callsigns, "HOUND"))
        lu.assertIsTrue(HOUND.setContainsValue(mockSettings.callsigns, "ALPHA"))
    end

    function TestHoundSector:TestSetCallsignKeepsForeignRegistration()
        -- the initial "HOUND" placeholder is unregistered and must not release
        -- another sector's callsign from the shared pool
        self.sector._hSettings = mockSettings
        table.insert(mockSettings.callsigns, "HOUND")
        self.sector:setCallsign("ALPHA")
        lu.assertIsTrue(HOUND.setContainsValue(mockSettings.callsigns, "HOUND"))
        lu.assertIsTrue(HOUND.setContainsValue(mockSettings.callsigns, "ALPHA"))
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

    -- hex grid sector zone (src/550, src/202)

    local function zoneSquare(cx, cz, half)
        cx = cx or 0
        cz = cz or 0
        half = half or 5000
        return {
            {x = cx - half, z = cz - half, y = 0},
            {x = cx + half, z = cz - half, y = 0},
            {x = cx + half, z = cz + half, y = 0},
            {x = cx - half, z = cz + half, y = 0},
        }
    end

    local function withZoneDistanceCounter(fn)
        local original = HOUND.Utils.Polygon.zoneDistance
        local counter = { calls = 0 }
        HOUND.Utils.Polygon.zoneDistance = function(...)
            counter.calls = counter.calls + 1
            return original(...)
        end
        local ok, err = pcall(fn, counter)
        HOUND.Utils.Polygon.zoneDistance = original
        lu.assertIsTrue(ok, tostring(err))
        return counter.calls
    end

    local function mockContact(state)
        local contact = { updates = 0 }
        contact.getPos = function() return state.pos end
        contact.getHexCell = function()
            if state.cell then return state.cell end
            if not HOUND.Utils.Dcs.isPoint(state.pos) then return nil end
            return HOUND.Mist.hex.pointToHex(state.pos)
        end
        contact.getMaxWeaponsRange = function() return state.range end
        contact.updateSector = function(_, name, inSector, threatsSector)
            contact.updates = contact.updates + 1
            contact.lastName = name
            contact.lastIn = inSector
            contact.lastThreat = threatsSector
        end
        return contact
    end

    function TestHoundSector:TestSetZoneBuildsPolygon()
        self.sector.name = "saipan"
        local zone = zoneSquare()
        self.sector:setZone(zone)
        lu.assertEquals(self.sector:getZone(), zone)
        lu.assertIsTable(self.sector._zonePoly)
        lu.assertEquals(self.sector._zonePoly.n, 4)
        lu.assertIsTable(self.sector._zoneHexCache)
        lu.assertIsNil(next(self.sector._zoneHexCache))
        lu.assertNotNil(self.sector.zoneCenter)
    end

    function TestHoundSector:TestUpdateSettingsZoneRebuilds()
        self.sector.name = "saipan"
        local zone = zoneSquare()
        self.sector:updateSettings({zone = zone})
        lu.assertEquals(self.sector:getZone(), zone)
        lu.assertIsTable(self.sector._zonePoly)
        lu.assertIsTable(self.sector._zoneHexCache)
    end

    function TestHoundSector:TestUpdateSettingsInvalidZoneKeepsCurrent()
        self.sector.name = "saipan"
        local zone = zoneSquare()
        self.sector:setZone(zone)
        local poly = self.sector._zonePoly
        local cache = self.sector._zoneHexCache
        self.sector:updateSettings({zone = {{x = 0, z = 0}}})
        lu.assertIs(self.sector:getZone(), zone)
        lu.assertIs(self.sector._zonePoly, poly)
        lu.assertIs(self.sector._zoneHexCache, cache)
    end

    function TestHoundSector:TestSetZoneReplacementDiffers()
        self.sector.name = "saipan"
        self.sector:setZone(zoneSquare(0, 0))
        local firstPoly = self.sector._zonePoly
        local firstCache = self.sector._zoneHexCache
        self.sector:setZone(zoneSquare(20000, 20000))
        lu.assertNotEquals(firstPoly, self.sector._zonePoly)
        -- identity: luaunit deep-compares tables, and both caches start empty
        lu.assertIsTrue(firstCache ~= self.sector._zoneHexCache)
        lu.assertNotEquals(firstPoly.xs[1], self.sector._zonePoly.xs[1])
    end

    function TestHoundSector:TestMembershipFollowsRadiusChange()
        local hex = HOUND.Mist.hex
        local savedRadius = hex.getRadius()
        local savedUseHexGrid = HOUND.useHexGrid
        local realGetTime = timer.getTime
        restoreAfter(function()
            hex.setRadius(savedRadius)
            HOUND.useHexGrid = savedUseHexGrid
            timer.getTime = realGetTime
        end, function()
            local t = 0
            timer.getTime = function() t = t + 0.1; return t end
            HOUND.useHexGrid = true
            hex.setRadius(1000)
            local pos = {x = 12000, z = 8000, y = 0}
            local oldHex = hex.pointToHex(pos)
            local newHex = hex.pointToHex(pos, 2000)
            local contact = setmetatable({ pos = { p = pos } }, HOUND.Contact.Base)
            local cells = {}
            -- priority 20 sorts before 10 with sectorsByPriorityLowFirst
            local sectorA = {
                getPriority = function() return 20 end,
                updateSectorMembership = function(_, c)
                    cells[1] = c:getHexCell()
                    -- simulates an async HOUND.setHexRadius between sectors
                    hex.setRadius(2000)
                end,
            }
            local sectorB = {
                getPriority = function() return 10 end,
                updateSectorMembership = function(_, c) cells[2] = c:getHexCell() end,
            }
            local hound = setmetatable({
                getId = function() return 987001 end,
                getSectors = function() return {sectorA, sectorB} end,
                contacts = {
                    listAllContacts = function() return {contact} end,
                    listAllSites = function() return {} end,
                },
            }, HoundElint)

            hound:updateSectorMembership()
            local guard = 0
            while HOUND.Coroutine.isRunning("sector-membership-987001") do
                HOUND.Coroutine._pump()
                guard = guard + 1
                if guard > 100 then error("sector membership did not finish") end
            end

            lu.assertNotNil(cells[1])
            lu.assertNotNil(cells[2])
            lu.assertEquals(cells[1].r, oldHex.r)
            lu.assertEquals(cells[1].q, oldHex.q)
            lu.assertEquals(cells[2].r, newHex.r)
            lu.assertEquals(cells[2].q, newHex.q)
        end)
    end

    function TestHoundSector:TestMembershipYieldsPerSector()
        local savedUseHexGrid = HOUND.useHexGrid
        local realGetTime = timer.getTime
        restoreAfter(function()
            HOUND.useHexGrid = savedUseHexGrid
            timer.getTime = realGetTime
        end, function()
            local t = 0
            timer.getTime = function() t = t + 0.1; return t end
            HOUND.useHexGrid = true
            local contact = setmetatable({ pos = { p = {x = 0, y = 0, z = 0} } }, HOUND.Contact.Base)
            local sectors = {}
            for i = 1, 3 do
                sectors[i] = {
                    getPriority = function() return i end,
                    updateSectorMembership = function() end,
                }
            end
            local hound = setmetatable({
                getId = function() return 987002 end,
                getSectors = function() return sectors end,
                contacts = {
                    listAllContacts = function() return {contact} end,
                    listAllSites = function() return {} end,
                },
            }, HoundElint)

            hound:updateSectorMembership()
            local pumps = 0
            while HOUND.Coroutine.isRunning("sector-membership-987002") do
                HOUND.Coroutine._pump()
                pumps = pumps + 1
                if pumps > 100 then error("sector membership did not finish") end
            end
            lu.assertIsTrue(pumps > 1)
        end)
    end

    function TestHoundSector:TestRemoveZonePurgesZone()
        self.sector.name = "saipan"
        self.sector:setZone(zoneSquare())
        lu.assertNotNil(self.sector._zonePoly)
        self.sector:removeZone()
        lu.assertIsNil(self.sector:getZone())
        lu.assertIsNil(self.sector.zoneCenter)
        lu.assertIsNil(self.sector._zonePoly)
        lu.assertIsNil(self.sector._zoneHexCache)
    end

    function TestHoundSector:TestSetZoneTooFewPoints()
        self.sector.name = "saipan"
        self.sector:setZone({{x = 0, z = 0}, {x = 1000, z = 0}})
        lu.assertIsNil(self.sector:getZone())
        lu.assertIsNil(self.sector._zonePoly)
        lu.assertIsNil(self.sector._zoneHexCache)
    end

    function TestHoundSector:TestSetZoneAcceptsDrawnZone2D()
        -- drawn zones supply Vec2 {x,y}; group routes supply Vec3 {x,y,z}
        self.sector.name = "saipan"
        local zone = {
            {x = -5000, y = -5000},
            {x = 5000, y = -5000},
            {x = 5000, y = 5000},
            {x = -5000, y = 5000},
        }
        self.sector:setZone(zone)
        lu.assertEquals(self.sector:getZone(), zone)
        lu.assertEquals(self.sector._zonePoly.n, 4)
        local hex = HOUND.Mist.hex
        local pos = {x = 0, y = 0, z = 0}
        local inSector, threats = HOUND.Utils.Polygon.threatOnSector(
            zone, pos, 0, hex.pointToHex(pos), self.sector._zoneHexCache, self.sector._zonePoly)
        lu.assertIsTrue(inSector)
        lu.assertIsTrue(threats)
    end

    function TestHoundSector:TestSetZoneInvalidKeepsExisting()
        self.sector.name = "saipan"
        local zone = zoneSquare()
        self.sector:setZone(zone)
        local poly = self.sector._zonePoly
        local cache = self.sector._zoneHexCache
        local center = self.sector.zoneCenter

        self.sector:setZone({{x = 0, z = 0}, {x = 1000, z = 0}})
        lu.assertEquals(self.sector:getZone(), zone)
        lu.assertIs(self.sector._zonePoly, poly)
        lu.assertIs(self.sector._zoneHexCache, cache)
        lu.assertIs(self.sector.zoneCenter, center)

        self.sector:setZone({{x = 0, z = 0}, {x = 1000, z = 0}, {x = "bad", z = 0}})
        lu.assertEquals(self.sector:getZone(), zone)
        lu.assertIs(self.sector._zonePoly, poly)
        lu.assertIs(self.sector._zoneHexCache, cache)
        lu.assertIs(self.sector.zoneCenter, center)
    end

    function TestHoundSector:TestUpdateSectorMembershipHex()
        self.sector.name = "saipan"
        self.sector:setZone(zoneSquare())
        self.sector._contacts = mockContacts
        local captured = {}
        local contact = {
            getPos = function() return {x = 0, y = 0, z = 0} end,
            getHexCell = function() return HOUND.Mist.hex.pointToHex({x = 0, y = 0, z = 0}) end,
            getMaxWeaponsRange = function() return 0 end,
            updateSector = function(_, name, inSector, threatsSector)
                captured.name = name
                captured.inSector = inSector
                captured.threatsSector = threatsSector
            end,
        }
        self.sector:updateSectorMembership(contact)
        lu.assertEquals(captured.name, "saipan")
        lu.assertIsTrue(captured.inSector)
        lu.assertIsTrue(captured.threatsSector)
    end

    function TestHoundSector:TestUpdateSectorMembershipLazyClassify()
        self.sector.name = "saipan"
        self.sector:setZone(zoneSquare())
        self.sector._contacts = mockContacts
        local state = { pos = { x = 0, y = 0, z = 0 }, range = 0 }
        local contact = mockContact(state)
        local calls = withZoneDistanceCounter(function()
            self.sector:updateSectorMembership(contact)
            lu.assertEquals(contact.updates, 1)
            lu.assertIsTrue(contact.lastIn)
            lu.assertIsTrue(contact.lastThreat)
            self.sector:updateSectorMembership(contact)
        end)
        lu.assertEquals(calls, 1)
        lu.assertEquals(contact.updates, 2)
    end

    function TestHoundSector:TestUpdateSectorMembershipThreatOnlyOutside()
        self.sector.name = "saipan"
        self.sector:setZone(zoneSquare())
        self.sector._contacts = mockContacts
        local state = { pos = { x = 12000, y = 0, z = 0 }, range = 10000 }
        local contact = mockContact(state)
        self.sector:updateSectorMembership(contact)
        lu.assertIsFalse(contact.lastIn)
        lu.assertIsTrue(contact.lastThreat)

        -- range is not part of the cached classification
        state.range = 0
        self.sector:updateSectorMembership(contact)
        lu.assertIsFalse(contact.lastIn)
        lu.assertIsFalse(contact.lastThreat)
    end

    function TestHoundSector:TestUpdateSectorMembershipZoneCacheHex()
        self.sector.name = "saipan"
        self.sector:setZone(zoneSquare())
        self.sector._contacts = mockContacts
        local hex = HOUND.Mist.hex
        local state = { pos = { x = 0, y = 0, z = 0 }, range = 50000 }
        local contact = mockContact(state)
        local h = hex.pointToHex(state.pos)
        local calls = withZoneDistanceCounter(function()
            self.sector:updateSectorMembership(contact)
            self.sector:updateSectorMembership(contact)
            state.cell = hex.neighbor(h, 1)
            self.sector:updateSectorMembership(contact)
            state.range = 60000
            self.sector:updateSectorMembership(contact)
        end)
        lu.assertEquals(calls, 2)
        lu.assertEquals(contact.updates, 4)
    end

    function TestHoundSector:TestUpdateSectorMembershipZoneCacheInvalidation()
        self.sector.name = "saipan"
        self.sector:setZone(zoneSquare())
        self.sector._contacts = mockContacts
        local state = { pos = { x = 0, y = 0, z = 0 }, range = 50000 }
        local contact = mockContact(state)
        local calls = withZoneDistanceCounter(function()
            self.sector:updateSectorMembership(contact)
            self.sector:setZone(zoneSquare(20000, 20000))
            self.sector:updateSectorMembership(contact)
        end)
        lu.assertEquals(calls, 2)
    end

    function TestHoundSector:TestUpdateSectorMembershipLegacyBypass()
        self.sector.name = "saipan"
        self.sector:setZone(zoneSquare())
        self.sector._contacts = mockContacts
        local state = { pos = { x = 0, y = 0, z = 0 }, range = 50000 }
        local contact = mockContact(state)
        local saved = HOUND.useHexGrid
        HOUND.useHexGrid = false
        local ok, err = pcall(function()
            local calls = withZoneDistanceCounter(function()
                self.sector:updateSectorMembership(contact)
                self.sector:updateSectorMembership(contact)
            end)
            lu.assertEquals(calls, 0)
            lu.assertIsNil(next(self.sector._zoneHexCache))
        end)
        HOUND.useHexGrid = saved
        lu.assertIsTrue(ok, tostring(err))
    end

    function TestHoundSector:TestIsThreatening()
        local member = setmetatable({threatSectors = {saipan = true}, primarySector = "saipan"}, HOUND.Contact.Base)
        lu.assertIsFalse(member:isThreatening("saipan"))

        local outsider = setmetatable({threatSectors = {saipan = true}, primarySector = "tinian"}, HOUND.Contact.Base)
        lu.assertIsTrue(outsider:isThreatening("saipan"))

        local nonThreat = setmetatable({threatSectors = {}, primarySector = "tinian"}, HOUND.Contact.Base)
        lu.assertIsFalse(nonThreat:isThreatening("saipan"))
    end

    function TestHoundSector:TestSetHexRadiusResetsZoneCache()
        self.sector.name = "saipan"
        self.sector:setZone(zoneSquare())
        local hex = HOUND.Mist.hex
        local pos = { x = 0, y = 0, z = 0 }
        HOUND.Utils.Polygon.threatOnSector(self.sector:getZone(), pos, 0,
            hex.pointToHex(pos), self.sector._zoneHexCache, self.sector._zonePoly)
        lu.assertNotNil(next(self.sector._zoneHexCache))

        local savedInstances = HOUND.INSTANCES
        local savedRadius = HOUND.Mist.hex.getRadius()
        local savedHexRadius = HOUND.hexRadius
        HOUND.INSTANCES = {
            [1] = {
                getSectors = function() return {self.sector} end,
                updateSectorMembership = function() end,
            },
        }
        restoreAfter(function()
            HOUND.INSTANCES = savedInstances
            HOUND.Mist.hex.setRadius(savedRadius)
            HOUND.hexRadius = savedHexRadius
        end, function()
            HOUND.setHexRadius(500)
            lu.assertEquals(HOUND.Mist.hex.getRadius(), 500)
            lu.assertIsTable(self.sector._zonePoly)
            lu.assertIsNil(next(self.sector._zoneHexCache))

            HOUND.setHexRadius(1000)
            lu.assertEquals(HOUND.Mist.hex.getRadius(), 1000)
            lu.assertIsTable(self.sector._zonePoly)
        end)
    end

    function TestHoundSector:TestSetHexRadiusInvalid()
        local savedInstances = HOUND.INSTANCES
        local savedRadius = HOUND.Mist.hex.getRadius()
        local savedHexRadius = HOUND.hexRadius
        HOUND.INSTANCES = {}
        restoreAfter(function()
            HOUND.INSTANCES = savedInstances
            HOUND.Mist.hex.setRadius(savedRadius)
            HOUND.hexRadius = savedHexRadius
        end, function()
            HOUND.setHexRadius(1000)
            HOUND.setHexRadius(nil)
            HOUND.setHexRadius("bad")
            HOUND.setHexRadius(0)
            lu.assertEquals(HOUND.Mist.hex.getRadius(), 1000)
        end)
    end
end
