do
    TestHoundDelayed1 = {}

    function TestHoundDelayed1:setUp()
        collectgarbage("collect")
    end

    function TestHoundDelayed1:tearDown()
        collectgarbage("collect")
    end

    function TestHoundDelayed1:03_base_00_low_accuracy()
        lu.assertEquals(self.houndBlue:countPlatforms(),2)
        lu.assertItemsEquals(self.houndBlue:listPlatforms(),{"ELINT_BLUE_C17_WEST","ELINT_BLUE_C17_EAST"})

        -- lu.assertIsTrue(self.houndBlue:removePlatform("ELINT_BLUE_C17_EAST"))
        -- lu.assertIsTrue(self.houndBlue:removePlatform("ELINT_BLUE_C17_WEST"))
        -- lu.assertIsTrue(self.houndBlue:addPlatform("ELINT_BLUE_E3_EAST"))
        -- lu.assertIsTrue(self.houndBlue:addPlatform("ELINT_BLUE_E3_WEST"))

        -- lu.assertEquals(self.houndBlue:countPlatforms(),2)
        -- lu.assertItemsEquals(self.houndBlue:listPlatforms(),{"ELINT_BLUE_C17_WEST","ELINT_BLUE_E3_EAST"})
    end
end