do
    TestHoundUtils = {}

    function TestHoundUtils:setUp()
    end

    function TestHoundUtils:TestabsTimeDelta()
        local baseTime = timer.getAbsTime()
        local delta = 10

        lu.assertEquals(HOUND.Utils.absTimeDelta(baseTime,baseTime+delta),delta)
    end

    function TestHoundUtils:TestangleDeltaRad()
        lu.assertIsNil(HOUND.Utils.angleDeltaRad())
        lu.assertAlmostEquals(HOUND.Utils.angleDeltaRad(math.rad(45),math.rad(45)+math.rad(90)),math.rad(90),0.0001)
        lu.assertAlmostEquals(HOUND.Utils.angleDeltaRad(math.rad(315),math.rad(45)),math.rad(90),0.0001)
        lu.assertAlmostEquals(HOUND.Utils.angleDeltaRad(math.rad(45),math.rad(315)),math.rad(90),0.0001)
        lu.assertAlmostEquals(HOUND.Utils.angleDeltaRad(math.rad(80),math.rad(190)),math.rad(110),0.0001)
        lu.assertAlmostEquals(HOUND.Utils.angleDeltaRad(math.rad(270),math.rad(210)),math.rad(60),0.0001)
    end

    function TestHoundUtils:TestAzimuthAverage()
        lu.assertAlmostEquals(HOUND.Utils.AzimuthAverage({math.rad(90),math.rad(30)}),math.rad(60),0.0001)
        lu.assertAlmostEquals(HOUND.Utils.AzimuthAverage({math.rad(90),math.rad(30),math.rad(180),math.rad(150),math.rad(0)}),math.rad(90),0.0001)
        lu.assertAlmostEquals(HOUND.Utils.AzimuthAverage({math.rad(315),math.rad(335)}),math.rad(325),0.0001)
        lu.assertAlmostEquals(HOUND.Utils.AzimuthAverage({math.rad(350),math.rad(10)}),math.rad(0),0.0001)
    end

    function TestHoundUtils:TestAzimuthAverageEmpty()
        lu.assertIsNil(HOUND.Utils.AzimuthAverage({}))
        lu.assertIsNil(HOUND.Utils.AzimuthAverage())
    end

    function TestHoundUtils:TestRandomAngle()
        lu.assertNotEquals(HOUND.Utils.RandomAngle(),HOUND.Utils.RandomAngle())
        local val = HOUND.Utils.RandomAngle()
        lu.assertIsTrue( ((val <= math.pi*2 ) and (val >= 0)))
    end

    function TestHoundUtils:TestNormalizeAngle()
        local PI = math.pi
        lu.assertAlmostEquals(HOUND.Utils.normalizeAngle(0),0,0.0001)
        lu.assertAlmostEquals(HOUND.Utils.normalizeAngle(PI),-PI,0.0001)
        lu.assertAlmostEquals(HOUND.Utils.normalizeAngle(PI*2),0,0.0001)
        lu.assertAlmostEquals(HOUND.Utils.normalizeAngle(-PI/2),-PI/2,0.0001)
        lu.assertAlmostEquals(HOUND.Utils.normalizeAngle(-PI),-PI,0.0001)
        lu.assertAlmostEquals(HOUND.Utils.normalizeAngle(3*PI),-PI,0.0001)
        lu.assertAlmostEquals(HOUND.Utils.normalizeAngle(5*PI/2),PI/2,0.0001)
    end

    function TestHoundUtils:TestGetHoundId()
        local id1 = HOUND.Utils.getHoundId()
        local id2 = HOUND.Utils.getHoundId()
        lu.assertEquals(id2,id1+1)
    end

    function TestHoundUtils:TestGetMarkId()
        local id1 = HOUND.Utils.getMarkId()
        local id2 = HOUND.Utils.getMarkId()
        lu.assertEquals(id2,id1+1)
    end

    function TestHoundUtils:TestSetInitialMarkId()
        lu.assertIsFalse(HOUND.Utils.Marker.setInitialId("not a number"))
        lu.assertIsFalse(HOUND.Utils.Marker.setInitialId(nil))
        local currentId = HOUND.Utils.Marker.getId()
        lu.assertIsFalse(HOUND.Utils.Marker.setInitialId(100))
    end

    function TestHoundUtils:TestMarkerCreate()
        local marker = HOUND.Utils.Marker.create()
        lu.assertIsTable(marker)
        lu.assertIsNumber(marker.id)
        lu.assertEquals(marker.id,-1)
        lu.assertIsFalse(marker:isDrawn())
        marker:remove()
    end

    function TestHoundUtils:TestMarkerCreateWithArgs()
        local marker = HOUND.Utils.Marker.create({
            text = "test",
            pos = {x=400000,z=2000000,y=0},
            coalition = coalition.side.BLUE
        })
        lu.assertIsTable(marker)
        lu.assertIsTrue(marker.id > 0)
        lu.assertIsTrue(marker:isDrawn())
        marker:remove()
        lu.assertIsFalse(marker:isDrawn())
    end

    function TestHoundUtils:TestGetMarkIdIncrement()
        local marker = HOUND.Utils.Marker.create({
            text = "test2",
            pos = {x=400001,z=2000001,y=0},
            coalition = coalition.side.BLUE
        })
        local markId = marker.id
        local nextId = HOUND.Utils.Marker.getId()
        lu.assertEquals(nextId,markId+1)
        marker:remove()
    end

    function TestHoundUtils:TestGetNormalAngularError()
        local nilErr = HOUND.Utils.getNormalAngularError()
        lu.assertIsTable(nilErr)
        local err = HOUND.Utils.getNormalAngularError(0.01)
        lu.assertIsTable(err)
        lu.assertIsNumber(err.az)
        lu.assertIsNumber(err.el)
        local err2 = HOUND.Utils.getNormalAngularError(0)
        lu.assertIsTable(err2)
        lu.assertIsNumber(err2.az)
    end

    function TestHoundUtils:TestGetControllerResponse()
        local resp = HOUND.Utils.getControllerResponse()
        lu.assertIsString(resp)
    end

    function TestHoundUtils:TestGetCoalitionString()
        lu.assertEquals(HOUND.Utils.getCoalitionString(coalition.side.BLUE),"BLUE")
        lu.assertEquals(HOUND.Utils.getCoalitionString(coalition.side.RED),"RED")
        lu.assertEquals(HOUND.Utils.getCoalitionString(coalition.side.NEUTRAL),"NEUTRAL")
        lu.assertEquals(HOUND.Utils.getCoalitionString(nil),"RED")
    end

    function TestHoundUtils:TestHasPayload()
        lu.assertIsTrue(HOUND.Utils.hasPayload())
        lu.assertIsTrue(HOUND.Utils.hasPayload(nil,"ELINT"))
        lu.assertIsTrue(HOUND.Utils.hasPayload("anything","anything"))
    end

    function TestHoundUtils:TestHasTask()
        lu.assertIsTrue(HOUND.Utils.hasTask())
        lu.assertIsTrue(HOUND.Utils.hasTask(nil,"AWACS"))
    end

    function TestHoundUtils:TestUseDMM()
        lu.assertIsFalse(HOUND.Utils.useDMM())
        lu.assertIsFalse(HOUND.Utils.useDMM(nil))
        lu.assertIsFalse(HOUND.Utils.useDMM("fake_unknown_type"))
    end

    function TestHoundUtils:TestUseMGRS()
        lu.assertIsFalse(HOUND.Utils.useMGRS())
        lu.assertIsFalse(HOUND.Utils.useMGRS(nil))
        lu.assertIsFalse(HOUND.Utils.useMGRS("fake_unknown_type"))
    end

    function TestHoundUtils:TestGetRoundedElevationFt()
        lu.assertEquals(HOUND.Utils.getRoundedElevationFt(50),150)
        lu.assertEquals(HOUND.Utils.getRoundedElevationFt(250),800)
        lu.assertEquals(HOUND.Utils.getRoundedElevationFt(500),1650)
        lu.assertEquals(HOUND.Utils.getRoundedElevationFt(1000),3300)
        lu.assertEquals(HOUND.Utils.getRoundedElevationFt(1500),4900)
        lu.assertEquals(HOUND.Utils.getRoundedElevationFt(5000),16400)
        lu.assertEquals(HOUND.Utils.getRoundedElevationFt(8848),29050)
    end

    function TestHoundUtils:TestRoundToNearest()
        lu.assertEquals(HOUND.Utils.roundToNearest(3213,1000),3000)
        lu.assertEquals(HOUND.Utils.roundToNearest(3213,500),3000)
        lu.assertEquals(HOUND.Utils.roundToNearest(3213,100),3200)
        lu.assertEquals(HOUND.Utils.roundToNearest(3213,50),3200)
        lu.assertEquals(HOUND.Utils.roundToNearest(3213,10),3210)
        lu.assertEquals(HOUND.Utils.roundToNearest(3213,5),3215)
        lu.assertEquals(HOUND.Utils.roundToNearest(14730,1000),15000)
        lu.assertEquals(HOUND.Utils.roundToNearest(14730,500),14500)
        lu.assertEquals(HOUND.Utils.roundToNearest(14730,100),14700)
        lu.assertEquals(HOUND.Utils.roundToNearest(14730,50),14750)
        lu.assertEquals(HOUND.Utils.roundToNearest(14730,10),14730)
        lu.assertEquals(HOUND.Utils.roundToNearest(14730,5),14730)
    end

    function TestHoundUtils:TestGetReportId()
        local str,char = HOUND.Utils.getReportId('C')
        lu.assertEquals(char,'D')
        lu.assertEquals(str,'Delta')
        lu.assertEquals(str,HOUND.DB.PHONETICS[char])

        str,char = HOUND.Utils.getReportId('Z')
        lu.assertEquals(char,'A')
        lu.assertEquals(str,'Alpha')

        str,char = HOUND.Utils.getReportId('Y')
        lu.assertEquals(char,'Z')
        lu.assertEquals(str,'Zulu')
    end

    function TestHoundUtils:TestDecToDMS()
        lu.assertItemsEquals(HOUND.Utils.DecToDMS(35.443),{d=35,m=26,s=34,mDec=26.580,sDec=580})
        lu.assertItemsEquals(HOUND.Utils.DecToDMS(-124.5543),{d=-124,m=33,s=15,mDec=33.258,sDec=258})

        lu.assertItemsEquals(HOUND.Utils.getHemispheres(35.443,-124.5543),{NS="N",EW="W"})
        lu.assertItemsEquals(HOUND.Utils.getHemispheres(35.443,-124.5543,true),{NS="North",EW="West"})
    end

    function TestHoundUtils:TestDcs()
        lu.assertIsFalse(HOUND.Utils.Dcs.isPoint("somethign"))
        lu.assertIsFalse(HOUND.Utils.Dcs.isPoint(true))
        lu.assertIsFalse(HOUND.Utils.Dcs.isPoint({"assd","asdf"}))
        lu.assertIsFalse(HOUND.Utils.Dcs.isPoint({x="asdf",z="asdf"}))
        lu.assertIsFalse(HOUND.Utils.Dcs.isPoint({x="123123",z="123123"}))
        lu.assertIsTrue(HOUND.Utils.Dcs.isPoint({x=12345,z=67890}))

        local unit = Unit.getByName("TOR_SAIPAN-1")
        local group = Group.getByName("SA-5_SAIPAN")
        local static= StaticObject.getByName("StaticTower")

        lu.assertIsFalse(HOUND.Utils.Dcs.isGroup(nil))
        lu.assertIsFalse(HOUND.Utils.Dcs.isGroup("SA-5_SAIPAN"))
        lu.assertIsFalse(HOUND.Utils.Dcs.isGroup(unit))
        lu.assertIsTrue(HOUND.Utils.Dcs.isGroup(group))

        lu.assertIsFalse(HOUND.Utils.Dcs.isUnit(nil))
        lu.assertIsFalse(HOUND.Utils.Dcs.isUnit("SA-5_SAIPAN"))
        lu.assertIsFalse(HOUND.Utils.Dcs.isUnit(group))
        lu.assertIsTrue(HOUND.Utils.Dcs.isUnit(unit))

        lu.assertIsTrue(HOUND.Utils.Dcs.isStaticObject(static))
        lu.assertIsFalse(HOUND.Utils.Dcs.isStaticObject("StaticTower"))
        lu.assertIsFalse(HOUND.Utils.Dcs.isStaticObject(group))
        lu.assertIsFalse(HOUND.Utils.Dcs.isStaticObject(unit))
    end

    function TestHoundUtils:TestCopyPoint()
        local p = {x=100,y=200,z=300}
        local copy = HOUND.Utils.Dcs.copyPoint(p)
        lu.assertIsTable(copy)
        lu.assertEquals(copy.x,100)
        lu.assertEquals(copy.y,200)
        lu.assertEquals(copy.z,300)
        copy.x = 999
        lu.assertEquals(p.x,100)
    end

    function TestHoundUtils:TestCopyPointInvalid()
        lu.assertIsNil(HOUND.Utils.Dcs.copyPoint(nil))
        lu.assertIsNil(HOUND.Utils.Dcs.copyPoint("string"))
        lu.assertIsNil(HOUND.Utils.Dcs.copyPoint({}))
    end

    function TestHoundUtils:TestCopyPointZY()
        local p = {x=100,y=200}
        local copy = HOUND.Utils.Dcs.copyPoint(p)
        lu.assertItemsEquals(copy, {x=100, y=0, z=200})
    end

    function TestHoundUtils:TestEarthLOS()
        local d = HOUND.Utils.Geo.EarthLOS(10668,0)
        lu.assertIsNumber(d)
        lu.assertIsTrue(d > 300000)
        lu.assertIsTrue(d < 500000)
    end

    function TestHoundUtils:TestEarthLOSPartial()
        local d = HOUND.Utils.Geo.EarthLOS(10668)
        lu.assertIsNumber(d)
        lu.assertIsTrue(d > 200000)
        lu.assertIsTrue(d < 400000)
    end

    function TestHoundUtils:TestEarthLOSNoArgs()
        lu.assertEquals(HOUND.Utils.Geo.EarthLOS(),0)
    end

    function TestHoundUtils:TestSqDist2D()
        local src = {x=0,z=0}
        local dst = {x=3,z=4}
        lu.assertEquals(HOUND.Utils.Geo.sqDist2D(src,dst),25)
    end

    function TestHoundUtils:TestSqDist2DInvalid()
        lu.assertEquals(HOUND.Utils.Geo.sqDist2D(nil,{x=1,z=1}),0)
        lu.assertEquals(HOUND.Utils.Geo.sqDist2D({x=1,z=1},nil),0)
        lu.assertEquals(HOUND.Utils.Geo.sqDist2D("bad",{x=1,z=1}),0)
    end

    function TestHoundUtils:TestGet2DDistance()
        local src = {x=0,z=0}
        local dst = {x=3,z=4}
        local dist = HOUND.Utils.Geo.get2DDistance(src,dst)
        if dist then
            lu.assertAlmostEquals(dist,5,0.0001)
        end
    end

    function TestHoundUtils:TestGet3DDistance()
        local src = {x=0,y=0,z=0}
        local dst = {x=3,y=4,z=4}
        local dist = HOUND.Utils.Geo.get3DDistance(src,dst)
        if dist then
            lu.assertIsNumber(dist)
            lu.assertIsTrue(dist > 5)
            lu.assertIsTrue(dist < 7)
        end
    end

    function TestHoundUtils:TestGeoDistanceInvalid()
        lu.assertIsNil(HOUND.Utils.Geo.get2DDistance(nil,{x=1,z=1}))
        lu.assertIsNil(HOUND.Utils.Geo.get3DDistance({x=1,z=1},nil))
    end

    function TestHoundUtils:TestGetMagVar()
        local pt = {x=400000,z=2000000,y=0}
        local mv = HOUND.Utils.getMagVar(pt)
        lu.assertIsNumber(mv)
    end

    function TestHoundUtils:TestGetMagVarInvalid()
        lu.assertEquals(HOUND.Utils.getMagVar(nil),0)
        lu.assertEquals(HOUND.Utils.getMagVar("string"),0)
    end

    function TestHoundUtils:TestGetBR()
        local src = {x=400000,z=2000000,y=0}
        local dst = {x=410000,z=2010000,y=0}
        local br = HOUND.Utils.getBR(src,dst)
        if br then
            lu.assertIsNumber(br.brg)
            lu.assertIsString(br.brStr)
            lu.assertIsNumber(br.rng)
            lu.assertEquals(#br.brStr,3)
        end
    end

    function TestHoundUtils:TestGetBRInvalid()
        lu.assertIsNil(HOUND.Utils.getBR(nil,{x=1,z=1}))
        lu.assertIsNil(HOUND.Utils.getBR({x=1,z=1},nil))
    end

    function TestHoundUtils:TestGetMappingClamp()
        lu.assertEquals(HOUND.Utils.Mapping.clamp(5,0,10),5)
        lu.assertEquals(HOUND.Utils.Mapping.clamp(-1,0,10),0)
        lu.assertEquals(HOUND.Utils.Mapping.clamp(15,0,10),10)
        lu.assertEquals(HOUND.Utils.Mapping.clamp(50,0,10),10)
        lu.assertEquals(HOUND.Utils.Mapping.clamp(0,0,10),0)
    end

    function TestHoundUtils:TestMappingLinear()
        lu.assertEquals(HOUND.Utils.Mapping.linear(10,0,10,0,100),100)
        lu.assertEquals(HOUND.Utils.Mapping.linear(0,0,10,0,100),0)
        lu.assertEquals(HOUND.Utils.Mapping.linear(5,0,10,0,100),50)
        lu.assertEquals(HOUND.Utils.Mapping.linear(0.5,0,1,0,100),50)
    end

    function TestHoundUtils:TestMappingLinearClamp()
        lu.assertEquals(HOUND.Utils.Mapping.linear(-10,0,10,0,100,true),0)
        lu.assertEquals(HOUND.Utils.Mapping.linear(20,0,10,0,100,true),100)
        lu.assertEquals(HOUND.Utils.Mapping.linear(-1,0,10,100,0,true),100)
        lu.assertEquals(HOUND.Utils.Mapping.linear(20,0,10,100,0,true),0)
    end

    function TestHoundUtils:TestMappingNonLinearDefaults()
        local v = HOUND.Utils.Mapping.nonLinear(5,0,10)
        lu.assertIsNumber(v)
        lu.assertIsTrue(v >= 0)
        lu.assertIsTrue(v <= 1)
    end

    function TestHoundUtils:TestMappingNonLinearOutRange()
        local v = HOUND.Utils.Mapping.nonLinear(5,0,10,0,100)
        lu.assertIsNumber(v)
        lu.assertIsTrue(v >= 0)
        lu.assertIsTrue(v <= 100)
    end

    function TestHoundUtils:TestMappingNonLinearSensitivity()
        local v1 = HOUND.Utils.Mapping.nonLinear(5,0,10,0,100,9)
        local v2 = HOUND.Utils.Mapping.nonLinear(5,0,10,0,100,0)
        lu.assertIsNumber(v1)
        lu.assertIsNumber(v2)
    end

    function TestHoundUtils:TestMappingNonLinearCurves()
        for _,curveType in ipairs({0,1,2,3,4,5,6}) do
            local v = HOUND.Utils.Mapping.nonLinear(5,0,10,0,100,5,curveType-1)
            lu.assertIsNumber(v)
        end
    end

    function TestHoundUtils:TestGetUnitVector()
        local v = HOUND.Utils.Vector.getUnitVector(0)
        lu.assertIsTable(v)
        lu.assertEquals(v.x,1)
        lu.assertEquals(v.z,0)
        lu.assertEquals(v.y,0)
    end

    function TestHoundUtils:TestGetUnitVectorNoArgs()
        local v = HOUND.Utils.Vector.getUnitVector()
        lu.assertItemsEquals(v,{x=0,y=0,z=0})
    end

    function TestHoundUtils:TestGetUnitVectorWithElevation()
        local v = HOUND.Utils.Vector.getUnitVector(math.pi/4,math.pi/4)
        lu.assertIsNumber(v.x)
        lu.assertIsNumber(v.z)
        lu.assertIsNumber(v.y)
        lu.assertIsTrue(v.y > 0)
    end

    function TestHoundUtils:TestGetRandomVec2()
        local v = HOUND.Utils.Vector.getRandomVec2(0.1)
        lu.assertIsTable(v)
        lu.assertIsNumber(v.x)
        lu.assertIsNumber(v.z)
        lu.assertIsNumber(v.y)
    end

    function TestHoundUtils:TestGetRandomVec2Invalid()
        local v = HOUND.Utils.Vector.getRandomVec2(nil)
        lu.assertItemsEquals(v,{x=0,y=0,z=0})
        v = HOUND.Utils.Vector.getRandomVec2("bad")
        lu.assertItemsEquals(v,{x=0,y=0,z=0})
        v = HOUND.Utils.Vector.getRandomVec2(0)
        lu.assertItemsEquals(v,{x=0,y=0,z=0})
    end

    function TestHoundUtils:TestGetRandomVec3()
        local v = HOUND.Utils.Vector.getRandomVec3(0.1)
        lu.assertIsTable(v)
        lu.assertIsNumber(v.x)
        lu.assertIsNumber(v.z)
        lu.assertIsNumber(v.y)
    end

    function TestHoundUtils:TestGetRandomVec3Invalid()
        local v = HOUND.Utils.Vector.getRandomVec3(nil)
        lu.assertItemsEquals(v,{x=0,y=0,z=0})
        v = HOUND.Utils.Vector.getRandomVec3(0)
        lu.assertItemsEquals(v,{x=0,y=0,z=0})
    end

    function TestHoundUtils:TestGenerateAngularError()
        local err = HOUND.Utils.Elint.generateAngularError(0.01)
        lu.assertIsTable(err)
        lu.assertIsNumber(err.az)
        lu.assertIsNumber(err.el)
    end

    function TestHoundUtils:TestGenerateAngularErrorZero()
        local err = HOUND.Utils.Elint.generateAngularError(0)
        lu.assertIsTable(err)
        lu.assertIsNumber(err.az)
    end

    function TestHoundUtils:TestGetSamRange()
        local tor = Unit.getByName("TOR_SAIPAN-1")
        local rng = HOUND.Utils.Dcs.getSamRange(tor)
        lu.assertIsNumber(rng)
        lu.assertIsTrue(rng >= 0)
        local bad = HOUND.Utils.Dcs.getSamRange(nil)
        lu.assertEquals(bad,0)
    end

    function TestHoundUtils:TestGetSamMaxRange()
        local tor = Unit.getByName("TOR_SAIPAN-1")
        local rng = HOUND.Utils.Dcs.getSamMaxRange(tor)
        lu.assertIsNumber(rng)
        lu.assertIsTrue(rng >= 0)
    end

    function TestHoundUtils:TestGetRadarDetectionRange()
        local tor = Unit.getByName("TOR_SAIPAN-1")
        local rng = HOUND.Utils.Dcs.getRadarDetectionRange(tor)
        lu.assertIsNumber(rng)
        lu.assertIsTrue(rng >= 0)
        local bad = HOUND.Utils.Dcs.getRadarDetectionRange(nil)
        lu.assertEquals(bad,0)
    end

    function TestHoundUtils:TestGetRadarUnitsInGroup()
        local group = Group.getByName("TOR_SAIPAN")
        local units = HOUND.Utils.Dcs.getRadarUnitsInGroup(group)
        lu.assertIsTable(units)
        local bad = HOUND.Utils.Dcs.getRadarUnitsInGroup(nil)
        lu.assertItemsEquals(bad,{})
    end

    function TestHoundUtils:TestGetSignalStrength()
        local src = {x=0,z=0,y=100}
        local dst = {x=1000,z=0,y=0}
        local ss = HOUND.Utils.Elint.getSignalStrength(src,dst,50000)
        lu.assertIsNumber(ss)
        lu.assertIsTrue(ss > 0)
    end

    function TestHoundUtils:TestGetSignalStrengthInvalid()
        lu.assertEquals(HOUND.Utils.Elint.getSignalStrength(nil,{x=1,z=1},100),0)
        lu.assertEquals(HOUND.Utils.Elint.getSignalStrength({x=1,z=1},nil,100),0)
        lu.assertEquals(HOUND.Utils.Elint.getSignalStrength({x=1,z=1},{x=2,z=2},0),0)
    end

    function TestHoundUtils:TestElintGetAzimuth()
        local src = {x=0,z=0,y=100}
        local dst = {x=1000,z=0,y=0}
        local az,el,vec = HOUND.Utils.Elint.getAzimuth(src,dst,0)
        lu.assertIsNumber(az)
        lu.assertIsNumber(el)
        lu.assertIsTable(vec)
        lu.assertAlmostEquals(az,0,0.001)
    end

    function TestHoundUtils:TestGaussianKernel()
        local v = HOUND.Utils.Cluster.gaussianKernel(0,1)
        lu.assertIsNumber(v)
        lu.assertIsTrue(v > 0)
        local v2 = HOUND.Utils.Cluster.gaussianKernel(10,1)
        lu.assertIsNumber(v2)
        lu.assertIsTrue(v2 > 0)
        lu.assertIsTrue(v2 < v)
    end

    function TestHoundUtils:TestSortContactsById()
        local a = {uid=100,maxWeaponsRange=10000}
        local b = {uid=200,maxWeaponsRange=5000}
        local c = {uid=100,maxWeaponsRange=20000}
        lu.assertIsTrue(HOUND.Utils.Sort.ContactsById(a,b))
        lu.assertIsFalse(HOUND.Utils.Sort.ContactsById(b,a))
        lu.assertIsTrue(HOUND.Utils.Sort.ContactsById(c,a))
    end

    function TestHoundUtils:TestSortContactsByPrio()
        local primary = {isPrimary=true,unitWeaponRange=10000,detectionRange=20000,radarRoles={1},uid=1}
        local secondary = {isPrimary=false,unitWeaponRange=5000,detectionRange=10000,radarRoles={1},uid=2}
        lu.assertIsTrue(HOUND.Utils.Sort.ContactsByPrio(primary,secondary))
        lu.assertIsFalse(HOUND.Utils.Sort.ContactsByPrio(secondary,primary))
    end

    function TestHoundUtils:TestSortContactsByPrioDetectFallback()
        local a = {isPrimary=false,unitWeaponRange=0,detectionRange=20000,radarRoles={1},uid=1}
        local b = {isPrimary=false,unitWeaponRange=0,detectionRange=10000,radarRoles={1},uid=2}
        lu.assertIsTrue(HOUND.Utils.Sort.ContactsByPrio(a,b))
        lu.assertIsFalse(HOUND.Utils.Sort.ContactsByPrio(b,a))
    end

    function TestHoundUtils:TestSortContactsByRange()
        local ewr = {isEWR=true,maxWeaponsRange=0,detectionRange=500000,typeAssigned={"EWR"},typeName="55G6",first_seen=100,uid=1}
        local sam = {isEWR=false,maxWeaponsRange=50000,detectionRange=100000,typeAssigned={"SA-10"},typeName="S-300",first_seen=200,uid=2}
        lu.assertIsFalse(HOUND.Utils.Sort.ContactsByRange(ewr,sam))
        lu.assertIsTrue(HOUND.Utils.Sort.ContactsByRange(sam,ewr))
    end

    function TestHoundUtils:TestSortSectorsByPriority()
        local high = {getPriority = function() return 90 end}
        local low = {getPriority = function() return 10 end}
        lu.assertIsTrue(HOUND.Utils.Sort.sectorsByPriorityLowFirst(high,low))
        lu.assertIsFalse(HOUND.Utils.Sort.sectorsByPriorityLowFirst(low,high))
        lu.assertIsTrue(HOUND.Utils.Sort.sectorsByPriorityLowLast(low,high))
        lu.assertIsFalse(HOUND.Utils.Sort.sectorsByPriorityLowLast(high,low))
    end

    function TestHoundUtils:TestTTSDecToDMS()
        local str = HOUND.Utils.TTS.DecToDMS(35.443)
        lu.assertIsString(str)
        lu.assertStrContains(str,"degrees")
        lu.assertStrContains(str,"minutes")
        lu.assertStrContains(str,"seconds")
    end

    function TestHoundUtils:TestTTSDecToDMSMinDec()
        local str = HOUND.Utils.TTS.DecToDMS(35.443,true)
        lu.assertIsString(str)
        lu.assertStrContains(str,"minutes")
    end

    function TestHoundUtils:TestTTSDecToDMSPadDeg()
        local str = HOUND.Utils.TTS.DecToDMS(35.443,false,true)
        lu.assertIsString(str)
        lu.assertStrContains(str,"035 degrees")
    end

    function TestHoundUtils:TestTTSGetReadTime()
        local t = HOUND.Utils.TTS.getReadTime(100)
        lu.assertIsNumber(t)
        lu.assertIsTrue(t > 0)
    end

    function TestHoundUtils:TestTTSGetReadTimeNil()
        lu.assertIsNil(HOUND.Utils.TTS.getReadTime())
    end

    function TestHoundUtils:TestTTSGetReadTimeString()
        local t = HOUND.Utils.TTS.getReadTime("hello world")
        lu.assertIsNumber(t)
        lu.assertIsTrue(t > 0)
    end

    function TestHoundUtils:TestTTSGetReadTimeSpeed()
        local t1 = HOUND.Utils.TTS.getReadTime(100,2.0)
        local t2 = HOUND.Utils.TTS.getReadTime(100,0.5)
        lu.assertIsNumber(t1)
        lu.assertIsNumber(t2)
    end

    function TestHoundUtils:TestTTSGetReadTimeGoogle()
        local t = HOUND.Utils.TTS.getReadTime(100,1.0,true)
        lu.assertIsNumber(t)
    end

    function TestHoundUtils:TestTTSGetCardinalDirection()
        lu.assertEquals(HOUND.Utils.TTS.getCardinalDirection(0),"North")
        lu.assertEquals(HOUND.Utils.TTS.getCardinalDirection(45),"North East")
        lu.assertEquals(HOUND.Utils.TTS.getCardinalDirection(90),"East")
        lu.assertEquals(HOUND.Utils.TTS.getCardinalDirection(135),"South East")
        lu.assertEquals(HOUND.Utils.TTS.getCardinalDirection(180),"South")
        lu.assertEquals(HOUND.Utils.TTS.getCardinalDirection(225),"South West")
        lu.assertEquals(HOUND.Utils.TTS.getCardinalDirection(270),"West")
        lu.assertEquals(HOUND.Utils.TTS.getCardinalDirection(315),"North West")
        lu.assertEquals(HOUND.Utils.TTS.getCardinalDirection(360),"North")
    end

    function TestHoundUtils:TestTTSGetCardinalDirectionWrap()
        lu.assertEquals(HOUND.Utils.TTS.getCardinalDirection(-45),"North West")
        lu.assertEquals(HOUND.Utils.TTS.getCardinalDirection(400),"North East")
    end

    function TestHoundUtils:TestGetFormationCallsign()
        local callsign = HOUND.Utils.getFormationCallsign({callsign={name="Carbon"}})
        lu.assertEquals(type(callsign),"string")
    end

    function TestHoundUtils:TestGetFormationCallsignEmpty()
        lu.assertEquals(HOUND.Utils.getFormationCallsign("string"),"")
    end

    function TestHoundUtils:TestPointClusterTilt()
        local points = {
            {x=0,y=0,z=0},
            {x=100,y=0,z=100},
            {x=50,y=0,z=50}
        }
        local tilt = HOUND.Utils.PointClusterTilt(points)
        lu.assertIsNumber(tilt)
        lu.assertIsTrue(tilt >= 0)
        lu.assertIsTrue(tilt <= math.pi*2)
    end

    function TestHoundUtils:TestPointClusterTiltInvalid()
        lu.assertIsNil(HOUND.Utils.PointClusterTilt(nil))
        lu.assertIsNil(HOUND.Utils.PointClusterTilt("string"))
    end

    function TestHoundUtils:TestPointClusterTiltWithRef()
        local points = {
            {x=0,z=0,y=0},
            {x=100,z=0,y=0}
        }
        local tilt = HOUND.Utils.PointClusterTilt(points,false,{x=0,z=0,y=0})
        lu.assertAlmostEquals(tilt,0,0.001)
    end

    function TestHoundUtils:TestGetFormationCallsignInvalid()
        lu.assertEquals(HOUND.Utils.getFormationCallsign(nil),"")
    end

    function TestHoundUtils:TestGetFormationCallsignNoCallsign()
        local result = HOUND.Utils.getFormationCallsign({callsign={}})
        lu.assertIsString(result)
    end

    function TestHoundUtils:TestTTSGetVerbalLLSouth()
        local str = HOUND.Utils.TTS.getVerbalLL(-35.443,-124.5543)
        lu.assertStrContains(str,"South")
        lu.assertStrContains(str,"West")
    end

    function TestHoundUtils:TestTTSGetVerbalLLNorthEast()
        local str = HOUND.Utils.TTS.getVerbalLL(35.443,37.5543)
        lu.assertStrContains(str,"North")
        lu.assertStrContains(str,"East")
    end

    function TestHoundUtils:TestGetEmitters()
        local tor = Unit.getByName("TOR_SAIPAN-1")
        local torContact = HOUND.Contact.Emitter:New(tor,coalition.side.BLUE)
        local ewrUnit = Unit.getByName("EWR_SAIPAN")
        local ewrContact = HOUND.Contact.Emitter:New(ewrUnit,coalition.side.BLUE)
        local shipUnit = Unit.getByName("KIROV_NORTH")
        local shipContact = HOUND.Contact.Emitter:New(shipUnit,coalition.side.BLUE)

        local contacts = {torContact,ewrContact,shipContact}
        table.sort(contacts,HOUND.Utils.Sort.ContactsByRange)
        lu.assertIsTrue(#contacts == 3)
        lu.assertEquals(contacts[1],shipContact)

        table.sort(contacts,HOUND.Utils.Sort.ContactsById)
        lu.assertIsTrue(#contacts == 3)

        table.sort(contacts,HOUND.Utils.Sort.ContactsByPrio)
        lu.assertIsTrue(#contacts == 3)
    end

    function TestHoundUtils:TestPolygonGaussianKernelMulti()
        local v1 = HOUND.Utils.Cluster.gaussianKernel(0,0.2)
        local v2 = HOUND.Utils.Cluster.gaussianKernel(0.5,0.2)
        lu.assertIsTrue(v1 > v2)
    end

    function TestHoundUtils:TestFilterFunctions()
        local elintGroups = HOUND.Utils.Filter.groupsByPrefix("ELINT_BLUE")
        lu.assertIsTable(elintGroups)
        local elintUnits = HOUND.Utils.Filter.unitsByPrefix("TOR_SAIPAN")
        lu.assertIsTable(elintUnits)
        local statics = HOUND.Utils.Filter.staticObjectsByPrefix("Static")
        lu.assertIsTable(statics)
        local empty = HOUND.Utils.Filter.groupsByPrefix(123)
        lu.assertItemsEquals(empty,{})
    end

    function TestHoundUtils:TestDcsGetGroupNames()
        local groups = HOUND.Utils.Dcs.getGroupNames("TOR")
        lu.assertIsTable(groups)
        lu.assertIsTrue(HOUND.Length(groups) > 0)
        groups = HOUND.Utils.Dcs.getGroupNames()
        lu.assertIsTable(groups)
    end

    function TestHoundUtils:TestDcsGetUnitNames()
        local units = HOUND.Utils.Dcs.getUnitNames("TOR_SAIPAN")
        lu.assertIsTable(units)
        lu.assertIsTrue(HOUND.Length(units) > 0)
    end

    function TestHoundUtils:TestDcsGetStaticObjectNames()
        local statics = HOUND.Utils.Dcs.getStaticObjectNames("Static")
        lu.assertIsTable(statics)
    end

    function TestHoundUtils:TestTTSGetVerbalContactAge()
        local testTime = timer.getAbsTime()
        lu.assertEquals(HOUND.Utils.TTS.getVerbalContactAge(testTime-10,true),"Active")
        lu.assertEquals(HOUND.Utils.TTS.getVerbalContactAge(testTime-80,true),"very recent")
        lu.assertEquals(HOUND.Utils.TTS.getVerbalContactAge(testTime-179,true),"recent")
        lu.assertEquals(HOUND.Utils.TTS.getVerbalContactAge(testTime-290,true),"relevant")
        lu.assertEquals(HOUND.Utils.TTS.getVerbalContactAge(testTime-600,true),"stale")

        lu.assertEquals(HOUND.Utils.TTS.getVerbalContactAge(testTime-5,true,true),"Active")
        lu.assertEquals(HOUND.Utils.TTS.getVerbalContactAge(testTime-60,true,true),"Down")
        lu.assertEquals(HOUND.Utils.TTS.getVerbalContactAge(testTime-(HOUND.CONTACT_TIMEOUT+1),true,true),"Asleep")

        lu.assertEquals(HOUND.Utils.TTS.getVerbalContactAge(testTime-5),"5 seconds")
        lu.assertEquals(HOUND.Utils.TTS.getVerbalContactAge(testTime-65),"1 minutes")
        lu.assertEquals(HOUND.Utils.TTS.getVerbalContactAge(testTime-301),"5 minutes")
        lu.assertEquals(HOUND.Utils.TTS.getVerbalContactAge(testTime-901),"15 minutes")
        lu.assertEquals(HOUND.Utils.TTS.getVerbalContactAge(testTime-(1.5*3600+1)),"90 minutes")
        lu.assertEquals(HOUND.Utils.TTS.getVerbalContactAge(testTime-(4.75*3600+1)),"4 hours, 45 minutes")
        lu.assertEquals(HOUND.Utils.TTS.getVerbalContactAge(testTime-(15*3600+1)),"15 hours, 0 minutes")
    end

    function TestHoundUtils:TestGetVerbalConfidenceLevel()
        lu.assertEquals(HOUND.Utils.TTS.getVerbalConfidenceLevel(0.1),"Precise")
        lu.assertEquals(HOUND.Utils.TTS.getVerbalConfidenceLevel(150),"Very High")
        lu.assertEquals(HOUND.Utils.TTS.getVerbalConfidenceLevel(499),"Very High")
        lu.assertEquals(HOUND.Utils.TTS.getVerbalConfidenceLevel(500),"High")
        lu.assertEquals(HOUND.Utils.TTS.getVerbalConfidenceLevel(501),"High")
        lu.assertEquals(HOUND.Utils.TTS.getVerbalConfidenceLevel(1000),"Medium")
        lu.assertEquals(HOUND.Utils.TTS.getVerbalConfidenceLevel(1900),"Low")
        lu.assertEquals(HOUND.Utils.TTS.getVerbalConfidenceLevel(2200),"Low")
        lu.assertEquals(HOUND.Utils.TTS.getVerbalConfidenceLevel(2600),"Very Low")
        lu.assertEquals(HOUND.Utils.TTS.getVerbalConfidenceLevel(3050),"Very Low")
        lu.assertEquals(HOUND.Utils.TTS.getVerbalConfidenceLevel(4600),"Unactionable")
        lu.assertEquals(HOUND.Utils.TTS.getVerbalConfidenceLevel(5300),"Unactionable")
    end

    function TestHoundUtils:TestSimplifyDistance()
        lu.assertEquals(HOUND.Utils.TTS.simplifyDistance(150),"150 meters")
        lu.assertEquals(HOUND.Utils.TTS.simplifyDistance(499),"500 meters")
        lu.assertEquals(HOUND.Utils.TTS.simplifyDistance(501),"500 meters")
        lu.assertEquals(HOUND.Utils.TTS.simplifyDistance(970),"950 meters")
        lu.assertEquals(HOUND.Utils.TTS.simplifyDistance(976),"1.0 kilometers")
        lu.assertEquals(HOUND.Utils.TTS.simplifyDistance(1070),"1.1 kilometers")
        lu.assertEquals(HOUND.Utils.TTS.simplifyDistance(1080),"1.1 kilometers")
        lu.assertEquals(HOUND.Utils.TTS.simplifyDistance(5300),"5.3 kilometers")
    end

    function TestHoundUtils:TestTtsTime()
        lu.assertEquals(HOUND.Utils.TTS.getTtsTime(43201),"12 hundred Local")
        lu.assertEquals(HOUND.Utils.TTS.getTtsTime(30601),"08 30 Local")
        lu.assertEquals(HOUND.Utils.TTS.getTtsTime(81901),"22 45 Local")
        lu.assertEquals(HOUND.Utils.TTS.getTtsTime(90901),"01 15 Local")
    end

    function TestHoundUtils:TestToPhonetic()
        lu.assertEquals(HOUND.Utils.TTS.toPhonetic("test"),"Tango Echo Sierra Tango")
        lu.assertEquals(HOUND.Utils.TTS.toPhonetic("brooklin 99"),"Bravo Romeo Oscar Oscar Kilo Lima India November , Niner Niner")
        lu.assertEquals(HOUND.Utils.TTS.toPhonetic("TEST2"),"Tango Echo Sierra Tango Two")
    end

    function TestHoundUtils:TestGetDefaultModulation()
        lu.assertEquals(HOUND.Utils.TTS.getdefaultModulation(251),"AM")
        lu.assertEquals(HOUND.Utils.TTS.getdefaultModulation("251.5"),"AM")
        lu.assertEquals(HOUND.Utils.TTS.getdefaultModulation(35),"FM")
        lu.assertEquals(HOUND.Utils.TTS.getdefaultModulation("35.5"),"FM")
        lu.assertEquals(HOUND.Utils.TTS.getdefaultModulation(35.5*1000000),"FM")
        lu.assertEquals(HOUND.Utils.TTS.getdefaultModulation(355*1000000),"AM")
        lu.assertEquals(HOUND.Utils.TTS.getdefaultModulation("251,35.4"),"AM,FM")
        lu.assertEquals(HOUND.Utils.TTS.getdefaultModulation("35.5,2,250,bad"),"FM,FM,AM,AM")
    end

    function TestHoundUtils:TestTextGetLL()
        lu.assertEquals(HOUND.Utils.Text.getLL(33.2533333,42.1792),"N33°15'11\" E042°10'45\"")
        lu.assertEquals(HOUND.Utils.Text.getLL(33.2533333,42.1791666,true),"N33°15.200' E042°10.750'")
        lu.assertEquals(HOUND.Utils.Text.getLL(-35.443,-124.5543),"S35°26'34\" W124°33'15\"")
        lu.assertEquals(HOUND.Utils.Text.getLL(-35.443,-124.5543,true),"S35°26.580' W124°33.258'")
    end

    function TestHoundUtils:TestTextGetTime()
        lu.assertEquals(HOUND.Utils.Text.getTime(43201),"1200")
        lu.assertEquals(HOUND.Utils.Text.getTime(30601),"0830")
        lu.assertEquals(HOUND.Utils.Text.getTime(81901),"2245")
        lu.assertEquals(HOUND.Utils.Text.getTime(90901),"0115")
    end

    function TestHoundUtils:TestElintDB()
        local emitter = Unit.getByName("TOR_SAIPAN-1")
        local platform = Unit.getByName("ELINT_BLUE_C17_EAST")

        lu.assertEquals(HOUND.DB.getEmitterBand(),HOUND.DB.Bands.C)
        lu.assertEquals(HOUND.DB.getEmitterBand(emitter),HOUND.DB.Bands.F)

        local emitterData = HOUND.DB.getRadarData(emitter:getTypeName())
        lu.assertIsTable(emitterData)
        lu.assertIsTable(emitterData.Freqency)
        lu.assertIsNumber(emitterData.Freqency[true])
        lu.assertIsNumber(emitterData.Freqency[false])

        lu.assertEquals(HOUND.DB.getApertureSize(),0)
        lu.assertEquals(HOUND.DB.getApertureSize(platform),40)

        lu.assertEquals(HOUND.DB.getDefraction(), math.rad(30))

        local test_defraction = HOUND.DB.getDefraction(emitterData.Freqency[false],HOUND.DB.getApertureSize(platform))
        lu.assertIsTrue(((test_defraction > 0.00093685) and (test_defraction < 0.037786275)))

        local test_precision = HOUND.DB.getSensorPrecision(platform,emitterData.Freqency[true])
        lu.assertIsTrue(((test_precision > 0.00093685) and (test_precision < 0.037786275)))

        lu.assertIsTrue(HOUND.setContainsValue(HOUND.DB.CALLSIGNS.GENERIC,HOUND.Utils.getHoundCallsign()))
        lu.assertIsFalse(HOUND.setContainsValue(HOUND.DB.CALLSIGNS.GENERIC,HOUND.Utils.getHoundCallsign("NATO")))
        lu.assertIsTrue(HOUND.setContainsValue(HOUND.DB.CALLSIGNS.NATO,HOUND.Utils.getHoundCallsign("NATO")))
        lu.assertIsFalse(HOUND.setContainsValue(HOUND.DB.CALLSIGNS.NATO,HOUND.Utils.getHoundCallsign()))
    end

    function TestHoundUtils:TestZone()
        local zone = HOUND.Utils.Zone.getDrawnZone("Tinian Sector")
        lu.assertNotNil(zone)
        lu.assertEquals(HOUND.Length(zone),15)
        lu.assertItemsEquals(HOUND.Utils.Zone.listDrawnZones(),{"Tinian Sector"})
        local zone2 = HOUND.Utils.Zone.getGroupRoute("Sector_Saipan")
        lu.assertNotNil(zone2)
        lu.assertEquals(HOUND.Length(zone2),17)
    end

    function TestHoundUtils:TestZoneInvalid()
        lu.assertIsNil(HOUND.Utils.Zone.getDrawnZone(123))
        lu.assertIsNil(HOUND.Utils.Zone.getDrawnZone("NonexistentZone"))
        lu.assertIsNil(HOUND.Utils.Zone.getGroupRoute("NonexistentGroup"))
    end

    function TestHoundUtils:TestGetEmitterBand()
        local emitter = Unit.getByName("SA-5_SAIPAN-1")
        local band = HOUND.DB.getEmitterBand(emitter)
        lu.assertIsTable(band)
    end

    function TestHoundUtils:TestGetActiveRadarsInGroup()
        local radars = HOUND.Utils.Elint.getActiveRadarsInGroup("TOR_SAIPAN")
        lu.assertIsTable(radars)
        local bad = HOUND.Utils.Elint.getActiveRadarsInGroup(nil)
        lu.assertItemsEquals(bad,{})
        local notFound = HOUND.Utils.Elint.getActiveRadarsInGroup("NONEXISTENT_GROUP")
        lu.assertItemsEquals(notFound,{})
    end

    function TestHoundUtils:TestDcsGetGroupNamesNoPrefix()
        local groups = HOUND.Utils.Dcs.getGroupNames()
        lu.assertIsTable(groups)
        lu.assertIsTrue(HOUND.Length(groups) > 0)
    end

    function TestHoundUtils:TestCopyPointXY()
        local p = {x=100,y=200}
        local copy = HOUND.Utils.Dcs.copyPoint(p)
        lu.assertItemsEquals(copy, {x=100, y=0, z=200})
    end

    function TestHoundUtils:TestGeoSetPointHeight()
        local pt = {x=400000,z=2000000}
        local result = HOUND.Utils.Geo.setPointHeight(pt,0)
        if result.y then
            lu.assertIsNumber(result.y)
        end
    end

    function TestHoundUtils:TestGeoSetPointHeightWithOffset()
        local pt = {x=400000,z=2000000}
        local result = HOUND.Utils.Geo.setPointHeight(pt,50)
        if result.y then
            lu.assertIsNumber(result.y)
        end
    end

    function TestHoundUtils:TestGeoSetHeight()
        local pts = {
            {x=400000,z=2000000},
            {x=401000,z=2001000}
        }
        local result = HOUND.Utils.Geo.setHeight(pts)
        lu.assertIsTable(result)
    end

    function TestHoundUtils:TestGeoSetHeightSingle()
        local pt = {x=400000,z=2000000}
        local result = HOUND.Utils.Geo.setHeight(pt)
        if result.y then
            lu.assertIsNumber(result.y)
        end
    end

    function TestHoundUtils:TestGeoSetHeightNonPoint()
        lu.assertEquals(HOUND.Utils.Geo.setHeight("string"),"string")
    end

    function TestHoundUtils:TestDcsIsRadarTracking()
        local tor = Unit.getByName("TOR_SAIPAN-1")
        local tracking = HOUND.Utils.Dcs.isRadarTracking(tor)
        lu.assertIsFalse(tracking)
        local bad = HOUND.Utils.Dcs.isRadarTracking(nil)
        lu.assertIsFalse(bad)
    end

    function TestHoundUtils:TestDcsGetPlayersInvalid()
        lu.assertItemsEquals(HOUND.Utils.Dcs.getPlayers(nil),{})
        lu.assertItemsEquals(HOUND.Utils.Dcs.getPlayers(-1),{})
        lu.assertItemsEquals(HOUND.Utils.Dcs.getPlayers(5),{})
    end

    function TestHoundUtils:TestDcsIsHuman()
        local tor = Unit.getByName("TOR_SAIPAN-1")
        lu.assertIsFalse(HOUND.Utils.Dcs.isHuman(tor))
        lu.assertIsFalse(HOUND.Utils.Dcs.isHuman(nil))
        lu.assertIsFalse(HOUND.Utils.Dcs.isHuman("string"))
    end

    function TestHoundUtils:TestDcsGetPlayersInGroupInvalid()
        lu.assertItemsEquals(HOUND.Utils.Dcs.getPlayersInGroup(nil),{})
        lu.assertItemsEquals(HOUND.Utils.Dcs.getPlayersInGroup("NONEXISTENT"),{})
    end

    function TestHoundUtils:TestTTSGetVerbalLLVariants()
        local str = HOUND.Utils.TTS.getVerbalLL(35.443,-124.5543,false)
        lu.assertIsString(str)
        lu.assertStrContains(str,"seconds")

        local str2 = HOUND.Utils.TTS.getVerbalLL(35.443,-124.5543,true)
        lu.assertIsString(str2)
        lu.assertStrContains(str2,"Decimal")
    end

    function TestHoundUtils:TestTTSGetVerbalContactAgeEdge()
        local now = timer.getAbsTime()
        local result = HOUND.Utils.TTS.getVerbalContactAge(now-1)
        lu.assertEquals(result,"1 seconds")
    end

    function TestHoundUtils:TestTTSGetVerbalConfidenceEdge()
        lu.assertEquals(HOUND.Utils.TTS.getVerbalConfidenceLevel(0),"Very High")
        lu.assertEquals(HOUND.Utils.TTS.getVerbalConfidenceLevel(5010),"Unactionable")
    end

    function TestHoundUtils:TestHoundSetContainsValue()
        local t = {10,20,30}
        lu.assertIsTrue(HOUND.setContainsValue(t,10))
        lu.assertIsFalse(HOUND.setContainsValue(t,40))
        lu.assertIsFalse(HOUND.setContainsValue(nil,10))
        lu.assertIsFalse(HOUND.setContainsValue(t,nil))
    end

    function TestHoundUtils:TestHoundSetContains()
        local t = {a=1,b=2}
        lu.assertIsTrue(HOUND.setContains(t,"a"))
        lu.assertIsFalse(HOUND.setContains(t,"c"))
        lu.assertIsFalse(HOUND.setContains(nil,"a"))
        lu.assertIsFalse(HOUND.setContains(t,nil))
    end

    function TestHoundUtils:TestHoundShallowCopy()
        local orig = {a=1,b=2,c={nested=true}}
        local copy = HOUND.shallowCopy(orig)
        lu.assertEquals(copy.a,1)
        lu.assertEquals(copy.b,2)
        copy.a = 999
        lu.assertEquals(orig.a,1)
        lu.assertIsNil(HOUND.shallowCopy(nil).a)
        lu.assertIsNil(HOUND.shallowCopy("string").a)
    end

    function TestHoundUtils:TestHoundSetIntersection()
        local a = {alpha=true,beta=true,gamma=true}
        local b = {beta=true,gamma=true,delta=true}
        local result = HOUND.setIntersection(a,b)
        lu.assertIsTrue(result.beta)
        lu.assertIsTrue(result.gamma)
        lu.assertIsNil(result.alpha)
        lu.assertIsNil(result.delta)
    end

    function TestHoundUtils:TestHoundLength()
        lu.assertEquals(HOUND.Length({a=1,b=2,c=3}),3)
        lu.assertEquals(HOUND.Length({}),0)
        lu.assertEquals(HOUND.Length(nil),0)
    end

    function TestHoundUtils:TestHoundReverseLookup()
        local t = {alpha=1,beta=2,gamma=3}
        lu.assertEquals(HOUND.reverseLookup(t,1),"alpha")
        lu.assertEquals(HOUND.reverseLookup(t,2),"beta")
        lu.assertIsNil(HOUND.reverseLookup(t,99))
        lu.assertIsNil(HOUND.reverseLookup(nil,1))
    end

    function TestHoundUtils:TestHoundGaussian()
        local v1 = HOUND.Gaussian(0,1)
        local v2 = HOUND.Gaussian(0,1)
        lu.assertIsNumber(v1)
        lu.assertIsNumber(v2)
    end

    function TestHoundUtils:TestHoundClamp()
        lu.assertEquals(HOUND.Clamp(5,0,10),5)
        lu.assertEquals(HOUND.Clamp(-1,0,10),0)
        lu.assertEquals(HOUND.Clamp(15,0,10),10)
    end

    function TestHoundUtils:TestHoundMixedGaussian()
        local v = HOUND.MixedGaussian(0,1,0.5)
        lu.assertIsNumber(v)
    end

    function TestHoundUtils:TestStringSplit()
        local result = string.split("a,b,c",",")
        lu.assertItemsEquals(result,{"a","b","c"})
        local result2 = string.split("hello world")
        lu.assertItemsEquals(result2,{" "})
    end

    function TestHoundUtils:TestHoundSetMgrsPresicion()
        HOUND.setMgrsPresicion(3)
        lu.assertEquals(HOUND.MGRS_PRECISION,1)
    end

    function TestHoundUtils:TestHoundShowExtendedInfo()
        HOUND.showExtendedInfo(true)
        lu.assertIsTrue(HOUND.EXTENDED_INFO)
        HOUND.showExtendedInfo(false)
        lu.assertIsFalse(HOUND.EXTENDED_INFO)
        HOUND.showExtendedInfo("string")
        lu.assertIsFalse(HOUND.EXTENDED_INFO)
    end

    function TestHoundUtils:TestHoundGetInstance()
        lu.assertIsNil(HOUND.getInstance(9999))
    end

    function TestHoundUtils:TestGetHoundCallsign()
        local callsign = HOUND.Utils.getHoundCallsign()
        lu.assertIsString(callsign)
        local nato = HOUND.Utils.getHoundCallsign("NATO")
        lu.assertIsString(nato)
    end

    function TestHoundUtils:TestTTSAvailable()
        local avail = HOUND.Utils.TTS.isAvailable()
        lu.assertIsBoolean(avail)
    end

    function TestHoundUtils:TestGetDefaultModulationFallback()
        lu.assertEquals(HOUND.Utils.TTS.getdefaultModulation(nil),"AM")
        lu.assertEquals(HOUND.Utils.TTS.getdefaultModulation("not_a_number"),"AM")
    end
    function TestHoundUtils:TestThreatOnSectorInvalidPolygon()
        local square = {{x=0,z=0},{x=100,z=0},{x=100,z=100},{x=0,z=100}}
        lu.assertIsNil(HOUND.Utils.Polygon.threatOnSector(nil, {x=50,z=50}))
        lu.assertIsNil(HOUND.Utils.Polygon.threatOnSector("bad", {x=50,z=50}))
        lu.assertIsNil(HOUND.Utils.Polygon.threatOnSector({{x=0,z=0}}, {x=50,z=50}))
        lu.assertIsNil(HOUND.Utils.Polygon.threatOnSector({{x=0,z=0},{x=100,z=0}}, {x=50,z=50}))
    end

    function TestHoundUtils:TestThreatOnSectorInvalidPoint()
        local square = {{x=0,z=0},{x=100,z=0},{x=100,z=100},{x=0,z=100}}
        lu.assertIsNil(HOUND.Utils.Polygon.threatOnSector(square, nil))
        lu.assertIsNil(HOUND.Utils.Polygon.threatOnSector(square, "bad"))
    end

    function TestHoundUtils:TestThreatOnSectorInside()
        local square = {{x=0,z=0},{x=100,z=0},{x=100,z=100},{x=0,z=100}}
        local inside = {x=50,z=50}
        local inPoly, intPoly = HOUND.Utils.Polygon.threatOnSector(square, inside)
        if inPoly ~= nil then
            lu.assertIsBoolean(inPoly)
            lu.assertIsBoolean(intPoly)
        end
    end

    function TestHoundUtils:TestThreatOnSectorOutside()
        local square = {{x=0,z=0},{x=100,z=0},{x=100,z=100},{x=0,z=100}}
        local outside = {x=200,z=200}
        local inPoly, intPoly = HOUND.Utils.Polygon.threatOnSector(square, outside)
        if inPoly ~= nil then
            lu.assertIsBoolean(inPoly)
            lu.assertIsBoolean(intPoly)
        end
    end

    function TestHoundUtils:TestThreatOnSectorWithRadius()
        local square = {{x=0,y=0,z=0},{x=100,y=0,z=0},{x=100,y=0,z=100},{x=0,y=0,z=100}}
        local nearEdge = {x=110,y=0,z=50}
        local inPoly, intPoly = HOUND.Utils.Polygon.threatOnSector(square, nearEdge, 20)
        if inPoly ~= nil then
            lu.assertIsBoolean(inPoly)
            lu.assertIsBoolean(intPoly)
        end
    end

    function TestHoundUtils:TestAzMinMaxInvalidRef()
        local poly = {{x=0,z=0},{x=100,z=0},{x=100,z=100},{x=0,z=100}}
        lu.assertIsNil(HOUND.Utils.Polygon.azMinMax(poly, nil))
        lu.assertIsNil(HOUND.Utils.Polygon.azMinMax(poly, {}))
    end

    function TestHoundUtils:TestAzMinMaxInvalidPoly()
        local refPos = {x=200,z=200}
        lu.assertIsNil(HOUND.Utils.Polygon.azMinMax(nil, refPos))
        lu.assertIsNil(HOUND.Utils.Polygon.azMinMax("bad", refPos))
        lu.assertIsNil(HOUND.Utils.Polygon.azMinMax({{x=0,z=0}}, refPos))
    end

    function TestHoundUtils:TestAzMinMaxRefInside()
        local poly = {{x=0,z=0},{x=100,z=0},{x=100,z=100},{x=0,z=100}}
        local inside = {x=50,z=50}
        local deltaMinMax = HOUND.Utils.Polygon.azMinMax(poly, inside)
        if deltaMinMax ~= nil then
            lu.assertIsNumber(deltaMinMax)
        end
    end

    function TestHoundUtils:TestAzMinMaxValid()
        local poly = {{x=0,y=0,z=0},{x=100,y=0,z=0},{x=100,y=0,z=100},{x=0,y=0,z=100}}
        local outside = {x=200,y=0,z=200}
        local deltaMinMax, minAz, maxAz = HOUND.Utils.Polygon.azMinMax(poly, outside)
        if deltaMinMax ~= nil then
            lu.assertIsNumber(deltaMinMax)
            lu.assertIsNumber(minAz.refAz)
            lu.assertIsNumber(maxAz.refAz)
        end
    end

    function TestHoundUtils:TestGetDeltaSubsetPercent()
        local points = {
            {x=0,y=0,z=0,score=1},
            {x=100,y=0,z=0,score=1},
            {x=50,y=0,z=50,score=1}
        }
        local subset = HOUND.Utils.Cluster.getDeltaSubsetPercent(points, nil, 0.6)
        lu.assertIsTable(subset)
        local refPos = {x=0,y=0,z=0}
        local relative = HOUND.Utils.Cluster.getDeltaSubsetPercent(points, refPos, 0.6, true)
        lu.assertIsTable(relative)
    end

    function TestHoundUtils:TestGetDeltaSubsetPercentEmpty()
        local subset = HOUND.Utils.Cluster.getDeltaSubsetPercent({}, nil, 0.6)
        lu.assertIsTable(subset)
        lu.assertEquals(#subset, 0)
    end

    function TestHoundUtils:TestGetDeltaSubsetPercentSingle()
        local points = {{x=42,y=0,z=42,score=1}}
        local subset = HOUND.Utils.Cluster.getDeltaSubsetPercent(points, nil, 0.6)
        lu.assertIsTable(subset)
        lu.assertEquals(#subset, 1)
        lu.assertEquals(subset[1].x, 42)
        lu.assertEquals(subset[1].z, 42)
    end

    function TestHoundUtils:TestWeightedCentroid()
        local points = {
            {x=0,z=0,score=1},
            {x=100,z=0,score=1},
            {x=0,z=100,score=1}
        }
        local est = HOUND.Utils.Cluster.WeightedCentroid(points)
        lu.assertIsNumber(est.x)
        lu.assertIsNumber(est.z)
        lu.assertIsNumber(est.y)
    end

    function TestHoundUtils:TestWeightedCentroidNoScores()
        local points = {
            {x=100,z=100,score=0},
            {x=200,z=200,score=-1}
        }
        local est = HOUND.Utils.Cluster.WeightedCentroid(points)
        lu.assertEquals(est.x, 0)
        lu.assertEquals(est.z, 0)
        lu.assertIsNumber(est.y)
    end

    function TestHoundUtils:TestWeightedCentroidEmpty()
        local est = HOUND.Utils.Cluster.WeightedCentroid({})
        lu.assertEquals(est.x, 0)
        lu.assertEquals(est.z, 0)
        lu.assertIsNumber(est.y)
    end

    function TestHoundUtils:tearDown()
    end
end
