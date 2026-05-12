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

    --- Dispatch event to external subscribers synchronously.
    -- @local
    local function dispatchExternalSync(event)
        for _, handler in pairs(HOUND.EventHandler.subscribers) do
            if handler.onHoundEvent and type(handler.onHoundEvent) == "function" then
                handler:onHoundEvent(event)
            end
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
                if handler.onHoundEvent and type(handler.onHoundEvent) == "function" then
                    handler:onHoundEvent(event)
                end
                coroutine.yield()
            end
        end,{name = guardName})
    end

    --- Execute event on all registeres subscribers
    -- @param event event to execute
    -- @local
    function HOUND.EventHandler.onHoundEvent(event)
        for _, handler in pairs(HOUND.EventHandler._internalSubscribers) do
            if handler and getmetatable(handler) == HoundElint and handler:getId() == event.houndId then
                if handler.onHoundInternalEvent and type(handler.onHoundInternalEvent) == "function" then
                    handler:onHoundInternalEvent(event)
                end
                if handler.onHoundEvent and type(handler.onHoundEvent) == "function" then
                    handler:onHoundEvent(event)
                end
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
