do
    if HoundWorkDir == nil then
        HoundWorkDir = "E:\\Dropbox\\uri\\Dropbox\\DCS\\Mission Building\\HoundElint\\"
    end
    -- assert(loadfile(HoundWorkDir..'include\\DCS-SimpleTextToSpeech.lua'))()
    -- HOUND.TTS_ENGINE = {'STTS'}

    function UserSpaceLogging(msg)
        trigger.action.outText(msg,10)
        env.info("***** "..msg.." *****")
    end

    env.info("Loading UnitTesting")
    assert(loadfile(HoundWorkDir..'demo_mission\\hound_unit_test\\extras\\luaunit.lua'))()

    runTest = {
        next = 1
    }
    function runTest.run(self)
        local tests = {
            {name = "module", func = self.moduleTesting, next_test_delay = 10},
            {name = "hound init", func = self.initTesting, next_test_delay = 15},
            {name = "hound base", func = self.baseTesting, next_test_delay = 1*60},
            {name = "hound functional 1 min", func = self.delayedTesting1m, next_test_delay = 4*60},
            {name = "hound functional 5 min", func = self.delayedTesting5m, next_test_delay = 0}

        }

        local currentTest = tests[self.next]
        UserSpaceLogging(string.format("Starting %s testing (%d/%d)",currentTest.name,self.next,#tests))
        currentTest.func()
        local next_test_time = timer.getTime() + currentTest.next_test_delay
        UserSpaceLogging(string.format("Finished %s Testing. Please check logs",currentTest.name))
        collectgarbage("collect")
        self.next = self.next + 1
        return next_test_time
    end

    function runTest.moduleTesting()
        assert(loadfile(HoundWorkDir..'demo_mission\\hound_unit_test\\extras\\test-houndUtils.lua'))()
        assert(loadfile(HoundWorkDir..'demo_mission\\hound_unit_test\\extras\\test-houndContact.lua'))()
        lu.LuaUnit.run()
    end

    function runTest.initTesting()
        assert(loadfile(HoundWorkDir..'demo_mission\\hound_unit_test\\extras\\test-hound-init.lua'))()
        lu.LuaUnit.run('--pattern', '01_init')
    end

    function runTest.baseTesting()
        assert(loadfile(HoundWorkDir..'demo_mission\\hound_unit_test\\extras\\test-hound-base.lua'))()
        lu.LuaUnit.run('--pattern', '02_base')
    end

    function runTest.delayedTesting1m()
        assert(loadfile(HoundWorkDir..'demo_mission\\hound_unit_test\\extras\\test-hound-delayed.lua'))()
        lu.LuaUnit.run('--pattern', '1mDelay')
    end

    function runTest.delayedTesting5m()
        lu.LuaUnit.run('--pattern', '5mDelay')
    end

    UserSpaceLogging("Starting Modules Testing")

    runTest.TaskId = timer.scheduleFunction(runTest.run, runTest, timer.getTime() + 1)
    -- env.info(mist.utils.tableShow(_G.env.mission.drawings.layers[2]["objects"][1]))
    -- local socket = _G.loadfile('socket.lua')
    -- env.info(type(base.require))

end