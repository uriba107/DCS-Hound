
do
    TestHoundContact = {}

    function TestHoundContact:setUp()
        self.contact = HOUND.Contact.Emitter:New(Unit.getByName("TOR_SAIPAN-1"),coalition.side.BLUE)
        lu.assertNotNil(self.contact)
        lu.assertIsTable(self.contact)
        lu.assertIsTrue(getmetatable(self.contact)==HOUND.Contact.Emitter)
    end

    function TestHoundContact:tearDown()
        -- self.contact:destroy()
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

        -- will change based on test time
        -- lu.assertAlmostEquals(az1,,0.0001)
        -- lu.assertAlmostEquals(el1,,0.0001)
        -- lu.assertAlmostEquals(az2,,0.0001)
        -- lu.assertAlmostEquals(el2,,0.0001)
        local emitterDetection = HOUND.Utils.Dcs.getRadarDetectionRange(emitter)
        local s1 = HOUND.Utils.Elint.getSignalStrength(p1,tgtPos,emitterDetection)
        local s2 = HOUND.Utils.Elint.getSignalStrength(p2,tgtPos,emitterDetection)

        local d1 = HOUND.Contact.Datapoint.New(platform1,p1, az1, el1, s1, timer.getAbsTime(),err,false)
        local d2 = HOUND.Contact.Datapoint.New(platform2,p2, az2, el2, s2, timer.getAbsTime(),err,false)

        self.contact:AddPoint(d1)
        self.contact:AddPoint(d2)

        local contactState = self.contact:processData()

        lu.assertEquals(contactState,HOUND.EVENTS.RADAR_DETECTED)

        lu.assertAlmostEquals(tgtPos.x,d1.estimatedPos.x,0.75)
        lu.assertAlmostEquals(tgtPos.z,d1.estimatedPos.z,0.75)

        lu.assertAlmostEquals(tgtPos.x,d2.estimatedPos.x,0.75)
        lu.assertAlmostEquals(tgtPos.z,d2.estimatedPos.z,0.75)

        lu.assertAlmostEquals(tgtPos.x,self.contact:getPos().x,0.75)
        lu.assertAlmostEquals(tgtPos.z,self.contact:getPos().z,0.75)
        -- lu.assertItemsEquals(tgtPos,d1.estimatedPos)
        -- lu.assertItemsEquals(tgtPos,d2.estimatedPos)
        -- lu.assertItemsEquals(tgtPos,self.contact:getPos())
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
        -- self.contact:processDataWIP()


        -- lu.assertIsTable(d1.posPolygon["3D"])
        -- lu.assertIsTable(d2.posPolygon["3D"])

        -- -- check algorithems
        -- lu.assertIsTrue(HOUND.Mist.pointInPolygon(tgtPos,d1.posPolygon["3D"]))
        -- lu.assertIsTrue(HOUND.Mist.pointInPolygon(tgtPos,d2.posPolygon["3D"]))

        -- lu.assertIsTable(d1.posPolygon["2D"])
        -- lu.assertIsTable(d2.posPolygon["2D"])

        -- local clipPoly = HOUND.Utils.Polygon.clipPolygons(d1.posPolygon["2D"],d2.posPolygon["2D"])
        -- clipPoly = HOUND.Utils.Polygon.clipPolygons(clipPoly,d1.posPolygon["3D"]) or clipPoly
        -- clipPoly = HOUND.Utils.Polygon.clipPolygons(clipPoly,d2.posPolygon["3D"]) or clipPoly
        -- lu.assertIsTable(clipPoly)
        -- -- HOUND.Mist.marker.add({pos=clipPoly,markType="freeform"})
        -- lu.assertIsTrue(HOUND.Mist.pointInPolygon(tgtPos,clipPoly))


        local contactState = self.contact:processData()

        lu.assertEquals(contactState,HOUND.EVENTS.RADAR_DETECTED)
        -- self.contact:processDataWIP()

        -- local estimation = self.contact:drawAreaMarker(16,true)
        -- lu.assertIsTable(estimation)
        -- lu.assertIsTrue(HOUND.Mist.pointInPolygon(tgtPos,estimation,tgtPos.y+10))
    end
end