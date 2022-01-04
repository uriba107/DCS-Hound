--- HoundContact
-- Contact class. containing related functions
-- @module HoundContact
do
    --- HoundContact decleration
    -- Contact class. containing related functions
    -- @type HoundContact
    HoundContact = {}
    HoundContact.__index = HoundContact

    local l_math = math
    local l_mist = mist
    local pi_2 = l_math.pi*2

    --- create new HoundContact instance
    -- @param DCS_Unit emitter DCS Unit
    -- @param HoundCoalition coalition Id of Hound Instace
    -- @return HoundContact
    function HoundContact.New(DCS_Unit,HoundCoalition)
        if not DCS_Unit or type(DCS_Unit) ~= "table" or not DCS_Unit.getName or not HoundCoalition then
            HoundLogger.warn("failed to create HoundContact instance")
            return
        end
        local elintcontact = {}
        setmetatable(elintcontact, HoundContact)
        elintcontact.unit = DCS_Unit
        elintcontact.uid = DCS_Unit:getID()
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

        if setContains(HoundDB.Sam,DCS_Unit:getTypeName())  then
            local unitName = DCS_Unit:getTypeName()
            elintcontact.typeName =  HoundDB.Sam[unitName].Name
            elintcontact.isEWR = setContainsValue(HoundDB.Sam[unitName].Role,"EWR")
            elintcontact.typeAssigned = HoundDB.Sam[unitName].Assigned
            elintcontact.band = HoundDB.Sam[unitName].Band
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
        elintcontact.maxWeaponsRange = HoundUtils.getSamMaxRange(DCS_Unit)
        elintcontact.detectionRange = HoundUtils.getRadarDetectionRange(DCS_Unit)
        elintcontact._dataPoints = {}
        elintcontact._markpointID = nil
        elintcontact._platformCoalition = HoundCoalition
        elintcontact.primarySector = "default"
        elintcontact.threatSectors = {
            default = true
        }
        elintcontact.detected_by = {}
        elintcontact.state = HOUND.EVENTS.RADAR_NEW
        elintcontact.preBriefed = false
        return elintcontact
    end

    --- Destructor function
    function HoundContact:destroy()
        self:removeMarkers()
    end

    --- Getters and Setters
    -- @section settings

    --- Get contact name
    -- @return String
    function HoundContact:getName()
        return self.typeName .. " " .. (self.uid%100)
    end

    --- Get contact type name
    -- @return String
    function HoundContact:getType()
        return self.typeName
    end

    --- Get contact UID
    -- @return Number
    function HoundContact:getId()
        return self.uid%100
    end

    --- get current extimted position
    function HoundContact:getPos()
        return self.pos.p
    end

    --- check if contact has estimated position
    function HoundContact:hasPos()
        return HoundUtils.Polygon.isDcsPoint(self.pos.p)
    end

    --- get max weapons range
    function HoundContact:getMaxWeaponsRange()
        return self.maxWeaponsRange
    end

    --- get type assinged string
    function HoundContact:getTypeAssigned()
        return table.concat(self.typeAssigned," or ")
    end
    --- check if contact DCS Unit is still alive
    -- @return State (bool)
    -- @return Boolean
    function HoundContact:isAlive()
        if self.unit:isExist() == false or self.unit:getLife() <= 1 then return false end
        return true
    end

    --- check if contact is timed out
    -- @return Bool True if timed out
    function HoundContact:isTimedout()
        return HoundUtils.absTimeDelta(timer.getAbsTime(), self.last_seen) > HOUND.CONTACT_TIMEOUT
    end
    --- Data Processing
    -- @section data_process

    --- Remove stale datapoints
    -- @local
    function HoundContact:CleanTimedout()
        if self:isTimedout() then
            -- if contact wasn't seen for 15 minuts purge all currnent data
            self._dataPoints = {}
            self.state = HOUND.EVENTS.RADAR_ASLEEP
        end
    end

    --- returns number of datapoints in contact
    -- @return Number of datapoint
    function HoundContact:countDatapoints()
        local count = 0
        for _,platformDataPoints in pairs(self.dataPoints) do
            count = count + Length(platformDataPoints)
        end
        return count
    end

    --- Add Datapoint to content
    -- @param datapoint HoundDatapoint
    function HoundContact:AddPoint(datapoint)
        self.last_seen = datapoint.t
        if Length(self._dataPoints[datapoint.platformId]) == 0 then
            self._dataPoints[datapoint.platformId] = {}
        end

        if datapoint.platformStatic then
            -- if Reciver is static, just keep the last Datapoint, as position never changes.
            -- if There is a datapoint, do rolling avarage on AZ to clean errors out.
            if Length(self._dataPoints[datapoint.platformId]) > 0 then
                -- poor man's Kalman
                self._dataPoints[datapoint.platformId][1]:AzKalman(datapoint.az)
                datapoint = self._dataPoints[datapoint.platformId][1]
                -- datapoint.az =  HoundUtils.AzimuthAverage({datapoint.az,self._dataPoints[datapoint.platformId][1].az})
            end
            self._dataPoints[datapoint.platformId] = {datapoint}
            return
        end

        if Length(self._dataPoints[datapoint.platformId]) < 2 then
            table.insert(self._dataPoints[datapoint.platformId], datapoint)
        else
            local LastElementIndex = Length(self._dataPoints[datapoint.platformId])
            local DeltaT = HoundUtils.absTimeDelta(self._dataPoints[datapoint.platformId][LastElementIndex - 1].t, datapoint.t)
            if  DeltaT >= 60 then
                table.insert(self._dataPoints[datapoint.platformId], datapoint)
            else
                self._dataPoints[datapoint.platformId][LastElementIndex] = datapoint
            end
            if Length(self._dataPoints[datapoint.platformId]) > HOUND.NUM_DATAPOINTS then
                table.remove(self._dataPoints[datapoint.platformId], 1)
            end
        end
    end

    --- Take two HoundDatapoints and return the location of intersection
    -- @local
    -- @param earlyPoint HoundDatapoint
    -- @param latePoint HoundDatapoint
    -- @return Position
    function HoundContact.triangulatePoints(earlyPoint, latePoint)
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
    function HoundContact.getDeltaSubsetPercent(Table,referencePos,NthPercentile)
        local t = l_mist.utils.deepCopy(Table)
        for _,pt in ipairs(t) do
            pt.dist = l_mist.utils.get2DDist(referencePos,pt)
        end
        table.sort(t,function(a,b) return a.dist < b.dist end)

        local percentile = l_math.floor(Length(t)*NthPercentile)
        local NumToUse = l_math.max(l_math.min(2,Length(t)),percentile)
        local RelativeToPos = {}
        for i = 1, NumToUse  do
            table.insert(RelativeToPos,l_mist.vec.sub(t[i],referencePos))
        end

        return RelativeToPos
    end

    --- Calculate Cotact's Ellipse of uncertenty
    -- @local
    -- @param estimatedPositions List of estimated positions
    -- @param[opt] Theta Azimuth bias of the dataset - in none given angle will be derrived from datapoints
    -- @return None (updates self.uncertenty_data)
    function HoundContact:calculateEllipse(estimatedPositions,Theta)

        local RelativeToPos = HoundContact.getDeltaSubsetPercent(estimatedPositions,self.pos.p,HOUND.ELLIPSE_PERCENTILE)

        local min = {}
        min.x = 99999
        min.y = 99999

        local max = {}
        max.x = -99999
        max.y = -99999

        -- -- experimental BS
        -- if Theta == nil then

        --     local AzBiasPool = {}

        --     for _,pos in ipairs(RelativeToPos) do
        --         table.insert(AzBiasPool,l_math.atan2(pos.z,pos.x))
        --     end

        --     Theta = HoundUtils.AzimuthAverage(AzBiasPool)
        -- end

        -- even more experimental BS
        if Theta == nil then
            Theta = HoundUtils.PointClusterTilt(RelativeToPos)
        end

        -- working rotation matrix BS
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

        self.uncertenty_data = {}
        self.uncertenty_data.major = l_math.max(a,b)
        self.uncertenty_data.minor = l_math.min(a,b)
        self.uncertenty_data.az = l_mist.utils.round(l_math.deg((Theta + pi_2)%pi_2))
        self.uncertenty_data.r  = (a+b)/4

    end

    --- Finallize position estimation Contact position
    -- @local
    -- @param estimatedPositions List of all estimated positions derrived fomr datapoints and intersections
    -- @param[opt] converge Boolean, if True function will try and converge on best position
    function HoundContact:calculatePos(estimatedPositions,converge)
        if estimatedPositions == nil then return end
        self.pos.p = l_mist.getAvgPoint(estimatedPositions)
        if converge then
            local subList = estimatedPositions
            local subsetPos = self.pos.p
            while (Length(subList) * HOUND.ELLIPSE_PERCENTILE) > 5 do
                local NewsubList = HoundContact.getDeltaSubsetPercent(subList,subsetPos,HOUND.ELLIPSE_PERCENTILE)
                subsetPos = l_mist.getAvgPoint(NewsubList)

                self.pos.p.x = self.pos.p.x + (subsetPos.x )
                self.pos.p.z = self.pos.p.z + (subsetPos.z )
                subList = NewsubList
                -- if HOUND.DEBUG then
                --     local goCrazy = mist.utils.deepCopy(subList)
                --     for _,point in pairs(goCrazy) do
                --         point.x = point.x + self.pos.p.x
                --         point.z = point.z + self.pos.p.z
                --     end
                --     local hull = HoundUtils.Polygon.giftWrap(goCrazy)
                --     if hull then
                --         for _,point in pairs(hull) do
                --             -- point.x = point.x+self.pos.p.x
                --             -- point.z = point.z+self.pos.p.z
                --             point.y = land.getHeight({x=point.x,y=point.z})
                --         end

                --         -- trigger.action.markupToAll(7,self._platformCoalition,self:getMarkerId(),
                --         -- unpack(hull),{0,255,0,0.5},{0,255,0,0.2},2)
                --         local marker = {
                --             id = self:getMarkerId(),
                --             pos = hull,
                --             markType = 7,
                --             markForCoa = self._platformCoalition,
                --             fillColor = {0,0,128,0.2}
                --         }
                --         mist.marker.add(marker)
                --     end
                -- end
            end
        end
        self.pos.p.y = land.getHeight({x=self.pos.p.x,y=self.pos.p.z})
        local bullsPos = coalition.getMainRefPoint(self._platformCoalition)
        self.pos.LL.lat, self.pos.LL.lon =  coord.LOtoLL(self.pos.p)
        self.pos.elev = self.pos.p.y
        self.pos.grid  = coord.LLtoMGRS(self.pos.LL.lat, self.pos.LL.lon)
        self.pos.be = HoundUtils.getBR(bullsPos,self.pos.p)

    end

    --- process data in contact
    -- @return HoundEvent
    -- @see HOUND.EVENTS
    function HoundContact:processData()
        if self.preBriefed then
            HoundLogger.trace(self:getName().." is PB..")
            if self.unit:isExist() then
                local unitPos = self.unit:getPosition()
                if l_mist.utils.get3DDist(unitPos.p,self.pos.p) < 0.1 then
                    HoundLogger.trace("No change in position.. skipping..")
                    return
                end
                HoundLogger.trace("position changed.. removing PB mark..")
                self.preBriefed = false
            else
                HoundLogger.trace("PB Unit does not exist")
                return
            end
        end
        local newContact = (self.state == HOUND.EVENTS.RADAR_NEW)
        local mobileDataPoints = {}
        local staticDataPoints = {}
        local estimatePositions = {}
        local platforms = {}
        local staticPlatformsOnly = true
        for _,platformDatapoints in pairs(self._dataPoints) do
            if Length(platformDatapoints) > 0 then
                for _,datapoint in pairs(platformDatapoints) do
                    if datapoint:isStatic() then
                        table.insert(staticDataPoints,datapoint)
                    else
                        staticPlatformsOnly = false
                        table.insert(mobileDataPoints,datapoint)
                    end
                    if datapoint.estimatedPos ~= nil then
                        table.insert(estimatePositions,datapoint.estimatedPos)
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
                    local err = (staticDataPoints[i].platformPrecision + staticDataPoints[j].platformPrecision)/2
                    if HoundUtils.angleDeltaRad(staticDataPoints[i].az,staticDataPoints[j].az) > err then
                        table.insert(estimatePositions,self.triangulatePoints(staticDataPoints[i],staticDataPoints[j]))
                    end
                end
            end
        end

        -- Statics against all mobiles
        if numStaticPoints > 0  and numMobilepoints > 0 then
            for _,staticDataPoint in ipairs(staticDataPoints) do
                for _,mobileDataPoint in ipairs(mobileDataPoints) do
                    local err = (staticDataPoint.platformPrecision + mobileDataPoint.platformPrecision)/2
                    if HoundUtils.angleDeltaRad(staticDataPoint.az,mobileDataPoint.az) > err then
                        table.insert(estimatePositions,self.triangulatePoints(staticDataPoint,mobileDataPoint))
                    end
                end
            end
         end

        -- mobiles agains mobiles
        if numMobilepoints > 1 then
            for i=1,numMobilepoints-1 do
                for j=i+1,numMobilepoints do
                    if mobileDataPoints[i].platformPos  ~= mobileDataPoints[j].platformPos then
                        local err = (mobileDataPoints[i].platformPrecision + mobileDataPoints[j].platformPrecision)/2
                        if HoundUtils.angleDeltaRad(mobileDataPoints[i].az,mobileDataPoints[j].az) > err then
                            table.insert(estimatePositions,self.triangulatePoints(mobileDataPoints[i],mobileDataPoints[j]))
                        end
                    end
                end
            end
        end

        if Length(estimatePositions) > 2 or (Length(estimatePositions) > 0 and staticPlatformsOnly) then
            self:calculatePos(estimatePositions,true)
            self:calculateEllipse(estimatePositions)

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
        end

        return self.state
    end

    --- Marker managment
    -- @section markers

    --- Remove all contact's F10 map markers
    -- @local
    function HoundContact:removeMarkers()
        if self.markpointID ~= nil then
            for _ = 1, Length(self.markpointID) do
                trigger.action.removeMark(table.remove(self.markpointID))
            end
        end
    end

    --- get MarkId from factory
    -- @local
    -- return mark idx
    function HoundContact:getMarkerId()
        if self.markpointID == nil then self.markpointID = {} end
        local idx = HoundUtils.getMarkId()
        table.insert(self.markpointID, idx)
        return idx
    end

    --- Draw marker Polygon
    -- @local
    -- @int numPoints number of points to draw (only 1,4,8 and 16 are valid)
    -- @bool[opt] debug if true will return the polygon points
    function HoundContact:drawAreaMarker(numPoints,debug)
        if numPoints == nil then numPoints = 1 end
        if numPoints ~= 1 and numPoints ~= 4 and numPoints ~=8 and numPoints ~= 16 then
            HoundLogger.error("DCS limitation, only 1,4,8 or 16 points are allowed")
            numPoints = 1
            end

        -- setup the marker
        local alpha = Map(l_math.floor(HoundUtils.absTimeDelta(self.last_seen)),0,HOUND.CONTACT_TIMEOUT,0.2,0.1)
        local fillcolor = {0,0,0,alpha}
        local linecolor = {0,0,0,alpha+0.15}
        if self._platformCoalition == coalition.side.BLUE then
            fillcolor[1] = 1
            linecolor[1] = 1
        end

        if self._platformCoalition == coalition.side.RED then
            fillcolor[3] = 1
            linecolor[3] = 1
        end

        if numPoints == 1 then
            trigger.action.circleToAll(self._platformCoalition,self:getMarkerId(),
            self.pos.p,self.uncertenty_data.r,linecolor,fillcolor,2,true)
            return
        end

        -- x = minorAxis*cos(theta)
        -- y = majorAxis*sin(theta)
        local angleStep = pi_2/numPoints
        local theta = l_math.rad(self.uncertenty_data.az)

        local polygonPoints = {}

        -- generate ellips points
        -- for pointAngle = angleStep, pi_2+angleStep/8, angleStep do
        for i = 1, numPoints do
            local pointAngle = i * angleStep
            -- env.info("polygon angle " .. l_math.deg(pointAngle))

            local point = {}
            point.x = self.uncertenty_data.major/2 * l_math.cos(pointAngle)
            point.z = self.uncertenty_data.minor/2 * l_math.sin(pointAngle)
            -- rotate and translate into correct position
            local x = point.x * l_math.cos(theta) - point.z * l_math.sin(theta)
            local z = point.x * l_math.sin(theta) + point.z * l_math.cos(theta)
            point.x = x + self.pos.p.x
            point.z = z + self.pos.p.z
            point.y = land.getHeight({x=point.x,y=point.z})+0.5

            table.insert(polygonPoints, point)
        end

        if numPoints == 4 then
            trigger.action.markupToAll(6,self._platformCoalition,self:getMarkerId(),
                polygonPoints[1], polygonPoints[2], polygonPoints[3], polygonPoints[4],
                linecolor,fillcolor,2,true)

        end
        if numPoints == 8 then
            trigger.action.markupToAll(7,self._platformCoalition,self:getMarkerId(),
                polygonPoints[1], polygonPoints[2], polygonPoints[3], polygonPoints[4],
                polygonPoints[5], polygonPoints[6], polygonPoints[7], polygonPoints[8],
                linecolor,fillcolor,2,true)
        end
        if numPoints == 16 then
            -- working
            trigger.action.markupToAll(7,self._platformCoalition,self:getMarkerId(),
                polygonPoints[1], polygonPoints[2], polygonPoints[3], polygonPoints[4],
                polygonPoints[5], polygonPoints[6], polygonPoints[7], polygonPoints[8],
                polygonPoints[9], polygonPoints[10], polygonPoints[11], polygonPoints[12],
                polygonPoints[13], polygonPoints[14], polygonPoints[15], polygonPoints[16],
                linecolor,fillcolor,2,true)
        end
        if debug then
            return polygonPoints
        end
    end

    --- Update marker positions
    -- @param MarkerType type of marker to use
    function HoundContact:updateMarker(MarkerType)
        if self.pos.p == nil or self.uncertenty_data == nil then return end

        -- local idx0 = self:getMarkerId()
        self:removeMarkers()

        trigger.action.markToCoalition(self:getMarkerId(), self.typeName .. " " .. (self.uid%100) ..
                                " (" .. self.uncertenty_data.major .. "/" .. self.uncertenty_data.minor .. "@" .. self.uncertenty_data.az .. "|" ..
                                l_math.floor(HoundUtils.absTimeDelta(self.last_seen)) .. "s)",self.pos.p,self._platformCoalition,true)

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
    function HoundContact:getPrimarySector()
        return self.primarySector
    end

    --- get sectors contact is threatening
    -- @return list of sector names
    function HoundContact:getSectors()
        return self.threatSectors
    end

    --- check if threatens sector
    -- @param sectorName
    -- @return Boot True if theat
    function HoundContact:isInSector(sectorName)
        -- HoundLogger.trace("inSector " .. self:getName() .. " (" .. tostring(sectorName) .."): ".. tostring(self.threatSectors[sectorName]) )
        return self.threatSectors[sectorName] or false
    end

    --- set correct sector 'default position' sector state
    -- @local
    function HoundContact:updateDefaultSector()
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
    function HoundContact:updateSector(sectorName,inSector,threatsSector)
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
    function HoundContact:addSector(sectorName)
        self.threatSectors[sectorName] = true
        self:updateDefaultSector()
    end

    --- remove contact from named sector
    -- @string sectorName name of sector
    function HoundContact:removeSector(sectorName)
        if self.threatSectors[sectorName] then
            self.threatSectors[sectorName] = false
            self:updateDefaultSector()
        end
    end

    --- check if contact in names sector
    -- @string sectorName name of sector
    -- @return bool True if contact thretens sector
    function HoundContact:isThreatsSector(sectorName)
        return self.threatSectors[sectorName] or false
    end

    --- Helper functions
    -- @section helpers

    --- Use Unit Position
    function HoundContact:useUnitPos()
        if not self.unit:isExist() then
            HoundLogger.info("PB failed - unit does not exist")
            return
        end
        local state = HOUND.EVENTS.RADAR_DETECTED
        if type(self.pos.p) == "table" then
            state = HOUND.EVENTS.RADAR_UPDATED
        end
        local bullsPos = coalition.getMainRefPoint(self._platformCoalition)
        local unitPos = self.unit:getPosition()
        self.preBriefed = true

        self.pos.p = unitPos.p
        self.pos.LL.lat, self.pos.LL.lon =  coord.LOtoLL(self.pos.p)
        self.pos.elev = self.pos.p.y
        self.pos.grid  = coord.LLtoMGRS(self.pos.LL.lat, self.pos.LL.lon)
        self.pos.be = HoundUtils.getBR(bullsPos,self.pos.p)

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
    function HoundContact:export()
        local contact = {}
        contact.typeName = self.typeName
        contact.uid = self.uid % 100
        contact.DCSunitName = self.unit:getName()
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
