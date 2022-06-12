--- Hound Comms Manager (Base class)
-- @module HOUND.Comms.Manager
do
    --- HOUND.Comms.Manager decleration
    -- @type HOUND.Comms.Manager
    HOUND.Comms.Manager = {}
    HOUND.Comms.Manager.__index = HOUND.Comms.Manager

    --- HOUND.Comms.Manager create
    -- @string sector name of parent sector
    -- @param houndConfig HoundConfig instance
    -- @tab[opt] settings table containing comms instance settings
    -- @return CommsManager Instance
    function HOUND.Comms.Manager:create(sector,houndConfig,settings)
        if (not houndConfig and type(houndConfig) ~= "table") or
            (not sector and type(sector) ~= "string") then
                HOUND.Logger.warn("[Hound] - Comm Controller could not be initilized, missing params")
                return nil
        end
        local CommsManager = {}
        setmetatable(CommsManager, HOUND.Comms.Manager)
        CommsManager.enabled = false
        CommsManager.transmitter = nil
        CommsManager.sector = nil
        CommsManager.houndConfig = houndConfig

        CommsManager._queue = {
            {},{},{}
        }

        CommsManager.settings = {
            freq = 250.000,
            modulation = "AM",
            volume = "1.0",
            name = "Hound",
            speed = 0,
            voice = nil,
            gender = nil,
            culture = nil,
            interval = 0.5
        }

        CommsManager.preferences = {
            enabletts = true,
            enabletext = false
        }

        if not STTS then
            CommsManager.preferences.enabletts = false
        end

        CommsManager.scheduler = nil

        -- CommsManager.updateSettings = function (self,settings)
        --     for k,v in pairs(settings) do
        --         local k0 = tostring(k):lower()
        --         if setContainsValue({"enabletts","enabletext","alerts"},k0) then
        --             self.preferences[k0] = v
        --         else
        --             self.settings[k0] = v
        --         end
        --     end
        -- end

        if type(settings) == "table" and Length(settings) > 0 then
            CommsManager:updateSettings(settings)
        end
        return CommsManager
    end

    --- Control functions
    -- @section Control

    --- Update settings
    -- @param settings #table a settings table
    function HOUND.Comms.Manager:updateSettings(settings)
        for k,v in pairs(settings) do
            local k0 = tostring(k):lower()
            if setContainsValue({"enabletts","enabletext","alerts"},k0) then
                self.preferences[k0] = v
            else
                self.settings[k0] = v
            end
        end
    end
    --- enable comm instance
    function HOUND.Comms.Manager:enable()
        self.enabled = true
        if self.scheduler == nil then
            self.scheduler = timer.scheduleFunction(self.TransmitFromQueue, self, timer.getTime() + self.settings.interval)
        end
        self:startCallbackLoop()
    end

    --- disable comm instance
    function HOUND.Comms.Manager:disable()
        if self.scheduler then
            timer.removeFunction(self.scheduler)
            self.scheduler = nil
        end
        self:stopCallbackLoop()
        self.enabled = false
    end

    --- Getters and Setters
    -- @section Settings

    --- is comm instance enabled
    -- @return Bool True if enabled
    function HOUND.Comms.Manager:isEnabled()
        return self.enabled
    end

    --- get value of setting in settings
    -- @param key config key requested
    -- @return settings[key]
    function HOUND.Comms.Manager:getSettings(key)
        local k0 = tostring(key):lower()
        if setContainsValue({"enabletts","enabletext","alerts"},k0) then
            return self.preferences[tostring(key):lower()]
        else
            return self.settings[tostring(key):lower()]
        end
    end

    --- set value of setting in settings
    -- @param key config key requested
    -- @param value desired value
    function HOUND.Comms.Manager:setSettings(key,value)
        local k0 = tostring(key):lower()
        if setContainsValue({"enabletts","enabletext","alerts"},k0) then
            self.preferences[k0] = value
        else
            self.settings[k0] = value
        end
    end

    --- enable text messages
    function HOUND.Comms.Manager:enableText()
        self:setSettings("enableText",true)
    end

    --- disable text messages
    function HOUND.Comms.Manager:disableText()
        self:setSettings("enableText",false)
    end

    --- enable text messages
    function HOUND.Comms.Manager:enableTTS()
        if STTS ~= nil then
            self:setSettings("enableTTS",true)
        end
    end

    --- disable text messages
    function HOUND.Comms.Manager:disableTTS()
        self:setSettings("enableTTS",false)
    end

    --- enable Alert messages
    function HOUND.Comms.Manager:enableAlerts()
        self:setSettings("alerts",true)
    end

    --- disable Alert messages
    function HOUND.Comms.Manager:disableAlerts()
        self:setSettings("alerts",false)
    end

    --- set transmitter
    -- @param transmitterName (String) name of the Unit which will be transmitter
    function HOUND.Comms.Manager:setTransmitter(transmitterName)
        if not transmitterName then transmitterName = "" end
        local candidate = Unit.getByName(transmitterName)
        if candidate == nil then
            candidate = StaticObject.getByName(transmitterName)
        end
        if candidate == nil and self.transmitter then
            self:removeTransmitter()
            return
        end
        if self.transmitter ~= candidate then
            self.transmitter = candidate
            HOUND.EventHandler.publishEvent({
                    id = HOUND.EVENTS.TRANSMITTER_ADDED,
                    houndId = self.houndConfig:getId(),
                    initiator = self.sector,
                    transmitter = candidate
                })
        end
    end

    --- Remove transmitter
    function HOUND.Comms.Manager:removeTransmitter()
        if self.transmitter ~= nil then
            self.transmitter = nil
            HOUND.EventHandler.publishEvent({
                    id = HOUND.EVENTS.TRANSMITTER_REMOVED,
                    houndId = self.houndConfig:getId(),
                    initiator = self.sector
                })
        end
    end

    --- get configured callsign
    -- @return string. currently configured callsign
    function HOUND.Comms.Manager:getCallsign()
        return self:getSettings("name")
    end

    --- set callsign
    -- @string callsign
    function HOUND.Comms.Manager:setCallsign(callsign)
        if type(callsign) == "string" then
            self:setSettings("name",callsign)
        end
    end

    --- get first configured frequency
    -- @return string first frequency configured
    function HOUND.Comms.Manager:getFreq()
        return self:getFreqs()[1]
    end

    --- get table of all configured frequencies
    -- @return table of all configured frequencies
    function HOUND.Comms.Manager:getFreqs()
        local freqs = string.split(self.settings.freq,",")
        local mod = string.split(self.settings.modulation,",")
        local retval = {}

        for i,freq in ipairs(freqs) do
            local str = string.format("%.3f",tonumber(freq)) .. " " .. (mod[i] or "AM")
            table.insert(retval,str)
        end
        return retval
    end

    --- Message Handling
    -- @section Messaging

    --- Add message object to queue
    -- @tab obj the message object to be added
    function HOUND.Comms.Manager:addMessageObj(obj)
        if obj.coalition == nil or not self.enabled then return end
        if obj.txt == nil and obj.tts == nil then return end
        if obj.priority == nil or obj.priority > 3 then obj.priority = 3 end
        if obj.priority == "loop" then
            self.loop.msg = obj
            return
        end
        table.insert(self._queue[obj.priority],obj)
    end

    --- add message to queue
    -- @int coalition coalition to transmit for
    -- @string msg Message to be added
    -- @int[opt] prio message priority in queue
    function HOUND.Comms.Manager:addMessage(coalition,msg,prio)
        if msg == nil or coalition == nil or ( type(msg) ~= "string" and string.len(tostring(msg)) <= 0) or not self.enabled then return end
        if prio == nil or prio > 3 then prio = 3 end

        local obj = {
            coalition = coalition,
            priority = prio,
            tts = msg
        }

        self:addMessageObj(obj)
    end

    --- add text message to queue
    function HOUND.Comms.Manager:addTxtMsg(coalition,msg,prio)
        -- TODO FIX!
        if msg == nil or string.len(tostring(msg)) == 0 or coalition == nil  or not self.enabled then return end
        if prio == nil then prio = 1 end
        local obj = {
            coalition = coalition,
            priority = prio,
            txt = msg
        }
        self:addMessageObj(obj)
    end

    --- Get next message from queue
    -- @local
    function HOUND.Comms.Manager:getNextMsg()
        for i,v in ipairs(self._queue) do
            if #v > 0 then return table.remove(self._queue[i],1) end
        end
    end

    --- returns configured transmitter position
    -- @local
    -- @return DCS position of transmitter or nil if none set
    function HOUND.Comms.Manager:getTransmitterPos()
        if self.transmitter == nil then return nil end
        if self.transmitter ~= nil and (self.transmitter:isExist() == false or self.transmitter:getLife() < 1) then
            return false
        end
        local pos = self.transmitter:getPoint()
        if self.transmitter:getCategory() == Object.Category.STATIC or self.transmitter:getDesc()["category"] == Unit.Category.GROUND_UNIT then
            pos.y = pos.y + self.transmitter:getDesc()["box"]["max"]["y"] + 5
        end
        return pos
    end

    --- Trsnsmit next message from queue
    -- @local
    -- @param gSelf #Table pointer to self
    -- @return time of next queue check
    function HOUND.Comms.Manager.TransmitFromQueue(gSelf)
        local msgObj = gSelf:getNextMsg()
        local readTime = gSelf.settings.interval
        if msgObj == nil then return timer.getTime() + readTime end
        local transmitterPos = gSelf:getTransmitterPos()

        if transmitterPos == false then
            env.info("[Hound] - Transmitter destroyed")
            HOUND.EventHandler.publishEvent({
                    id = HOUND.EVENTS.TRANSMITTER_DESTROYED,
                    houndId = gSelf.houndConfig:getId(),
                    initiator = gSelf.sector,
                    transmitter = gSelf.transmitter
                })

            return timer.getTime() + 10
        end

        if gSelf.enabled and STTS ~= nil and msgObj.tts ~= nil and gSelf.preferences.enabletts then
            HOUND.Utils.TTS.Transmit(msgObj.tts,msgObj.coalition,gSelf.settings,transmitterPos)
            readTime = HOUND.Utils.TTS.getReadTime(msgObj.tts,gSelf.settings.speed)
            -- env.info("TTS msg: " .. msgObj.tts)
        end

        if gSelf.enabled and gSelf.preferences.enabletext and msgObj.txt ~= nil then
            readTime =  HOUND.Utils.TTS.getReadTime(msgObj.tts,gSelf.settings.speed) or HOUND.Utils.TTS.getReadTime(msgObj.txt,gSelf.settings.speed)
            if msgObj.gid then
                if type(msgObj.gid) == "table" then
                    for _,gid in ipairs(msgObj.gid) do
                        trigger.action.outTextForGroup(gid,msgObj.txt,readTime+2)
                    end
                else
                    trigger.action.outTextForGroup(msgObj.gid,msgObj.txt,readTime+2)
                end
            else
                trigger.action.outTextForCoalition(msgObj.coalition,msgObj.txt,readTime+2)
            end
        end
        return timer.getTime() + readTime + gSelf.settings.interval
    end

    --- abstract methods
    -- @section abstacts

    --- start loop placeholder
    -- @local
    function HOUND.Comms.Manager:startCallbackLoop()
        return nil
    end

    --- stop loop placeholder
    -- @local
    function HOUND.Comms.Manager:stopCallbackLoop()
        return nil
    end

    --- SetMsgCallback placeholder
    -- @local
    function HOUND.Comms.Manager:SetMsgCallback()
        return nil
    end

    --- run callback message scheduler placeholder
    -- @local
    function HOUND.Comms.Manager:runCallback()
        return nil
    end
end
