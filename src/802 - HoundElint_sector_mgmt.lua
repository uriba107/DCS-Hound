--- Hound Main interface
-- Elint system for DCS
-- @author uri_ba
-- @copyright uri_ba 2020-2021
-- @module HoundElint

do
    local HoundUtils = HOUND.Utils

    --- Sector managment
    -- @section sectors

    --- Add named sector
    -- @param[type=string] sectorName name of sector to add
    -- @param[opt] sectorSettings table of sector settings
    -- @param[opt] priority Sector priority (lower is higher)
    -- @return[type=bool] True if sector successfully added
    function HoundElint:addSector(sectorName,sectorSettings,priority)
        if type(sectorName) ~= "string" then return false end
        if string.lower(sectorName) == "default" or string.lower(sectorName) == "all" then
            HOUND.Logger.info(sectorName.. " is a reserved sector name")
            return false
        end
        if type(sectorSettings) == "number" and priority == nil then
            priority = sectorSettings
            sectorSettings = nil
        end
        priority = priority or 50
        if not self.sectors[sectorName] then
            self.sectors[sectorName] = HOUND.Sector.create(self.settings:getId(),sectorName,sectorSettings,priority)
            if self.settings:getOnScreenDebug() then
                HOUND.Logger.onScreenDebug("Sector " .. sectorName  .. " was added to Hound instance ".. self:getId(),10)
            end
            return self.sectors[sectorName]
        end

        return false
    end

    --- Remove Named sector
    -- @param[type=string] sectorName name of sector to add
    -- @return[type=bool] True if sector successfully removed
    function HoundElint:removeSector(sectorName)
        if sectorName == nil or not self.sectors[sectorName] then return false end
        self.sectors[sectorName] = self.sectors[sectorName]:destroy()
        if self.settings:getOnScreenDebug() then
            HOUND.Logger.onScreenDebug("Sector " .. sectorName .. " was removed from Hound instance ".. self:getId(),10)
        end
        return true
    end

    --- Update named sector settings
    -- @param[type=string|nil] sectorName name of sector (nil == "default")
    -- @tab sectorSettings sector settings
    -- @param[type=?string] subSettingName update specific setting ("controller", "atis", "notifier")
    -- @return[type=bool] False if an error occurred, true otherwise
    function HoundElint:updateSectorSettings(sectorName,sectorSettings,subSettingName)
        if sectorName == nil then sectorName = "default" end
        if not self.sectors[sectorName] then
            env.warn("No sector named ".. sectorName .." was found.")
            return false
        end
        if sectorSettings == nil or type(sectorSettings) ~= "table" then return false end
        local sector = self.sectors[sectorName]
        if subSettingName ~= nil and type(subSettingName) == "string" then
            local subSetting = string.lower(subSettingName)
            if subSetting == "controller" or subSetting == "atis" or subSetting == "notifier" then
                local generatedSettings = {}
                generatedSettings[subSetting] = sectorSettings
                sector:updateSettings(generatedSettings)
                return true
            end
        end
        sector:updateSettings(sectorSettings)
        return true
    end

    --- list all sectors
    -- @param[type=?string] element list only sectors with specified element. Valid options are "controller", "atis", "notifier" and "zone"
    -- @return list of sector names
    function HoundElint:listSectors(element)
        local sectors = {}
        for name,sector in pairs(self.sectors) do
            local addToList = true
            if element then
                if string.lower(element) == "controller" then
                    addToList=sector:hasController()
                end
                if string.lower(element) == "atis" then
                    addToList=sector:hasAtis()
                end
                if string.lower(element) == "notifier" then
                    addToList=sector:hasNotifier()
                end
                if string.lower(element) == "zone" then
                    addToList=sector:hasZone()
                end
            end

            if addToList then
                table.insert(sectors,name)
            end
        end
        return sectors
    end

    --- get all sectors
    -- @param[type=?string] element list only sectors with specified element. Valid options are "controller", "atis", "notifier" and "zone"
    -- @return list of HOUND.Sector instances
    function HoundElint:getSectors(element)
        local sectors = {}
        for _,sector in pairs(self.sectors) do
            local addToList = true
            if element then
                if string.lower(element) == "controller" then
                    addToList=sector:hasController()
                end
                if string.lower(element) == "atis" then
                    addToList=sector:hasAtis()
                end
                if string.lower(element) == "notifier" then
                    addToList=sector:hasNotifier()
                end
                if string.lower(element) == "zone" then
                    addToList=sector:hasZone()
                end
            end

            if addToList then
                table.insert(sectors,sector)
            end
        end
        return sectors
    end

    --- return number of sectors
    -- @param[type=?string] element count only sectors with specified element ("controller"/"atis"/"notifier"/"zone")
    -- @return[type=int]. number of sectors
    function HoundElint:countSectors(element)
        return HOUND.Length(self:listSectors(element))
    end

    --- return HOUND.Sector instance
    -- @string sectorName Name of wanted sector
    -- @return HOUND.Sector
    function HoundElint:getSector(sectorName)
        if HOUND.setContains(self.sectors,sectorName) then
            return self.sectors[sectorName]
        end
    end

    --- enable Text notification for controller
    -- @param[type=?string] sectorName name of sector to enable (default is "default", "all" will enable on all sectors)
    function HoundElint:enableText(sectorName)
        if sectorName == nil or type(sectorName) ~= "string" then
            sectorName = "default"
        end
        if self.sectors[sectorName] then
            self.sectors[sectorName]:enableText()
            return
        end
        if string.lower(sectorName) == "all" then
            for _,sector in pairs(self.sectors) do
                sector:enableText()
            end
        end

    end

    --- disable Text notification for controller
    -- @param[type=?string] sectorName name of sector to disable (default is "default", "all" will enable on all sectors)
    function HoundElint:disableText(sectorName)
        if sectorName == nil or type(sectorName) ~= "string" then
            sectorName = "default"
        end
        if self.sectors[sectorName] then
            self.sectors[sectorName]:disableText()
            return
        end
        if string.lower(sectorName) == "all" then
            for _,sector in pairs(self.sectors) do
                sector:disableText()
            end
        end
    end

    --- enable Text-To-Speach notification for controller
    -- @param[type=?string] sectorName name of sector to enable (default is "default", "all" will enable on all sectors)
    function HoundElint:enableTTS(sectorName)
        if sectorName == nil or type(sectorName) ~= "string" then
            sectorName = "default"
        end
        if self.sectors[sectorName] then
            self.sectors[sectorName]:enableTTS()
            return
        end
        if string.lower(sectorName) == "all" then
            for _,sector in pairs(self.sectors) do
                sector:enableTTS()
            end
        end
    end

    --- disable Text-to-speach notification for controller
    -- @param[type=?string] sectorName name of sector to disable (default is "default", "all" will enable on all sectors)
    function HoundElint:disableTTS(sectorName)
        if sectorName == nil or type(sectorName) ~= "string" then
            sectorName = "default"
        end
        if self.sectors[sectorName] then
            self.sectors[sectorName]:disableTTS()
            return
        end
        if string.lower(sectorName) == "all" then
            for _,sector in pairs(self.sectors) do
                sector:disableTTS()
            end
        end
    end

    --- enable Alert notification for controller
    -- @param[type=?string] sectorName name of sector to enable (default is "default", "all" will enable on all sectors)
    function HoundElint:enableAlerts(sectorName)
        if sectorName == nil or type(sectorName) ~= "string" then
            sectorName = "default"
        end
        if self.sectors[sectorName] then
            self.sectors[sectorName]:enableAlerts()
            return
        end
        if string.lower(sectorName) == "all" then
            for _,sector in pairs(self.sectors) do
                sector:enableAlerts()
            end
        end

    end

    --- disable Alert notification for controller
    -- @param[type=?string] sectorName name of sector to disable (default is "default", "all" will enable on all sectors)
    function HoundElint:disableAlerts(sectorName)
        if sectorName == nil or type(sectorName) ~= "string" then
            sectorName = "default"
        end
        if self.sectors[sectorName] then
            self.sectors[sectorName]:disableAlerts()
            return
        end
        if string.lower(sectorName) == "all" then
            for _,sector in pairs(self.sectors) do
                sector:disableAlerts()
            end
        end
    end

    --- Set sector callsign
    -- @string sectorName sector to change
    -- @string sectorCallsign callsign for sector. if not provided, a random one will be selected from pool. "NATO" will draw from the NATO pool
    -- @return[type=bool] True if callsign was changes. False otherwise
    function HoundElint:setCallsign(sectorName,sectorCallsign)
        if not sectorName then return false end
        local NATO = self.settings:getUseNATOCallsigns()
        if sectorCallsign == "NATO" then
            sectorCallsign = true
        end
        if type(sectorCallsign) == "boolean" then
            NATO = sectorCallsign
            sectorCallsign = nil
        end
        if self.sectors[sectorName] then
            self.sectors[sectorName]:setCallsign(sectorCallsign,NATO)
            return true
        end
        return false
    end

    --- get sector callsign
    -- @string sectorName sector to change
    -- @return String - callsign for sector. will return empty string if err
    function HoundElint:getCallsign(sectorName)
        if not sectorName then return "" end
        if self.sectors[sectorName] then
            return self.sectors[sectorName]:getCallsign()
        end
        return ""
    end

    --- set transmitter to named sector
    -- @param[type=string] sectorName name of sector to apply to.
    --- valid values are name of sector, "all" or nil (will change default)
    -- @param transmitter DCS unit name which will be the transmitter
    function HoundElint:setTransmitter(sectorName,transmitter)
        if not sectorName and not transmitter then return end
        if sectorName and not transmitter then
            transmitter = sectorName
            sectorName = "default"
        end
        if sectorName == nil then sectorName = "default" end
        if string.lower(sectorName) == "all" then
            for _,sector in pairs(self.sectors) do
                sector:setTransmitter(transmitter)
            end
        end
        if self.sectors[sectorName] then
            self.sectors[sectorName]:setTransmitter(transmitter)
        end
    end

    --- remove transmitter to named sector
    -- @param[type=string] sectorName name of sector to apply to.
    --- valid values are name of sector, "all" or nil (will change default)
    function HoundElint:removeTransmitter(sectorName)
        if sectorName == nil then sectorName = "default" end
        if string.lower(sectorName) == "all" then
            for _,sector in pairs(self.sectors) do
                sector:removeTransmitter()
            end
        end
        if self.sectors[sectorName] then
            self.sectors[sectorName]:removeTransmitter()
        end
    end

    --- get zone of sector
    -- @param[type=string] sectorName to act on
    -- @return table of points or nil if no sector set
    function HoundElint:getZone(sectorName)
        sectorName = sectorName or "default"
        if self.sectors[sectorName] then
            return self.sectors[sectorName]:getZone()
        end
    end

    --- add zone to sector
    -- @param[type=string] sectorName to act on
    -- @param zoneCandidate DCS Group name. Group's waypoints will be used.
    -- same as MOOSE. use late activation invisible helicopter group is recommended.
    function HoundElint:setZone(sectorName,zoneCandidate)
        if type(sectorName) ~= "string" then return end
        if type(zoneCandidate) ~= "string" and zoneCandidate ~= nil then return end
        if self.sectors[sectorName] then
            self.sectors[sectorName]:setZone(zoneCandidate)
        end
        self:updateSectorMembership()
    end

    --- remove zone from sector
    -- @param[type=string] sectorName to act on
    function HoundElint:removeZone(sectorName)
        if self.sectors[sectorName] then
            self.sectors[sectorName]:removeZone()
        end
        self:updateSectorMembership()
    end

    --- add a child sector to a meta-sector
    -- @param[type=string] metaSectorName name of the meta-sector
    -- @param[type=string] childSectorName name of the child sector to add
    function HoundElint:addChildSector(metaSectorName, childSectorName)
        if self.sectors[metaSectorName] then
            self.sectors[metaSectorName]:addChildSector(childSectorName)
        end
    end

    --- remove a child sector from a meta-sector
    -- @param[type=string] metaSectorName name of the meta-sector
    -- @param[type=string] childSectorName name of the child sector to remove
    function HoundElint:removeChildSector(metaSectorName, childSectorName)
        if self.sectors[metaSectorName] then
            self.sectors[metaSectorName]:removeChildSector(childSectorName)
        end
    end

    --- update sector membership for all contacts
    -- @local
    function HoundElint:updateSectorMembership()
        local guardName = "sector-membership-" .. self:getId()
        if HOUND.Coroutine.isRunning(guardName) then return end
        local self_ = self
        HOUND.Coroutine.add(function()
            local sectors = self_:getSectors()
            table.sort(sectors, HoundUtils.Sort.sectorsByPriorityLowFirst)
            for _, sector in pairs(sectors) do
                for _, contact in ipairs(self_.contacts:listAllContacts()) do
                    sector:updateSectorMembership(contact)
                end
                coroutine.yield()
            end
            for _, site in ipairs(self_.contacts:listAllSites()) do
                site:updateSector()
            end
        end, { name = guardName })
    end
end
