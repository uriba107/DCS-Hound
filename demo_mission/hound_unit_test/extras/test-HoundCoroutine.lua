do
    TestHoundCoroutine = {}

    local function simpleCo() coroutine.yield() end

    local function quickExit() return 42 end

    function TestHoundCoroutine:setUp()
        HOUND.Coroutine.shutdown()
        HOUND.Coroutine._list = {}
        HOUND.Coroutine._running = false
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
end
