--- HOUND.Logger
-- Hound logging function - Based on VEAF work
-- @local
-- @module HOUND.Logger
do
    local l_env = env

    --- Hound Logger decleration
    HOUND.Logger = {
        level = 3
    }
    HOUND.Logger.__index = HOUND.Logger

    HOUND.Logger.LEVEL = {
        ["error"]=1,
        ["warning"]=2,
        ["info"]=3,
        ["debug"]=4,
        ["trace"]=5,
    }
    -- HOUND.Logger.StopWatch = {
    --     name=nil,
    --     starttime = nil
    -- }
    -- HOUND.Logger.StopWatch.__index = HOUND.Logger.StopWatch

    -- function HOUND.Logger.StopWatch:Start(name)
    --     if not HOUND.DEBUG then return self end
    --     if os == nil then return self end
    --     if name ~= nil and type(name) == "string" then
    --         self.name = name
    --     end
    --     self.starttime=os.clock()
    --     return self
    -- end

    -- function HOUND.Logger.StopWatch:Stop()
    --     if not HOUND.DEBUG then return nil end
    --     if os == nil then return nil end
    --     local stoptime = os.clock()
    --     local str = "[ StopWatch ] "
    --     if self.name ~= nil then
    --         str = str .. self.name .. " - "
    --     end
    --     str = str .. stoptime - self.starttime .." ms"
    --     HOUND.Logger.debug(str)
    -- end

    function HOUND.Logger.setBaseLevel(level)
        if setContainsValue(HOUND.Logger.LEVEL,level) then
            HOUND.Logger.level = level
        end
    end

    function HOUND.Logger.formatText(text, ...)
        if not text then
            return ""
        end
        if type(text) ~= 'string' then
            text = tostring(text)
        else
            if arg and arg.n and arg.n > 0 then
                local pArgs = {}
                for index,value in ipairs(arg) do
                    pArgs[index] = tostring(value)
                end
                text = text:format(unpack(pArgs))
            end
        end
        local fName = nil
        local cLine = nil
        if debug then
            local dInfo = debug.getinfo(3)
            fName = dInfo.name
            cLine = dInfo.currentline
            -- local fsrc = dinfo.short_src
            --local fLine = dInfo.linedefined
        end
        if fName and cLine then
            return fName .. '|' .. cLine .. ': ' .. text
        elseif cLine then
            return cLine .. ': ' .. text
        else
            return ' ' .. text
        end
    end

    function HOUND.Logger.print(level, text)
        -- local texts = HOUND.Logger.splitText(text)
        local texts = {text}
        local levelChar = 'E'
        local logFunction = l_env.error
        if level == HOUND.Logger.LEVEL["warning"] then
            levelChar = 'W'
            logFunction = l_env.warning
        elseif level == HOUND.Logger.LEVEL["info"] then
            levelChar = 'I'
            logFunction = l_env.info
        elseif level == HOUND.Logger.LEVEL["debug"] then
            levelChar = 'D'
            logFunction = l_env.info
        elseif level == HOUND.Logger.LEVEL["trace"] then
            levelChar = 'T'
            logFunction = l_env.info
        end
        for i = 1, #texts do
            if i == 1 then
                logFunction('[Hound](' .. levelChar.. ') - ' .. texts[i])
            else
                logFunction(texts[i])
            end
        end
    end

    function HOUND.Logger.error(text, ...)
        if HOUND.Logger.level >= 1 then
            text = HOUND.Logger.formatText(text, unpack(arg))
            HOUND.Logger.print(1, text)
        end
    end

    function HOUND.Logger.warn(text, ...)
        if HOUND.Logger.level >= 2 then
            text = HOUND.Logger.formatText(text, unpack(arg))
            HOUND.Logger.print(2, text)
        end
    end

    function HOUND.Logger.info(text, ...)
        if HOUND.Logger.level >= 3 then
            text = HOUND.Logger.formatText(text, unpack(arg))
            HOUND.Logger.print(3, text)
        end
    end

    function HOUND.Logger.debug(text, ...)
        if HOUND.Logger.level >= 4 then
            text = HOUND.Logger.formatText(text, unpack(arg))
            HOUND.Logger.print(4, text)
        end
    end

    function HOUND.Logger.trace(text, ...)
        if HOUND.Logger.level >= 5 then
            text = HOUND.Logger.formatText(text, unpack(arg))
            HOUND.Logger.print(5, text)
        end
    end

    if HOUND.DEBUG then
        HOUND.Logger.setBaseLevel(HOUND.Logger.LEVEL.trace)
    end
end
