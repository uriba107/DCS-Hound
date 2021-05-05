do
    HoundCommsManager = {}
    HoundCommsManager.__index = HoundCommsManager

    function HoundCommsManager:create(settings)
        local CommsManager = {}
        setmetatable(CommsManager, HoundCommsManager)
        CommsManager.enabled = false
        CommsManager.transmitter = nil

        CommsManager._queue = {
            {},{},{}
        }

        CommsManager.loop = {
            MsgCallback = nil,
            body = "",
            header = "",
            footer = "",
            msg = "",
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

        CommsManager.scheduler = nil

        if settings ~= nil and type(settings) == "table" then
            CommsManager:updateSettings(settings)
        end
        return CommsManager
    end

    -- Houskeeping functions
    function HoundCommsManager:updateSettings(settings)
        for k,v in pairs(settings) do self.settings[k] = v end
    end

    function HoundCommsManager:StopLoop()
        self.loop.msg = ""
        self.loop.header = ""
        self.loop.body = ""
        self.loop.footer = ""
        self.loop.MsgCallback = nil
    end

    function HoundCommsManager:SetMsgCallback(callback,args)
        if callback ~=nil and type(callback) == "function" then
            self.loop.MsgCallback = {func=callback,args=args}
        end
    end
    
    -- Main functions
    function HoundCommsManager:addMessageObj(obj)
        if obj.coalition == nil then return end
        if obj.txt == nil and obj.tts == nil then return end
        if obj.priority == nil or obj.priority > 3 then obj.priority = 3 end
        if obj.priority == "loop" then 
            self.loop.msg = obj
            return
        end
        table.insert(self._queue[obj.priority],obj)

    end

    function HoundCommsManager:addMessage(coalition,msg,prio)
        if msg == nil or coalition == nil or ( type(msg) ~= "string" and string.len(tostring(msg)) <= 0) or not self.enabled then return end
        if prio == nil or prio > 3 then prio = 3 end 

        local obj = {
            coalition = coalition,
            priority = prio,
            tts = msg
        }

        self:addMessageObj(obj)
    end

    function HoundCommsManager:addTxtMsg(coalition,msg,prio)
        -- TODO FIX!
        if msg == nil or string.len(tostring(msg)) == 0 or coalition == nil then return end
        if prio == nil then prio = 1 end
        local obj = {
            coalition = coalition,
            priority = prio,
            txt = msg
        }
        self:addMessageObj(obj)
    end

    function HoundCommsManager:getNextMsg()
        if self.loop.MsgCallback ~= nil and type(self.loop.MsgCallback.func) == "function"  then 
                self.loop.MsgCallback.func(self.loop.MsgCallback.args) 
        end

        if self.loop.msg.tts ~= nil and (string.len(self.loop.msg.tts) > 0 or string.len(self.loop.msg.txt) > 0) then
            return self.loop.msg
        end

        for i,v in ipairs(self._queue) do
            if #v > 0 then return table.remove(self._queue[i],1) end
        end
    end

    function HoundCommsManager:getTransmitterPos()
        if self.transmitter == nil then return nil end
        if self.transmitter ~= nil and (self.transmitter:isExist() == false or self.transmitter:getLife() < 1) then
            return false
        end
        local pos = self.transmitter:getPoint()
        if self.transmitter:getCategory() == Object.Category.STATIC then
            pos.y = pos.y + 120
        end
        if self.transmitter:getDesc()["category"] == Unit.Category.GROUND_UNIT then
            pos.y = pos.y + 50
        end
        return pos
    end

    function HoundCommsManager.TransmitFromQueue(gSelf)
        local msgObj = gSelf:getNextMsg()
        if msgObj == nil then return timer.getTime() + gSelf.settings.interval end
        local transmitterPos = gSelf:getTransmitterPos()

        if transmitterPos == false then
            env.info("[Hound] - Transmitter destroyed")
            return
        end

        if msgObj.txt ~= nil then
            local readTime =  HoundUtils.TTS.getReadTime(msgObj.tts,gSelf.settings.speed) or HoundUtils.TTS.getReadTime(msgObj.txt,gSelf.settings.speed)
            trigger.action.outTextForCoalition(msgObj.coalition,msgObj.txt,readTime+2)
        end

        if gSelf.enabled and STTS ~= nil and msgObj.tts ~= nil then
            HoundUtils.TTS.Transmit(msgObj.tts,msgObj.coalition,gSelf.settings,transmitterPos)

            return timer.getTime() + HoundUtils.TTS.getReadTime(msgObj.tts,gSelf.settings.speed) -- temp till I figure out the speed
        end
    end

    function HoundCommsManager:enable()
        self.enabled = true 
        if self.scheduler == nil then
            self.scheduler = timer.scheduleFunction(HoundCommsManager.TransmitFromQueue, self, timer.getTime() + self.settings.interval)
        end
    end

    function HoundCommsManager:disable()
        self.enabled = false 
        self:StopLoop()
    end

    function HoundCommsManager:setTransmitter(platformName)
        local canidate = Unit.getByName(platformName)
        if canidate == nil then
            canidate = StaticObject.getByName(platformName)
        end

        self.transmitter = canidate
    end

    function HoundCommsManager:removeTransmitter()
        if self.transmitter ~= nil then
            self.transmitter = nil
        end
    end
end