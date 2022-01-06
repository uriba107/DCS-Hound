do
    TestHoundUtils = {}

    function TestHoundUtils:setUp()
    end
    function TestHoundUtils:TestabsTimeDelta()
        local baseTime = timer.getAbsTime()
        local delta = 10

        lu.assertEquals(HoundUtils.absTimeDelta(baseTime,baseTime+delta),delta)        
    end
    function TestHoundUtils:TestangleDeltaRad()
        lu.assertIsNil(HoundUtils.angleDeltaRad())
        lu.assertAlmostEquals(HoundUtils.angleDeltaRad(math.rad(45),math.rad(45)+math.rad(90)),math.rad(90),0.0001)
        lu.assertAlmostEquals(HoundUtils.angleDeltaRad(math.rad(315),math.rad(45)),math.rad(90),0.0001)
        lu.assertAlmostEquals(HoundUtils.angleDeltaRad(math.rad(45),math.rad(315)),math.rad(90),0.0001)
        lu.assertAlmostEquals(HoundUtils.angleDeltaRad(math.rad(80),math.rad(190)),math.rad(110),0.0001)
        lu.assertAlmostEquals(HoundUtils.angleDeltaRad(math.rad(270),math.rad(210)),math.rad(60),0.0001)
    end
    function TestHoundUtils:TestAzimuthAverage()
        lu.assertAlmostEquals(HoundUtils.AzimuthAverage({math.rad(90),math.rad(30)}),math.rad(60),0.0001)
        lu.assertAlmostEquals(HoundUtils.AzimuthAverage({math.rad(90),math.rad(30),math.rad(180),math.rad(150),math.rad(0)}),math.rad(90),0.0001)

        lu.assertAlmostEquals(HoundUtils.AzimuthAverage({math.rad(315),math.rad(335)}),math.rad(325),0.0001)
        lu.assertAlmostEquals(HoundUtils.AzimuthAverage({math.rad(350),math.rad(10)}),math.rad(0),0.0001)
        -- lu.assertAlmostEquals(HoundUtils.AzimuthAverage({math.rad(315),math.rad(330),math.rad(45),math.rad(30),math.rad(350)}),math.rad(350),0.0001)

    end
    function TestHoundUtils:TestRandomAngle()
        lu.assertNotEquals(HoundUtils.RandomAngle(),HoundUtils.RandomAngle())
        local val = HoundUtils.RandomAngle()
        lu.assertIsTrue( ((val <= math.pi*2 ) and (val >= 0)))
    end
    function TestHoundUtils:TestgetSamMaxRange()
    end

    function TestHoundUtils:TestgetRadarDetectionRange()
    end
    function TestHoundUtils:TestgetRoundedElevationFt()
        lu.assertEquals(HoundUtils.getRoundedElevationFt(50),150)
        lu.assertEquals(HoundUtils.getRoundedElevationFt(250),800)
        lu.assertEquals(HoundUtils.getRoundedElevationFt(500),1650)
        lu.assertEquals(HoundUtils.getRoundedElevationFt(1000),3300)
        lu.assertEquals(HoundUtils.getRoundedElevationFt(1500),4900)
        lu.assertEquals(HoundUtils.getRoundedElevationFt(5000),16400)
        lu.assertEquals(HoundUtils.getRoundedElevationFt(8848),29050)
    end
    function TestHoundUtils:TestroundToNearest()
        lu.assertEquals(HoundUtils.roundToNearest(3213,1000),3000)
        lu.assertEquals(HoundUtils.roundToNearest(3213,500),3000)
        lu.assertEquals(HoundUtils.roundToNearest(3213,100),3200)
        lu.assertEquals(HoundUtils.roundToNearest(3213,50),3200)
        lu.assertEquals(HoundUtils.roundToNearest(3213,10),3210)
        lu.assertEquals(HoundUtils.roundToNearest(3213,5),3215)
        lu.assertEquals(HoundUtils.roundToNearest(14730,1000),15000)
        lu.assertEquals(HoundUtils.roundToNearest(14730,500),14500)
        lu.assertEquals(HoundUtils.roundToNearest(14730,100),14700)
        lu.assertEquals(HoundUtils.roundToNearest(14730,50),14750)
        lu.assertEquals(HoundUtils.roundToNearest(14730,10),14730)
        lu.assertEquals(HoundUtils.roundToNearest(14730,5),14730)
    end
    function TestHoundUtils:TestgetReportId()
        local str,char = HoundUtils.getReportId('C')
        lu.assertEquals(char,'D')
        lu.assertEquals(str,'Delta')
        lu.assertEquals(str,HoundDB.PHONETICS[char])

        str,char = HoundUtils.getReportId('Z')
        lu.assertEquals(char,'A')
        lu.assertEquals(str,'Alpha')
        lu.assertEquals(str,HoundDB.PHONETICS[char])

        str,char = HoundUtils.getReportId('Y')
        lu.assertEquals(char,'Z')
        lu.assertEquals(str,'Zulu')
        lu.assertEquals(str,HoundDB.PHONETICS[char])
    end
    function TestHoundUtils:TestDecToDMS()
        lu.assertItemsEquals(HoundUtils.DecToDMS(35.443),{d=35,m=26,s=34,mDec=26.580,sDec=580})
        lu.assertItemsEquals(HoundUtils.DecToDMS(-124.5543),{d=-124,m=33,s=15,mDec=33.258,sDec=258})

        lu.assertItemsEquals(HoundUtils.getHemispheres(35.443,-124.5543),{NS="N",EW="W"})
        lu.assertItemsEquals(HoundUtils.getHemispheres(35.443,-124.5543,true),{NS="North",EW="West"}) 
    end

    function TestHoundUtils:TestgetBR()
        
    end

    function TestHoundUtils:TestLOS()
        
    end

    function TestHoundUtils:TestTTS()
        -- HoundUtils.TTS.toPhonetic
        lu.assertEquals(HoundUtils.TTS.toPhonetic("test"),"Tango Echo Sierra Tango")
        lu.assertEquals(HoundUtils.TTS.toPhonetic("brooklin 99"),"Bravo Romeo Oscar Oscar Kilo Lima India November , Niner Niner")
        lu.assertEquals(HoundUtils.TTS.toPhonetic("TEST2"),"Tango Echo Sierra Tango Two")

        -- HoundUtils.TTS.getTtsTime
        lu.assertEquals(HoundUtils.TTS.getTtsTime(43201),"12 hundred Local")
        lu.assertEquals(HoundUtils.TTS.getTtsTime(30601),"08 30 Local")
        lu.assertEquals(HoundUtils.TTS.getTtsTime(81901),"22 45 Local")
        lu.assertEquals(HoundUtils.TTS.getTtsTime(90901),"01 15 Local")

        -- HoundUtils.TTS.getVerbalConfidenceLevel
        lu.assertEquals(HoundUtils.TTS.getVerbalConfidenceLevel(150),"Very High")
        lu.assertEquals(HoundUtils.TTS.getVerbalConfidenceLevel(499),"Very High")
        lu.assertEquals(HoundUtils.TTS.getVerbalConfidenceLevel(500),"High")
        lu.assertEquals(HoundUtils.TTS.getVerbalConfidenceLevel(501),"High")
        lu.assertEquals(HoundUtils.TTS.getVerbalConfidenceLevel(1000),"Medium")
        lu.assertEquals(HoundUtils.TTS.getVerbalConfidenceLevel(1900),"Low")
        lu.assertEquals(HoundUtils.TTS.getVerbalConfidenceLevel(2200),"Low")
        lu.assertEquals(HoundUtils.TTS.getVerbalConfidenceLevel(2600),"Very Low")
        lu.assertEquals(HoundUtils.TTS.getVerbalConfidenceLevel(3050),"Very Low")
        lu.assertEquals(HoundUtils.TTS.getVerbalConfidenceLevel(4600),"Unactionable")
        lu.assertEquals(HoundUtils.TTS.getVerbalConfidenceLevel(5300),"Unactionable")

        -- HoundUtils.TTS.getVerbalContactAge
        local testTime = timer.getAbsTime()
        lu.assertEquals(HoundUtils.TTS.getVerbalContactAge(testTime-10,true),"Active")
        lu.assertEquals(HoundUtils.TTS.getVerbalContactAge(testTime-80,true),"very recent")
        lu.assertEquals(HoundUtils.TTS.getVerbalContactAge(testTime-179,true),"recent")
        lu.assertEquals(HoundUtils.TTS.getVerbalContactAge(testTime-290,true),"relevant")
        lu.assertEquals(HoundUtils.TTS.getVerbalContactAge(testTime-600,true),"stale")

        lu.assertEquals(HoundUtils.TTS.getVerbalContactAge(testTime-5,true,true),"Active")
        lu.assertEquals(HoundUtils.TTS.getVerbalContactAge(testTime-60,true,true),"Awake")

        lu.assertEquals(HoundUtils.TTS.getVerbalContactAge(testTime-5),"5 seconds")
        lu.assertEquals(HoundUtils.TTS.getVerbalContactAge(testTime-65),"1 minutes")
        lu.assertEquals(HoundUtils.TTS.getVerbalContactAge(testTime-301),"5 minutes")
        lu.assertEquals(HoundUtils.TTS.getVerbalContactAge(testTime-901),"15 minutes")
        lu.assertEquals(HoundUtils.TTS.getVerbalContactAge(testTime-(1.5*3600+1)),"90 minutes")
        lu.assertEquals(HoundUtils.TTS.getVerbalContactAge(testTime-(4.75*3600+1)),"4 hours, 45 minutes")
        lu.assertEquals(HoundUtils.TTS.getVerbalContactAge(testTime-(15*3600+1)),"15 hours, 0 minutes")

        -- HoundUtils.TTS.getVerbalLL
        lu.assertEquals(HoundUtils.TTS.getVerbalLL(35.443,-124.5543),"North, 35 degrees, 26 minutes, 34 seconds, West, 124 degrees, 33 minutes, 15 seconds")
        lu.assertEquals(HoundUtils.TTS.getVerbalLL(35.443,-124.5543,true),"North, 35 degrees, 26, Decimal Five Eight Zero minutes, West, 124 degrees, 33, Decimal Two Five Eight minutes")
        lu.assertEquals(HoundUtils.TTS.getVerbalLL(35.443,37.5543),"North, 35 degrees, 26 minutes, 34 seconds, East, 037 degrees, 33 minutes, 15 seconds")
        lu.assertEquals(HoundUtils.TTS.getVerbalLL(-35.443,37.5543,false),"South, 35 degrees, 26 minutes, 34 seconds, East, 037 degrees, 33 minutes, 15 seconds")
        lu.assertEquals(HoundUtils.TTS.getVerbalLL(-35.443,37.5543,true),"South, 35 degrees, 26, Decimal Five Eight Zero minutes, East, 037 degrees, 33, Decimal Two Five Eight minutes")

        -- HoundUtils.TTS.simplfyDistance
        lu.assertEquals(HoundUtils.TTS.simplfyDistance(150),"150 meters")
        lu.assertEquals(HoundUtils.TTS.simplfyDistance(499),"500 meters")
        lu.assertEquals(HoundUtils.TTS.simplfyDistance(501),"500 meters")
        lu.assertEquals(HoundUtils.TTS.simplfyDistance(970),"950 meters")
        lu.assertEquals(HoundUtils.TTS.simplfyDistance(976),"1.0 kilometers")
        lu.assertEquals(HoundUtils.TTS.simplfyDistance(1070),"1.1 kilometers")
        lu.assertEquals(HoundUtils.TTS.simplfyDistance(1080),"1.1 kilometers")
        lu.assertEquals(HoundUtils.TTS.simplfyDistance(5300),"5.3 kilometers")
    end

    function TestHoundUtils:TestText()
        -- HoundUtils.Text.getLL
        lu.assertEquals(HoundUtils.Text.getLL(33.2533333,42.1792),"N33°15'11\" E42°10'45\"")
        lu.assertEquals(HoundUtils.Text.getLL(33.2533333,42.1791666,true),"N33°15.200' E42°10.750'")
        lu.assertEquals(HoundUtils.Text.getLL(-35.443,-124.5543),"S35°26'34\" W124°33'15\"")
        lu.assertEquals(HoundUtils.Text.getLL(-35.443,-124.5543,true),"S35°26.580' W124°33.258'")

        --  HoundUtils.Text.getTime
        lu.assertEquals(HoundUtils.Text.getTime(43201),"1200")
        lu.assertEquals(HoundUtils.Text.getTime(30601),"0830")
        lu.assertEquals(HoundUtils.Text.getTime(81901),"2245")
        lu.assertEquals(HoundUtils.Text.getTime(90901),"0115")
    end

    function TestHoundUtils:TestElint()
        local emitter = Unit.getByName("TOR_SAIPAN-1")
        local platform = Unit.getByName("ELINT_BLUE_C17_EAST")

        -- HoundUtils.Elint.getEmitterBand
        lu.assertEquals(HoundUtils.Elint.getEmitterBand(),'C')
        lu.assertEquals(HoundUtils.Elint.getEmitterBand(emitter),'F')

        -- HoundUtils.Elint.getApertureSize
        lu.assertEquals(HoundUtils.Elint.getApertureSize(),0)
        lu.assertEquals(HoundUtils.Elint.getApertureSize(platform),50)

        -- HoundUtils.Elint.getDefraction
        lu.assertEquals(HoundUtils.Elint.getDefraction(), math.rad(30))
        lu.assertEquals(HoundUtils.Elint.getDefraction(HoundUtils.Elint.getEmitterBand(emitter),HoundUtils.Elint.getApertureSize(platform)),0.0017131)

        -- HoundUtils.Elint.getSensorPrecision
        lu.assertEquals(HoundUtils.Elint.getSensorPrecision(platform,HoundUtils.Elint.getEmitterBand(emitter)),0.0017131)
        -- HoundUtils.Elint.generateAngularError

        -- HoundUtils.Elint.getAzimuth

        -- HoundUtils.getHoundCallsign
        lu.assertIsTrue(setContainsValue(HoundDB.CALLSIGNS.GENERIC,HoundUtils.getHoundCallsign()))
        lu.assertIsFalse(setContainsValue(HoundDB.CALLSIGNS.GENERIC,HoundUtils.getHoundCallsign("NATO")))
        lu.assertIsTrue(setContainsValue(HoundDB.CALLSIGNS.NATO,HoundUtils.getHoundCallsign("NATO")))
        lu.assertIsFalse(setContainsValue(HoundDB.CALLSIGNS.NATO,HoundUtils.getHoundCallsign()))
    end

    function TestHoundUtils:TestPolygon()
        -- HoundUtils.Polygon.isDcsPoint
        lu.assertIsFalse(HoundUtils.Polygon.isDcsPoint("somethign"))
        lu.assertIsFalse(HoundUtils.Polygon.isDcsPoint(true))
        lu.assertIsFalse(HoundUtils.Polygon.isDcsPoint({"assd","asdf"}))
        lu.assertIsFalse(HoundUtils.Polygon.isDcsPoint({x="asdf",z="asdf"}))
        lu.assertIsFalse(HoundUtils.Polygon.isDcsPoint({x="123123",z="123123"}))
        lu.assertIsTrue(HoundUtils.Polygon.isDcsPoint({x=12345,z=67890}))

    end

    function TestHoundUtils:TestVector()
    end

    function TestHoundUtils:TestZone()

        local zone = HoundUtils.Zone.getDrawnZone("Tinian Sector")
        lu.assertNotNil(zone)
        lu.assertEquals(Length(zone),15)
        -- lu.assertItemsEquals(zone[1],zone[Length(zone)])

        lu.assertItemsEquals(HoundUtils.Zone.listDrawnZones(),{"Tinian Sector"})

    end

    function TestHoundUtils:tearDown()
    end
end