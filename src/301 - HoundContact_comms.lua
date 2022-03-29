--- HOUND.Contact_comms
-- @module HOUND.Contact
do
    local l_math = math

    --- return Information used in Text messages
    -- @param utmZone (bool) True will add UTM zone to response
    -- @param MGRSdigits (Number) number of digits in the MGRS part of the response (eg. 2 = 12, 5=12345)
    -- @return GridPos (string) MGRS grid position (eg. "CY 564 123", "DN 2 4")
    -- Return BE (string) Bullseye position string (eg. "035/15", "187/120")
    function HOUND.Contact:getTextData(utmZone,MGRSdigits)
        if self.pos.p == nil then return end
        local GridPos = ""
        if utmZone then
            GridPos = GridPos .. self.pos.grid.UTMZone .. " "
        end
        GridPos = GridPos .. self.pos.grid.MGRSDigraph
        local BE = self.pos.be.brStr .. "/" .. self.pos.be.rng
        if MGRSdigits == nil then
            return GridPos,BE
        end
        local E = l_math.floor(self.pos.grid.Easting/(10^l_math.min(5,l_math.max(1,5-MGRSdigits))))
        local N = l_math.floor(self.pos.grid.Northing/(10^l_math.min(5,l_math.max(1,5-MGRSdigits))))
        GridPos = GridPos .. " " .. E .. " " .. N

        return GridPos,BE
    end

    --- return Information used in TTS messages
    -- @param utmZone (bool) True will add UTM zone to response
    -- @param MGRSdigits (Number) number of digits in the MGRS part of the response (eg. 2 = 12, 5=12345)
    -- @return GridPos (string) MGRS grid position (eg. "Charlie Yankee one two   Three  four")
    -- Return BE (string) Bullseye position string (eg. "Zero Three Five 15")
    function HOUND.Contact:getTtsData(utmZone,MGRSdigits)
        if self.pos.p == nil then return end
        local phoneticGridPos = ""
        if utmZone then
            phoneticGridPos =  phoneticGridPos .. HOUND.Utils.TTS.toPhonetic(self.pos.grid.UTMZone) .. " "
        end

        phoneticGridPos =  phoneticGridPos ..  HOUND.Utils.TTS.toPhonetic(self.pos.grid.MGRSDigraph)
        local phoneticBulls = HOUND.Utils.TTS.toPhonetic(self.pos.be.brStr)
                                .. "  " .. self.pos.be.rng
        if MGRSdigits==nil then
            return phoneticGridPos,phoneticBulls
        end
        local E = l_math.floor(self.pos.grid.Easting/(10^l_math.min(5,l_math.max(1,5-MGRSdigits))))
        local N = l_math.floor(self.pos.grid.Northing/(10^l_math.min(5,l_math.max(1,5-MGRSdigits))))
        phoneticGridPos = phoneticGridPos .. " " .. HOUND.Utils.TTS.toPhonetic(E) .. "   " .. HOUND.Utils.TTS.toPhonetic(N)

        return phoneticGridPos,phoneticBulls
    end

    --- Generate TTS brief for the contact (for ATIS)
    -- @param NATO (bool) True will generate NATO Brevity brief
    -- @return string containing

    function HOUND.Contact:generateTtsBrief(NATO)
        if self.pos.p == nil or self.uncertenty_data == nil then return end
        local phoneticGridPos,phoneticBulls = self:getTtsData(false,1)
        local reportedName = self:getName()
        if NATO then
            reportedName = self:getNatoDesignation()
        end
        local str = reportedName .. ", " .. HOUND.Utils.TTS.getVerbalContactAge(self.last_seen,true,NATO)
        if NATO then
            str = str .. " bullseye " .. phoneticBulls
        else
            str = str .. " at " .. phoneticGridPos -- .. ", bullseye " .. phoneticBulls
        end
        str = str .. ", accuracy " .. HOUND.Utils.TTS.getVerbalConfidenceLevel( self.uncertenty_data.r ) .. "."
        return str
    end

    --- Generate TTS report for the contact (for controller)
    -- @param[opt] useDMM if true. output will be DM.M rather then the default DMS
    -- @param[opt] refPos position of reference point for BR (Not Currently Used)
    -- @return generated message
    function HOUND.Contact:generateTtsReport(useDMM,refPos)
        if self.pos.p == nil then return end
        useDMM = useDMM or false

        local BR = nil
        if refPos ~= nil and refPos.x ~= nil and refPos.z ~= nil then
            BR = HOUND.Utils.getBR(self.pos.p,refPos)
        end
        local phoneticGridPos,phoneticBulls = self:getTtsData(true,HOUND.MGRS_PRECISION)
        local msg =  self:getName() .. ", " .. HOUND.Utils.TTS.getVerbalContactAge(self.last_seen,true)
        if BR ~= nil
            then
                msg = msg .. " from you " .. HOUND.Utils.TTS.toPhonetic(BR.brStr) .. " for " .. BR.rng
            else
                msg = msg .." at bullseye " .. phoneticBulls
        end
        local LLstr = HOUND.Utils.TTS.getVerbalLL(self.pos.LL.lat,self.pos.LL.lon,useDMM)
        msg = msg .. ", accuracy " .. HOUND.Utils.TTS.getVerbalConfidenceLevel( self.uncertenty_data.r )
        msg = msg .. ", position " .. LLstr
        msg = msg .. ", I say again " .. LLstr
        msg = msg .. ", MGRS " .. phoneticGridPos
        msg = msg .. ", elevation  " .. HOUND.Utils.getRoundedElevationFt(self.pos.elev) .. " feet MSL"

        if HOUND.EXTENDED_INFO then
            msg = msg .. ", ellipse " ..  HOUND.Utils.TTS.simplfyDistance(self.uncertenty_data.major) .. " by " ..  HOUND.Utils.TTS.simplfyDistance(self.uncertenty_data.minor) .. ", aligned bearing " .. HOUND.Utils.TTS.toPhonetic(string.format("%03d",self.uncertenty_data.az))
            msg = msg .. ", Tracked for " .. HOUND.Utils.TTS.getVerbalContactAge(self.first_seen) .. ", last seen " .. HOUND.Utils.TTS.getVerbalContactAge(self.last_seen) .. " ago"
        end
        msg = msg .. ". " .. HOUND.Utils.getControllerResponse()
        return msg
    end

    --- Generate Text report for the contact (for controller)
    -- @param[opt] useDMM if true. output will be DM.M rather then the default DMS
    -- @param[opt] refPos position of reference point for BR
    -- @return generated message
    function HOUND.Contact:generateTextReport(useDMM,refPos)
        if self.pos.p == nil then return end
        useDMM = useDMM or false

        local GridPos,BePos = self:getTextData(true,HOUND.MGRS_PRECISION)
        local BR = nil
        if refPos ~= nil and refPos.x ~= nil and refPos.z ~= nil then
            BR = HOUND.Utils.getBR(self.pos.p,refPos)
        end
        local msg =  self:getName() .." (" .. HOUND.Utils.TTS.getVerbalContactAge(self.last_seen,true).. ")\n"
        msg = msg .. "Accuracy: " .. HOUND.Utils.TTS.getVerbalConfidenceLevel( self.uncertenty_data.r ) .. "\n"
        msg = msg .. "BE: " .. BePos .. "\n" -- .. " (grid ".. GridPos ..")\n"
        if BR ~= nil then
            msg = msg .. "BR: " .. BR.brStr .. " for " .. BR.rng
        end
        msg = msg .. "LL: " .. HOUND.Utils.Text.getLL(self.pos.LL.lat,self.pos.LL.lon,useDMM).."\n"
        msg = msg .. "MGRS: " .. GridPos .. "\n"
        msg = msg .. "Elev: " .. HOUND.Utils.getRoundedElevationFt(self.pos.elev) .. "ft"
        if HOUND.EXTENDED_INFO then
            msg = msg .. "\nEllipse: " ..  self.uncertenty_data.major .. " by " ..  self.uncertenty_data.minor .. " aligned bearing " .. string.format("%03d",self.uncertenty_data.az) .. "\n"
            msg = msg .. "Tracked for: " .. HOUND.Utils.TTS.getVerbalContactAge(self.first_seen) .. " Last Contact: " ..  HOUND.Utils.TTS.getVerbalContactAge(self.last_seen) .. " ago. "
        end
        return msg
    end

    --- generate Text for the Radio menu item
    -- @return string
    function HOUND.Contact:generateRadioItemText()
        if not self:hasPos() then return end
        local GridPos,BePos = self:getTextData(true,1)
        BePos = BePos:gsub(" for ","/")
        return self:getName() .. " - BE: " .. BePos .. " (".. GridPos ..")"
    end

    --- generate PopUp report
    -- @param isTTS Bool. If true message will be for TTS. False will make a text message
    -- @param sectorName string Name of primary sector if present function will only return sector data
    -- @return string. compiled message
    function HOUND.Contact:generatePopUpReport(isTTS,sectorName)
        local msg = self:getName() .. " is now Alive"

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
    function HOUND.Contact:generateDeathReport(isTTS,sectorName)
        local msg = self:getName() .. " has been destroyed"
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

    --- Generate Intel brief Message (for export)
    -- @return string - compiled message
    function HOUND.Contact:generateIntelBrief()
        -- track ECHO 1017, straigh flush, ACTIVE, BULLSEYE 012 13, lat/lon, accuracy very high.
        -- TrackId,RadarType,State,Bullseye,Latitude,Longitude,MGRS,Accuracy
        local msg = ""
        if self:hasPos() then
            local GridPos,BePos = self:getTextData(true,HOUND.MGRS_PRECISION)
            msg = {
                self:getTrackId(),self:getNatoDesignation(),self:getType(),
                HOUND.Utils.TTS.getVerbalContactAge(self.last_seen,true,true),
                BePos,self.pos.LL.lat,self.pos.LL.lon, GridPos,
                HOUND.Utils.TTS.getVerbalConfidenceLevel( self.uncertenty_data.r ),
                HOUND.Utils.Text.getTime(self.last_seen)
            }
            msg = table.concat(msg,",")
        end
        return msg
    end
end
