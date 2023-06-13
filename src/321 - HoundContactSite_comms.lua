--- HOUND.Contact.Site_comms
-- @module HOUND.Contact.Site
do
    -- local l_math = math

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
    function HOUND.Contact.Site:generateRadioItemText()
        local primary = self:getPrimary()
        if not primary:hasPos() then return end
        local GridPos,BePos = primary:getTextData(true,1)
        BePos = BePos:gsub(" for ","/")
        return self:getName() .. " - BE: " .. BePos .. " (".. GridPos ..")"
    end
end