
do
    TestHoundContact = {}

    function TestHoundContact:setUp()
        self.contact = HOUND.Contact.Emitter:New(Unit.getByName("TOR_SAIPAN-1"),coalition.side.BLUE)
        lu.assertNotNil(self.contact)
        lu.assertIsTable(self.contact)
        lu.assertIsTrue(getmetatable(self.contact)==HOUND.Contact.Emitter)
    end

    function TestHoundContact:tearDown()
        self.contact = nil
    end

    function TestHoundContact:TestLocation()
        local emitter = Unit.getByName("TOR_SAIPAN-1")
        local platform1 = Unit.getByName("ELINT_BLUE_C17_EAST")
        local platform2 = Unit.getByName("ELINT_BLUE_C17_WEST")

        lu.assertIsTrue(HOUND.Utils.Dcs.isUnit(emitter))
        lu.assertIsTrue(HOUND.Utils.Dcs.isUnit(platform1))
        lu.assertIsTrue(HOUND.Utils.Dcs.isUnit(platform1))

        lu.assertNotNil(self.contact)
        lu.assertIsTable(self.contact)
        lu.assertIsTrue(getmetatable(self.contact)==HOUND.Contact.Emitter)
        lu.assertEquals(self.contact.state,HOUND.EVENTS.RADAR_NEW)
        lu.assertEquals(emitter,self.contact:getDcsObject())
        local hp,perc = self.contact:getLife()
        HOUND.Logger.debug(hp,perc)

        local tgtPos = emitter:getPosition().p
        local p1 = platform1:getPosition().p
        local p2 = platform2:getPosition().p
        local err = 0

        lu.assertIsTrue(HOUND.Utils.Geo.checkLOS(p1, tgtPos))
        lu.assertIsTrue(HOUND.Utils.Geo.checkLOS(p2, tgtPos))

        local az1,el1 = HOUND.Utils.Elint.getAzimuth( p1, tgtPos, err )
        local az2,el2 = HOUND.Utils.Elint.getAzimuth( p2, tgtPos, err )

        local emitterDetection = HOUND.Utils.Dcs.getRadarDetectionRange(emitter)
        local s1 = HOUND.Utils.Elint.getSignalStrength(p1,tgtPos,emitterDetection)
        local s2 = HOUND.Utils.Elint.getSignalStrength(p2,tgtPos,emitterDetection)

        local d1 = HOUND.Contact.Datapoint.New(platform1,p1, az1, el1, s1, timer.getAbsTime(),err,false)
        local d2 = HOUND.Contact.Datapoint.New(platform2,p2, az2, el2, s2, timer.getAbsTime(),err,false)

        self.contact:AddPoint(d1)
        self.contact:AddPoint(d2)

        local contactState = self.contact:processData()

        lu.assertEquals(contactState,HOUND.EVENTS.RADAR_DETECTED)

        lu.assertAlmostEquals(tgtPos.x,d1:getPos().x,0.75)
        lu.assertAlmostEquals(tgtPos.z,d1:getPos().z,0.75)

        lu.assertAlmostEquals(tgtPos.x,d2:getPos().x,0.75)
        lu.assertAlmostEquals(tgtPos.z,d2:getPos().z,0.75)

        local contactPos = self.contact:getPos()
        if contactPos then
            lu.assertAlmostEquals(tgtPos.x,contactPos.x,0.75)
            lu.assertAlmostEquals(tgtPos.z,contactPos.z,0.75)
        end
    end

    function TestHoundContact:TestLocationErr()
        local emitter = Unit.getByName("TOR_SAIPAN-1")
        local platform1 = Unit.getByName("ELINT_BLUE_C17_EAST")
        local platform2 = Unit.getByName("ELINT_BLUE_C17_WEST")


        lu.assertEquals(self.contact.state,HOUND.EVENTS.RADAR_NEW)
        lu.assertEquals(emitter,self.contact:getDcsObject())

        local tgtPos = emitter:getPosition().p
        local p1 = platform1:getPosition().p
        local p2 = platform2:getPosition().p
        local emitterFreqs = self.contact:getWavelenght()
        HOUND.Logger.debug(emitterFreqs)
        lu.assertIsTrue(((emitterFreqs > 0.074948) and (emitterFreqs < 0.099931)))

        local err = HOUND.DB.getSensorPrecision(platform1,emitterFreqs)
        HOUND.Logger.debug(HOUND.Mist.utils.tableShow(err))

        lu.assertIsTrue(((err > 0.00093685) and (err < 0.037786275)))

        local az1,el1 = HOUND.Utils.Elint.getAzimuth( p1, tgtPos, err )
        local az2,el2 = HOUND.Utils.Elint.getAzimuth( p2, tgtPos, err )
        local emitterDetection = HOUND.Utils.Dcs.getRadarDetectionRange(emitter)
        local s1 = HOUND.Utils.Elint.getSignalStrength(p1,tgtPos,emitterDetection)
        local s2 = HOUND.Utils.Elint.getSignalStrength(p2,tgtPos,emitterDetection)
        local d1 = HOUND.Contact.Datapoint.New(platform1,p1, az1, el1, s1, timer.getAbsTime(),err,false)
        local d2 = HOUND.Contact.Datapoint.New(platform2,p2, az2, el2, s2, timer.getAbsTime(),err,false)

        self.contact:AddPoint(d1)
        self.contact:AddPoint(d2)

        local contactState = self.contact:processData()

        lu.assertEquals(contactState,HOUND.EVENTS.RADAR_DETECTED)
    end

    function TestHoundContact:TestPreBriefed()
        lu.assertIsFalse(self.contact:isAccurate())
        lu.assertIsFalse(self.contact:getPreBriefed())
        self.contact:setPreBriefed(true)
        lu.assertIsTrue(self.contact:isAccurate())
        lu.assertIsTrue(self.contact:getPreBriefed())
        self.contact:setPreBriefed(false)
        lu.assertIsFalse(self.contact:getPreBriefed())
    end

    function TestHoundContact:TestExport()
        self.contact:setPreBriefed(false)
        self.contact:useUnitPos(HOUND.MARKER.POINT)
        local exported = self.contact:export()
        lu.assertIsTable(exported)
        lu.assertEquals(exported.typeName,self.contact.typeName)
        lu.assertEquals(exported.uid,self.contact:getId())
        lu.assertIsNumber(exported.maxWeaponsRange)
        lu.assertIsNumber(exported.last_seen)
    end
end

do
    TestHoundContactEmitter = {}

    function TestHoundContactEmitter:setUp()
        self.tor = Unit.getByName("TOR_SAIPAN-1")
        self.ewr = Unit.getByName("EWR_SAIPAN")
        self.ship = Unit.getByName("KIROV_NORTH")
        self.sa5sr = Unit.getByName("SA-5_SAIPAN-1")
        self.sa5tr = Unit.getByName("SA-5_SAIPAN-2")
        lu.assertNotNil(self.tor)
        lu.assertNotNil(self.ewr)
        lu.assertNotNil(self.ship)
        lu.assertNotNil(self.sa5sr)
        lu.assertNotNil(self.sa5tr)
    end

    function TestHoundContactEmitter:tearDown()
        self.contacts = nil
    end

    function TestHoundContactEmitter:TestConstructorInvalid()
        lu.assertIsNil(HOUND.Contact.Emitter:New())
        lu.assertIsNil(HOUND.Contact.Emitter:New(nil,coalition.side.BLUE))
        lu.assertIsNil(HOUND.Contact.Emitter:New("string",coalition.side.BLUE))
        lu.assertIsNil(HOUND.Contact.Emitter:New({},coalition.side.BLUE))
        lu.assertIsNil(HOUND.Contact.Emitter:New(self.tor,nil))
    end

    function TestHoundContactEmitter:TestEmitterTypes()
        local contacts = {}
        contacts.tor = HOUND.Contact.Emitter:New(self.tor,coalition.side.BLUE)
        contacts.ewr = HOUND.Contact.Emitter:New(self.ewr,coalition.side.BLUE)
        contacts.ship = HOUND.Contact.Emitter:New(self.ship,coalition.side.BLUE)
        contacts.sa5sr = HOUND.Contact.Emitter:New(self.sa5sr,coalition.side.BLUE)
        contacts.sa5tr = HOUND.Contact.Emitter:New(self.sa5tr,coalition.side.BLUE)
        self.contacts = contacts

        for _,c in pairs(contacts) do
            lu.assertIsTrue(getmetatable(c)==HOUND.Contact.Emitter)
            lu.assertEquals(c.state,HOUND.EVENTS.RADAR_NEW)
            lu.assertIsString(c:getName())
            lu.assertIsNumber(c:getId())
            lu.assertIsString(c:getType())
            lu.assertIsString(c:getTrackId())
            lu.assertIsTrue(c:isAlive())
        end

        lu.assertEquals(contacts.ewr.isEWR,true)
        lu.assertEquals(contacts.ewr.typeAssigned[1],"EWR")
        lu.assertStrContains(contacts.ewr:getName(),"Tall Rack 4")
        lu.assertStrContains(contacts.tor:getName(),"Tor")
        lu.assertEquals(contacts.ship.typeAssigned[1],"Naval")
    end

    function TestHoundContactEmitter:TestLife()
        local c = HOUND.Contact.Emitter:New(self.tor,coalition.side.BLUE)
        local hp,perc = c:getLife()
        lu.assertIsNumber(hp)
        lu.assertIsNumber(perc)
        lu.assertIsTrue(hp > 0)
        lu.assertIsTrue(perc > 0)
        lu.assertIsTrue(perc <= 1.0)
    end

    function TestHoundContactEmitter:TestSetDead()
        local c = HOUND.Contact.Emitter:New(self.tor,coalition.side.BLUE)
        lu.assertIsTrue(c:isAlive())
        c:setDead()
        lu.assertIsFalse(c:isAlive())
        lu.assertEquals(c.state,HOUND.EVENTS.RADAR_NEW)
    end

    function TestHoundContactEmitter:TestDestroy()
        local c = HOUND.Contact.Emitter:New(self.tor,coalition.side.BLUE)
        c:destroy()
        lu.assertEquals(c.state,HOUND.EVENTS.RADAR_DESTROYED)
        local eq = c:getEventQueue()
        lu.assertEquals(#eq,1)
        lu.assertEquals(eq[1].id,HOUND.EVENTS.RADAR_DESTROYED)
    end

    function TestHoundContactEmitter:TestWavelength()
        local c = HOUND.Contact.Emitter:New(self.tor,coalition.side.BLUE)
        local searchWl = c:getWavelenght(false)
        local trackWl = c:getWavelenght(true)
        lu.assertIsNumber(searchWl)
        lu.assertIsNumber(trackWl)
        lu.assertIsTrue(searchWl > 0)
        lu.assertIsTrue(trackWl > 0)
    end

    function TestHoundContactEmitter:TestElevNoPos()
        local c = HOUND.Contact.Emitter:New(self.tor,coalition.side.BLUE)
        lu.assertEquals(c:getElev(),0)
    end

    function TestHoundContactEmitter:TestGetIdMod()
        local c = HOUND.Contact.Emitter:New(self.tor,coalition.side.BLUE)
        local uid = self.tor:getID()
        lu.assertEquals(c:getId(),uid%100)
        local c2 = HOUND.Contact.Emitter:New(self.tor,coalition.side.BLUE,9999)
        lu.assertEquals(c2:getId(),9999%100)
    end

    function TestHoundContactEmitter:TestTrackId()
        local c = HOUND.Contact.Emitter:New(self.tor,coalition.side.BLUE)
        lu.assertStrContains(c:getTrackId(),"E")
        c:setPreBriefed(true)
        lu.assertStrContains(c:getTrackId(),"I")
    end

    function TestHoundContactEmitter:TestCleanTimedout()
        local c = HOUND.Contact.Emitter:New(self.tor,coalition.side.BLUE)
        c._dataPoints = {p1={{t=0}}}
        c.last_seen = timer.getAbsTime() - HOUND.CONTACT_TIMEOUT - 1
        local state = c:CleanTimedout()
        lu.assertEquals(state,HOUND.EVENTS.RADAR_ASLEEP)
        lu.assertItemsEquals(c._dataPoints,{})
    end

    function TestHoundContactEmitter:TestCleanTimedoutFresh()
        local c = HOUND.Contact.Emitter:New(self.tor,coalition.side.BLUE)
        c._dataPoints = {p1={{t=1}}}
        local state = c:CleanTimedout()
        lu.assertEquals(c.state,HOUND.EVENTS.RADAR_NEW)
    end

    function TestHoundContactEmitter:TestCountPlatformsEmpty()
        local c = HOUND.Contact.Emitter:New(self.tor,coalition.side.BLUE)
        lu.assertEquals(c:countPlatforms(),0)
        lu.assertEquals(c:countDatapoints(),0)
    end

    function TestHoundContactEmitter:TestUseUnitPos()
        local c = HOUND.Contact.Emitter:New(self.tor,coalition.side.BLUE)
        local state = c:useUnitPos(HOUND.MARKER.POINT)
        lu.assertEquals(state,HOUND.EVENTS.RADAR_DETECTED)
        lu.assertIsTrue(c:hasPos())
        lu.assertIsTrue(c:isAccurate())
        lu.assertIsTable(c.uncertenty_data)
        lu.assertEquals(c.uncertenty_data.major,0.1)
        lu.assertEquals(c.uncertenty_data.minor,0.1)
        lu.assertEquals(c.uncertenty_data.az,0)
        lu.assertEquals(c.uncertenty_data.r,0.1)
    end

    function TestHoundContactEmitter:TestCalculatePolyInvalid()
        local poly = HOUND.Contact.Emitter.calculatePoly(nil)
        lu.assertEquals(#poly,0)
        poly = HOUND.Contact.Emitter.calculatePoly({major=100,minor=50})
        lu.assertEquals(#poly,0)
        poly = HOUND.Contact.Emitter.calculatePoly({major=100,minor=50,az=45})
        lu.assertEquals(#poly,8)
    end

    function TestHoundContactEmitter:TestCalculatePoly()
        local uncertenty = {major=200,minor=100,az=45}
        local refPos = {x=1000,y=100,z=2000}
        local poly = HOUND.Contact.Emitter.calculatePoly(uncertenty,8,refPos)
        lu.assertIsTable(poly)
        lu.assertEquals(#poly,8)
        for _,pt in ipairs(poly) do
            lu.assertIsNumber(pt.x)
            lu.assertIsNumber(pt.z)
            lu.assertIsNumber(pt.y)
        end
    end

    function TestHoundContactEmitter:TestCalculatePolyRefPosDefault()
        local uncertenty = {major=200,minor=100,az=45}
        local poly = HOUND.Contact.Emitter.calculatePoly(uncertenty,8)
        lu.assertIsTable(poly)
        lu.assertEquals(#poly,8)
    end

    function TestHoundContactEmitter:TestTriangulatePoints()
        local earlyPoint = {
            platformPos = {x=0,z=0,y=100},
            az = math.rad(45),
            platformPrecision = 0.01
        }
        local latePoint = {
            platformPos = {x=1000,z=0,y=100},
            az = math.rad(135),
            platformPrecision = 0.01
        }
        setmetatable(earlyPoint, {__index = HOUND.Contact.Datapoint})
        setmetatable(latePoint, {__index = HOUND.Contact.Datapoint})
        earlyPoint.az = math.rad(45)
        latePoint.az = math.rad(135)
        local pos = HOUND.Contact.Emitter.triangulatePoints(earlyPoint,latePoint)
        lu.assertIsTable(pos)
        lu.assertIsNumber(pos.x)
        lu.assertIsNumber(pos.z)
        lu.assertIsNumber(pos.y)
        lu.assertIsNumber(pos.score)
    end

    function TestHoundContactEmitter:TestCalculateExtrasPosData()
        local c = HOUND.Contact.Emitter:New(self.tor,coalition.side.BLUE)
        local pos = {p = {x=400000,y=100,z=2000000}}
        local result = c:calculateExtrasPosData(pos)
        lu.assertIsTable(result.LL)
        lu.assertIsNumber(result.LL.lat)
        lu.assertIsNumber(result.LL.lon)
        lu.assertIsNumber(result.elev)
        lu.assertIsTable(result.grid)
        lu.assertIsString(result.grid.MGRSDigraph)
        lu.assertIsTable(result.be)
        lu.assertIsNumber(result.be.brg)
        lu.assertIsNumber(result.be.rng)
    end

    function TestHoundContactEmitter:TestProcessDataPreBriefed()
        local c = HOUND.Contact.Emitter:New(self.sa5sr,coalition.side.BLUE)
        c:useUnitPos(HOUND.MARKER.POINT)
        c.state = HOUND.EVENTS.RADAR_DETECTED
        local state = c:processData()
        lu.assertNotEquals(state,HOUND.EVENTS.RADAR_DETECTED)
    end

    function TestHoundContactEmitter:TestExportWithPos()
        local c = HOUND.Contact.Emitter:New(self.tor,coalition.side.BLUE)
        c:useUnitPos(HOUND.MARKER.POINT)
        local exported = c:export()
        lu.assertIsTable(exported)
        lu.assertEquals(exported.typeName,c.typeName)
        lu.assertEquals(exported.uid,c:getId())
        lu.assertIsTable(exported.pos)
        lu.assertIsNumber(exported.pos.x)
        lu.assertIsTable(exported.LL)
        lu.assertIsString(exported.accuracy)
        lu.assertIsTable(exported.uncertenty)
        lu.assertIsNumber(exported.uncertenty.major)
        lu.assertIsNumber(exported.uncertenty.minor)
        lu.assertIsNumber(exported.uncertenty.heading)
        lu.assertIsNumber(exported.maxWeaponsRange)
        lu.assertIsNumber(exported.last_seen)
    end

    function TestHoundContactEmitter:TestExportWithoutPos()
        local c = HOUND.Contact.Emitter:New(self.tor,coalition.side.BLUE)
        local exported = c:export()
        lu.assertIsNil(exported.pos)
        lu.assertIsNil(exported.accuracy)
    end

    function TestHoundContactEmitter:TestProcessIntersection()
        local c = HOUND.Contact.Emitter:New(self.tor,coalition.side.BLUE)
        local target = {}
        local p1 = {
            platformPos = {x=0,z=0,y=100},
            az = math.rad(45),
            platformPrecision = 0.01,
            platformId = 1,
            platformName = "p1",
            platformStatic = false,
            signalStrength = 50,
            t = timer.getAbsTime()
        }
        local p2 = {
            platformPos = {x=1000,z=0,y=100},
            az = math.rad(135),
            platformPrecision = 0.01,
            platformId = 2,
            platformName = "p2",
            platformStatic = false,
            signalStrength = 50,
            t = timer.getAbsTime()
        }
        setmetatable(p1, {__index = HOUND.Contact.Datapoint})
        setmetatable(p2, {__index = HOUND.Contact.Datapoint})
        HOUND.Contact.Emitter.processIntersection(c,target,p1,p2)
        lu.assertIsTable(target)
        lu.assertEquals(#target,1)
        lu.assertIsNumber(target[1].x)
        lu.assertIsNumber(target[1].z)
        lu.assertIsNumber(target[1].score)
    end

    function TestHoundContactEmitter:TestProcessIntersectionSkipSamePos()
        local c = HOUND.Contact.Emitter:New(self.tor,coalition.side.BLUE)
        local target = {}
        local p1 = {
            platformPos = {x=100,z=200,y=100},
            az = math.rad(45),
            platformPrecision = 0.01,
            platformId = 1,
            platformName = "p1",
            platformStatic = false,
            signalStrength = 50,
            t = timer.getAbsTime()
        }
        setmetatable(p1, {__index = HOUND.Contact.Datapoint})
        HOUND.Contact.Emitter.processIntersection(c,target,p1,p1)
        lu.assertEquals(#target,0)
    end

    function TestHoundContactEmitter:TestProcessDataWithDatapoints()
        local c = HOUND.Contact.Emitter:New(self.tor,coalition.side.BLUE)
        local now = timer.getAbsTime()
        local dp1 = {
            platformPos = {x=534000,z=1900000,y=10668},
            az = math.rad(47),
            platformPrecision = 0.01,
            signalStrength = 80,
            t = now - 5,
            platformId = 1,
            platformName = "ELINT_BLUE_C17_EAST",
            platformStatic = false,
            processed = false
        }
        local dp2 = {
            platformPos = {x=528000,z=1895000,y=10668},
            az = math.rad(132),
            platformPrecision = 0.01,
            signalStrength = 75,
            t = now - 3,
            platformId = 2,
            platformName = "ELINT_BLUE_C17_WEST",
            platformStatic = false,
            processed = false
        }
        setmetatable(dp1, {__index = HOUND.Contact.Datapoint})
        setmetatable(dp2, {__index = HOUND.Contact.Datapoint})
        c:AddPoint(dp1)
        c:AddPoint(dp2)
        local state = c:processData()
        HOUND.Logger.debug("processData returned state: " .. tostring(state))
        lu.assertNotNil(state)
    end

    function TestHoundContactEmitter:TestDcsAccessors()
        local c = HOUND.Contact.Emitter:New(self.tor,coalition.side.BLUE)
        lu.assertEquals(c:getDcsObject(),self.tor)
        lu.assertEquals(c:getDcsName(),self.tor:getName())
        lu.assertIsString(c:getDcsGroupName())
    end

    function TestHoundContactEmitter:TestEventQueue()
        local c = HOUND.Contact.Emitter:New(self.tor,coalition.side.BLUE)
        lu.assertItemsEquals(c:getEventQueue(),{})
        c:queueEvent(HOUND.EVENTS.RADAR_DETECTED)
        local eq = c:getEventQueue()
        lu.assertEquals(#eq,1)
        lu.assertEquals(eq[1].id,HOUND.EVENTS.RADAR_DETECTED)
        lu.assertEquals(eq[1].initiator,c)
        lu.assertIsNumber(eq[1].time)
    end

    function TestHoundContactEmitter:TestQueueNoChange()
        local c = HOUND.Contact.Emitter:New(self.tor,coalition.side.BLUE)
        c:queueEvent(HOUND.EVENTS.NO_CHANGE)
        lu.assertItemsEquals(c:getEventQueue(),{})
    end

    function TestHoundContactEmitter:TestSectorDefaults()
        local c = HOUND.Contact.Emitter:New(self.tor,coalition.side.BLUE)
        lu.assertEquals(c:getPrimarySector(),"default")
        lu.assertIsTrue(c:isInSector("default"))
        local sectors = c:getSectors()
        lu.assertIsTrue(sectors["default"])
        lu.assertEquals(HOUND.Length(sectors),1)
    end

    function TestHoundContactEmitter:TestAddRemoveSector()
        local c = HOUND.Contact.Emitter:New(self.tor,coalition.side.BLUE)
        c:addSector("Tinian")
        lu.assertIsTrue(c:isInSector("Tinian"))
        lu.assertIsTrue(c:isThreatsSector("Tinian"))
        c:removeSector("Tinian")
        lu.assertIsFalse(c:isThreatsSector("Tinian"))
        lu.assertIsFalse(c:isInSector("Tinian"))
    end

    function TestHoundContactEmitter:TestUpdateSector()
        local c = HOUND.Contact.Emitter:New(self.tor,coalition.side.BLUE)
        c:updateSector("Tinian",true,true)
        lu.assertEquals(c:getPrimarySector(),"Tinian")
        lu.assertIsTrue(c:isThreatsSector("Tinian"))
        c:updateSector("Saipan",false,true)
        lu.assertEquals(c:getPrimarySector(),"Tinian")
        lu.assertIsTrue(c:isThreatsSector("Saipan"))
        c:removeSector("Tinian")
        lu.assertEquals(c:getPrimarySector(),"Tinian")
    end

    function TestHoundContactEmitter:TestSectorNilArgs()
        local c = HOUND.Contact.Emitter:New(self.tor,coalition.side.BLUE)
        c:updateSector("NullZone",nil,nil)
        lu.assertIsFalse(c:isInSector("NullZone"))
        lu.assertIsFalse(c:isThreatsSector("NullZone"))
    end

    function TestHoundContactEmitter:TestDefaultSectorFallback()
        local c = HOUND.Contact.Emitter:New(self.tor,coalition.side.BLUE)
        c:addSector("A")
        c:addSector("B")
        lu.assertTrue(c:isInSector("default"))
        c:removeSector("A")
        c:removeSector("B")
        lu.assertIsTrue(c:isInSector("default"))
    end

    function TestHoundContactEmitter:TestRemoveMarkers()
        local c = HOUND.Contact.Emitter:New(self.tor,coalition.side.BLUE)
        c:removeMarkers()
    end

    function TestHoundContactEmitter:TestGetTextDataNoPos()
        local c = HOUND.Contact.Emitter:New(self.tor,coalition.side.BLUE)
        lu.assertIsNil(c:getTextData())
        lu.assertIsNil(c:getTtsData())
    end
end

do
    TestHoundEmitterComms = {}

    local function createMockEmitter(overrides)
        local e = {uid = 1}
        setmetatable(e, {__index = HOUND.Contact.Emitter})

        e.pos = {p = {x=100, y=0, z=200}, LL = {lat=35.443, lon=-124.5543}}
        e.uncertenty_data = {r = 500, x = 100, z = 100, major = 200, minor = 100, az = 45}
        e.last_seen = timer.getAbsTime() - 120
        e.first_seen = timer.getAbsTime() - 600
        e.name = "55G6"
        e.typeAssigned = {"Early Warning"}
        e.isEWR = true
        e.DcsTypeName = "55G6"
        e.DcsObjectName = "EWR_SAIPAN-1"
        e.DcsGroupName = "EWR_SAIPAN"

        e.getTtsData = function(self_, useMGRS, precision) return "11S 123 456", "030/45" end
        e.getTextData = function(self_, useMGRS, precision) return "11S 123 456", "030/45" end
        e.getName = function(self_) return self_.name end
        e.getDesignation = function(self_, NATO) if NATO then return "EYEBALL" end return "Early Warning" end
        e.isAccurate = function(self_) return false end
        e.hasPos = function(self_) return self_.pos ~= nil and self_.pos.p ~= nil end
        e.getElev = function(self_) return 100 end
        e.getTrackId = function(self_) return "E001" end
        e.getType = function(self_) return "55G6" end

        if overrides then
            for k, v in pairs(overrides) do
                e[k] = v
            end
        end
        return e
    end

    function TestHoundEmitterComms:setUp()
        self.mock = createMockEmitter()
    end

    function TestHoundEmitterComms:tearDown()
        self.mock = nil
    end

    -- generateTtsBrief

    function TestHoundEmitterComms:testTtsBriefNoPos()
        self.mock.pos.p = nil
        local result = self.mock:generateTtsBrief(false)
        lu.assertIsNil(result)
    end

    function TestHoundEmitterComms:testTtsBriefNoUncertenty()
        self.mock.uncertenty_data = nil
        local result = self.mock:generateTtsBrief(false)
        lu.assertIsNil(result)
    end

    function TestHoundEmitterComms:testTtsBriefNonNATO()
        local result = self.mock:generateTtsBrief(false)
        lu.assertIsString(result)
        lu.assertStrContains(result, "55G6")
        lu.assertStrContains(result, " at ")
        lu.assertStrContains(result, "11S 123 456")
        lu.assertStrContains(result, "accuracy")
    end

    function TestHoundEmitterComms:testTtsBriefNATO()
        local result = self.mock:generateTtsBrief(true)
        lu.assertIsString(result)
        lu.assertStrContains(result, "EYEBALL")
        lu.assertStrContains(result, "bullseye")
        lu.assertStrContains(result, "030/45")
        lu.assertStrContains(result, "accuracy")
    end

    function TestHoundEmitterComms:testTtsBriefAccurate()
        self.mock.isAccurate = function() return true end
        local result = self.mock:generateTtsBrief(false)
        lu.assertIsString(result)
        lu.assertStrContains(result, "55G6")
        lu.assertStrContains(result, "reported")
    end

    function TestHoundEmitterComms:testTtsBriefAccurateNATO()
        self.mock.isAccurate = function() return true end
        local result = self.mock:generateTtsBrief(true)
        lu.assertIsString(result)
        lu.assertStrContains(result, "EYEBALL")
        lu.assertStrContains(result, "reported")
        lu.assertStrContains(result, "bullseye")
    end

    function TestHoundEmitterComms:testTtsBriefNotAccurateIncludesAge()
        self.mock.last_seen = timer.getAbsTime() - 10
        local result = self.mock:generateTtsBrief(false)
        lu.assertIsString(result)
        lu.assertStrContains(result, "Active")
    end

    -- generateTtsReport

    function TestHoundEmitterComms:testTtsReportNoPos()
        self.mock.pos.p = nil
        local result = self.mock:generateTtsReport()
        lu.assertIsNil(result)
    end

    function TestHoundEmitterComms:testTtsReportNotAccurate()
        local result = self.mock:generateTtsReport()
        lu.assertIsString(result)
        lu.assertStrContains(result, "55G6")
        lu.assertStrContains(result, "accuracy")
        lu.assertStrContains(result, "MGRS")
        lu.assertStrContains(result, "bullseye")
        lu.assertStrContains(result, "feet MSL")
    end

    function TestHoundEmitterComms:testTtsReportAccurate()
        self.mock.isAccurate = function() return true end
        local result = self.mock:generateTtsReport()
        lu.assertIsString(result)
        lu.assertStrContains(result, "reported")
    end

    function TestHoundEmitterComms:testTtsReportWithRefPos()
        local refPos = {x = 500, z = 500, y = 0}
        local result = self.mock:generateTtsReport(false, false, refPos)
        lu.assertIsString(result)
        lu.assertStrContains(result, "from you")
    end

    function TestHoundEmitterComms:testTtsReportPreferMGRS()
        local result = self.mock:generateTtsReport(false, true)
        lu.assertIsString(result)
        lu.assertStrContains(result, "11S 123 456")
    end

    function TestHoundEmitterComms:testTtsReportUseDMM()
        local result = self.mock:generateTtsReport(true)
        lu.assertIsString(result)
        lu.assertStrContains(result, "55G6")
        lu.assertStrContains(result, "feet MSL")
    end

    function TestHoundEmitterComms:testTtsReportEndsWithControllerResponse()
        local result = self.mock:generateTtsReport()
        lu.assertIsString(result)
        -- controller response is appended after ". " at the end of the report
        local _, controllerPart = result:match("(.+)%.%s(.+)$")
        if controllerPart then
            lu.assertIsTrue(controllerPart == "Good Luck!" or controllerPart == "Happy Hunting!" or controllerPart == "Please send my regards." or controllerPart == "Come back with E T A, T O T, and B D A." or controllerPart == " ")
        end
    end

    -- generateTextReport

    function TestHoundEmitterComms:testTextReportNoPos()
        self.mock.pos.p = nil
        local result = self.mock:generateTextReport()
        lu.assertIsNil(result)
    end

    function TestHoundEmitterComms:testTextReportNotAccurate()
        local result = self.mock:generateTextReport()
        lu.assertIsString(result)
        lu.assertStrContains(result, "55G6")
        lu.assertStrContains(result, "Accuracy")
        lu.assertStrContains(result, "MGRS")
        lu.assertStrContains(result, "LL")
        lu.assertStrContains(result, "Elev")
    end

    function TestHoundEmitterComms:testTextReportAccurate()
        self.mock.isAccurate = function() return true end
        local result = self.mock:generateTextReport()
        lu.assertIsString(result)
        lu.assertStrContains(result, "Reported")
    end

    function TestHoundEmitterComms:testTextReportWithRefPos()
        local refPos = {x = 500, z = 500, y = 0}
        local result = self.mock:generateTextReport(false, refPos)
        lu.assertIsString(result)
        lu.assertStrContains(result, "BR")
    end

    function TestHoundEmitterComms:testTextReportUseDMM()
        local result = self.mock:generateTextReport(true)
        lu.assertIsString(result)
        lu.assertStrContains(result, "55G6")
    end

    -- generatePopUpReport

    function TestHoundEmitterComms:testPopUpReportAccurate()
        self.mock.isAccurate = function() return true end
        local result = self.mock:generatePopUpReport(false)
        lu.assertIsString(result)
        lu.assertStrContains(result, "55G6")
        lu.assertStrContains(result, "reported")
    end

    function TestHoundEmitterComms:testPopUpReportNotAccurate()
        local result = self.mock:generatePopUpReport(false)
        lu.assertIsString(result)
        lu.assertStrContains(result, "55G6")
        lu.assertStrContains(result, "Alive")
    end

    function TestHoundEmitterComms:testPopUpReportWithSector()
        local result = self.mock:generatePopUpReport(false, "Saipan")
        lu.assertIsString(result)
        lu.assertStrContains(result, "in Saipan")
        -- sector suppresses position data
        lu.assertNotStrContains(result, "BE")
    end

    function TestHoundEmitterComms:testPopUpReportTTSPos()
        local result = self.mock:generatePopUpReport(true)
        lu.assertIsString(result)
        lu.assertStrContains(result, "bullseye")
        lu.assertStrContains(result, "grid")
    end

    function TestHoundEmitterComms:testPopUpReportTextPos()
        local result = self.mock:generatePopUpReport(false)
        lu.assertIsString(result)
        lu.assertStrContains(result, "BE")
        lu.assertStrContains(result, "grid")
    end

    function TestHoundEmitterComms:testPopUpReportNoPos()
        self.mock.pos.p = nil
        local result = self.mock:generatePopUpReport(false)
        lu.assertIsString(result)
        -- without pos, just name + state + .
        lu.assertStrContains(result, "55G6")
        lu.assertEquals(result:sub(-1), ".")
    end

    -- generateDeathReport

    function TestHoundEmitterComms:testDeathReport()
        local result = self.mock:generateDeathReport(false)
        lu.assertIsString(result)
        lu.assertStrContains(result, "destroyed")
    end

    function TestHoundEmitterComms:testDeathReportWithSector()
        local result = self.mock:generateDeathReport(false, "Tinian")
        lu.assertIsString(result)
        lu.assertStrContains(result, "destroyed")
        lu.assertStrContains(result, "in Tinian")
    end

    function TestHoundEmitterComms:testDeathReportTTSPos()
        local result = self.mock:generateDeathReport(true)
        lu.assertIsString(result)
        lu.assertStrContains(result, "bullseye")
        lu.assertStrContains(result, "grid")
    end

    function TestHoundEmitterComms:testDeathReportTextPos()
        local result = self.mock:generateDeathReport(false)
        lu.assertIsString(result)
        lu.assertStrContains(result, "BE")
        lu.assertStrContains(result, "grid")
    end

    function TestHoundEmitterComms:testDeathReportNoPos()
        self.mock.pos.p = nil
        local result = self.mock:generateDeathReport(false)
        lu.assertIsString(result)
        lu.assertStrContains(result, "destroyed")
        lu.assertEquals(result:sub(-1), ".")
    end

    -- getRadioItemText

    function TestHoundEmitterComms:testGetRadioItemText()
        local result = self.mock:getRadioItemText()
        lu.assertIsString(result)
        lu.assertStrContains(result, "55G6")
        lu.assertStrContains(result, "BE")
        lu.assertStrContains(result, "030/45")
    end

    function TestHoundEmitterComms:testGetRadioItemTextNoPos()
        self.mock.pos = nil
        local result = self.mock:getRadioItemText()
        lu.assertIsString(result)
        lu.assertEquals(result, "55G6")
    end

    -- generateIntelBrief

    function TestHoundEmitterComms:testIntelBrief()
        local result = self.mock:generateIntelBrief()
        lu.assertIsString(result)
        lu.assertStrContains(result, "E001")
        lu.assertStrContains(result, "55G6")
        lu.assertStrContains(result, ",")
    end

    function TestHoundEmitterComms:testIntelBriefNoPos()
        self.mock.pos = nil
        local result = self.mock:generateIntelBrief()
        lu.assertIsString(result)
        lu.assertEquals(result, "")
    end
end

do
    TestHoundContactDatapoint = {}

    function TestHoundContactDatapoint:setUp()
        self.tor = Unit.getByName("TOR_SAIPAN-1")
        lu.assertNotNil(self.tor)
        self.tgtPos = self.tor:getPoint()
        self.platform = Unit.getByName("ELINT_BLUE_C17_EAST")
        lu.assertNotNil(self.platform)
        self.p0 = self.platform:getPoint()
        self.az0 = math.rad(45)
        self.el0 = math.rad(2)
        self.s0 = 50
        self.t0 = timer.getAbsTime()
    end

    function TestHoundContactDatapoint:tearDown()
    end

    function TestHoundContactDatapoint:TestConstructorInvalid()
        local dp = HOUND.Contact.Datapoint.New(self.platform, self.p0, self.az0, self.el0, nil, self.t0, nil, false)
        lu.assertNotNil(dp)
        lu.assertEquals(dp.signalStrength, 0)
        lu.assertIsNumber(dp.platformPrecision)
        lu.assertEquals(dp.signalStrength, 0)
    end

    function TestHoundContactDatapoint:TestConstructorValid()
        local dp = HOUND.Contact.Datapoint.New(self.platform, self.p0, self.az0, self.el0, self.s0, self.t0, 0.01, false)
        lu.assertNotNil(dp)
        lu.assertIsTrue(getmetatable(dp) == HOUND.Contact.Datapoint)
        lu.assertEquals(dp.platformPos, self.p0)
        lu.assertEquals(dp.az, self.az0)
        lu.assertEquals(dp.el, self.el0)
        lu.assertEquals(dp.signalStrength, tonumber(self.s0))
        lu.assertEquals(dp.t, self.t0)
        lu.assertIsNumber(dp.platformId)
        lu.assertIsString(dp.platformName)
        lu.assertIsFalse(dp.platformStatic)
        lu.assertIsNumber(dp.platformPrecision)
        lu.assertNil(dp.kalman)
        lu.assertIsFalse(dp.processed)
    end

    function TestHoundContactDatapoint:TestConstructorStatic()
        local dp = HOUND.Contact.Datapoint.New(self.platform, self.p0, self.az0, self.el0, self.s0, self.t0, 0.01, true)
        lu.assertNotNil(dp)
        lu.assertIsTrue(dp.platformStatic)
        lu.assertNotNil(dp.kalman)
        lu.assertIsNumber(dp.az)
    end

    function TestHoundContactDatapoint:TestIsStaticFalse()
        local dp = HOUND.Contact.Datapoint.New(self.platform, self.p0, self.az0, self.el0, self.s0, self.t0, 0.01, false)
        lu.assertIsFalse(dp:isStatic())
    end

    function TestHoundContactDatapoint:TestIsStaticTrue()
        local dp = HOUND.Contact.Datapoint.New(self.platform, self.p0, self.az0, self.el0, self.s0, self.t0, 0.01, true)
        lu.assertIsTrue(dp:isStatic())
    end

    function TestHoundContactDatapoint:TestGetAge()
        local dp = HOUND.Contact.Datapoint.New(self.platform, self.p0, self.az0, self.el0, self.s0, self.t0, 0.01, false)
        local age = dp:getAge()
        lu.assertIsNumber(age)
        lu.assertIsTrue(age >= 0)
    end

    function TestHoundContactDatapoint:TestUpdateStatic()
        local dp = HOUND.Contact.Datapoint.New(self.platform, self.p0, self.az0, self.el0, self.s0, self.t0, 0.01, true)
        local newAz = math.rad(46)
        local result = dp:update(newAz)
        lu.assertNotNil(result)
        lu.assertIsNumber(result)
        lu.assertIsNumber(dp.az)
    end

    function TestHoundContactDatapoint:TestUpdateNonStaticNoPrecision()
        local dp = HOUND.Contact.Datapoint.New(self.platform, self.p0, self.az0, self.el0, self.s0, self.t0, nil, false)
        dp.platformPrecision = nil
        local result = dp:update(math.rad(46))
        lu.assertNil(result)
    end

    function TestHoundContactDatapoint:TestGetPosNoAzNoEl()
        local dp = HOUND.Contact.Datapoint.New(self.platform, self.p0, nil, nil, self.s0, self.t0, 0.01, false)
        local pos = dp:getPos()
        lu.assertNil(pos)
    end

    function TestHoundContactDatapoint:TestGetPosStatic()
        local dp = HOUND.Contact.Datapoint.New(self.platform, self.p0, self.az0, self.el0, self.s0, self.t0, 0.01, true)
        local pos = dp:getPos()
        if pos then
            lu.assertIsNumber(pos.x)
        end
    end
end
