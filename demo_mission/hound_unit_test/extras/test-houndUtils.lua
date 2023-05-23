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
        -- lu.assertAlmostEquals(HOUND.Utils.AzimuthAverage({math.rad(315),math.rad(330),math.rad(45),math.rad(30),math.rad(350)}),math.rad(350),0.0001)

    end
    function TestHoundUtils:TestRandomAngle()
        lu.assertNotEquals(HOUND.Utils.RandomAngle(),HOUND.Utils.RandomAngle())
        local val = HOUND.Utils.RandomAngle()
        lu.assertIsTrue( ((val <= math.pi*2 ) and (val >= 0)))
    end
    function TestHoundUtils:TestgetSamMaxRange()
    end

    function TestHoundUtils:TestgetRadarDetectionRange()
    end
    function TestHoundUtils:TestgetRoundedElevationFt()
        lu.assertEquals(HOUND.Utils.getRoundedElevationFt(50),150)
        lu.assertEquals(HOUND.Utils.getRoundedElevationFt(250),800)
        lu.assertEquals(HOUND.Utils.getRoundedElevationFt(500),1650)
        lu.assertEquals(HOUND.Utils.getRoundedElevationFt(1000),3300)
        lu.assertEquals(HOUND.Utils.getRoundedElevationFt(1500),4900)
        lu.assertEquals(HOUND.Utils.getRoundedElevationFt(5000),16400)
        lu.assertEquals(HOUND.Utils.getRoundedElevationFt(8848),29050)
    end
    function TestHoundUtils:TestroundToNearest()
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
    function TestHoundUtils:TestgetReportId()
        local str,char = HOUND.Utils.getReportId('C')
        lu.assertEquals(char,'D')
        lu.assertEquals(str,'Delta')
        lu.assertEquals(str,HOUND.DB.PHONETICS[char])

        str,char = HOUND.Utils.getReportId('Z')
        lu.assertEquals(char,'A')
        lu.assertEquals(str,'Alpha')
        lu.assertEquals(str,HOUND.DB.PHONETICS[char])

        str,char = HOUND.Utils.getReportId('Y')
        lu.assertEquals(char,'Z')
        lu.assertEquals(str,'Zulu')
        lu.assertEquals(str,HOUND.DB.PHONETICS[char])
    end
    function TestHoundUtils:TestDecToDMS()
        lu.assertItemsEquals(HOUND.Utils.DecToDMS(35.443),{d=35,m=26,s=34,mDec=26.580,sDec=580})
        lu.assertItemsEquals(HOUND.Utils.DecToDMS(-124.5543),{d=-124,m=33,s=15,mDec=33.258,sDec=258})

        lu.assertItemsEquals(HOUND.Utils.getHemispheres(35.443,-124.5543),{NS="N",EW="W"})
        lu.assertItemsEquals(HOUND.Utils.getHemispheres(35.443,-124.5543,true),{NS="North",EW="West"}) 
    end

    function TestHoundUtils:TestgetBR()
        
    end

    function TestHoundUtils:TestGeo()
        -- HOUND.Utils.Dcs.isPoint
        lu.assertIsFalse(HOUND.Utils.Dcs.isPoint("somethign"))
        lu.assertIsFalse(HOUND.Utils.Dcs.isPoint(true))
        lu.assertIsFalse(HOUND.Utils.Dcs.isPoint({"assd","asdf"}))
        lu.assertIsFalse(HOUND.Utils.Dcs.isPoint({x="asdf",z="asdf"}))
        lu.assertIsFalse(HOUND.Utils.Dcs.isPoint({x="123123",z="123123"}))
        lu.assertIsTrue(HOUND.Utils.Dcs.isPoint({x=12345,z=67890}))
    end

    function TestHoundUtils:TestTTS()
        -- HOUND.Utils.TTS.getdefaultModulation
        lu.assertEquals(HOUND.Utils.TTS.getdefaultModulation(251),"AM")
        lu.assertEquals(HOUND.Utils.TTS.getdefaultModulation("251.5"),"AM")
        lu.assertEquals(HOUND.Utils.TTS.getdefaultModulation(35),"FM")
        lu.assertEquals(HOUND.Utils.TTS.getdefaultModulation("35.5"),"FM")
        lu.assertEquals(HOUND.Utils.TTS.getdefaultModulation(35.5*1000000),"FM")
        lu.assertEquals(HOUND.Utils.TTS.getdefaultModulation(355*1000000),"AM")
        lu.assertEquals(HOUND.Utils.TTS.getdefaultModulation("251,35.4"),"AM,FM")
        lu.assertEquals(HOUND.Utils.TTS.getdefaultModulation("35.5,2,250,bad"),"FM,FM,AM,AM")

        -- HOUND.Utils.TTS.toPhonetic
        lu.assertEquals(HOUND.Utils.TTS.toPhonetic("test"),"Tango Echo Sierra Tango")
        lu.assertEquals(HOUND.Utils.TTS.toPhonetic("brooklin 99"),"Bravo Romeo Oscar Oscar Kilo Lima India November , Niner Niner")
        lu.assertEquals(HOUND.Utils.TTS.toPhonetic("TEST2"),"Tango Echo Sierra Tango Two")

        -- HOUND.Utils.TTS.getTtsTime
        lu.assertEquals(HOUND.Utils.TTS.getTtsTime(43201),"12 hundred Local")
        lu.assertEquals(HOUND.Utils.TTS.getTtsTime(30601),"08 30 Local")
        lu.assertEquals(HOUND.Utils.TTS.getTtsTime(81901),"22 45 Local")
        lu.assertEquals(HOUND.Utils.TTS.getTtsTime(90901),"01 15 Local")

        -- HOUND.Utils.TTS.getVerbalConfidenceLevel
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

        -- HOUND.Utils.TTS.getVerbalContactAge
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

        -- HOUND.Utils.TTS.getVerbalLL
        lu.assertEquals(HOUND.Utils.TTS.getVerbalLL(35.443,-124.5543),"North, 35 degrees, 26 minutes, 34 seconds, West, 124 degrees, 33 minutes, 15 seconds")
        lu.assertEquals(HOUND.Utils.TTS.getVerbalLL(35.443,-124.5543,true),"North, 35 degrees, 26, Decimal Five Eight Zero minutes, West, 124 degrees, 33, Decimal Two Five Eight minutes")
        lu.assertEquals(HOUND.Utils.TTS.getVerbalLL(35.443,37.5543),"North, 35 degrees, 26 minutes, 34 seconds, East, 037 degrees, 33 minutes, 15 seconds")
        lu.assertEquals(HOUND.Utils.TTS.getVerbalLL(-35.443,37.5543,false),"South, 35 degrees, 26 minutes, 34 seconds, East, 037 degrees, 33 minutes, 15 seconds")
        lu.assertEquals(HOUND.Utils.TTS.getVerbalLL(-35.443,37.5543,true),"South, 35 degrees, 26, Decimal Five Eight Zero minutes, East, 037 degrees, 33, Decimal Two Five Eight minutes")

        -- HOUND.Utils.TTS.simplfyDistance
        lu.assertEquals(HOUND.Utils.TTS.simplfyDistance(150),"150 meters")
        lu.assertEquals(HOUND.Utils.TTS.simplfyDistance(499),"500 meters")
        lu.assertEquals(HOUND.Utils.TTS.simplfyDistance(501),"500 meters")
        lu.assertEquals(HOUND.Utils.TTS.simplfyDistance(970),"950 meters")
        lu.assertEquals(HOUND.Utils.TTS.simplfyDistance(976),"1.0 kilometers")
        lu.assertEquals(HOUND.Utils.TTS.simplfyDistance(1070),"1.1 kilometers")
        lu.assertEquals(HOUND.Utils.TTS.simplfyDistance(1080),"1.1 kilometers")
        lu.assertEquals(HOUND.Utils.TTS.simplfyDistance(5300),"5.3 kilometers")
    end

    function TestHoundUtils:TestText()
        -- HOUND.Utils.Text.getLL
        lu.assertEquals(HOUND.Utils.Text.getLL(33.2533333,42.1792),"N33°15'11\" E42°10'45\"")
        lu.assertEquals(HOUND.Utils.Text.getLL(33.2533333,42.1791666,true),"N33°15.200' E42°10.750'")
        lu.assertEquals(HOUND.Utils.Text.getLL(-35.443,-124.5543),"S35°26'34\" W124°33'15\"")
        lu.assertEquals(HOUND.Utils.Text.getLL(-35.443,-124.5543,true),"S35°26.580' W124°33.258'")

        --  HOUND.Utils.Text.getTime
        lu.assertEquals(HOUND.Utils.Text.getTime(43201),"1200")
        lu.assertEquals(HOUND.Utils.Text.getTime(30601),"0830")
        lu.assertEquals(HOUND.Utils.Text.getTime(81901),"2245")
        lu.assertEquals(HOUND.Utils.Text.getTime(90901),"0115")
    end

    function TestHoundUtils:TestElint()
        local emitter = Unit.getByName("TOR_SAIPAN-1")
        local platform = Unit.getByName("ELINT_BLUE_C17_EAST")

        -- HOUND.DB.getEmitterBand
        lu.assertEquals(HOUND.DB.getEmitterBand(),'C')
        lu.assertEquals(HOUND.DB.getEmitterBand(emitter),'F')

        -- HOUND.DB.getApertureSize
        lu.assertEquals(HOUND.DB.getApertureSize(),0)
        lu.assertEquals(HOUND.DB.getApertureSize(platform),40)

        -- HOUND.DB.getDefraction
        lu.assertEquals(HOUND.DB.getDefraction(), math.rad(30))
        lu.assertEquals(HOUND.DB.getDefraction(HOUND.DB.getEmitterBand(emitter),HOUND.DB.getApertureSize(platform)),0.002141375)

        -- HOUND.DB.getSensorPrecision
        lu.assertEquals(HOUND.DB.getSensorPrecision(platform,HOUND.DB.getEmitterBand(emitter)),0.002141375)
        -- HOUND.Utils.Elint.generateAngularError

        -- HOUND.Utils.Elint.getAzimuth

        -- HOUND.Utils.getHoundCallsign
        lu.assertIsTrue(HOUND.setContainsValue(HOUND.DB.CALLSIGNS.GENERIC,HOUND.Utils.getHoundCallsign()))
        lu.assertIsFalse(HOUND.setContainsValue(HOUND.DB.CALLSIGNS.GENERIC,HOUND.Utils.getHoundCallsign("NATO")))
        lu.assertIsTrue(HOUND.setContainsValue(HOUND.DB.CALLSIGNS.NATO,HOUND.Utils.getHoundCallsign("NATO")))
        lu.assertIsFalse(HOUND.setContainsValue(HOUND.DB.CALLSIGNS.NATO,HOUND.Utils.getHoundCallsign()))
    end

    function TestHoundUtils:TestPolygon()


    end

    function TestHoundUtils:TestVector()
    end

    function TestHoundUtils:TestZone()

        local zone = HOUND.Utils.Zone.getDrawnZone("Tinian Sector")
        lu.assertNotNil(zone)
        lu.assertEquals(HOUND.Length(zone),15)
        -- lu.assertItemsEquals(zone[1],zone[HOUND.Length(zone)])

        lu.assertItemsEquals(HOUND.Utils.Zone.listDrawnZones(),{"Tinian Sector"})

    end

    function TestHoundUtils:TestDcs()
        local unit = Unit.getByName("TOR_SAIPAN-1")
        local group = Group.getByName("SA-5_SAIPAN")

        lu.assertIsFalse(HOUND.Utils.Dcs.isGroup(nil))
        lu.assertIsFalse(HOUND.Utils.Dcs.isGroup("SA-5_SAIPAN"))
        lu.assertIsFalse(HOUND.Utils.Dcs.isGroup(unit))
        lu.assertIsTrue(HOUND.Utils.Dcs.isGroup(group))

        lu.assertIsFalse(HOUND.Utils.Dcs.isUnit(nil))
        lu.assertIsFalse(HOUND.Utils.Dcs.isUnit("SA-5_SAIPAN"))
        lu.assertIsFalse(HOUND.Utils.Dcs.isUnit(group))
        lu.assertIsTrue(HOUND.Utils.Dcs.isUnit(unit))
    end

    function TestHoundUtils:tearDown()
    end
end