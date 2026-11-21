do
    TestHoundWorker = {}

    function TestHoundWorker:setUp()
        collectgarbage("collect")
        self.worker = HOUND.ElintWorker.create()
        self.testId = self.worker:getId()
    end

    function TestHoundWorker:tearDown()
        HOUND.Config.configMaps[self.testId] = nil
        self.worker = nil
        collectgarbage("collect")
    end

    -- Constructor & Properties

    function TestHoundWorker:TestCreate()
        lu.assertIsTable(self.worker)
        lu.assertEquals(getmetatable(self.worker), HOUND.ElintWorker)
        lu.assertIsTable(self.worker.contacts)
        lu.assertIsTable(self.worker.platforms)
        lu.assertIsTable(self.worker.sites)
        lu.assertIsTable(self.worker.settings)
        lu.assertEquals(self.worker.TrackIdCounter, 0)
    end

    function TestHoundWorker:TestCreateWithId()
        local w = HOUND.ElintWorker.create(42)
        lu.assertEquals(w:getId(), 42)
        HOUND.Config.configMaps[42] = nil
    end

    function TestHoundWorker:TestGetNewTrackId()
        lu.assertEquals(self.worker:getNewTrackId(), 1)
        lu.assertEquals(self.worker:getNewTrackId(), 2)
        lu.assertEquals(self.worker:getNewTrackId(), 3)
        lu.assertEquals(self.worker.TrackIdCounter, 3)
    end

    function TestHoundWorker:TestGetId()
        lu.assertIsNumber(self.worker:getId())
        lu.assertTrue(self.worker:getId() > 0)
    end

    function TestHoundWorker:TestSetCoalition()
        local result = self.worker:setCoalition(coalition.side.BLUE)
        lu.assertTrue(result)
        lu.assertEquals(self.worker:getCoalition(), coalition.side.BLUE)
    end

    function TestHoundWorker:TestSetCoalitionTwice()
        self.worker:setCoalition(coalition.side.BLUE)
        local result = self.worker:setCoalition(coalition.side.RED)
        lu.assertIsFalse(result)
        lu.assertEquals(self.worker:getCoalition(), coalition.side.BLUE)
    end

    function TestHoundWorker:TestSetCoalitionInvalid()
        lu.assertIsFalse(self.worker:setCoalition(nil))
        lu.assertTrue(self.worker:setCoalition("bad"))
    end

    function TestHoundWorker:TestGetCoalitionDefault()
        lu.assertIsNil(self.worker:getCoalition())
    end

    function TestHoundWorker:TestCountPlatformsZero()
        lu.assertEquals(self.worker:countPlatforms(), 0)
    end

    function TestHoundWorker:TestCountPlatformsAfterInsert()
        self.worker.platforms = { {}, {} }
        lu.assertEquals(self.worker:countPlatforms(), 2)
    end

    function TestHoundWorker:TestListPlatforms()
        local p1 = { getName = function() return "PlatformA" end }
        local p2 = { getName = function() return "PlatformB" end }
        self.worker.platforms = { p1, p2 }
        local result = self.worker:listPlatforms()
        lu.assertItemsEquals(result, { "PlatformA", "PlatformB" })
    end

    -- DB platform data guards (HOUND.DB.getPlatformData / 103)

    function TestHoundWorker:TestGetPlatformDataDeadUnit()
        local mock = setmetatable({ isExist = function() return false end }, Unit)
        lu.assertIsNil(HOUND.DB.getPlatformData(mock))
    end

    function TestHoundWorker:TestGetPlatformDataDeadStatic()
        local mock = setmetatable({ isExist = function() return false end }, StaticObject)
        lu.assertIsNil(HOUND.DB.getPlatformData(mock))
    end

    function TestHoundWorker:TestGetPlatformDataInvalidType()
        lu.assertIsNil(HOUND.DB.getPlatformData(nil))
        lu.assertIsNil(HOUND.DB.getPlatformData("PlatformA"))
    end

    -- Contact query methods

    function TestHoundWorker:TestIsTrackedNil()
        lu.assertIsFalse(self.worker:isTracked(nil))
    end

    function TestHoundWorker:TestIsTrackedByString()
        self.worker.contacts["test_radar"] = true
        lu.assertTrue(self.worker:isTracked("test_radar"))
        lu.assertIsFalse(self.worker:isTracked("unknown"))
    end

    function TestHoundWorker:TestIsTrackedByTable()
        local mock = { getName = function() return "radar_unit" end }
        self.worker.contacts["radar_unit"] = true
        lu.assertTrue(self.worker:isTracked(mock))
    end

    function TestHoundWorker:TestIsContactNil()
        lu.assertIsFalse(self.worker:isContact(nil))
    end

    function TestHoundWorker:TestIsContactByString()
        self.worker.contacts["SA-2_radar"] = {}
        lu.assertTrue(self.worker:isContact("SA-2_radar"))
        lu.assertIsFalse(self.worker:isContact("unknown_radar"))
    end

    function TestHoundWorker:TestIsContactByTable()
        local mock = { getName = function() return "group_target" end }
        self.worker.contacts["group_target"] = {}
        lu.assertTrue(self.worker:isContact(mock))
    end

    function TestHoundWorker:TestGetContactNil()
        lu.assertIsNil(self.worker:getContact(nil))
    end

    function TestHoundWorker:TestGetContactByString()
        local contact = { uid = 1 }
        self.worker.contacts["known_emitter"] = contact
        lu.assertEquals(self.worker:getContact("known_emitter"), contact)
        lu.assertIsNil(self.worker:getContact("unknown"))
    end

    -- Site query methods

    function TestHoundWorker:TestIsSiteNil()
        lu.assertIsFalse(self.worker:isSite(nil))
    end

    function TestHoundWorker:TestIsSiteByString()
        self.worker.sites["SA-3_group"] = {}
        lu.assertTrue(self.worker:isSite("SA-3_group"))
        lu.assertIsFalse(self.worker:isSite("other_group"))
    end

    function TestHoundWorker:TestGetSiteNil()
        lu.assertIsNil(self.worker:getSite(nil))
    end

    -- Launch cooldown (onLaunchCooldown)

    --- register a mock site, inheriting the real HOUND.Contact.Site.onLaunchCooldown
    function TestHoundWorker:mockSiteSeen(grpName,secondsSinceSeen)
        local site = {getLastSeen = function() return secondsSinceSeen end}
        -- own metatable so the class lookup works without a prior Site:New
        setmetatable(site,{__index = HOUND.Contact.Site})
        self.worker.sites[grpName] = site
        return site
    end

    function TestHoundWorker:TestOnLaunchCooldownUnknownGroup()
        lu.assertIsFalse(self.worker:onLaunchCooldown("never_seen_group"))
    end

    function TestHoundWorker:TestOnLaunchCooldownFirstLaunchPasses()
        self:mockSiteSeen("cool_group",0)
        lu.assertIsFalse(self.worker:onLaunchCooldown("cool_group"))
    end

    function TestHoundWorker:TestOnLaunchCooldownBlocksRepeatLaunches()
        self:mockSiteSeen("cool_group",0)
        lu.assertIsFalse(self.worker:onLaunchCooldown("cool_group"))
        -- repeat launches inside the window are blocked, regardless of last_seen
        lu.assertIsTrue(self.worker:onLaunchCooldown("cool_group"))
        lu.assertIsTrue(self.worker:onLaunchCooldown("cool_group"))
    end

    function TestHoundWorker:TestOnLaunchCooldownIgnoresLastSeen()
        local cooldown = self.worker.settings:getAlertOnLaunchCooldown()
        -- a stale site still gets its first launch through - last_seen must not suppress it
        self:mockSiteSeen("stale_group",cooldown * 10)
        lu.assertIsFalse(self.worker:onLaunchCooldown("stale_group"))
        lu.assertIsTrue(self.worker:onLaunchCooldown("stale_group"))
        -- and a fresh site is blocked just the same
        self:mockSiteSeen("fresh_group",0)
        lu.assertIsFalse(self.worker:onLaunchCooldown("fresh_group"))
        lu.assertIsTrue(self.worker:onLaunchCooldown("fresh_group"))
    end

    -- Remove methods

    function TestHoundWorker:TestRemoveContactByString()
        local contact = { getDcsGroupName = function() return "grp" end, updateDeadDcsObject = function() end }
        self.worker.contacts["emitter_a"] = contact
        lu.assertTrue(self.worker:removeContact("emitter_a"))
        lu.assertIsNil(self.worker.contacts["emitter_a"])
    end

    function TestHoundWorker:TestRemoveContactByEmitterTable()
        local mockEmitter = { getDcsName = function() return "emitter_b" end }
        setmetatable(mockEmitter, HOUND.Contact.Emitter)
        self.worker.contacts["emitter_b"] = { getDcsGroupName = function() return "grp" end, updateDeadDcsObject = function() end }
        lu.assertTrue(self.worker:removeContact(mockEmitter))
        lu.assertIsNil(self.worker.contacts["emitter_b"])
    end

    function TestHoundWorker:TestRemoveContactInvalidType()
        lu.assertIsFalse(self.worker:removeContact(nil))
        lu.assertIsFalse(self.worker:removeContact(123))
        lu.assertIsFalse(self.worker:removeContact(true))
    end

    function TestHoundWorker:TestRemoveSiteByString()
        self.worker.sites["sam_site"] = {}
        lu.assertTrue(self.worker:removeSite("sam_site"))
        lu.assertIsNil(self.worker.sites["sam_site"])
    end

    function TestHoundWorker:TestRemoveSiteBySiteTable()
        local mockSite = { getDcsName = function() return "site_c" end }
        setmetatable(mockSite, HOUND.Contact.Site)
        self.worker.sites["site_c"] = {}
        lu.assertTrue(self.worker:removeSite(mockSite))
        lu.assertIsNil(self.worker.sites["site_c"])
    end

    function TestHoundWorker:TestRemoveSiteInvalidType()
        lu.assertIsFalse(self.worker:removeSite(nil))
        lu.assertIsFalse(self.worker:removeSite(456))
    end

    -- Query functions (501 - HoundElintWorker_queries)

    function TestHoundWorker:TestCountContacts()
        self.worker.contacts = { a = {}, b = {}, c = {} }
        lu.assertEquals(self.worker:countContacts(), 3)
        self.worker.contacts = {}
        lu.assertEquals(self.worker:countContacts(), 0)
    end

    function TestHoundWorker:TestCountContactsWithSector()
        local c1 = { isInSector = function(_, s) return s == "north" end }
        local c2 = { isInSector = function(_, s) return s == "south" end }
        local c3 = { isInSector = function(_, s) return s == "north" end }
        self.worker.contacts = { c1 = c1, c2 = c2, c3 = c3 }
        lu.assertEquals(self.worker:countContacts("north"), 2)
        lu.assertEquals(self.worker:countContacts("south"), 1)
        lu.assertEquals(self.worker:countContacts("east"), 0)
    end

    function TestHoundWorker:TestCountSites()
        self.worker.sites = { s1 = {}, s2 = {} }
        lu.assertEquals(self.worker:countSites(), 2)
        self.worker.sites = {}
        lu.assertEquals(self.worker:countSites(), 0)
    end

    function TestHoundWorker:TestCountSitesWithSector()
        local s1 = { isInSector = function(_, s) return s == "zone_a" end }
        local s2 = { isInSector = function(_, s) return s == "zone_b" end }
        local s3 = { isInSector = function(_, s) return s == "zone_a" end }
        self.worker.sites = { s1, s2, s3 }
        lu.assertEquals(self.worker:countSites("zone_a"), 2)
        lu.assertEquals(self.worker:countSites("zone_b"), 1)
    end

    function TestHoundWorker:TestGetContacts()
        local c1 = { uid = 1 }
        local c2 = { uid = 2 }
        self.worker.contacts = { a = c1, b = c2 }
        local result = self.worker:getContacts()
        lu.assertEquals(#result, 2)
    end

    function TestHoundWorker:TestGetContactsWithSector()
        local c1 = { uid = 1, isInSector = function(_, s) return s == "alpha" end }
        local c2 = { uid = 2, isInSector = function(_, s) return false end }
        self.worker.contacts = { a = c1, b = c2 }
        local result = self.worker:getContacts("alpha")
        lu.assertEquals(#result, 1)
        lu.assertEquals(result[1].uid, 1)
    end

    function TestHoundWorker:TestGetContactsEmpty()
        self.worker.contacts = {}
        local result = self.worker:getContacts()
        lu.assertItemsEquals(result, {})
    end

    function TestHoundWorker:TestGetSites()
        local s1 = { name = "Site1" }
        local s2 = { name = "Site2" }
        self.worker.sites = { a = s1, b = s2 }
        local result = self.worker:getSites()
        lu.assertEquals(#result, 2)
    end

    function TestHoundWorker:TestGetSitesWithSector()
        local s1 = { name = "Site1", isInSector = function(_, s) return s == "delta" end }
        local s2 = { name = "Site2", isInSector = function(_, s) return false end }
        self.worker.sites = { a = s1, b = s2 }
        local result = self.worker:getSites("delta")
        lu.assertEquals(#result, 1)
        lu.assertEquals(result[1].name, "Site1")
    end

    function TestHoundWorker:TestSortContacts()
        local c1 = { uid = 2, name = "Beta" }
        local c2 = { uid = 1, name = "Alpha" }
        self.worker.contacts = { a = c1, b = c2 }
        local byId = function(a, b) return a.uid < b.uid end
        local sorted = self.worker:sortContacts(byId)
        lu.assertEquals(#sorted, 2)
        lu.assertEquals(sorted[1].uid, 1)
        lu.assertEquals(sorted[2].uid, 2)
    end

    function TestHoundWorker:TestSortContactsInvalidFunc()
        local sorted = self.worker:sortContacts(nil)
        lu.assertIsNil(sorted)
    end

    function TestHoundWorker:TestSortSites()
        local s1 = { priority = 10 }
        local s2 = { priority = 5 }
        local s3 = { priority = 20 }
        self.worker.sites = { a = s1, b = s2, c = s3 }
        local byPrio = function(a, b) return a.priority < b.priority end
        local sorted = self.worker:sortSites(byPrio)
        lu.assertEquals(#sorted, 3)
        lu.assertEquals(sorted[1].priority, 5)
        lu.assertEquals(sorted[2].priority, 10)
        lu.assertEquals(sorted[3].priority, 20)
    end

    function TestHoundWorker:TestSortSitesInvalidFunc()
        lu.assertIsNil(self.worker:sortSites(nil))
    end

    function TestHoundWorker:TestListAllContacts()
        local c1 = { uid = 1 }
        local c2 = { uid = 2 }
        self.worker.contacts = { a = c1, b = c2 }
        local result = self.worker:listAllContacts()
        lu.assertEquals(result, self.worker.contacts)
    end

    function TestHoundWorker:TestListAllContactsWithSector()
        local c1 = { uid = 1, isInSector = function(_, s) return s == "sector_x" end }
        local c2 = { uid = 2, isInSector = function(_, s) return false end }
        self.worker.contacts = { a = c1, b = c2 }
        local result = self.worker:listAllContacts("sector_x")
        lu.assertEquals(#result, 1)
        lu.assertEquals(result[1].uid, 1)
    end

    function TestHoundWorker:TestListAllSites()
        local s1 = { name = "S1" }
        local s2 = { name = "S2" }
        self.worker.sites = { a = s1, b = s2 }
        local result = self.worker:listAllSites()
        lu.assertEquals(result, self.worker.sites)
    end

    function TestHoundWorker:TestListAllSitesWithSector()
        local s1 = { name = "S1", isInSector = function(_, s) return s == "zone1" end }
        local s2 = { name = "S2", isInSector = function(_, s) return false end }
        self.worker.sites = { a = s1, b = s2 }
        local result = self.worker:listAllSites("zone1")
        lu.assertEquals(#result, 1)
        lu.assertEquals(result[1].name, "S1")
    end

    function TestHoundWorker:TestListContactsInSector()
        -- contacts live in a name-keyed dictionary, not an array
        local c1 = { uid = 2, isInSector = function(_, s) return s == "target" end }
        local c2 = { uid = 1, isInSector = function(_, s) return false end }
        self.worker.contacts = { alpha = c1, bravo = c2 }
        local result = self.worker:listContactsInSector("target")
        lu.assertEquals(#result, 1)
        lu.assertEquals(result[1], c1)
    end

    function TestHoundWorker:TestListContactsInSectorNilSector()
        local c1 = { uid = 3 }
        local c2 = { uid = 1 }
        local c3 = { uid = 2 }
        self.worker.contacts = { charlie = c1, alpha = c2, bravo = c3 }
        local result = self.worker:listContactsInSector()
        lu.assertEquals(#result, 3)
        lu.assertEquals(result[1].uid, 1)
        lu.assertEquals(result[2].uid, 2)
        lu.assertEquals(result[3].uid, 3)
    end

    function TestHoundWorker:TestListContactsInSectorEmpty()
        self.worker.contacts = {}
        local result = self.worker:listContactsInSector("nonexistent")
        lu.assertItemsEquals(result, {})
    end

    function TestHoundWorker:TestListAllContactsByRange()
        local c1 = { uid = 1, isInSector = function() return true end }
        local c2 = { uid = 2, isInSector = function() return true end }
        self.worker.contacts = { a = c1, b = c2 }
        local result = self.worker:listAllContactsByRange()
        lu.assertIsTable(result)
        lu.assertTrue(#result >= 2)
    end

    function TestHoundWorker:TestListAllSitesByRange()
        local s1 = { name = "A", isInSector = function() return true end }
        local s2 = { name = "B", isInSector = function() return true end }
        self.worker.sites = { a = s1, b = s2 }
        local result = self.worker:listAllSitesByRange()
        lu.assertIsTable(result)
        lu.assertTrue(#result >= 2)
    end

    -- addContact / addSite must survive a constructor that bails out and returns nil
    function TestHoundWorker:TestAddContactWithNilConstructor()
        local tor = Unit.getByName("TOR_SAIPAN-1")
        lu.assertNotNil(tor)
        local origNew = HOUND.Contact.Emitter.New
        HOUND.Contact.Emitter.New = function() return nil end
        local ok, err = pcall(function() self.worker:addContact(tor) end)
        HOUND.Contact.Emitter.New = origNew
        lu.assertIsTrue(ok, tostring(err))
        lu.assertEquals(HOUND.Length(self.worker.contacts), 0)
    end

    function TestHoundWorker:TestAddSiteWithNilConstructor()
        local contact = HOUND.Contact.Emitter:New(Unit.getByName("TOR_SAIPAN-1"), coalition.side.BLUE, 1)
        lu.assertNotNil(contact)
        local origNew = HOUND.Contact.Site.New
        HOUND.Contact.Site.New = function() return nil end
        local ok, err = pcall(function() self.worker:addSite(contact) end)
        HOUND.Contact.Site.New = origNew
        lu.assertIsTrue(ok, tostring(err))
        lu.assertEquals(HOUND.Length(self.worker.sites), 0)
    end

    function TestHoundWorker:TestAddSiteWithoutGroupName()
        local contact = HOUND.Contact.Emitter:New(Unit.getByName("TOR_SAIPAN-1"), coalition.side.BLUE, 1)
        lu.assertNotNil(contact)
        contact.DcsGroupName = nil
        local ok, err = pcall(function() self.worker:addSite(contact) end)
        lu.assertIsTrue(ok, tostring(err))
        lu.assertEquals(HOUND.Length(self.worker.sites), 0)
    end

end
