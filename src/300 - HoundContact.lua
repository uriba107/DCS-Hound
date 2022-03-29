--- HOUND.Contact
-- Contact class. containing related functions
-- @module HOUND.Contact
do
    --- HOUND.Contact decleration
    -- Contact class. containing related functions
    -- @type HOUND.Contact
    HOUND.Contact = {}
    HOUND.Contact.__index = HOUND.Contact

    local l_math = math
    local l_mist = mist
    local pi_2 = l_math.pi*2

    --- create new HOUND.Contact instance
    -- @param DCS_Unit emitter DCS Unit
    -- @param HoundCoalition coalition Id of Hound Instace
    -- @param[opt] ContactId specify uid for the contact. if not present Unit ID will be used
    -- @return HOUND.Contact
    function HOUND.Contact.New(DCS_Unit,HoundCoalition,ContactId)
        if not DCS_Unit or type(DCS_Unit) ~= "table" or not DCS_Unit.getName or not HoundCoalition then
            HOUND.Logger.warn("failed to create HOUND.Contact instance")
            return
        end
        local elintcontact = {}
        setmetatable(elintcontact, HOUND.Contact)
        elintcontact.unit = DCS_Unit
        elintcontact.uid = ContactId or DCS_Unit:getID()
        elintcontact.DCStypeName = DCS_Unit:getTypeName()
        elintcontact.typeName = DCS_Unit:getTypeName()
        elintcontact.isEWR = false
        elintcontact.typeAssigned = {"Unknown"}
        elintcontact.band = "C"

        local contactUnitCategory = DCS_Unit:getDesc()["category"]
        if contactUnitCategory and contactUnitCategory == Unit.Category.SHIP then
            elintcontact.band = "E"
            elintcontact.typeAssigned = {"Naval"}
        end

        if setContains(HOUND.DBs.Sam,DCS_Unit:getTypeName())  then
            local unitName = DCS_Unit:getTypeName()
            elintcontact.typeName =  HOUND.DBs.Sam[unitName].Name
            elintcontact.isEWR = setContainsValue(HOUND.DBs.Sam[unitName].Role,"EWR")
            elintcontact.typeAssigned = HOUND.DBs.Sam[unitName].Assigned
            elintcontact.band = HOUND.DBs.Sam[unitName].Band
        end

        elintcontact.pos = {
            p = nil,
            grid = nil,
            LL = {
                lat = nil,
                lon = nil,
            },
            be = {
                brg = nil,
                rng = nil
            }
        }
        elintcontact.uncertenty_data = nil
        elintcontact.last_seen = timer.getAbsTime()
        elintcontact.first_seen = timer.getAbsTime()
        elintcontact.maxWeaponsRange = HOUND.Utils.getSamMaxRange(DCS_Unit)
        elintcontact.detectionRange = HOUND.Utils.getRadarDetectionRange(DCS_Unit)
        elintcontact._dataPoints = {}
        -- elintcontact._markpointID = nil
        elintcontact._markpoints = {
            p = HOUND.Utils.Marker.create(),
            u = HOUND.Utils.Marker.create()
        }
        elintcontact._platformCoalition = HoundCoalition
        elintcontact.primarySector = "default"
        elintcontact.threatSectors = {
            default = true
        }
        elintcontact.detected_by = {}
        elintcontact.state = HOUND.EVENTS.RADAR_NEW
        elintcontact.preBriefed = false
        elintcontact.unitAlive = true
        elintcontact._kalman = HOUND.Estimator.Kalman.posFilter()
        return elintcontact
    end

    --- Destructor function
    function HOUND.Contact:destroy()
        self:removeMarkers()
    end

    --- Getters and Setters
    -- @section settings

    --- Get contact name
    -- @return String
    function HOUND.Contact:getName()
        return self:getType() .. " " .. self:getId()
    end

    --- Get contact type name
    -- @return String
    function HOUND.Contact:getType()
        return self.typeName
    end

    --- Get contact UID
    -- @return Number
    function HOUND.Contact:getId()
        return self.uid%100
    end

    --- Get last seen in seconds
    -- @return number in seconds since contact was last seen
    function HOUND.Contact:getLastSeen()
        return HOUND.Utils.absTimeDelta(self.last_seen)
    end
    --- get Contact Track ID
    -- @return string
    function HOUND.Contact:getTrackId()
        local trackType = 'E'
        if self.preBriefed then
            trackType = 'I'
        end
        return string.format("%s-%d",trackType,self.uid)
    end
    --- get NATO designation
    -- @return string
    function HOUND.Contact:getNatoDesignation()
        local natoDesignation = string.gsub(self:getTypeAssigned(),"(SA)-",'')
            if natoDesignation == "Naval" then
                natoDesignation = self:getType()
            end
        return natoDesignation
    end

    --- get current extimted position
    function HOUND.Contact:getPos()
        return self.pos.p
    end

    --- check if contact has estimated position
    function HOUND.Contact:hasPos()
        return HOUND.Utils.Geo.isDcsPoint(self.pos.p)
    end

    --- get max weapons range
    function HOUND.Contact:getMaxWeaponsRange()
        return self.maxWeaponsRange
    end

    --- get type assinged string
    function HOUND.Contact:getTypeAssigned()
        return table.concat(self.typeAssigned," or ")
    end

    --- check if contact DCS Unit is still alive
    -- @return State (bool)
    -- @return Boolean
    function HOUND.Contact:isAlive()
        return self.unitAlive
    end

    --- set internal alive flag to false
    -- This is internal function ment to be called on "S_EVENT_DEAD"
    function HOUND.Contact:setDead()
        self.unitAlive = false
    end

    --- check if contact is recent
    -- @return Bool True if seen in the 2 minutes
    function HOUND.Contact:isRecent()
        return HOUND.Utils.absTimeDelta(self.last_seen)/120 < 1.0
    end

    --- check if contact is timed out
    -- @return Bool True if timed out
    function HOUND.Contact:isTimedout()
        return HOUND.Utils.absTimeDelta(self.last_seen) > HOUND.CONTACT_TIMEOUT
    end

    --- Get current state
    -- @return Contact state
    -- @see HOUND.EVENTS
    function HOUND.Contact:getState()
        return self.state
    end

    --- Data Processing
    -- @section data_process

    --- Remove stale datapoints
    -- @local
    function HOUND.Contact:CleanTimedout()
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
    function HOUND.Contact:countPlatforms(skipStatic)
        local count = 0
        if Length(self._dataPoints) == 0 then return count end
        for _,platformDataPoints in pairs(self._dataPoints) do
            if not platformDataPoints[1].staticPlatform or (not skipStatic and platformDataPoints[1].staticPlatform) then
                count = count + 1
            end
        end
        return count
    end

    --- returns number of datapoints in contact
    -- @return Number of datapoint
    function HOUND.Contact:countDatapoints()
        local count = 0
        if Length(self._dataPoints) == 0 then return count end
        for _,platformDataPoints in pairs(self._dataPoints) do
            count = count + Length(platformDataPoints)
        end
        return count
    end

    --- Add Datapoint to content
    -- @param datapoint HOUND.Datapoint
    function HOUND.Contact:AddPoint(datapoint)
        self.last_seen = datapoint.t
        if Length(self._dataPoints[datapoint.platformId]) == 0 then
            self._dataPoints[datapoint.platformId] = {}
        end

        if datapoint.platformStatic then
            -- if Reciver is static, just keep the last Datapoint, as position never changes.
            -- if There is a datapoint, do rolling avarage on AZ to clean errors out.
            if Length(self._dataPoints[datapoint.platformId]) == 0 then
                self._dataPoints[datapoint.platformId] = {datapoint}
                return
            end
            local predicted = {}
            if HOUND.Utils.Geo.isDcsPoint(self.pos.p) then
                predicted.az,predicted.el = HOUND.Utils.Elint.getAzimuth( datapoint.platformPos , self.pos.p, 0.0 )
                -- HOUND.Logger.trace("sample vs prediction - " .. l_math.deg(datapoint.az) .. " | " .. l_math.deg(predicted.az))
                if type(self.uncertenty_data) == "table" and self.uncertenty_data.minor and self.uncertenty_data.major and self.uncertenty_data.az then
                    predicted.err = HOUND.Utils.Polygon.azMinMax(HOUND.Contact.calculatePoly(self.uncertenty_data,8,self.pos.p),datapoint.platformPos)
                end
            end
            self._dataPoints[datapoint.platformId][1]:update(datapoint.az,predicted.az,predicted.err)
                -- datapoint = self._dataPoints[datapoint.platformId][1]
                -- datapoint.az =  HOUND.Utils.AzimuthAverage({datapoint.az,self._dataPoints[datapoint.platformId][1].az})
            return
        end

        -- if HOUND.Utils.Geo.isDcsPoint(datapoint:getPos()) then
        --     datapoint:calcError()
        -- end
        if Length(self._dataPoints[datapoint.platformId]) < 2 then
            table.insert(self._dataPoints[datapoint.platformId], 1, datapoint)
            return
        else
            local DeltaT = self._dataPoints[datapoint.platformId][2]:getAge() - datapoint:getAge()
            if  DeltaT >= HOUND.DATAPOINTS_INTERVAL then
                table.insert(self._dataPoints[datapoint.platformId], 1, datapoint)
            else
                self._dataPoints[datapoint.platformId][1] = datapoint
            end
        end

        -- cleanup
        for i=Length(self._dataPoints[datapoint.platformId]),1,-1 do
            if self._dataPoints[datapoint.platformId][i]:getAge() > HOUND.CONTACT_TIMEOUT then
                table.remove(self._dataPoints[datapoint.platformId])
            else
                -- as list is always ordered, if you no longer need to pop the last one out, break out
                i=1
            end
        end
        local pointsPerPlatform = l_math.ceil(HOUND.DATAPOINTS_NUM/self:countPlatforms(true))
        while Length(self._dataPoints[datapoint.platformId]) > pointsPerPlatform do
            table.remove(self._dataPoints[datapoint.platformId])
        end
    end

    --- Take two HOUND.Datapoints and return the location of intersection
    -- @local
    -- @param earlyPoint HOUND.Datapoint
    -- @param latePoint HOUND.Datapoint
    -- @return Position
    function HOUND.Contact.triangulatePoints(earlyPoint, latePoint)
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

        return pos
    end

    --- Get a list of Nth elements centerd around a position from table of positions.
    -- @local
    -- @param Table A List of positions
    -- @param referencePos Point in relations to all points are evaluated
    -- @param NthPercentile Percintile of which Datapoints are taken (0.6=60%)
    -- @return List
    function HOUND.Contact.getDeltaSubsetPercent(Table,referencePos,NthPercentile)
        local t = l_mist.utils.deepCopy(Table)
        local len_t = Length(t)
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
        -- if len_t <= 4 then
        --     NumToUse = len_t
        -- end
        local RelativeToPos = {}
        for i = 1, NumToUse  do
            table.insert(RelativeToPos,l_mist.vec.sub(t[i],referencePos))
        end

        return RelativeToPos
    end

    --- Calculate Cotact's Ellipse of uncertenty
    -- @local
    -- @param estimatedPositions List of estimated positions
    -- @param[opt] giftWrapped pass true if estimatedPosition is just a giftWrap polygon point set (closed polygon, not a point cluster)
    -- @param[opt] refPos reference position to use for computing the uncertenty ellipse. (will use cluster avarage if none provided)
    -- @return None (updates self.uncertenty_data)
    function HOUND.Contact.calculateEllipse(estimatedPositions,giftWrapped,refPos)
        local percentile = HOUND.ELLIPSE_PERCENTILE
        if giftWrapped then percentile = 1.0 end
        local RelativeToPos = HOUND.Contact.getDeltaSubsetPercent(estimatedPositions,refPos,percentile)

        local min = {}
        min.x = 99999
        min.y = 99999

        local max = {}
        max.x = -99999
        max.y = -99999

        Theta = HOUND.Utils.PointClusterTilt(RelativeToPos)

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
        uncertenty_data.theta = (Theta + pi_2) % pi_2
        uncertenty_data.az = l_mist.utils.round(l_math.deg(uncertenty_data.theta))
        uncertenty_data.r  = (a+b)/4

        return uncertenty_data
    end

    --- calculate ellipse errors
    function HOUND.Contact.calculateEllipseErrors(uncertenty_ellipse)
        if not uncertenty_ellipse.theta then return end
        local err = {}

        local sinTheta = l_math.sin(uncertenty_ellipse.theta)
        local cosTheta = l_math.cos(uncertenty_ellipse.theta)

        err.x = l_math.max(l_math.abs(uncertenty_ellipse.minor/2*cosTheta), l_math.abs(-uncertenty_ellipse.major/2*sinTheta))
        err.z = l_math.max(l_math.abs(uncertenty_ellipse.minor/2*sinTheta), l_math.abs(uncertenty_ellipse.major/2*cosTheta))

        err.score = {}
        err.score.x = HOUND.Estimator.accuracyScore(err.x)
        err.score.z = HOUND.Estimator.accuracyScore(err.z)
        return err
    end

    --- Finallize position estimation Contact position
    -- @local
    -- @param estimatedPositions List of all estimated positions derrived fomr datapoints and intersections
    -- @param[opt] converge Boolean, if True function will try and converge on best position
    -- @return estimated position (DCS point)
    function HOUND.Contact.calculatePos(estimatedPositions,converge)
        if type(estimatedPositions) ~= "table" or Length(estimatedPositions) == 0 then return end
        local pos = l_mist.getAvgPoint(estimatedPositions)
        if converge then
            local subList = estimatedPositions
            local subsetPos = pos
            while (Length(subList) * HOUND.ELLIPSE_PERCENTILE) > 5 do
                local NewsubList = HOUND.Contact.getDeltaSubsetPercent(subList,subsetPos,HOUND.ELLIPSE_PERCENTILE)
                subsetPos = l_mist.getAvgPoint(NewsubList)

                pos.x = pos.x + (subsetPos.x )
                pos.z = pos.z + (subsetPos.z )
                subList = NewsubList
            end
        end
        pos.y = land.getHeight({x=pos.x,y=pos.z})
        return pos
    end

    --- calculate additional position data
    -- @param pos basic position table to be filled with extended data
    -- @return pos input object, but with more data
    function HOUND.Contact:calculatePosExtras(pos)
        if type(pos.p) == "table" and HOUND.Utils.Geo.isDcsPoint(pos.p) then
            local bullsPos = coalition.getMainRefPoint(self._platformCoalition)
            pos.LL = {}
            pos.LL.lat, pos.LL.lon = coord.LOtoLL(pos.p)
            pos.elev = pos.p.y
            pos.grid  = coord.LLtoMGRS(pos.LL.lat, pos.LL.lon)
            pos.be = HOUND.Utils.getBR(bullsPos,pos.p)
        end
        return pos
    end


    --- process the intersection
    -- @param targetTable where should the result be stored
    -- @param point1 HOUND.Datapoint Instance no.1
    -- @param point2 HOUND.Datapoint Instance no.2
    function HOUND.Contact:processIntersection(targetTable,point1,point2)
        local err = (point1.platformPrecision + point2.platformPrecision)/2
        if HOUND.Utils.angleDeltaRad(point1.az,point2.az) < err then return end
        local intersection = self.triangulatePoints(point1,point2)
        if not HOUND.Utils.Geo.isDcsPoint(intersection) then return end
        -- if HOUND.USE_KALMAN then
        --     local polygon = HOUND.Utils.Polygon.clipPolygons(point1:get2dPoly(),point2:get2dPoly())
        --     if Length(polygon) > 2 then
        --         intersection.err = self.calculateEllipseErrors(self.calculateEllipse(polygon,true))
        --         self._kalman:update(intersection)
        --     end
        -- end
        table.insert(targetTable,intersection)

    end

    --- process data in contact
    -- @return HoundEvent
    -- @see HOUND.EVENTS
    function HOUND.Contact:processData()
        if self.preBriefed then
            HOUND.Logger.trace(self:getName().." is PB..")
            if self.unit:isExist() then
                local unitPos = self.unit:getPosition()
                if l_mist.utils.get3DDist(unitPos.p,self.pos.p) < 0.1 then
                    HOUND.Logger.trace("No change in position.. skipping..")
                    return
                end
                HOUND.Logger.trace("position changed.. removing PB mark..")
                self.preBriefed = false
            else
                HOUND.Logger.trace("PB Unit does not exist")
                return
            end
        end

        if not self:isRecent() then
            return self.state
        end

        local newContact = (self.state == HOUND.EVENTS.RADAR_NEW)
        local mobileDataPoints = {}
        local staticDataPoints = {}
        local estimatePositions = {}
        local platforms = {}
        local staticPlatformsOnly = true
        local staticClipPolygon2D = nil

        for _,platformDatapoints in pairs(self._dataPoints) do
            if Length(platformDatapoints) > 0 then
                for _,datapoint in pairs(platformDatapoints) do
                    if datapoint:isStatic() then
                        table.insert(staticDataPoints,datapoint)
                        if type(datapoint:get2dPoly()) == "table" then
                            staticClipPolygon2D = HOUND.Utils.Polygon.clipPolygons(staticClipPolygon2D,datapoint:get2dPoly()) or datapoint:get2dPoly()
                        end
                    else
                        staticPlatformsOnly = false
                        table.insert(mobileDataPoints,datapoint)
                    end
                    if HOUND.Utils.Geo.isDcsPoint(datapoint:getPos()) then
                        local point = l_mist.utils.deepCopy(datapoint:getPos())
                        table.insert(estimatePositions,point)
                        -- if HOUND.USE_KALMAN then
                        --     point.err = datapoint:getErrors()
                        --     self._kalman:update(point)
                        -- end
                    end
                    platforms[datapoint.platformName] = 1
                end
            end
        end
        local numMobilepoints = Length(mobileDataPoints)
        local numStaticPoints = Length(staticDataPoints)

        if numMobilepoints+numStaticPoints < 2 and Length(estimatePositions) == 0 then return end
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
                -- only process each datapoint once as anchor (it will be processed against every new datapoint anyway)
                -- local processKalman = (HOUND.USE_KALMAN and not mobileDataPoints[i].processed)
                for j=i+1,numMobilepoints do
                    if mobileDataPoints[i].platformPos ~= mobileDataPoints[j].platformPos then
                        self:processIntersection(estimatePositions,mobileDataPoints[i],mobileDataPoints[j])
                    end
                end
                mobileDataPoints[i].processed = true
            end
        end


        if Length(estimatePositions) > 2 or (Length(estimatePositions) > 0 and staticPlatformsOnly) then

            self.pos.p = HOUND.Utils.Cluster.weightedMean(estimatePositions)

            self.uncertenty_data = self.calculateEllipse(estimatePositions,false,self.pos.p)

            if type(staticClipPolygon2D) == "table" and ( staticPlatformsOnly) then
                self.uncertenty_data = self.calculateEllipse(staticClipPolygon2D,true,self.pos.p)
            end

            self.uncertenty_data.az = l_mist.utils.round(l_math.deg((self.uncertenty_data.theta+l_mist.getNorthCorrection(self.pos.p)+pi_2)%pi_2))

            self:calculatePosExtras(self.pos)

            if self.state == HOUND.EVENTS.RADAR_ASLEEP then
                self.state = HOUND.EVENTS.SITE_ALIVE
            else
                self.state = HOUND.EVENTS.RADAR_UPDATED
            end

            local detected_by = {}

            for key,_ in pairs(platforms) do
                table.insert(detected_by,key)
            end
            self.detected_by = detected_by
        end

        if newContact and self.pos.p ~= nil and self.isEWR == false then
            self.state = HOUND.EVENTS.RADAR_DETECTED
            self:calculatePosExtras(self.pos)
        end

        return self.state
    end

    --- Marker managment
    -- @section markers

    --- Remove all contact's F10 map markers
    -- @local
    function HOUND.Contact:removeMarkers()
        for _,marker in pairs(self._markpoints) do
            marker:remove()
        end
    end

    --- calculate uncertenty Polygon from data
    -- @local
    -- @param uncertenty_data uncertenty data table
    -- @param[opt] numPoints number of datapoints in the polygon
    -- @param[opt] refPos center of the polygon (DCS point)
    -- @return Polygon created by inputs
    function HOUND.Contact.calculatePoly(uncertenty_data,numPoints,refPos)
        local polygonPoints = {}
        if type(uncertenty_data) ~= "table" or not uncertenty_data.major or not uncertenty_data.minor or not uncertenty_data.az then
            return polygonPoints
        end
        if type(numPoints) ~= "number" then
            numPoints = 8
        end
        if not HOUND.Utils.Geo.isDcsPoint(refPos) then
            refPos = {x=0,y=0,z=0}
        end
        local angleStep = pi_2/numPoints
        local theta = l_math.rad(uncertenty_data.az)

        -- generate ellips points
        -- for pointAngle = angleStep, pi_2+angleStep/8, angleStep do
        for i = 1, numPoints do
            local pointAngle = i * angleStep
            -- env.info("polygon angle " .. l_math.deg(pointAngle))

            local point = {}
            point.x = uncertenty_data.major/2 * l_math.cos(pointAngle)
            point.z = uncertenty_data.minor/2 * l_math.sin(pointAngle)
            -- rotate and translate into correct position
            local x = point.x * l_math.cos(theta) - point.z * l_math.sin(theta)
            local z = point.x * l_math.sin(theta) + point.z * l_math.cos(theta)
            point.x = x + refPos.x
            point.z = z + refPos.z

            table.insert(polygonPoints, point)
        end
        HOUND.Utils.Geo.setHeight(polygonPoints)

        return polygonPoints

    end

    --- Draw marker Polygon
    -- @local
    -- @int numPoints number of points to draw (only 1,4,8 and 16 are valid)
    function HOUND.Contact:drawAreaMarker(numPoints)
        if numPoints == nil then numPoints = 1 end
        if numPoints ~= 1 and numPoints ~= 4 and numPoints ~=8 and numPoints ~= 16 then
            HOUND.Logger.error("DCS limitation, only 1,4,8 or 16 points are allowed")
            numPoints = 1
            end

        -- setup the marker
        local alpha = HOUND.Utils.Mapping.linear(l_math.floor(HOUND.Utils.absTimeDelta(self.last_seen)),0,HOUND.CONTACT_TIMEOUT,0.2,0.05,true)
        local fillColor = {0,0,0,alpha}
        local lineColor = {0,0,0,0.30}
        if self._platformCoalition == coalition.side.BLUE then
            fillColor[1] = 1
            lineColor[1] = 1
        end

        if self._platformCoalition == coalition.side.RED then
            fillColor[3] = 1
            lineColor[3] = 1
        end

        local markArgs = {
            fillColor = fillColor,
            lineColor = lineColor,
            coalition = self._platformCoalition
        }
        if numPoints == 1 then
            markArgs.pos = {
                p = self.pos.p,
                r = self.uncertenty_data.r
            }
        else
            markArgs.pos = HOUND.Contact.calculatePoly(self.uncertenty_data,numPoints,self.pos.p)
        end
        return self._markpoints.u:update(markArgs)
    end

    --- Update marker positions
    -- @param MarkerType type of marker to use
    function HOUND.Contact:updateMarker(MarkerType)
        if self.pos.p == nil or self.uncertenty_data == nil and not self:isRecent() then return end

        local markerArgs = {
            text = self.typeName .. " " .. (self.uid%100) ..
                    " (" .. self.uncertenty_data.major .. "/" .. self.uncertenty_data.minor .. "@" .. self.uncertenty_data.az .. ")",
            pos = self.pos.p,
            coalition = self._platformCoalition
        }
        self._markpoints.p:update(markerArgs)

        if MarkerType == HOUND.MARKER.NONE then return end

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

    --- Sector Mangment
    -- @section sectors

    --- Get primaty sector for contact
    -- @return name of sector the position is in
    function HOUND.Contact:getPrimarySector()
        return self.primarySector
    end

    --- get sectors contact is threatening
    -- @return list of sector names
    function HOUND.Contact:getSectors()
        return self.threatSectors
    end

    --- check if threatens sector
    -- @param sectorName
    -- @return Boot True if theat
    function HOUND.Contact:isInSector(sectorName)
        -- HOUND.Logger.trace("inSector " .. self:getName() .. " (" .. tostring(sectorName) .."): ".. tostring(self.threatSectors[sectorName]) )
        return self.threatSectors[sectorName] or false
    end

    --- set correct sector 'default position' sector state
    -- @local
    function HOUND.Contact:updateDefaultSector()
        self.threatSectors[self.primarySector] = true
        if self.primarySector == "default" then return end
        for k,v in pairs(self.threatSectors) do
            if k ~= "default" and v == true then
                self.threatSectors["default"] = false
                return
            end
        end
        self.threatSectors["default"] = true
    end

    --- Update sector data
    -- @string sectorName name of sector
    -- @string inSector true if contact is in the sector
    -- @string threatsSector true if contact threatens sector
    function HOUND.Contact:updateSector(sectorName,inSector,threatsSector)
        if inSector == nil and threatsSector == nil then
            -- this sector has no zone this might need some logic. but for now just no.
            return
        end
        self.threatSectors[sectorName] = threatsSector or false

        if inSector and self.primarySector ~= sectorName then
            self.primarySector = sectorName
            self.threatSectors[sectorName] = true
        end
        self:updateDefaultSector()
    end

    --- add contact to names sector
    -- @string sectorName name of sector
    function HOUND.Contact:addSector(sectorName)
        self.threatSectors[sectorName] = true
        self:updateDefaultSector()
    end

    --- remove contact from named sector
    -- @string sectorName name of sector
    function HOUND.Contact:removeSector(sectorName)
        if self.threatSectors[sectorName] then
            self.threatSectors[sectorName] = false
            self:updateDefaultSector()
        end
    end

    --- check if contact in names sector
    -- @string sectorName name of sector
    -- @return bool True if contact thretens sector
    function HOUND.Contact:isThreatsSector(sectorName)
        return self.threatSectors[sectorName] or false
    end

    --- Helper functions
    -- @section helpers

    --- Use Unit Position
    function HOUND.Contact:useUnitPos()
        if not self.unit:isExist() then
            HOUND.Logger.info("PB failed - unit does not exist")
            return
        end
        local state = HOUND.EVENTS.RADAR_DETECTED
        if type(self.pos.p) == "table" then
            state = HOUND.EVENTS.RADAR_UPDATED
        end
        local unitPos = self.unit:getPosition()
        self.preBriefed = true

        self.pos.p = unitPos.p
        self:calculatePosExtras(self.pos)

        self.uncertenty_data = {}
        self.uncertenty_data.major = 0.1
        self.uncertenty_data.minor = 0.1
        self.uncertenty_data.az = 0
        self.uncertenty_data.r  = 0.1

        table.insert(self.detected_by,"External")
        return state
    end

    --- Generate contact export object
    -- @return exported object
    function HOUND.Contact:export()
        local contact = {}
        contact.typeName = self.typeName
        contact.uid = self.uid % 100
        contact.DCSunitName = self.unit:getName()
        if self.pos.p ~= nil and self.uncertenty_data ~= nil then
            contact.pos = self.pos.p
            contact.LL = self.pos.LL

            contact.accuracy = HOUND.Utils.TTS.getVerbalConfidenceLevel( self.uncertenty_data.r )
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
