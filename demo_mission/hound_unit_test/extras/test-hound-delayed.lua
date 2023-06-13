do
    -- extends TestHoundFunctional 
    function TestHoundFunctional:Test_1mDelay_00_debugOutput()
        local delayTest = function (expectedStr)
            -- env.info(self.houndBlue:printDebugging())
            lu.assertStrContains(self.houndBlue:printDebugging(),expectedStr)
        end
        local delayMove = function()
            Group.getByName("TOR_SAIPAN"):getController():setSpeed(50)
        end
        self.houndBlue:preBriefedContact('SA-5_SAIPAN')

        lu.assertEquals(self.houndBlue:countPreBriefedContacts(),2)
        lu.assertStrContains(self.houndBlue:printDebugging(),"Platforms: 2 | sectors: 3 (Z:2 ,C:2 ,A: 2 ,N:1) | Sites: 2 | Contacts: 3 (A:1 ,PB:2)")
        self.houndBlue:preBriefedContact('EWR_SAIPAN')
        lu.assertEquals(self.houndBlue:countPreBriefedContacts(),3)
        local tor = Group.getByName("TOR_SAIPAN")
        tor:enableEmission(false)
        self.houndBlue:preBriefedContact(tor:getName())
        lu.assertEquals(self.houndBlue:countPreBriefedContacts(),4)

        local sa5 = Group.getByName('SA-5_SAIPAN')
        sa5:enableEmission(true)

        timer.scheduleFunction(delayTest,"Platforms: 2 | sectors: 3 (Z:2 ,C:2 ,A: 2 ,N:1) | Sites: 3 | Contacts: 4 (A:2 ,PB:4)",timer.getTime()+45)
        timer.scheduleFunction(delayMove,nil,timer.getTime()+60)
    
    end

    function TestHoundFunctional:Test_1mDelay_01_Sector()
        local sites = self.houndBlue.contacts:listAllSites()
        lu.assertEquals(3,HOUND.Length(sites))
        for _,site in ipairs(sites) do
            lu.assertEquals(getmetatable(site),HOUND.Contact.Site)
        end

    end

    function TestHoundFunctional:Test_5mDelay_00_preBriefed()
        self.houndBlue:onScreenDebug(true)

        local delayTest = function (expectedStr)
            -- env.info(self.houndBlue:printDebugging())
            lu.assertEquals(self.houndBlue:countPreBriefedContacts(),3)
            lu.assertStrContains(self.houndBlue:printDebugging(),expectedStr)
        end

        -- env.info(self.houndBlue:printDebugging())
        lu.assertStrContains(self.houndBlue:printDebugging(),"Platforms: 2 | sectors: 3 (Z:2 ,C:2 ,A: 2 ,N:1) | Sites: 3 | Contacts: 4 (A:2 ,PB:4)")
        local tor = Group.getByName("TOR_SAIPAN")
        tor:enableEmission(true)
        timer.scheduleFunction(delayTest,"Platforms: 2 | sectors: 3 (Z:2 ,C:2 ,A: 2 ,N:1) | Sites: 3 | Contacts: 4 (A:3 ,PB:3)",timer.getTime()+45)

    end
end