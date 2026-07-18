do
    local TwoPI = 2 * math.pi
    local HalfPi = math.pi / 2

    TestHoundEstimator = {}

    local origSetHeight
    local origSetPointHeight
    local origGetProjectedIP
    local origUpdateMarker

    function TestHoundEstimator:setUp()
        origSetHeight = HOUND.Utils.Geo.setHeight
        origSetPointHeight = HOUND.Utils.Geo.setPointHeight
        origGetProjectedIP = HOUND.Utils.Geo.getProjectedIP
        origUpdateMarker = HOUND.Contact.Estimator.UPLKF.updateMarker

        HOUND.Utils.Geo.setHeight = function(point, offset)
            if type(point) == "table" then
                if HOUND.Utils.Dcs.isPoint(point) then
                    if type(point.y) ~= "number" then
                        point.y = 0
                    end
                    return point
                end
                for _, pt in pairs(point) do
                    if type(pt) == "table" and HOUND.Utils.Dcs.isPoint(pt) and type(pt.y) ~= "number" then
                        pt.y = 0
                    end
                end
            end
            return point
        end

        HOUND.Utils.Geo.setPointHeight = function(point, offset)
            if HOUND.Utils.Dcs.isPoint(point) and type(point.y) ~= "number" then
                point.y = 0
            end
            return point
        end

        HOUND.Utils.Geo.getProjectedIP = function(p0, az, el)
            if not HOUND.Utils.Dcs.isPoint(p0) then return nil end
            local horizontal = math.cos(el) * 10000
            return {
                x = p0.x + math.cos(az) * horizontal,
                z = p0.z + math.sin(az) * horizontal,
                y = p0.y + math.sin(el) * 10000
            }
        end

        HOUND.Contact.Estimator.UPLKF.updateMarker = function() end

        HOUND.KALMAN_DEBUG = false
        HOUND.DEBUG = false
    end

    function TestHoundEstimator:tearDown()
        HOUND.Utils.Geo.setHeight = origSetHeight
        HOUND.Utils.Geo.setPointHeight = origSetPointHeight
        HOUND.Utils.Geo.getProjectedIP = origGetProjectedIP
        HOUND.Contact.Estimator.UPLKF.updateMarker = origUpdateMarker
    end

    function TestHoundEstimator:TestAccuracyScoreNil()
        lu.assertEquals(HOUND.Contact.Estimator.accuracyScore(nil), 0)
    end

    function TestHoundEstimator:TestAccuracyScoreString()
        lu.assertEquals(HOUND.Contact.Estimator.accuracyScore("not a number"), 0)
    end

    function TestHoundEstimator:TestAccuracyScoreTable()
        lu.assertEquals(HOUND.Contact.Estimator.accuracyScore({}), 0)
    end

    function TestHoundEstimator:TestAccuracyScoreZero()
        local score = HOUND.Contact.Estimator.accuracyScore(0)
        local expected = HOUND.Utils.Cluster.gaussianKernel(
            HOUND.Utils.Mapping.linear(0, 0, 100000, 1, 0, true), 0.2)
        lu.assertAlmostEquals(score, expected, 0.0001)
    end

    function TestHoundEstimator:TestAccuracyScoreHundredK()
        local score = HOUND.Contact.Estimator.accuracyScore(100000)
        local expected = HOUND.Utils.Cluster.gaussianKernel(
            HOUND.Utils.Mapping.linear(100000, 0, 100000, 1, 0, true), 0.2)
        lu.assertAlmostEquals(score, expected, 0.0001)
    end

    function TestHoundEstimator:TestAccuracyScoreNegative()
        local score = HOUND.Contact.Estimator.accuracyScore(-100)
        local expected = HOUND.Utils.Cluster.gaussianKernel(
            HOUND.Utils.Mapping.linear(-100, 0, 100000, 1, 0, true), 0.2)
        lu.assertAlmostEquals(score, expected, 0.0001)
    end

    function TestHoundEstimator:TestAccuracyScoreVeryLarge()
        local score = HOUND.Contact.Estimator.accuracyScore(1e9)
        local expected = HOUND.Utils.Cluster.gaussianKernel(
            HOUND.Utils.Mapping.linear(1e9, 0, 100000, 1, 0, true), 0.2)
        lu.assertAlmostEquals(score, expected, 0.0001)
    end

    function TestHoundEstimator:TestPosFilterInit()
        local filter = HOUND.Contact.Estimator.Kalman.posFilter()
        lu.assertNotNil(filter)
        lu.assertEquals(filter.P.x, 0.5)
        lu.assertEquals(filter.P.z, 0.5)
        lu.assertIsTable(filter.estimated)
    end

    function TestHoundEstimator:TestPosFilterFirstUpdate()
        local filter = HOUND.Contact.Estimator.Kalman.posFilter()
        local point = {x = 100, z = 200, y = 50}
        filter:update(point)
        lu.assertNotNil(filter.estimated.p)
        lu.assertEquals(filter.estimated.p.x, 100)
        lu.assertEquals(filter.estimated.p.z, 200)
        lu.assertEquals(filter.estimated.p.y, 50)
    end

    function TestHoundEstimator:TestPosFilterSecondUpdate()
        local filter = HOUND.Contact.Estimator.Kalman.posFilter()
        filter:update({x = 100, z = 200, y = 50})

        local datapoint = {
            x = 110, z = 190, y = 45,
            err = { score = { x = 4, z = 9 } }
        }
        filter:update(datapoint)

        lu.assertIsNumber(filter.estimated.p.x)
        lu.assertIsNumber(filter.estimated.p.z)
        lu.assertIsNumber(filter.P.x)
        lu.assertIsNumber(filter.P.z)
        lu.assertIsTrue(filter.P.x > 0)
        lu.assertIsTrue(filter.P.z > 0)
    end

    function TestHoundEstimator:TestPosFilterUpdateNoErrScore()
        local filter = HOUND.Contact.Estimator.Kalman.posFilter()
        filter:update({x = 100, z = 200, y = 50})

        local origPx = filter.P.x
        filter:update({x = 110, z = 190, y = 45})
        lu.assertEquals(filter.P.x, origPx)
    end

    function TestHoundEstimator:TestPosFilterUpdateNilErrScore()
        local filter = HOUND.Contact.Estimator.Kalman.posFilter()
        filter:update({x = 100, z = 200, y = 50})
        local origPx = filter.P.x
        filter:update({x = 110, z = 190, y = 45, err = {}})
        lu.assertEquals(filter.P.x, origPx)
    end

    function TestHoundEstimator:TestPosFilterGet()
        local filter = HOUND.Contact.Estimator.Kalman.posFilter()
        lu.assertIsNil(filter:get())
        filter:update({x = 100, z = 200, y = 50})
        local pos = filter:get()
        lu.assertEquals(pos.x, 100)
        lu.assertEquals(pos.z, 200)
    end

    function TestHoundEstimator:TestPosFilterGetBeforeUpdate()
        local filter = HOUND.Contact.Estimator.Kalman.posFilter()
        lu.assertIsNil(filter:get())
    end

    function TestHoundEstimator:TestPosFilterUpdateWithErrScoreChangesP()
        local filter = HOUND.Contact.Estimator.Kalman.posFilter()
        filter:update({x = 100, z = 200, y = 50})
        local px0 = filter.P.x
        local pz0 = filter.P.z
        filter:update({
            x = 105, z = 195, y = 48,
            err = { score = { x = 1, z = 1 } }
        })
        lu.assertNotEquals(filter.P.x, px0)
        lu.assertNotEquals(filter.P.z, pz0)
    end

    function TestHoundEstimator:TestAzFilterInit()
        local maxError = 0.1
        local filter = HOUND.Contact.Estimator.Kalman.AzFilter(maxError)
        lu.assertEquals(filter.P, 0.5)
        lu.assertEquals(filter.noiseVariance, (0.1 / 2) * (0.1 / 2))
        lu.assertIsNil(filter.estimated)
    end

    function TestHoundEstimator:TestAzFilterFirstUpdate()
        local filter = HOUND.Contact.Estimator.Kalman.AzFilter(0.1)
        filter:update(1.0)
        lu.assertIsNumber(filter.estimated)
        lu.assertEquals(filter.estimated, 1.0)
    end

    function TestHoundEstimator:TestAzFilterGet()
        local filter = HOUND.Contact.Estimator.Kalman.AzFilter(0.1)
        lu.assertIsNil(filter:get())
        filter:update(1.0)
        lu.assertEquals(filter:get(), 1.0)
    end

    function TestHoundEstimator:TestAzFilterUpdateWithPredictedAz()
        local filter = HOUND.Contact.Estimator.Kalman.AzFilter(0.1)
        filter:update(1.0, 0.9)
        lu.assertIsNumber(filter.estimated)
    end

    function TestHoundEstimator:TestAzFilterUpdateWithProcessNoise()
        local filter = HOUND.Contact.Estimator.Kalman.AzFilter(0.1)
        filter:update(1.0, nil, 0.5)
        lu.assertIsNumber(filter.estimated)
    end

    function TestHoundEstimator:TestAzFilterSecondUpdateConverges()
        local filter = HOUND.Contact.Estimator.Kalman.AzFilter(0.5)
        filter:update(1.0)
        local first = filter.estimated
        filter:update(1.05)
        local second = filter.estimated
        lu.assertIsTrue(math.abs(second - 1.0) < math.abs(first - 1.0))
    end

    function TestHoundEstimator:TestAzElFilterInit()
        local filter = HOUND.Contact.Estimator.Kalman.AzElFilter()
        lu.assertEquals(filter.K.Az, 0)
        lu.assertEquals(filter.K.El, 0)
        lu.assertEquals(filter.P.Az, 1)
        lu.assertEquals(filter.P.El, 1)
        lu.assertIsNil(filter.estimated.pos)
        lu.assertIsNil(filter.estimated.Az)
        lu.assertIsNil(filter.estimated.El)
    end

    function TestHoundEstimator:TestAzElFilterFirstUpdate()
        local filter = HOUND.Contact.Estimator.Kalman.AzElFilter()
        local datapoint = {
            az = 1.0,
            el = 0.1,
            platformPos = {x = 0, z = 0, y = 1000},
            platformPrecision = 0.01
        }
        local result = filter:update(datapoint)
        lu.assertNotNil(result)
        lu.assertIsNumber(result.Az)
        lu.assertIsNumber(result.El)
        lu.assertIsTable(result.pos)
        lu.assertIsNumber(result.pos.x)
        lu.assertIsNumber(result.pos.z)
    end

    function TestHoundEstimator:TestAzElFilterReset()
        local filter = HOUND.Contact.Estimator.Kalman.AzElFilter()
        local datapoint = {
            az = 1.0,
            el = 0.1,
            platformPos = {x = 0, z = 0, y = 1000},
            platformPrecision = 0.01
        }
        filter:update(datapoint)
        filter:reset()
        lu.assertEquals(filter.P.Az, 1)
        lu.assertEquals(filter.P.El, 1)
    end

    function TestHoundEstimator:TestAzElFilterGetValue()
        local filter = HOUND.Contact.Estimator.Kalman.AzElFilter()
        local v = filter:getValue()
        lu.assertIsNil(v.pos)
        lu.assertIsNil(v.Az)
        lu.assertIsNil(v.El)

        local datapoint = {
            az = 1.0,
            el = 0.1,
            platformPos = {x = 0, z = 0, y = 1000},
            platformPrecision = 0.01
        }
        filter:update(datapoint)
        local v2 = filter:getValue()
        lu.assertIsTable(v2.pos)
    end

    function TestHoundEstimator:TestUPLKFCreate()
        local p0 = {x = 1000, z = 2000, y = 100}
        local filter = HOUND.Contact.Estimator.UPLKF:create(p0, nil, 100.0, 5000, false)
        lu.assertNotNil(filter)
        lu.assertEquals(filter.state[1][1], 1000)
        lu.assertEquals(filter.state[2][1], 2000)
        lu.assertEquals(filter.state[3][1], 0)
        lu.assertEquals(filter.state[4][1], 0)
        lu.assertIsFalse(filter.mobile)
    end

    function TestHoundEstimator:TestUPLKFCreateMobile()
        local p0 = {x = 1000, z = 2000, y = 100}
        local v0 = {x = 10, z = 5}
        local filter = HOUND.Contact.Estimator.UPLKF:create(p0, v0, 100.0, 5000, true)
        lu.assertIsTrue(filter.mobile)
        lu.assertEquals(filter.state[3][1], 10)
        lu.assertEquals(filter.state[4][1], 5)
    end

    function TestHoundEstimator:TestUPLKFCreateInvalid()
        lu.assertIsNil(HOUND.Contact.Estimator.UPLKF:create(nil))
        lu.assertIsNil(HOUND.Contact.Estimator.UPLKF:create("not a point"))
        lu.assertIsNil(HOUND.Contact.Estimator.UPLKF:create({}))
        lu.assertIsNil(HOUND.Contact.Estimator.UPLKF:create({x = "abc", z = "def"}))
    end

    function TestHoundEstimator:TestUPLKFGetEstimatedPos()
        local p0 = {x = 1000, z = 2000, y = 100}
        local filter = HOUND.Contact.Estimator.UPLKF:create(p0, nil, 100.0, 5000, false)
        local pos = filter:getEstimatedPos()
        lu.assertNotNil(pos)
        lu.assertEquals(pos.x, 1000)
        lu.assertEquals(pos.z, 2000)
    end

    function TestHoundEstimator:TestUPLKFGetEstimatedPosWithState()
        local p0 = {x = 1000, z = 2000, y = 100}
        local filter = HOUND.Contact.Estimator.UPLKF:create(p0, nil, 100.0, 5000, false)
        local customState = {
            {500},
            {1500},
            {0},
            {0}
        }
        local pos = filter:getEstimatedPos(customState)
        lu.assertEquals(pos.x, 500)
        lu.assertEquals(pos.z, 1500)
    end

    function TestHoundEstimator:TestUPLKFGetUncertainty()
        local p0 = {x = 1000, z = 2000, y = 100}
        local filter = HOUND.Contact.Estimator.UPLKF:create(p0, nil, 100.0, 5000, false)
        local u = filter:getUncertainty()
        lu.assertIsTable(u)
        lu.assertIsNumber(u.major)
        lu.assertIsNumber(u.minor)
        lu.assertIsNumber(u.theta)
        lu.assertIsNumber(u.az)
        lu.assertIsNumber(u.r)
        lu.assertIsTrue(u.major >= u.minor)
    end

    function TestHoundEstimator:TestUPLKFGetUncertaintyCustomConfidence()
        local p0 = {x = 1000, z = 2000, y = 100}
        local filter = HOUND.Contact.Estimator.UPLKF:create(p0, nil, 100.0, 5000, false)
        local u1 = filter:getUncertainty()
        local u2 = filter:getUncertainty(1.0)
        lu.assertIsTrue(u2.major < u1.major)
    end

    function TestHoundEstimator:TestUPLKFNormalizeAz()
        local normalize = HOUND.Contact.Estimator.UPLKF.normalizeAz
        local result = normalize(0)
        lu.assertIsNumber(result)
        lu.assertIsTrue(result >= -math.pi)
        lu.assertIsTrue(result <= math.pi)
    end

    function TestHoundEstimator:TestUPLKFNormalizeAzEdge()
        local normalize = HOUND.Contact.Estimator.UPLKF.normalizeAz
        local az_north = normalize(0)
        local az_east = normalize(HalfPi)
        local az_south = normalize(math.pi)
        local az_west = normalize(3 * HalfPi)
        lu.assertIsNumber(az_north)
        lu.assertIsNumber(az_east)
        lu.assertIsNumber(az_south)
        lu.assertIsNumber(az_west)
        lu.assertIsTrue(az_south > az_east)
    end

    function TestHoundEstimator:TestUPLKFBearingToAzimuth()
        local b2a = HOUND.Contact.Estimator.UPLKF.bearingToAzimuth
        local az = b2a(0)
        lu.assertIsNumber(az)
        lu.assertIsTrue(az >= 0)
        lu.assertIsTrue(az <= TwoPI)
    end

    function TestHoundEstimator:TestUPLKFBearingToAzimuthRoundtrip()
        local normalize = HOUND.Contact.Estimator.UPLKF.normalizeAz
        local b2a = HOUND.Contact.Estimator.UPLKF.bearingToAzimuth
        for _, bearing in ipairs({0, HalfPi, math.pi, 3 * HalfPi}) do
            local az = b2a(bearing)
            local roundtrip = normalize(az)
            lu.assertAlmostEquals(roundtrip, bearing, 0.0001)
        end
    end

    function TestHoundEstimator:TestUPLKFGetF()
        local p0 = {x = 1000, z = 2000, y = 100}
        local filter = HOUND.Contact.Estimator.UPLKF:create(p0, nil, 100.0, 5000, false)
        local deltaT = 10
        local F = filter:getF(deltaT)
        lu.assertIsTable(F)
        lu.assertEquals(#F, 4)
        lu.assertEquals(#F[1], 4)
        lu.assertEquals(F[1][1], 1)
        lu.assertEquals(F[1][3], deltaT)
        lu.assertEquals(F[2][2], 1)
        lu.assertEquals(F[2][4], deltaT)
        lu.assertEquals(F[3][3], 1)
        lu.assertEquals(F[4][4], 1)
    end

    function TestHoundEstimator:TestUPLKFGetQ()
        local p0 = {x = 1000, z = 2000, y = 100}
        local filter = HOUND.Contact.Estimator.UPLKF:create(p0, nil, 100.0, 5000, false)
        local Q = filter:getQ(10)
        lu.assertIsTable(Q)
        lu.assertEquals(#Q, 4)
        lu.assertEquals(#Q[1], 4)
        lu.assertIsTrue(Q[1][1] > 0)
    end

    function TestHoundEstimator:TestUPLKFGetQMobile()
        local p0 = {x = 1000, z = 2000, y = 100}
        local mobileFilter = HOUND.Contact.Estimator.UPLKF:create(p0, nil, 100.0, 5000, true)
        local stationaryFilter = HOUND.Contact.Estimator.UPLKF:create(p0, nil, 100.0, 5000, false)
        local qMobile = mobileFilter:getQ(10)
        local qStationary = stationaryFilter:getQ(10)
        lu.assertIsTrue(qMobile[1][1] > qStationary[1][1])
    end

    function TestHoundEstimator:TestUPLKFPredictStep()
        local p0 = {x = 1000, z = 2000, y = 100}
        local filter = HOUND.Contact.Estimator.UPLKF:create(p0, nil, 100.0, 5000, false)
        local X = filter.state
        local P = filter.P
        local x_hat, P_hat = filter:predictStep(X, P, 10)
        lu.assertIsTable(x_hat)
        lu.assertIsTable(P_hat)
        lu.assertEquals(#x_hat, 4)
        lu.assertEquals(#P_hat, 4)
    end

    function TestHoundEstimator:TestNormalizeAzAngles()
        local normalize = HOUND.Contact.Estimator.UPLKF.normalizeAz
        lu.assertEquals(normalize(HalfPi), 0, 0.0001)
        lu.assertAlmostEquals(normalize(math.pi), -HalfPi, 0.0001)
        lu.assertEquals(normalize(0), HalfPi, 0.0001)
    end

    function TestHoundEstimator:TestBearingToAzimuthValues()
        local b2a = HOUND.Contact.Estimator.UPLKF.bearingToAzimuth
        lu.assertEquals(b2a(0), HalfPi, 0.0001)
        lu.assertEquals(b2a(HalfPi), 0, 0.0001)
        lu.assertEquals(b2a(math.pi), 3 * HalfPi, 0.0001)
        lu.assertEquals(b2a(3 * HalfPi), math.pi, 0.0001)
    end
end
