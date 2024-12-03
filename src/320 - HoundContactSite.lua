--- HOUND.Contact.Site
-- Site class containing related functions
-- @module HOUND.Contact.Site
-- @see HOUND.Contact.Base
do
    --- HOUND.Contact.Site  (Extends @{HOUND.Contact.Base})
    -- Site class containing related functions
    -- @type HOUND.Contact.Site
    HOUND.Contact.Site = {}
    HOUND.Contact.Site = HOUND.inheritsFrom(HOUND.Contact.Base)

    local l_math = math
    local l_mist = mist
    -- local pi_2 = l_math.pi*2
    local HoundUtils = HOUND.Utils

    --- create new HOUND.Contact.Site instance
    -- @param HoundContact emitter HoundContact
    -- @param HoundCoalition coalition Id of Hound Instace
    -- @param[opt] SiteId specify uid for the Site. if not present Group ID will be used
    -- @return HOUND.Contact.Site instance
    function HOUND.Contact.Site:New(HoundContact,HoundCoalition,SiteId)
        if not HoundContact or type(HoundContact) ~= "table" or not HoundContact.getDcsGroupName or not HoundCoalition then
            HOUND.Logger.warn("failed to create HOUND.Contact.Site instance")
            return
        end
        local instance = self:superClass():New(HoundContact:getDcsObject(),HoundCoalition)
        setmetatable(instance, HOUND.Contact.Site)
        self.__index = self
        instance.DcsObject = HoundContact:getDcsObject():getGroup()
        instance.gid = SiteId or tonumber(instance.DcsObject:getId())
        instance.DcsGroupName = instance.DcsObject:getName()
        instance.DcsObjectName = instance.DcsObject:getName()
        instance.typeAssigned = HoundContact.typeAssigned

        instance.emitters = { HoundContact }
        instance.primaryEmitter = HoundContact
        instance.last_seen = HoundContact:getLastSeen()
        instance.first_seen = HoundContact.first_seen
        instance.last_launch_notify = 0
        instance.maxWeaponsRange = HoundContact:getMaxWeaponsRange()
        instance.detectionRange = HoundContact:getRadarDetectionRange()
        instance.isEWR = HoundContact.isEWR
        instance.state = HOUND.EVENTS.SITE_NEW
        instance.preBriefed = HoundContact:isAccurate()
        instance.DcsRadarUnits = HoundUtils.Dcs.getRadarUnitsInGroup(instance.DcsObject)
        setmetatable(instance.emitters,{__mode="v"})
        return instance
    end

    --- Destructor function
    function HOUND.Contact.Site:destroy()
        self:removeMarkers()
    end

    --- Getters and Setters
    -- @section settings

    --- Get site name
    -- @return String
    function HOUND.Contact.Site:getName()
        -- return self:getType() .. " " .. self:getId()
        local prefix = 'T'
        if self.isEWR then
            prefix = 'S'
        end

        return self.name or string.format("%s%03d",prefix,self:getId())
    end

    --- set Site Name
    -- @param requestedName requested name
    function HOUND.Contact.Site:setName(requestedName)
        if type(requestedName) == "string" or type(requestedName) == "nil" then
            self.name = requestedName
        end
    end

    --- Get site type name
    -- @return String
    function HOUND.Contact.Site:getType()
        return self:getTypeAssigned()
    end

    --- Get Site GID
    -- @return Number
    function HOUND.Contact.Site:getId()
        return self.gid%1000
    end

    --- Get Site Group Name
    -- @return String
    function HOUND.Contact.Site:getDcsGroupName()
        return self.DcsGroupName
    end

    --- Get the DCS unit name
    -- @return String
    function HOUND.Contact.Site:getDcsName()
        return self.DcsGroupName
    end

    --- Get the underlying DCS Object
    -- @return DCS Group or DCS staticObject
    function HOUND.Contact.Site:getDcsObject()
        return self.DcsObject or self.DcsGroupName
    end

    --- Get last seen in seconds
    -- @return number in seconds since contact was last seen
    function HOUND.Contact.Site:getLastSeen()
        return HoundUtils.absTimeDelta(self.last_seen)
    end

    --- get type assinged string
    -- @return string
    function HOUND.Contact.Site:getTypeAssigned()
        return table.concat(self.typeAssigned," or ")
    end

    --- Check if site is Active
    -- @return[type=Bool] True if seen in the last 15 seconds
    function HOUND.Contact.Site:isActive()
        return self:getLastSeen()/16 < 1.0
    end

    --- check if site is recent
    -- @return[type=Bool] True if seen in the last 2 minutes
    function HOUND.Contact.Site:isRecent()
        return self:getLastSeen()/120 < 1.0
    end

    --- check if site position is accurate
    -- @return[type=bool] - True target is pre briefed
    function HOUND.Contact.Site:isAccurate()
        return self.preBriefed
    end

    --- check if contact DCS Unit is still alive
    -- @return[type=bool] True if object is considered Alive
    function HOUND.Contact.Site:isAlive()
        return #self.emitters > 0
    end

    --- check if site is timed out
    -- @return[type=Bool] True if timed out
    function HOUND.Contact.Site:isTimedout()
        return self:getLastSeen() > HOUND.CONTACT_TIMEOUT
    end

    --- Get current state
    -- @return site state in @{HOUND.EVENTS}
    function HOUND.Contact.Site:getState()
        return self.state
    end

    --- get current extimted position of primary
    -- @return DCS point - estimated position
    function HOUND.Contact.Site:getPos()
        return self.pos.p or nil
    end

    --- Does site have any living radars still (for DBA)
    -- @local
    -- @return[type=bool] true if any radars are alive in the group
    function HOUND.Contact.Site:hasRadarUnits()
        if not HoundUtils.Dcs.isGroup(self.DcsObject) or self.DcsObject:getSize() == 0 then return false end
        local lastUnit = self.DcsObject:getUnit(self.DcsObject:getSize())
        return lastUnit:hasSensors(Unit.SensorType.RADAR)
    end

    --- Emitter managment
    -- @section Emitters

    --- Add emitter to site
    -- @param HoundEmitter @{HOUND.Contact.Emitter} radar to add
    -- @return @{HOUND.EVENTS}
    function HOUND.Contact.Site:addEmitter(HoundEmitter)
        self.state = HOUND.EVENTS.NO_CHANGE
        if HoundEmitter:getDcsGroupName() == self:getDcsGroupName() and
            not HOUND.setContainsValue(self.emitters,HoundEmitter) then
                table.insert(self.emitters,HoundEmitter)
                self:selectPrimaryEmitter()
                self:updateTypeAssigned()
                self:updateSector()
                self:updateGroupRadars()
                self.state = HOUND.EVENTS.SITE_UPDATED
        end
        return self.state
    end

    --- Add emitter to site
    -- @param HoundEmitter @{HOUND.Contact.Emitter} radar to remove
    -- @return @{HOUND.EVENTS}
    function HOUND.Contact.Site:removeEmitter(HoundEmitter)
        self.state = HOUND.EVENTS.NO_CHANGE
        if HoundEmitter:getDcsGroupName() == self:getDcsGroupName() then
            for idx,emitter in ipairs(self.emitters) do
                if emitter == HoundEmitter then
                    table.remove(self.emitters,idx)
                    if #self.emitters > 0 then
                        self:selectPrimaryEmitter()
                    end
                    self:updateGroupRadars()
                    self.state = HOUND.EVENTS.SITE_UPDATED
                    break
                end
            end
        end
        return self.state
    end

    --- Prune Nil emitters
    -- @local
    function HOUND.Contact.Site:gcEmitters()
        for idx=#self.emitters,1,-1 do
            if self.emitters[idx] == nil then
                table.remove(self.emitters,idx)
            end
        end
    end

    --- update internal actual radars list
    -- @local
    function HOUND.Contact.Site:updateGroupRadars()
        self.DcsRadarUnits = HoundUtils.Dcs.getRadarUnitsInGroup(self.DcsObject)
    end

    --- Get site's primary emitter
    -- @return @{HOUND.Contact.Emitter}
    function HOUND.Contact.Site:getPrimary()
        if not self.primaryEmitter then
            self:selectPrimaryEmitter()
        end
        return self.primaryEmitter
    end

    --- get Dict with all emitters in site
    -- @return #table @{HOUND.Contact.Emitter}
    function HOUND.Contact.Site:getEmitters()
        return self.emitters
    end

    --- get emitter count for site
    -- @return[type=int] number of emitters currently in the site
    function HOUND.Contact.Site:countEmitters()
        return #self.emitters
    end
    --- re-sort emitters
    -- @local
    function HOUND.Contact.Site:sortEmitters()
        table.sort(self.emitters,HoundUtils.Sort.ContactsByPrio)
    end

    --- select primaty emitter for site
    -- @return[type=Bool] True if primary changed
    function HOUND.Contact.Site:selectPrimaryEmitter()
        self:sortEmitters()
        if self.primaryEmitter ~= self.emitters[1] then
            self.primaryEmitter = self.emitters[1]
            self.isEWR = self.primaryEmitter.isEWR
            self.state = HOUND.EVENTS.SITE_UPDATED
            return true
        end
        return false
    end

    --- update site type
    -- @return[type=Bool] True if site type changed
    function HOUND.Contact.Site:updateTypeAssigned()
        local type = self.primaryEmitter.typeAssigned or {}
        if HOUND.Length(type) > 1 then
            for _,emitter in ipairs(self.emitters) do
                type = HOUND.setIntersection(type,emitter.typeAssigned)
            end
        end
        if self:getTypeAssigned() ~= table.concat(type," or ") then
            self.typeAssigned = type

            if self.state ~= HOUND.EVENTS.SITE_NEW then
               self:queueEvent(HOUND.EVENTS.SITE_CLASSIFIED)
            end
            self.state = HOUND.EVENTS.SITE_UPDATED
        end
    end

    --- update stored site pos
    function HOUND.Contact.Site:updatePos()
        local noPos = (self.pos.p == nil)
        self:ensurePrimaryHasPos()
        for _,emitter in ipairs(self.emitters) do
            if emitter:hasPos() then
                self.pos.p = l_mist.utils.deepCopy(emitter:getPos())
                break
            end
        end
        if noPos and self.pos.p ~= nil then
            self:queueEvent(HOUND.EVENTS.SITE_CREATED)
        end
    end

    --- Ensure primay emitter has position
    -- @param[table] refPos DCS Point with adhock position if nothing else is available
    function HOUND.Contact.Site:ensurePrimaryHasPos(refPos)
        local primary = self:getPrimary()
        if ( not primary:hasPos() ) then
            for _,emitter in ipairs(self.emitters) do
                if ( emitter:hasPos() ) then
                    primary.pos = l_mist.utils.deepCopy(emitter.pos)
                    primary.uncertenty_data = l_mist.utils.deepCopy(emitter.uncertenty_data)
                    break
                end
            end

            if ( not primary:hasPos() and HoundUtils.Dcs.isPoint(refPos)) then
                local uncertenty = primary:getMaxWeaponsRange() * 0.75
                primary.pos.p = l_mist.utils.deepCopy(refPos)
                primary.pos.p = primary:calculateExtrasPosData(primary.pos)
                primary.uncertenty_data = {}
                primary.uncertenty_data.major = uncertenty
                primary.uncertenty_data.minor = uncertenty
                primary.uncertenty_data.theta = 0
                primary.uncertenty_data.az = 0
                primary.uncertenty_data.r  = uncertenty
            end
        end
    end

    --- Update sector data
    function HOUND.Contact.Site:updateSector()
        for _,emitter in ipairs(self.emitters) do
            if emitter:hasPos() then
                self.threatSectors = emitter.threatSectors
                self.primarySector = emitter.primarySector
                break
            end
        end
        self:updateDefaultSector()
    end

    --- trigger launch event
    -- @param[number] cooldown interval between alerts. avoid spam
    function HOUND.Contact.Site:LaunchDetected(cooldown)
        local cooldown = cooldown or 30
        -- HOUND.Logger.trace(self:getName() .. " Launch detected - last notification " ..  HoundUtils.absTimeDelta(self.last_launch_notify))
        if ( HoundUtils.absTimeDelta(self.last_launch_notify) > cooldown ) then
            -- HOUND.Logger.trace(self:getName() .. " LaunchDetected - triggered")

            self.last_launch_notify = timer.getAbsTime()
            -- self:queueEvent(HOUND.EVENTS.SITE_LAUNCH)
            local event = {
                id = HOUND.EVENTS.SITE_LAUNCH,
                initiator = self,
                time = timer.getTime()
            }
            return event
        end
    end

    --- Process site data (wrapper for consistency)
    function HOUND.Contact.Site:processData()
        self:update()
    end

    --- Update site data
    function HOUND.Contact.Site:update()
        -- update stats
        if #self.emitters > 0 then
            self:gcEmitters()
            self:selectPrimaryEmitter()
            self:updateTypeAssigned()
            self:updatePos()
            self:updateSector()
            local isPB = false
            for _,emitter in ipairs(self.emitters) do
                self.last_seen = l_math.max(self.last_seen,emitter.last_seen)
                self.maxWeaponsRange = l_math.max(self.maxWeaponsRange,emitter:getMaxWeaponsRange())
                self.detectionRange = l_math.max(self.detectionRange,emitter:getRadarDetectionRange())
                isPB = isPB or emitter:isAccurate()
            end
            self:setPreBriefed(isPB)
        end
        if self.state ~=  HOUND.EVENTS.SITE_ASLEEP then
            if (self:isTimedout() and not self:isAccurate()) or #self.emitters == 0 then
                self.state = HOUND.EVENTS.SITE_ASLEEP
                self:queueEvent(self.state)
            end
        end
        if #self.emitters == 0 and not self:hasRadarUnits() then
            self:queueEvent(HOUND.EVENTS.SITE_REMOVED)
        end
    end

    --- Marker managment
    -- @section markers

    --- Draw marker Polygon
    -- @local
    -- @int numPoints number of points to draw (only 1,4,8 and 16 are valid)
    function HOUND.Contact.Site:drawAreaMarker(numPoints)
        if numPoints == nil then numPoints = 1 end
        if numPoints ~= 1 and numPoints ~= 4 and numPoints ~=8 and numPoints ~= 16 then
            HOUND.Logger.error("DCS limitation, only 1,4,8 or 16 points are allowed")
            numPoints = 1
            end

        -- setup the marker
        local alpha = HoundUtils.Mapping.linear(l_math.floor(HoundUtils.absTimeDelta(self.last_seen)),0,HOUND.CONTACT_TIMEOUT,0.5,0.1,true)
        local fillColor = {0,0,0,0}
        local lineColor = {0,0.2,0,alpha}
        local lineType = 4
        if (HoundUtils.absTimeDelta(self.last_seen) < 15) then
            lineType = 3
        end
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
            coalition = self._platformCoalition,
            lineType = lineType
        }
        if numPoints == 1 then
            markArgs.pos = {
                p = self:getPos(),
                r = self.maxWeaponsRange
            }
        else
            markArgs.pos = HOUND.Contact.Emitter.calculatePoly(self.uncertenty_data,numPoints,self.pos.p)
        end
        return self._markpoints.area:update(markArgs)
    end

    --- Update marker positions
    -- @param MarkerType type of marker to use
    function HOUND.Contact.Site:updateMarker(MarkerType)
        if not HoundUtils.Dcs.isPoint(self:getPos()) or type(self.maxWeaponsRange) ~= "number"  then return end
        self._markpoints.area:remove()

        local textColor = 0
        local textAlpha = 1
        if not self:isAccurate() then
            textAlpha = HoundUtils.Mapping.linear(l_math.floor(HoundUtils.absTimeDelta(self.last_seen)),10,HOUND.CONTACT_TIMEOUT,1,0.5,true)
        end
        if self:isTimedout() and not self:isAccurate() then
            textAlpha = 0.5
            Colorfactor = 0.3
        end

        local lineColor = {textColor,textColor,textColor,textAlpha}

        if self._platformCoalition == coalition.side.BLUE then
            lineColor[1] = 0.7
        elseif self._platformCoalition == coalition.side.RED then
            lineColor[3] = 0.7
        end

        local markerArgs = {
            text = self:getName() .. " (" .. self:getDesignation(true).. ")",
            pos = self:getPos(),
            coalition = self._platformCoalition,
            lineColor = lineColor,
            useLegacyMarker = false
        }
        self._markpoints.pos:update(markerArgs)

        -- if MarkerType <= HOUND.MARKER.SITE_ONLY then
        --     -- if self._markpoints.area:isDrawn() then
        --         self._markpoints.area:remove()
        --     -- end
        --     return
        -- -- elseif MarkerType > HOUND.MARKER.SITE_ONLY then
        -- --     self:drawAreaMarker()
        -- end
    end

    --- update position markers for site and radars
    -- @param markerType requested HOUND.MARKER type
    -- @param[type=?boolean] drawSite requested HOUND.MARKER for the site.
    function HOUND.Contact.Site:updateMarkers(markerType,drawSite)
        -- update markers of all sites with markerType
        if (type(markerType) ~= "number" or markerType == HOUND.MARKER.NONE) and not drawSite then return end
        if markerType > HOUND.MARKER.SITE_ONLY then
            for _,emitter in pairs(self.emitters) do
                HOUND.Logger.debug("update marker for " .. emitter:getName())
                emitter:updateMarker(markerType)
                HOUND.Logger.debug(emitter:getName() .. " Done")
            end
        end
        if drawSite then
            HOUND.Logger.debug("Update marker for site " .. self:getName())
            self:updateMarker(HOUND.MARKER.SITE_ONLY)
            HOUND.Logger.debug(self:getName() .. " Done")
        end
    end

end