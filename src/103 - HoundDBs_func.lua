--- Hound databases (functions)
-- @local
-- @module HOUND.DB
-- @field HOUND.DB
do
    local l_mist = HOUND.Mist
    local l_math = math

    --- DB functions
    -- @section Functions

    --- Get radar object Data
    -- @param typeName DCS Tye name
    -- @return Radar information table
    function HOUND.DB.getRadarData(typeName)
        if not HOUND.DB.Radars[typeName] then return end
        local data = l_mist.utils.deepCopy(HOUND.DB.Radars[typeName])
        data.isEWR = HOUND.setContainsValue(data.Role,HOUND.DB.RadarType.EWR)
        data.Freqency = HOUND.DB.getEmitterFrequencies(data.Band)
        return data
    end

    --- check if canidate Object is a valid platform
    -- @param candidate DCS Object (Unit or Static Object)
    -- @return[type=bool] True if object is valid platform
    function HOUND.DB.isValidPlatform(candidate)
        if (not HOUND.Utils.Dcs.isUnit(candidate) and not HOUND.Utils.Dcs.isStaticObject(candidate)) or not candidate:isExist()
             then return false
        end

        local isValid = false
        local mainCategory = Object.getCategory(candidate)
        local type = candidate:getTypeName()
        if HOUND.setContains(HOUND.DB.Platform,mainCategory) then
            if HOUND.setContains(HOUND.DB.Platform[mainCategory],type) then
                if HOUND.DB.Platform[mainCategory][type]['require'] then
                    local platformData = HOUND.DB.Platform[mainCategory][type]
                    -- TODO: actually make logic here
                    if HOUND.setContains(platformData['require'],'CLSID') then
                        local required = platformData['require']['CLSID']
                        -- then if payload is valid (currently always retuns true)
                        isValid = HOUND.Utils.hasPayload(candidate,required)
                    end
                    if HOUND.setContains(platformData['require'],'TASK') then
                        local required = platformData['require']['TASK']
                        -- check for tasking requirements (for now will always return false)
                        isValid = not HOUND.Utils.hasTask(candidate,required)
                    end
                else
                    isValid = true
                end
            end
        end
        return isValid
    end

    --- Get Platform data
    -- @local
    -- @param DcsObject platform unit
    -- @return platform data
    function HOUND.DB.getPlatformData(DcsObject)
        if not HOUND.Utils.Dcs.isUnit(DcsObject) and not HOUND.Utils.Dcs.isStaticObject(DcsObject) then return end

        local platformData={
            pos = l_mist.utils.deepCopy(DcsObject:getPosition().p),
            isStatic = false,
            isAerial = false,
        }

        local mainCategory, PlatformUnitCategory = DcsObject:getCategory()
        local typeName = DcsObject:getTypeName()
        local DbInfo = HOUND.DB.Platform[mainCategory][typeName]

        local errorDist = DbInfo.ins_error or 0
        platformData.posErr = HOUND.Utils.Vector.getRandomVec2(errorDist)
        platformData.posErr.y = 0
        platformData.ApertureSize = (DbInfo.antenna.size * DbInfo.antenna.factor) or 0

        local VerticalOffset = DbInfo.antenna.size
        local objHitBox = DcsObject:getDesc()["box"]
        if objHitBox then
            VerticalOffset = objHitBox["max"]["y"]
        end
        if mainCategory == Object.Category.STATIC then
            platformData.isStatic = true
            platformData.pos.y = platformData.pos.y + VerticalOffset/2
        else
            -- local PlatformUnitCategory = DcsObject:getCategory()
            if PlatformUnitCategory == Unit.Category.HELICOPTER or PlatformUnitCategory == Unit.Category.AIRPLANE then
                platformData.isAerial = true
            end
            if PlatformUnitCategory == Unit.Category.GROUND_UNIT then
                platformData.pos.y = platformData.pos.y + VerticalOffset
            end
        end
        if not platformData.isAerial then
            platformData.pos.y = platformData.pos.y + VerticalOffset
        end
        return platformData
    end

    --- Get defraction
    -- for band and effective antenna size return angular resolution
    -- @local
    -- @param wavelength Radar transmission band (A-L) as defined in HOUND.DB
    -- @param antenna_size Effective antenna size for platform as defined in HOUND.DB
    -- @return angular resolution in Radians for wavelength and Antenna combo

    function HOUND.DB.getDefraction(wavelength,antenna_size)
        if wavelength == nil or antenna_size == nil or antenna_size == 0 then return l_math.rad(30) end
        return wavelength/antenna_size
    end

    --- get Effective Aperture size for platform
    -- @local
    -- @param DcsObject Unit requested (used as platform)
    -- @return Effective aperture size in meters
    function HOUND.DB.getApertureSize(DcsObject)
        if not HOUND.Utils.Dcs.isUnit(DcsObject) and not HOUND.Utils.Dcs.isStaticObject(DcsObject) then return 0 end
        local mainCategory = Object.getCategory(DcsObject)
        local typeName = DcsObject:getTypeName()
        if HOUND.setContains(HOUND.DB.Platform,mainCategory) then
            if HOUND.setContains(HOUND.DB.Platform[mainCategory],typeName) then
                return HOUND.DB.Platform[mainCategory][typeName].antenna.size * HOUND.DB.Platform[mainCategory][typeName].antenna.factor * HOUND.ANTENNA_FACTOR
            end
        end
        return 0
    end

    --- Get emitter Band
    -- @local
    -- @param DcsUnit Radar unit
    -- @return Char radar band
    function HOUND.DB.getEmitterBand(DcsUnit)
        if not HOUND.Utils.Dcs.isUnit(DcsUnit) then return HOUND.DB.Bands.C end
        local typeName = DcsUnit:getTypeName()
        local _,isTracking = DcsUnit:getRadar()
        if HOUND.setContains(HOUND.DB.Radars,typeName) then
            return HOUND.DB.Radars[typeName].Band[HOUND.Utils.Dcs.isUnit(isTracking)]
        end
        return HOUND.DB.Bands.C
    end

    --- Generate uniqe radar frequencies for contact
    -- @local
    -- @param[type=tab] bands
    -- @param[type=?number] factor between 0 and 1 where between high and low freqs (for testing)
    -- @return table containig wavelengths in meters for the radar
    function HOUND.DB.getEmitterFrequencies(bands,factor)
        local freqFactor = factor or l_math.random()
        return {
            [true] = bands[true][1] + bands[true][2] * freqFactor,
            [false] = bands[false][1] + bands[false][2] * freqFactor
        }
    end

    --- Elint Function - Get sensor precision
    -- @param platform Instance of DCS Unit which is the detecting platform
    -- @param emitterFreq Radar wavelength (frequency) of radar (in meters) or DCS Unit
    -- @return angular resolution in Radians of platform against specific Radar frequency
    function HOUND.DB.getSensorPrecision(platform,emitterFreq)
        local wavelength = emitterFreq
        if HOUND.Utils.Dcs.isUnit(emitterFreq) then
            local _,track = emitterFreq:getRadar()
            wavelength = HOUND.DB.getEmitterFrequencies(HOUND.DB.getEmitterBand(emitterFreq))[HOUND.Utils.Dcs.isUnit(track)]
        end

        return HOUND.DB.getDefraction(wavelength,HOUND.DB.getApertureSize(platform)) or l_math.rad(20.0) -- precision
    end



    --- populate the HOUND.DB.HumanUnits db
    -- @param[type=?number] coalitionId if provided, DB will be updated to specificd coalition only
    function HOUND.DB.updateHumanDb(coalitionId)
        local coalitions = coalition.side
        if type(coalitionId == "number") and (coalitionId >= 0 and coalitionId <= 2) then
            coalitions = { coalitionId }
        end
        for _,coa in pairs(coalitions) do
            local activeCoaPlayers = HOUND.Utils.Dcs.getPlayers(coa)
            for unitName,player in pairs(activeCoaPlayers) do
                if not HOUND.DB.HumanUnits.byName[coa][unitName] then
                    HOUND.DB.HumanUnits.byName[coa][unitName] = HOUND.Mist.utils.deepCopy(player)
                else
                    for k,v in pairs(player) do
                        HOUND.DB.HumanUnits.byName[coa][unitName][k] = player[k]
                    end
                end
                local gid = player.groupId
                if type(HOUND.DB.HumanUnits.byGid[coa][gid]) ~= "table" then
                    HOUND.DB.HumanUnits.byGid[coa][gid] = {}
                end
                HOUND.DB.HumanUnits.byGid[coa][gid][unitName] = HOUND.DB.HumanUnits.byName[coa][unitName]
            end
        end
    end

     --- cleanup the HOUND.DB.HumanUnits db from disconnected units.
    -- @param[type=?number] coalitionId if provided, DB will be updated to specificd coalition only
    function HOUND.DB.cleanHumanDb(coalitionId)
        local coalitions = coalition.side
        if type(coalitionId == "number") and (coalitionId >= 0 and coalitionId <= 2) then
            coalitions = { coalitionId }
        end
        for _,coa in pairs(coalitions) do
            for unitName,player in pairs(HOUND.DB.HumanUnits.byName[coa]) do
                if HOUND.Utils.absTimeDelta(player.lastSeen) > 300 then
                    local gid = player.groupId
                    HOUND.DB.HumanUnits.byName[coa][unitName] = nil
                    HOUND.DB.HumanUnits.byGid[coa][gid][unitName] = nil
                    if length(HOUND.DB.HumanUnits.byGid[coa][gid]) == 0 then
                        HOUND.DB.HumanUnits.byGid[coa][gid] = nil
                    end
                end
            end
        end
    end

    --- create a partial "humanByName" mist record from unit
    -- use subset of mist format https://github.com/mrSkortch/MissionScriptingTools/blob/master/Example%20DBs/mist_DBs_humansByName.lua
    --@param DcsUnit
    --@return table
    function HOUND.DB.generateMistDbEntry(DcsUnit)
        if not HOUND.Utils.Dcs.isUnit(DcsUnit) then return {} end
        -- {
        --     ["type"] = "F-15C",
        --     ["unitId"] = 10,
        --     ["unitName"] = "F-15C Client #2_unit",
        --     ["groupId"] = 5,
        --     ["groupName"] = "F-15C Client #2",
        --     ["callsign"] = {
        --         [1] = 2,
        --         [2] = 1,
        --         [3] = 1,
        --         ["name"] = "Springfield11",
        --     }, -- end of ["callsign"]
        -- }
        local grp = DcsUnit:getGroup()
        local unitCallsign = DcsUnit:getCallsign()
        local parsedCallsign = {unitCallsign:match("([%a]+)(%d+)%-(%d+)")}
        if #parsedCallsign ~= 3 then
            parsedCallsign = {unitCallsign:match("([%a]+)(%d)(%d)")}
        end
        local unitData = {
            type = DcsUnit:getTypeName(),
            unitId = DcsUnit:getID(),
            unitName = DcsUnit:getName(),
            lastSeen = timer:getAbsTime(),
            groupId = grp:getID(),
            groupName = grp:getName(),
            callsign = {
                [1] = parsedCallsign[1],
                [2] = tonumber(parsedCallsign[2]),
                [3] = tonumber(parsedCallsign[3]),
                name = unitCallsign
            }
        }
        return unitData
    end
end