    --- HoundEventHandler
    -- class to managing Hound Specific event handlers
    -- @module HoundEventHandler
do
    --- HoundEventHandler Decleration
    -- @type HoundEventHandler
    HoundEventHandler = {
        idx = 0,
        subscribers = {},
        _internalSubscribers = {}
    }

    HoundEventHandler.__index = HoundEventHandler

    --- register new event handler
    -- @param handler handler to register
    function HoundEventHandler.addEventHandler(handler)
        if type(handler) == "table" then
            HoundEventHandler.subscribers[handler] = handler
        end
    end

    --- deregister event handler
    -- @param handler handler to remove
    function HoundEventHandler.removeEventHandler(handler)
        HoundEventHandler.subscribers[handler] = nil
    end

    --- register new internal event handler
    -- @local
    -- @param handler handler to register
    function HoundEventHandler.addInternalEventHandler(handler)
        if type(handler) == "table" then
            HoundEventHandler._internalSubscribers[handler] = handler
        end
    end

    --- deregister internal event handler
    -- @local
    -- @param handler handler to register
    function HoundEventHandler.removeInternalEventHandler(handler)
        if setContains(HoundEventHandler._internalSubscribers,handler) then
            HoundEventHandler._internalSubscribers[handler] = nil
        end
    end

    --- Execute event on all registeres subscribers
    function HoundEventHandler.onHoundEvent(event)
        for _, handler in pairs(HoundEventHandler._internalSubscribers) do
            if handler.onHoundEvent and type(handler.onHoundEvent) == "function" then
                if handler and handler.settings then
                    handler:onHoundEvent(event)
                end
            end
        end
        for _, handler in pairs(HoundEventHandler.subscribers) do
            if handler.onHoundEvent and type(handler.onHoundEvent) == "function" then
                handler:onHoundEvent(event)
            end
        end
    end

    --- publish event to subscribers
    -- @local
    function HoundEventHandler.publishEvent(event)
        event.time = timer.getTime()
        HoundEventHandler.onHoundEvent(event)
        -- return event.idx
    end

    --- get next event idx
    -- @local
    function HoundEventHandler.getIdx()
        HoundEventHandler.idx = HoundEventHandler.idx + 1
        return  HoundEventHandler.idx
    end
end
