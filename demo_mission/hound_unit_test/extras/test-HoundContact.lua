
do
    TestHoundContact = {}

    function TestHoundContact:setUp()
        self.contact = HoundContact.New(Unit.getByName("TOR_SAIPAN-1"),coalition.side.BLUE)
        lu.assertNotNil(self.contact)
        lu.assertIsTable(self.contact)

    end

    function TestHoundContact:tearDown()
        -- self.contact:destroy()
        self.contact = nil

    end

    function TestHoundContact:TestLocation()
        local emitter = Unit.getByName("TOR_SAIPAN-1")
        local platform1 = Unit.getByName("ELINT_BLUE_C17_EAST")
        local platform2 = Unit.getByName("ELINT_BLUE_C17_WEST")

        lu.assertIsTable(emitter)
        lu.assertIsTable(platform1)
        lu.assertIsTable(platform1)

        lu.assertNotNil(self.contact)
        lu.assertIsTable(self.contact)
        lu.assertEquals(self.contact.state,HOUND.EVENTS.RADAR_NEW)

        local tgtPos = emitter:getPosition().p
        local p1 = platform1:getPosition().p
        local p2 = platform2:getPosition().p
        local err = 0

        lu.assertIsTrue(HoundUtils.Geo.checkLOS(p1, tgtPos))
        lu.assertIsTrue(HoundUtils.Geo.checkLOS(p2, tgtPos))

        local az1,el1 = HoundUtils.Elint.getAzimuth( p1, tgtPos, err )
        local az2,el2 = HoundUtils.Elint.getAzimuth( p2, tgtPos, err )

        -- will change based on test time
        -- lu.assertAlmostEquals(az1,,0.0001)
        -- lu.assertAlmostEquals(el1,,0.0001)
        -- lu.assertAlmostEquals(az2,,0.0001)
        -- lu.assertAlmostEquals(el2,,0.0001)

        local d1 = HOUND.Datapoint.New(platform1,p1, az1, el1, timer.getAbsTime(),err,false)
        local d2 = HOUND.Datapoint.New(platform2,p2, az2, el2, timer.getAbsTime(),err,false)

        self.contact:AddPoint(d1)
        self.contact:AddPoint(d2)

        local contactState = self.contact:processData()

        lu.assertEquals(contactState,HOUND.EVENTS.RADAR_DETECTED)

        lu.assertAlmostEquals(tgtPos.x,d1.estimatedPos.x,0.5)
        lu.assertAlmostEquals(tgtPos.z,d1.estimatedPos.z,0.5)

        lu.assertAlmostEquals(tgtPos.x,d2.estimatedPos.x,0.5)
        lu.assertAlmostEquals(tgtPos.z,d2.estimatedPos.z,0.5)

        lu.assertAlmostEquals(tgtPos.x,self.contact:getPos().x,0.5)
        lu.assertAlmostEquals(tgtPos.z,self.contact:getPos().z,0.5)
        -- lu.assertItemsEquals(tgtPos,d1.estimatedPos)
        -- lu.assertItemsEquals(tgtPos,d2.estimatedPos)
        -- lu.assertItemsEquals(tgtPos,self.contact:getPos())
    end

    function TestHoundContact:TestLocationErr()
        local emitter = Unit.getByName("TOR_SAIPAN-1")
        local platform1 = Unit.getByName("ELINT_BLUE_C17_EAST")
        local platform2 = Unit.getByName("ELINT_BLUE_C17_WEST")


        lu.assertEquals(self.contact.state,HOUND.EVENTS.RADAR_NEW)

        local tgtPos = emitter:getPosition().p
        local p1 = platform1:getPosition().p
        local p2 = platform2:getPosition().p

        local err = HoundUtils.Elint.getSensorPrecision(platform1,HoundUtils.Elint.getEmitterBand(emitter))
        lu.assertEquals(err,0.0017131)

        local az1,el1 = HoundUtils.Elint.getAzimuth( p1, tgtPos, err )
        local az2,el2 = HoundUtils.Elint.getAzimuth( p2, tgtPos, err )

        local d1 = HOUND.Datapoint.New(platform1,p1, az1, el1, timer.getAbsTime(),err,false)
        local d2 = HOUND.Datapoint.New(platform2,p2, az2, el2, timer.getAbsTime(),err,false)

        self.contact:AddPoint(d1)
        self.contact:AddPoint(d2)
        -- self.contact:processDataWIP()


        lu.assertIsTable(d1.posPolygon["3D"])
        lu.assertIsTable(d2.posPolygon["3D"])

        -- check algorithems
        lu.assertIsTrue(mist.pointInPolygon(tgtPos,d1.posPolygon["3D"]))
        lu.assertIsTrue(mist.pointInPolygon(tgtPos,d2.posPolygon["3D"]))

        lu.assertIsTable(d1.posPolygon["2D"])
        lu.assertIsTable(d2.posPolygon["2D"])

        local clipPoly = HoundUtils.Polygon.clipPolygons(d1.posPolygon["2D"],d2.posPolygon["2D"])
        clipPoly = HoundUtils.Polygon.clipPolygons(clipPoly,d1.posPolygon["3D"]) or clipPoly
        clipPoly = HoundUtils.Polygon.clipPolygons(clipPoly,d2.posPolygon["3D"]) or clipPoly
        lu.assertIsTable(clipPoly)
        -- mist.marker.add({pos=clipPoly,markType="freeform"})
        lu.assertIsTrue(mist.pointInPolygon(tgtPos,clipPoly))


        local contactState = self.contact:processData()

        lu.assertEquals(contactState,HOUND.EVENTS.RADAR_DETECTED)
        -- self.contact:processDataWIP()

        -- local estimation = self.contact:drawAreaMarker(16,true)
        -- lu.assertIsTable(estimation)
        -- lu.assertIsTrue(mist.pointInPolygon(tgtPos,estimation,tgtPos.y+10))
    end
end