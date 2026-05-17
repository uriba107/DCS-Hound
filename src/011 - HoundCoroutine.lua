--- HOUND.Coroutine
-- Collaborative scheduler for long-running Hound work.
-- Lets pipelines (Sniff discovery, UpdateMarkers, sector membership)
-- yield across sim ticks so a single expensive call can't hitch DCS.
-- In Lua 5.1 (DCS), pcall/xpcall are C functions — you cannot
-- coroutine.yield() across them. Coroutine bodies must be plain Lua.
-- Errors are caught via coroutine.resume's return values (it returns
-- false, error_string on error — it never throws).
-- @local
-- @module HOUND.Coroutine
do
    HOUND.Coroutine = {
        --- default wake interval for the pump (seconds)
        YieldInterval = 0.05,
        --- per-resume budget; longer resumes log a debug warning
        MaxExecutionTime = 0.01,
        --- internal: active coroutine records
        _list = {},
        --- internal: true while timer pump is armed
        _running = false,
    }

    --- internal pump — advances one tick's worth of coroutines.
    -- coroutine.resume returns (false, err) on error — never throws.
    -- @local
    local function pump()
        if not HOUND.Coroutine._running then return nil end
        local now = timer.getTime()
        local list = HOUND.Coroutine._list
        local i = 1
        while i <= #list do
            local rec = list[i]
            if coroutine.status(rec.co) == "dead" then
                table.remove(list, i)
            elseif (now - rec.lastResume) >= rec.interval then
                local startT = timer.getTime()
                local ok, v1, v2 = coroutine.resume(rec.co)
                local elapsed = timer.getTime() - startT

                if not ok then
                    HOUND.Logger.error(
                        string.format("coroutine '%s' crashed: %s",
                            tostring(rec.name), tostring(v1)))
                    if rec.onError then
                        pcall(rec.onError, v1)
                    end
                    table.remove(list, i)
                else
                    rec.lastResume = now
                    if rec.onYield then
                        pcall(rec.onYield, v1, v2)
                    end
                    if HOUND.DEBUG and elapsed > HOUND.Coroutine.MaxExecutionTime then
                        HOUND.Logger.debug(string.format(
                            "coroutine '%s' slice %.4fs exceeds budget %.4fs",
                            tostring(rec.name), elapsed,
                            HOUND.Coroutine.MaxExecutionTime))
                    end
                    if coroutine.status(rec.co) == "dead" then
                        table.remove(list, i)
                    else
                        i = i + 1
                    end
                end
            else
                i = i + 1
            end
        end

        if #list == 0 then
            HOUND.Coroutine._running = false
            return nil
        end
        return timer.getTime() + HOUND.Coroutine.YieldInterval
    end

    --- start pump if idle
    -- @local
    local function ensurePump()
        if HOUND.Coroutine._running then return end
        HOUND.Coroutine._running = true
        timer.scheduleFunction(pump, nil,
            timer.getTime() + HOUND.Coroutine.YieldInterval)
    end

    --- schedule a coroutine
    -- Body is plain Lua (no pcall/xpcall wrapper) so coroutine.yield
    -- works in Lua 5.1. Errors surface via coroutine.resume's return.
    -- @param func function body to run
    -- @param[opt] opts table { name=string, interval=number, onError=function, onYield=function }
    -- @param ... extra args passed to func
    -- @return id (opaque handle) or nil on error
    function HOUND.Coroutine.add(func, opts, ...)
        if type(func) ~= "function" then
            HOUND.Logger.error("HOUND.Coroutine.add: func not callable")
            return nil
        end
        opts = opts or {}
        local args = {...}
        local co = coroutine.create(function()
            return func(unpack(args))
        end)
        local rec = {
            id = {},
            co = co,
            name = opts.name or "anonymous",
            interval = type(opts.interval) == "number" and opts.interval
                       or HOUND.Coroutine.YieldInterval,
            lastResume = timer.getTime() - HOUND.Coroutine.YieldInterval,
            onError = opts.onError,
            onYield = opts.onYield,
        }
        table.insert(HOUND.Coroutine._list, rec)
        ensurePump()
        HOUND.Logger.trace("scheduled coroutine '" .. rec.name .. "'")
        return rec.id
    end

    --- cancel a coroutine by handle
    -- @param id handle returned from add
    -- @return true if found and removed
    function HOUND.Coroutine.cancel(id)
        if id == nil then return false end
        for i, rec in ipairs(HOUND.Coroutine._list) do
            if rec.id == id then
                table.remove(HOUND.Coroutine._list, i)
                return true
            end
        end
        return false
    end

    --- cancel all coroutines matching a name
    -- @param name string
    -- @return number removed
    function HOUND.Coroutine.cancelByName(name)
        if type(name) ~= "string" then return 0 end
        local removed = 0
        local i = 1
        while i <= #HOUND.Coroutine._list do
            if HOUND.Coroutine._list[i].name == name then
                table.remove(HOUND.Coroutine._list, i)
                removed = removed + 1
            else
                i = i + 1
            end
        end
        return removed
    end

    --- check whether a coroutine with the given name is active
    -- used by re-entry guards
    -- @param name string
    -- @return bool
    function HOUND.Coroutine.isRunning(name)
        for _, rec in ipairs(HOUND.Coroutine._list) do
            if rec.name == name
               and coroutine.status(rec.co) ~= "dead" then
                return true
            end
        end
        return false
    end

    --- total active coroutine count
    function HOUND.Coroutine.count()
        return #HOUND.Coroutine._list
    end

    --- predicate: any active coroutines?
    function HOUND.Coroutine.hasWork()
        return #HOUND.Coroutine._list > 0
    end

    --- convenience alias for coroutine.yield
    -- @local
    function HOUND.Coroutine.yield()
        return coroutine.yield()
    end

    --- cancel everything; used by HoundElint:destroy and :systemOff
    function HOUND.Coroutine.shutdown()
        HOUND.Coroutine._list = {}
        HOUND.Coroutine._running = false
        HOUND.Logger.trace("HOUND.Coroutine shutdown")
    end
end
