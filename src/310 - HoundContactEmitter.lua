--- HOUND.Contact.Emitter (Extends HOUND.Contact.Base)
-- Contact class. containing related functions
-- @module HOUND.Contact.Emitter
do

    local l_math = math
    local l_mist = HOUND.Mist
    local PI_2 = l_math.pi*2
    local HoundUtils = HOUND.Utils

    --- HOUND.Contact decleration (Extends HOUND.Contact.Base)
    -- Contact class. containing related functions
    -- @type HOUND.Contact.Emitter
    -- @see HOUND.Contact.Base
    HOUND.Contact.Emitter = {}
    HOUND.Contact.Emitter = HOUND.inheritsFrom(HOUND.Contact.Base)
    -- HOUND.Contact.Emitter.__index = HOUND.Contact.Emitter


    --- create new HOUND.Contact instance
    -- @param DcsObject emitter DCS Unit
    -- @param HoundCoalition coalition Id of Hound Instace
    -- @param[opt] ContactId specify uid for the contact. if not present Unit ID will be used
    -- @return HOUND.Contact instance
    function HOUND.Contact.Emitter:New(DcsObject,HoundCoalition,ContactId)
        if not DcsObject or type(DcsObject) ~= "table" or not DcsObject.getName or not HoundCoalition then
            HOUND.Logger.warn("failed to create HOUND.Contact instance")
            return
        end
        local instance = self:superClass():New(DcsObject,HoundCoalition)
        setmetatable(instance, HOUND.Contact.Emitter)
        self.__index = self

        instance.uid = ContactId or tonumber(DcsObject:getID())
        instance.DcsTypeName = DcsObject:getTypeName()
        instance.DcsGroupName = Group.getName(DcsObject:getGroup())
        instance.DcsObjectName = DcsObject:getName()
        instance.DcsObjectAlive = true
        instance.typeName = DcsObject:getTypeName()
        instance.isEWR = false
        instance.typeAssigned = {"Unknown"}
        instance.band = {
            [false] = HOUND.DB.Bands.C,
            [true] = HOUND.DB.Bands.C,
        }
        instance.isPrimary = false
        instance.radarRoles = {HOUND.DB.RadarType.SEARCH}

        local _,contactUnitCategory = DcsObject:getCategory()
        if contactUnitCategory and contactUnitCategory == Unit.Category.SHIP then
            instance.band = {
                [false] = HOUND.DB.Bands.E,
                [true] = HOUND.DB.Bands.E,
            }
            instance.typeAssigned = {"Naval"}
            instance.radarRoles = {HOUND.DB.RadarType.NAVAL}
        end

        local contactData = HOUND.DB.getRadarData(instance.DcsTypeName)
        if contactData  then
            instance.typeName =  contactData.Name
            instance.isEWR = contactData.isEWR
            instance.typeAssigned = contactData.Assigned
            instance.band = contactData.Band
            instance.isPrimary = contactData.isPrimary
            instance.radarRoles = contactData.Role
            instance.frequency = contactData.Freqency
            -- HOUND.Logger.debug(instance.DcsObjectName .. " | " ..mist.utils.tableShow(instance.frequency))
        end

        instance.uncertenty_data = nil
        instance.maxWeaponsRange = HoundUtils.Dcs.getSamMaxRange(DcsObject)
        instance.detectionRange = HoundUtils.Dcs.getRadarDetectionRange(DcsObject)
        instance._dataPoints = {}
        instance.detected_by = {}
        instance.state = HOUND.EVENTS.RADAR_NEW
        instance.preBriefed = false
        instance.unitAlive = true
        instance.Kalman = nil
        return instance
    end

    --- Destructor function
    function HOUND.Contact.Emitter:destroy()
        self:removeMarkers()
        self.state=HOUND.EVENTS.RADAR_DESTROYED
        self:queueEvent(HOUND.EVENTS.RADAR_DESTROYED)
    end

    --- Getters and Setters
    -- @section settings

    --- Get contact name
    -- @return String
    function HOUND.Contact.Emitter:getName()
        return self:getType() .. " " .. self:getId()
    end

    --- Get contact type name
    -- @return String
    function HOUND.Contact.Emitter:getType()
        return self.typeName
    end

    --- Get contact UID
    -- @return Number
    function HOUND.Contact.Emitter:getId()
        return self.uid%100
    end

    --- get Contact Track ID
    -- @return string
    function HOUND.Contact.Emitter:getTrackId()
        local trackType = 'E'
        if self:isAccurate() then
            trackType = 'I'
        end
        return string.format("%s-%d",trackType,self.uid)
    end

    --- get current extimted position
    -- @return DCS point - estimated position
    function HOUND.Contact.Emitter:getPos()
        return self.pos.p
    end

    --- get radar transmission wavelength
    -- @ param[type=bool] isTracking detemins which frequency range will be retunred
    function HOUND.Contact.Emitter:getWavelenght(isTracking)
        isTracking = isTracking or false
        return self.frequency[isTracking]
    end

    --- get current estimated position elevation
    -- @return[type=int] Elevation in ft.
    function HOUND.Contact.Emitter:getElev()
        if not self:hasPos() then return 0 end
        local step = 50
        if self:isAccurate() then
            step = 1
        end
        return HoundUtils.getRoundedElevationFt(self.pos.elev,step)
    end

    --- get unit health
    -- @return unit HP points
    -- @return Unit HP in percent
    function HOUND.Contact.Emitter:getLife()
        if self:isAlive() and (not HoundUtils.Dcs.isUnit(self.DcsObject)) then
            HOUND.Logger.error("something is wrong with the object for " .. self.DcsObjectName)
            -- self:updateDeadDcsObject()
            self:setDead()
        end
        if self.DcsObject and type(self.DcsObject) == "table" and self.DcsObject:isExist() then
            return self.DcsObject:getLife(),(self.DcsObject:getLife()/self.DcsObject:getLife0())
        end
        return 0
    end

    --- check if contact DCS Unit is still alive
    -- @return[type=bool] True if object is considered Alive
    function HOUND.Contact.Emitter:isAlive()
        return self.DcsObjectAlive
    end

    --- set internal alive flag to false
    -- This is internal function ment to be called on "S_EVENT_DEAD"
    -- unit will be changed to Unit.name because DCS will remove the unit at the end of the event.
    function HOUND.Contact.Emitter:setDead()
        self.DcsObjectAlive = false
        self:updateDeadDcsObject()
    end

    --- update the internal DCS Object
    -- Since March 2022, Dead units are converted to staticObject on delayed death
    function HOUND.Contact.Emitter:updateDeadDcsObject()
        self.DcsObject = Unit.getByName(self.DcsObjectName) or StaticObject.getByName(self.DcsObjectName)
        if not self.DcsObject then
            self.DcsObject = self.DcsObjectName
        end
    end

    --- Data Processing
    -- @section data_process

    --- Remove stale datapoints
    -- @local
    function HOUND.Contact.Emitter:CleanTimedout()
        if self:isTimedout() then
            -- if contact wasn't seen for 15 minuts purge all currnent data
            self._dataPoints = {}
            self.state = HOUND.EVENTS.RADAR_ASLEEP
        end
        return self.state
    end

    --- return number of platforms
    -- @param[opt] skipStatic if true, will ignore static platforms in count
    -- @return Number of platfoms
    function HOUND.Contact.Emitter:countPlatforms(skipStatic)
        local count = 0
        if HOUND.Length(self._dataPoints) == 0 then return count end
        for _,platformDataPoints in pairs(self._dataPoints) do
            if not platformDataPoints[1].staticPlatform or (not skipStatic and platformDataPoints[1].staticPlatform) then
                count = count + 1
            end
        end
        return count
    end

    --- returns number of datapoints in contact
    -- @return Number of datapoint
    function HOUND.Contact.Emitter:countDatapoints()
        local count = 0
        if HOUND.Length(self._dataPoints) == 0 then return count end
        for _,platformDataPoints in pairs(self._dataPoints) do
            count = count + HOUND.Length(platformDataPoints)
        end
        return count
    end

    function HOUND.Contact.Emitter:KalmanPredict(timestamp)
        timestamp = timestamp or timer.getAbsTime()
        if HOUND.ENABLE_KALMAN and self.Kalman then
            HOUND.Logger.debug(self:getName() .. " is KalmanPredict")
            self.Kalman:predict(timestamp)
        end

    end
    --- Add Datapoint to content
    -- @param datapoint @{HOUND.Contact.Datapoint}
    function HOUND.Contact.Emitter:AddPoint(datapoint)
        if HOUND.ENABLE_KALMAN and not self.Kalman and HoundUtils.Dcs.isPoint(self.pos.p) then
            if self.uncertenty_data.r < 5000 then
                self.Kalman = HOUND.Contact.Estimator.UPLKF(self.pos.p,{x=0,z=0},self.last_seen,self.uncertenty_data.r)
            end
        end
        self.last_seen = datapoint.t
        if HOUND.ENABLE_KALMAN and self.Kalman then
            HOUND.Logger.debug(self:getName() .. " is KalmanUpdate")
            self.Kalman:update(datapoint.platformPos,datapoint.az,datapoint.t,datapoint.platformPrecision)
            -- return
        end

        if HOUND.Length(self._dataPoints[datapoint.platformId]) == 0 then
            self._dataPoints[datapoint.platformId] = {}
        end

        if datapoint.platformStatic then
            -- if Reciver is static, just keep the last Datapoint, as position never changes.
            -- if There is a datapoint, do rolling avarage on AZ to clean errors out.
            if HOUND.Length(self._dataPoints[datapoint.platformId]) == 0 then
                self._dataPoints[datapoint.platformId] = {datapoint}
                return
            end
            local predicted = {}
            if HoundUtils.Dcs.isPoint(self.pos.p) then
                predicted.az,predicted.el = HoundUtils.Elint.getAzimuth( datapoint.platformPos , self.pos.p, 0.0 )
                if type(self.uncertenty_data) == "table" and self.uncertenty_data.minor and self.uncertenty_data.major and self.uncertenty_data.az then
                    predicted.err = HoundUtils.Polygon.azMinMax(HOUND.Contact.Emitter.calculatePoly(self.uncertenty_data,8,self.pos.p),datapoint.platformPos)
                end
            end
            self._dataPoints[datapoint.platformId][1]:update(datapoint.az,predicted.az,predicted.err)
            return
        end

        if HOUND.Length(self._dataPoints[datapoint.platformId]) < 2 then
            table.insert(self._dataPoints[datapoint.platformId], 1, datapoint)
            return
        else
            local DeltaT = self._dataPoints[datapoint.platformId][2]:getAge() - datapoint:getAge()
            if  DeltaT >= HOUND.DATAPOINTS_INTERVAL then
                table.insert(self._dataPoints[datapoint.platformId], 1, datapoint)
            else
                local deallocate = self._dataPoints[datapoint.platformId][1]
                self._dataPoints[datapoint.platformId][1] = datapoint
                deallocate = nil
            end
        end

        -- cleanup
        for i=HOUND.Length(self._dataPoints[datapoint.platformId]),1,-1 do
            if self._dataPoints[datapoint.platformId][i]:getAge() > HOUND.CONTACT_TIMEOUT then
                local deallocate = table.remove(self._dataPoints[datapoint.platformId])
                deallocate = nil
            else
                -- as list is always ordered, if you no longer need to pop the last one out, break out
                i=1
            end
        end

        if self:countPlatforms(true) > 0 then
            local pointsPerPlatform = l_math.ceil(HOUND.DATAPOINTS_NUM/self:countPlatforms(true))
            while HOUND.Length(self._dataPoints[datapoint.platformId]) > pointsPerPlatform do
                local deallocate = table.remove(self._dataPoints[datapoint.platformId])
                deallocate = nil
            end
        end
    end

    --- Take two HOUND.Contact.Datapoints and return the location of intersection
    -- @local
    -- @param earlyPoint @{HOUND.Contact.Datapoint}
    -- @param latePoint @{HOUND.Contact.Datapoint}
    -- @return Position
    function HOUND.Contact.Emitter.triangulatePoints(earlyPoint, latePoint)
        local p1 = earlyPoint.platformPos
        local p2 = latePoint.platformPos

        local m1 = l_math.tan(earlyPoint.az)
        local m2 = l_math.tan(latePoint.az)

        local b1 = -m1 * p1.x + p1.z
        local b2 = -m2 * p2.x + p2.z

        local Easting = (b2 - b1) / (m1 - m2)
        local Northing = m1 * Easting + b1

        local pos = {}
        pos.x = Easting
        pos.z = Northing
        pos.y = land.getHeight({x=pos.x,y=pos.z})

        pos.score = earlyPoint.signalStrength * latePoint.signalStrength

        return pos
    end

    --- Calculate Cotact's Ellipse of uncertenty
    -- @local
    -- @param estimatedPositions List of estimated positions
    -- @param[opt] refPos reference position to use for computing the uncertenty ellipse. (will use cluster avarage if none provided)
    -- @param[opt] giftWrapped pass true if estimatedPosition is just a giftWrap polygon point set (closed polygon, not a point cluster)
    -- @return None (updates self.uncertenty_data)
    function HOUND.Contact.Emitter.calculateEllipse(estimatedPositions,refPos,giftWrapped)
        local percentile = HOUND.ELLIPSE_PERCENTILE
        if giftWrapped then percentile = 1.0 end
        local RelativeToPos = HoundUtils.Cluster.getDeltaSubsetPercent(estimatedPositions,refPos,percentile,true)

        local min = {}
        min.x = 99999
        min.y = 99999

        local max = {}
        max.x = -99999
        max.y = -99999

        Theta = HoundUtils.PointClusterTilt(RelativeToPos)

        local sinTheta = l_math.sin(-Theta)
        local cosTheta = l_math.cos(-Theta)

        for k,pos in ipairs(RelativeToPos) do
            local newPos = {}
            newPos.x = pos.x*cosTheta - pos.z*sinTheta
            newPos.z = pos.x*sinTheta + pos.z*cosTheta
            newPos.y = pos.y

            min.x = l_math.min(min.x,newPos.x)
            max.x = l_math.max(max.x,newPos.x)
            min.y = l_math.min(min.y,newPos.z)
            max.y = l_math.max(max.y,newPos.z)

            RelativeToPos[k] = newPos
        end

        local a = l_mist.utils.round(l_math.abs(min.x)+l_math.abs(max.x))
        local b = l_mist.utils.round(l_math.abs(min.y)+l_math.abs(max.y))

        local uncertenty_data = {}
        uncertenty_data.major = l_math.max(a,b)
        uncertenty_data.minor = l_math.min(a,b)
        uncertenty_data.theta = (Theta + PI_2) % PI_2
        uncertenty_data.az = l_mist.utils.round(l_math.deg(uncertenty_data.theta))
        uncertenty_data.r  = (a+b)/4

        return uncertenty_data
    end

    --- calculate additional position data
    -- @param pos basic position table to be filled with extended data
    -- @return pos input object, but with more data
    function HOUND.Contact.Emitter:calculateExtrasPosData(pos)
        if HoundUtils.Dcs.isPoint(pos.p) then
            local bullsPos = coalition.getMainRefPoint(self._platformCoalition)
            pos.LL = {}
            pos.LL.lat, pos.LL.lon = coord.LOtoLL(pos.p)
            pos.elev = pos.p.y
            pos.grid  = coord.LLtoMGRS(pos.LL.lat, pos.LL.lon)
            pos.be = HoundUtils.getBR(bullsPos,pos.p)
        end
        return pos
    end


    --- process the intersection
    -- @param targetTable where should the result be stored
    -- @param point1 @{HOUND.Contact.Datapoint} Instance no.1
    -- @param point2 @{HOUND.Contact.Datapoint} Instance no.2
    function HOUND.Contact.Emitter:processIntersection(targetTable,point1,point2)
        local err = (point1.platformPrecision + point2.platformPrecision)/2
        if HoundUtils.angleDeltaRad(point1.az,point2.az) < err then return end
        local intersection = self.triangulatePoints(point1,point2)
        if not HoundUtils.Dcs.isPoint(intersection) then return end
        table.insert(targetTable,intersection)
    end

    --- process data in contact
    -- @return HoundEvent id (@{HOUND.EVENTS})
    function HOUND.Contact.Emitter:processData()
        if self:getPreBriefed() then
            if type(self.DcsObject) == "table" and type(self.DcsObject.isExist) == "function" and self.DcsObject:isExist()
                then
                    local unitPos = self.DcsObject:getPosition()
                    if HoundUtils.Geo.get2DDistance(unitPos.p,self.pos.p) < 0.25 then return end
                    -- HOUND.Logger.debug(self:getName().. " has moved")
                    -- HOUND.Logger.debug("3D: ".. HoundUtils.Geo.get3DDistance(unitPos.p,self.pos.p) .. " | 2D: "..HoundUtils.Geo.get2DDistance(unitPos.p,self.pos.p))
                    if self:isActive() then
                        HOUND.Logger.debug(self:getName().. " is active and moved.. not longer PB")
                        self:setPreBriefed(false)
                    end
                else
                    self.state = HOUND.EVENTS.NO_CHANGE
                    return
            end
        end

        if not self:isRecent() and self.state ~= HOUND.EVENTS.RADAR_NEW then
            return self.state
        end

        -- if self.kalman then
        --     self.pos.p = self.kalman:getEstimatedPos()
        --     self:calculateExtrasPosData(self.pos)
        --     self.state = HOUND.EVENTS.RADAR_UPDATED
        --     self:queueEvent(self.state)
        --     return self.state
        -- end


        local newContact = (self.state == HOUND.EVENTS.RADAR_NEW)
        local mobileDataPoints = {}
        local staticDataPoints = {}
        local estimatePositions = {}
        local platforms = {}
        local staticPlatformsOnly = true
        local staticClipPolygon2D = nil

        for _,platformDatapoints in pairs(self._dataPoints) do
            if HOUND.Length(platformDatapoints) > 0 then
                for _,datapoint in pairs(platformDatapoints) do
                    if datapoint:isStatic() then
                        table.insert(staticDataPoints,datapoint)
                        if type(datapoint:get2dPoly()) == "table" then
                            staticClipPolygon2D = HoundUtils.Polygon.clipPolygons(staticClipPolygon2D,datapoint:get2dPoly()) or datapoint:get2dPoly()
                        end
                    else
                        staticPlatformsOnly = false
                        table.insert(mobileDataPoints,datapoint)
                    end
                    if HoundUtils.Dcs.isPoint(datapoint:getPos()) then
                        local point = l_mist.utils.deepCopy(datapoint:getPos())
                        table.insert(estimatePositions,point)
                    end
                    platforms[datapoint.platformName] = 1
                end
            end
        end
        local numMobilepoints = HOUND.Length(mobileDataPoints)
        local numStaticPoints = HOUND.Length(staticDataPoints)
        table.sort(mobileDataPoints, function(a,b) return a.signalStrength < b.signalStrength end)
        table.sort(staticDataPoints, function(a,b) return a.signalStrength < b.signalStrength end)

        if numMobilepoints+numStaticPoints < 2 and HOUND.Length(estimatePositions) == 0 then return end
        -- Static against all statics
        if numStaticPoints > 1 then
            for i=1,numStaticPoints-1 do
                for j=i+1,numStaticPoints do
                    self:processIntersection(estimatePositions,staticDataPoints[i],staticDataPoints[j])
                end
            end
        end

        -- Statics against all mobiles
        if numStaticPoints > 0  and numMobilepoints > 0 then
            for _,staticDataPoint in ipairs(staticDataPoints) do
                for _,mobileDataPoint in ipairs(mobileDataPoints) do
                    self:processIntersection(estimatePositions,staticDataPoint,mobileDataPoint)
                end
            end
         end

        -- mobiles agains mobiles
        if numMobilepoints > 1 then
            for i=1,numMobilepoints-1 do
                for j=i+1,numMobilepoints do
                    if mobileDataPoints[i].platformPos ~= mobileDataPoints[j].platformPos then
                        self:processIntersection(estimatePositions,mobileDataPoints[i],mobileDataPoints[j])
                    end
                end
                mobileDataPoints[i].processed = true
            end
        end

        if HOUND.Length(estimatePositions) > 2 or (HOUND.Length(estimatePositions) > 0 and staticPlatformsOnly) then
            table.sort(estimatePositions, function(a,b) return a.score < b.score end)

            self.pos.p = HoundUtils.Cluster.weightedMean(estimatePositions,self.pos.p)

            if HOUND.Length(estimatePositions) > 10 then
                -- local posSubset = HoundUtils.Cluster.getDeltaSubsetPercent(estimatePositions,self.pos.p,HOUND.ELLIPSE_PERCENTILE)
                self.pos.p = HoundUtils.Cluster.weightedMean(
                    HoundUtils.Cluster.getDeltaSubsetPercent(estimatePositions,self.pos.p,HOUND.ELLIPSE_PERCENTILE),
                    self.pos.p)
            end

            self.uncertenty_data = self.calculateEllipse(estimatePositions,self.pos.p)
            if type(staticClipPolygon2D) == "table" and ( staticPlatformsOnly) then
                self.uncertenty_data = self.calculateEllipse(staticClipPolygon2D,self.pos.p,true)
            end

            self.uncertenty_data.az = l_mist.utils.round(l_math.deg((self.uncertenty_data.theta+l_mist.getNorthCorrection(self.pos.p)+PI_2)%PI_2))

            self:calculateExtrasPosData(self.pos)

            if self.state == HOUND.EVENTS.RADAR_ASLEEP then
                self.state = HOUND.EVENTS.SITE_ALIVE
            else
                self.state = HOUND.EVENTS.RADAR_UPDATED
            end

            local detected_by = {}

            for key,_ in pairs(platforms) do
                table.insert(detected_by,key)
            end
            local deallocate = self.detected_by
            self.detected_by = detected_by
            deallocate = nil
        end

        if newContact and HoundUtils.Dcs.isPoint(self.pos.p) ~= nil and self.isEWR == false then
            self.state = HOUND.EVENTS.RADAR_DETECTED
            self:calculateExtrasPosData(self.pos)
        end
        self:queueEvent(self.state)
        return self.state
    end

    --- Marker managment
    -- @section markers

    --- calculate uncertenty Polygon from data
    -- @local
    -- @param uncertenty_data uncertenty data table
    -- @param[opt] numPoints number of datapoints in the polygon
    -- @param[opt] refPos center of the polygon (DCS point)
    -- @return Polygon created by inputs
    function HOUND.Contact.Emitter.calculatePoly(uncertenty_data,numPoints,refPos)
        local polygonPoints = {}
        if type(uncertenty_data) ~= "table" or not uncertenty_data.major or not uncertenty_data.minor or not uncertenty_data.az then
            return polygonPoints
        end
        if type(numPoints) ~= "number" then
            numPoints = 8
        end
        if not HoundUtils.Dcs.isPoint(refPos) then
            refPos = {x=0,y=0,z=0}
        end
        local angleStep = PI_2/numPoints
        local theta = l_math.rad(uncertenty_data.az) - HoundUtils.getMagVar(refPos)
        local cos_theta,sin_theta = l_math.cos(theta),l_math.sin(theta)
        -- generate ellips points
        for i = 1, numPoints do
            local pointAngle = PI_2 - (i * angleStep)
            local point = {}
            point.x = uncertenty_data.major/2 * l_math.cos(pointAngle)
            point.z = uncertenty_data.minor/2 * l_math.sin(pointAngle)
            -- rotate and translate into correct position
            local x = point.x * cos_theta - point.z * sin_theta
            local z = point.x * sin_theta + point.z * cos_theta
            point.x = x + refPos.x
            point.z = z + refPos.z
            local mgrs = coord.LLtoMGRS(coord.LOtoLL( point ))
            if type(mgrs) == "table" and type(mgrs.Easting) == "number" and type(mgrs.Northing ) == "number" then
                table.insert(polygonPoints, point)
            end
        end
        HoundUtils.Geo.setHeight(polygonPoints)

        return polygonPoints
    end

    --- Draw marker Polygon
    -- @local
    -- @int numPoints number of points to draw (only 1,4,8 and 16 are valid)
    function HOUND.Contact.Emitter:drawAreaMarker(numPoints)
        if numPoints == nil then numPoints = 1 end
        if numPoints ~= 1 and numPoints ~= 4 and numPoints ~=8 and numPoints ~= 16 then
            HOUND.Logger.error("DCS limitation, only 1,4,8 or 16 points are allowed")
            numPoints = 1
            end

        -- setup the marker
        local alpha = HoundUtils.Mapping.linear(l_math.floor(HoundUtils.absTimeDelta(self.last_seen)),0,HOUND.CONTACT_TIMEOUT,HOUND.MARKER_MAX_ALPHA,HOUND.MARKER_MIN_ALPHA,true)
        local fillColor = {0,0,0,alpha}
        local lineColor = {0,0,0,HOUND.MARKER_LINE_OPACITY}
        local lineType = 2
        if (HoundUtils.absTimeDelta(self.last_seen) < 30) then
            lineType = 1
        end
        if self._platformCoalition == coalition.side.BLUE then
            fillColor[1] = 1
            lineColor[1] = 1
        elseif self._platformCoalition == coalition.side.RED then
            fillColor[3] = 1
            lineColor[3] = 1
        end

        local markArgs = {
            fillColor = fillColor,
            lineColor = lineColor,
            coalition = self._platformCoalition,
            lineType = lineType
        }
        if numPoints == 1 then
            markArgs.pos = {
                p = self.pos.p,
                r = self.uncertenty_data.r
            }
        else
            markArgs.pos = HOUND.Contact.Emitter.calculatePoly(self.uncertenty_data,numPoints,self.pos.p)
        end
        return self._markpoints.area:update(markArgs)
    end

    --- Update marker positions
    -- @param MarkerType type of marker to use
    function HOUND.Contact.Emitter:updateMarker(MarkerType)
        local MarkerType = MarkerType or HOUND.MARKER.POINT
        if not self:hasPos() or self.uncertenty_data == nil or not self:isRecent() then return end
        if self:isAccurate() and self._markpoints.pos:isDrawn() then return end
        local markerArgs = {
            text = self.typeName .. " " .. (self.uid%100),
            pos = self.pos.p,
            coalition = self._platformCoalition,
            useLegacyMarker = HOUND.USE_LEGACY_MARKERS
        }
        if not self:isAccurate() and HOUND.USE_LEGACY_MARKERS then
            markerArgs.text = markerArgs.text .. " (" .. self.uncertenty_data.major .. "/" .. self.uncertenty_data.minor .. "@" .. self.uncertenty_data.az .. ")"
        end
        if MarkerType >= HOUND.MARKER.POINT then
            -- HOUND.Logger.debug("skip update markpoint")
            self._markpoints.pos:update(markerArgs)
        end

        if  MarkerType < HOUND.MARKER.POINT or self:isAccurate() then
            -- if self._markpoints.area:isDrawn() then
                self._markpoints.area:remove()
                if MarkerType < HOUND.MARKER.POINT then
                    self._markpoints.pos:remove()
                end
            -- end
            return
        end

        if MarkerType == HOUND.MARKER.CIRCLE then
            self:drawAreaMarker()
        end

        if MarkerType == HOUND.MARKER.DIAMOND then
            self:drawAreaMarker(4)
        end

        if MarkerType == HOUND.MARKER.OCTAGON then
            self:drawAreaMarker(8)
        end

        if MarkerType == HOUND.MARKER.POLYGON then
            self:drawAreaMarker(16)
        end
    end

    --- Helper functions
    -- @section helpers

    --- Use DCS Unit Position as contact position
    -- @param[number] unitPosMarker marker type to use for unit (see HOUND.MARKER)
    function HOUND.Contact.Emitter:useUnitPos(unitPosMarker)
        if not self.DcsObject:isExist() then
            HOUND.Logger.info("PB failed - unit does not exist")
            return
        end
        self.state = HOUND.EVENTS.RADAR_DETECTED
        if type(self.pos.p) == "table" then
            self.state = HOUND.EVENTS.RADAR_UPDATED
        end
        local unitPos = self.DcsObject:getPosition()
        self:setPreBriefed(true)

        self.pos.p = l_mist.utils.deepCopy(unitPos.p)
        self:calculateExtrasPosData(self.pos)

        self.uncertenty_data = {}
        self.uncertenty_data.major = 0.1
        self.uncertenty_data.minor = 0.1
        self.uncertenty_data.az = 0
        self.uncertenty_data.r  = 0.1

        table.insert(self.detected_by,"External")
        self:updateMarker(unitPosMarker)
        return self.state
    end

    --- Generate contact export object
    -- @return exported object
    function HOUND.Contact.Emitter:export()
        local contact = {}
        contact.typeName = self.typeName
        contact.uid = self.uid % 100
        contact.DcsObjectName = self.DcsObject:getName()
        if self.pos.p ~= nil and self.uncertenty_data ~= nil then
            contact.pos = self.pos.p
            contact.LL = self.pos.LL

            contact.accuracy = HoundUtils.TTS.getVerbalConfidenceLevel( self.uncertenty_data.r )
            contact.uncertenty = {
                major = self.uncertenty_data.major,
                minor = self.uncertenty_data.minor,
                heading = self.uncertenty_data.az
            }
        end
        contact.maxWeaponsRange = self.maxWeaponsRange
        contact.last_seen = self.last_seen
        contact.detected_by = self.detected_by
        return l_mist.utils.deepCopy(contact)
    end
end
