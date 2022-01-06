    --- HoundDatapoint
    -- @module HoundDatapoint
do
    local l_math = math
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

    --- @type HoundDatapoint
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
        elintDatapoint.posPolygon["2D"],elintDatapoint.posPolygon["3D"] = elintDatapoint:calcPolygons()
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

    --- Estimate contact position from Datapoint information only
    -- @local
    function HoundDatapoint.estimatePos(self)
        if self.el == nil or l_math.abs(self.el) <= self.platformPrecision then return end
        local maxSlant = self.platformPos.y/l_math.abs(l_math.sin(self.el))
        local unitVector = HoundUtils.Vector.getUnitVector(self.az,self.el)
        local point =land.getIP(self.platformPos, unitVector , maxSlant+100 )
        -- self.estimatedPos = point
        return point
    end

    --- generate Az only Triangle and if possible Az/El polygon footprint
    -- @local
    -- Polygons are made for Sutherland–Hodgman pollygon clipping algorithm so they are all counter-clockwise
    function HoundDatapoint.calcPolygons(self)
        if self.platformPrecision == 0 then return nil,nil end
        -- calc 2D az triangle
        local maxSlant = HoundUtils.EarthLOS(self.platformPos.y)*1.2
        local poly2D = {}
        table.insert(poly2D,self.platformPos)
        for _,theta in ipairs({((self.az - self.platformPrecision + PI_2) % PI_2),((self.az + self.platformPrecision + PI_2) % PI_2) }) do
            local point = {}
            point.x = maxSlant*l_math.cos(theta) + self.platformPos.x
            point.z = maxSlant*l_math.sin(theta) + self.platformPos.z
            -- point.y = land.getHeight({x=point.x,y=point.z})+0.5
            table.insert(poly2D,point)
        end
        -- mist.marker.add({pos=poly2D,markType="freeform"})

        -- self.posPolygon["2D"] = poly2D
        if self.el == nil then return poly2D end
        -- calc 3d Az/El polygon
        local poly3D = {}

        local numSteps = 16
        local angleStep = PI_2/numSteps
        -- for pointAngle = angleStep, PI_2+angleStep/8, angleStep do
        for i = 1,numSteps do
            local pointAngle = (i*angleStep)
            local azStep = self.az + (self.platformPrecision * l_math.sin(pointAngle))
            local elStep = self.el + (self.platformPrecision * l_math.cos(pointAngle))
            local point = land.getIP(self.platformPos, HoundUtils.Vector.getUnitVector(azStep,elStep) , maxSlant)
            if point then
                table.insert(poly3D,point)
            end
        end
        -- mist.marker.add({pos=poly3D,markType="freeform"})
        -- self.posPolygon["3D"] = poly3D
        return poly2D,poly3D
    end

    --- Smooth azimuth using Kalman filter
    -- @local
    -- @param self Datapoint instance
    -- @param newAz new Az input
    function HoundDatapoint.AzKalman(self,newAz)
        if not self.platformPrecision and not self.platformStatic then return end
        if not self.kalman then
            self.kalman = {}
            self.kalman.P = 1
        end

        self.kalman.K = self.kalman.P / (self.kalman.P+self.platformPrecision)
        self.az = ((self.az + self.kalman.K * (newAz-self.az)) + PI_2) % PI_2
        self.kalman.P = (1-self.kalman.K)
        self.posPolygon["2D"],_ = self:calcPolygons()
        -- HoundLogger.trace(self.platformName.."(" .. self.id .. ") Kalman: z="..math.deg(newAz).." | out="..math.deg(self.az).." | vars=".. mist.utils.tableShow(self.kalman) )
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
