do
    -- extends TestHoundFunctional 
    function TestHoundFunctional:Test_1mDelay_00_debugOutput()
        local delayTest = function (expectedStr)
            -- env.info(self.houndBlue:printDebugging())
            lu.assertStrContains(self.houndBlue:printDebugging(),expectedStr)
        end
        local delayMove = function()
            Group.getByName("TOR_SAIPAN"):getController():setSpeed(20)
        end
        lu.assertEquals(self.houndBlue:countPreBriefedContacts(),2)
        lu.assertStrContains(self.houndBlue:printDebugging(),"Platforms: 2 | sectors: 3 (Z:2 ,C:2 ,A: 2 ,N:1) | Contacts: 3 (A:1 ,PB:2)")
        self.houndBlue:preBriefedContact('EWR_SAIPAN')
        lu.assertEquals(self.houndBlue:countPreBriefedContacts(),3)
        local tor = Group.getByName("TOR_SAIPAN")
        tor:enableEmission(false)
        self.houndBlue:preBriefedContact(tor:getName())
        lu.assertEquals(self.houndBlue:countPreBriefedContacts(),4)
        timer.scheduleFunction(delayTest,"Platforms: 2 | sectors: 3 (Z:2 ,C:2 ,A: 2 ,N:1) | Contacts: 4 (A:1 ,PB:4)",timer.getTime()+20)
        timer.scheduleFunction(delayMove,nil,timer.getTime()+30)
    end

    function TestHoundFunctional:Test_5mDelay_00_preBriefed()
        self.houndBlue:onScreenDebug(true)

        local delayTest = function (expectedStr)
            -- env.info(self.houndBlue:printDebugging())
            lu.assertEquals(self.houndBlue:countPreBriefedContacts(),3)
            lu.assertStrContains(self.houndBlue:printDebugging(),expectedStr)
        end

        -- env.info(self.houndBlue:printDebugging())
        lu.assertStrContains(self.houndBlue:printDebugging(),"Platforms: 2 | sectors: 3 (Z:2 ,C:2 ,A: 2 ,N:1) | Contacts: 4 (A:1 ,PB:4)")
        local tor = Group.getByName("TOR_SAIPAN")
        tor:enableEmission(true)
        timer.scheduleFunction(delayTest,"Platforms: 2 | sectors: 3 (Z:2 ,C:2 ,A: 2 ,N:1) | Contacts: 4 (A:2 ,PB:3)",timer.getTime()+30)

    end
end