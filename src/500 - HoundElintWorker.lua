    --- HOUND.ElintWorker
    -- @module HOUND.ElintWorker
do
    local HoundUtils = HOUND.Utils

    HOUND.ElintWorker = {}
    HOUND.ElintWorker.__index = HOUND.ElintWorker

    local l_math = math
    function HOUND.ElintWorker.create(HoundInstanceId)
        local instance = {}
        instance.contacts = {}
        instance.platforms = {}
        instance.sites = {}
        instance.settings =  HOUND.Config.get(HoundInstanceId)
        instance.coalitionId = nil
        instance.TrackIdCounter = 0
        setmetatable(instance, HOUND.ElintWorker)
        return instance
    end

    --- set coalition
    -- retundent function will change global coalition
    function HOUND.ElintWorker:setCoalition(coalitionId)
        if not coalitionId then return false end
        if not self.settings:getCoalition() then
            self.settings:setCoalition(coalitionId)
            return true
        end
        return false
    end

    --- get worker coalition
    -- @return coalitionId
    function HOUND.ElintWorker:getCoalition()
        return self.settings:getCoalition()
    end

    --- get the next track number
    -- @return UID for the contact
    function HOUND.ElintWorker:getNewTrackId()
        self.TrackIdCounter = self.TrackIdCounter + 1
        return self.TrackIdCounter
    end

    --- Platform Management
    -- @section Platforms

    --- add platform
    -- @string platformName DCS Unit Name of platform to be added
    -- @return[type=bool] True if requested platform was added. else false
    function HOUND.ElintWorker:addPlatform(platformName)
        local candidate = Unit.getByName(platformName) or StaticObject.getByName(platformName)

        if self:getCoalition() == nil and candidate ~= nil then
            self:setCoalition(candidate:getCoalition())
        end

        if candidate ~= nil and candidate:getCoalition() == self:getCoalition()
            and not HOUND.setContainsValue(self.platforms,candidate) and HOUND.DB.isValidPlatform(candidate) then
                table.insert(self.platforms, candidate)
                HOUND.EventHandler.publishEvent({
                    id = HOUND.EVENTS.PLATFORM_ADDED,
                    initiator = candidate,
                    houndId = self.settings:getId(),
                    coalition = self.settings:getCoalition()
                })
                return true
        end
        HOUND.Logger.warn("[Hound] - Failed to add platform "..platformName..". Make sure you use unit name and that all requirments are met.")
        return false
    end

    --- remove specificd platform
    -- @param platformName DCS Unit name to remove
    -- @return[type=bool] true if removed, else false
    function HOUND.ElintWorker:removePlatform(platformName)
        local candidate = Unit.getByName(platformName)
        if candidate == nil then
            candidate = StaticObject.getByName(platformName)
        end

        if candidate ~= nil then
            for k,v in ipairs(self.platforms) do
                if v == candidate then
                    table.remove(self.platforms, k)
                    HOUND.EventHandler.publishEvent({
                        id = HOUND.EVENTS.PLATFORM_REMOVED,
                        initiator = candidate,
                        houndId = self.settings:getId(),
                        coalition = self.settings:getCoalition()
                    })
                    return true
                end
            end
        end
        return false
    end

    --- make sure all platforms are still alive and relevate
    function HOUND.ElintWorker:platformRefresh()
        if HOUND.Length(self.platforms) < 1 then return end
        for id,platform in ipairs(self.platforms) do
            if platform:isExist() == false or platform:getLife() <1 then
                table.remove(self.platforms, id)
                HOUND.EventHandler.publishEvent({
                    id = HOUND.EVENTS.PLATFORM_DESTROYED,
                    initiator = platform,
                    houndId = self.settings:getId(),
                    coalition = self.settings:getCoalition()
                })
            end
        end
    end

    --- remove dead platforms
    function HOUND.ElintWorker:removeDeadPlatforms()
        if HOUND.Length(self.platforms) < 1 then return end
        for id,platform in ipairs(self.platforms) do
            if platform:isExist() == false or platform:getLife() <1  or (platform:getCategory() ~= Object.Category.STATIC and platform:isActive() == false) then
                table.remove(self.platforms, id)
                HOUND.EventHandler.publishEvent({
                    id = HOUND.EVENTS.PLATFORM_DESTROYED,
                    initiator = platform,
                    houndId = self.settings:getId(),
                    coalition = self.settings:getCoalition()
                })
            end
        end
    end

    --- count number of platforms
    -- @return[type=int] number of platforms
    function HOUND.ElintWorker:countPlatforms()
        return HOUND.Length(self.platforms)
    end

    --- list all associated platform unit names
    -- @return Table list of active platform names
    function HOUND.ElintWorker:listPlatforms()
        local platforms = {}
        for _,platform in ipairs(self.platforms) do
            table.insert(platforms,platform:getName())
        end
        return platforms
    end

    --- Contact Management
    -- @section Contacts

    --- return if contact exists in the system
    -- @return[type=bool] return True if unit is in the system
    function HOUND.ElintWorker:isContact(emitter)
        if emitter == nil then return false end
        local emitterName = nil
        if type(emitter) == "string" then
            emitterName = emitter
        end
        if type(emitter) == "table" and emitter.getName ~= nil then
            emitterName = emitter:getName()
        end
        return HOUND.setContains(self.contacts,emitterName)
    end

    --- add contact to worker
    -- @param emitter DCS Unit to add
    -- @return Name of added unit
    function HOUND.ElintWorker:addContact(emitter)
        if emitter == nil or emitter.getName == nil then return end
        local emitterName = emitter:getName()
        if self.contacts[emitterName] ~= nil then return emitterName end
        self.contacts[emitterName] = HOUND.Contact.Emitter:New(emitter, self:getCoalition(), self:getNewTrackId())
        local site = self:getSite(self.contacts[emitterName])
        if site then
            site:addEmitter(self.contacts[emitterName])
        else
            HOUND.Logger.debug("failed to create site")
        end
        self.contacts[emitterName]:queueEvent(HOUND.EVENTS.RADAR_NEW)
        return emitterName
    end

    --- get HOUND.Contact from DCS Unit/UID
    -- @param emitter DCS Unit/name of radar unit
    -- @param[opt] getOnly if true function will not create new unit if not exist
    -- @return @{HOUND.Contact.Emitter} instance of that Unit
    function HOUND.ElintWorker:getContact(emitter,getOnly)
        if emitter == nil then return nil end
        local emitterName = nil
        if type(emitter) == "string" then
            emitterName = emitter
        end
        if HoundUtils.Dcs.isUnit(emitter) then
            emitterName = emitter:getName()
        end
        if getmetatable(emitter) == HOUND.Contact.Emitter then
            emitterName = emitter:getDcsName()
        end
        if emitterName ~= nil and self.contacts[emitterName] ~= nil then return self.contacts[emitterName] end
        if not self.contacts[emitterName] and type(emitter) == "table" and not getOnly then
            self:addContact(emitter)
            return self.contacts[emitterName]
        end
        return nil
    end

    --- remove Contact from tracking
    -- @string emitterName DCS unit Name to remove
    -- @return[type=bool] true if removed.
    function HOUND.ElintWorker:removeContact(emitterName)
        if type(emitterName) == "table" and getmetatable(emitterName) == HOUND.Contact.Emitter then
            emitterName = emitterName:getDcsName()
        end
        if not type(emitterName) == "string" then return false end
        if self.contacts[emitterName] then
            local site = self:getSite(self.contacts[emitterName]:getDcsGroupName(),true)
            if site then
                site:removeEmitter(self.contacts[emitterName])
            end

            self.contacts[emitterName]:updateDeadDcsObject()
            -- HOUND.EventHandler.publishEvent({
            --     id = HOUND.EVENTS.RADAR_DESTROYED,
            --     initiator = self.contacts[emitterName],
            --     houndId = self.settings:getId(),
            --     coalition = self.settings:getCoalition()
            -- })
        end
        self.contacts[emitterName] = nil
        return true
    end

    --- set contact as Prebriefed
    -- @param emitter DCS Unit/Unit name of radar
    function HOUND.ElintWorker:setPreBriefedContact(emitter)
        if not emitter:isExist() then return end
        local contact = self:getContact(emitter)
        local contactState = contact:useUnitPos()
        if contactState then
            HOUND.EventHandler.publishEvent({
                id = contactState,
                initiator = contact,
                houndId = self.settings:getId(),
                coalition = self.settings:getCoalition()
            })
        end
    end

    --- set contact as Dead
    -- @param emitter DCS Unit/Unit name of radar
    function HOUND.ElintWorker:setDead(emitter)
        local contact = self:getContact(emitter,true)
        if contact then
            HOUND.Logger.trace("setDead for " .. contact:getName())
            contact:setDead()
         end
    end
    --- is contact is tracked
    -- @param emitter DCS Unit/UID of requested emitter
    -- @return[type=bool] if Unit is being tracked by current HoundWorker instance.
    function HOUND.ElintWorker:isTracked(emitter)
        if emitter == nil then return false end
        if type(emitter) =="string" and self.contacts[emitter] ~= nil then return true end
        if type(emitter) == "table" and emitter.getName ~= nil and self.contacts[emitter:getName()] ~= nil then return true end
        return false
    end

    -- --- add datapoint to emitter
    -- -- @param emitter DCS UNIT with radar
    -- -- @param datapoint @{HOUND.Contact.Datapoint} instance
    -- function HOUND.ElintWorker:addDatapointToEmitter(emitter,datapoint)
    --     if not self:isTracked(emitter) then
    --         self:addContact(emitter)
    --     end
    --     local HoundContact = self:getContact(emitter)
    --     HoundContact:AddPoint(datapoint)
    -- end

    --- Site functions
    -- @section Sites

    --- return if site exists in the system
    -- @param site group name
    -- @return[type=bool] return True if group is in the system
    function HOUND.ElintWorker:isSite(site)
        if site == nil then return false end
        local groupName = nil
        if type(site) == "string" then
            groupName = site
        end
        if HOUND.Utils.Dcs.isGroup(site) then
            groupName = site:getName()
        end
        return HOUND.setContains(self.sites,groupName)
    end


    --- add site to worker
    -- @param emitter DCS Unit to add
    -- @return Name of added group
    function HOUND.ElintWorker:addSite(emitter)
        if emitter == nil or emitter.getName == nil then return end
        local groupName = emitter:getDcsGroupName()
        if self.sites[groupName] ~= nil then return groupName end
        self.sites[groupName] = HOUND.Contact.Site:New(emitter, self:getCoalition(), self:getNewTrackId())
        self.sites[groupName]:queueEvent(HOUND.EVENTS.SITE_NEW)
        return groupName
    end

    --- get HOUND.Contact.Site from DCS Unit/UID
    -- @param emitter  @{HOUND.Contact.Emitter} or DCS group name or DCS group
    -- @param[opt] getOnly if true function will not create new unit if not exist
    -- @return @{HOUND.Contact.Site} instance of input group
    function HOUND.ElintWorker:getSite(emitter,getOnly)
        if emitter == nil then return nil end
        local groupName = nil
        if type(emitter) == "string" then
            groupName = emitter
        end
        if HOUND.Utils.Dcs.isGroup(emitter) then
            groupName = emitter:getName()
        elseif HOUND.Utils.Dcs.isUnit(emitter) then
            groupName = Group.getName(emitter:getGroup())
        end
        if getmetatable(emitter) == HOUND.Contact.Emitter then
            groupName = emitter:getDcsGroupName()
        end
        if groupName ~= nil and self.sites[groupName] ~= nil then return self.sites[groupName] end
        if not self.sites[groupName] and type(emitter) == "table" and not getOnly then
            self:addSite(emitter)
            return self.sites[groupName]
        end
        return nil
    end

    --- remove Site from tracking
    -- @string groupName DCS group Name to remove
    -- @return[type=bool] true if removed.
    function HOUND.ElintWorker:removeSite(groupName)
        if type(groupName) == "table" and getmetatable(groupName) == HOUND.Contact.Site then
            groupName = groupName:getDcsName()
        end
        if not type(groupName) == "string" then return false end
        self.sites[groupName] = nil
        return true
    end


    --- Worker functions
    -- @section Worker

    --- update markers to all contacts
    -- update all emitters
    function HOUND.ElintWorker:UpdateMarkers()
        if self.settings:getUseMarkers() then
            for _,contact in pairs(self.contacts) do
                contact:updateMarker(self.settings:getMarkerType())
            end
        end
        if self.settings:getMarkSites() then
            for _,site in pairs(self.sites) do
                site:updateMarker(HOUND.MARKER.NONE)
            end
        end
    end

    --- Perform a sample of all emitting radars against all platforms
    -- generates and stores datapoints as required
    function HOUND.ElintWorker:Sniff()
        self:removeDeadPlatforms()

        if HOUND.Length(self.platforms) == 0 then return end

        local Radars = HoundUtils.Elint.getActiveRadars(self:getCoalition())

        if HOUND.Length(Radars) == 0 then return end
        -- env.info("Recivers: " .. table.getn(self.platform) .. " | Radars: " .. table.getn(Radars))
        for _,RadarName in ipairs(Radars) do
            local radar = Unit.getByName(RadarName)
            -- local RadarUid = radar:getName()
            -- local RadarType = radar:getTypeName()
            -- local RadarName = radar:getName()
            local radarPos = radar:getPosition().p
            radarPos.y = radarPos.y + radar:getDesc()["box"]["max"]["y"] -- use vehicle bounting box for height
            local _,isRadarTracking = radar:getRadar()

            isRadarTracking = HoundUtils.Dcs.isUnit(isRadarTracking)

            for _,platform in ipairs(self.platforms) do
                local platformData = HOUND.DB.getPlatformData(platform)

                if HoundUtils.Geo.checkLOS(platformData.pos, radarPos) then
                    local contact = self:getContact(radar)
                    local sampleAngularResolution = HOUND.DB.getSensorPrecision(platform,contact.band[isRadarTracking])
                    if sampleAngularResolution < l_math.rad(10.0) then
                        local az,el = HoundUtils.Elint.getAzimuth( platformData.pos, radarPos, sampleAngularResolution )
                        if not platformData.isAerial then
                            el = nil
                        end

                        if not platform.isStatic and self.settings:getPosErr() then
                            for axis,value in pairs(platformData.pos) do
                                platformData.pos[axis] = value + platformData.posErr[axis]
                            end
                        end
                        local signalStrength = HoundUtils.Elint.getSignalStrength(platformData.pos,radarPos,contact.detectionRange)
                        local datapoint = HOUND.Contact.Datapoint.New(platform,platformData.pos, az, el, signalStrength, timer.getAbsTime(),sampleAngularResolution,platformData.isStatic)
                        contact:AddPoint(datapoint)
                    end
                end
            end
        end
    end


    --- Process function
    -- process all the information stored in the system to update all radar positions
    function HOUND.ElintWorker:Process()
        if HOUND.Length(self.contacts) < 1 then return end
        for contactName, contact in pairs(self.contacts) do
            if contact ~= nil then
                local contactState = contact:processData()
                if contactState == HOUND.EVENTS.RADAR_DETECTED then
                    if self.settings:getUseMarkers() then
                        contact:updateMarker(self.settings:getMarkerType())
                    end
                    -- if self.settings:getMarkSites() then
                    --     self:getSite(contact,true):updateMarker(HOUND.MARKER.NONE)
                    -- end
                end

                if contact:isTimedout() and not contact:getPreBriefed() then
                    contactState = contact:CleanTimedout()
                end
                if self.settings:getBDA() and contact:isAlive() and contact:getLife() < 1 then
                    contact:setDead()
                end
                if not contact:isAlive() and (contact:getLastSeen() > 60 or contact:getPreBriefed()) then
                    contact:destroy()
                end

                -- publish event (in case of destroyed radar, event is handled by the notify function)
                if contactState and contactState ~= HOUND.EVENTS.NO_CHANGE then
                    local contactEvents = contact:getEventQueue()
                    while #contactEvents > 0 do
                        local event = table.remove(contactEvents,1)
                        -- HOUND.Logger.onScreenDebug(contact:getDcsName() .. " has triggered " .. HOUND.reverseLookup(HOUND.EVENTS,event.id),5)
                        event.houndId = self.settings:getId()
                        event.coalition = self.settings:getCoalition()
                        HOUND.EventHandler.publishEvent(event)
                    end
                end
            end
        end
        for _, site in pairs(self.sites) do
            if site ~= nil then
                site:processData()
                local siteEvents = site:getEventQueue()
                while #siteEvents > 0 do
                    local event = table.remove(siteEvents,1)
                    -- HOUND.Logger.onScreenDebug(site:getDcsName() .. " has triggered " .. HOUND.reverseLookup(HOUND.EVENTS,event.id),5)
                    event.houndId = self.settings:getId()
                    event.coalition = self.settings:getCoalition()
                    HOUND.EventHandler.publishEvent(event)
                end
            end
        end
    end
end
