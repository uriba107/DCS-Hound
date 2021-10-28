    --- HoundElintWorker
    -- @module HoundElintWorker
do
    HoundElintWorker = {}
    HoundElintWorker.__index = HoundElintWorker

    local l_math = math
    function HoundElintWorker.create(HoundInstanceId)
        local instance = {}
        instance._contacts = {}
        instance._platforms = {}
        instance._settings =  HoundConfig.get(HoundInstanceId)
        instance.coalitionId = nil
        setmetatable(instance, HoundElintWorker)
        return instance
    end

    --- set coalition
    -- retundent function will change global coalition
    function HoundElintWorker:setCoalition(coalitionId)
        if not coalitionId then return false end
        if not self._settings:getCoalition() then
            self._settings:setCoalition(coalitionId)
            return true
        end
        return false
    end

    --- get worker coalition
    -- @return coalitionId
    function HoundElintWorker:getCoalition()
        return self._settings:getCoalition()
    end

    --- add platform
    -- @string platformName DCS Unit Name of platform to be added
    -- @return Bool. True if requested platform was added. else false
    function HoundElintWorker:addPlatform(platformName)
        local candidate = Unit.getByName(platformName)
        if candidate == nil then
            candidate = StaticObject.getByName(platformName)
        end

        if self:getCoalition() == nil and candidate ~= nil then
            self:setCoalition(candidate:getCoalition())
        end

        if candidate ~= nil and candidate:getCoalition() == self:getCoalition() then
            local mainCategory = candidate:getCategory()
            local type = candidate:getTypeName()

            if setContains(HoundDB.Platform,mainCategory) then
                if setContains(HoundDB.Platform[mainCategory],type) then
                    for _,v in pairs(self._platforms) do
                        if v == candidate then
                            return
                        end
                    end
                    table.insert(self._platforms, candidate)
                    HoundEventHandler.publishEvent({
                        id = HOUND.EVENTS.PLATFORM_ADDED,
                        initiator = candidate,
                        houndId = self._settings:getId(),
                        coalition = self._settings:getCoalition()
                    })
                    return true
                end
            end
        end
        HoundLogger.warn("[Hound] - Failed to add platform "..platformName..". Make sure you use unit name.")
        return false
    end

    --- remove specificd platform
    -- @param platformName DCS Unit name to remove
    -- @return Bool. true if removed, else false
    function HoundElintWorker:removePlatform(platformName)
        local candidate = Unit.getByName(platformName)
        if candidate == nil then
            candidate = StaticObject.getByName(platformName)
        end

        if candidate ~= nil then
            for k,v in ipairs(self._platforms) do
                if v == candidate then
                    table.remove(self._platforms, k)
                    HoundEventHandler.publishEvent({
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
    function HoundElintWorker:platformRefresh()
        if Length(self._platforms) < 1 then return end
        for id,platform in ipairs(self._platforms) do
            if platform:isExist() == false or platform:getLife() <1 then
                table.remove(self._platforms, id)
                HoundEventHandler.publishEvent({
                    id = HOUND.EVENTS.PLATFORM_DESTROYED,
                    initiator = platform,
                    houndId = self._settings:getId(),
                    coalition = self._settings:getCoalition()
                })
            end
        end
    end

    --- remove dead platforms
    function HoundElintWorker:removeDeadPlatforms()
        if Length(self._platforms) < 1 then return end
        for id,platform in ipairs(self._platforms) do
            if platform:isExist() == false or platform:getLife() <1  or (platform:getCategory() ~= Object.Category.STATIC and platform:isActive() == false) then
                table.remove(self._platforms, id)
                HoundEventHandler.publishEvent({
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
    function HoundElintWorker:countPlatforms()
        return Length(self._platforms)
    end

    --- list all associated platform unit names
    -- @return Table list of active platform names
    function HoundElintWorker:listPlatforms()
        local platforms = {}
        for _,platform in ipairs(self._platforms) do
            table.insert(platforms,platform:getName())
        end
        return platforms
    end

    --- add contact to worker
    -- @param emitter DCS Unit to add
    -- @return UID of added unit
    function HoundElintWorker:addContact(emitter)
        if emitter == nil or emitter.getID == nil then return end
        local uid = emitter:getID()
        if self._contacts[uid] ~= nil then return uid end
        self._contacts[uid] = HoundContact.New(emitter, self:getCoalition())
        HoundEventHandler.publishEvent({
            id = HOUND.EVENTS.RADAR_NEW,
            initiator = emitter,
            houndId = self._settings:getId(),
            coalition = self._settings:getCoalition()
        })
        return uid
    end

    --- get HoundContact from DCS Unit/UID
    -- @param emitter DCS Unit/UID of radar
    -- @return HoundContact instance of that Unit
    function HoundElintWorker:getContact(emitter)
        if emitter == nil then return nil end
        local uid = nil
        if type(emitter) =="number" then
            uid = emitter
        end
        if type(emitter) == "table" and emitter.getID ~= nil then
            uid = emitter:getID()
        end

        if uid ~= nil and self._contacts[uid] ~= nil then return self._contacts[uid] end
        if not self._contacts[uid] and type(emitter) == "table" then
            self:addContact(emitter)
            return self._contacts[uid]
        end
        return nil
    end

    --- remove Contact from tracking
    -- @int uid DCS unit ID (UID) to remove
    -- @return Bool. true if removed.
    function HoundElintWorker:removeContact(uid)
        if not uid then return false end
        HoundEventHandler.publishEvent({
            id = HOUND.EVENTS.RADAR_DESTROYED,
            initiator = self._contacts[uid],
            houndId = self._settings:getId(),
            coalition = self._settings:getCoalition()
        })

        self._contacts[uid] = nil
        return true
    end

    --- is contact is tracked
    -- @param emitter DCS Unit/UID of requested emitter
    -- @return Bool. is Unit is being tracked by current HoundWorker instance.
    function HoundElintWorker:isTracked(emitter)
        if emitter == nil then return false end
        if type(emitter) =="number" and self._contacts[emitter] ~= nil then return true end
        if type(emitter) == "table" and emitter.getID ~= nil and self._contacts[emitter:getID()] ~= nil then return true end
        return false
    end

    --- add datapoint to emitter
    -- @param emitter DCS UNIT with radar
    -- @param datapoint HoundDatapoint instance
    function HoundElintWorker:addDatapointToEmitter(emitter,datapoint)
        if not self:isTracked(emitter) then
            self:addContact(emitter)
        end
        local HoundContact = self:getContact(emitter)
        HoundContact:AddPoint(datapoint)
    end

    --- list all contact is a sector
    function HoundElintWorker:listInSector(sectorName)
        local emitters = {}
        for _,emitter in ipairs(self._contacts) do
            if emitter:isInSector(sectorName) then
                table.insert(emitters,emitter)
            end
        end
        table.sort(emitters,HoundUtils.Sort.ContactsByRange)
        return emitters
    end

    --- update markers to all contacts
    function HoundElintWorker:UpdateMarkers()
        if self._settings:getUseMarkers() then
            for _, contact in pairs(self._contacts) do
                contact:updateMarker(self._settings:getMarkerType())
                -- if HOUND.DEBUG then
                --     contact:processDataWIP()
                -- end
            end
        end
    end

    --- Return all contacts managed by this instance regardless of sector
    function HoundElintWorker:listAll(sectorName)
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
    function HoundElintWorker:listAllbyRange(sectorName)
        return self:sortContacts(HoundUtils.Sort.ContactsByRange,sectorName)
    end

    --- return number of contacts tracked
    -- @param[opt] sectorName String name or sector to filter by
    function HoundElintWorker:countContacts(sectorName)
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
    function HoundElintWorker:sortContacts(sortFunc,sectorName)
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
    function HoundElintWorker:Sniff()
        self:removeDeadPlatforms()

        if Length(self._platforms) == 0 then
            HoundLogger.trace("no active platform")
            return
        end

        local Radars = HoundUtils.Elint.getActiveRadars(self:getCoalition())

        if Length(Radars) == 0 then
            HoundLogger.trace("No Transmitting Radars")
            return
        end
        -- env.info("Recivers: " .. table.getn(self.platform) .. " | Radars: " .. table.getn(Radars))
        for _,RadarName in ipairs(Radars) do
            local radar = Unit.getByName(RadarName)
            -- local RadarUid = radar:getID()
            -- local RadarType = radar:getTypeName()
            -- local RadarName = radar:getName()
            local radarPos = radar:getPosition().p
            radarPos.y = radarPos.y + radar:getDesc()["box"]["max"]["y"] -- use vehicle bounting box for height

            for _,platform in ipairs(self._platforms) do
                local platformPos = platform:getPosition().p
                -- local platformId = platform:getID()
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
                        posErr = HoundUtils.Vector.getRandomVec3(self._settings:getPosErr())
                    end

                    if PlatformUnitCategory == Unit.Category.GROUND_UNIT then
                        platformPos.y = platformPos.y + platform:getDesc()["box"]["max"]["y"]
                    end
                end

                if HoundUtils.checkLOS(platformPos, radarPos) then
                    local contact = self:getContact(radar)
                    local sampleAngularResolution = HoundUtils.Elint.getSensorPrecision(platform,contact.band)
                    if sampleAngularResolution < l_math.rad(15.0) then
                        local az,el = HoundUtils.Elint.getAzimuth( platformPos, radarPos, sampleAngularResolution )
                        if not isAerialUnit then
                            el = nil
                        else
                            for axis,value in pairs(platformPos) do
                                platformPos[axis] = value + posErr[axis]
                            end
                        end

                        local datapoint = HoundDatapoint.New(platform,platformPos, az, el, timer.getAbsTime(),sampleAngularResolution,platformIsStatic)
                        contact:AddPoint(datapoint)
                    end
                end
            end
        end
    end

    --- Process function
    -- process all the information stored in the system to update all radar positions
    function HoundElintWorker:Process()
        -- local currentTime = timer.getTime() + 0.2
        -- if self.controller.msgTimer < currentTime then
        --     self.controller.msgTimer = currentTime
        -- end
        if Length(self._contacts) < 1 then return end
        for uid, contact in pairs(self._contacts) do
            if contact ~= nil then
                -- env.info("emitter " .. emitter:getName() .. " has " .. emitter:countDatapoints() .. " dataPoints")
                local contactState = contact:processData()
                -- if HOUND.DEBUG then
                --     contact:processDataWIP()
                -- end
                if contactState == HOUND.EVENTS.RADAR_DETECTED then
                    if self._settings:getUseMarkers() then contact:updateMarker(self._settings:getMarkerType()) end
                end
                if contact:isTimedout() then
                    contact:CleanTimedout()
                    contactState = HOUND.EVENTS.RADAR_ASLEEP
                end
                if self._settings:getBDA() and contact:isAlive() == false and HoundUtils.absTimeDelta(contact.last_seen, timer.getAbsTime()) > 60 then
                    contact:destroy()
                    self:removeContact(uid)

                -- this can be deleted or at leased wrapped in config option. remove timed out contacts
                -- else
                --     if HoundUtils.absTimeDelta(contact.last_seen,
                --                             timer.getAbsTime()) > 1800 then
                --         self:removeRadarRadioItem(contact)
                --         contact:removeMarker()
                --         self._contacts[uid] = nil
                --     end
                else
                    -- publish event (in case of destroyed radar, event is handled by the notify function)
                    HoundEventHandler.publishEvent({
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
