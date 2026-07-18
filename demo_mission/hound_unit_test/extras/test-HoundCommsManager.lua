do
    TestHoundCommsManager = {}

    function TestHoundCommsManager:setUp()
        self._savedSettings = {}
        self.houndConfig = {
            getId = function() return 1 end,
            getAtisUpdateInterval = function() return 300 end,
            _settings = self._savedSettings,
            get = function(_, key) return self._savedSettings[key] end,
            set = function(_, key, val) self._savedSettings[key] = val end,
        }
        self.sector = "test_sector"
        self.manager = HOUND.Comms.Manager:create(self.sector, self.houndConfig)
        lu.assertNotNil(self.manager)
    end

    function TestHoundCommsManager:tearDown()
        if self.manager then
            if self.manager.scheduler then
                timer.removeFunction(self.manager.scheduler)
                self.manager.scheduler = nil
            end
        end
    end

    --- Constructor guards

    function TestHoundCommsManager:TestCreateNilConfig()
        local m = HOUND.Comms.Manager:create("sector", nil)
        lu.assertNil(m)
    end

    function TestHoundCommsManager:TestCreateNilSector()
        local m = HOUND.Comms.Manager:create(nil, self.houndConfig)
        lu.assertNil(m)
    end

    function TestHoundCommsManager:TestCreateWithSettings()
        local m = HOUND.Comms.Manager:create(self.sector, self.houndConfig, {freq = 300, name = "ALPHA"})
        lu.assertNotNil(m)
        lu.assertEquals(m.settings.freq, 300)
        lu.assertEquals(m.settings.name, "ALPHA")
    end

    function TestHoundCommsManager:TestCreateDefaultFreq()
        lu.assertEquals(self.manager.settings.freq, 250.000)
    end

    --- Enable/disable

    function TestHoundCommsManager:TestIsEnabledDefault()
        lu.assertFalse(self.manager:isEnabled())
    end

    function TestHoundCommsManager:TestEnable()
        self.manager:enable()
        lu.assertTrue(self.manager:isEnabled())
        lu.assertNotNil(self.manager.scheduler)
    end

    function TestHoundCommsManager:TestDisable()
        self.manager:enable()
        lu.assertTrue(self.manager:isEnabled())
        lu.assertNotNil(self.manager.scheduler)
        self.manager:disable()
        lu.assertFalse(self.manager:isEnabled())
        lu.assertNil(self.manager.scheduler)
    end

    --- Settings

    function TestHoundCommsManager:TestUpdateSettings()
        self.manager:updateSettings({freq = 300, name = "ALPHA"})
        lu.assertEquals(self.manager:getSettings("freq"), 300)
        lu.assertEquals(self.manager:getSettings("name"), "ALPHA")
    end

    function TestHoundCommsManager:TestUpdateSettingsPreferences()
        self.manager:updateSettings({enabletts = true, alerts = true})
        lu.assertTrue(self.manager.preferences.enabletts)
        lu.assertTrue(self.manager.preferences.alerts)
    end

    function TestHoundCommsManager:TestSetSettings()
        self.manager:setSettings("freq", 251)
        lu.assertEquals(self.manager:getSettings("freq"), 251)
    end

    function TestHoundCommsManager:TestGetSettings()
        lu.assertNil(self.manager:getSettings("nonexistent"))
    end

    --- Text/TTS/Alerts toggles

    function TestHoundCommsManager:TestEnableText()
        self.manager:enableText()
        lu.assertTrue(self.manager.preferences.enabletext)
    end

    function TestHoundCommsManager:TestDisableText()
        self.manager.preferences.enabletext = true
        self.manager:disableText()
        lu.assertFalse(self.manager.preferences.enabletext)
    end

    function TestHoundCommsManager:TestEnableTTS()
        self.manager.preferences.enabletts = false
        self.manager:enableTTS()
        lu.assertTrue(self.manager.preferences.enabletts)
    end

    function TestHoundCommsManager:TestEnableAlerts()
        self.manager:enableAlerts()
        lu.assertTrue(self.manager.preferences.alerts)
    end

    function TestHoundCommsManager:TestDisableAlerts()
        self.manager.preferences.alerts = true
        self.manager:disableAlerts()
        lu.assertFalse(self.manager.preferences.alerts)
    end

    --- Callsign

    function TestHoundCommsManager:TestGetCallsignDefault()
        lu.assertEquals(self.manager:getCallsign(), "Hound")
    end

    function TestHoundCommsManager:TestSetCallsign()
        self.manager:setCallsign("BRAVO")
        lu.assertEquals(self.manager:getCallsign(), "BRAVO")
    end

    function TestHoundCommsManager:TestSetCallsignInvalid()
        self.manager:setCallsign(123)
        lu.assertEquals(self.manager:getCallsign(), "Hound")
    end

    --- Frequency

    function TestHoundCommsManager:TestGetFreqDefault()
        local f = self.manager:getFreq()
        lu.assertIsString(f)
        lu.assertStrContains(f, "250.000")
    end

    function TestHoundCommsManager:TestGetFreqs()
        local freqs = self.manager:getFreqs()
        lu.assertIsTable(freqs)
        lu.assertEquals(#freqs, 1)
        lu.assertEquals(freqs[1], "250.000 AM")
    end

    function TestHoundCommsManager:TestGetFreqsMulti()
        self.manager:setSettings("freq", "250,251")
        self.manager:setSettings("modulation", "AM,FM")
        local freqs = self.manager:getFreqs()
        lu.assertEquals(#freqs, 2)
        lu.assertEquals(freqs[1], "250.000 AM")
        lu.assertEquals(freqs[2], "251.000 FM")
    end

    --- Message queue

    function TestHoundCommsManager:TestAddMessageObj()
        self.manager.enabled = true
        self.manager:addMessageObj({coalition = 2, tts = "hello", priority = 1})
        lu.assertEquals(#self.manager._queue[1], 1)
        lu.assertEquals(self.manager._queue[1][1].tts, "hello")
    end

    function TestHoundCommsManager:TestAddMessageObjDisabled()
        self.manager.enabled = false
        self.manager:addMessageObj({coalition = 2, tts = "hello", priority = 1})
        lu.assertEquals(#self.manager._queue[1], 0)
    end

    function TestHoundCommsManager:TestAddMessageObjNoCoalition()
        self.manager.enabled = true
        self.manager:addMessageObj({tts = "hello", priority = 1})
        for _, q in ipairs(self.manager._queue) do
            lu.assertEquals(#q, 0)
        end
    end

    function TestHoundCommsManager:TestAddMessageObjNoContent()
        self.manager.enabled = true
        self.manager:addMessageObj({coalition = 2, priority = 1})
        for _, q in ipairs(self.manager._queue) do
            lu.assertEquals(#q, 0)
        end
    end

    function TestHoundCommsManager:TestAddMessageObjPriorityClamp()
        self.manager.enabled = true
        self.manager:addMessageObj({coalition = 2, tts = "test", priority = 5})
        lu.assertEquals(#self.manager._queue[3], 1)
    end

    function TestHoundCommsManager:TestAddMessageObjPriorityZero()
        self.manager.enabled = true
        self.manager:addMessageObj({coalition = 2, tts = "test", priority = 0})
        lu.assertEquals(#self.manager._queue[1], 1)
        lu.assertTrue(self.manager._queue[1][1].push)
    end

    function TestHoundCommsManager:TestAddMessageObjPriorityLoop()
        self.manager.enabled = true
        self.manager.loop = {}
        self.manager:addMessageObj({coalition = 2, tts = "loop msg", priority = "loop"})
        lu.assertNotNil(self.manager.loop.msg)
        lu.assertEquals(self.manager.loop.msg.tts, "loop msg")
    end

    function TestHoundCommsManager:TestAddMessageObjContactIdDedup()
        self.manager.enabled = true
        local gid = {100}
        self.manager:addMessageObj({coalition = 2, tts = "first", contactId = 1, gid = gid, priority = 1})
        lu.assertEquals(#self.manager._queue[1], 1)
        self.manager:addMessageObj({coalition = 2, tts = "second", contactId = 1, gid = gid, priority = 1})
        lu.assertEquals(#self.manager._queue[1], 1)
        lu.assertEquals(self.manager._queue[1][1].tts, "second")
    end

    function TestHoundCommsManager:TestAddMessageObjGidTable()
        self.manager.enabled = true
        self.manager:addMessageObj({coalition = 2, tts = "test", gid = 123, priority = 1})
        lu.assertIsTable(self.manager._queue[1][1].gid)
        lu.assertEquals(#self.manager._queue[1][1].gid, 1)
        lu.assertEquals(self.manager._queue[1][1].gid[1], 123)
    end

    function TestHoundCommsManager:TestAddMessageObjGidTableAlready()
        self.manager.enabled = true
        local gidTable = {456}
        self.manager:addMessageObj({coalition = 2, tts = "test", gid = gidTable, priority = 1})
        lu.assertEquals(self.manager._queue[1][1].gid, gidTable)
    end

    function TestHoundCommsManager:TestAddMessageObjPush()
        self.manager.enabled = true
        self.manager:addMessageObj({coalition = 2, tts = "first", priority = 1})
        self.manager:addMessageObj({coalition = 2, tts = "pushed", priority = 1, push = true})
        lu.assertEquals(#self.manager._queue[1], 2)
        lu.assertEquals(self.manager._queue[1][1].tts, "pushed")
    end

    --- Message helpers

    function TestHoundCommsManager:TestAddMessage()
        self.manager.enabled = true
        self.manager:addMessage(2, "test")
        lu.assertEquals(#self.manager._queue[3], 1)
        lu.assertEquals(self.manager._queue[3][1].tts, "test")
    end

    function TestHoundCommsManager:TestAddMessageNil()
        self.manager.enabled = true
        self.manager:addMessage(2, nil)
        for _, q in ipairs(self.manager._queue) do
            lu.assertEquals(#q, 0)
        end
    end

    function TestHoundCommsManager:TestAddTxtMsg()
        self.manager.enabled = true
        self.manager:addTxtMsg(2, "text")
        lu.assertEquals(#self.manager._queue[1], 1)
        lu.assertEquals(self.manager._queue[1][1].txt, "text")
    end

    function TestHoundCommsManager:TestAddTxtMsgEmpty()
        self.manager.enabled = true
        self.manager:addTxtMsg(2, "")
        for _, q in ipairs(self.manager._queue) do
            lu.assertEquals(#q, 0)
        end
    end

    --- Queue management

    function TestHoundCommsManager:TestGetNextMsg()
        self.manager.enabled = true
        self.manager:addMessageObj({coalition = 2, tts = "low", priority = 3})
        self.manager:addMessageObj({coalition = 2, tts = "high", priority = 1})
        self.manager:addMessageObj({coalition = 2, tts = "mid", priority = 2})
        lu.assertEquals(self.manager:getNextMsg().tts, "high")
        lu.assertEquals(self.manager:getNextMsg().tts, "mid")
        lu.assertEquals(self.manager:getNextMsg().tts, "low")
    end

    function TestHoundCommsManager:TestGetNextMsgEmpty()
        lu.assertNil(self.manager:getNextMsg())
    end

    --- Transmitter

    function TestHoundCommsManager:TestTransmitterDefault()
        lu.assertNil(self.manager.transmitter)
    end

    function TestHoundCommsManager:TestSetRemoveTransmitter()
        local ok, err = pcall(function()
            self.manager:setTransmitter("TOR_SAIPAN-1")
        end)
        if ok then
            lu.assertNotNil(self.manager.transmitter)
        else
            lu.assertNil(self.manager.transmitter)
        end
        local ok2, err2 = pcall(function()
            self.manager:removeTransmitter()
        end)
        if ok2 then
            lu.assertNil(self.manager.transmitter)
        end
    end

    function TestHoundCommsManager:TestSetTransmitterInvalid()
        local ok, _ = pcall(function()
            self.manager:setTransmitter("NONEXISTENT_UNIT_12345")
        end)
        if ok then
            lu.assertNil(self.manager.transmitter)
        end
    end

    --- Alias

    function TestHoundCommsManager:TestGetAliasDefault()
        lu.assertNil(self.manager:getAlias())
    end

    function TestHoundCommsManager:TestSetAlias()
        self.manager:setAlias("Guard")
        lu.assertEquals(self.manager:getAlias(), "Guard")
    end

    --- Abstract method guards

    function TestHoundCommsManager:TestStartCallbackLoop()
        lu.assertNil(self.manager:startCallbackLoop())
    end

    function TestHoundCommsManager:TestStopCallbackLoop()
        lu.assertNil(self.manager:stopCallbackLoop())
    end

    function TestHoundCommsManager:TestSetMsgCallback()
        lu.assertNil(self.manager:SetMsgCallback())
    end

    function TestHoundCommsManager:TestRunCallback()
        lu.assertNil(self.manager:runCallback())
    end
end

do
    TestHoundCommsInformationSystem = {}

    function TestHoundCommsInformationSystem:setUp()
        self._savedSettings = {}
        self.houndConfig = {
            getId = function() return 1 end,
            getAtisUpdateInterval = function() return 300 end,
            _settings = self._savedSettings,
            get = function(_, key) return self._savedSettings[key] end,
            set = function(_, key, val) self._savedSettings[key] = val end,
        }
        self.atis = HOUND.Comms.InformationSystem:create("default", self.houndConfig)
        lu.assertNotNil(self.atis)
    end

    function TestHoundCommsInformationSystem:tearDown()
        if self.atis then
            if self.atis.callback and self.atis.callback.scheduler then
                timer.removeFunction(self.atis.callback.scheduler)
                self.atis.callback.scheduler = nil
            end
            if self.atis.scheduler then
                timer.removeFunction(self.atis.scheduler)
                self.atis.scheduler = nil
            end
        end
    end

    function TestHoundCommsInformationSystem:TestCreateValid()
        local atis = HOUND.Comms.InformationSystem:create("default", self.houndConfig)
        lu.assertNotNil(atis)
        lu.assertEquals(getmetatable(atis), HOUND.Comms.InformationSystem)
        lu.assertEquals(atis.settings.freq, 250.500)
        lu.assertEquals(atis.settings.interval, 4)
        lu.assertEquals(atis.settings.speed, 1)
        lu.assertEquals(atis.preferences.reportewr, false)
        lu.assertIsFunction(atis.getCallsign)
    end

    function TestHoundCommsInformationSystem:TestCreateWithSettings()
        local atis = HOUND.Comms.InformationSystem:create("default", self.houndConfig, {freq = 260})
        lu.assertEquals(atis.settings.freq, 260)
    end

    function TestHoundCommsInformationSystem:TestReportEWR()
        self.atis:reportEWR(true)
        lu.assertTrue(self.atis:getSettings("reportEWR"))
        self.atis:reportEWR(false)
        lu.assertFalse(self.atis:getSettings("reportEWR"))
    end

    function TestHoundCommsInformationSystem:TestReportEWRInvalid()
        self.atis.preferences.reportewr = false
        self.atis:reportEWR("bad")
        lu.assertNil(self.atis:getSettings("reportEWR"))
    end

    function TestHoundCommsInformationSystem:TestStopCallbackLoop()
        self.atis.loop.msg = {tts = "test"}
        self.atis.loop.header = "H"
        self.atis.loop.body = "B"
        self.atis.loop.footer = "F"
        self.atis:stopCallbackLoop()
        lu.assertNil(self.atis.loop.msg)
        lu.assertEquals(self.atis.loop.header, "")
        lu.assertEquals(self.atis.loop.body, "")
        lu.assertEquals(self.atis.loop.footer, "")
        lu.assertIsTable(self.atis.callback)
        lu.assertEquals(#self.atis.callback, 0)
    end

    function TestHoundCommsInformationSystem:TestSetMsgCallback()
        local testFunc = function() end
        self.atis:SetMsgCallback(testFunc, {key = "val"})
        lu.assertEquals(self.atis.callback.func, testFunc)
        lu.assertEquals(self.atis.callback.args.key, "val")
        lu.assertEquals(self.atis.callback.interval, 300)
    end

    function TestHoundCommsInformationSystem:TestSetMsgCallbackNoFunc()
        self.atis:SetMsgCallback(nil, {})
        lu.assertNil(self.atis.callback.func)
    end

    function TestHoundCommsInformationSystem:TestRunCallback()
        local calledArgs = nil
        local calledLoop = nil
        local calledPrefs = nil
        local testFunc = function(args, loop, prefs)
            calledArgs = args
            calledLoop = loop
            calledPrefs = prefs
            loop.msg = {tts = "callback msg", coalition = 2}
        end
        self.atis:SetMsgCallback(testFunc, {key = "val"})
        local nextTime = self.atis:runCallback()
        lu.assertEquals(calledArgs.key, "val")
        lu.assertNotNil(calledLoop)
        lu.assertNotNil(calledPrefs)
        lu.assertIsNumber(nextTime)
        nextTime = nil
    end

    function TestHoundCommsInformationSystem:TestGetNextMsgOverride()
        local testFunc = function(args, loop, prefs)
            loop.msg = {tts = "atis override", coalition = 2}
        end
        self.atis:SetMsgCallback(testFunc, {})
        local msg = self.atis:getNextMsg()
        lu.assertNotNil(msg)
        lu.assertEquals(msg.tts, "atis override")
        lu.assertEquals(msg.coalition, 2)
    end

    function TestHoundCommsInformationSystem:TestGetNextMsgNoMsg()
        self.atis.callback = {}
        self.atis:stopCallbackLoop()
        local msg = self.atis:getNextMsg()
        lu.assertNil(msg)
    end
end
