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

    --- Check if polygon is under threat of SAM
    -- @param polygon Table of point reprasenting a polygon
    -- @param point DCS position (x,z)
    -- @param radius Radius in Meters around point to test
    -- @return[type=Bool] True if point is in polygon
    -- @return[type=Bool] True if radius around point intersects polygon
    function HOUND.Utils.Polygon.threatOnSector(polygon,point, radius)
        if type(polygon) ~= "table" or HOUND.Length(polygon) < 3 or not HOUND.Utils.Dcs.isPoint(l_mist.utils.makeVec3(polygon[1])) then
            return
        end
        if not HOUND.Utils.Dcs.isPoint(point) then
            return
        end
        local inPolygon = l_mist.pointInPolygon(point,polygon)
        local intersectsPolygon = inPolygon

        if radius ~= nil and radius > 0 and l_mist.shape ~= nil then
            -- if mist version in use contains shapesOverlap use it. (4.5.103?)
            local circle={point=point,radius=radius}
            intersectsPolygon = l_mist.shape.insideShape(circle,polygon)
        end
        return inPolygon,intersectsPolygon
    end


    --- find min/max azimuth
    -- @param poly Polygon
    -- @param refPos DCS point to calculate from
    -- @return deltaMinMax delta angle between the two extream points
    -- @return minAz (rad)
    -- @return maxAz (rad)
    function HOUND.Utils.Polygon.azMinMax(poly,refPos)
        if not HOUND.Utils.Dcs.isPoint(refPos) or type(poly) ~= "table" or HOUND.Length(poly) < 2 or l_mist.pointInPolygon(refPos,poly) then
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
        return (1/(bandwidth*l_math.sqrt(2*l_math.pi))) * l_math.exp(-0.5*((value / bandwidth))^2)
    end

    --- Get a list of Nth elements centerd around a position from table of positions.
    -- @param Table A List of positions
    -- @param referencePos Point in relations to all points are evaluated
    -- @param NthPercentile Percintile of which Datapoints are taken (0.6=60%)
    -- @param returnRelative If true returning array will contain relative positions to referencePos
    -- @return List
    function HOUND.Utils.Cluster.getDeltaSubsetPercent(Table,referencePos,NthPercentile,returnRelative)
        local t = l_mist.utils.deepCopy(Table)
        local len_t = HOUND.Length(t)
        t = HOUND.Utils.Geo.setHeight(t)
        if not referencePos then
            referencePos = l_mist.getAvgPoint(t)
        end
        for _,pt in ipairs(t) do
            pt.dist = l_mist.utils.get2DDist(referencePos,pt)
        end
        table.sort(t,function(a,b) return a.dist < b.dist end)

        local percentile = l_math.floor(len_t*NthPercentile)
        local NumToUse = l_math.max(l_math.min(2,len_t),percentile)
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
        local sumWeights = 0
        local estimate = {z=0,x=0}
        for _,pos in ipairs(PosList) do
            if HOUND.Utils.Dcs.isPoint(pos) and pos.score > 0 then
                local w = pos.score
                sumWeights = sumWeights + w
                estimate.z = estimate.z + (w * (pos.z - estimate.z)) / sumWeights
                estimate.x = estimate.x + (w * (pos.x - estimate.x)) / sumWeights
            end
        end
        estimate.y = land.getHeight({x=estimate.x, y=estimate.z}) or 0
        return estimate
    end
end