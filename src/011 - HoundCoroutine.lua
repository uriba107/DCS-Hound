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
        --- internal: true while pump() is iterating _list; remover mutators defer
        -- structural changes (mark dead instead of removing) until pump ends
        _pumping = false,
    }

    --- internal: drop dead-marked records. Only call outside a pump walk.
    -- @local
    local function purgeDead()
        local list = HOUND.Coroutine._list
        for i = #list, 1, -1 do
            if list[i].dead then
                table.remove(list, i)
            end
        end
    end

    --- internal pump — advances one tick's worth of coroutines.
    -- Does not remove from _list during the walk: a resumed coroutine or its
    -- onError/onYield callbacks may reentrantly call add/cancel/cancelByName/
    -- shutdown. add appends, but the walk is bounded by the record count captured
    -- at tick start, so new work waits for a later tick. Removers mark records dead
    -- instead of removing them. Records are compacted after the walk. table.remove
    -- mid-walk would shift indices and skip/repeat records.
    -- coroutine.resume returns (false, err) on error — never throws.
    -- @local
    local function pump()
        if not HOUND.Coroutine._running then return nil end
        HOUND.Coroutine._pumping = true
        local now = timer.getTime()
        local list = HOUND.Coroutine._list
        local n = #list
        local i = 1
        while i <= n do
            local rec = list[i]
            if rec.dead or coroutine.status(rec.co) == "dead" then
                i = i + 1
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
                    rec.dead = true
                    i = i + 1
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
                        rec.dead = true
                    end
                    i = i + 1
                end
            else
                i = i + 1
            end
        end
        HOUND.Coroutine._pumping = false
        purgeDead()

        if #list == 0 then
            HOUND.Coroutine._running = false
            return nil
        end
        return timer.getTime() + HOUND.Coroutine.YieldInterval
    end

    --- internal: exposed so tests can advance one pump tick synchronously
    HOUND.Coroutine._pump = pump

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
    -- Mutating _list while the pump walks it is unsafe, so during a pump the
    -- record is only marked dead and removed after the walk (purgeDead).
    -- @param id handle returned from add
    -- @return true if found and removed
    function HOUND.Coroutine.cancel(id)
        if id == nil then return false end
        for _, rec in ipairs(HOUND.Coroutine._list) do
            if not rec.dead and rec.id == id then
                rec.dead = true
                if not HOUND.Coroutine._pumping then
                    purgeDead()
                end
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
        for _, rec in ipairs(HOUND.Coroutine._list) do
            if not rec.dead and rec.name == name then
                rec.dead = true
                removed = removed + 1
            end
        end
        if removed > 0 and not HOUND.Coroutine._pumping then
            purgeDead()
        end
        return removed
    end

    --- check whether a coroutine with the given name is active
    -- used by re-entry guards
    -- @param name string
    -- @return bool
    function HOUND.Coroutine.isRunning(name)
        for _, rec in ipairs(HOUND.Coroutine._list) do
            if not rec.dead
               and rec.name == name
               and coroutine.status(rec.co) ~= "dead" then
                return true
            end
        end
        return false
    end

    --- total active coroutine count
    function HOUND.Coroutine.count()
        local count = 0
        for _, rec in ipairs(HOUND.Coroutine._list) do
            if not rec.dead then count = count + 1 end
        end
        return count
    end

    --- predicate: any active coroutines?
    function HOUND.Coroutine.hasWork()
        return HOUND.Coroutine.count() > 0
    end

    --- convenience alias for coroutine.yield
    -- @local
    function HOUND.Coroutine.yield()
        return coroutine.yield()
    end

    --- cancel everything; used by HoundElint:destroy and :systemOff
    -- Clears _list in place (doesn't replace the table) so an in-progress
    -- pump keeps iterating the same array; dead-marking lets the pump skip
    -- and purge naturally. Coroutines added after shutdown are not orphaned.
    function HOUND.Coroutine.shutdown()
        for _, rec in ipairs(HOUND.Coroutine._list) do
            if not rec.dead then
                rec.dead = true
            end
        end
        -- Do not clear _running mid-pump: a coroutine added from inside the
        -- current slice would re-arm the pump, and the finishing pump would
        -- then schedule a second one. The active pump sees the empty list and
        -- clears _running itself.
        if not HOUND.Coroutine._pumping then
            HOUND.Coroutine._running = false
            purgeDead()
        end
        HOUND.Logger.trace("HOUND.Coroutine shutdown")
    end
end
