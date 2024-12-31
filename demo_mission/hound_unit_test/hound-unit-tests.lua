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
            {name = "hound functional 1 min", func = self.delayedTesting1m, next_test_delay = 2*60},
            {name = "hound functional UI", func = self.testUI, next_test_delay = 2*60},
            {name = "hound functional 5 min", func = self.delayedTesting5m, next_test_delay = 0}

        }

        local currentTest = tests[self.next]
        UserSpaceLogging(string.format("Starting %s testing (%d/%d)",currentTest.name,self.next,#tests))
        currentTest.func()
        local next_test_time = timer.getTime() + currentTest.next_test_delay
        if currentTest.name ~= "hound functional UI" then
            UserSpaceLogging(string.format("Finished %s Testing. Please check logs",currentTest.name))
            collectgarbage("collect")
        end
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

    function runTest.delayedTestingUi(self)
        assert(loadfile(HoundWorkDir..'demo_mission\\hound_unit_test\\extras\\test-hound-Comms.lua'))()
        lu.LuaUnit.run('--pattern', 'Comms')
        UserSpaceLogging(string.format("Finished UI Testing for %s. Please check logs\n Please switch to dynamic slot if possible to retest.",TestHoundFunctional.eventTriggerUnit:getName()))
    end

    function runTest.testUI()
        function runTest.onEvent(self,DcsEvent)
            -- env.info("EVENT TIRGGERED!\n".. HOUND.Mist.utils.tableShow(DcsEvent))
            if HOUND.Utils.Dcs.isUnit(DcsEvent.initiator) then env.info(DcsEvent.initiator:getName()) end
            if (DcsEvent.id == world.event.S_EVENT_BIRTH)
                and HOUND.Utils.Dcs.isHuman(DcsEvent.initiator)
            then
                TestHoundFunctional.eventTriggerUnit=DcsEvent.initiator
                timer.scheduleFunction(runTest.delayedTestingUi, runTest, timer.getTime() + 10)
            end
        end

        world.addEventHandler(runTest)
        UserSpaceLogging("Please switch to Aircraft slot to initilize testing")
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