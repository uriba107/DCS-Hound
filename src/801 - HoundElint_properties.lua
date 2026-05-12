--- Hound Main interface
-- Elint system for DCS
-- @author uri_ba
-- @copyright uri_ba 2020-2021
-- @module HoundElint

do
    local HoundUtils = HOUND.Utils

    --- Platforms managment
    -- @section platforms

    --- add platform from hound instance
    -- @string platformName Unit name for platform to add
    -- @return[type=bool] True if successfuly added
    function HoundElint:addPlatform(platformName)
        return self.contacts:addPlatform(platformName)
    end

    --- Remove platform from hound instance
    -- @string platformName Unit name for platform to remove
    -- @return[type=bool] True if successfuly removed
    function HoundElint:removePlatform(platformName)
        return self.contacts:removePlatform(platformName)
    end

    --- count Platforms
    -- @return[type=int] number of assigned platforms
    function HoundElint:countPlatforms()
        return self.contacts:countPlatforms()
    end

    --- list platforms
    -- @return[type=tab] list of platfoms
    function HoundElint:listPlatforms()
        return self.contacts:listPlatforms()
    end

    --- Contact managment
    -- @section contacts

    --- count contacts
    -- @param[type=?string] sectorName String name or sector to filter by
    -- @return[type=int] number of contacts currently tracked
    function HoundElint:countContacts(sectorName)
        return self.contacts:countContacts(sectorName)
    end

    --- count Active contacts
    -- @param[type=?string] sectorName String name or sector to filter by
    -- @return[type=Int] number of contacts currently Transmitting
    function HoundElint:countActiveContacts(sectorName)
        local activeContactCount = 0
        local contacts =  self.contacts:getContacts(sectorName)
        for _,contact in pairs(contacts) do
            if contact:isActive() then
                activeContactCount = activeContactCount +1
            end
        end
        return activeContactCount
    end

    --- count preBriefed contacts
    -- @param[type=?string] sectorName String name or sector to filter by
    -- @return[type=int] number of contacts currently in PB status
    function HoundElint:countPreBriefedContacts(sectorName)
        local pbContactCount = 0
        local contacts =  self.contacts:getContacts(sectorName)
        for _,contact in pairs(contacts) do
            if contact:isAccurate() then
                pbContactCount = pbContactCount +1
                -- HOUND.Logger.trace(contact:getName() .. " Is PB")
            end
        end
        return pbContactCount
    end

    --- set/create a pre Briefed contacts
    -- @param[type=string] DCS_Object_Name name of DCS Unit or Group to add
    -- @param[opt] codeName Optional name for site created
    function HoundElint:preBriefedContact(DCS_Object_Name,codeName)
        if type(DCS_Object_Name) ~= "string" then return end
        local units = {}
        local obj = Group.getByName(DCS_Object_Name) or Unit.getByName(DCS_Object_Name)
        local grpName = DCS_Object_Name
        if not obj then
            HOUND.Logger.info("Cannot pre-brief " .. DCS_Object_Name .. ": object does not exist.")
            return
        end
        if HoundUtils.Dcs.isGroup(obj) then
            units = obj:getUnits()
        elseif HoundUtils.Dcs.isUnit(obj) then
            table.insert(units,obj)
            grpName = obj:getGroup():getName()
        end

        for _,unit in pairs(units) do
            if unit:getCoalition() ~= self.settings:getCoalition() and unit:isExist() and HOUND.setContains(HOUND.DB.Radars,unit:getTypeName()) then
                self.contacts:setPreBriefedContact(unit)
            end
        end
        if type(codeName) == "string" then
            local site = self.contacts:getSite(grpName,true)
            if site then
                site:setName(codeName)
            end
        end
    end

    --- Mark Radar as dead
    -- @param[type=string|tab] radarUnit DCS Unit, DCS Group or Unit/Group name to mark as dead
    function HoundElint:markDeadContact(radarUnit)
        local units={}
        local obj = radarUnit
        if type(radarUnit) == "string" then
            obj = Group.getByName(radarUnit) or Unit.getByName(radarUnit)
        end
        if HoundUtils.Dcs.isGroup(obj) then
            units = obj:getUnits()
            for i, unit in ipairs(units) do
                units[i] = unit:getName()
            end
        elseif HoundUtils.Dcs.isUnit(obj) then
            table.insert(units,obj:getName())
        end
        if not obj then
            if type(radarUnit) == "string" then
                table.insert(units,radarUnit)
                HOUND.Logger.debug("markDeadContact: obj nil, using string '" .. radarUnit .. "'")
            else
                HOUND.Logger.info("Cannot mark as dead: object does not exist.")
                return
            end
        end
        for _,unit in pairs(units) do
            if self.contacts:isContact(unit) then
                self.contacts:setDead(unit)
            end
        end
    end

    --- Issue a Launch Alert
    -- @param[type=string|tab] fireUnit DCS Unit, DCS Group or Unit/Group name currently Launching
    function HoundElint:AlertOnLaunch(fireUnit)
        if not self:getAlertOnLaunch() or (not HoundUtils.Dcs.isGroup(fireUnit) and not HoundUtils.Dcs.isUnit(fireUnit)) then return end
        HOUND.Logger.debug("Launch Alert called for " .. fireUnit:getName())
        self.contacts:AlertOnLaunch(fireUnit)
    end

    --- count sites
    -- @param[type=?string] sectorName name or sector to filter by
    -- @return[type=int] number of contacts currently tracked
    function HoundElint:countSites(sectorName)
        return self.contacts:countSites(sectorName)
    end

    --- Instance Setup
    -- @section HoundElint

    --- enable Markers for Hound Instance (default)
    -- @param[opt] markerType change marker type to use
    -- @return[type=Bool] True if changed
    function HoundElint:enableMarkers(markerType)
        if markerType and HOUND.setContainsValue(HOUND.MARKER,markerType) then
            self:setMarkerType(markerType)
        end
        return self.settings:setUseMarkers(true)
    end

    --- disable Markers for Hound Instance
    -- @return[type=Bool] True if changed

    function HoundElint:disableMarkers()
        return self.settings:setUseMarkers(false)
    end

    --- enable Site Markers for Hound Instance (default)
    -- @return[type=Bool] True if changed
    function HoundElint:enableSiteMarkers()
        return self.settings:setMarkSites(true)
    end

    --- disable Site Markers for Hound Instance
    -- @return[type=Bool] True if changed

    function HoundElint:disableSiteMarkers()
        return self.settings:setMarkSites(false)
    end

    --- Set marker type for Hound instance
    -- @param markerType valid marker type enum
    -- @see HOUND.MARKER
    -- @return[type=Bool] True if changed
    function HoundElint:setMarkerType(markerType)
        if markerType and HOUND.setContainsValue(HOUND.MARKER,markerType) then
            return self.settings:setMarkerType(markerType)
        end
        return false
    end

    --- set intervals
    -- @param setIntervalName interval name to change (scan,process,menu,markers)
    -- @param setValue interval in seconds to set.
    -- @return[type=Bool] True if changed
    function HoundElint:setTimerInterval(setIntervalName,setValue)
        if self.settings and HOUND.setContains(self.settings.intervals,string.lower(setIntervalName)) then
            return self.settings:setInterval(setIntervalName,setValue)
        end
        return false
    end

    --- enable platforms INS position errors
    -- @return[type=bool] if settings was updated
    function HoundElint:enablePlatformPosErrors()
        return self.settings:setPosErr(true)
    end

    --- disable platforms INS position errors
    -- @return[type=bool] if settings was updated
    function HoundElint:disablePlatformPosErrors()
        return self.settings:setPosErr(false)
    end

    --- get current callsign override table
    -- @return table current state
    function HoundElint:getCallsignOverride()
        return self.settings:getCallsignOverride()
    end

    --- set callsign override table
    -- @param overrides Table of overrides
    -- @return[type=Bool] True if setting has been updated
    function HoundElint:setCallsignOverride(overrides)
        return self.settings:setCallsignOverride(overrides)
    end

    --- get current BDA setting state
    -- @return[type=bool] current state
    function HoundElint:getBDA()
        return self.settings:getBDA()
    end

    --- enable BDA for Hound Instance
    -- Hound will notify on radar destruction
    -- @return[type=Bool] True if setting has been updated
    function HoundElint:enableBDA()
        return self.settings:setBDA(true)
    end

    --- disable BDA for Hound Instance
    -- @return[type=Bool] True if setting has been updated
    function HoundElint:disableBDA()
        return self.settings:setBDA(false)
    end

    --- Get current state of NATO brevity setting
    -- @return[type=bool] current state
    function HoundElint:getNATO()
        return self.settings:getNATO()
    end

    --- enable NATO brevity for Hound Instance
    -- @return[type=Bool] True if setting has been updated
    function HoundElint:enableNATO()
        return self.settings:setNATO(true)
    end

    --- disable NATO brevity for Hound Instance
    -- @return[type=Bool] True if setting has been updated
    function HoundElint:disableNATO()
        return self.settings:setNATO(false)
    end

    --- get Alert on launch for Hound Instance
    -- @return[type=Bool] Current state
    function HoundElint:getAlertOnLaunch()
        return self.settings:getAlertOnLaunch()
    end

    --- set Alert on Launch for Hound instance
    -- @return[type=Bool] True if setting has been updated
    function HoundElint:setAlertOnLaunch(value)
        return self.settings:setAlertOnLaunch(value)
    end

    --- set flag if callsignes for sectors under Callsignes would be from the NATO pool
    -- @return[type=Bool] True if setting has been updated
    function HoundElint:useNATOCallsigns(value)
        if type(value) ~= "boolean" then return false end
        return self.settings:setUseNATOCallsigns(value)
    end

    --- set Atis Update interval
    -- @param value desired interval in seconds
    -- @return true if change was made
    function HoundElint:setAtisUpdateInterval(value)
        return self.settings:setAtisUpdateInterval(value)
    end

    --- Set Main parent menu for hound Instace
    -- must be set <b>BEFORE</b> calling <code>enableController()</code>
    -- @param parent desired parent menu (pass nil to clear)
    -- @return[type=Bool] True if no errors
    function HoundElint:setRadioMenuParent(parent)
        local retval = self.settings:setRadioMenuParent(parent)
        if retval == true and self:isRunning() then
            self:populateRadioMenu()
        end
        return retval or false
    end
end
