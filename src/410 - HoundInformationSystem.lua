    --- Hound Information System (extends HOUND.Comms.Manager)
    -- @module HOUND.Comms.InformationSystem

do
    --- Hound inforamtion System (extends HOUND.Comms.Manager)
    -- @see HOUND.Comms.Manager

    HOUND.Comms.InformationSystem = {}
    -- HOUND.Comms.InformationSystem.__index = HOUND.Comms.InformationSystem
    HOUND.Comms.InformationSystem = inheritsFrom(HOUND.Comms.Manager)

    --- HOUND.Comms.InformationSystem create
    -- @string sector name of parent sector
    -- @param houndConfig HoundConfig instance
    -- @tab[opt] settings table containing comms instance settings
    -- @return HOUND.Comms.InformationSystem Instance
    function HOUND.Comms.InformationSystem:create(sector,houndConfig,settings)
        local instance = self:superClass():create(sector,houndConfig,settings)
        setmetatable(instance, self)
        self.__index = self

        instance.settings.freq = 250.500
        instance.settings.interval = 4
        instance.settings.speed = 1
        instance.preferences.reportewr = false

        if settings and type(settings) == "table" then
            instance:updateSettings(settings)
        end

        instance.callback = {
            scheduler = nil,
            func = nil,
            args = nil,
            interval = 300
        }

        instance.loop = {
            body = "",
            msg = nil,
            reportIdx = 'Z'
        }

        return instance
    end

    --- Getters and Setters
    -- @section Settings

    --- set reportEWR state
    -- @bool state Desired state
    function HOUND.Comms.InformationSystem:reportEWR(state)
        if type(state) == "boolean" then
            self:setSettings("reportEWR",state)
        end
    end

    --- Function Overrides
    -- @section Overrides

    --- Start callback loop
    -- @local
    -- Implementation of abstract for ATIS
    function HOUND.Comms.InformationSystem:startCallbackLoop()
        if self.enabled and not self.callback.scheduler then
            self.callback.scheduler = timer.scheduleFunction(self.runCallback, self, timer.getTime()+0.1)
        end
    end

    --- stop callback loop
    -- @local
    -- Implementation of abstract for ATIS
    function HOUND.Comms.InformationSystem:stopCallbackLoop()
        if self.callback.scheduler then
            timer.removeFunction(self.callback.scheduler)
            self.callback.scheduler = nil
        end
        self.loop.msg = nil
        self.loop.header = ""
        self.loop.body = ""
        self.loop.footer = ""
        self.callback = {}
    end

    --- configure function for loop
    -- Implementation of abstract
    -- @func callback to run in loop
    -- @tab args argument table for callback function
    function HOUND.Comms.InformationSystem:SetMsgCallback(callback,args)
        if callback ~= nil and type(callback) == "function" then
            self.callback.func = callback
            self.callback.args = args
            self.callback.interval = self.houndConfig:getAtisUpdateInterval()
        end
        if self.callback.scheduler == nil and self.scheduler ~= nil then
            self.startCallbackLoop()
        end
    end

    --- run callback message scheduler
    -- @local
    -- Implementation of abstract
    -- @return time of next run
    function HOUND.Comms.InformationSystem:runCallback()
        local nextDelay = self.callback.interval or 300
        if self.callback ~= nil and type(self.callback.func) == "function"  then
            self.callback.func(self.callback.args,self.loop,self.preferences)
        end
        return timer.getTime() + nextDelay
    end

    --- Get next message from queue
    -- override implementation
    -- @local
    function HOUND.Comms.InformationSystem:getNextMsg()
        if self.loop and not self.loop.msg then
            self:runCallback()
        end
        if self.loop and self.loop.msg and self.loop.msg.tts ~= nil and (string.len(self.loop.msg.tts) > 0 or string.len(self.loop.msg.txt) > 0) then
            return self.loop.msg
        end
    end
end
