--- HOUND.Utils
-- This class holds generic function used by all of Hound Components
-- @module HOUND.Utils
do
    local l_mist = HOUND.Mist
    local l_math = math
    local l_grpc = GRPC
    local PI_2 = 2*l_math.pi

--- HOUND.Utils decleration
-- @table HOUND.Utils
-- @field Mapping Extrapulation functions
-- @field Geo Geographic functions
-- @field Text Text functions
-- @field Elint Elint functions
-- @field Sort Sort funtions
-- @field Filter Filter functions
-- @field ReportId intrnal ATIS numerator
-- @field _MarkId internal markId Counter
-- @field _HoundId internal HoundId counter
    HOUND.Utils = {
        Mapping = {},
        Dcs     = {},
        Geo     = {},
        Marker  = {},
        Text    = {},
        Elint   = {},
        Vector  = {},
        Zone    = {},
        Sort    = {},
        Filter  = {},
        ReportId = nil,
        _HoundId = 0
    }
    HOUND.Utils.__index = HOUND.Utils

    --- General functions
    -- @section general

    --- get next Hound Instance Id
    -- @return #number Next HoundId

    function HOUND.Utils.getHoundId()
        HOUND.Utils._HoundId = HOUND.Utils._HoundId + 1
        return HOUND.Utils._HoundId
    end

    --- Get next Markpoint Id (Depricated)
    -- @see HOUND.Utils.Marker.getId
    -- @local
    -- return the next available MarkId
    -- @return Next MarkId
    function HOUND.Utils.getMarkId()
        return HOUND.Utils.Marker.getId()
    end

    --- Set New initial marker Id (DEPRICATED)
    -- @see HOUND.Utils.Marker.setInitialId
    -- @local
    -- @param startId Number to start counting from
    -- @return[type=Bool] True if initial ID was updated
    function HOUND.Utils.setInitialMarkId(startId)
        return HOUND.Utils.Marker.setInitialId(startId)
    end

    --[[
    ----- Generic Functions ----
    --]]

    --- Get time delta between two timestemps
    -- @param t0 time to test (in number of seconds)
    -- @param[opt] t1 time in number of seconds. if not provided, will use current DCS mission time
    -- @return time delta between t0 and t1
    -- @usage HOUND.Utils.absTimeDelta(<10s ago>,now) ==> 10

    function HOUND.Utils.absTimeDelta(t0, t1)
        if t1 == nil then t1 = timer.getAbsTime() end
        return t1 - t0
    end

    --- return difference in radias between two angles (bearings)
    -- @param rad1 angle in radians
    -- @param rad2 angle in radians
    -- @return angle difference between rad1 and rad2 (between pi and -pi)

    function HOUND.Utils.angleDeltaRad(rad1,rad2)
        if not rad1 or not rad2 then return end
        -- return l_math.abs(l_math.abs(rad1-l_math.pi)-l_math.abs(rad2-l_math.pi))
        return l_math.pi - l_math.abs(l_math.pi - l_math.abs(rad1-rad2) % PI_2)
    end

    --- normlize angle in radians
    -- @param[type=number] rad
    -- @return normlized angle in rad (0-2Pi)
    function HOUND.Utils.normalizeAngle(rad)
        return rad - (PI_2) * l_math.floor((rad + l_math.pi) / (PI_2))
    end

    --- return avarage azimuth
    -- @param azimuths a list of azimuths in radians
    -- @return the avarage azimuth of the list provided in radians (between 0 and 2*pi)

    function HOUND.Utils.AzimuthAverage(azimuths)
        -- TODO: fix this function. Circular mean has errors, bad ones..
        if not azimuths or HOUND.Length(azimuths) == 0 then return nil end

        local sumSin = 0
        local sumCos = 0
        for i=1, HOUND.Length(azimuths) do
            sumSin = sumSin + l_math.sin(azimuths[i])
            sumCos = sumCos + l_math.cos(azimuths[i])
        end
        return (l_math.atan2(sumSin,sumCos) + PI_2) % PI_2
    end

    --- Return magnetic variation in point
    -- @param DCSpoint point
    -- @return Magentic variation in radians
    function HOUND.Utils.getMagVar(DCSpoint)
        if not HOUND.Utils.Dcs.isPoint(DCSpoint) then return 0 end
        -- local l_magvar = require('magvar')
        -- if l_magvar then
        --     local lat, lon, _ = coord.LOtoLL(DCSpoint)
        --     return magvar.get_mag_decl(lat, lon)
        -- end
        return l_mist.getNorthCorrection(DCSpoint)

    end
    --- return the tilt of a point cluster
    -- @param points a list of DCS points
    -- @param[opt] MagNorth (Bool) if true value will include north var correction
    -- @param[opt] refPos a DCS point that will be the reference for azimuth
    -- @return azimuth in radians (between 0 and pi)
    function HOUND.Utils.PointClusterTilt(points,MagNorth,refPos)
        if not points or type(points) ~= "table" then return end
        if not refPos then
            refPos = l_mist.getAvgPoint(points)
        end
        local magVar = 0
        if MagNorth then
            magVar = HOUND.Utils.getMagVar(refPos)
        end
        local biasVector = nil
        for _,point in pairs(points) do
            local V = {
                y = 0
            }
            V.x = point.x - refPos.x
            V.z = point.z - refPos.z
            if V.x < 0 then
                V.x = -V.x
                V.z = -V.z
            end
            if biasVector == nil then biasVector = V else biasVector = l_mist.vec.add(biasVector,V) end
        end
        return (l_math.atan2(biasVector.z,biasVector.x) + magVar) % PI_2
    end

    --- returns a random angle
    -- @return random angle in radians between 0 and 2*pi

    function HOUND.Utils.RandomAngle()
        -- actuallu a map
        return l_math.random() * 2 * l_math.pi
    end

    --- return ground elevation rouded to 50 feet
    -- @param elev Height in meters
    -- @param[opt] resolution round to the nerest increment. default is 50
    -- @return elevation converted to feet, rounded to the nearest 50 ft

    function HOUND.Utils.getRoundedElevationFt(elev,resolution)
        if not resolution then
            resolution = 50
        end
        return HOUND.Utils.roundToNearest(l_mist.utils.metersToFeet(elev),resolution)
    end

    --- return rounted number nearest a set interval
    -- @param input numeric value to be rounded
    -- @param nearest numeric value of the step to round input to (e.g 10,50,500)
    -- @return input number rounded to the nearest interval provided.(e.g 3244 -> 3250)

    function HOUND.Utils.roundToNearest(input,nearest)
        return l_mist.utils.round(input/nearest) * nearest
    end

    --- get normal distribution angular error.
    -- will generate gaussian magnitude based on variance and random angle
    -- @param variance error margin requester (in radians)
    -- @return table {el,az}, contining error in Azimuth and elevation in radians

    function HOUND.Utils.getNormalAngularError(variance)
        -- https://en.m.wikipedia.org/wiki/Box%E2%80%93Muller_transform
        local stddev = variance /2
        local Magnitude = l_math.sqrt(-2 * l_math.log(l_math.random())) * stddev
        local Theta = 2* math.pi * l_math.random()

        -- from radius and angle you can get the point on the circles
        local epsilon = {
            az = Magnitude * l_math.cos(Theta),
            el = Magnitude * l_math.sin(Theta)
        }
        return epsilon
    end

    --- get random controller snarky remark
    -- @return random response string from pool
    function HOUND.Utils.getControllerResponse()
        local response = {
            " ",
            "Good Luck!",
            "Happy Hunting!",
            "Please send my regards.",
            "Come back with E T A, T O T, and B D A.",
            " "
        }
        return response[l_math.max(1,l_math.min(l_math.ceil(timer.getAbsTime() % HOUND.Length(response)),HOUND.Length(response)))]
    end

    --- get coalition string
    -- @param coalitionID integer of DCS coalition id
    -- @return string name of coalition

    function HOUND.Utils.getCoalitionString(coalitionID)
        local coalitionStr = "RED"
        if coalitionID == coalition.side.BLUE then
            coalitionStr = "BLUE"
        elseif coalitionID == coalition.side.NEUTRAL then
            coalitionStr = "NEUTRAL"
        end
        return coalitionStr
    end

    --- returns hemisphere information for LatLon
    -- @param lat (float) latitude in decimal Degrees
    -- @param lon (float) longitude in decimal Degrees
    -- @param fullText (bool) determin if function should return "E" or "East"
    -- @return (table) {NS=string,EW=string} return hemisphere strings

    function HOUND.Utils.getHemispheres(lat,lon,fullText)
        local hemi = {
            NS = "North",
            EW = "East"
        }
        if lat < 0 then hemi.NS = "South" end
        if lon < 0 then hemi.EW = "West" end
        if fullText == nil or fullText == false then
            hemi.NS = string.sub(hemi.NS, 1, 1)
            hemi.EW = string.sub(hemi.EW, 1, 1)
        end
        return hemi
    end

    --- get "ATIS" report ID
    -- returns next Phonetic report ID.
    -- Report ID loops around, i.e "Alpha" --> "Bravo" -> .. -> "Zulu" -> "Alpha"
    -- @param[opt] ReportId char, current report ID if not using global var
    -- @return (string) phonetic ID ("Alpha","Bravo", "charlie"...)
    -- @return (Char) letter of ReportId ('A','B','C','D')

    function HOUND.Utils.getReportId(ReportId)
        local returnId
        if ReportId ~= nil then
            returnId =  string.byte(ReportId)
        else
            returnId = HOUND.Utils.ReportId
        end
        if returnId == nil or returnId == string.byte('Z') then
            returnId = string.byte('A')
        else
            returnId = returnId + 1
        end
        if not ReportId then
            HOUND.Utils.ReportId = returnId
        end

        return HOUND.DB.PHONETICS[string.char(returnId)],string.char(returnId)
    end

    --- Convert Decimal Degrees to DMS (D.DD to DMS)
    -- @param cood (float) lat or lon (e.g. 35.443, -124.5543)
    -- @return DMS (table)
    -- { d=deg,
    --   m=minutes,
    --   s=sec,
    --   mDec = Decimal minutes
    -- }

    function HOUND.Utils.DecToDMS(cood)
        local deg = l_math.floor(cood)
        if cood < 0 then
            deg = l_math.ceil(cood)
        end
        local minutes = l_math.floor(l_math.abs(cood - deg) * 60)
        local sec = l_math.floor((l_math.abs(cood-deg) * 3600) % 60)
        local dec = l_math.abs(cood-deg) * 60

        return {
            d = deg,
            m = minutes,
            s = sec,
            mDec = l_mist.utils.round(dec ,3),
            sDec = l_mist.utils.round((l_mist.utils.round(dec,3)*1000)-(minutes*1000))
        }
    end

    --- retrun Bearing (magnetic) and range between two points
    -- @param src (DCS pos) Position of source
    -- @param dst (DCS pos) Position of destination
    -- @return (table) {br = bearing(float), brStr=bearing(string, 3 chars rounded, e.g "044"), rng = Range in NM}

    function HOUND.Utils.getBR(src,dst)
        if not src or not dst then return end
        local BR = {}
        local dir = l_mist.utils.getDir(l_mist.vec.sub(dst,src),src) -- pass src to get magvar included
        -- local magvar = l_mist.getNorthCorrection(src)
        BR.brg = l_mist.utils.round(l_mist.utils.toDegree( dir ))
        BR.brStr = string.format("%03d",BR.brg)
        BR.rng = l_mist.utils.round(l_mist.utils.metersToNM(l_mist.utils.get2DDist(dst,src)))
        -- env.info("getBR: " .. dir .. "|".. magvar .. "="..BR.brg)
        return BR
    end

    --- Get group callsign from unit
    -- @param player mist.DB entry to get formation callsign for
    -- @param[opt] override callsign substitution table
    -- @param[opt] flightMember if True. value returned will be the full callsign (i.e "Uzi 1 1" rather then the default "Uzi 1")
    -- @return Formation callsign string
    function HOUND.Utils.getFormationCallsign(player,override,flightMember)
        local callsign = ""
        local DcsUnit = Unit.getByName(player.unitName)
        if type(player) ~= "table" then return callsign end
        if type(flightMember) == "table" and override == nil then
            override,flightMember = flightMember,override
        end
        local formationCallsign = string.gsub(player.callsign.name,"[%d%s]","")

        callsign =  formationCallsign .. " " .. player.callsign[2]
        if flightMember then
            callsign = callsign .. " " .. player.callsign[3]
        end

        if type(override) == "table" then
            if HOUND.setContains(override,formationCallsign) then
                local override = override[formationCallsign]
                if override == "*" then
                    override = DcsUnit:getGroup():getName() or formationCallsign
                end
                callsign = callsign:gsub(formationCallsign,override)
                return string.upper(callsign:match( "^%s*(.-)%s*$" ))
            end
        end

        if not DcsUnit then return string.upper(callsign:match( "^%s*(.-)%s*$" )) end

        local playerName = DcsUnit:getPlayerName()
        playerName = playerName:match("%a+%s%d+[?%p%s*]%d*")
        if playerName then
            callsign = playerName
            local base = string.match(callsign,"%a+")
            local num = tonumber(string.match(callsign,"%d+"))
            local memberNum = string.gsub(callsign,"%a+%s%d+[%p%s*]","")
            if memberNum:len() > 0 then
                memberNum = tonumber(memberNum:match("%d+"))
            else
                memberNum = nil
            end

            callsign = base
            if type(num) == "number" and type(memberNum) == "number" then
                callsign = callsign .. " " .. num
            end

            if flightMember then
                if type(memberNum) == "number" then
                    callsign = callsign .. " " .. memberNum
                end
                if type(num) == "number" and type(memberNum) == "nil" then
                    callsign = callsign .. " " .. num
                end
            end
            return string.upper(callsign:match( "^%s*(.-)%s*$" ))
        end
        return string.upper(callsign:match( "^%s*(.-)%s*$" ))
    end

    --- get Callsign
    -- @param[opt] namePool string "GENERIC" or "NATO"
    -- @return string random callsign from pool
    function HOUND.Utils.getHoundCallsign(namePool)
        local SelectedPool = HOUND.DB.CALLSIGNS[namePool] or HOUND.DB.CALLSIGNS.GENERIC
        return SelectedPool[l_math.random(1, HOUND.Length(SelectedPool))]
    end

    --- Unit use DMM
    -- @param DcsUnit DCS Unit or typeName string
    function HOUND.Utils.useDMM(DcsUnit)
        if not DcsUnit then return false end
        local typeName = nil
        if type(DcsUnit) == "string" then
            typeName = DcsUnit
        end
        if HOUND.Utils.Dcs.isUnit(DcsUnit) then
            typeName = DcsUnit:getTypeName()
        end
        return HOUND.setContains(HOUND.DB.useDMM,typeName)
    end

    --- Unit use MGRS
    -- @param DcsUnit DCS Unit or typeName string
    function HOUND.Utils.useMGRS(DcsUnit)
        if not DcsUnit then return false end
        local typeName = nil
        if type(DcsUnit) == "string" then
            typeName = DcsUnit
        end
        if HOUND.Utils.Dcs.isUnit(DcsUnit) then
            typeName = DcsUnit:getTypeName()
        end
        return HOUND.setContains(HOUND.DB.useMGRS,typeName)
    end
    --- does unit has payload (placeholder)
    -- @param DcsUnit DCS unit
    -- @param payloadName Name of payload
    -- @return[type=bool] always true
    function HOUND.Utils.hasPayload(DcsUnit,payloadName)
        -- TODO: add implementation
        return true
    end

    --- does unit has task (placeholder)
    -- @param DcsUnit DCS unit
    -- @param taskName Name of task
    -- @return[type=bool] always true
    function HOUND.Utils.hasTask(DcsUnit,taskName)
        -- TODO: add implementation
        return true
    end

    --- Value mapping Functions
    -- @section Mapping
    HOUND.Utils.Mapping.CURVES = {
        RETAIL = 0,
        WINDOWS = 1,
        HERRA9 = 2,
        HERRA45 = 3,
        EXPONENTIAL = 4,
        MIXED = 5,
        POWER = 6
    }

    --- clamn values to range (minmax)
    -- @local
    -- @param[type=number] input value
    -- @param[type=number] out_min Minimum output value
    -- @param[type=number] out_max Maximum output value
    function HOUND.Utils.Mapping.clamp(input, out_min, out_max)
        return l_math.max(out_min,l_math.min(input,out_max))
    end

    --- map input to range (Arduino implementation)
    -- @local
    -- @param input value
    -- @param in_min Minimum allowble input value
    -- @param in_max Maximum allowable input value
    -- @param out_min Minimum allowable output value
    -- @param out_max Maximum allowable output value
    -- @param[opt] clamp Bool if true values will be clipped at range specified
    -- @return calculated mapped value
    -- @usage HOUND.Utils.Mapping.linear(10,0,10,0,100) = 100
    --  HOUND.Utils.Mapping.linear(0.5,0,1,0,100) = 50
    function HOUND.Utils.Mapping.linear(input, in_min, in_max, out_min, out_max,clamp)
        local mapValue = (input - in_min) * (out_max - out_min) / (in_max - in_min) + out_min
        if clamp then
            if out_min < out_max then
                return l_math.max(out_min,l_math.min(out_max,mapValue))
            else
                return l_math.max(out_max,l_math.min(out_min,mapValue))
            end
        end
        return mapValue
    end

    --- Map values on a curve
    -- @param value original input
    -- @param in_min Minimum input value
    -- @param in_max Maximum input value
    -- @param[opt] out_min Minimum output value (0 if not specified)
    -- @param[opt] out_max Maximum output value (1 if not specified)
    -- @param[opt] sensitivity requested sensitivity (0-9, default 9 is leased curved)
    -- @param[opt] curve_type requested curve profile (0-6, 0 is default)
    function HOUND.Utils.Mapping.nonLinear(value,in_min,in_max,out_min,out_max,sensitivity,curve_type)
        -- https://github.com/achilleas-k/fs2open.github.com/blob/joystick_curves/joy_curve_notes/new_curves.md

        if type(sensitivity) ~= "number" then
            sensitivity = 9
        end
        sensitivity=l_math.min(0,l_math.max(9,sensitivity))
        local relativePos = HOUND.Utils.Mapping.linear(value,in_min,in_max,0,1)
        -- retail curve (default)
        -- f(I) = I*(s/9)+(I^5)*(9-s)/9
        local mappedIn = relativePos*(sensitivity/9)+(relativePos^5)*(9-sensitivity)/9
        if type(curve_type) == "number" then
            if curve_type == 1 then
                -- windows curve
                -- f(I) = I^(3-(s/4.5))
                mappedIn = relativePos^(3-(sensitivity/4.5))
            elseif curve_type == 2 then
                -- Herra 9
                -- f(I) = I^(s/9)*((1-cos(I*π))/2)^((9-s)/9)
                mappedIn = relativePos^(sensitivity/9)*((1-l_math.cos(relativePos*l_math.pi))/2)^((9-sensitivity)/9)
            elseif curve_type == 3 then
                -- Herra 4.5
                -- f(I) = I^(s/9)*((1-cos(I*π))/2)^((9-s)/4.5)
                mappedIn = relativePos^(sensitivity/9)*((1-l_math.cos(relativePos*l_math.pi))/2)^((9-sensitivity)/4.5)
            elseif curve_type == 4 then
                -- Exponential curve
                mappedIn = (l_math.exp((10-sensitivity)*relativePos)-1)/(l_math.exp(10-sensitivity)-1)
            elseif curve_type == 5 then
                -- Mixed curve
                -- f(x) = I^(1+((5-s)/9))
                mappedIn = relativePos^(1+((5-sensitivity)/9))
            elseif curve_type == 6 then
                -- Power curve
                -- f(I) = I*I^((9-s)/9)
                mappedIn = relativePos*relativePos^((9-sensitivity)/9)
            end
        end

        if type(out_min) == "number" and type(out_max) == "number" then
            return HOUND.Utils.Mapping.linear(mappedIn,0,1,out_min,out_max)
        end
        return mappedIn
    end

    --- DCS object functions
    -- @section Dcs

    ---  check if point is DCS point
    -- @param point DCS point candidate
    -- @return[type=Bool] True if is valid point
    function HOUND.Utils.Dcs.isPoint(point)
        if type(point) ~= "table" then return false end
        -- local point_meta = getmetatable(point)
        -- local vec2_meta = getmetatable({x=0,z=0})
        -- local vec3_meta = getmetatable({x=0,z=0,y=0})
        -- return point_meta == vec3_meta or point_meta == vec2_meta
        return (type(point.x) == "number") and (type(point.z) == "number")
    end

    --- check if object is DCS Unit
    -- @param obj DCS Object canidate
    -- @return[type=Bool] True if object is unit
    function HOUND.Utils.Dcs.isUnit(obj)
        if type(obj) ~= "table" then return false end
        return getmetatable(obj) == Unit
    end

    --- check if object is DCS Group
    -- @param obj DCS Object canidate
    -- @return[type=Bool] True if object is Group
    function HOUND.Utils.Dcs.isGroup(obj)
        if type(obj) ~= "table" then return false end
        return getmetatable(obj) == Group
    end

    --- check if object is DCS static object
    -- @param obj DCS Object canidate
    -- @return[type=Bool] True if object is static object
    function HOUND.Utils.Dcs.isStaticObject(obj)
        if type(obj) ~= "table" then return false end
        return getmetatable(obj) == StaticObject
    end

    --- check if object is a human unit
    -- @param obj DCS Object canidate
    -- @return[type=Bool] True if object is a Human unit
    function HOUND.Utils.Dcs.isHuman(obj)
        if not HOUND.Utils.Dcs.isUnit(obj) then return false end
        return obj:getPlayerName() ~= nil
    end

    --- get list of human clinets for hound.
    -- @param coalitionId
    -- @return list of units
    function HOUND.Utils.Dcs.getPlayers(coalitionId)
        if type(coalitionId) ~= "number" or (coalitionId > 2 or coalitionId < 0) then return {} end
        local players = coalition.getPlayers(coalitionId)
        local humanUnits = {}
        for i = 1, #players do
            local playerUnit = players[i]
            local _,catEx = playerUnit:getCategory()
            if HOUND.setContainsValue({Unit.Category.AIRPLANE,Unit.Category.HELICOPTER},catEx) then
                local unit_data = HOUND.DB.generateMistDbEntry(playerUnit)
                humanUnits[unit_data.unitName] = unit_data
            end
        end
        return humanUnits
    end

    --- get human players in group
    --@param[type=tab] DcsGroup
    --@return table of players in group
    function HOUND.Utils.Dcs.getPlayersInGroup(DcsGroup)
        if type(DcsGroup) == "string" then
            DcsGroup = Group.getByName(DcsGroup)
        end
        if not HOUND.Utils.Dcs.isGroup(DcsGroup) then return {} end
        local coa = DcsGroup:getCoalition()
        local gid = DcsGroup:getID()
        if type(HOUND.DB.HumanUnits.byGid[coa][gid]) ~= "table" then return {} end
        local humanUnits = {}
        for unitName,unitData in pairs(HOUND.DB.HumanUnits.byGid[coa][gid]) do
            humanUnits[unitName] = unitData
        end
        return humanUnits
    end

    --- check if Unit is tracking anything with it's radar
    -- @param DcsUnit
    -- @return[type=bool] True if tracking
    function HOUND.Utils.Dcs.isRadarTracking(DcsUnit)
        if not HOUND.Utils.Dcs.isUnit(DcsUnit) then return false end
        local _,isTracking = DcsUnit:getRadar()
        return HOUND.Utils.Dcs.isUnit(isTracking)
    end

    --- return maximum weapon range in the group of DCS Unit
    -- @param DcsUnit DCS unit - in Hound context unit with emitting radar
    -- @return maximum weapon range in meters of the DCS Group the emitter is part of

    function HOUND.Utils.Dcs.getSamMaxRange(DcsUnit)
        local maxRng = 0
        if DcsUnit ~= nil then
            local units = DcsUnit:getGroup():getUnits()
            for _, unit in ipairs(units) do
                local weapons = unit:getAmmo()
                if weapons ~= nil then
                    for _, ammo in ipairs(weapons) do
                        if ammo.desc.category == Weapon.Category.MISSILE and ammo.desc.missileCategory == Weapon.MissileCategory.SAM then
                            maxRng = l_math.max(l_math.max(ammo.desc.rangeMaxAltMax,ammo.desc.rangeMaxAltMin),maxRng)
                        end
                    end
                end
            end
        end
        return maxRng
    end

    --- return Radar detection Range for provided unit
    -- @param DcsUnit DCS Unit with radars sensor
    -- @return Unit radar detection range agains airborne targers in meters

    function HOUND.Utils.Dcs.getRadarDetectionRange(DcsUnit)
        -- TODO: fix for ships
        local detectionRange = 0
        local unit_sensors = DcsUnit:getSensors()
        if not unit_sensors then return detectionRange end
        if not HOUND.setContains(unit_sensors,Unit.SensorType.RADAR) then return detectionRange end
        for _,radar in pairs(unit_sensors[Unit.SensorType.RADAR]) do
            if HOUND.setContains(radar,"detectionDistanceAir") then
                for _,aspects in pairs(radar["detectionDistanceAir"]) do
                    for _,range in pairs(aspects) do
                        detectionRange = l_math.max(detectionRange,range)
                        -- env.info(radar["typeName"].. " Detection range is " .. range)
                    end
                end
            end
        end
        return detectionRange
    end

    --- return all radar units in group
    -- @param DcsGroup DCS Group
    -- @return[type=table] Table of radar units in group
    function HOUND.Utils.Dcs.getRadarUnitsInGroup(DcsGroup)
        local radarUnits = {}
        if HOUND.Utils.Dcs.isGroup(DcsGroup) and DcsGroup:isExist() and DcsGroup:getSize() > 0 then
            for _,unit in ipairs(DcsGroup:getUnits()) do
                if unit:hasSensors(Unit.SensorType.RADAR) and HOUND.setContains(HOUND.DB.Radars,unit:getTypeName()) then
                    table.insert(radarUnits,unit)
                end
            end
        end
        return radarUnits
    end

    --- get all current Groups, name only
    -- @param[type=?string] prefix return only groups starting with prefix
    -- @return table of currently existing DCS group names
    function HOUND.Utils.Dcs.getGroupNames(prefix)
        local groups = {}
        if type(prefix) ~= "string" then
            prefix = nil
        end
        for _,coalitionName in pairs(coalition.side) do
            for _,group in pairs(coalition.getGroups(coalitionName)) do
                local groupName = group:getName()
                if prefix == nil or (prefix ~= "" and string.find(groupName, prefix, 1, true) == 1) then
                    groups[groupName] = group:getID()
                end
            end
        end
        return groups
    end

        --- get all current Groups, name only
    -- @param[type=?string] prefix return only groups starting with prefix
    -- @return table of currently existing DCS group names
    function HOUND.Utils.Dcs.getUnitNames(prefix)
        local units = {}
        if type(prefix) ~= "string" then
            prefix = nil
        end
        for _,coalitionName in pairs(coalition.side) do
            for _,group in pairs(coalition.getGroups(coalitionName)) do
                for _,unit in pairs(group:getUnits()) do
                    local unitName = unit:getName()
                    if prefix == nil or (prefix ~= "" and string.find(unitName, prefix, 1, true) == 1) then
                        units[unitName] = HOUND.DB.generateMistDbEntry(unit)
                    end
                end
            end
        end
        return units
    end

    --- get all current static objects, name only
    -- @return table of currently existing DCS static object names
    function HOUND.Utils.Dcs.getStaticObjectNames(prefix)
        local staticObjs = {}
        if type(prefix) ~= "string" then
            prefix = nil
        end
        for _,coalitionName in pairs(coalition.side) do
            for _,staticObj in pairs(coalition.getStaticObjects(coalitionName)) do
                local name = staticObj:getName()
                if prefix == nil or (prefix ~= "" and string.find(name, prefix, 1, true) == 1) then
                    staticObjs[name] = name
                end

            end
        end
        return staticObjs
    end

    function HOUND.Utils.Dcs.getGroupPoints(groupIdent)
        -- search by groupId and allow groupId and groupName as inputs
        local gpId = groupIdent
        if type(groupIdent) == 'string' and not tonumber(groupIdent) then
            for grpName,grpId in pairs(HOUND.Utils.Dcs.getGroupNames(groupIdent)) do
                if grpName == groupIdent then
                    gpId = grpId
                end
            end
            if gpId == groupIdent then
                log:error("Group not found: $1", groupIdent)
            end
        end

        for coa_name, coa_data in pairs(env.mission.coalition) do
            if  type(coa_data) == 'table' then
                if coa_data.country then --there is a country table
                    for cntry_id, cntry_data in pairs(coa_data.country) do
                        for obj_cat_name, obj_cat_data in pairs(cntry_data) do
                            if obj_cat_name == "helicopter" or obj_cat_name == "ship" or obj_cat_name == "plane" or obj_cat_name == "vehicle" then	-- only these types have points
                                if ((type(obj_cat_data) == 'table') and obj_cat_data.group and (type(obj_cat_data.group) == 'table') and (#obj_cat_data.group > 0)) then	--there's a group!
                                    for group_num, group_data in pairs(obj_cat_data.group) do
                                        if group_data and group_data.groupId == gpId then -- this is the group we are looking for
                                            if group_data.route and group_data.route.points and #group_data.route.points > 0 then
                                                local points = {}
                                                for point_num, point in pairs(group_data.route.points) do
                                                    if not point.point then
                                                        points[point_num] = { x = point.x, y = point.y }
                                                    else
                                                        points[point_num] = point.point	--it's possible that the ME could move to the point = Vec2 notation.
                                                    end
                                                end
                                                return points
                                            end
                                            return
                                        end	--if group_data and group_data.name and group_data.name == 'groupname'
                                    end --for group_num, group_data in pairs(obj_cat_data.group) do
                                end --if ((type(obj_cat_data) == 'table') and obj_cat_data.group and (type(obj_cat_data.group) == 'table') and (#obj_cat_data.group > 0)) then
                            end --if obj_cat_name == "helicopter" or obj_cat_name == "ship" or obj_cat_name == "plane" or obj_cat_name == "vehicle" or obj_cat_name == "static" then
                        end --for obj_cat_name, obj_cat_data in pairs(cntry_data) do
                    end --for cntry_id, cntry_data in pairs(coa_data.country) do
                end --if coa_data.country then --there is a country table
            end --if coa_name == 'red' or coa_name == 'blue' and type(coa_data) == 'table' then
        end --for coa_name, coa_data in pairs(mission.coalition) do
    end

    --- Geo Function
    -- @section Geo

    --- Return if the is LOS between two DCS points
    -- checks both radar horizon (round earth) and DCS terrain LOS
    -- @param pos0 (DCS pos)
    -- @param pos1 (DCS pos)
    -- @return (bool) true if both units have LOS between them

    function HOUND.Utils.Geo.checkLOS(pos0,pos1)
        if not HOUND.Utils.Dcs.isPoint(pos0) or not HOUND.Utils.Dcs.isPoint(pos1) then return false end
        local dist = l_mist.utils.get2DDist(pos0,pos1)
        local radarHorizon = HOUND.Utils.Geo.EarthLOS(pos0.y,pos1.y)
        return (dist <= radarHorizon*1.025 and land.isVisible(pos0,pos1))
    end

    --- Returns maximum horizon distance given heigh above the earth of two points
    -- if only one observer hight is provided, result would be maximum view distance to Sea Level
    -- @param h0 height of observer 1 in meters
    -- @param[opt] h1 height of observer 2 in meters
    -- @return distance maximum LOS distance in meters

    function HOUND.Utils.Geo.EarthLOS(h0,h1)
        if not h0 then return 0 end
        local Re = 6367444 -- Radius of earth in M (avarage radius of WGS84)
        local d0 = l_math.sqrt(h0^2+2*Re*h0)
        local d1 = 0
        if h1 then d1 = l_math.sqrt(h1^2+2*Re*h1) end
        return d0+d1
    end

    --- Returns Projected line impact point with Terrain
    -- @param p0 source Postion
    -- @param az Azimuth from Position (radians)
    -- @param el Elevation angle from position (radians)
    -- @return DCS point of intersection with ground
    function HOUND.Utils.Geo.getProjectedIP(p0,az,el)
        if not HOUND.Utils.Dcs.isPoint(p0) or type(az) ~= "number" or type(el) ~= "number" then return end
        local maxSlant = HOUND.Utils.Geo.EarthLOS(p0.y)*1.1
        -- local maxSlant = (p0.y/l_math.abs(l_math.sin(el)))+100

        local unitVector = HOUND.Utils.Vector.getUnitVector(az,el)
        return land.getIP(p0, unitVector , maxSlant )
    end

    --- Ensure Inpoint DCS point has Elevation
    -- @local
    -- @param point DCS point
    -- @param[type=?number] offset offset in meters from actual height
    -- @return Point but with elevation
    function HOUND.Utils.Geo.setPointHeight(point,offset)
        if HOUND.Utils.Dcs.isPoint(point) and type(point.y) ~= "number" then
            offset = offset or 0
            point.y = land.getHeight({x=point.x,y=point.z}) + offset
        end
        return point
    end

    --- Ensure input point or point table all have valid Elevation
    -- @param point DCS point
    -- @param[type=?number] offset offset in meters from actual height
    -- @return same as input, but with elevation. will return original value if is not DCS point
    function HOUND.Utils.Geo.setHeight(point,offset)
        if type(point) == "table" then
            offset = offset or 0
            if HOUND.Utils.Dcs.isPoint(point) then
                return HOUND.Utils.Geo.setPointHeight(point,offset)
            end
            for _,pt in pairs(point) do
                pt = HOUND.Utils.Geo.setPointHeight(pt,offset)
            end
        end
        return point
    end

    --- Get 2D distance between two points
    -- wrapper for mist.utils.get2DDist
    -- @param src dcs point
    -- @param dst dcs point
    -- @return distance in meters
    function HOUND.Utils.Geo.get2DDistance(src, dst)
        if HOUND.Utils.Dcs.isPoint(src) and HOUND.Utils.Dcs.isPoint(dst) then
            return l_mist.utils.get2DDist(src,dst)
        end

    end

    --- Get 3D distance between two points
    -- wrapper for mist.utils.get3DDist
    -- @param src dcs point
    -- @param dst dcs point
    -- @return distance in meters
    function HOUND.Utils.Geo.get3DDistance(src, dst)
        if HOUND.Utils.Dcs.isPoint(src) and HOUND.Utils.Dcs.isPoint(dst) then
            return l_mist.utils.get3DDist(src,dst)
        end

    end


    --- Marker Functions
    -- @section Markers
    HOUND.Utils.Marker._MarkId = 4999
    HOUND.Utils.Marker.Type = {
        NONE = 0,
        POINT = 1,
        TEXT =  2,
        CIRCLE = 3,
        FREEFORM = 4
    }

    --- Get next Markpoint Id
    -- @local
    -- return the next available MarkId
    -- @return Next MarkId
    function HOUND.Utils.Marker.getId()
        -- if HOUND.FORCE_MANAGE_MARKERS then
        --     HOUND.Utils.Marker._MarkId = HOUND.Utils.Marker._MarkId + 1
        -- elseif UTILS and UTILS.GetMarkID then
        --     HOUND.Utils.Marker._MarkId = UTILS.GetMarkID()
        -- else
            HOUND.Utils.Marker._MarkId = HOUND.Utils.Marker._MarkId + 1
        -- end
        return HOUND.Utils.Marker._MarkId
    end

    --- Set New initial marker Id
    -- @local
    -- @param startId Number to start counting from
    -- @return[type=Bool] True if initial ID was updated
    function HOUND.Utils.Marker.setInitialId(startId)
        if type(startId) ~= "number" then
            HOUND.Logger.error("Failed to set Initial marker Id. Value provided was not a number")
            return false
        end
        if HOUND.Utils.Marker._MarkID ~= 0 then
            HOUND.Logger.error("Initial MarkId not updated because markers have already been drawn")
            return false
        end
        HOUND.Utils.Marker._MarkId = startId
        return true
    end

    --- create Marker entity
    -- @local
    -- @function HOUND.Utils.Marker.create
    -- @param[opt] args parameters of markpoint
    -- @return Hound Marker Instance

    function HOUND.Utils.Marker.create(args)
        local instance = {}
        instance.id = -1
        instance.type = HOUND.Utils.Marker.Type.NONE

        --- update markpoint position
        -- @within HOUND.Utils.Marker.instance
        -- @param self Hound Marker instance
        -- @param pos position of marker (only single point is supported)
        instance.setPos = function(self,pos)
            if self.type == HOUND.Utils.Marker.Type.FREEFORM then return end
            if HOUND.Utils.Dcs.isPoint(pos) then
                trigger.action.setMarkupPositionStart(self.id,pos)
            end
        end

        --- update markpoint text
        -- @within HOUND.Utils.Marker.instance
        -- @param self Hound Marker instance
        -- @param text new text for marker
        instance.setText = function(self,text)
            if type(text) == "string" and self.id > 0 then
                if self.type == HOUND.Utils.Marker.Type.TEXT then
                    -- text = "¤ « " .. text
                    text = HOUND.MARKER_TEXT_POINTER .. text
                end
                trigger.action.setMarkupText(self.id,text)
            end
        end

        --- update markpoint radius
        -- @within HOUND.Utils.Marker.instance
        -- @param self Hound Marker instance
        -- @param radius new radius of markpoint (only circle type marks are supported)
        instance.setRadius = function(self,radius)
            if type(radius) == "number" and self.type == HOUND.Utils.Marker.Type.CIRCLE and self.id > 0 then
                trigger.action.setMarkupRadius(self.id,radius)
            end
        end

        --- update markpoint fill color
        -- @within HOUND.Utils.Marker.instance
        -- @param self Hound Marker instance
        -- @param color new fill color of marker
        instance.setFillColor = function(self,color)
            if self.id > 0 and self.type ~= HOUND.Utils.Marker.Type.FREEFORM and type(color) == "table" then
                trigger.action.setMarkupColorFill(self.id,color)
            end
        end

        --- update markpoint line color
        -- @within HOUND.Utils.Marker.instance
        -- @param self Hound Marker instance
        -- @param color new fill color of marker
        instance.setLineColor = function(self,color)
            if self.id > 0 and self.type ~= HOUND.Utils.Marker.Type.FREEFORM and type(color) == "table" then
                trigger.action.setMarkupColor(self.id,color)
            end
        end

        --- update markpoint line type
        -- @within HOUND.Utils.Marker.instance
        -- @param self Hound Marker instance
        -- @param lineType new lineType for marker
        instance.setLineType = function(self,lineType)
            if self.id > 0 and type(lineType) == "number" and self.type ~= HOUND.Utils.Marker.Type.FREEFORM then
                trigger.action.setMarkupTypeLine(self.id,lineType)
            end
        end

        --- Check if marpoint is drawn
        -- @within HOUND.Utils.Marker.instance
        -- @param self Hound Marker instance
        -- @return[type=bool] - True if marker is drawn
        instance.isDrawn = function(self)
            return (self.id > 0)
        end

        --- remove markpoint
        -- @within HOUND.Utils.Marker.instance
        -- @param self Hound Marker instance
        instance.remove = function(self)
            if self.id > 0 then
                local GC = (self.id % 5 == 0)
                trigger.action.removeMark(self.id)
                self.id = -1
                self.type = HOUND.Utils.Marker.Type.NONE
                if GC then
                    collectgarbage("collect")
                end
            end
        end

        --- create new point (internal)
        -- @within HOUND.Utils.Marker.instance
        -- @local
        -- @param self Hound Marker instance
        -- @param args full args array
        instance._new = function(self,args)
            if type(args) ~= "table" then return false end
            local coalition = args.coalition
            local pos = args.pos
            local text = args.text
            local lineColor = args.lineColor or {0,0,0,0.75}
            local fillColor = args.fillColor or {0,0,0,0}
            local lineType = args.lineType or 2
            local fontSize = args.fontSize or 16
            -- if type(fillColor) ~= "table" or type(lineColor) ~= "table" or type(text) ~= "string" then return false end
            if self.id < 1 then
                self.id = HOUND.Utils.Marker.getId()
            end
            if HOUND.Utils.Dcs.isPoint(pos) then
                if args.useLegacyMarker then
                    self.type = HOUND.Utils.Marker.Type.POINT
                    trigger.action.markToCoalition(self.id, text, pos, coalition,true)
                    return true
                end
                self.type = HOUND.Utils.Marker.Type.TEXT
                -- trigger.action.textToAll(coalition,self.id, pos,lineColor,fillColor,fontSize,true,"¤ « " .. text)
                trigger.action.textToAll(coalition,self.id, pos,lineColor,fillColor,fontSize,true,HOUND.MARKER_TEXT_POINTER .. text)
                return true
            end

            if HOUND.Length(pos) == 2 and HOUND.Utils.Dcs.isPoint(pos.p) and type(pos.r) == "number" then
                self.type = HOUND.Utils.Marker.Type.CIRCLE
                trigger.action.circleToAll(coalition,self.id, pos.p,pos.r,lineColor,fillColor,lineType,true)
                return true
            end

            if HOUND.Length(pos) == 4 then
                self.type = HOUND.Utils.Marker.Type.FREEFORM
                trigger.action.markupToAll(6,coalition,self.id,
                    pos[1], pos[2], pos[3], pos[4],
                    lineColor,fillColor,lineType,true)
            end

            if HOUND.Length(pos) == 8 then
                self.type = HOUND.Utils.Marker.Type.FREEFORM
                trigger.action.markupToAll(7,coalition,self.id,
                    pos[1], pos[2], pos[3], pos[4],
                    pos[5], pos[6], pos[7], pos[8],
                    lineColor,fillColor,lineType,true)
            end

            if HOUND.Length(pos) == 16 then
                self.type = HOUND.Utils.Marker.Type.FREEFORM
                trigger.action.markupToAll(7,coalition,self.id,
                    pos[1], pos[2], pos[3], pos[4],
                    pos[5], pos[6], pos[7], pos[8],
                    pos[9], pos[10], pos[11], pos[12],
                    pos[13], pos[14], pos[15], pos[16],
                    lineColor,fillColor,lineType,true)
            end
        end

        --- replace markpoint (internal)
        -- @within HOUND.Utils.Marker.instance
        -- @local
        -- @param self Hound Marker instance
        -- @param args full args array
        instance._replace = function(self,args)
            self:remove()
            return self:_new(args)
        end

        --- update markpoint
        -- @within HOUND.Utils.Marker.instance
        -- @param self Hound Marker instance
        -- @param args full args array
        instance.update = function(self,args)
            if type(args.coalition) ~= "number" then return false end
            if self.id < 1 then
                return self:_new(args)
            end

            if (self.type ==  HOUND.Utils.Marker.Type.POINT or self.type == HOUND.Utils.Marker.Type.FREEFORM) then
                return self:_replace(args)
            end
            if args.pos then
                local pos = args.pos
                if HOUND.Utils.Dcs.isPoint(pos) then
                    self:setPos(pos)
                end
                if HOUND.Length(pos) == 2 and type(pos.r) == "number" and HOUND.Utils.Dcs.isPoint(pos.p) then
                    self:setPos(pos.p)
                    self:setRadius(pos.r)
                end
                if type(pos) == "table" and HOUND.Length(pos) > 2 and HOUND.Utils.Dcs.isPoint(pos[1]) then
                    return self:_replace(args)
                end
            end
            if args.text and type(args.text) == "string" then
                self:setText(args.text)
            end
            if type(args.fillColor) == "table" then
                self:setFillColor(args.fillColor)
            end
            if type(args.lineColor) == "table" then
                self:setLineColor(args.lineColor)
            end
            if type(args.lineType) == "number" then
                self:setLineType(args.lineType)
            end
        end
        -- actual logic for the class
        if type(args) == "table" then
            instance.update(instance,args)
        end
        return instance
    end


    --- Text Functions
    -- @section Text

    --- convert LL to displayable string
    -- @param lat Latitude in decimal degrees ("32.343","-14.44333")
    -- @param lon Longitude in decimal degrees ("42.343","-144.432")
    -- @param[opt] minDec (bool) if true, function will return LL in DM.M format
    -- @return LL string.
    -- eg. "N33°15'12" E042°10'45"" or "N33°15.200' E042°10.750'"
    function HOUND.Utils.Text.getLL(lat,lon,minDec)
        local hemi = HOUND.Utils.getHemispheres(lat,lon)
        lat = HOUND.Utils.DecToDMS(lat)
        lon = HOUND.Utils.DecToDMS(lon)
        if minDec == true then
            return hemi.NS .. string.format("%02d",l_math.abs(lat.d)) .. "°" .. string.format("%.3f",lat.mDec) .. "'" ..  " " ..  hemi.EW  .. string.format("%03d",l_math.abs(lon.d)) .. "°" .. string.format("%.3f",lon.mDec) .. "'"
        end
        return hemi.NS .. string.format("%02d",l_math.abs(lat.d)) .. "°" .. string.format("%02d",lat.m) .. "'".. string.format("%02d",l_math.floor(lat.s)).."\"" ..  " " ..  hemi.EW  .. string.format("%03d",l_math.abs(lon.d)) .. "°" .. string.format("%02d",lon.m) .. "'".. string.format("%02d",l_math.floor(lon.s)) .."\""
    end

    --- Text Function - returns current DCS time in military time format string
    -- @param[opt] timestamp DCS time in seconds (timer.getAbsTime()) - Optional, if not arg provided will return for current game time
    -- @return time in human radable format e.g. "1430", "0812"
    function HOUND.Utils.Text.getTime(timestamp)
        if timestamp == nil then timestamp = timer.getAbsTime() end
        local DHMS = l_mist.time.getDHMS(timestamp)
        return string.format("%02d",DHMS.h)  .. string.format("%02d",DHMS.m)
    end

    --- Elint functions
    -- @section elint

    --- Elint Function - Generate angular error
    -- @param variance amount of variance in gausian random function
    -- @return table {az,el} error in radians per element

    function HOUND.Utils.Elint.generateAngularError(variance)
        local vec2 = HOUND.Utils.Vector.getRandomVec2(variance)
        local epsilon = {
            az = vec2.x,
            el = vec2.z
        }
        return epsilon
    end

    --- Get Azimuth (and elevation) between two points
    -- @param src position of the source (i.e Hound platform)
    -- @param dst position of the destination (i.e emitting radar)
    -- @param sensorPrecision angular resolution (in rad) of platform against radar
    -- @return[type=number] Azimuth from source to destination in radians (0 to 2*pi)
    -- @return[type=number] Elevation angle from source to destination in radians (-pi to pi)
    -- @return[type=table] the vector betweeb the points
    function HOUND.Utils.Elint.getAzimuth(src, dst, sensorPrecision)
        if not HOUND.Utils.Dcs.isPoint(src) or not HOUND.Utils.Dcs.isPoint(dst) then return end
        local AngularErr = HOUND.Utils.Elint.generateAngularError(sensorPrecision)

        local vec = l_mist.vec.sub(dst, src)
        local az = l_math.atan2(vec.z,vec.x) + AngularErr.az
        if az < 0 then
            az = az + PI_2
        end
        if az > PI_2 then
            az = az - PI_2
        end

        local el = (l_math.atan(vec.y/l_math.sqrt(vec.x^2 + vec.z^2)) + AngularErr.el)


        return az,el,vec
    end

    --- Get Signal strength of point
    -- @param src position of the source (i.e Hound platform)
    -- @param dst position of the destination (i.e emitting radar)
    -- @param maxDetection Maximum detection range of radar in meters
    -- @return[type=number] Signal strength

    function HOUND.Utils.Elint.getSignalStrength(src, dst, maxDetection)
        if not HOUND.Utils.Dcs.isPoint(src) or not HOUND.Utils.Dcs.isPoint(dst) or not (type(maxDetection) == "number" and maxDetection > 0) then return 0 end
        local dist = l_mist.utils.get3DDist(src,dst)
        local rng = (dist/maxDetection)
        return 1/(rng*rng)
    end

    --- Get currently transmitting Ground and Ship radars that are not in the Hound Instance coalition
    -- @param instanceCoalition CoalitionID for current Hound Instance
    -- @return Table of all currently transmitting Ground and Ship radars that are not in the Hound Instance coalition

    function HOUND.Utils.Elint.getActiveRadars(instanceCoalition)
        local Radars = {}
        if instanceCoalition == nil then return Radars end

        for _,coalitionName in pairs(coalition.side) do
            if coalitionName ~= instanceCoalition then
                for _,CategoryId in pairs({Group.Category.GROUND,Group.Category.SHIP}) do
                    for _,group in pairs(coalition.getGroups(coalitionName, CategoryId)) do
                        for _,unit in pairs(group:getUnits()) do
                            if (unit:isExist() and unit:isActive() and unit:getRadar()) then
                                table.insert(Radars, unit:getName()) -- insert the name
                            end
                        end
                    end
                end
            end
        end
        return Radars
    end

    --- Get currently transmitting units in a given groupName
    -- @param GroupName groupName for group
    -- @return Table of all currently transmitting Ground and Ship radars that are not in the Hound Instance coalition
    function HOUND.Utils.Elint.getActiveRadarsInGroup(GroupName)
        local Radars = {}
        if GroupName == nil then return Radars end
        local group = Group.getByName(GroupName)
        if not HOUND.Utils.Dcs.isGroup(group) then return Radars end
        for _,unit in pairs(group:getUnits()) do
            if (unit:isExist() and unit:isActive() and unit:getRadar()) then
                table.insert(Radars, unit:getName()) -- insert the name
            end
        end
        return Radars
    end

    --- Get RWR contacts for platfom
    -- @param platform DCS Unit of platform
    -- @return Table of all currently transmitting Ground and Ship radars that RWR detected by supplied platform
    function HOUND.Utils.Elint.getRwrContacts(platform)
        if not HOUND.Utils.Dcs.isUnit(platform) and not platform:hasSensors(Unit.SensorType.RWR) then return {} end
        local radars = {}
        local platformCoalition = platform:getCoalition()
        local contacts = platform:getController():getDetectedTargets(Controller.Detection.RWR)
        for _,unit in contacts do
            if unit:getCoalition() ~= platformCoalition and unit:getRadar() then
                table.insert(radars,unit:getName())
            end
        end
        return radars
    end

    --- Vector functions
    -- @section Vectors

    --- get UnitVector
    -- @param Theta azimuth in radians
    -- @param[opt] Phi elevation in radians
    -- @return Unit vector {x,y,z}
    function HOUND.Utils.Vector.getUnitVector(Theta,Phi)
        if not Theta then
            return {x=0,y=0,z=0}
        end
        Phi = Phi or 0
        local unitVector = {
                x = l_math.cos(Phi)*l_math.cos(Theta),
                z = l_math.cos(Phi)*l_math.sin(Theta),
                y = l_math.sin(Phi)
            }
        return unitVector
    end

    --- Get random 2D vector
    -- use Box–Muller transform to randomize errors on 2D vector
    -- https://en.wikipedia.org/wiki/Box%E2%80%93Muller_transform}
    -- @param variance amount of variance in gausian random function
    -- @return DCS standard {x,z,y} vector
    function HOUND.Utils.Vector.getRandomVec2(variance)
        if type(variance) ~= 'number' or variance == 0 then return {x=0,y=0,z=0} end
        local stddev = variance / 2
        local Magnitude = l_math.sqrt(-2 * l_math.log(l_math.random())) * stddev
        local Theta = PI_2 * l_math.random()
        local epsilon = HOUND.Utils.Vector.getUnitVector(Theta)
        for axis,value in pairs(epsilon) do
            epsilon[axis] = value * Magnitude
        end
        return epsilon
    end

    --- Get random 3d vector
    -- use Box–Muller transform to randomize errors on 3D vector
    -- https://en.wikipedia.org/wiki/Box%E2%80%93Muller_transform}
    -- @param variance amount of variance in gausian random function
    -- @return DCS standard {x,z,y} vector
    function HOUND.Utils.Vector.getRandomVec3(variance)
        if type(variance) ~= 'number' or variance == 0 then return {x=0,y=0,z=0} end
        local stddev = variance /2
        local Magnitude = l_math.sqrt(-2 * l_math.log(l_math.random())) * stddev
        local Theta = PI_2 * l_math.random()
        local Phi = PI_2 * l_math.random()

        -- from radius and angle you can get the point on the circles
        local epsilon = HOUND.Utils.Vector.getUnitVector(Theta,Phi)
        for axis,value in pairs(epsilon) do
            epsilon[axis] = value * Magnitude
        end
        return epsilon
    end

    --- Zone functions
    -- @section Zone

    --- List all Useable zones from drawings.
    -- (supported types are freeForm Polygon, rectangle and Oval)
    -- @return list of strings
    function HOUND.Utils.Zone.listDrawnZones()
        local zoneNames = {}
        local base = _G.env.mission
        if not base or not base.drawings or not base.drawings.layers then return zoneNames end
        for _,drawLayer in pairs(base.drawings.layers) do
            if type(drawLayer["objects"]) == "table" then
                for _,drawObject in pairs(drawLayer["objects"]) do
                    if drawObject["primitiveType"] == "Polygon" and (HOUND.setContainsValue({"free","rect","oval"},drawObject["polygonMode"])) then
                        table.insert(zoneNames,drawObject["name"])
                    end
                end
            end
        end
        return zoneNames
    end

    --- Get zone from drawing
    -- (supported types are freeForm Polygon, rectangle and Oval)
    -- @param zoneName
    -- @return table of points
    function HOUND.Utils.Zone.getDrawnZone(zoneName)
        if type(zoneName) ~= "string" then return nil end
        if not _G.env.mission.drawings or not _G.env.mission.drawings.layers then return nil end
        for _,drawLayer in pairs(_G.env.mission.drawings.layers) do
            if type(drawLayer["objects"]) == "table" then
                for _,drawObject in pairs(drawLayer["objects"]) do
                    if drawObject["name"] == zoneName and drawObject["primitiveType"] == "Polygon" then
                        local points = {}
                        local theta = nil
                        if drawObject["polygonMode"] == "free" and HOUND.Length(drawObject["points"]) >2 then
                            points = l_mist.utils.deepCopy(drawObject["points"])
                            table.remove(points)
                        end
                        if drawObject["polygonMode"] == "rect" then
                            theta = l_math.rad(drawObject["angle"])
                            local w,h = drawObject["width"],drawObject["height"]


                            table.insert(points,{x=h/2,y=w/2})
                            table.insert(points,{x=-h/2,y=w/2})
                            table.insert(points,{x=-h/2,y=-w/2})
                            table.insert(points,{x=h/2,y=-w/2})
                        end
                        if drawObject["polygonMode"] == "oval" then
                            theta = l_math.rad(drawObject["angle"])
                            local r1,r2 = drawObject["r1"],drawObject["r2"]
                            local numPoints = 16
                            local angleStep = PI_2/numPoints

                            for i = 1, numPoints do
                                local pointAngle = PI_2 - (i * angleStep)
                                local x = r1 * l_math.cos(pointAngle)
                                local y = r2 * l_math.sin(pointAngle)
                                table.insert(points,{x=x,y=y})
                            end
                        end
                        if theta then
                            for _,point in pairs(points) do
                                local x = point.x
                                local y = point.y
                                point.x = x * l_math.cos(theta) - y * l_math.sin(theta)
                                point.y = x * l_math.sin(theta) + y * l_math.cos(theta)
                            end
                        end
                        if HOUND.Length(points) < 3 then return nil end
                        local objectX,objecty = drawObject["mapX"],drawObject["mapY"]
                        for _,point in pairs(points) do
                            point.x = point.x + objectX
                            point.y = point.y + objecty
                        end
                        return points
                    end
                end
            end
        end
        return nil
    end

    --- get polygon defined by group waypoints
    -- @param GroupName
    -- @return table of points if group exists or nil
    function HOUND.Utils.Zone.getGroupRoute(GroupName)
        if type(GroupName) == "string" and HOUND.Utils.Dcs.isGroup(Group.getByName(GroupName)) then
            return HOUND.Utils.Dcs.getGroupPoints(Group.getByName(GroupName):getID())
        end
    end

    --- Sort Functions
    -- @section Sort

    --- Sort contacts by engament range
    -- @param a @{HOUND.Contact.Emitter} instance
    -- @param b @{HOUND.Contact.Emitter} Instance
    -- @return[type=bool]
    -- @usage table.sort(unSorted,HOUND.Utils.Sort.ContactsByRange)
    function HOUND.Utils.Sort.ContactsByRange(a,b)
        if a.isEWR ~= b.isEWR then
          return b.isEWR and not a.isEWR
        end
        if a.maxWeaponsRange ~= b.maxWeaponsRange then
            return a.maxWeaponsRange > b.maxWeaponsRange
        end
        if a.detectionRange ~= b.detectionRange then
            return a.detectionRange > b.detectionRange
        end
        if a.typeAssigned ~= b.typeAssigned then
            return table.concat(a.typeAssigned) < table.concat(b.typeAssigned)
        end
        if a.typeName ~= b.typeName then
            return a.typeName < b.typeName
        end
        if a.first_seen ~= b.first_seen then
            return a.first_seen > b.first_seen
        end
        if getmetatable(a) == HOUND.Contact.Site then
            return a.gid < b.gid
        end
        return a.uid < b.uid
    end

    --- Sort contacts by ID
    -- @param a @{HOUND.Contact.Emitter} instance
    -- @param b @{HOUND.Contact.Emitter} Instance
    -- @return[type=bool]
    -- @usage table.sort(unSorted,HOUND.Utils.Sort.ContactsById)
    function HOUND.Utils.Sort.ContactsById(a,b)
        if  a.uid ~= b.uid then
            return a.uid < b.uid
        end
        return a.maxWeaponsRange > b.maxWeaponsRange
    end

    --- sort contacts by Priority (primary first)
    -- @param a @{HOUND.Contact.Emitter} instance
    -- @param b @{HOUND.Contact.Emitter} Instance
    -- @return[type=bool]
    -- @usage table.sort(unSorted,HOUND.Utils.Sort.ContactsByPrio)
    function HOUND.Utils.Sort.ContactsByPrio(a,b)
        if a.isPrimary ~= b.isPrimary then
            return a.isPrimary and not b.isPrimary
        end
        if a.radarRoles ~= b.radarRoles then
            local aRoles,bRoles = 0,0
            for _,role in pairs(a.radarRoles) do
                aRoles = aRoles + role
            end
            for _,role in pairs(b.radarRoles) do
                bRoles = bRoles + role
            end
            return aRoles > bRoles
        end
        return a.uid < b.uid
    end

    --- sort sectors by priority (low first)
    -- @param a @{HOUND.Sector} instance
    -- @param b @{HOUND.Sector} Instance
    -- @return[type=bool]
    -- @usage table.sort(unSorted,HOUND.Utils.Sort.sectorsByPriorityLowFirst)
    function HOUND.Utils.Sort.sectorsByPriorityLowFirst(a,b)
        return a:getPriority() > b:getPriority()
    end

    --- sort sectors by priority (Low last)
    -- @param a @{HOUND.Sector} instance
    -- @param b @{HOUND.Sector} Instance
    -- @return[type=bool]
    -- @usage table.sort(unSorted,HOUND.Utils.Sort.sectorsByPriorityLowLast)
    function HOUND.Utils.Sort.sectorsByPriorityLowLast(a,b)
        return a:getPriority() < b:getPriority()
    end

    --- Filter Functions
    -- @section Filter

    --- get Groups by prefix
    -- @param prefix string
    -- @return table of DCS groups indexed by group name
    function HOUND.Utils.Filter.groupsByPrefix(prefix)
        if type(prefix) ~= "string" then return {} end
        local groups = {}
        for groupName, _ in pairs(HOUND.Utils.Dcs.getGroupNames(prefix)) do
            local dcsObject = Group.getByName(groupName)
            if HOUND.Utils.Dcs.isGroup(dcsObject) then
                groups[groupName] = dcsObject
            end
        end
        return groups
    end

    --- get Units by prefix
    -- @param prefix string
    -- @return table of DCS Units indexed by Unit name
    function HOUND.Utils.Filter.unitsByPrefix(prefix)
        if type(prefix) ~= "string" then return {} end
        local units = {}
        for unitName, _ in pairs(HOUND.Utils.Dcs.getUnitNames(prefix)) do
            local dcsUnit = Unit.getByName(unitName)
            if HOUND.Utils.Dcs.isUnit(dcsUnit) then
                units[unitName] = dcsUnit
            end
        end
        return units
    end

    --- get StatcObjects by prefix
    -- @param prefix string
    -- @return table of DCS StaticObjects indexed by object name
    function HOUND.Utils.Filter.staticObjectsByPrefix(prefix)
        if type(prefix) ~= "string" then return {} end
        local objects = {}
        for objectName, _ in pairs(HOUND.Utils.Dcs.getStaticObjectNames(prefix)) do
            local dcsObject = StaticObject.getByName(objectName)
            if HOUND.Utils.Dcs.isStaticObject(dcsObject) then
                objects[objectName] = dcsObject
            end
        end
        return objects
    end
end
