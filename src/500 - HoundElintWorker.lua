    --- HOUND.ElintWorker
    -- @module HOUND.ElintWorker
do
    HOUND.ElintWorker = {}
    HOUND.ElintWorker.__index = HOUND.ElintWorker

    local l_math = math
    function HOUND.ElintWorker.create(HoundInstanceId)
        local instance = {}
        instance._contacts = {}
        instance._platforms = {}
        instance._settings =  HOUND.Config.get(HoundInstanceId)
        instance.coalitionId = nil
        instance.TrackIdCounter = 0
        setmetatable(instance, HOUND.ElintWorker)
        return instance
    end

    --- set coalition
    -- retundent function will change global coalition
    function HOUND.ElintWorker:setCoalition(coalitionId)
        if not coalitionId then return false end
        if not self._settings:getCoalition() then
            self._settings:setCoalition(coalitionId)
            return true
        end
        return false
    end

    --- get worker coalition
    -- @return coalitionId
    function HOUND.ElintWorker:getCoalition()
        return self._settings:getCoalition()
    end

    --- add platform
    -- @string platformName DCS Unit Name of platform to be added
    -- @return Bool. True if requested platform was added. else false
    function HOUND.ElintWorker:addPlatform(platformName)
        local candidate = Unit.getByName(platformName)
        if candidate == nil then
            candidate = StaticObject.getByName(platformName)
        end

        if self:getCoalition() == nil and candidate ~= nil then
            self:setCoalition(candidate:getCoalition())
        end

        if candidate ~= nil and candidate:getCoalition() == self:getCoalition()
            and not setContainsValue(self._platforms,candidate) and HOUND.Utils.Elint.isValidPlatform(candidate) then
                table.insert(self._platforms, candidate)
                HOUND.EventHandler.publishEvent({
                    id = HOUND.EVENTS.PLATFORM_ADDED,
                    initiator = candidate,
                    houndId = self._settings:getId(),
                    coalition = self._settings:getCoalition()
                })
                return true
        end
        HOUND.Logger.warn("[Hound] - Failed to add platform "..platformName..". Make sure you use unit name and that all requirments are met.")
        return false
    end

    --- remove specificd platform
    -- @param platformName DCS Unit name to remove
    -- @return Bool. true if removed, else false
    function HOUND.ElintWorker:removePlatform(platformName)
        local candidate = Unit.getByName(platformName)
        if candidate == nil then
            candidate = StaticObject.getByName(platformName)
        end

        if candidate ~= nil then
            for k,v in ipairs(self._platforms) do
                if v == candidate then
                    table.remove(self._platforms, k)
                    HOUND.EventHandler.publishEvent({
                        id = HOUND.EVENTS.PLATFORM_REMOVED,
                        initiator = candidate,
                        houndId = self._settings:getId(),
                        coalition = self._settings:getCoalition()
                    })
                    return true
                end
            end
        end
        return false
    end

    --- make sure all platforms are still alive and relevate
    function HOUND.ElintWorker:platformRefresh()
        if Length(self._platforms) < 1 then return end
        for id,platform in ipairs(self._platforms) do
            if platform:isExist() == false or platform:getLife() <1 then
                table.remove(self._platforms, id)
                HOUND.EventHandler.publishEvent({
                    id = HOUND.EVENTS.PLATFORM_DESTROYED,
                    initiator = platform,
                    houndId = self._settings:getId(),
                    coalition = self._settings:getCoalition()
                })
            end
        end
    end

    --- remove dead platforms
    function HOUND.ElintWorker:removeDeadPlatforms()
        if Length(self._platforms) < 1 then return end
        for id,platform in ipairs(self._platforms) do
            if platform:isExist() == false or platform:getLife() <1  or (platform:getCategory() ~= Object.Category.STATIC and platform:isActive() == false) then
                table.remove(self._platforms, id)
                HOUND.EventHandler.publishEvent({
                    id = HOUND.EVENTS.PLATFORM_DESTROYED,
                    initiator = platform,
                    houndId = self._settings:getId(),
                    coalition = self._settings:getCoalition()
                })
            end
        end
    end

    --- count number of platforms
    -- @return Int number of platforms
    function HOUND.ElintWorker:countPlatforms()
        return Length(self._platforms)
    end

    --- list all associated platform unit names
    -- @return Table list of active platform names
    function HOUND.ElintWorker:listPlatforms()
        local platforms = {}
        for _,platform in ipairs(self._platforms) do
            table.insert(platforms,platform:getName())
        end
        return platforms
    end

    --- get the next track number
    -- @return UID for the contact
    function HOUND.ElintWorker:getNewTrackId()
        self.TrackIdCounter = self.TrackIdCounter + 1
        return self.TrackIdCounter
    end

    --- return if contact exists in the system
    -- @return Bool return True if unit is in the system
    function HOUND.ElintWorker:isContact(emitter)
        if emitter == nil then return false end
        local emitterName = nil
        if type(emitter) == "string" then
            emitterName = emitter
        end
        if type(emitter) == "table" and emitter.getName ~= nil then
            emitterName = emitter:getName()
        end
        return setContains(self._contacts,emitterName)
    end

    --- add contact to worker
    -- @param emitter DCS Unit to add
    -- @return Name of added unit
    function HOUND.ElintWorker:addContact(emitter)
        if emitter == nil or emitter.getName == nil then return end
        local emitterName = emitter:getName()
        if self._contacts[emitterName] ~= nil then return emitterName end
        self._contacts[emitterName] = HOUND.Contact.New(emitter, self:getCoalition(), self:getNewTrackId())
        HOUND.EventHandler.publishEvent({
            id = HOUND.EVENTS.RADAR_NEW,
            initiator = emitter,
            houndId = self._settings:getId(),
            coalition = self._settings:getCoalition()
        })
        return emitterName
    end

    --- get HOUND.Contact from DCS Unit/UID
    -- @param emitter DCS Unit/name of radar unit
    -- @param[opt] getOnly if true function will not create new unit if not exist
    -- @return HOUND.Contact instance of that Unit
    function HOUND.ElintWorker:getContact(emitter,getOnly)
        if emitter == nil then return nil end
        local emitterName = nil
        if type(emitter) == "string" then
            emitterName = emitter
        end
        if type(emitter) == "table" and emitter.getName ~= nil then
            emitterName = emitter:getName()
        end

        if emitterName ~= nil and self._contacts[emitterName] ~= nil then return self._contacts[emitterName] end
        if not self._contacts[emitterName] and type(emitter) == "table" and not getOnly then
            self:addContact(emitter)
            return self._contacts[emitterName]
        end
        return nil
    end

    --- remove Contact from tracking
    -- @string emitterName DCS unit Name to remove
    -- @return Bool. true if removed.
    function HOUND.ElintWorker:removeContact(emitterName)
        if not type(emitterName) == "string" then return false end
        if self._contacts[emitterName] then
            HOUND.EventHandler.publishEvent({
                id = HOUND.EVENTS.RADAR_DESTROYED,
                initiator = self._contacts[emitterName],
                houndId = self._settings:getId(),
                coalition = self._settings:getCoalition()
            })
        end

        self._contacts[emitterName] = nil
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
                houndId = self._settings:getId(),
                coalition = self._settings:getCoalition()
            })
        end
    end

    --- set contact as Dead
    -- @param emitter DCS Unit/Unit name of radar
    function HOUND.ElintWorker:setDead(emitter)
        local contact = self:getContact(emitter,true)
        if contact then contact:setDead() end
    end
    --- is contact is tracked
    -- @param emitter DCS Unit/UID of requested emitter
    -- @return Bool. is Unit is being tracked by current HoundWorker instance.
    function HOUND.ElintWorker:isTracked(emitter)
        if emitter == nil then return false end
        if type(emitter) =="string" and self._contacts[emitter] ~= nil then return true end
        if type(emitter) == "table" and emitter.getName ~= nil and self._contacts[emitter:getName()] ~= nil then return true end
        return false
    end

    --- add datapoint to emitter
    -- @param emitter DCS UNIT with radar
    -- @param datapoint HOUND.Datapoint instance
    function HOUND.ElintWorker:addDatapointToEmitter(emitter,datapoint)
        if not self:isTracked(emitter) then
            self:addContact(emitter)
        end
        local HoundContact = self:getContact(emitter)
        HoundContact:AddPoint(datapoint)
    end

    --- list all contact is a sector
    function HOUND.ElintWorker:listInSector(sectorName)
        local emitters = {}
        for _,emitter in ipairs(self._contacts) do
            if emitter:isInSector(sectorName) then
                table.insert(emitters,emitter)
            end
        end
        table.sort(emitters,HOUND.Utils.Sort.ContactsByRange)
        return emitters
    end

    --- update markers to all contacts
    function HOUND.ElintWorker:UpdateMarkers()
        if self._settings:getUseMarkers() then
            for _, contact in pairs(self._contacts) do
                contact:updateMarker(self._settings:getMarkerType())
            end
        end
    end

    --- Return all contacts managed by this instance regardless of sector
    function HOUND.ElintWorker:listAll(sectorName)
        if sectorName then
            local contacts = {}
            for _,emitter in pairs(self._contacts) do
                if emitter:isInSector(sectorName) then
                        table.insert(contacts,emitter)
                end
            end
            return contacts
        end
        return self._contacts
    end

    --- return all contacts managed by this instance sorted by range
    function HOUND.ElintWorker:listAllbyRange(sectorName)
        return self:sortContacts(HOUND.Utils.Sort.ContactsByRange,sectorName)
    end

    --- return number of contacts tracked
    -- @param[opt] sectorName String name or sector to filter by
    function HOUND.ElintWorker:countContacts(sectorName)
        if sectorName then
            local contacts = 0
            for _,contact in pairs(self._contacts) do
                if contact:isInSector(sectorName) then
                    contacts = contacts + 1
                end
            end
            return contacts
        end
        return Length(self._contacts)
    end

    --- return a sorted list of contacts
    -- @param sortFunc Function to sort by
    -- @param[opt] sectorName String. sector to filter by
    -- @return sorted list of contacts
    function HOUND.ElintWorker:sortContacts(sortFunc,sectorName)
        if type(sortFunc) ~= "function" then return end
        local sorted = {}
        for _,emitter in pairs(self._contacts) do
            if sectorName then
                if emitter:isInSector(sectorName) then
                    table.insert(sorted,emitter)
                end
            else
                table.insert(sorted,emitter)
            end
        end
        table.sort(sorted, sortFunc)
        return sorted
    end

    --- Perform a sample of all emitting radars against all platforms
    -- generates and stores datapoints as required
    function HOUND.ElintWorker:Sniff()
        self:removeDeadPlatforms()

        if Length(self._platforms) == 0 then
            HOUND.Logger.trace("no active platform")
            return
        end

        local Radars = HOUND.Utils.Elint.getActiveRadars(self:getCoalition())

        if Length(Radars) == 0 then
            HOUND.Logger.trace("No Transmitting Radars")
            return
        end
        -- env.info("Recivers: " .. table.getn(self.platform) .. " | Radars: " .. table.getn(Radars))
        for _,RadarName in ipairs(Radars) do
            local radar = Unit.getByName(RadarName)
            -- local RadarUid = radar:getName()
            -- local RadarType = radar:getTypeName()
            -- local RadarName = radar:getName()
            local radarPos = radar:getPosition().p
            radarPos.y = radarPos.y + radar:getDesc()["box"]["max"]["y"] -- use vehicle bounting box for height

            for _,platform in ipairs(self._platforms) do
                local platformPos = platform:getPosition().p
                -- local platformId = platform:getName()
                local platformIsStatic = false
                local isAerialUnit = false
                local posErr = {x = 0, z = 0, y = 0 }

                if platform:getCategory() == Object.Category.STATIC then
                    platformIsStatic = true
                    platformPos.y = platformPos.y + platform:getDesc()["box"]["max"]["y"]
                else
                    local PlatformUnitCategory = platform:getDesc()["category"]
                    if PlatformUnitCategory == Unit.Category.HELICOPTER or PlatformUnitCategory == Unit.Category.AIRPLANE then
                        isAerialUnit = true
                        posErr = HOUND.Utils.Vector.getRandomVec3(self._settings:getPosErr())
                    end

                    if PlatformUnitCategory == Unit.Category.GROUND_UNIT then
                        platformPos.y = platformPos.y + platform:getDesc()["box"]["max"]["y"]
                    end
                end

                if HOUND.Utils.Geo.checkLOS(platformPos, radarPos) then
                    local contact = self:getContact(radar)
                    local sampleAngularResolution = HOUND.Utils.Elint.getSensorPrecision(platform,contact.band)
                    if sampleAngularResolution < l_math.rad(10.0) then
                        local az,el = HOUND.Utils.Elint.getAzimuth( platformPos, radarPos, sampleAngularResolution )
                        if not isAerialUnit then
                            el = nil
                        else
                            for axis,value in pairs(platformPos) do
                                platformPos[axis] = value + posErr[axis]
                            end
                        end

                        local datapoint = HOUND.Datapoint.New(platform,platformPos, az, el, timer.getAbsTime(),sampleAngularResolution,platformIsStatic)
                        contact:AddPoint(datapoint)
                    end
                end
            end
        end
    end

    --- Process function
    -- process all the information stored in the system to update all radar positions
    function HOUND.ElintWorker:Process()
        if Length(self._contacts) < 1 then return end
        for contactName, contact in pairs(self._contacts) do
            if contact ~= nil then
                -- env.info("emitter " .. contact:getName() .. " has " .. contact:countDatapoints() .. " dataPoints")
                local contactState = contact:processData()

                if contactState == HOUND.EVENTS.RADAR_DETECTED then
                    if self._settings:getUseMarkers() then contact:updateMarker(self._settings:getMarkerType()) end
                end

                if contact:isTimedout() then
                    contactState = contact:CleanTimedout()
                end

                if self._settings:getBDA() and contact:getLastSeen() > 60 and not contact:isAlive() then
                    self:removeContact(contactName)
                    contact:destroy()
                    return
                end

                -- publish event (in case of destroyed radar, event is handled by the notify function)
                if contactState then
                    HOUND.EventHandler.publishEvent({
                        id = contactState,
                        initiator = contact,
                        houndId = self._settings:getId(),
                        coalition = self._settings:getCoalition()
                    })
                end
            end
        end
    end
end
