--- HOUND.Contact.Site_comms
-- @module HOUND.Contact.Site
do
    -- local l_math = math
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
            local emitterEntry = {
                ['dcsName'] = emitter:getDcsName(),
                ['txt'] = emitter:getRadioItemText()
            }
            if emitter == self.primaryEmitter then
                emitterEntry.txt = "(*) " .. emitterEntry.txt
            end
            table.insert(items['emitters'],emitterEntry)
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
            reportedName = self:getNatoDesignation()
        end
        local str = reportedName
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
end