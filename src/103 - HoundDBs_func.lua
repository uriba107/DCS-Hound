--- Hound databases (functions)
-- @local
-- @module HOUND.DB
-- @field HOUND.DB
do
    local l_mist = mist
    local l_math = math

    --- DB functions
    -- @section Functions

    --- Get radar object Data
    -- @param typeName DCS Tye name
    -- @return Radar information table
    function HOUND.DB.getRadarData(typeName)
        if not HOUND.DB.Radars[typeName] then return end
        local data = l_mist.utils.deepCopy(HOUND.DB.Radars[typeName])
        data.isEWR = setContainsValue(data.Role,"EWR")
        return data
    end

    --- check if canidate Object is a valid platform
    -- @param candidate DCS Object (Unit or Static Object)
    -- @return Bool. True if object is valid platform
    function HOUND.DB.isValidPlatform(candidate)
        if type(candidate) ~= "table" or type(candidate.isExist) ~= "function" or not candidate:isExist()
             then return false
        end

        local isValid = false
        local mainCategory = Object.getCategory(candidate)
        local type = candidate:getTypeName()
        if setContains(HOUND.DB.Platform,mainCategory) then
            if setContains(HOUND.DB.Platform[mainCategory],type) then
                if HOUND.DB.Platform[mainCategory][type]['require'] then
                    local platformData = HOUND.DB.Platform[mainCategory][type]
                    -- TODO: actually make logic here
                    if setContains(platformData['require'],'CLSID') then
                        local required = platformData['require']['CLSID']
                        -- then if payload is valid (currently always retuns true)
                        isValid = HOUND.Utils.hasPayload(candidate,required)
                    end
                    if setContains(platformData['require'],'TASK') then
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
    -- @param DCS_Unit platform unit
    -- @return platform data
    function HOUND.DB.getPlatformData(DCS_Unit)
        if type(DCS_Unit) ~= "table" or not DCS_Unit.getTypeName or not DCS_Unit.getCategory then return end
        -- if not HOUND.DB.isValidPlatform(DCS_Unit) then return end

        local platformData={
            pos = l_mist.utils.deepCopy(DCS_Unit:getPosition().p),
            isStatic = false,
            isAerial = false,
        }

        local mainCategory = Object.getCategory(DCS_Unit)
        local typeName = DCS_Unit:getTypeName()
        local DbInfo = HOUND.DB.Platform[mainCategory][typeName]

        local errorDist = DbInfo.ins_error or 0
        platformData.posErr = HOUND.Utils.Vector.getRandomVec2(errorDist)
        platformData.posErr.y = 0
        platformData.ApertureSize = (DbInfo.antenna.size * DbInfo.antenna.factor) or 0

        if Object.getCategory(DCS_Unit) == Object.Category.STATIC then
            platformData.isStatic = true
            -- platformData.pos.y = platformData.pos.y + DCS_Unit:getDesc()["box"]["max"]["y"]
        else
            local PlatformUnitCategory = DCS_Unit:getDesc()["category"]
            if PlatformUnitCategory == Unit.Category.HELICOPTER or PlatformUnitCategory == Unit.Category.AIRPLANE then
                platformData.isAerial = true
            end
            -- if PlatformUnitCategory == Unit.Category.GROUND_UNIT then
            --     platformData.pos.y = platformData.pos.y + DCS_Unit:getDesc()["box"]["max"]["y"]
            -- end
        end
        if not platformData.isAerial then
            platformData.pos.y = platformData.pos.y + DCS_Unit:getDesc()["box"]["max"]["y"]
        end
        return platformData
    end

    --- Get defraction
    -- for band and effective antenna size return angular resolution
    -- @local
    -- @param band Radar transmission band (A-L) as defined in HOUND.DB
    -- @param antenna_size Effective antenna size for platform as defined in HOUND.DB
    -- @return angular resolution in Radians for Band Antenna combo

    function HOUND.DB.getDefraction(band,antenna_size)
        if band == nil or antenna_size == nil or antenna_size == 0 then return l_math.rad(30) end
        return HOUND.DB.Bands[band]/antenna_size
    end

    --- get Effective Aperture size for unit
    -- @local
    -- @param DCS_Unit Unit requested (used as platform)
    -- @return Effective aperture size in meters
    function HOUND.DB.getApertureSize(DCS_Unit)
        if type(DCS_Unit) ~= "table" or not DCS_Unit.getTypeName or not DCS_Unit.getCategory then return 0 end
        local mainCategory = Object.getCategory(DCS_Unit)
        local typeName = DCS_Unit:getTypeName()
        if setContains(HOUND.DB.Platform,mainCategory) then
            if setContains(HOUND.DB.Platform[mainCategory],typeName) then
                return HOUND.DB.Platform[mainCategory][typeName].antenna.size *  HOUND.DB.Platform[mainCategory][typeName].antenna.factor
            end
        end
        return 0
    end

    --- Get emitter Band
    -- @local
    -- @param DCS_Unit Radar unit
    -- @return Char radar band
    function HOUND.DB.getEmitterBand(DCS_Unit)
        if type(DCS_Unit) ~= "table" or not DCS_Unit.getTypeName then return 'C' end
        local typeName = DCS_Unit:getTypeName()
        if setContains(HOUND.DB.Radars,typeName) then
            return HOUND.DB.Radars[typeName].Band
        end
        return 'C'
    end

    --- Elint Function - Get sensor precision
    -- @param platform Instance of DCS Unit which is the detecting platform
    -- @param emitterBand Radar Band (frequency) of radar (A-L)
    -- @return angular resolution in Radians of platform against specific Radar frequency
    function HOUND.DB.getSensorPrecision(platform,emitterBand)
        return HOUND.DB.getDefraction(emitterBand,HOUND.DB.getApertureSize(platform)) or l_math.rad(20.0) -- precision
    end
end