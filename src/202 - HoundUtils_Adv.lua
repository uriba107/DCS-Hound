    --- HOUND.Utils
    -- This class holds generic function used by all of Hound Components
    -- @module HOUND.Utils
do
    local l_mist = HOUND.Mist
    local l_math = math
    local PI_2 = 2*l_math.pi

    HOUND.Utils.Polygon ={}
    HOUND.Utils.Cluster = {}

    --- Polygon functions
    -- @section Polygon

    --- Legacy polygon threat query.
    -- Used when HOUND.useHexGrid is false and while a sector's hex grid is
    -- still building, so membership is never left unresolved.
    -- @param polygon Table of points representing a polygon (sector zone)
    -- @param point DCS position (x,z)
    -- @param radius Radius in Meters around point to test
    -- @return[type=Bool] True if point is in the polygon
    -- @return[type=Bool] True if radius around point intersects the polygon
    function HOUND.Utils.Polygon.threatOnSectorLegacy(polygon, point, radius)
        if type(polygon) ~= "table" or #polygon < 3 or not HOUND.Utils.Dcs.isPoint(l_mist.utils.makeVec3(polygon[1])) then
            return
        end
        if not HOUND.Utils.Dcs.isPoint(point) then
            return
        end
        local inPolygon = l_mist.pointInPolygon(point,polygon)
        local intersectsPolygon = inPolygon
        if radius ~= nil and radius > 0 and l_mist.shape ~= nil then
            local circle={point=point,radius=radius}
            intersectsPolygon = l_mist.shape.insideShape(circle,polygon)
        end
        return inPolygon,intersectsPolygon
    end

    --- Distance from an XZ point to a polygon, and whether it is inside.
    -- Single pass: even-odd crossing test plus minimum segment distance.
    -- @param px point x
    -- @param pz point z
    -- @param xs polygon x coordinates (array)
    -- @param zs polygon z coordinates (array)
    -- @param n number of polygon points
    -- @return[type=Bool] True if the point is inside the polygon
    -- @return[type=number] Distance to the nearest polygon edge in meters (0 inside)
    function HOUND.Utils.Polygon.zoneDistance(px, pz, xs, zs, n)
        local inside = false
        local best = math.huge
        local prevX, prevZ = xs[n], zs[n]
        for i = 1, n do
            local curX, curZ = xs[i], zs[i]
            if (prevZ <= pz) ~= (curZ <= pz) then
                local vt = (pz - prevZ) / (curZ - prevZ)
                if px < prevX + vt * (curX - prevX) then
                    inside = not inside
                end
            end
            local dx, dz = curX - prevX, curZ - prevZ
            local l2 = dx*dx + dz*dz
            local t = 0
            if l2 > 0 then
                t = ((px - prevX) * dx + (pz - prevZ) * dz) / l2
                if t < 0 then t = 0 elseif t > 1 then t = 1 end
            end
            local ex, ez = prevX + t*dx - px, prevZ + t*dz - pz
            local d = math.sqrt(ex*ex + ez*ez)
            if d < best then best = d end
            prevX, prevZ = curX, curZ
        end
        if inside then return true, 0 end
        return false, best
    end

    --- Check if polygon is under threat of SAM
    -- Uses the sector's hex grid classification when HOUND.useHexGrid is true
    -- (default). Each contact hex is classified lazily on first sight and cached
    -- per sector with the radius it was computed at, so a radius change
    -- recomputes instead of reusing the old grid; no zone-wide cell set is built.
    -- Point-to-hex snap error is bounded by HOUND.hexRadius, which is added to
    -- the radius so a threat is never missed. Set HOUND.useHexGrid = false to
    -- restore the legacy polygon implementation.
    -- @param polygon Table of points representing a polygon (sector zone)
    -- @param point DCS position (x,z)
    -- @param radius Radius in Meters around point to test
    -- @param hexPoint Contact hex cell (Contact.Base:getHexCell); derived from point when absent
    -- @param hexCache Sector hex classification cache keyed by HOUND.Mist.hex.cellKey
    -- @param zonePoly Sector zone as {xs=..., zs=..., n=...}
    -- @return[type=Bool] True if point is in the sector zone
    -- @return[type=Bool] True if radius around point intersects the sector zone
    function HOUND.Utils.Polygon.threatOnSector(polygon, point, radius, hexPoint, hexCache, zonePoly)
        if not HOUND.useHexGrid then
            return HOUND.Utils.Polygon.threatOnSectorLegacy(polygon, point, radius)
        end
        if not zonePoly or type(hexCache) ~= "table" then
            -- no zone for this sector (default or meta sector)
            return
        end

        local hex = HOUND.Mist.hex
        if not hexPoint then
            if not HOUND.Utils.Dcs.isPoint(point) then
                return
            end
            hexPoint = hex.pointToHex(point)
        end

        local hexRadius = hex.getRadius()
        local key = hex.cellKey(hexPoint.r, hexPoint.q)
        local class = hexCache[key]
        -- the classification is resolution dependent: recompute after a radius
        -- change instead of reusing the cell geometry of the old grid
        if not class or class.radius ~= hexRadius then
            local center = hex.makeVec2(hexPoint)
            local inside, distance = HOUND.Utils.Polygon.zoneDistance(
                center.x, center.y, zonePoly.xs, zonePoly.zs, zonePoly.n)
            class = { inside = inside, distance = distance, radius = hexRadius }
            hexCache[key] = class
        end

        if class.inside then
            return true, true
        end
        return false, class.distance <= (radius or 0) + hexRadius
    end


    --- find min/max azimuth
    -- @param poly Polygon
    -- @param refPos DCS point to calculate from
    -- @return deltaMinMax delta angle between the two extream points
    -- @return minAz (rad)
    -- @return maxAz (rad)
    function HOUND.Utils.Polygon.azMinMax(poly,refPos)
        if not HOUND.Utils.Dcs.isPoint(refPos) or type(poly) ~= "table" or #poly < 2 or l_mist.pointInPolygon(refPos,poly) then
            return
        end

        local points = l_mist.utils.deepCopy(poly)
        for _,pt in pairs(points) do
            pt.refAz = l_mist.utils.getDir(l_mist.vec.sub(pt,refPos))
        end

        table.sort(points,function (a,b) return (a.refAz+PI_2) < (b.refAz+PI_2) end)
        local leftMost = table.remove(points,1)
        local rightMost = table.remove(points)
        return HOUND.Utils.angleDeltaRad(leftMost.refAz,rightMost.refAz),(leftMost),(rightMost)
    end
    --- Clustering algorithems (for future use)
    -- @section Clusters

    --- Get gaussian weight
    -- @param value input to evaluate
    -- @param bandwidth Standard diviation for weight calculation
    function HOUND.Utils.Cluster.gaussianKernel(value,bandwidth)
        if type(value) ~= "number" or type(bandwidth) ~= "number" or bandwidth <= 0 then
            return 0
        end
        return (1/(bandwidth*l_math.sqrt(2*l_math.pi))) * l_math.exp(-0.5*((value / bandwidth))^2)
    end

    --- Get a list of Nth elements centerd around a position from table of positions.
    -- @param Table A List of positions
    -- @param referencePos Point in relations to all points are evaluated
    -- @param NthPercentile Percintile of which Datapoints are taken (0.6=60%)
    -- @param returnRelative If true returning array will contain relative positions to referencePos
    -- @return List
    function HOUND.Utils.Cluster.getDeltaSubsetPercent(Table,referencePos,NthPercentile,returnRelative)
        if type(Table) ~= "table" then return {} end
        -- local t = l_mist.utils.deepCopy(Table)
        -- t = HOUND.Utils.Geo.setHeight(t)
        -- shallow copy to reduce overhead
        local t = {}
        for _,pt in ipairs(Table) do
            table.insert(t, { x = pt.x, y = pt.y or 0, z = pt.z, dist = 0, score = pt.score})
        end
        local len_t = #t
        if len_t == 0 then return {} end
        if type(NthPercentile) ~= "number" then
            NthPercentile = 1
        end

        if not referencePos then
            referencePos = l_mist.getAvgPoint(t)
        end
        for _,pt in ipairs(t) do
            pt.dist = l_mist.utils.get2DDist(referencePos,pt)
        end
        table.sort(t,function(a,b) return a.dist < b.dist end)

        local percentile = l_math.floor(len_t*NthPercentile)
        local NumToUse = l_math.max(l_math.min(2,len_t),l_math.min(percentile,len_t))
        local returnTable = {}
        for i = 1, NumToUse  do
            table.insert(returnTable,t[i])
        end
        if returnRelative then
            for i = 1,#returnTable do
                returnTable[i] = l_mist.vec.sub(returnTable[i],referencePos)
            end
        end

        return returnTable
    end

    --- Calculate weighted least squares estimate from a list of positions with scores
    -- @param PosList List of positions with scores
    -- @return Weighted average position estimate {x,y,z}
    function HOUND.Utils.Cluster.WeightedCentroid(PosList)
        if type(PosList) ~= "table" then
            return {x = 0, y = 0, z = 0}
        end
        local sumWeights = 0
        local estimate = {z=0,x=0}
        for _,pos in ipairs(PosList) do
            if HOUND.Utils.Dcs.isPoint(pos) and type(pos.score) == "number" and pos.score > 0 then
                local w = pos.score
                sumWeights = sumWeights + w
                estimate.z = estimate.z + (w * (pos.z - estimate.z)) / sumWeights
                estimate.x = estimate.x + (w * (pos.x - estimate.x)) / sumWeights
            end
        end
        -- DCS land.getHeight uses a Vec2 {x=,y=} where 'y' is the z-axis coordinate
        estimate.y = land.getHeight({x=estimate.x, y=estimate.z}) or 0
        return estimate
    end
end