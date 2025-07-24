    --- HOUND.Contact.Datapoint
    -- @module HOUND.Contact.Datapoint
do
    local l_math = math
    local HoundUtils = HOUND.Utils

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
    -- @param s0 signal strength as detected by the platform
    -- @param t0 Abs time of datapoint
    -- @param[opt] angularResolution angular resolution of datapoint
    -- @param[opt] isPlatformStatic (bool)
    -- @return Datapoint instance
    function HOUND.Contact.Datapoint.New(platform0, p0, az0, el0, s0, t0, angularResolution, isPlatformStatic)
        local elintDatapoint = {}
        setmetatable(elintDatapoint, HOUND.Contact.Datapoint)
        elintDatapoint.platformPos = p0
        elintDatapoint.az = az0
        elintDatapoint.el = el0
        elintDatapoint.signalStrength = tonumber(s0) or 0
        elintDatapoint.t = tonumber(t0)
        elintDatapoint.platformId = tonumber(platform0:getID())
        elintDatapoint.platformName = platform0:getName()
        elintDatapoint.platformStatic = isPlatformStatic or false
        elintDatapoint.platformPrecision = angularResolution or l_math.rad(HOUND.MAX_ANGULAR_RES_DEG)
        elintDatapoint.kalman = nil
        elintDatapoint.processed = false
        if elintDatapoint.platformStatic then
            elintDatapoint.kalman = HOUND.Contact.Estimator.Kalman.AzFilter(elintDatapoint.platformPrecision)
            elintDatapoint:update(elintDatapoint.az)
        end
        -- if HOUND.DEBUG then
        --     elintDatapoint.id = elintDatapoint.getId()
        -- end
        return elintDatapoint
    end

    --- check if platform is static
    -- @return[type=Bool] True if platform is static
    function HOUND.Contact.Datapoint.isStatic(self)
        return self.platformStatic
    end

    --- Get datapoint age in seconds
    -- @return time in seconds
    function HOUND.Contact.Datapoint.getAge(self)
        return HoundUtils.absTimeDelta(self.t)
    end

    --- Get datapoint projected position
    -- @return[type=table] DCS point
    function HOUND.Contact.Datapoint.getPos(self)
        if self.kalman then
            return self.kalman:getValue().pos or nil
        end
        if not self.az and not self.el then return end
        self.pos = HoundUtils.Geo.getProjectedIP(self.platformPos, self.az, self.el)
        if not HountUtils.Dcs.isPoint(self.pos) then
            self.pos = HoundUtils.Geo.getProjectedIP(self.platformPos, self.az, (self.el - (self.platformPrecision/2)))
        end
        return self.pos
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
        return self.az
    end
end
