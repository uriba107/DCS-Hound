    --- HOUND.Utils
    -- This class holds generic function used by all of Hound Components
    -- @module HOUND.Utils
do
    local l_mist = HOUND.Mist
    local l_math = math
    local l_grpc = GRPC
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

    --- Filter out points not in polygon
    -- @param points Points to filter
    -- @param polygon - enclosing polygon to filter by
    -- @return points from original set which are inside polygon.
    function HOUND.Utils.Polygon.filterPointsByPolygon(points,polygon)
        local filteredPoints = {}
        if type(points) ~= "table" or type(polygon) ~= "table" then return filteredPoints end

        for _,point in pairs(points) do
            if l_mist.pointInPolygon(point,polygon) then
                table.insert(filteredPoints,point)
            end
        end
        return filteredPoints
    end

    --- calculate cliping of polygons
    -- <a href="https://rosettacode.org/wiki/Sutherland-Hodgman_polygon_clipping#Lua">Sutherland-Hodgman polygon clipping</a>
    -- @param  subjectPolygon List of points of first polygon
    -- @param  clipPolygon list of points of second polygon
    -- @return List of points of the clipped polygon or nil if not clipping found
    function HOUND.Utils.Polygon.clipPolygons(subjectPolygon, clipPolygon)
        local function inside (p, cp1, cp2)
            return (cp2.x-cp1.x)*(p.z-cp1.z) > (cp2.z-cp1.z)*(p.x-cp1.x)
        end

        local function intersection (cp1, cp2, s, e)
            local dcx, dcz = cp1.x-cp2.x, cp1.z-cp2.z
            local dpx, dpz = s.x-e.x, s.z-e.z
            local n1 = cp1.x*cp2.z - cp1.z*cp2.x
            local n2 = s.x*e.z - s.z*e.x
            local n3 = 1 / (dcx*dpz - dcz*dpx)
            local x = (n1*dpx - n2*dcx) * n3
            local z = (n1*dpz - n2*dcz) * n3
            return {x=x, z=z}
        end

        if type(subjectPolygon) ~= "table" or type(clipPolygon) ~= "table" then return end

        local outputList = subjectPolygon
        local cp1 = clipPolygon[#clipPolygon]
        for _, cp2 in ipairs(clipPolygon) do  -- WP clipEdge is cp1,cp2 here
        local inputList = outputList
        outputList = {}
        local s = inputList[#inputList]
        for _, e in ipairs(inputList) do
            if inside(e, cp1, cp2) then
            if not inside(s, cp1, cp2) then
                outputList[#outputList+1] = intersection(cp1, cp2, s, e)
            end
            outputList[#outputList+1] = e
            elseif inside(s, cp1, cp2) then
            outputList[#outputList+1] = intersection(cp1, cp2, s, e)
            end
            s = e
        end
        cp1 = cp2
        end
        if HOUND.Length(outputList) > 0 then
            return outputList
        end
        return nil
    end

    --- Gift wrapping algorithem
    -- Returns the convex hull (using <a href="http://en.wikipedia.org/wiki/Gift_wrapping_algorithm">Jarvis' Gift wrapping algorithm</a>).
    -- @param points array of DCS points ({x=&ltvalue&gt,z=&ltvalue&gt})
    -- @return the convex hull as an array of points
    function HOUND.Utils.Polygon.giftWrap(points)
        -- Calculates the signed area
        local function signedArea(p, q, r)
            local cross = (q.z - p.z) * (r.x - q.x)
                        - (q.x - p.x) * (r.z - q.z)
            return cross
        end
        -- Checks if points p, q, r are oriented counter-clockwise
        local function isCCW(p, q, r) return signedArea(p, q, r) < 0 end

        -- We need at least 3 points
        local numPoints = #points
        if numPoints < 3 then
            return
        end

        -- Find the left-most point
        local leftMostPointIndex = 1
        for i = 1, numPoints do
            if points[i].x < points[leftMostPointIndex].x then
                leftMostPointIndex = i
            end
        end

        local p = leftMostPointIndex
        local hull = {} -- The convex hull to be returned

        -- Process CCW from the left-most point to the start point
        repeat
            -- Find the next point q such that (p, i, q) is CCW for all i
            local q = points[p + 1] and p + 1 or 1
            for i = 1, numPoints, 1 do
                if isCCW(points[p], points[i], points[q]) then q = i end
            end

            table.insert(hull, points[q]) -- Save q to the hull
            p = q  -- p is now q for the next iteration
        until (p == leftMostPointIndex)

        return hull
    end

    --- calculate Smallest circle around point cloud
    -- Welzel algorithm for <a href="https://en.wikipedia.org/wiki/Smallest-circle_problem">Smallest-circle problem</a>
    -- Implementation taken from <a href="https://github.com/rowanwins/smallest-enclosing-circle/blob/master/src/main.js">github/rowins</a>
    -- @param points Table containing cloud points
    -- @return Circle {x=&ltCenter X&gt,z=&ltCenter Z&gt, y=&ltLand height at XZ&gt,r=&ltradius in meters&gt}
    function HOUND.Utils.Polygon.circumcirclePoints(points)
        local function calcCircle(p1,p2,p3)
            local cx,cz, r
            if HOUND.Utils.Dcs.isPoint(p1) and not p2 and not p3 then
                return {x = p1.x, z = p1.z,r = 0}
            end
            if HOUND.Utils.Dcs.isPoint(p1) and HOUND.Utils.Dcs.isPoint(p2) and not p3 then
                cx = 0.5 * (p1.x + p2.x)
                cz = 0.5 * (p1.z + p2.z)
            else
                local a = p2.x - p1.x
                local b = p2.z - p1.z
                local c = p3.x - p1.x
                local d = p3.z - p1.z
                local e = a * (p2.x + p1.x) * 0.5 + b * (p2.z + p1.z) * 0.5
                local f = c * (p3.x + p1.x) * 0.5 + d * (p3.z + p1.z) * 0.5
                local det = a * d - b * c

                cx = (d * e - b * f) / det
                cz = (-c * e + a * f) / det
            end

            r = l_math.sqrt((p1.x - cx) * (p1.x - cx) + (p1.z - cz) * (p1.z - cz))
            -- env.info("x: " .. cx .. ", z: " .. cz.. ", r: " .. r)
            return {x=cx,z=cz,r=r}
        end

        local function isInCircle(p,c)
            return ((c.x - p.x) * (c.x - p.x) + (c.z - p.z) * (c.z - p.z) <= c.r * c.r)
        end

        local function shuffle(a)
            for i = #a, 2, -1 do
                local j = l_math.random(i)
                a[i], a[j] = a[j], a[i]
            end
            return a
        end

        local function mec(pts,n,boundary,b)
            local circle
            if b == 3 then
                circle = calcCircle(boundary[1],boundary[2],boundary[3])
            elseif (n == 1) and (b == 0) then circle = calcCircle(pts[1])
            elseif (n == 0) and (b == 2) then circle = calcCircle(boundary[1], boundary[2])
            elseif (n == 1) and (b == 1) then circle = calcCircle(boundary[1], pts[1])
            else
                circle = mec(pts, n-1, boundary, #boundary)
                if ( not isInCircle(pts[n], circle)) then
                    boundary[b+1] = pts[n]
                    circle = mec(pts, n-1, boundary, #boundary)
                end
            end
            return circle
        end

        local clonedPoints = l_mist.utils.deepCopy(points)
        shuffle(clonedPoints)
        return mec(clonedPoints, #points, {}, 0)
    end

    --- return the area of a convex polygon
    -- @param polygon list of DCS points
    -- @return area of polygon
    function HOUND.Utils.Polygon.getArea(polygon)
        if not polygon or type(polygon) ~= "table" or HOUND.Length(polygon) < 2 then return 0 end
        local a,b = 0,0
        for i=1,HOUND.Length(polygon)-1 do
            a = a + polygon[i].x * polygon[i+1].z
            b = b + polygon[i].z * polygon[i+1].x
        end
        a = a + polygon[HOUND.Length(polygon)].x * polygon[1].z
        b = b + polygon[HOUND.Length(polygon)].z * polygon[1].x
        return l_math.abs((a-b)/2)
    end

    --- clip or hull two polygons
    -- @param polyA polygon
    -- @param polyB polygon
    -- @return Polygon which is clip or convexHull of the two input polygons
    function HOUND.Utils.Polygon.clipOrHull(polyA,polyB)
        -- make sure polyA is always the larger one
        if HOUND.Utils.Polygon.getArea(polyA) < HOUND.Utils.Polygon.getArea(polyB) then
            polyA,polyB = polyB,polyA
        end
        local polygon = HOUND.Utils.Polygon.clipPolygons(polyA,polyB)
        if Polygon == nil then
            local points = l_mist.utils.deepCopy(polyA)
            for _,point in pairs(polyB) do
                table.insert(points,l_mist.utils.deepCopy(point))
            end
            polygon = HOUND.Utils.Polygon.giftWrap(points)
        end
        return polygon
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

    --- Calculate running std dev
    -- @return std calc instance
    -- https://en.wikipedia.org/wiki/Algorithms_for_calculating_variance#Welford's_online_algorithm
    function HOUND.Utils.Cluster.stdDev()
        local instance = {}
        instance.count = 0
        instance.mean = 0
        instance.M2 = 0
        instance.update = function(self,value)
            self.count = self.count + 1
            local delta = value - self.mean
            self.mean = self.mean + (delta / self.count)
            local delta2 = value - self.mean
            self.M2 = self.M2 + (delta * delta2)
        end
        instance.get = function (self)
            if self.count < 2 then return nil end
            return {
                mean = self.mean,
                variance = (self.M2/self.count),
                sampleVariance = (self.M2/(self.count-1))
            }
        end
        return instance
    end

    --- find the weighted mean of a points cluster (meanShift)
    -- @param origPoints DCS points cluster
    -- @param[opt] initPos externally provided initial mean (DCS Point)
    -- @param[opt] threashold distance in meters below with solution is considered converged (default 1m)
    -- @param[opt] maxIttr Max itterations from converging solution (default 100)
    -- @return DCS point of the cluster weighted mean

    function HOUND.Utils.Cluster.weightedMean(origPoints,initPos,threashold,maxIttr)
        if type(origPoints) ~= "table" or not HOUND.Utils.Dcs.isPoint(origPoints[1]) then return end
        local points = HOUND.Utils.Geo.setHeight(l_mist.utils.deepCopy(origPoints))
        if HOUND.Length(points) == 1 then return l_mist.utils.deepCopy(points[1]) end

        local current_mean = initPos
        if type(current_mean) == "boolean" and current_mean then
            current_mean = points[l_math.random(HOUND.Length(points))]
        end
        if not HOUND.Utils.Dcs.isPoint(current_mean) then
            current_mean = l_mist.getAvgPoint(origPoints)
        end
        if not HOUND.Utils.Dcs.isPoint(current_mean) then return end
        threashold = threashold or 1
        maxIttr = maxIttr or 100
        local last_mean
        local ittr = 0
        local converged = false

        while not converged do
            last_mean = l_mist.utils.deepCopy(current_mean)
            local totalDist = 0
            local totalInvWeight = 0
            -- calculate dists
            for _,point in pairs(points) do
                point.dist = l_mist.utils.get2DDist(last_mean,point)
                totalDist = totalDist + point.dist
            end
            -- table.sort(points,function (a,b) return a.dist < b.dist end )
            for _,point in pairs(points) do
                point.w = 1/(point.dist/totalDist)
                totalInvWeight = totalInvWeight + point.w
            end

            for _,point in pairs(points) do
                local weight = point.w/totalInvWeight
                current_mean = l_mist.vec.add(current_mean,l_mist.vec.scalar_mult(l_mist.vec.sub(point,current_mean),weight))
            end
            ittr = ittr + 1
            converged = l_mist.utils.get2DDist(last_mean,current_mean) < threashold or ittr == maxIttr
        end
        HOUND.Utils.Geo.setHeight(current_mean)
        return l_mist.utils.deepCopy(current_mean)
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
end