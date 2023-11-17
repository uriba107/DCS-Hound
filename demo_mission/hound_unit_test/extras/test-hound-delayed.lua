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

        lu.assertEquals(self.houndBlue:countPreBriefedContacts(),4)
        lu.assertStrContains(self.houndBlue:printDebugging(),"Platforms: 2 | sectors: 3 (Z:2 ,C:2 ,A: 2 ,N:1) | Sites: 3 | Contacts: 5 (A:2 ,PB:4)")
        self.houndBlue:preBriefedContact('EWR_SAIPAN')
        lu.assertEquals(self.houndBlue:countPreBriefedContacts(),5)
        local tor = Group.getByName("TOR_SAIPAN")
        tor:enableEmission(false)
        self.houndBlue:preBriefedContact(tor:getName())
        lu.assertEquals(self.houndBlue:countPreBriefedContacts(),6)

        local sa5 = Group.getByName('SA-5_SAIPAN')
        sa5:enableEmission(true)

        timer.scheduleFunction(delayTest,"Platforms: 2 | sectors: 3 (Z:2 ,C:2 ,A: 2 ,N:1) | Sites: 5 | Contacts: 8 (A:4 ,PB:6)",timer.getTime()+45)
        timer.scheduleFunction(delayMove,nil,timer.getTime()+60)

    end

    function TestHoundFunctional:Test_1mDelay_01_Sector()
        local sites = self.houndBlue.contacts:listAllSites()
        lu.assertEquals(HOUND.Length(sites),4)
        for _,site in ipairs(sites) do
            lu.assertEquals(getmetatable(site),HOUND.Contact.Site)
        end
    end

    function TestHoundFunctional:Test_1mDelay_02_destroy()
        function delayTest(expectedStr)
            lu.assertStrContains(self.houndBlue:printDebugging(),expectedStr)
        end

        local function destroyObject(DcsObject)
            local units = {}
            if getmetatable(DcsObject) == Unit then
                table.insert(units,DcsObject)
            end
            if getmetatable(DcsObject) == Group then
                units = DcsObject:getUnits()
            end

            for i=#units,1,-1 do
                local unit = units[i]
                local pos = unit:getPoint()
                local life0 = unit:getLife0()
                local life = unit:getLife()
                local name = unit:getName()
                local ittr = 1
                while life > 1 and ittr < 10 do
                    -- local pwr = math.max(0.0055,(life-1)/life0)
                    local pwr = life0*2
                    env.info(ittr .. " | " .. name .. " has " .. life .. " HP, started with " .. life0 .. " explody power: " .. pwr)
                    trigger.action.explosion(pos,pwr)
                    life = unit:getLife()
                    ittr = ittr+1
                end
            end
        end

        self.houndBlue:enableBDA()
        lu.assertIsTrue(self.houndBlue:getBDA())
        local grp = Group.getByName('SA-5_SAIPAN')
        lu.assertIsTrue(HOUND.Utils.Dcs.isGroup(grp))
        lu.assertEquals(grp:getSize(),8)

        destroyObject(grp:getUnit(2)) -- nuke TR first
    end

    function TestHoundFunctional:Test_1mDelay_03_ships()
        local ships = Group.getByName('SHIPS_NORTH')
        lu.assertIsTrue(HOUND.Utils.Dcs.isGroup(ships))
        lu.assertEquals(ships:getSize(),2)
        ships:enableEmission(true)
    end

    function TestHoundFunctional:Test_5mDelay_00_preBriefed()
        function delayTest(expectedStr)
            -- env.info(self.houndBlue:printDebugging())
            lu.assertEquals(self.houndBlue:countPreBriefedContacts(),3)
            lu.assertStrContains(self.houndBlue:printDebugging(),expectedStr)
        end
        self.houndBlue:onScreenDebug(true)

        lu.assertStrContains(self.houndBlue:printDebugging(),"Platforms: 2 | sectors: 3 (Z:2 ,C:2 ,A: 2 ,N:1) | Sites: 5 | Contacts: 8 (A:4 ,PB:6)")
        local tor = Group.getByName("TOR_SAIPAN")
        tor:enableEmission(true)
        timer.scheduleFunction(delayTest,"Platforms: 2 | sectors: 3 (Z:2 ,C:2 ,A: 2 ,N:1) | Sites: 5 | Contacts: 8 (A:4 ,PB:6)",timer.getTime()+45)
    end

    function TestHoundFunctional:Test_5mDelay_01_exports()
        self.houndBlue:dumpIntelBrief()
    end

    function TestHoundFunctional:Test_5mDelay_02_boats()
        local sector = self.houndBlue:getSector("default")
        local loopData = {
            reportIdx = 'A',
            body = "",
            msg = {}
        }
        sector:generateAtis(loopData,{reportewr = false })
        local msg = loopData.msg.tts
        lu.assertStrContains(msg,"Kirov (CG)")
        lu.assertStrContains(msg,"Moskva (CG)")
    end
end