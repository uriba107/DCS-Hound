do
    TestHoundContactSite = {}

    function TestHoundContactSite:setUp()
        self.torUnit = Unit.getByName("TOR_SAIPAN-1")
        lu.assertNotNil(self.torUnit)
        self.torContact = HOUND.Contact.Emitter:New(self.torUnit,coalition.side.BLUE)
        lu.assertNotNil(self.torContact)
    end

    function TestHoundContactSite:tearDown()
        self.torContact = nil
        self.site = nil
    end

    function TestHoundContactSite:TestConstructorInvalid()
        lu.assertIsNil(HOUND.Contact.Site:New())
        lu.assertIsNil(HOUND.Contact.Site:New(nil,coalition.side.BLUE))
        lu.assertIsNil(HOUND.Contact.Site:New("string",coalition.side.BLUE))
        lu.assertIsNil(HOUND.Contact.Site:New({},coalition.side.BLUE))
        lu.assertIsNil(HOUND.Contact.Site:New(self.torContact,nil))
    end

    function TestHoundContactSite:TestConstructorValid()
        self.site = HOUND.Contact.Site:New(self.torContact,coalition.side.BLUE)
        lu.assertNotNil(self.site)
        lu.assertIsTrue(getmetatable(self.site)==HOUND.Contact.Site)
        lu.assertEquals(self.site.state,HOUND.EVENTS.SITE_NEW)
    end

    function TestHoundContactSite:TestConstructorWithId()
        self.site = HOUND.Contact.Site:New(self.torContact,coalition.side.BLUE,5555)
        lu.assertEquals(self.site:getId(),5555%1000)
    end

    function TestHoundContactSite:TestName()
        self.site = HOUND.Contact.Site:New(self.torContact,coalition.side.BLUE)
        lu.assertIsString(self.site:getName())
        lu.assertStrContains(self.site:getName(),"T")
        lu.assertStrContains(self.site:getName(),self.site:getId())
        self.site:setName("TestSite")
        lu.assertEquals(self.site:getName(),"TestSite")
        self.site:setName(nil)
        lu.assertIsNil(self.site.name)
    end

    function TestHoundContactSite:TestEWRName()
        local ewrUnit = Unit.getByName("EWR_SAIPAN")
        local ewrContact = HOUND.Contact.Emitter:New(ewrUnit,coalition.side.BLUE)
        self.site = HOUND.Contact.Site:New(ewrContact,coalition.side.BLUE)
        lu.assertStrContains(self.site:getName(),"S")
    end

    function TestHoundContactSite:TestTypeAndId()
        self.site = HOUND.Contact.Site:New(self.torContact,coalition.side.BLUE)
        lu.assertEquals(self.site:getType(),self.site:getTypeAssigned())
        lu.assertIsString(self.site:getType())
        lu.assertIsNumber(self.site:getId())
    end

    function TestHoundContactSite:TestDcsAccessors()
        self.site = HOUND.Contact.Site:New(self.torContact,coalition.side.BLUE)
        local torGroup = Group.getByName("TOR_SAIPAN")
        lu.assertEquals(self.site:getDcsObject(),torGroup)
        lu.assertEquals(self.site:getDcsGroupName(),"TOR_SAIPAN")
        lu.assertEquals(self.site:getDcsName(),"TOR_SAIPAN")
    end

    function TestHoundContactSite:TestInitialState()
        self.site = HOUND.Contact.Site:New(self.torContact,coalition.side.BLUE)
        lu.assertEquals(self.site:getState(),HOUND.EVENTS.SITE_NEW)
        lu.assertIsFalse(self.site:isAccurate())
        lu.assertIsTrue(self.site:isAlive())
        lu.assertTrue(self.site:isTimedout())
        lu.assertIsFalse(self.site:isActive())
        lu.assertIsFalse(self.site:isRecent())
    end

    function TestHoundContactSite:TestEmitterMgmt()
        self.site = HOUND.Contact.Site:New(self.torContact,coalition.side.BLUE)
        lu.assertEquals(self.site:countEmitters(),1)
        lu.assertEquals(self.site:getPrimary(),self.torContact)
        local emitters = self.site:getEmitters()
        lu.assertIsTable(emitters)
        lu.assertEquals(#emitters,1)
        lu.assertEquals(emitters[1],self.torContact)
    end

    function TestHoundContactSite:TestAddSameGroupEmitter()
        local secondTor = HOUND.Contact.Emitter:New(self.torUnit,coalition.side.BLUE)
        self.site = HOUND.Contact.Site:New(self.torContact,coalition.side.BLUE)
        local state = self.site:addEmitter(secondTor)
        lu.assertEquals(state,17)
        lu.assertIsNumber(self.site:countEmitters())
    end

    function TestHoundContactSite:TestRemoveEmitter()
        self.site = HOUND.Contact.Site:New(self.torContact,coalition.side.BLUE)
        self.site:removeEmitter(self.torContact)
        lu.assertEquals(self.site:countEmitters(),0)
    end

    function TestHoundContactSite:TestRemoveNonMemberEmitter()
        local ewrUnit = Unit.getByName("EWR_SAIPAN")
        local ewrContact = HOUND.Contact.Emitter:New(ewrUnit,coalition.side.BLUE)
        self.site = HOUND.Contact.Site:New(self.torContact,coalition.side.BLUE)
        self.site:removeEmitter(ewrContact)
        lu.assertEquals(self.site:countEmitters(),1)
    end

    function TestHoundContactSite:TestHasRadarUnits()
        self.site = HOUND.Contact.Site:New(self.torContact,coalition.side.BLUE)
        lu.assertIsTrue(self.site:hasRadarUnits())
    end

    function TestHoundContactSite:TestUpdateTypeAssigned()
        self.site = HOUND.Contact.Site:New(self.torContact,coalition.side.BLUE)
        local initialType = self.site:getTypeAssigned()
        self.site:updateTypeAssigned()
        lu.assertIsString(self.site:getTypeAssigned())
    end

    function TestHoundContactSite:TestUpdatePos()
        self.site = HOUND.Contact.Site:New(self.torContact,coalition.side.BLUE)
        self.torContact:useUnitPos(HOUND.MARKER.POINT)
        self.site:updatePos()
        lu.assertIsTrue(self.site:hasPos())
        local pos = self.site:getPos()
        lu.assertIsNumber(pos.x)
        lu.assertIsNumber(pos.z)
    end

    function TestHoundContactSite:TestEnsurePrimaryHasPos()
        self.site = HOUND.Contact.Site:New(self.torContact,coalition.side.BLUE)
        self.site:ensurePrimaryHasPos()
        lu.assertIsFalse(self.site:hasPos())
        self.torContact:useUnitPos(HOUND.MARKER.POINT)
        self.site:ensurePrimaryHasPos()
        lu.assertIsTrue(self.site:hasPos())
        lu.assertIsTable(self.site.pos.grid)
        lu.assertIsTable(self.site.pos.be)
        lu.assertIsTable(self.site.uncertenty_data)
        lu.assertIsString(self.site.pos.grid.MGRSDigraph)
        lu.assertIsNumber(self.site.pos.be.brg)
        lu.assertIsNumber(self.site.uncertenty_data.major)
    end

    function TestHoundContactSite:TestEnsurePrimaryHasPosRefPos()
        self.site = HOUND.Contact.Site:New(self.torContact,coalition.side.BLUE)
        self.site:ensurePrimaryHasPos({x=500000,z=1900000,y=0})
        lu.assertIsTrue(self.site:hasPos())
        local pos = self.site:getPos()
        lu.assertEquals(pos.x,500000)
        lu.assertEquals(pos.z,1900000)
        lu.assertIsTable(self.site.uncertenty_data)
        lu.assertIsNumber(self.site.uncertenty_data.major)
        lu.assertIsNumber(self.site.uncertenty_data.minor)
        lu.assertIsNumber(self.site.uncertenty_data.theta)
    end

    function TestHoundContactSite:TestUpdate()
        self.site = HOUND.Contact.Site:New(self.torContact,coalition.side.BLUE)
        self.site:update()
        lu.assertIsNumber(self.site.last_seen)
        lu.assertIsNumber(self.site.maxWeaponsRange)
        lu.assertIsNumber(self.site.detectionRange)
    end

    function TestHoundContactSite:TestProcessData()
        self.site = HOUND.Contact.Site:New(self.torContact,coalition.side.BLUE)
        self.site:processData()
        lu.assertIsNumber(self.site.maxWeaponsRange)
    end

    function TestHoundContactSite:TestDestroy()
        self.site = HOUND.Contact.Site:New(self.torContact,coalition.side.BLUE)
        local initialMark = self.site._markpoints.pos
        self.site:destroy()
        lu.assertNotNil(initialMark)
    end
end

do
    TestHoundSiteComms = {}

    local function makeMockEmitter(dcsName, hasPos, radioItemText)
        local e = {}
        setmetatable(e, {__index = HOUND.Contact.Emitter})
        e.dcsName = dcsName
        e.uid = 1001
        e._hasPos = hasPos
        e._radioItemText = radioItemText
        function e:hasPos() return self._hasPos end
        function e:getDcsName() return self.dcsName end
        function e:getRadioItemText() return self._radioItemText end
        return e
    end

    function TestHoundSiteComms:setUp()
        self.mockEmitter1 = makeMockEmitter(
            "TOR_SAIPAN-1",
            true,
            "Tor MP - BE: 045/120 (38T PL 564 123)"
        )
        self.mockEmitter2 = makeMockEmitter(
            "TOR_SAIPAN-2",
            false,
            "Tor TR"
        )
        self.mockEmitter3 = makeMockEmitter(
            "EWR_SAIPAN",
            true,
            "55G6 - BE: 045/120 (38T PL 564 123)"
        )

        self.site = {}
        setmetatable(self.site, {__index = HOUND.Contact.Site})
        self.site.name = "T001"
        self.site.pos = {
            p = {x = 1000, y = 0, z = 2000},
            grid = {
                UTMZone = "38T",
                MGRSDigraph = "PL",
                Easting = 564,
                Northing = 123
            },
            be = {
                brg = "045",
                rng = "120",
                brStr = "045"
            },
            LL = {lat = 15.0, lon = 145.0},
            elev = 100
        }
        self.site.DcsGroupName = "TOR_GROUP"
        self.site.DcsObjectName = "TOR_GROUP"
        self.site.gid = 1001
        self.site.typeAssigned = {"SAM"}
        self.site.last_seen = 1000
        self.site.uncertenty_data = {major = 100, minor = 50, az = 45, r = 75}
        self.site.preBriefed = false
        self.site.emitters = {self.mockEmitter1, self.mockEmitter2}
        self.site.primaryEmitter = self.mockEmitter1
        self.site._platformCoalition = 2

        do
            local hasPos = function(self)
                return self.pos ~= nil and self.pos.p ~= nil
            end
            self.site.hasPos = hasPos

            function self.site:getPos()
                if not self:hasPos() then return nil end
                return {x = self.pos.p.x, y = self.pos.p.y, z = self.pos.p.z}
            end

            function self.site:getTextData(utmZone, MGRSdigits)
                return "38T PL 564 123", "045/120"
            end

            function self.site:getTtsData(utmZone, MGRSdigits)
                return "Three Eight Tango Papa Lima five six four one two three", "Zero Four Five 120"
            end

            function self.site:getName()
                return self.name
            end

            function self.site:getDesignation(NATO)
                if NATO then return "SA-2" end
                return "SAM"
            end

            function self.site:getTypeAssigned()
                return table.concat(self.typeAssigned, " or ")
            end

            function self.site:getDcsName()
                return self.DcsGroupName
            end

            function self.site:isAccurate()
                return self.preBriefed
            end

            function self.site:getLastSeen()
                return 5
            end

            function self.site:getType()
                return self:getTypeAssigned()
            end

            function self.site:getEmitters()
                return self.emitters
            end

            function self.site:getPrimary()
                return self.primaryEmitter
            end

            function self.site:getState()
                return self.state
            end
        end

        self._origGetVerbalContactAge = HOUND.Utils.TTS.getVerbalContactAge
        self._origGetVerbalConfidenceLevel = HOUND.Utils.TTS.getVerbalConfidenceLevel
        HOUND.Utils.TTS.getVerbalContactAge = function() return "stale" end
        HOUND.Utils.TTS.getVerbalConfidenceLevel = function() return "Low" end
    end

    function TestHoundSiteComms:tearDown()
        HOUND.Utils.TTS.getVerbalContactAge = self._origGetVerbalContactAge
        HOUND.Utils.TTS.getVerbalConfidenceLevel = self._origGetVerbalConfidenceLevel
        self.site = nil
        self.mockEmitter1 = nil
        self.mockEmitter2 = nil
        self.mockEmitter3 = nil
    end

    function TestHoundSiteComms:TestGetRadioItemTextNoPos()
        self.site.pos.p = nil
        lu.assertEquals(self.site:getRadioItemText(), "T001")
    end

    function TestHoundSiteComms:TestGetRadioItemTextWithPos()
        local result = self.site:getRadioItemText()
        lu.assertStrContains(result, "T001")
        lu.assertStrContains(result, "045/120")
        lu.assertStrContains(result, "38T PL 564 123")
    end

    function TestHoundSiteComms:TestGetRadioItemsText()
        local items = self.site:getRadioItemsText()
        lu.assertIsTable(items)
        lu.assertEquals(items.dcsName, "TOR_GROUP")
        lu.assertIsString(items.txt)
        lu.assertEquals(items.typeAssigned, "SAM")
        lu.assertIsTable(items.pos)
        lu.assertIsNumber(items.last_seen)
        lu.assertIsTable(items.emitters)
    end

    function TestHoundSiteComms:TestGetRadioItemsTextSkipsEmittersNoPos()
        local items = self.site:getRadioItemsText()
        lu.assertEquals(#items.emitters, 1)
    end

    function TestHoundSiteComms:TestGetRadioItemsTextPrimaryPrefix()
        self.site.emitters = {self.mockEmitter1, self.mockEmitter3}
        self.site.primaryEmitter = self.mockEmitter1
        local items = self.site:getRadioItemsText()
        lu.assertEquals(#items.emitters, 2)
        lu.assertStrContains(items.emitters[1].txt, "★ ")
        lu.assertNotStrContains(items.emitters[2].txt, "★ ")
    end

    function TestHoundSiteComms:TestGeneratePopUpReportNoPosNoSector()
        self.site.pos.p = nil
        local msg = self.site:generatePopUpReport(false)
        lu.assertStrContains(msg, "is active")
        lu.assertEquals(msg:sub(-1), ".")
    end

    function TestHoundSiteComms:TestGeneratePopUpReportWithSector()
        local msg = self.site:generatePopUpReport(false, "Saipan")
        lu.assertStrContains(msg, "is active")
        lu.assertStrContains(msg, "in Saipan")
    end

    function TestHoundSiteComms:TestGeneratePopUpReportTTSWithPos()
        local msg = self.site:generatePopUpReport(true)
        lu.assertStrContains(msg, "bullseye")
        lu.assertStrContains(msg, "grid")
    end

    function TestHoundSiteComms:TestGeneratePopUpReportTextWithPos()
        local msg = self.site:generatePopUpReport(false)
        lu.assertStrContains(msg, "BE:")
        lu.assertStrContains(msg, "grid")
    end

    function TestHoundSiteComms:TestGeneratePopUpReportWithSectorNoPos()
        self.site.pos.p = nil
        local msg = self.site:generatePopUpReport(false, "Saipan")
        lu.assertStrContains(msg, "in Saipan")
        lu.assertNotStrContains(msg, "bullseye")
    end

    function TestHoundSiteComms:TestGeneratePopUpReportNoSectorNoPosLocation()
        self.site.pos.p = nil
        local msg = self.site:generatePopUpReport(false)
        lu.assertStrContains(msg, "is active")
        lu.assertNotStrContains(msg, "bullseye")
        lu.assertNotStrContains(msg, "grid")
    end

    function TestHoundSiteComms:TestGenerateDeathReport()
        local msg = self.site:generateDeathReport(false)
        lu.assertStrContains(msg, "is down")
        lu.assertEquals(msg:sub(-1), ".")
    end

    function TestHoundSiteComms:TestGenerateDeathReportWithSector()
        local msg = self.site:generateDeathReport(false, "Saipan")
        lu.assertStrContains(msg, "in Saipan")
    end

    function TestHoundSiteComms:TestGenerateDeathReportTTSWithPos()
        local msg = self.site:generateDeathReport(true)
        lu.assertStrContains(msg, "bullseye")
        lu.assertStrContains(msg, "grid")
    end

    function TestHoundSiteComms:TestGenerateDeathReportTextWithPos()
        local msg = self.site:generateDeathReport(false)
        lu.assertStrContains(msg, "BE:")
        lu.assertStrContains(msg, "grid")
    end

    function TestHoundSiteComms:TestGenerateDeathReportNoPos()
        self.site.pos.p = nil
        local msg = self.site:generateDeathReport(false)
        lu.assertNotStrContains(msg, "grid")
    end

    function TestHoundSiteComms:TestGenerateAsleepReport()
        local msg = self.site:generateAsleepReport(false)
        lu.assertStrContains(msg, "is asleep")
    end

    function TestHoundSiteComms:TestGenerateAsleepReportWithSector()
        local msg = self.site:generateAsleepReport(false, "Saipan")
        lu.assertStrContains(msg, "in Saipan")
    end

    function TestHoundSiteComms:TestGenerateAsleepReportTTSWithPos()
        local msg = self.site:generateAsleepReport(true)
        lu.assertStrContains(msg, "bullseye")
    end

    function TestHoundSiteComms:TestGenerateAsleepReportNoPos()
        self.site.pos.p = nil
        local msg = self.site:generateAsleepReport(false)
        lu.assertNotStrContains(msg, "grid")
    end

    function TestHoundSiteComms:TestGenerateLaunchAlert()
        local msg = self.site:generateLaunchAlert(false)
        lu.assertStrContains(msg, "SAM LAUNCH!")
        lu.assertEquals(msg:sub(-1), "!")
    end

    function TestHoundSiteComms:TestGenerateLaunchAlertWithSector()
        local msg = self.site:generateLaunchAlert(false, "Saipan")
        lu.assertStrContains(msg, "in Saipan")
    end

    function TestHoundSiteComms:TestGenerateLaunchAlertTTS()
        local msg = self.site:generateLaunchAlert(true)
        lu.assertStrContains(msg, "bullseye")
    end

    function TestHoundSiteComms:TestGenerateIdentReport()
        local msg = self.site:generateIdentReport(false)
        lu.assertStrContains(msg, "identified as")
    end

    function TestHoundSiteComms:TestGenerateIdentReportWithSector()
        local msg = self.site:generateIdentReport(false, "Saipan")
        lu.assertStrContains(msg, "in Saipan")
        lu.assertStrContains(msg, "identified as")
    end

    function TestHoundSiteComms:TestGenerateIdentReportTTSWithPos()
        local msg = self.site:generateIdentReport(true)
        lu.assertStrContains(msg, "bullseye")
    end

    function TestHoundSiteComms:TestGenerateIdentReportNoPos()
        self.site.pos.p = nil
        local msg = self.site:generateIdentReport(false)
        lu.assertStrContains(msg, "identified as")
        lu.assertNotStrContains(msg, "grid")
    end

    function TestHoundSiteComms:TestGetDesignationNATO()
        lu.assertEquals(self.site:getDesignation(true), "SA-2")
    end

    function TestHoundSiteComms:TestGetDesignationNoNATO()
        lu.assertEquals(self.site:getDesignation(false), "SAM")
    end

    function TestHoundSiteComms:TestGenerateTtsBriefNoPos()
        self.site.pos.p = nil
        local msg = self.site:generateTtsBrief(false)
        lu.assertEquals(msg, "")
    end

    function TestHoundSiteComms:TestGenerateTtsBriefAccurate()
        self.site.preBriefed = true
        local msg = self.site:generateTtsBrief(false)
        lu.assertStrContains(msg, "reported")
        lu.assertStrContains(msg, "Three Eight")
        lu.assertStrContains(msg, ".")
    end

    function TestHoundSiteComms:TestGenerateTtsBriefNotAccurate()
        self.site.preBriefed = false
        local msg = self.site:generateTtsBrief(false)
        lu.assertStrContains(msg, "stale")
        lu.assertStrContains(msg, "Low")
        lu.assertStrContains(msg, "at ")
    end

    function TestHoundSiteComms:TestGenerateTtsBriefNATO()
        self.site.preBriefed = true
        local msg = self.site:generateTtsBrief(true)
        lu.assertStrContains(msg, "bullseye")
        lu.assertNotStrContains(msg, "T001")
    end

    function TestHoundSiteComms:TestGenerateTtsBriefNaval()
        local orig = self.site.getType
        self.site.getType = function() return "Naval" end
        self.site.emitters = {self.mockEmitter1}
        self.mockEmitter1.generateTtsBrief = function(self, NATO) return "naval brief" end
        local msg = self.site:generateTtsBrief(false)
        lu.assertEquals(msg, "naval brief")
        self.site.getType = orig
    end

    function TestHoundSiteComms:TestGenerateIntelBrief()
        self.mockEmitter1.generateIntelBrief = function(self) return "emitter intel" end
        local items = self.site:generateIntelBrief()
        lu.assertIsTable(items)
        lu.assertEquals(#items, 1)
        lu.assertStrContains(items[1], "T001")
        lu.assertStrContains(items[1], "emitter intel")
    end

    function TestHoundSiteComms:TestGenerateIntelBriefEmptyEmitters()
        self.site.emitters = {}
        local result = self.site:generateIntelBrief()
        lu.assertIsNil(result)
    end

    function TestHoundSiteComms:TestExport()
        self.mockEmitter1.export = function(self)
            return {dcsName = "TOR_SAIPAN-1"}
        end
        local report = self.site:export()
        lu.assertIsTable(report)
        lu.assertEquals(report.name, "T001")
        lu.assertEquals(report.DcsObjectName, "TOR_GROUP")
        lu.assertEquals(report.Type, "SA-2")
        lu.assertIsNumber(report.gid)
        lu.assertEquals(report.gid, 1)
        lu.assertIsTable(report.emitters)
    end

    function TestHoundSiteComms:TestExportNoEmitters()
        self.site.emitters = {}
        local report = self.site:export()
        lu.assertIsTable(report)
        lu.assertEquals(report.name, "T001")
        lu.assertIsTable(report.emitters)
        lu.assertEquals(#report.emitters, 0)
    end
end
