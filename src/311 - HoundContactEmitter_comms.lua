--- HOUND.Contact.Emitter_comms
-- @module HOUND.Contact.Emitter
do
    local l_math = math
    local HoundUtils = HOUND.Utils

    --- Comms functions
    -- @section Comms

    --- return Information used in Text messages
    -- @param utmZone (bool) True will add UTM zone to response
    -- @param MGRSdigits (Number) number of digits in the MGRS part of the response (eg. 2 = 12, 5=12345)
    -- @return GridPos (string) MGRS grid position (eg. "CY 564 123", "DN 2 4")
    -- Return BE (string) Bullseye position string (eg. "035/15", "187/120")
    function HOUND.Contact.Emitter:getTextData(utmZone,MGRSdigits)
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
    function HOUND.Contact.Emitter:getTtsData(utmZone,MGRSdigits)
        if self.pos.p == nil then return end
        local phoneticGridPos = ""
        if utmZone then
            phoneticGridPos =  phoneticGridPos .. HoundUtils.TTS.toPhonetic(self.pos.grid.UTMZone) .. " "
        end

        phoneticGridPos =  phoneticGridPos ..  HoundUtils.TTS.toPhonetic(self.pos.grid.MGRSDigraph)
        local phoneticBulls = HoundUtils.TTS.toPhonetic(self.pos.be.brStr)
                                .. "  " .. self.pos.be.rng
        if MGRSdigits==nil then
            return phoneticGridPos,phoneticBulls
        end
        local E = l_math.floor(self.pos.grid.Easting/(10^l_math.min(5,l_math.max(1,5-MGRSdigits))))
        local N = l_math.floor(self.pos.grid.Northing/(10^l_math.min(5,l_math.max(1,5-MGRSdigits))))
        phoneticGridPos = phoneticGridPos .. " " .. HoundUtils.TTS.toPhonetic(E) .. "   " .. HoundUtils.TTS.toPhonetic(N)

        return phoneticGridPos,phoneticBulls
    end

    --- Generate TTS brief for the contact (for ATIS)
    -- @param NATO (bool) True will generate NATO Brevity brief
    -- @return string containing

    function HOUND.Contact.Emitter:generateTtsBrief(NATO)
        if self.pos.p == nil or self.uncertenty_data == nil then return end
        local phoneticGridPos,phoneticBulls = self:getTtsData(false,1)
        local reportedName = self:getName()
        if NATO then
            reportedName = self:getDesignation(NATO)
        end
        local str = reportedName
        if self:isAccurate() then
            str = str .. ", reported"
        else
            str = str .. ", " .. HoundUtils.TTS.getVerbalContactAge(self.last_seen,true,NATO)
        end
        if NATO then
            str = str .. " bullseye " .. phoneticBulls
        else
            str = str .. " at " .. phoneticGridPos
        end
        if not self:isAccurate() then
            str = str .. ", accuracy " .. HoundUtils.TTS.getVerbalConfidenceLevel( self.uncertenty_data.r )
        end
        str = str .. "."
        return str
    end

    --- Generate TTS report for the contact (for controller)
    -- @param[opt] useDMM if true. output will be DM.M rather then the default DMS
    -- @param[opt] preferMGRS if true output will be MGRS rather then Lat/Lon (not Currently used)
    -- @param[opt] refPos position of reference point for BR (Not Currently Used)
    -- @return generated message
    function HOUND.Contact.Emitter:generateTtsReport(useDMM,preferMGRS,refPos)
        if self.pos.p == nil then return end
        useDMM = useDMM or false
        preferMGRS = preferMGRS or false
        local MGRSPrecision = HOUND.MGRS_PRECISION
        if preferMGRS then
            MGRSPrecision = 5;
        end
        local BR = nil
        if refPos ~= nil and refPos.x ~= nil and refPos.z ~= nil then
            BR = HoundUtils.getBR(self.pos.p,refPos)
        end
        local phoneticGridPos,phoneticBulls = self:getTtsData(true,MGRSPrecision)
        local msg =  self:getName()
        if self:isAccurate()
            then
                msg = msg .. ", reported"
            else
               msg = msg .. ", " .. HoundUtils.TTS.getVerbalContactAge(self.last_seen,true)
        end
        if BR ~= nil
            then
                msg = msg .. " from you " .. HoundUtils.TTS.toPhonetic(BR.brStr) .. " for " .. BR.rng
            else
                msg = msg .." at bullseye " .. phoneticBulls
        end
        local LLstr = HoundUtils.TTS.getVerbalLL(self.pos.LL.lat,self.pos.LL.lon,useDMM)

        local primaryPos = LLstr
        if preferMGRS then
            primaryPos = phoneticGridPos
        end

        msg = msg .. ", accuracy " .. HoundUtils.TTS.getVerbalConfidenceLevel( self.uncertenty_data.r )
        msg = msg .. ", position " .. primaryPos
        msg = msg .. ", I say again " .. primaryPos
        if not preferMGRS then
            msg = msg .. ", MGRS " .. phoneticGridPos
        end
        msg = msg .. ", elevation  " .. self:getElev() .. " feet MSL"

        if HOUND.EXTENDED_INFO then
            if self:isAccurate()
                then
                    msg = msg .. ", Reported " .. HoundUtils.TTS.getVerbalContactAge(self.first_seen) .. " ago"
                else
                    msg = msg .. ", ellipse " ..  HoundUtils.TTS.simplfyDistance(self.uncertenty_data.major) .. " by " ..  HoundUtils.TTS.simplfyDistance(self.uncertenty_data.minor) .. ", aligned bearing " .. HoundUtils.TTS.toPhonetic(string.format("%03d",self.uncertenty_data.az))
                    msg = msg .. ", Tracked for " .. HoundUtils.TTS.getVerbalContactAge(self.first_seen) .. ", last seen " .. HoundUtils.TTS.getVerbalContactAge(self.last_seen) .. " ago"
                end
        end
        msg = msg .. ". " .. HoundUtils.getControllerResponse()
        return msg
    end

    --- Generate Text report for the contact (for controller)
    -- @param[opt] useDMM if true. output will be DM.M rather then the default DMS
    -- @param[opt] refPos position of reference point for BR
    -- @return generated message
    function HOUND.Contact.Emitter:generateTextReport(useDMM,refPos)
        if self.pos.p == nil then return end
        useDMM = useDMM or false

        local GridPos,BePos = self:getTextData(true,HOUND.MGRS_PRECISION)
        local BR = nil
        if refPos ~= nil and refPos.x ~= nil and refPos.z ~= nil then
            BR = HoundUtils.getBR(self.pos.p,refPos)
        end
        local msg =  self:getName()
        if self:isAccurate()
            then
                msg = msg .." (Reported)\n"
            else
                msg = msg .." (" .. HoundUtils.TTS.getVerbalContactAge(self.last_seen,true).. ")\n"
        end
        msg = msg .. "Accuracy: " .. HoundUtils.TTS.getVerbalConfidenceLevel( self.uncertenty_data.r ) .. "\n"
        msg = msg .. "BE: " .. BePos .. "\n" -- .. " (grid ".. GridPos ..")\n"
        if BR ~= nil then
            msg = msg .. "BR: " .. BR.brStr .. " for " .. BR.rng
        end
        msg = msg .. "LL: " .. HoundUtils.Text.getLL(self.pos.LL.lat,self.pos.LL.lon,useDMM).."\n"
        msg = msg .. "MGRS: " .. GridPos .. "\n"
        msg = msg .. "Elev: " .. self:getElev() .. "ft"
        if HOUND.EXTENDED_INFO then
            if self:isAccurate() then
                msg = msg .. "\nReported " .. HoundUtils.TTS.getVerbalContactAge(self.first_seen) .. " ago. "
            else
                msg = msg .. "\nEllipse: " ..  self.uncertenty_data.major .. " by " ..  self.uncertenty_data.minor .. " aligned bearing " .. string.format("%03d",self.uncertenty_data.az) .. "\n"
                msg = msg .. "Tracked for: " .. HoundUtils.TTS.getVerbalContactAge(self.first_seen) .. " Last Contact: " ..  HoundUtils.TTS.getVerbalContactAge(self.last_seen) .. " ago. "
            end
        end
        return msg
    end

    --- generate Text for the Radio menu item
    -- @return string
    function HOUND.Contact.Emitter:getRadioItemText()
        if not self:hasPos() then return self:getName() end
        local GridPos,BePos = self:getTextData(true,1)
        BePos = BePos:gsub(" for ","/")
        return self:getName() .. " - BE: " .. BePos .. " (".. GridPos ..")"
    end

    --- generate PopUp report
    -- @param isTTS Bool. If true message will be for TTS. False will make a text message
    -- @param[type=string] sectorName Name of primary sector if present function will only return sector data
    -- @return string. compiled message
    function HOUND.Contact.Emitter:generatePopUpReport(isTTS,sectorName)
        local msg = self:getName()
        if self:isAccurate() then
            msg = msg .. " has been reported"
        else
            msg = msg .. " is now Alive"
        end

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
    -- @param[type=string] sectorName Name of primary sector if present function will only return sector data
    -- @return string. compiled message
    function HOUND.Contact.Emitter:generateDeathReport(isTTS,sectorName)
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
    function HOUND.Contact.Emitter:generateIntelBrief()
        -- TrackId,RadarType,State,Bullseye,Latitude,Longitude,MGRS,Accuracy,DCS type,DCS Unit
        local msg = ""
        if self:hasPos() then
            local GridPos,BePos = self:getTextData(true,HOUND.MGRS_PRECISION)
            msg = {
                self:getTrackId(),self:getType(),
                HoundUtils.TTS.getVerbalContactAge(self.last_seen,true,true),
                BePos,string.format("%02.6f",self.pos.LL.lat),string.format("%03.6f",self.pos.LL.lon), GridPos,
                HoundUtils.TTS.getVerbalConfidenceLevel( self.uncertenty_data.r ),
                HoundUtils.Text.getTime(self.last_seen),self.DcsTypeName,self.DcsObjectName
            }
            msg = table.concat(msg,",")
        end
        return msg
    end
end
