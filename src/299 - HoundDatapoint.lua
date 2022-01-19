    --- HoundDatapoint
    -- @module HoundDatapoint
do
    local l_math = math
    local l_mist = mist
    local PI_2 = 2*l_math.pi

    --- @table HoundDatapoint
    -- @field platformPos position of platform at time of sample
    -- @field az Azimuth from platformPos to emitter
    -- @field el Elevation from platfromPos to emitter
    -- @field t Time of sample
    -- @field platformId uid of platform DCS unit
    -- @field platformName Name of platform DCS unit
    -- @field platformStatic True if platform is static object
    -- @field platformPrecision Angular resolution of platform in radians
    -- @field estimatedPos estimated position of emitter from AZ/EL (if applicable)
    -- @field posPolygon.2D estimated position polygon from AZ only info
    -- @field posPolygon.3D estimated position polygon from AZ/EL info (if applicable)

    -- @type HoundDatapoint
    HoundDatapoint = {}
    HoundDatapoint.__index = HoundDatapoint
    HoundDatapoint.DataPointId = 0

    --- Create new HoundDatapoint instance
    -- @param platform0 DCS Unit of locating platform
    -- @param p0 Position of platform on detection
    -- @param az0 Azimuth (rad) from platform to emitter
    -- @param el0 Elevation (rad) from platform to emitter
    -- @param t0 Abs time of datapoint
    -- @param[opt] angularResolution angular resolution of datapoint
    -- @param[opt] isPlatformStatic (bool)
    -- @return Datapoint instance
    function HoundDatapoint.New(platform0, p0, az0, el0, t0, angularResolution, isPlatformStatic)
        local elintDatapoint = {}
        setmetatable(elintDatapoint, HoundDatapoint)
        elintDatapoint.platformPos = p0
        elintDatapoint.az = az0
        elintDatapoint.el = el0
        elintDatapoint.t = tonumber(t0)
        elintDatapoint.platformId = platform0:getID()
        elintDatapoint.platformName = platform0:getName()
        elintDatapoint.platformStatic = isPlatformStatic or false
        elintDatapoint.platformPrecision = angularResolution or l_math.rad(20)
        elintDatapoint.estimatedPos = elintDatapoint:estimatePos()
        elintDatapoint.posPolygon = {}
        elintDatapoint.posPolygon["2D"],elintDatapoint.posPolygon["3D"],elintDatapoint.posPolygon["EllipseParams"] = elintDatapoint:calcPolygons()
        elintDatapoint.kalman = nil
        if elintDatapoint.platformStatic then
            elintDatapoint.kalman = HoundEstimator.Kalman.AzFilter(elintDatapoint.platformPrecision)
            elintDatapoint:update(elintDatapoint.az)
        end
        if HOUND.DEBUG then
            elintDatapoint.id = elintDatapoint.getId()
        end
        return elintDatapoint
    end

    --- check if platform is static
    -- @return Bool True if platform is static
    function HoundDatapoint.isStatic(self)
        return self.platformStatic
    end

    --- Get estimated position
    -- @return DCS point
    function HoundDatapoint.getPos(self)
        return self.estimatedPos
    end

    --- Get 2D polygon
    -- @return table of DCS points
    function HoundDatapoint.get2dPoly(self)
        return self.posPolygon['2D']
    end

    --- Get 3D polygon
    -- @return table of DCS points
    function HoundDatapoint.get3dPoly(self)
        return self.posPolygon['3D']
    end

    --- Get 3D polygon ellipse parameters
    -- @return table of ellipse parameters
    function HoundDatapoint.getEllipseParams(self)
        return self.posPolygon['EllipseParams']
    end

    --- Estimate contact position from Datapoint information only
    -- @local
    function HoundDatapoint.estimatePos(self)
        if self.el == nil or l_math.abs(self.el) <= self.platformPrecision then return end
        -- local maxSlant = self.platformPos.y/l_math.abs(l_math.sin(self.el))
        -- local unitVector = HoundUtils.Vector.getUnitVector(self.az,self.el)
        -- local point =land.getIP(self.platformPos, unitVector , maxSlant+100 )
        -- self.estimatedPos = point
        return HoundUtils.Geo.getProjectedIP(self.platformPos,self.az,self.el)
    end

    --- generate Az only Triangle and if possible Az/El polygon footprint
    -- @local
    -- Polygons are made for Sutherland–Hodgman pollygon clipping algorithm so they are all counter-clockwise
    -- @return 2D Polygon
    -- @return 3D Polygon
    -- @return Ellipse parametes for 3D Polygon (theta,major,minor)
    function HoundDatapoint.calcPolygons(self)
        if self.platformPrecision == 0 then return nil,nil end
        -- calc 2D az triangle
        local maxSlant = HoundUtils.Geo.EarthLOS(self.platformPos.y)*1.2
        local poly2D = {}
        table.insert(poly2D,self.platformPos)
        for _,theta in ipairs({((self.az - self.platformPrecision + PI_2) % PI_2),((self.az + self.platformPrecision + PI_2) % PI_2) }) do
            local point = {}
            point.x = maxSlant*l_math.cos(theta) + self.platformPos.x
            point.z = maxSlant*l_math.sin(theta) + self.platformPos.z
            -- point.y = land.getHeight({x=point.x,y=point.z})+0.5
            table.insert(poly2D,point)
        end
        if self.el == nil then return poly2D end
        -- calc 3d Az/El polygon
        local poly3D = {}
        local ellipse = {
            theta = self.az
        }

        local numSteps = 16
        local angleStep = PI_2/numSteps
        for i = 1,numSteps do
            local pointAngle = (i*angleStep)
            local azStep = self.az + (self.platformPrecision * l_math.sin(pointAngle))
            local elStep = self.el + (self.platformPrecision * l_math.cos(pointAngle))
            local point = HoundUtils.Geo.getProjectedIP(self.platformPos, azStep,elStep) or {x=maxSlant*l_math.cos(azStep) + self.platformPos.x,z=maxSlant*l_math.sin(azStep) + self.platformPos.z}
            if not point.y then
                point = HoundUtils.Geo.setHeight(point)
            end

            if point then
                table.insert(poly3D,point)
                if i == numSteps/4 then
                    ellipse.minor = point
                elseif i == numSteps/2 then
                    ellipse.major = point
                elseif i == 3*(numSteps/4) then
                    if HoundUtils.Geo.isDcsPoint(ellipse.minor) then
                        ellipse.minor = l_mist.utils.get2DDist(ellipse.minor,point)
                    end
                elseif i == numSteps then
                    if HoundUtils.Geo.isDcsPoint(ellipse.major) then
                        ellipse.major = l_mist.utils.get2DDist(ellipse.major,point)
                    end
                end
            end
        end
        if type(ellipse.minor) ~= "number" or type(ellipse.major) ~= "number" then
            ellipse = {}
        end

        -- mist.marker.add({pos=poly3D,markType="freeform"})
        -- self.posPolygon["3D"] = poly3D
        return poly2D,poly3D,ellipse
    end

    --- Smooth azimuth using Kalman filter
    -- @local
    -- @param self Datapoint instance
    -- @param newAz new Az input
    -- @param predictedAz predicted azimuth
    function HoundDatapoint.update(self,newAz,predictedAz)
        if not self.platformPrecision and not self.platformStatic then return end
        self.kalman:update(newAz,predictedAz)
        self.az = self.kalman:get()
        self.posPolygon["2D"],self.posPolygon["3D"] = self:calcPolygons()
        return self.az
    end

    --- Assign id for each Datapoint for debugging
    -- @local
    -- @return DatapointId (number)
    function HoundDatapoint.getId()
        HoundDatapoint.DataPointId = HoundDatapoint.DataPointId + 1
        return HoundDatapoint.DataPointId
    end
end
