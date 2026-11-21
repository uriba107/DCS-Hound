do
    TestHoundCoroutine = {}

    local function simpleCo() coroutine.yield() end

    local function quickExit() return 42 end

    function TestHoundCoroutine:setUp()
        HOUND.Coroutine.shutdown()
        HOUND.Coroutine._list = {}
        HOUND.Coroutine._running = false
        HOUND.Coroutine._pumping = false
    end

    function TestHoundCoroutine:tearDown()
        HOUND.Coroutine.shutdown()
    end

    function TestHoundCoroutine:TestAddInvalidFunc()
        lu.assertNil(HOUND.Coroutine.add(nil))
    end

    function TestHoundCoroutine:TestAddValid()
        local id = HOUND.Coroutine.add(simpleCo)
        lu.assertIsTable(id)
        lu.assertEquals(#HOUND.Coroutine._list, 1)
        lu.assertIsTrue(HOUND.Coroutine._running)
    end

    function TestHoundCoroutine:TestAddWithOpts()
        local opts = { name = "myCo", interval = 0.1 }
        local id = HOUND.Coroutine.add(simpleCo, opts)
        lu.assertIsTable(id)
        local rec = HOUND.Coroutine._list[1]
        lu.assertEquals(rec.name, "myCo")
        lu.assertEquals(rec.interval, 0.1)
    end

    function TestHoundCoroutine:TestAddWithArgs()
        local captured
        local function cap(...) captured = {...}; coroutine.yield() end
        HOUND.Coroutine.add(cap, nil, "hello", 42)
        coroutine.resume(HOUND.Coroutine._list[1].co)
        lu.assertEquals(captured[1], "hello")
        lu.assertEquals(captured[2], 42)
    end

    function TestHoundCoroutine:TestAddMultiple()
        HOUND.Coroutine.add(simpleCo)
        HOUND.Coroutine.add(simpleCo)
        HOUND.Coroutine.add(simpleCo)
        lu.assertEquals(HOUND.Coroutine.count(), 3)
    end

    function TestHoundCoroutine:TestCancelNil()
        lu.assertFalse(HOUND.Coroutine.cancel(nil))
    end

    function TestHoundCoroutine:TestCancelValid()
        local id = HOUND.Coroutine.add(simpleCo)
        lu.assertEquals(#HOUND.Coroutine._list, 1)
        lu.assertIsTrue(HOUND.Coroutine.cancel(id))
        lu.assertEquals(#HOUND.Coroutine._list, 0)
    end

    function TestHoundCoroutine:TestCancelUnknown()
        lu.assertFalse(HOUND.Coroutine.cancel({}))
    end

    function TestHoundCoroutine:TestCancelByNameInvalid()
        lu.assertEquals(HOUND.Coroutine.cancelByName(123), 0)
    end

    function TestHoundCoroutine:TestCancelByNameValid()
        HOUND.Coroutine.add(simpleCo, { name = "A" })
        HOUND.Coroutine.add(simpleCo, { name = "A" })
        HOUND.Coroutine.add(simpleCo, { name = "B" })
        lu.assertEquals(HOUND.Coroutine.cancelByName("A"), 2)
        lu.assertEquals(HOUND.Coroutine.count(), 1)
    end

    function TestHoundCoroutine:TestCancelByNameNone()
        lu.assertEquals(HOUND.Coroutine.cancelByName("nonexistent"), 0)
    end

    function TestHoundCoroutine:TestIsRunningFalse()
        lu.assertFalse(HOUND.Coroutine.isRunning("anything"))
    end

    function TestHoundCoroutine:TestIsRunningTrue()
        HOUND.Coroutine.add(simpleCo, { name = "testCo" })
        lu.assertIsTrue(HOUND.Coroutine.isRunning("testCo"))
    end

    function TestHoundCoroutine:TestIsRunningDead()
        HOUND.Coroutine.add(quickExit, { name = "deadCo" })
        coroutine.resume(HOUND.Coroutine._list[1].co)
        lu.assertFalse(HOUND.Coroutine.isRunning("deadCo"))
    end

    function TestHoundCoroutine:TestCountZero()
        lu.assertEquals(HOUND.Coroutine.count(), 0)
    end

    function TestHoundCoroutine:TestCountNonZero()
        HOUND.Coroutine.add(simpleCo)
        HOUND.Coroutine.add(simpleCo)
        lu.assertEquals(HOUND.Coroutine.count(), 2)
    end

    function TestHoundCoroutine:TestHasWorkFalse()
        lu.assertFalse(HOUND.Coroutine.hasWork())
    end

    function TestHoundCoroutine:TestHasWorkTrue()
        HOUND.Coroutine.add(simpleCo)
        lu.assertIsTrue(HOUND.Coroutine.hasWork())
    end

    function TestHoundCoroutine:TestShutdown()
        HOUND.Coroutine.add(simpleCo)
        HOUND.Coroutine.add(simpleCo)
        HOUND.Coroutine.shutdown()
        lu.assertEquals(#HOUND.Coroutine._list, 0)
        lu.assertFalse(HOUND.Coroutine._running)
        lu.assertEquals(HOUND.Coroutine.count(), 0)
        lu.assertFalse(HOUND.Coroutine.hasWork())
    end

    function TestHoundCoroutine:TestPumpSelfCancelKeepsWalking()
        -- a record cancelling itself during resume is deferred to purgeDead and
        -- must not stop the next record from running in the same tick
        local ran = {}
        local id
        id = HOUND.Coroutine.add(function()
            ran.selfCancelled = true
            HOUND.Coroutine.cancel(id)
        end, { name = "selfCancel" })
        HOUND.Coroutine.add(function() ran.next = true end, { name = "next" })

        HOUND.Coroutine._pump()

        lu.assertIsTrue(ran.selfCancelled)
        lu.assertIsTrue(ran.next)
        lu.assertEquals(HOUND.Coroutine.count(), 0)
        lu.assertEquals(#HOUND.Coroutine._list, 0)
    end

    function TestHoundCoroutine:TestPumpShutdownThenAddDefers()
        -- shutdown during a tick marks records dead; a record added afterwards joins
        -- the list for a later tick and must not arm a second scheduling loop
        local ran = {}
        HOUND.Coroutine.add(function()
            HOUND.Coroutine.shutdown()
            HOUND.Coroutine.add(function() ran.late = true end, { name = "late" })
        end, { name = "outer" })

        local scheduled = 0
        local realSchedule = timer.scheduleFunction
        timer.scheduleFunction = function(...)
            scheduled = scheduled + 1
            return realSchedule(...)
        end
        local ok, err = pcall(HOUND.Coroutine._pump)
        timer.scheduleFunction = realSchedule

        lu.assertIsTrue(ok, tostring(err))
        lu.assertNil(ran.late)
        lu.assertEquals(scheduled, 0)
        lu.assertEquals(HOUND.Coroutine.count(), 1)
        lu.assertIsTrue(HOUND.Coroutine._running)
    end
end
