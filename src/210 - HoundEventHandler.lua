    --- HOUND.EventHandler
    -- class to managing Hound Specific event handlers
    -- @module HOUND.EventHandler
do
    --- HOUND.EventHandler Decleration
    -- @type HOUND.EventHandler
    HOUND.EventHandler = {
        idx = 0,
        subscribers = {},
        _internalSubscribers = {},
        subscribeOn = {}
    }

    HOUND.EventHandler.__index = HOUND.EventHandler

    --- register new event handler
    -- @param handler handler to register
    function HOUND.EventHandler.addEventHandler(handler)
        if type(handler) == "table" then
            HOUND.EventHandler.subscribers[handler] = handler
        end
    end

    --- deregister event handler
    -- @param handler handler to remove
    function HOUND.EventHandler.removeEventHandler(handler)
        HOUND.EventHandler.subscribers[handler] = nil
        for eventType,_ in pairs(HOUND.EventHandler.subscribeOn) do
            HOUND.EventHandler.subscribeOn[eventType][handler] = nil
        end
    end

    --- register new internal event handler
    -- @local
    -- @param handler handler to register
    function HOUND.EventHandler.addInternalEventHandler(handler)
        if type(handler) == "table" then
            HOUND.EventHandler._internalSubscribers[handler] = handler
        end
    end

    --- deregister internal event handler
    -- @local
    -- @param handler handler to register
    function HOUND.EventHandler.removeInternalEventHandler(handler)
        if HOUND.setContains(HOUND.EventHandler._internalSubscribers,handler) then
            HOUND.EventHandler._internalSubscribers[handler] = nil
        end
    end

    -- -- register using on pattern
    -- -- @param eventType event to register
    -- -- @param handler handler to register
    -- function HOUND.EventHandler.on(eventType,handler)
    --     if type(handler) == "function" then
    --         if not HOUND.EventHandler.subscribeOn[eventType] then
    --             HOUND.EventHandler.subscribeOn[eventType] = {}
    --         end
    --         HOUND.EventHandler.subscribeOn[eventType][handler] = handler
    --     end
    -- end

    --- Events that must reach external subscribers synchronously.
    -- Destruction events: internal handler may invalidate event.initiator
    -- before a deferred coroutine runs, causing CTD on stale DCS objects.
    -- SITE_LAUNCH: time-sensitive — handlers need it on the same frame.
    -- @local
    local SYNC_EVENTS = {
        [HOUND.EVENTS.RADAR_DESTROYED] = true,
        [HOUND.EVENTS.SITE_REMOVED]    = true,
        [HOUND.EVENTS.SITE_ASLEEP]     = true,
        [HOUND.EVENTS.SITE_LAUNCH]     = true,
    }

    --- Invoke a handler method, isolating callback errors.
    -- @local
    local function safeDispatch(handler, funcName, event)
        local func = handler[funcName]
        if func and type(func) == "function" then
            local ok, err = pcall(func, handler, event)
            if not ok then
                HOUND.Logger.error("HoundEventHandler: " .. funcName .. " failed on event " ..
                    tostring(event.id) .. " (" .. tostring(err) .. ")")
            end
        end
    end

    --- Dispatch event to external subscribers synchronously.
    -- Snapshots the subscriber table so callbacks that (de)register handlers
    -- via the public API during dispatch cannot mutate the iterated table.
    -- @local
    local function dispatchExternalSync(event)
        local snapshot = {}
        for k, v in pairs(HOUND.EventHandler.subscribers) do
            snapshot[k] = v
        end
        for _, handler in pairs(snapshot) do
            safeDispatch(handler, "onHoundEvent", event)
        end
    end

    --- Dispatch event to external subscribers asynchronously.
    -- Snapshots the subscriber table at call time, then schedules a coroutine
    -- that yields between handlers so a slow or buggy server-owner callback
    -- cannot hitch the sim frame.
    -- @local
    local function dispatchExternalAsync(event)
        if next(HOUND.EventHandler.subscribers) == nil then return end
        local snapshot = {}
        for k, v in pairs(HOUND.EventHandler.subscribers) do
            snapshot[k] = v
        end
        local guardName = "HoundEventHandler_on_" .. (event.houndId or "unknown")
        HOUND.Coroutine.add(function()
            for _, handler in pairs(snapshot) do
                safeDispatch(handler, "onHoundEvent", event)
                coroutine.yield()
            end
        end,{name = guardName})
    end

    --- Execute event on all registeres subscribers
    -- @param event event to execute
    -- @local
    function HOUND.EventHandler.onHoundEvent(event)
        -- Snapshot: an internal handler may register/deregister handlers while
        -- the event is dispatched, which must not mutate the iterated table.
        local internalSnapshot = {}
        for k, v in pairs(HOUND.EventHandler._internalSubscribers) do
            internalSnapshot[k] = v
        end
        for _, handler in pairs(internalSnapshot) do
            if handler and getmetatable(handler) == HoundElint and handler:getId() == event.houndId then
                safeDispatch(handler, "onHoundInternalEvent", event)
                safeDispatch(handler, "onHoundEvent", event)
            end
        end
        dispatchExternalSync(event)
        -- if SYNC_EVENTS[event.id] then
        --     HOUND.Logger.debug("EventHandler: dispatching SYNC for event " .. tostring(event.id))
        --     dispatchExternalSync(event)
        -- else
        --     dispatchExternalAsync(event)
        -- end
    end

    --- publish event to subscribers
    -- @local
    function HOUND.EventHandler.publishEvent(event)
        if not event.time then
            event.time = timer.getTime()
        end
        HOUND.EventHandler.onHoundEvent(event)
        -- return event.idx
    end

    --- get next event idx
    -- @local
    function HOUND.EventHandler.getIdx()
        HOUND.EventHandler.idx = HOUND.EventHandler.idx + 1
        return  HOUND.EventHandler.idx
    end
end
