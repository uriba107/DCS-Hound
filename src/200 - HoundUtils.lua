--- HOUND.Utils
-- This class holds generic function used by all of Hound Components
-- @module HOUND.Utils
do
    local l_mist = mist
    local l_math = math
    local pi_2 = 2*l_math.pi

--- HOUND.Utils decleration
-- @table HOUND.Utils
-- @field Mapping Extrapulation functions
-- @field Geo Geographic functions
-- @field TTS TTS Functions
-- @field Text Text functions
-- @field Elint Elint functions
-- @field Sort Sort funtions
-- @field Filter Filter functions
-- @field ReportId intrnal ATIS numerator
-- @field _MarkId internal markId Counter
-- @field _HoundId internal HoundId counter
    HOUND.Utils = {
        Mapping = {},
        Geo     = {},
        Marker  = {},
        TTS     = {},
        Text    = {},
        Elint   = {},
        Vector  = {},
        Zone    = {},
        Polygon = {},
        Cluster = {},
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
    -- @return Bool True if initial ID was updated
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
        return l_math.pi - l_math.abs(l_math.pi - l_math.abs(rad1-rad2) % pi_2)
    end

    --- return avarage azimuth
    -- @param azimuths a list of azimuths in radians
    -- @return the avarage azimuth of the list provided in radians (between 0 and 2*pi)

    function HOUND.Utils.AzimuthAverage(azimuths)
        -- TODO: fix this function. Circular mean has errors, bad ones..
        if not azimuths or Length(azimuths) == 0 then return nil end

        local sumSin = 0
        local sumCos = 0
        for i=1, Length(azimuths) do
            sumSin = sumSin + l_math.sin(azimuths[i])
            sumCos = sumCos + l_math.cos(azimuths[i])
        end
        return (l_math.atan2(sumSin,sumCos) + pi_2) % pi_2
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
            magVar = l_mist.getNorthCorrection(refPos)
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
        return (l_math.atan2(biasVector.z,biasVector.x) + magVar) % pi_2
    end

    --- returns a random angle
    -- @return random angle in radians between 0 and 2*pi

    function HOUND.Utils.RandomAngle()
        -- actuallu a map
        return l_math.random() * 2 * l_math.pi
    end

    --- return maximum weapon range in the group of DCS Unit
    -- @param DCS_Unit DCS unit - in Hound context unit with emitting radar
    -- @return maximum weapon range in meters of the DCS Group the emitter is part of

    function HOUND.Utils.getSamMaxRange(DCS_Unit)
        local maxRng = 0
        if DCS_Unit ~= nil then
            local units = DCS_Unit:getGroup():getUnits()
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
    -- @param DCS_Unit DCS Unit with radars sensor
    -- @return Unit radar detection range agains airborne targers in meters

    function HOUND.Utils.getRadarDetectionRange(DCS_Unit)
        -- TODO: fix for ships
        local detectionRange = 0
        local unit_sensors = DCS_Unit:getSensors()
        if not unit_sensors then return detectionRange end
        if not setContains(unit_sensors,Unit.SensorType.RADAR) then return detectionRange end
        for _,radar in pairs(unit_sensors[Unit.SensorType.RADAR]) do
            if setContains(radar,"detectionDistanceAir") then
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
            " "
        }
        return response[l_math.max(1,l_math.min(l_math.ceil(timer.getAbsTime() % Length(response)),Length(response)))]
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
    -- @param[opt] flightMember if True. value returned will be the full callsign (i.e "Uzi 1 1" rather then the default "Uzi 1")
    -- @return Formation callsign string
    function HOUND.Utils.getFormationCallsign(player,flightMember)
        local callsign = ""
        if type(player) ~= "table" then return callsign end
        callsign = string.gsub(player.callsign.name,"[%d%s]","") .. " " .. player.callsign[2]
        if flightMember then
            callsign = callsign .. " " .. player.callsign[3]
        end

        local DCS_Unit = Unit.getByName(player.unitName)
        if not DCS_Unit then return string.upper(callsign:match( "^%s*(.-)%s*$" )) end

        local playerName = DCS_Unit:getPlayerName()
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
        return SelectedPool[l_math.random(1, Length(SelectedPool))]
    end

    --- Unit use DMM
    -- @param DCS_Unit DCS Unit or typeName string
    function HOUND.Utils.isDMM(DCS_Unit)
        if not DCS_Unit then return false end
        local typeName = nil
        if type(DCS_Unit) == "string" then
            typeName = DCS_Unit
        end
        if type(DCS_Unit) == "Table" and DCS_Unit.getTypeName then
            typeName = DCS_Unit:getTypeName()
        end
        return setContains(HOUND.DB.useDecMin,typeName)
    end

    --- does unit has payload (placeholder)
    -- @param DCS_Unit DCS unit
    -- @param payloadName Name of payload
    -- @return Bool always true
    function HOUND.Utils.hasPayload(DCS_Unit,payloadName)
        -- TODO: add implementation
        return true
    end

    --- does unit has task (placeholder)
    -- @param DCS_Unit DCS unit
    -- @param taskName Name of task
    -- @return Bool always true
    function HOUND.Utils.hasTask(DCS_Unit,taskName)
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

    --- Geo Function
    -- @section Geo

    --- Return if the is LOS between two DCS points
    -- checks both radar horizon (round earth) and DCS terrain LOS
    -- @param pos0 (DCS pos)
    -- @param pos1 (DCS pos)
    -- @return (bool) true if both units have LOS between them

    function HOUND.Utils.Geo.checkLOS(pos0,pos1)
        if not pos0 or not pos1 then return false end
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

    ---  check if point is DCS point
    -- @param point DCS point candidate
    -- @return Bool True if is valid point
    function HOUND.Utils.Geo.isDcsPoint(point)
        if type(point) ~= "table" then return false end
        return (type(point.x) == "number") and (type(point.z) == "number")
    end

    --- Returns Projected line impact point with Terrain
    -- @param p0 source Postion
    -- @param az Azimuth from Position (radians)
    -- @param el Elevation angle from position (radians)
    -- @return DCS point of intersection with ground
    function HOUND.Utils.Geo.getProjectedIP(p0,az,el)
        if not HOUND.Utils.Geo.isDcsPoint(p0) or type(az) ~= "number" or type(el) ~= "number" then return end
        local maxSlant = HOUND.Utils.Geo.EarthLOS(p0.y)*1.2
        -- local maxSlant = (p0.y/l_math.abs(l_math.sin(el)))+100

        local unitVector = HOUND.Utils.Vector.getUnitVector(az,el)
        return land.getIP(p0, unitVector , maxSlant )
    end

    --- Ensure Inpoint DCS point has Elevation
    -- @local
    -- @param point DCS point
    -- @return Point but with elevation
    function HOUND.Utils.Geo.setPointHeight(point)
        if HOUND.Utils.Geo.isDcsPoint(point) and type(point.y) ~= "number" then
            point.y = land.getHeight({x=point.x,y=point.z})
        end
        return point
    end

    --- Ensure input point or point table all have valid Elevation
    -- @param point DCS point
    -- @return same as input, but with elevation. will return original value if is not DCS point
    function HOUND.Utils.Geo.setHeight(point)
        if type(point) == "table" then
            if HOUND.Utils.Geo.isDcsPoint(point) then
                return HOUND.Utils.Geo.setPointHeight(point)
            end
            for _,pt in pairs(point) do
                pt = HOUND.Utils.Geo.setPointHeight(pt)
            end
        end
        return point
    end

    --- Marker Functions
    -- @section Markers
    HOUND.Utils.Marker._MarkId = 9999
    HOUND.Utils.Marker.Type = {
        NONE = 0,
        POINT = 1,
        CIRCLE = 2,
        FREEFORM = 3
    }

    --- Get next Markpoint Id
    -- @local
    -- return the next available MarkId
    -- @return Next MarkId
    function HOUND.Utils.Marker.getId()
        if HOUND.FORCE_MANAGE_MARKERS then
            HOUND.Utils.Marker._MarkId = HOUND.Utils.Marker._MarkId + 1
        elseif UTILS and UTILS.GetMarkID then
            HOUND.Utils.Marker._MarkId = UTILS.GetMarkID()
        elseif HOUND.MIST_VERSION >= 4.6 or (HOUND.MIST_VERSION == 4.5 and l_mist.build >= 106 ) then
            HOUND.Utils.Marker._MarkId = l_mist.marker.getNextId()
        else
            HOUND.Utils.Marker._MarkId = HOUND.Utils.Marker._MarkId + 1
        end
        return HOUND.Utils.Marker._MarkId
    end

    --- Set New initial marker Id
    -- @local
    -- @param startId Number to start counting from
    -- @return Bool True if initial ID was updated
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
            if HOUND.Utils.Geo.isDcsPoint(pos) then
                trigger.action.setMarkupPositionStart(self.id,pos)
            end
        end

        --- update markpoint text
        -- @within HOUND.Utils.Marker.instance
        -- @param self Hound Marker instance
        -- @param text new text for marker
        instance.setText = function(self,text)
            if type(text) == "string" and self.id > 0 then
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

        --- Check if marpoint is drawn
        -- @within HOUND.Utils.Marker.instance
        -- @param self Hound Marker instance
        -- @return Bool - True if marker is drawn
        instance.isDrawn = function(self)
            return (self.id > 0)
        end

        --- remove markpoint
        -- @within HOUND.Utils.Marker.instance
        -- @param self Hound Marker instance
        instance.remove = function(self)
            if self.id > 0 then
                trigger.action.removeMark(self.id)
                if self.id % 500 == 0 then
                    collectgarbage("collect")
                end
                self.id = -1
                self.type = HOUND.Utils.Marker.Type.NONE
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
            local lineColor = args.lineColor
            local fillColor = args.fillColor
            -- if type(fillColor) ~= "table" or type(lineColor) ~= "table" or type(text) ~= "string" then return false end
            self.id = HOUND.Utils.Marker.getId()

            if HOUND.Utils.Geo.isDcsPoint(pos) then
                self.type = HOUND.Utils.Marker.Type.POINT
                trigger.action.markToCoalition(self.id, text, pos, coalition,true)
                return true
            end

            if Length(pos) == 2 and HOUND.Utils.Geo.isDcsPoint(pos.p) and type(pos.r) == "number" then
                self.type = HOUND.Utils.Marker.Type.CIRCLE
                trigger.action.circleToAll(coalition,self.id, pos.p,pos.r,lineColor,fillColor,2,true)
                return true
            end

            if Length(pos) == 4 then
                self.type = HOUND.Utils.Marker.Type.FREEFORM
                trigger.action.markupToAll(6,coalition,self.id,
                    pos[1], pos[2], pos[3], pos[4],
                    lineColor,fillColor,2,true)

            end
            if Length(pos) == 8 then
                self.type = HOUND.Utils.Marker.Type.FREEFORM
                trigger.action.markupToAll(7,coalition,self.id,
                    pos[1], pos[2], pos[3], pos[4],
                    pos[5], pos[6], pos[7], pos[8],
                    lineColor,fillColor,2,true)
            end
            if Length(pos) == 16 then
                self.type = HOUND.Utils.Marker.Type.FREEFORM
                trigger.action.markupToAll(7,coalition,self.id,
                    pos[1], pos[2], pos[3], pos[4],
                    pos[5], pos[6], pos[7], pos[8],
                    pos[9], pos[10], pos[11], pos[12],
                    pos[13], pos[14], pos[15], pos[16],
                    lineColor,fillColor,2,true)
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
            if self.id < 0 then
                return self:_new(args)
            end
            -- if self.id > 0 and self.type == HOUND.Utils.Marker.Type.FREEFORM then
            if self.id > 0 and self.type ~= HOUND.Utils.Marker.Type.NONE then
                    return self:_replace(args)
            end
            -- Update still does not work in MP for DC 2.7 leaving this for the future :(
            -- if self.id > 0 then
            --     if args.pos then
            --         local pos = args.pos
            --         if HOUND.Utils.Geo.isDcsPoint(pos) then
            --             self:setPos(pos)
            --         end
            --         if Length(pos) == 2 and type(pos.r) == "number" and HOUND.Utils.Geo.isDcsPoint(pos.p) then
            --             self:setPos(pos.p)
            --             self:setRadius(pos.r)
            --         end
            --         if type(pos) == "table" and Length(pos) > 2 and HOUND.Utils.Geo.isDcsPoint(pos[1]) then
            --             return self:_replace(args)
            --         end
            --     end
            --     if args.text and type(args.text) == "string" then
            --         self:setText(args.text)
            --     end
            --     if type(args.fillColor) == "table" then
            --         self:setFillColor(args.fillColor)
            --     end
            --     if type(args.lineColor) == "table" then
            --         self:setLineColor(args.lineColor)
            --     end
            -- end
        end
        -- actual logic for the class
        if type(args) == "table" then
            instance.update(instance,args)
        end
        return instance
    end

    --- TTS Functions
    -- @section TTS

    --- Transmit message using STTS (private)
    -- @param msg The message to transmit
    -- @param coalitionID Coalition to recive transmission
    -- @param args STTS settings in hash table (minimum required is {freq=})
    -- @param[opt] transmitterPos DCS Position point for transmitter
    -- @return STTS.TextToSpeech return value recived from STTS, currently estimated speechTime

    function HOUND.Utils.TTS.Transmit(msg,coalitionID,args,transmitterPos)

        if STTS == nil then return end
        if msg == nil then return end
        if coalitionID == nil then return end

        if args.freq == nil then return end
        args.modulation = args.modulation or "AM"
        args.volume = args.volume or "1.0"
        args.name = args.name or "Hound"
        args.gender = args.gender or "female"
        args.culture = args.culture or "en-US"

        return STTS.TextToSpeech(msg,args.freq,args.modulation,args.volume,args.name,coalitionID,transmitterPos,args.speed,args.gender,args.culture,args.voice,args.googleTTS)
    end

    --- returns current DCS time in military time string for TTS
    -- @param[opt] timestamp DCS time in seconds (timer.getAbsTime()) - if not arg provided will return for current game time
    -- @return timeString e.g. "14 30 local", "08 hundred local"

    function HOUND.Utils.TTS.getTtsTime(timestamp)
        if timestamp == nil then timestamp = timer.getAbsTime() end
        local DHMS = l_mist.time.getDHMS(timestamp)
        local hours = DHMS.h
        local minutes = DHMS.m
        -- local seconds = DHMS.s
        if hours == 0 then
            hours = HOUND.DB.PHONETICS["0"]
        else
            hours = string.format("%02d",hours)
        end

        if minutes == 0 then
            minutes = "hundred"
        else
            minutes = string.format("%02d",minutes)
        end

        return hours .. " " .. minutes .. " Local"
    end

    --- return verbal accuracy description
    -- in 500 meters interval
    -- @param confidenceRadius meters
    -- @return (string) Description of accuracy e.g "Very High","High","Low"...

    function HOUND.Utils.TTS.getVerbalConfidenceLevel(confidenceRadius)
        if confidenceRadius == 0.1 then return "Precise" end

        local score={
            "Very High", -- 500
            "High", -- 1000
            "Medium", -- 1500
            "Low", -- 2000
            "Low", -- 2500
            "Very Low", -- 3000
            "Very Low", -- 3500
            "Very Low", -- 4000
            "Very Low", -- 4500
            "Unactionable", -- 5000
        }
        return score[l_math.min(#score,l_math.max(1,l_math.floor(confidenceRadius/500)+1))]
    end

    --- Get Verbal description of contact age
    -- has multiple "modes of operation"
    -- @param timestamp dcs time in seconds of last time a target was seen
    -- @param[opt] isSimple (bool) switch between output modes. true: "Active", "recent"... False: "3 seconds","5 minutes"
    -- @param[opt] NATO (bool) requires isSimple=true, will return only "Active" or "Awake" as per NATO Lowdown
    -- @return string of time passed based on selected flags.

    function HOUND.Utils.TTS.getVerbalContactAge(timestamp,isSimple,NATO)
        local ageSeconds = HOUND.Utils.absTimeDelta(timestamp,timer.getAbsTime())

        if isSimple then
            if NATO then
                if ageSeconds < 16 then return "Active" end
                if ageSeconds < HOUND.CONTACT_TIMEOUT then return "Down" end
                return "Asleep"
            end
            if ageSeconds < 16 then return "Active" end
            if ageSeconds <= 90 then return "very recent" end
            if ageSeconds <= 180 then return "recent" end
            if ageSeconds <= 300 then return "relevant" end
            return "stale"
        end
        local DHMS = l_mist.time.getDHMS(ageSeconds)
        if ageSeconds < 60 then return tostring(l_math.floor(DHMS.s)) .. " seconds" end
        if ageSeconds < 7200 then return tostring(l_math.floor(DHMS.h)*60+l_math.floor(DHMS.m)) .. " minutes" end
        return tostring(l_math.floor(DHMS.h)) .. " hours, " .. tostring(l_math.floor(DHMS.m)) .. " minutes"
    end

    -- TTS Function - convert Decimal degrees to DMS/DM.M speech string
    -- @param cood (float) input coordinate arg in decimal deg (e.g "32.443232", "-144.3432")
    -- @param[opt] minDec (bool) if true output will return in DM.M else in DMS
    -- @param[opt] padDeg (Bool) if true degrees will be zero padded. (32 -> 032 )
    -- @return TTS ready stings. e.g "32 degrees, 15 mintes, 6 seconds", "32 degrees, 15.100 seconds"

    function HOUND.Utils.TTS.DecToDMS(cood,minDec,padDeg)
        local DMS = HOUND.Utils.DecToDMS(cood)
        local strTab = {
            l_math.abs(DMS.d) .. " degrees",
            string.format("%02d",DMS.m) .. " minutes",
            string.format("%02d",DMS.s) .. " seconds"
        }
        if padDeg == true then
            strTab[1] = string.format("%03d",l_math.abs(DMS.d)) .. " degrees"
        end
        if minDec == true then
            strTab[2] = string.format("%02d",DMS.m)
            strTab[3] = HOUND.Utils.TTS.toPhonetic( "." .. string.format("%03d",DMS.sDec)) .. " minutes"
        end
        -- return degStr .. ", " .. minStr .. ", " .. secStr
        return table.concat(strTab,", ")
    end

    --- convert LL to TTS string
    -- @param lat Latitude in decimal degrees ("32.343","-14.44333")
    -- @param lon Longitude in decimal degrees ("42.343","-144.432")
    -- @param[opt] minDec (bool) if true, function will return LL in DM.M format
    -- @return LL string.
    -- eg. "North, 33 degrees, 15 minutes, 12 seconds, East, 42 degrees, 10 minutes, 45 seconds "

    function HOUND.Utils.TTS.getVerbalLL(lat,lon,minDec)
        minDec = minDec or false
        local hemi = HOUND.Utils.getHemispheres(lat,lon,true)
        return hemi.NS .. ", " .. HOUND.Utils.TTS.DecToDMS(lat,minDec)  ..  ", " .. hemi.EW .. ", " .. HOUND.Utils.TTS.DecToDMS(lon,minDec,true)
    end

    --- Convert string to phonetic text
    -- @param str String to convert
    -- @return string broken up to phonetics
    -- @usage HOUND.Utils.TTS.toPhonetic("B29") will return "Bravo Two Niner"

    function HOUND.Utils.TTS.toPhonetic(str)
        local retval = ""
        str = string.upper(tostring(str))
        for i=1, string.len(str) do
            retval = retval .. HOUND.DB.PHONETICS[string.sub(str, i, i)] .. " "
        end
        return retval:match( "^%s*(.-)%s*$" ) -- return and strip trailing whitespaces
    end

    --- get estimated message read time
    -- returns estimated time in seconds STTS will need to read a message
    -- @param length length of string to estimate (also except the string itself)
    -- @param[opt] speed speed setting for reading them message
    -- @param[opt] isGoogle Bool, if true calculation will be done for GoogleTTS engine
    -- @return estimated message read time in seconds

    function HOUND.Utils.TTS.getReadTime(length,speed,isGoogle)
        -- Assumptions for time calc: 100 Words per min, avarage of 5 letters for english word
        -- so 5 chars * 100wpm = 500 characters per min = 8.3 chars per second
        -- so lengh of msg / 8.3 = number of seconds needed to read it. rounded down to 8 chars per sec
        -- map function:  (x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min
        if length == nil then return nil end
        local maxRateRatio = 3 -- can be chaned to 5 if windows TTSrate is up to 5x not 4x

        speed = speed or 1.0
        isGoogle = isGoogle or false

        local speedFactor = 1.0
        if isGoogle then
            speedFactor = speed
        else
            if speed ~= 0 then
                speedFactor = l_math.abs(speed) * (maxRateRatio - 1) / 10 + 1
            end
            if speed < 0 then
                speedFactor = 1/speedFactor
            end
        end

        local wpm = l_math.ceil(100 * speedFactor)
        local cps = l_math.floor((wpm * 5)/60)

        if type(length) == "string" then
            length = string.len(length)
        end

        return l_math.ceil(length/cps)
    end

    --- simplify distance
    -- @param distanceM Distance in meters to simplify
    -- @return Simplified distance
    -- below 1km function will return number in meters
    -- eg. 140m => 150m, 520m => 500m, 4539m => 4.5km

    function HOUND.Utils.TTS.simplfyDistance(distanceM)
        local distanceUnit = "meters"
        local distance = HOUND.Utils.roundToNearest(distanceM,50) or 0
        if distance >= 1000 then
            distance = string.format("%.1f",tostring(HOUND.Utils.roundToNearest(distanceM,100)/1000))
            distanceUnit = "kilometers"
        end
        return distance .. " " .. distanceUnit
    end

    --- Text Functions
    -- @section Text

    --- convert LL to displayable string
    -- @param lat Latitude in decimal degrees ("32.343","-14.44333")
    -- @param lon Longitude in decimal degrees ("42.343","-144.432")
    -- @param[opt] minDec (bool) if true, function will return LL in DM.M format
    -- @return LL string.
    -- eg. "N33°15'12" E42°10'45"" or  "N33°15.200' E42°10.750'"
    function HOUND.Utils.Text.getLL(lat,lon,minDec)
        local hemi = HOUND.Utils.getHemispheres(lat,lon)
        lat = HOUND.Utils.DecToDMS(lat)
        lon = HOUND.Utils.DecToDMS(lon)
        if minDec == true then
            return hemi.NS .. l_math.abs(lat.d) .. "°" .. string.format("%.3f",lat.mDec) .. "'" ..  " " ..  hemi.EW  .. l_math.abs(lon.d) .. "°" .. string.format("%.3f",lon.mDec) .. "'"
        end
        return hemi.NS .. l_math.abs(lat.d) .. "°" .. string.format("%02d",lat.m) .. "'".. string.format("%02d",l_math.floor(lat.s)).."\"" ..  " " ..  hemi.EW  .. l_math.abs(lon.d) .. "°" .. string.format("%02d",lon.m) .. "'".. string.format("%02d",l_math.floor(lon.s)) .."\""
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
    -- @return Azimuth (radians) from source to destination (0 to 2*pi)
    -- @return elevation angle (radians) from source to destination (-pi to pi)

    function HOUND.Utils.Elint.getAzimuth(src, dst, sensorPrecision)
        -- local pi_2 = 2*l_math.pi
        local AngularErr = HOUND.Utils.Elint.generateAngularError(sensorPrecision)

        local vec = l_mist.vec.sub(dst, src)
        local az = l_math.atan2(vec.z,vec.x) + AngularErr.az
        if az < 0 then
            az = az + pi_2
        end
        if az > pi_2 then
            az = az - pi_2
        end

        local el = (l_math.atan(vec.y/l_math.sqrt(vec.x^2 + vec.z^2)) + AngularErr.el)

        return az,el
    end

    --- Get currently transmitting Ground and Ship radars that are not in the Hound Instance coalition
    -- @param instanceCoalition CoalitionID for current Hound Instance
    -- @return Table of all currently transmitting Ground and Ship radars that are not in the Hound Instance coalition

    function HOUND.Utils.Elint.getActiveRadars(instanceCoalition)
        if instanceCoalition == nil then return end
        local Radars = {}

        for _,coalitionName in pairs(coalition.side) do
            if coalitionName ~= instanceCoalition then
                -- env.info("starting coalition ".. coalitionName)
                for _,CategoryId in pairs({Group.Category.GROUND,Group.Category.SHIP}) do
                    -- env.info("starting categoty ".. CategoryId)
                    for _,group in pairs(coalition.getGroups(coalitionName, CategoryId)) do
                        -- env.info("starting group ".. group:getName())
                        for _,unit in pairs(group:getUnits()) do
                            -- env.info("looking at ".. unit:getName())
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

    --- Get RWR contacts for platfom
    -- @param platform DCS Unit of platform
    -- @return Table of all currently transmitting Ground and Ship radars that RWR detected by supplied platform
    function HOUND.Utils.Elint.getRwrContacts(platform)
        local radars = {}
        local platformCoalition = platform:getCoalition()
        if not platform:hasSensors(Unit.SensorType.RWR) then return radars end
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
        if variance == 0 then return {x=0,y=0,z=0} end
        local stddev = variance /2
        local Magnitude = l_math.sqrt(-2 * l_math.log(l_math.random())) * stddev
        local Theta = pi_2 * l_math.random()
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
        if variance == 0 then return {x=0,y=0,z=0} end
        local stddev = variance /2
        local Magnitude = l_math.sqrt(-2 * l_math.log(l_math.random())) * stddev
        local Theta = pi_2 * l_math.random()
        local Phi = pi_2 * l_math.random()

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
                    if drawObject["primitiveType"] == "Polygon" and (setContainsValue({"free","rect","oval"},drawObject["polygonMode"])) then
                        table.insert(zoneNames,drawObject["name"])
                    end
                end
            end
        end
        return zoneNames
    end

    --- Get zone from drawing\
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
                        if drawObject["polygonMode"] == "free" and Length(drawObject["points"]) >2 then
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
                            local angleStep = pi_2/numPoints

                            for i = 1, numPoints do
                                local pointAngle = i * angleStep
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
                        if Length(points) < 3 then return nil end
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

    --- Polygon functions
    -- @section Polygon

    --- Check if polygon is under threat of SAM
    -- @param polygon Table of point reprasenting a polygon
    -- @param point DCS position (x,z)
    -- @param radius Radius in Meters around point to test
    -- @return Bool True if point is in polygon
    -- @return Bool True if radius around point intersects polygon
    function HOUND.Utils.Polygon.threatOnSector(polygon,point, radius)
        if type(polygon) ~= "table" or Length(polygon) < 3 or not HOUND.Utils.Geo.isDcsPoint(l_mist.utils.makeVec3(polygon[1])) then
            return
        end
        if not HOUND.Utils.Geo.isDcsPoint(point) then
            return
        end
        local inPolygon = l_mist.pointInPolygon(point,polygon)
        local intersectsPolygon = inPolygon

        if radius ~= nil and radius > 0 and l_mist.shape ~= nil then
            -- if mist version in use contains shapesOverlap use it. (4.5.103?)
            local circle={point=point,radius=radius}
            intersectsPolygon = l_mist.shape.insideShape(circle,polygon)
        end
        return inPolygon,intersectsPolygon
    end

    --- Filter out points not in polygon
    -- @param points Points to filter
    -- @param polygon - enclosing polygon to filter by
    -- @return points from original set which are inside polygon.
    function HOUND.Utils.Polygon.filterPointsByPolygon(points,polygon)
        local filteredPoints = {}
        if type(points) ~= "table" or type(polygon) ~= "table" then return filteredPoints end

        for _,point in pairs(points) do
            if l_mist.pointInPolygon(point,polygon) then
                table.insert(filteredPoints,point)
            end
        end
        return filteredPoints
    end

    --- calculate cliping of polygons
    -- <a href="https://rosettacode.org/wiki/Sutherland-Hodgman_polygon_clipping#Lua">Sutherland-Hodgman polygon clipping</a>
    -- @param  subjectPolygon List of points of first polygon
    -- @param  clipPolygon list of points of second polygon
    -- @return List of points of the clipped polygon or nil if not clipping found
    function HOUND.Utils.Polygon.clipPolygons(subjectPolygon, clipPolygon)
        local function inside (p, cp1, cp2)
            return (cp2.x-cp1.x)*(p.z-cp1.z) > (cp2.z-cp1.z)*(p.x-cp1.x)
        end

        local function intersection (cp1, cp2, s, e)
            local dcx, dcz = cp1.x-cp2.x, cp1.z-cp2.z
            local dpx, dpz = s.x-e.x, s.z-e.z
            local n1 = cp1.x*cp2.z - cp1.z*cp2.x
            local n2 = s.x*e.z - s.z*e.x
            local n3 = 1 / (dcx*dpz - dcz*dpx)
            local x = (n1*dpx - n2*dcx) * n3
            local z = (n1*dpz - n2*dcz) * n3
            return {x=x, z=z}
        end

        if type(subjectPolygon) ~= "table" or type(clipPolygon) ~= "table" then return end

        local outputList = subjectPolygon
        local cp1 = clipPolygon[#clipPolygon]
        for _, cp2 in ipairs(clipPolygon) do  -- WP clipEdge is cp1,cp2 here
        local inputList = outputList
        outputList = {}
        local s = inputList[#inputList]
        for _, e in ipairs(inputList) do
            if inside(e, cp1, cp2) then
            if not inside(s, cp1, cp2) then
                outputList[#outputList+1] = intersection(cp1, cp2, s, e)
            end
            outputList[#outputList+1] = e
            elseif inside(s, cp1, cp2) then
            outputList[#outputList+1] = intersection(cp1, cp2, s, e)
            end
            s = e
        end
        cp1 = cp2
        end
        if Length(outputList) > 0 then
            return outputList
        end
        return nil
    end

    --- Gift wrapping algorithem
    -- Returns the convex hull (using <a href="http://en.wikipedia.org/wiki/Gift_wrapping_algorithm">Jarvis' Gift wrapping algorithm</a>).
    -- @param points array of DCS points ({x=&ltvalue&gt,z=&ltvalue&gt})
    -- @return the convex hull as an array of points
    function HOUND.Utils.Polygon.giftWrap(points)
        -- Calculates the signed area
        local function signedArea(p, q, r)
            local cross = (q.z - p.z) * (r.x - q.x)
                        - (q.x - p.x) * (r.z - q.z)
            return cross
        end
        -- Checks if points p, q, r are oriented counter-clockwise
        local function isCCW(p, q, r) return signedArea(p, q, r) < 0 end

        -- We need at least 3 points
        local numPoints = #points
        if numPoints < 3 then
            return
        end

        -- Find the left-most point
        local leftMostPointIndex = 1
        for i = 1, numPoints do
            if points[i].x < points[leftMostPointIndex].x then
                leftMostPointIndex = i
            end
        end

        local p = leftMostPointIndex
        local hull = {} -- The convex hull to be returned

        -- Process CCW from the left-most point to the start point
        repeat
            -- Find the next point q such that (p, i, q) is CCW for all i
            local q = points[p + 1] and p + 1 or 1
            for i = 1, numPoints, 1 do
                if isCCW(points[p], points[i], points[q]) then q = i end
            end

            table.insert(hull, points[q]) -- Save q to the hull
            p = q  -- p is now q for the next iteration
        until (p == leftMostPointIndex)

        return hull
    end

    --- calculate Smallest circle around point cloud
    -- Welzel algorithm for <a href="https://en.wikipedia.org/wiki/Smallest-circle_problem">Smallest-circle problem</a>
    -- Implementation taken from <a href="https://github.com/rowanwins/smallest-enclosing-circle/blob/master/src/main.js">github/rowins</a>
    -- @param points Table containing cloud points
    -- @return Circle {x=&ltCenter X&gt,z=&ltCenter Z&gt, y=&ltLand height at XZ&gt,r=&ltradius in meters&gt}
    function HOUND.Utils.Polygon.circumcirclePoints(points)
        local function calcCircle(p1,p2,p3)
            local cx,cz, r
            if HOUND.Utils.Geo.isDcsPoint(p1) and not p2 and not p3 then
                return {x = p1.x, z = p1.z,r = 0}
            end
            if HOUND.Utils.Geo.isDcsPoint(p1) and HOUND.Utils.Geo.isDcsPoint(p2) and not p3 then
                cx = 0.5 * (p1.x + p2.x)
                cz = 0.5 * (p1.z + p2.z)
            else
                local a = p2.x - p1.x
                local b = p2.z - p1.z
                local c = p3.x - p1.x
                local d = p3.z - p1.z
                local e = a * (p2.x + p1.x) * 0.5 + b * (p2.z + p1.z) * 0.5
                local f = c * (p3.x + p1.x) * 0.5 + d * (p3.z + p1.z) * 0.5
                local det = a * d - b * c

                cx = (d * e - b * f) / det
                cz = (-c * e + a * f) / det
            end

            r = l_math.sqrt((p1.x - cx) * (p1.x - cx) + (p1.z - cz) * (p1.z - cz))
            -- env.info("x: " .. cx .. ", z: " .. cz.. ", r: " .. r)
            return {x=cx,z=cz,r=r}
        end

        local function isInCircle(p,c)
            return ((c.x - p.x) * (c.x - p.x) + (c.z - p.z) * (c.z - p.z) <= c.r * c.r)
        end

        local function shuffle(a)
            for i = #a, 2, -1 do
                local j = l_math.random(i)
                a[i], a[j] = a[j], a[i]
            end
            return a
        end

        local function mec(pts,n,boundary,b)
            local circle
            if b == 3 then
                circle = calcCircle(boundary[1],boundary[2],boundary[3])
            elseif (n == 1) and (b == 0) then circle = calcCircle(pts[1])
            elseif (n == 0) and (b == 2) then circle = calcCircle(boundary[1], boundary[2])
            elseif (n == 1) and (b == 1) then circle = calcCircle(boundary[1], pts[1])
            else
                circle = mec(pts, n-1, boundary, #boundary)
                if ( not isInCircle(pts[n], circle)) then
                    boundary[b+1] = pts[n]
                    circle = mec(pts, n-1, boundary, #boundary)
                end
            end
            return circle
        end

        local clonedPoints = l_mist.utils.deepCopy(points)
        shuffle(clonedPoints)
        return mec(clonedPoints, #points, {}, 0)
    end

    --- return the area of a convex polygon
    -- @param polygon list of DCS points
    -- @return area of polygon
    function HOUND.Utils.Polygon.getArea(polygon)
        if not polygon or type(polygon) ~= "table" or Length(polygon) < 2 then return 0 end
        local a,b = 0,0
        for i=1,Length(polygon)-1 do
            a = a + polygon[i].x * polygon[i+1].z
            b = b + polygon[i].z * polygon[i+1].x
        end
        a = a + polygon[Length(polygon)].x * polygon[1].z
        b = b + polygon[Length(polygon)].z * polygon[1].x
        return l_math.abs((a-b)/2)
    end

    --- clip or hull two polygons
    -- @param polyA polygon
    -- @param polyB polygon
    -- @return Polygon which is clip or convexHull of the two input polygons
    function HOUND.Utils.Polygon.clipOrHull(polyA,polyB)
        -- make sure polyA is always the larger one
        if HOUND.Utils.Polygon.getArea(polyA) < HOUND.Utils.Polygon.getArea(polyB) then
            polyA,polyB = polyB,polyA
        end
        local polygon = HOUND.Utils.Polygon.clipPolygons(polyA,polyB)
        if Polygon == nil then
            local points = l_mist.utils.deepCopy(polyA)
            for _,point in pairs(polyB) do
                table.insert(points,l_mist.utils.deepCopy(point))
            end
            polygon = HOUND.Utils.Polygon.giftWrap(points)
        end
        return polygon
    end

    --- find min/max azimuth
    -- @param poly Polygon
    -- @param refPos DCS point to calculate from
    -- @return deltaMinMax delta angle between the two extream points
    -- @return minAz (rad)
    -- @return maxAz (rad)
    function HOUND.Utils.Polygon.azMinMax(poly,refPos)
        if not HOUND.Utils.Geo.isDcsPoint(refPos) or type(poly) ~= "table" or Length(poly) < 2 or l_mist.pointInPolygon(refPos,poly) then
            return
        end

        local points = l_mist.utils.deepCopy(poly)
        for _,pt in pairs(points) do
            pt.refAz = l_mist.utils.getDir(l_mist.vec.sub(pt,refPos))
        end

        table.sort(points,function (a,b) return (a.refAz+pi_2) < (b.refAz+pi_2) end)
        local leftMost = table.remove(points,1)
        local rightMost = table.remove(points)
        return HOUND.Utils.angleDeltaRad(leftMost.refAz,rightMost.refAz),(leftMost),(rightMost)
    end
    --- Clustering algorithems (for future use)
    -- @section Clusters

    --- Get gaussian weight
    -- @param value input to evaluate
    -- @param bandwidth Standard diviation for weight calculation
    function HOUND.Utils.Cluster.gaussianKernel(value,bandwidth)
        return (1/(bandwidth*l_math.sqrt(2*l_math.pi))) * l_math.exp(-0.5*((value / bandwidth))^2)
    end

    --- Calculate running std dev
    -- @return std calc instance
    -- https://en.wikipedia.org/wiki/Algorithms_for_calculating_variance#Welford's_online_algorithm
    function HOUND.Utils.Cluster.stdDev()
        local instance = {}
        instance.count = 0
        instance.mean = 0
        instance.M2 = 0
        instance.update = function(self,value)
            self.count = self.count + 1
            local delta = value - self.mean
            self.mean = self.mean + (delta / self.count)
            local delta2 = value - self.mean
            self.M2 = self.M2 + (delta * delta2)
        end
        instance.get = function (self)
            if self.count < 2 then return nil end
            return {
                mean = self.mean,
                variance = (self.M2/self.count),
                sampleVariance = (self.M2/(self.count-1))
            }
        end
        return instance
    end

    --- find the weighted mean of a points cluster (meanShift)
    -- @param origPoints DCS points cluster
    -- @param[opt] initPos externally provided initial mean (DCS Point)
    -- @param[opt] threashold distance in meters below with solution is considered converged (default 1m)
    -- @param[opt] maxIttr Max itterations from converging solution (default 100)
    -- @return DCS point of the cluster weighted mean

    function HOUND.Utils.Cluster.weightedMean(origPoints,initPos,threashold,maxIttr)
        if type(origPoints) ~= "table" or not HOUND.Utils.Geo.isDcsPoint(origPoints[1]) then return end
        local points = HOUND.Utils.Geo.setHeight(l_mist.utils.deepCopy(origPoints))

        local current_mean = initPos
        if type(current_mean) == "boolean" and current_mean then
            current_mean = points[l_math.random(Length(points))]
        end
        if not HOUND.Utils.Geo.isDcsPoint(current_mean) then
            current_mean = l_mist.getAvgPoint(origPoints)
        end
        if not HOUND.Utils.Geo.isDcsPoint(current_mean) then return end
        threashold = threashold or 1
        maxIttr = maxIttr or 100
        local last_mean
        local ittr = 0
        local converged = false

        while not converged do
            last_mean = l_mist.utils.deepCopy(current_mean)
            local totalDist = 0
            local totalInvWeight = 0
            -- calculate dists
            for _,point in pairs(points) do
                point.dist = l_mist.utils.get2DDist(last_mean,point)
                totalDist = totalDist + point.dist
            end
            -- table.sort(points,function (a,b) return a.dist < b.dist end )
            for _,point in pairs(points) do
                point.w = 1/(point.dist/totalDist)
                totalInvWeight = totalInvWeight + point.w
            end

            for _,point in pairs(points) do
                local weight = point.w/totalInvWeight
                current_mean = l_mist.vec.add(current_mean,l_mist.vec.scalar_mult(l_mist.vec.sub(point,current_mean),weight))
            end
            ittr = ittr + 1
            converged = l_mist.utils.get2DDist(last_mean,current_mean) < threashold or ittr == maxIttr
        end
        HOUND.Utils.Geo.setHeight(current_mean)
        return l_mist.utils.deepCopy(current_mean)
    end

    --- K-means++ algorithm
    -- <a href=https://rosettacode.org/wiki/K-means%2B%2B_clustering#Lua>Source of implementation</a>
    -- @param data Datapoints
    -- @param nclusters Number of clusters to create
    -- @param init Initilization method. Valid values are ["kmeans++","random"]
    -- @return centers (table)
    -- @return cluster (table)
    -- @return J loss value
    function HOUND.Utils.Cluster.kmeans(data, nclusters, init)
        -- K-means Clustering
        --
        assert(nclusters > 0)
        assert(#data > nclusters)
        assert(init == "kmeans++" or init == "random")

        local diss = function(p, q)
          -- Computes the dissimilarity between points 'p' and 'q'
          return math.pow(p.x - q.x, 2) + math.pow(p.z - q.z, 2)
        end

        -- Initialization

        local centers = {} -- clusters centroids
        if init == "kmeans++" then
          local K = 1

          -- take one center c1, chosen uniformly at random from 'data'
          local i = math.random(1, #data)
          centers[K] = {x = data[i].x, z = data[i].z}
          local D = {}

          -- repeat until we have taken 'nclusters' centers
          while K < nclusters do
            -- take a new center ck, choosing a point 'i' of 'data' with probability
            -- D(i)^2 / sum_{i=1}^n D(i)^2

            local sum_D = 0.0
            for i = 1,#data do
              local min_d = D[i]
              local d = diss(data[i], centers[K])
              if min_d == nil or d < min_d then
                  min_d = d
              end
              D[i] = min_d
              sum_D = sum_D + min_d
            end

            sum_D = math.random() * sum_D
            for i = 1,#data do
              sum_D = sum_D - D[i]

              if sum_D <= 0 then
                K = K + 1
                centers[K] = {x = data[i].x, z = data[i].z}
                break
              end
            end
          end
        elseif init == "random" then
          for k = 1,nclusters do
            local i = math.random(1, #data)
            centers[k] = {x = data[i].x, z = data[i].z}
          end
        end

        -- Lloyd K-means Clustering
        --
        local cluster = {} -- k-partition
        for i = 1,#data do cluster[i] = 0 end

        local J = function()
          -- Computes the loss value
          --
          local loss = 0.0
          for i = 1,#data do
            loss = loss + diss(data[i], centers[cluster[i]])
          end
          return loss
        end

        local updated = false
        repeat
          -- update k-partition
          --
          local card = {}
          for k = 1,nclusters do
            card[k] = 0.0
          end

          updated = false
          for i = 1,#data do
            local min_d, min_k = nil, nil

            for k = 1,nclusters do
              local d = diss(data[i], centers[k])

              if min_d == nil or d < min_d then
                min_d, min_k = d, k
              end
            end

            if min_k ~= cluster[i] then updated = true end

            cluster[i]  = min_k
            card[min_k] = card[min_k] + 1.0
          end
          -- print("update k-partition: ", J())

          -- update centers
          --
          for k = 1,nclusters do
            centers[k].x = 0.0
            centers[k].z = 0.0
          end

          for i = 1,#data do
            local k = cluster[i]

            centers[k].x = centers[k].x + (data[i].x / card[k])
            centers[k].z = centers[k].z + (data[i].z / card[k])
          end
          -- print("    update centers: ", J())
        until updated == false
        HOUND.Utils.Geo.setHeight(centers)
        return centers, cluster, J()
      end

    --- convert contacts to centroieds for meanShift
    -- @param contacts list of HOUND.Contact instances to evaluate
    -- @return list of centrods where centroid = {p=&ltDCS pos&gt,r=&ltradius&gt,members={&ltHOUND.Contact&gt}}
    -- function HOUND.Utils.Cluster.getCentroids(contacts)
    --     local centroids = {}
    --     -- populate centroids with all emitters
    --     for _,contact in ipairs(contacts) do
    --         local centroid = {
    --             p = contact.pos.p,
    --             r = contact.uncertenty_radius.r,
    --             members = {}
    --         }
    --         table.insert(centroid.members,contact)
    --         table.insert(centroids,centroid)
    --     end
    --     return centroids
    -- end

    --- Mean-shift algorithem to group radars to sites
    -- http://www.chioka.in/meanshift-algorithm-for-the-rest-of-us-python/
    -- @param contacts list of HOUND.Contact instances to cluster
    -- @param[opt] iterations maximum nuber of itteratoins to run
    -- @return List of centroieds {p=&ltDCS position&gt,r=&ltuncertenty radius&gt,members={&ltlist of HOUND.Contacts&gt}}
    -- function HOUND.Utils.Cluster.meanShift(contacts,iterations)
    --     local kernel_bandwidth = 1000

    --     -- Helper functions
    --     local function gaussianKernel(distance,bandwidth)
    --         return (1/(bandwidth*l_math.sqrt(2*l_math.pi))) * l_math.exp(-0.5*((distance / bandwidth))^2)
    --     end

    --     local function findNeighbours(centroids,centroid,distance)
    --         if distance == nil then distance = centroid.r or kernel_bandwidth end
    --         local eligable = {}
    --         for _,candidate in ipairs(centroids) do
    --             local dist = l_mist.utils.get2DDist(candidate.p,centroid.p)
    --             if dist <= distance then
    --                 table.insert(eligable,candidate)
    --             end
    --         end
    --         return eligable
    --     end

    --     local function compareCentroids(item1,item2)
    --         if item1.p.x ~= item2.p.x or item1.p.z ~= item2.p.z or item1.r ~= item2.r then return false end
    --         if Length(item1.members) ~= Length(item2.members) then return false end
    --         return true
    --     end

    --     local function compareCentroidLists(t1,t2)
    --         if Length(t1) ~= Length(t2) then return false end
    --         for _,item1 in ipairs(t1) do
    --             for _,item2 in ipairs(t2) do
    --                 if not compareCentroids(item1,item2) then return false end
    --             end
    --         end
    --         return true
    --     end

    --     local function insertUniq(t,candidate)
    --         if type(t) ~= "table" or not candidate then return end
    --         for _,item in ipairs(t) do
    --             if not compareCentroids(item,candidate) then return end
    --         end
    --         env.info("Adding uniq: " .. candidate.p.x .. "/" .. candidate.p.z ..  " r=".. candidate.r .. " with " .. Length(candidate.members) .. " members")
    --         table.insert(t,candidate)
    --     end

    --     -- Function starts here
    --     local centroids = {}
    --     -- populate centroids with all emitters
    --     for _,contact in ipairs(contacts) do
    --         local centroid = {
    --             p = contact.pos.p,
    --             r = l_math.min(contact.uncertenty_radius.r,kernel_bandwidth),
    --             members = {}
    --         }
    --         table.insert(centroid.members,contact)
    --         table.insert(centroids,centroid)
    --     end

    --     local past_centroieds = {}
    --     local converged = false
    --     local itr = 1
    --     while not converged do
    --         env.info("itteration " .. itr .. " starting with " .. Length(centroids) .. " centroids")
    --         local new_centroids = {}
    --         for _,centroid in ipairs(centroids) do
    --             local neighbours = findNeighbours(centroids,centroid)
    --             local num_z = 0
    --             local num_x = 0
    --             local num_r = 0
    --             local denominator = 0
    --             local new_members = {}
    --             for _,neighbour in ipairs(neighbours) do
    --                 local dist = l_mist.utils.get2DDist(neighbour.p,centroid.p)
    --                 local weight = gaussianKernel(dist,centroid.r)
    --                 num_z = num_z + (neighbour.p.z * weight)
    --                 num_x = num_x + (neighbour.p.x * weight)
    --                 num_r = num_r + (neighbour.r * weight)
    --                 denominator = denominator + weight
    --                 for _,memeber in ipairs(neighbour.members) do
    --                     table.insert(new_members,memeber)
    --                 end
    --             end
    --             local new_centroid = l_mist.utils.deepCopy(centroid)
    --             new_centroid.p.x = num_x/denominator
    --             new_centroid.p.z = num_z/denominator
    --             new_centroid.r = num_r/denominator
    --             new_centroid.members = new_members
    --             insertUniq(new_centroids,new_centroid)
    --         end
    --         past_centroieds = centroids
    --         centroids = new_centroids
    --         itr = itr + 1
    --         converged = (compareCentroidLists(centroids,past_centroieds) or (iterations ~= nil and iterations <= itr))
    --     end
    --     env.info("meanShift() converged")
    --     return centroids
    -- end

    --- Sort Functions
    -- @section Sort

    --- Sort contacts by engament range
    -- @param a @{HOUND.Contact} instance
    -- @param b @{HOUND.Contact} Instance
    -- @return Bool
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
        return a.uid < b.uid
    end

    --- Sort contacts by ID
    -- @param a @{HOUND.Contact} instance
    -- @param b @{HOUND.Contact} Instance
    -- @return Bool
    -- @usage table.sort(unSorted,HOUND.Utils.Sort.ContactsById)
    function HOUND.Utils.Sort.ContactsById(a,b)
        if  a.uid ~= b.uid then
            return a.uid < b.uid
        end
        return a.maxWeaponsRange > b.maxWeaponsRange
    end

    --- sort sectors by priority (low first)
    -- @param a @{HOUND.Sector} instance
    -- @param b @{HOUND.Sector} Instance
    -- @return Bool
    -- @usage table.sort(unSorted,HOUND.Utils.Sort.sectorsByPriorityLowFirst)
    function HOUND.Utils.Sort.sectorsByPriorityLowFirst(a,b)
        return a:getPriority() > b:getPriority()
    end

    --- sort sectors by priority (Low last)
    -- @param a @{HOUND.Sector} instance
    -- @param b @{HOUND.Sector} Instance
    -- @return Bool
    -- @usage table.sort(unSorted,HOUND.Utils.Sort.sectorsByPriorityLowLast)
    function HOUND.Utils.Sort.sectorsByPriorityLowLast(a,b)
        return a:getPriority() < b:getPriority()
    end

    --- Filter Functions
    -- @section Filter

    --- get Groups by prefix
    -- Implementation taken from Skynet-IADS
    -- @param prefix string
    -- @return table of DCS groups indexed by group name
    function HOUND.Utils.Filter.groupsByPrefix(prefix)
        if type(prefix) ~= "string" then return {} end
        local groups = {}
        for groupName, groupData in pairs(l_mist.DBs.groupsByName) do
            local pos = string.find(groupName, prefix, 1, true)
            if pos and pos == 1 then
                --mist returns groups, units and, StaticObjects
                local dcsObject = Group.getByName(groupName)
                if dcsObject then
                    groups[groupName] = dcsObject
                end
            end
        end
        return groups
    end

    --- get Units by prefix
    -- Implementation taken from Skynet-IADS
    -- @param prefix string
    -- @return table of DCS Units indexed by Unit name
    function HOUND.Utils.Filter.unitsByPrefix(prefix)
        if type(prefix) ~= "string" then return {} end
        local units = {}
        for unitName, unit in pairs(l_mist.DBs.unitsByName) do
            local pos = string.find(unitName, prefix, 1, true)
            --somehow the MIST unit db contains StaticObject, we check to see we only add Units
            local dcsUnit = Unit.getByName(unitName)
            if pos and pos == 1 and dcsUnit then
                units[unitName] = dcsUnit
            end
        end
        return units
    end

    --- get StatcObjects by prefix
    -- Implementation taken from Skynet-IADS
    -- @param prefix string
    -- @return table of DCS StaticObjects indexed by object name
    function HOUND.Utils.Filter.staticObjectsByPrefix(prefix)
        if type(prefix) ~= "string" then return {} end
        local objects = {}
        for objectName, unit in pairs(l_mist.DBs.unitsByName) do
            local pos = string.find(objectName, prefix, 1, true)
            --somehow the MIST unit db contains StaticObject, we check to see we only add Units
            local dcsObject = StaticObject.getByName(objectName)
            if pos and pos == 1 and dcsObject then
                objects[objectName] = dcsObject
            end
        end
        return objects
    end
end
