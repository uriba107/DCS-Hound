    --- HOUND.Contact.Datapoint
    -- @module HOUND.Contact.Datapoint
do
    local l_math = math
    local l_mist = mist
    local PI_2 = 2*l_math.pi

    --- @table HOUND.Contact.Datapoint
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

    -- @type HOUND.Contact.Datapoint
    HOUND.Contact.Datapoint = {}
    HOUND.Contact.Datapoint.__index = HOUND.Contact.Datapoint
    HOUND.Contact.Datapoint.DataPointId = 0

    --- Create new HOUND.Contact.Datapoint instance
    -- @param platform0 DCS Unit of locating platform
    -- @param p0 Position of platform on detection
    -- @param az0 Azimuth (rad) from platform to emitter
    -- @param el0 Elevation (rad) from platform to emitter
    -- @param t0 Abs time of datapoint
    -- @param[opt] angularResolution angular resolution of datapoint
    -- @param[opt] isPlatformStatic (bool)
    -- @return Datapoint instance
    function HOUND.Contact.Datapoint.New(platform0, p0, az0, el0, t0, angularResolution, isPlatformStatic)
        local elintDatapoint = {}
        setmetatable(elintDatapoint, HOUND.Contact.Datapoint)
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
        elintDatapoint.processed = false
        if elintDatapoint.platformStatic then
            elintDatapoint.kalman = HOUND.Contact.Estimator.Kalman.AzFilter(elintDatapoint.platformPrecision)
            elintDatapoint:update(elintDatapoint.az)
        end
        if HOUND.DEBUG then
            elintDatapoint.id = elintDatapoint.getId()
        end
        return elintDatapoint
    end

    --- check if platform is static
    -- @return Bool True if platform is static
    function HOUND.Contact.Datapoint.isStatic(self)
        return self.platformStatic
    end

    --- Get estimated position
    -- @return DCS point
    function HOUND.Contact.Datapoint.getPos(self)
        return self.estimatedPos
    end

    --- Get datapoint age in seconds
    -- @return time in seconds
    function HOUND.Contact.Datapoint.getAge(self)
        return HOUND.Utils.absTimeDelta(self.t)
    end

    --- Get 2D polygon
    -- @return table of DCS points
    function HOUND.Contact.Datapoint.get2dPoly(self)
        return self.posPolygon['2D']
    end

    --- Get 3D polygon
    -- @return table of DCS points
    function HOUND.Contact.Datapoint.get3dPoly(self)
        return self.posPolygon['3D']
    end

    --- Get 3D polygon ellipse parameters
    -- @return table of ellipse parameters
    function HOUND.Contact.Datapoint.getEllipseParams(self)
        return self.posPolygon['EllipseParams']
    end

    --- Get computed error table
    -- @return error table
    function HOUND.Contact.Datapoint.getErrors(self)
        if type(self.err) ~= "table" then
            self:calcError()
        end
        return self.err
    end

    --- Estimate contact position from Datapoint information only
    -- @local
    function HOUND.Contact.Datapoint.estimatePos(self)
        if self.el == nil or l_math.abs(self.el) <= self.platformPrecision then return end
        -- local maxSlant = HOUND.Utils.Geo.EarthLOS(self.platformPos.y)*0.8
        -- local point = HOUND.Utils.Geo.getProjectedIP(self.platformPos,self.az,self.el)
        -- if not HOUND.Utils.Geo.isDcsPoint(point) then
        --     point = {x=maxSlant*l_math.cos(self.az) + self.platformPos.x,z=maxSlant*l_math.sin(self.az) + self.platformPos.z}
        -- end
        return HOUND.Utils.Geo.getProjectedIP(self.platformPos,self.az,self.el)
    end

    --- generate Az only Triangle and if possible Az/El polygon footprint
    -- @local
    -- Polygons are made for Sutherland–Hodgman pollygon clipping algorithm so they are all counter-clockwise
    -- @return 2D Polygon
    -- @return 3D Polygon
    -- @return Ellipse parametes for 3D Polygon (theta,major,minor)
    function HOUND.Contact.Datapoint.calcPolygons(self)
        if self.platformPrecision == 0 then return nil,nil end
        -- calc 2D az triangle
        local maxSlant = l_math.min(250000,HOUND.Utils.Geo.EarthLOS(self.platformPos.y)*1.1)
        local poly2D = {}
        table.insert(poly2D,self.platformPos)
        for _,theta in ipairs({((self.az - self.platformPrecision + PI_2) % PI_2),((self.az + self.platformPrecision + PI_2) % PI_2) }) do
            local point = {}
            point.x = maxSlant*l_math.cos(theta) + self.platformPos.x
            point.z = maxSlant*l_math.sin(theta) + self.platformPos.z
            -- point.y = land.getHeight({x=point.x,y=point.z})+0.5
            table.insert(poly2D,point)
        end
        HOUND.Utils.Geo.setHeight(poly2D)
        -- if self.platformStatic then
        --     mist.marker.add({pos={poly2D[1],poly2D[3]},markType="line"})
        -- end

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
            local point = HOUND.Utils.Geo.getProjectedIP(self.platformPos, azStep,elStep) or {x=maxSlant*l_math.cos(azStep) + self.platformPos.x,z=maxSlant*l_math.sin(azStep) + self.platformPos.z}
            if not point.y then
                point = HOUND.Utils.Geo.setHeight(point)
            end

            if HOUND.Utils.Geo.isDcsPoint(point) and HOUND.Utils.Geo.isDcsPoint(self:getPos()) then
                table.insert(poly3D,point)
                if i == numSteps/4 then
                    ellipse.minor = point
                elseif i == numSteps/2 then
                    ellipse.major = point
                    ellipse.majorCG = l_mist.utils.get2DDist(self:getPos(),point)
                elseif i == 3*(numSteps/4) then
                    if HOUND.Utils.Geo.isDcsPoint(ellipse.minor) then
                        ellipse.minor = l_mist.utils.get2DDist(ellipse.minor,point)
                    end
                elseif i == numSteps then
                    if HOUND.Utils.Geo.isDcsPoint(ellipse.major) then
                        ellipse.major = l_mist.utils.get2DDist(ellipse.major,point)
                        ellipse.majorCG = ellipse.majorCG / (ellipse.majorCG + l_mist.utils.get2DDist(self:getPos(),point))
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

    --- calculate errors on 3dPoly
    function HOUND.Contact.Datapoint.calcError(self)
        if type(self.posPolygon["EllipseParams"]) == "table" and self.posPolygon["EllipseParams"].theta then
        local ellipse = self.posPolygon['EllipseParams']
        if ellipse.theta then
            local sinTheta = l_math.sin(ellipse.theta)
            local cosTheta = l_math.cos(ellipse.theta)
            self.err = {
                x = l_math.max(l_math.abs(ellipse.minor/2*cosTheta), l_math.abs(-ellipse.major/2*sinTheta)),
                z = l_math.max(l_math.abs(ellipse.minor/2*sinTheta), l_math.abs(ellipse.major/2*cosTheta))
            }
            self.err.score = {
                x = HOUND.Contact.Estimator.accuracyScore(self.err.x),
                z = HOUND.Contact.Estimator.accuracyScore(self.err.z)
            }
        end


        end
    end
    --- Smooth azimuth using Kalman filter
    -- @local
    -- @param self Datapoint instance
    -- @param newAz new Az input
    -- @param[opt] predictedAz predicted azimuth
    -- @param[opt] processNoise Process noise
    function HOUND.Contact.Datapoint.update(self,newAz,predictedAz,processNoise)
        if not self.platformPrecision and not self.platformStatic then return end
        self.kalman:update(newAz,nil,processNoise)
        self.az = self.kalman:get()
        self.posPolygon["2D"],self.posPolygon["3D"] = self:calcPolygons()
        return self.az
    end

    --- Assign id for each Datapoint for debugging
    -- @local
    -- @return DatapointId (number)
    function HOUND.Contact.Datapoint.getId()
        HOUND.Contact.Datapoint.DataPointId = HOUND.Contact.Datapoint.DataPointId + 1
        return HOUND.Contact.Datapoint.DataPointId
    end
end
