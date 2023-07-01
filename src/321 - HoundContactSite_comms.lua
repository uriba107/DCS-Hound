--- HOUND.Contact.Site_comms
-- @module HOUND.Contact.Site
do
    -- local l_math = math
    local l_mist = mist
    local HoundUtils = HOUND.Utils

    --- return Information used in Text messages primary emitter
    -- @param utmZone (bool) True will add UTM zone to response
    -- @param MGRSdigits (Number) number of digits in the MGRS part of the response (eg. 2 = 12, 5=12345)
    -- @return GridPos (string) MGRS grid position (eg. "CY 564 123", "DN 2 4")
    -- Return BE (string) Bullseye position string (eg. "035/15", "187/120")
    function HOUND.Contact.Site:getTextData(utmZone,MGRSdigits)
        local primary = self:getPrimary()
        if not primary:hasPos() then return end
        return primary:getTextData(utmZone,MGRSdigits)
    end

    --- return Information used in TTS messages info will be that of primary emitter
    -- @param utmZone (bool) True will add UTM zone to response
    -- @param MGRSdigits (Number) number of digits in the MGRS part of the response (eg. 2 = 12, 5=12345)
    -- @return GridPos (string) MGRS grid position (eg. "Charlie Yankee one two   Three  four")
    -- Return BE (string) Bullseye position string (eg. "Zero Three Five 15")
    function HOUND.Contact.Site:getTtsData(utmZone,MGRSdigits)
        local primary = self:getPrimary()
        if not primary:hasPos() then return end
        return primary:getTtsData(utmZone,MGRSdigits)
    end


    --- generate Text for the Radio menu item
    -- @return string
    function HOUND.Contact.Site:getRadioItemText()
        local primary = self:getPrimary()
        if not primary:hasPos() then return end
        local GridPos,BePos = primary:getTextData(true,1)
        BePos = BePos:gsub(" for ","/")
        return self:getName() .. " - BE: " .. BePos .. " (".. GridPos ..")"
    end

    --- Generate text items for entire site
    -- @return #table all radio items for site
    function HOUND.Contact.Site:getRadioItemsText()
        local items = {
            ['dcsName'] = self:getDcsName(),
            ['txt'] = self:getRadioItemText(),
            ['typeAssigned'] = self:getTypeAssigned(),
            ['emitters'] = {}
        }
        for _,emitter in ipairs(self.emitters) do
            if emitter:hasPos() then
                local emitterEntry = {
                    ['dcsName'] = emitter:getDcsName(),
                    ['txt'] = emitter:getRadioItemText()
                }
                if emitter == self.primaryEmitter then
                    emitterEntry.txt = "(*) " .. emitterEntry.txt
                end
                table.insert(items['emitters'],emitterEntry)
            end
        end
        return items
    end

    --- generate PopUp report
    -- @param isTTS Bool. If true message will be for TTS. False will make a text message
    -- @param sectorName string Name of primary sector if present function will only return sector data
    -- @return string. compiled message
    function HOUND.Contact.Site:generatePopUpReport(isTTS,sectorName)
        local msg = self:getName() .. ", identified as " .. self:getNatoDesignation() .. ", is now Alive"

        if sectorName then
            msg = msg .. " in " .. sectorName
        else
            local primary = self:getPrimary()
            if primary:hasPos() then
                local GridPos,BePos
                if isTTS then
                    GridPos,BePos = primary:getTtsData(true,1)
                    msg = msg .. ", bullseye " .. BePos .. ", grid ".. GridPos
                else
                    GridPos,BePos = primary:getTextData(true,1)
                    msg = msg .. " BE: " .. BePos .. " (grid ".. GridPos ..")"
                end
            end
        end
        return msg .. "."
    end

    --- generate Radar dead report
    -- @param isTTS Bool. If true message will be for TTS. False will make a text message
    -- @param sectorName string Name of primary sector if present function will only return sector data
    -- @return string. compiled message
    function HOUND.Contact.Site:generateDeathReport(isTTS,sectorName)
        local msg = self:getName() ..  ", identified as " .. self:getNatoDesignation() .. " has been destroyed"
        if sectorName then
            msg = msg .. " in " .. sectorName
        else
            if self:hasPos() then
                local GridPos,BePos
                if isTTS then
                    GridPos,BePos = self:getTtsData(true,1)
                    msg = msg .. ", bullseye " .. BePos .. ", grid ".. GridPos
                else
                    GridPos,BePos = self:getTextData(true,1)
                    msg = msg .. " BE: " .. BePos .. " (grid ".. GridPos ..")"
                end
            end
        end
        return msg .. "."
    end

    --- generate Radar dead report
    -- @param isTTS Bool. If true message will be for TTS. False will make a text message
    -- @param sectorName string Name of primary sector if present function will only return sector data
    -- @return string. compiled message
    function HOUND.Contact.Site:generateAsleepReport(isTTS,sectorName)
        local msg = self:getName() ..  ", identified as " .. self:getNatoDesignation() .. " is asleep"
        if sectorName then
            msg = msg .. " in " .. sectorName
        else
            if self:hasPos() then
                local GridPos,BePos
                if isTTS then
                    GridPos,BePos = self:getTtsData(true,1)
                    msg = msg .. ", bullseye " .. BePos .. ", grid ".. GridPos
                else
                    GridPos,BePos = self:getTextData(true,1)
                    msg = msg .. " BE: " .. BePos .. " (grid ".. GridPos ..")"
                end
            end
        end
        return msg .. "."
    end

    --- generate ident report
    -- @param isTTS Bool. If true message will be for TTS. False will make a text message
    -- @param sectorName string Name of primary sector if present function will only return sector data
    -- @return string. compiled message
    function HOUND.Contact.Site:generateIdentReport(isTTS,sectorName)
        local msg = self:getName()

        if sectorName then
            msg = msg .. " in " .. sectorName
            msg = msg .. ", has been reclassified as " .. self:getNatoDesignation()
        else
            msg = msg .. ", has been reclassified as " .. self:getNatoDesignation()
            local primary = self:getPrimary()
            if primary:hasPos() then
                local GridPos,BePos
                if isTTS then
                    GridPos,BePos = primary:getTtsData(true,1)
                    msg = msg .. ", bullseye " .. BePos .. ", grid ".. GridPos
                else
                    GridPos,BePos = primary:getTextData(true,1)
                    msg = msg .. " BE: " .. BePos .. " (grid ".. GridPos ..")"
                end
            end
        end
        return msg .. "."
    end

    --- Generate TTS brief for the Site (for ATIS)
    -- @param NATO (bool) True will generate NATO Brevity brief
    -- @return string containing

    function HOUND.Contact.Site:generateTtsBrief(NATO)
        local primary = self:getPrimary()
        if getmetatable(primary) ~= HOUND.Contact.Emitter or primary.pos.p == nil or primary.uncertenty_data == nil then return end
        local phoneticGridPos,phoneticBulls = primary:getTtsData(false,1)
        local reportedName = self:getName()
        if NATO then
            reportedName = ""
        end
        local str = reportedName .. " " .. self:getNatoDesignation()
        if primary:isAccurate() then
            str = str .. ", reported"
        else
            str = str .. ", " .. HoundUtils.TTS.getVerbalContactAge(self.last_seen,true,NATO)
        end
        if NATO then
            str = str .. " bullseye " .. phoneticBulls
        else
            str = str .. " at " .. phoneticGridPos
        end
        if not primary:isAccurate() then
            str = str .. ", accuracy " .. HoundUtils.TTS.getVerbalConfidenceLevel( primary.uncertenty_data.r )
        end
        str = str .. "."
        return str
    end

    --- Generate Intel brief Message (for export)
    -- @return string - compiled multi-line message for site
    function HOUND.Contact.Site:generateIntelBrief()
        -- SiteId,SiteType,(TrackId,RadarType,State,Bullseye,Latitude,Longitude,MGRS,Accuracy,DCS type,DCS Unit),DCS Group
        if #self.emitters == 0 then return end
        local items = {}

        for _,emitter in ipairs(self.emitters) do
            local body = emitter:generateIntelBrief()
            if body ~= "" then
                local entry = table.concat({self:getName(),self:getNatoDesignation(),body,self.DCSobjectName},",")
                table.insert(items,entry)
            end
        end
        return items
    end

    --- Generate contact export object
    -- @return exported object
    function HOUND.Contact.Site:export()
        local report = {
            name = self:getName(),
            DCSobjectName = self:getDcsName(),
            gid = self.gid % 100,
            Type = self:getNatoDesignation(),
            last_seen = self.last_seen,
            emitters = {}
        }
        if #self.emitters == 0 then return report end
        for _,emitter in ipairs(self.emitters) do
            table.insert(report.emitters,emitter:export())
        end
        return l_mist.utils.deepCopy(report)
    end
end