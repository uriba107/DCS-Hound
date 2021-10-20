--- HoundLogger
-- Hound logging function - Based on VEAF work
-- @local
-- @module HoundLogger
do
    local l_env = env

    --- Hound Logger decleration
    HoundLogger = {
        level = 3
    }
    HoundLogger.__index = HoundLogger

    HoundLogger.LEVEL = {
        ["error"]=1,
        ["warning"]=2,
        ["info"]=3,
        ["debug"]=4,
        ["trace"]=5,
    }
    -- HoundLogger.StopWatch = {
    --     name=nil,
    --     starttime = nil
    -- }
    -- HoundLogger.StopWatch.__index = HoundLogger.StopWatch

    -- function HoundLogger.StopWatch:Start(name)
    --     if not HOUND.DEBUG then return self end
    --     if os == nil then return self end
    --     if name ~= nil and type(name) == "string" then
    --         self.name = name
    --     end
    --     self.starttime=os.clock()
    --     return self
    -- end

    -- function HoundLogger.StopWatch:Stop()
    --     if not HOUND.DEBUG then return nil end
    --     if os == nil then return nil end
    --     local stoptime = os.clock()
    --     local str = "[ StopWatch ] "
    --     if self.name ~= nil then
    --         str = str .. self.name .. " - "
    --     end
    --     str = str .. stoptime - self.starttime .." ms"
    --     HoundLogger.debug(str)
    -- end

    function HoundLogger.setBaseLevel(level)
        if setContainsValue(HoundLogger.LEVEL,level) then
            HoundLogger.level = level
        end
    end

    function HoundLogger.formatText(text, ...)
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

    function HoundLogger.print(level, text)
        -- local texts = HoundLogger.splitText(text)
        local texts = {text}
        local levelChar = 'E'
        local logFunction = l_env.error
        if level == HoundLogger.LEVEL["warning"] then
            levelChar = 'W'
            logFunction = l_env.warning
        elseif level == HoundLogger.LEVEL["info"] then
            levelChar = 'I'
            logFunction = l_env.info
        elseif level == HoundLogger.LEVEL["debug"] then
            levelChar = 'D'
            logFunction = l_env.info
        elseif level == HoundLogger.LEVEL["trace"] then
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

    function HoundLogger.error(text, ...)
        if HoundLogger.level >= 1 then
            text = HoundLogger.formatText(text, unpack(arg))
            HoundLogger.print(1, text)
        end
    end

    function HoundLogger.warn(text, ...)
        if HoundLogger.level >= 2 then
            text = HoundLogger.formatText(text, unpack(arg))
            HoundLogger.print(2, text)
        end
    end

    function HoundLogger.info(text, ...)
        if HoundLogger.level >= 3 then
            text = HoundLogger.formatText(text, unpack(arg))
            HoundLogger.print(3, text)
        end
    end

    function HoundLogger.debug(text, ...)
        if HoundLogger.level >= 4 then
            text = HoundLogger.formatText(text, unpack(arg))
            HoundLogger.print(4, text)
        end
    end

    function HoundLogger.trace(text, ...)
        if HoundLogger.level >= 5 then
            text = HoundLogger.formatText(text, unpack(arg))
            HoundLogger.print(5, text)
        end
    end

    if HOUND.DEBUG then
        HoundLogger.setBaseLevel(HoundLogger.LEVEL.trace)
    end
end
