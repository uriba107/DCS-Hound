-- Tests for HOUND.Mist.hex (pointy-top cube rqs grid, src/020 - HoundMist.lua).
-- No DCS runtime needed except TestMakeVec3GL (needs land.getHeight; skips when land is nil).
-- No require()/io (DCS Lua 5.1). Map tables counted with pairs-loop (# unreliable).
do
    TestHoundHex = {}

    local function countKeys(t)
        local n = 0
        for _ in pairs(t) do n = n + 1 end
        return n
    end

    local function hexEquals(a, b)
        return a.r == b.r and a.q == b.q and a.s == b.s
    end

    -- 60km square centered on origin. Covers many hexes at default radius 1000.
    local function originSquare()
        return {
            {x = -30000, z = -30000, y = 0},
            {x = 30000, z = -30000, y = 0},
            {x = 30000, z = 30000, y = 0},
            {x = -30000, z = 30000, y = 0},
        }
    end

    local function fixedHexes(hex)
        return {hex.to(0, 0, 0), hex.to(1, 2, -3), hex.to(-2, 1, 1), hex.to(3, -1, -2)}
    end

    function TestHoundHex:TestHashRoundtrip()
        local hex = HOUND.Mist.hex
        lu.assertEquals(hex.hash(hex.to(1, 2, -3)), "1 2 -3")
        lu.assertEquals(hex.hash(hex.to(0, 0, 0)), "0 0 0")
        -- s omitted when nil
        lu.assertEquals(hex.hash({r = 1, q = 2}), "1 2")
        -- hashToHex parses signed groups; "-0" parses to 0 (getFromRoute normalizes "0 0 -0" to "0 0 0")
        local h = hex.hashToHex("0 0 -0")
        lu.assertEquals(h.r, 0)
        lu.assertEquals(h.q, 0)
        lu.assertTrue(h.s == 0)
        for _, orig in ipairs(fixedHexes(hex)) do
            lu.assertTrue(hexEquals(orig, hex.hashToHex(hex.hash(orig))))
        end
    end

    function TestHoundHex:TestHashNormalizesNegativeZero()
        local hex = HOUND.Mist.hex
        -- pointToHex at the origin returns s = -0.0; hash must match "0 0 0"
        lu.assertEquals(hex.hash(hex.pointToHex({ x = 0, y = 0, z = 0 })), "0 0 0")
        lu.assertEquals(hex.hash({ r = 0, q = 0, s = -0.0 }), "0 0 0")
        lu.assertEquals(hex.hash({ r = -0.0, q = 0, s = 0 }), "0 0 0")
    end

    function TestHoundHex:TestPointVecRoundtrip()
        local hex = HOUND.Mist.hex
        -- makeVec3 returns {x, z, y=0}
        local v0 = hex.makeVec3(hex.to(0, 0, 0))
        lu.assertEquals(v0.x, 0)
        lu.assertEquals(v0.z, 0)
        lu.assertEquals(v0.y, 0)
        -- pointToHex inverts makeVec3
        for _, orig in ipairs(fixedHexes(hex)) do
            lu.assertTrue(hexEquals(orig, hex.pointToHex(hex.makeVec3(orig))))
        end
        -- pointToHex reads point.z or point.y; point.x maps to r
        local a = hex.pointToHex({x = 100, z = 200})
        local b = hex.pointToHex({x = 100, y = 200})
        lu.assertTrue(hexEquals(a, b))
    end

    function TestHoundHex:TestNeighbor()
        local hex = HOUND.Mist.hex
        local c = hex.to(0, 0, 0)
        local seen = {}
        for i = 1, 6 do
            local n = hex.neighbor(c, i)
            lu.assertNotNil(n)
            lu.assertEquals(hex.distance(c, n), 1)
            seen[hex.hash(n)] = true
        end
        lu.assertEquals(countKeys(seen), 6)
        lu.assertIsNil(hex.direction(0))
        lu.assertIsNil(hex.neighbor(c, 0))
    end

    function TestHoundHex:TestDistance()
        local hex = HOUND.Mist.hex
        lu.assertEquals(hex.distance(hex.to(0, 0, 0), hex.to(0, 0, 0)), 0)
        lu.assertEquals(hex.distance(hex.to(0, 0, 0), hex.to(1, 0, -1)), 1)
        lu.assertEquals(hex.distance(hex.to(0, 0, 0), hex.to(2, -1, -1)), 2)
        lu.assertEquals(hex.distance(hex.to(1, 2, -3), hex.to(-1, -2, 3)), 6)
    end

    function TestHoundHex:TestCubeRing()
        local hex = HOUND.Mist.hex
        local c = hex.to(0, 0, 0)
        -- cubeRing returns a {[hash]=hex} map, not an array
        local ring = hex.cubeRing(c, 2)
        lu.assertEquals(countKeys(ring), 12)
        for k, h in pairs(ring) do
            lu.assertEquals(hex.distance(c, h), 2)
            lu.assertTrue(hexEquals(h, hex.hashToHex(k)))
        end
    end

    function TestHoundHex:TestCubeSpiral()
        local hex = HOUND.Mist.hex
        local c = hex.to(0, 0, 0)
        local spiral = hex.cubeSpiral(c, 2)
        lu.assertEquals(countKeys(spiral), 1 + 6 + 12)
        lu.assertNotNil(spiral[hex.hash(c)])
        for _, h in pairs(spiral) do
            lu.assertTrue(hex.distance(c, h) <= 2)
        end
    end

    function TestHoundHex:TestLineDraw()
        local hex = HOUND.Mist.hex
        local a = hex.to(0, 0, 0)
        local b = hex.to(3, -1, -2)
        local line = hex.lineDraw(a, b)
        lu.assertEquals(#line, hex.distance(a, b) + 1)
        lu.assertTrue(hexEquals(line[1], a))
        lu.assertTrue(hexEquals(line[#line], b))
    end

    function TestHoundHex:TestGetFromRouteFill()
        local hex = HOUND.Mist.hex
        local sq = originSquare()
        local edge = hex.getFromRoute(sq, false)
        local fill = hex.getFromRoute(sq, true)
        lu.assertTrue(countKeys(fill) > countKeys(edge))
        for k in pairs(edge) do
            lu.assertNotNil(fill[k])
        end
        lu.assertIsNil(fill["0 0 -0"])
        lu.assertNotNil(fill["0 0 0"])
    end

    function TestHoundHex:TestGetFromRouteFillInsidePolygon()
        local hex = HOUND.Mist.hex
        local poly = originSquare()
        local edge = hex.getFromRoute(poly, false)
        local fill = hex.getFromRoute(poly, true)
        local checked = 0
        for hash, cell in pairs(fill) do
            if not edge[hash] then
                lu.assertIsTrue(HOUND.Mist.pointInPolygon(hex.makeVec2(cell), poly))
                checked = checked + 1
            end
        end
        lu.assertIsTrue(checked > 0)
    end

    function TestHoundHex:TestGetFromRouteYields()
        local hex = HOUND.Mist.hex
        local realGetTime = timer.getTime
        local t = 0
        timer.getTime = function() t = t + 0.01; return t end
        local co = coroutine.create(function()
            return hex.getFromRoute(originSquare(), true, coroutine.yield)
        end)
        local resumes, result = 0, nil
        local ok, err = pcall(function()
            while true do
                local resumed, value = coroutine.resume(co)
                lu.assertIsTrue(resumed, tostring(value))
                resumes = resumes + 1
                if coroutine.status(co) == "dead" then result = value; break end
                lu.assertIsTrue(resumes < 1000)
            end
        end)
        timer.getTime = realGetTime
        lu.assertIsTrue(ok, tostring(err))
        lu.assertIsTable(result)
        lu.assertIsTrue(HOUND.Length(result) > 0)
        lu.assertIsTrue(resumes > 1)
    end

    function TestHoundHex:TestRingWalkProperty()
        local hex = HOUND.Mist.hex
        local center = hex.to(0, 0, 0)
        local targets = {hex.to(3, -1, -2), hex.to(-2, 2, 0)}
        for _, t in ipairs(targets) do
            local pc = hex.makeVec3(t)
            local half = 12000
            local poly = {
                {x = pc.x - half, z = pc.z - half, y = 0},
                {x = pc.x + half, z = pc.z - half, y = 0},
                {x = pc.x + half, z = pc.z + half, y = 0},
                {x = pc.x - half, z = pc.z + half, y = 0},
            }
            local cells = hex.getFromRoute(poly, true)
            lu.assertTrue(countKeys(cells) > 0)
            local minD = math.huge
            for _, h in pairs(cells) do
                local d = hex.distance(center, h)
                if d < minD then minD = d end
            end
            local firstHit = nil
            for k = 0, 12 do
                for kh in pairs(hex.cubeRing(center, k)) do
                    if cells[kh] then firstHit = k break end
                end
                if firstHit then break end
            end
            lu.assertEquals(firstHit, minD)
        end
    end

    function TestHoundHex:TestDrawNoMist()
        local hex = HOUND.Mist.hex
        local savedMist = _G.mist
        _G.mist = nil
        local ok1, res1 = pcall(hex.draw, hex.to(0, 0, 0))
        _G.mist = {}
        local ok2, res2 = pcall(hex.draw, hex.to(0, 0, 0))
        _G.mist = savedMist
        lu.assertTrue(ok1)
        lu.assertIsNil(res1)
        lu.assertTrue(ok2)
        lu.assertIsNil(res2)
    end

    function TestHoundHex:TestUseHexGridDefault()
        lu.assertIsTrue(HOUND.useHexGrid)
        HOUND.useHexGrid = false
        lu.assertIsFalse(HOUND.useHexGrid)
        HOUND.useHexGrid = true
        lu.assertIsTrue(HOUND.useHexGrid)
    end

    function TestHoundHex:TestRadius()
        local hex = HOUND.Mist.hex
        lu.assertEquals(HOUND.hexRadius, 1000)
        lu.assertEquals(hex.getRadius(), 1000)
        hex.setRadius(5000)
        lu.assertEquals(hex.getRadius(), 5000)
        hex.setRadius(1000)
        lu.assertEquals(hex.getRadius(), 1000)
        hex.setRadius(nil)
        hex.setRadius("bad")
        hex.setRadius(0)
        lu.assertEquals(hex.getRadius(), 1000)
    end

    local function zoneGrid(poly)
        local hex = HOUND.Mist.hex
        local centerHex = hex.pointToHex(HOUND.Mist.getAvgPoint(poly))
        local cells = hex.getFromRoute(poly, true)
        local keys, list = {}, {}
        local radiusHex = 0
        for _, cell in pairs(cells) do
            keys[hex.cellKey(cell.r, cell.q)] = true
            table.insert(list, cell)
            local distance = hex.distance(centerHex, cell)
            if distance > radiusHex then radiusHex = distance end
        end
        return keys, list, centerHex, radiusHex
    end

    function TestHoundHex:TestThreatOnSectorHexQuery()
        local hex = HOUND.Mist.hex
        local savedRadius = hex.getRadius()
        hex.setRadius(1000)
        local poly = {
            {x = -5000, z = -5000, y = 0},
            {x = 5000, z = -5000, y = 0},
            {x = 5000, z = 5000, y = 0},
            {x = -5000, z = 5000, y = 0},
        }
        local keys, list, centerHex, radiusHex = zoneGrid(poly)

        local inSector, threat = HOUND.Utils.Polygon.threatOnSector(poly, {x = 0, z = 0}, nil, keys, list, centerHex, radiusHex)
        lu.assertIsTrue(inSector)
        lu.assertIsTrue(threat)

        inSector, threat = HOUND.Utils.Polygon.threatOnSector(poly, {x = 50000, z = 50000}, nil, keys, list, centerHex, radiusHex)
        lu.assertIsFalse(inSector)
        lu.assertIsFalse(threat)

        inSector, threat = HOUND.Utils.Polygon.threatOnSector(poly, {x = 6000, z = 0}, 2000, keys, list, centerHex, radiusHex)
        lu.assertIsFalse(inSector)
        lu.assertIsTrue(threat)

        hex.setRadius(savedRadius)
    end

    function TestHoundHex:TestThreatOnSectorOriginMembership()
        local hex = HOUND.Mist.hex
        local savedRadius = hex.getRadius()
        hex.setRadius(1000)
        local poly = originSquare()
        local keys, list, centerHex, radiusHex = zoneGrid(poly)
        local inSector, threat = HOUND.Utils.Polygon.threatOnSector(
            poly, { x = 0, y = 0, z = 0 }, 50000, keys, list, centerHex, radiusHex)
        lu.assertIsTrue(inSector)
        lu.assertIsTrue(threat)
        hex.setRadius(savedRadius)
    end

    function TestHoundHex:TestThreatOnSectorScanMatchesBruteForce()
        local hex = HOUND.Mist.hex
        local savedRadius = hex.getRadius()
        local radius = 1000
        hex.setRadius(radius)
        local poly = {
            {x = -6000, z = -6000, y = 0},
            {x = 6000, z = -6000, y = 0},
            {x = 6000, z = 6000, y = 0},
            {x = -6000, z = 6000, y = 0},
        }
        local keys, list, centerHex, radiusHex = zoneGrid(poly)
        local step = 1.5 * radius
        local range = 5000
        local rings = math.ceil(range / step) + 1

        for x = -14000, 14000, 3000 do
            for z = -14000, 14000, 3000 do
                local point = {x = x, y = 0, z = z}
                local h = hex.pointToHex(point)
                local minD = math.huge
                for _, cell in ipairs(list) do
                    local distance = hex.distance(h, cell)
                    if distance < minD then minD = distance end
                end
                local expectedIn = minD == 0
                local expectedThreat = minD <= rings
                local inSector, threat = HOUND.Utils.Polygon.threatOnSector(poly, point, range, keys, list, centerHex, radiusHex)
                lu.assertEquals(inSector, expectedIn)
                lu.assertEquals(threat, expectedThreat)
            end
        end

        hex.setRadius(savedRadius)
    end

    function TestHoundHex:TestMakeVec3GL()
        -- DCS-only: requires land.getHeight. Skipped when land is absent.
        if land == nil or type(land.getHeight) ~= "function" then return end
        local hex = HOUND.Mist.hex
        local h = hex.to(1, 2, -3)
        local v3 = hex.makeVec3(h)
        local gl = hex.makeVec3GL(h, 10)
        lu.assertEquals(gl.x, v3.x)
        lu.assertEquals(gl.z, v3.z)
        lu.assertEquals(gl.y, land.getHeight({x = v3.x, y = v3.z}) + 10)
    end
end
