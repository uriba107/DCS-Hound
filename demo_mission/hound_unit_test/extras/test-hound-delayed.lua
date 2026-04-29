do
    -- extends TestHoundFunctional 
    TestHoundFunctional.baseUnitCount = {
        platforms = 2,
        sectors = 3,
        zones = 2,
        controllers = 2,
        atis = 2,
        notifiers = 1,
        sites = 3,
        contacts = 5,
        preBriefed = 4,
        active = 2
    }

    function TestHoundFunctional:setBaseUnitCount()
        local debugStr = self.houndBlue:printDebugging()
        local pattern = "Platforms: (%d+) | sectors: (%d+) %(Z:(%d+) ,C:(%d+) ,A: (%d+) ,N:(%d+)%) | Sites: (%d+) | Contacts: (%d+) %(A:(%d+) ,PB:(%d+)%)"
        local p, s, z, c, a, n, si, co, ca, cp = debugStr:match(pattern)

        if p then
            self.baseUnitCount = {
                platforms = tonumber(p),
                sectors = tonumber(s),
                zones = tonumber(z),
                controllers = tonumber(c),
                atis = tonumber(a),
                notifiers = tonumber(n),
                sites = tonumber(si),
                contacts = tonumber(co),
                active = tonumber(ca),
                preBriefed = tonumber(cp)
            }
        end
    end

    function TestHoundFunctional:Test_2mDelay_00_updateBaseline()
        self:setBaseUnitCount()
    end
    function TestHoundFunctional:Test_2mDelay_01_debugOutput()
        local delayTest = function (expectedStr)
            lu.assertStrContains(self.houndBlue:printDebugging(),expectedStr)
        end
        local delayMove = function()
            Group.getByName("TOR_SAIPAN"):getController():setSpeed(50)
        end
        self.houndBlue:preBriefedContact('SA-5_SAIPAN')

        lu.assertEquals(self.houndBlue:countPreBriefedContacts(),4)
        lu.assertStrContains(self.houndBlue:printDebugging(),string.format("| Sites: %d | Contacts: %d (A:%d ,PB:%d)",
                self.baseUnitCount.sites,self.baseUnitCount.contacts,self.baseUnitCount.active,self.baseUnitCount.preBriefed))
        self.houndBlue:preBriefedContact('EWR_SAIPAN')
        lu.assertEquals(self.houndBlue:countPreBriefedContacts(),5)
        local tor = Group.getByName("TOR_SAIPAN")
        tor:enableEmission(false)
        self.houndBlue:preBriefedContact(tor:getName())
        lu.assertEquals(self.houndBlue:countPreBriefedContacts(),6)

        local sa5 = Group.getByName('SA-5_SAIPAN')
        sa5:enableEmission(true)

        assert(timer.scheduleFunction(delayTest,string.format("| Sites: %d | Contacts: %d (A:%d ,PB:%d)",
            self.baseUnitCount.sites,self.baseUnitCount.contacts-1,self.baseUnitCount.active-1,self.baseUnitCount.preBriefed
        ),timer.getTime()+90))
        assert(timer.scheduleFunction(delayMove,nil,timer.getTime()+60))
    end

    function TestHoundFunctional:Test_2mDelay_02_Sector()
        local sites = self.houndBlue.contacts:listAllSites()
        lu.assertEquals(HOUND.Length(sites),4)
        for _,site in ipairs(sites) do
            lu.assertEquals(getmetatable(site),HOUND.Contact.Site)
        end
    end
    function TestHoundFunctional:Test_2mDelay_03_EventHandler()
        lu.assertEquals(type(self.houndBlue.onHoundEvent),"function")
        lu.assertIsNil(self.houndBlue:onHoundEvent({HoundId = self.houndBlue:getId(),id = "updated"}))
        function self.houndBlue:onHoundEvent(event)
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
            if event.id == "updated" then return true end
            if event.id == HOUND.EVENTS.RADAR_DESTROYED then
                env.info("HOUND.EVENTS.RADAR_DESTROYED for " .. event.initiator:getDcsName() )
                lu.assertEquals(event.initiator:getDcsGroupName(),"SA-5_SAIPAN")
                local grp = Group.getByName(event.initiator:getDcsGroupName())
                local grpSize = grp:getSize()
                local lastUnit = grp:getUnit(grpSize)
                if grpSize >=7 then
                    lu.assertIsTrue(lastUnit:hasSensors(Unit.SensorType.RADAR))
                    destroyObject(grp:getUnit(1))
                else
                    lu.assertIsFalse(lastUnit:hasSensors(Unit.SensorType.RADAR))
                end
            end
            if event.id == HOUND.EVENTS.SITE_ASLEEP then
                env.info("HOUND.EVENTS.SITE_ASLEEP for " .. event.initiator:getDcsName() )
                if event.initiator:getDcsGroupName() == "SA-5_SAIPAN" then
                    lu.assertEquals(event.initiator:getDcsGroupName(),"SA-5_SAIPAN")
                    lu.assertIsFalse(event.initiator:hasRadarUnits())
                elseif event.initiator:getDcsGroupName() == "SA-6_TINIAN" then
                    lu.assertEquals(event.initiator:getDcsGroupName(),"SA-6_TINIAN")
                    lu.assertIsTrue(event.initiator:hasRadarUnits())
                end
            end
            if event.id == HOUND.EVENTS.SITE_REMOVED then
                lu.assertEquals(event.initiator:getDcsGroupName(),"SA-5_SAIPAN")
                lu.assertEquals(event.initiator:countEmitters(),0)
                lu.assertIsFalse(event.initiator:hasRadarUnits())
                lu.assertStrContains(self:printDebugging(),string.format("| Sites: %d | Contacts: %d (A:%d ,PB:%d)",
                    TestHoundFunctional.baseUnitCount.platforms,
                    TestHoundFunctional.baseUnitCount.sectors,TestHoundFunctional.baseUnitCount.zones,TestHoundFunctional.baseUnitCount.controllers,TestHoundFunctional.baseUnitCount.atis,TestHoundFunctional.baseUnitCount.notifiers,
                    TestHoundFunctional.baseUnitCount.sites,TestHoundFunctional.baseUnitCount.contacts-1,TestHoundFunctional.baseUnitCount.active-1,TestHoundFunctional.baseUnitCount.preBriefed))
            end
        end
        lu.assertEquals(type(self.houndBlue.onHoundEvent),"function")
        lu.assertIsTrue(self.houndBlue:onHoundEvent({HoundId = self.houndBlue:getId(),id = "updated"}))
    end

    function TestHoundFunctional:Test_2mDelay_04_destroy()
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

    function TestHoundFunctional:Test_2mDelay_05_ships()
        local ships = Group.getByName('SHIPS_NORTH')
        lu.assertIsTrue(HOUND.Utils.Dcs.isGroup(ships))
        lu.assertEquals(ships:getSize(),2)
        ships:enableEmission(true)
    end

    function TestHoundFunctional:Test_6mDelay_00_updateBaseline()
        self:setBaseUnitCount()
    end

    function TestHoundFunctional:Test_6mDelay_01_preBriefed()
        function delayTest(expectedStr)
            lu.assertEquals(self.houndBlue:countPreBriefedContacts(),3)
            lu.assertStrContains(self.houndBlue:printDebugging(),expectedStr)
        end
        self.houndBlue:onScreenDebug(true)

        lu.assertStrContains(self.houndBlue:printDebugging(),string.format("| Sites: %d | Contacts: %d (A:%d ,PB:%d)",
            self.baseUnitCount.sites+1,self.baseUnitCount.contacts+1,self.baseUnitCount.active+1,self.baseUnitCount.preBriefed)
        )
        local tor = Group.getByName("TOR_SAIPAN")
        tor:enableEmission(true)
        assert(timer.scheduleFunction(delayTest,string.format("| Sites: %d | Contacts: %d (A:%d ,PB:%d)",
            self.baseUnitCount.sites+2,self.baseUnitCount.contacts+2,self.baseUnitCount.active+3,self.baseUnitCount.preBriefed-1
        ),timer.getTime()+45))
    end

    function TestHoundFunctional:Test_6mDelay_02_exports()
        self.houndBlue:dumpIntelBrief()
    end

    function TestHoundFunctional:Test_6mDelay_03_boats()
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

    function TestHoundFunctional:Test_6mDelay_04_shoot()
        function delayTest(expectedStr)
            lu.assertStrContains(self.houndBlue:printDebugging(),expectedStr)
        end
        shootEvent = {}
        shootEvent.HoundInstance = self.houndBlue
        function shootEvent:onEvent(DcsEvent)
            if DcsEvent.id == world.event.S_EVENT_SHOT and self.HoundInstance then
                if self.HoundInstance and DcsEvent.initiator and DcsEvent.initiator:getCoalition() ~= self.HoundInstance:getCoalition()
                    and ( DcsEvent.initiator:getGroup() == Group.getByName("SA-6_TINIAN") )
                then
                    local tgt = DcsEvent.weapon:getTarget()
                    local uav = Unit.getByName("MQ-9_TGT")
                    lu.assertItemsEquals(tgt,uav)
                    HOUND.Logger.info("SA-6 fired on UAV")
                end
            end
        end
        function shootEvent:onHoundEvent(houndEvent)
            if houndEvent.houndId ~= self.HoundInstance.settings:getId() then
                -- HOUND.Logger.trace("Processing Event " .. HOUND.reverseLookup(HOUND.EVENTS,houndEvent.id) .. " for myself? " .. tostring(houndEvent.houndId == self:getId()))
                return
            end 
            if houndEvent.id == HOUND.EVENTS.SITE_LAUNCH then
                lu.assertEquals(getmetatable(houndEvent.initiator),HOUND.Contact.Site)
                local grp = houndEvent.initiator.DcsObject
                lu.assertIsTrue(HOUND.Utils.Dcs.isGroup(grp))
                lu.assertEquals("SA-6_TINIAN",grp:getName())
            end           
        end
        world.addEventHandler(shootEvent)
        HOUND.EventHandler.addEventHandler(shootEvent)
        
        local uavgrp = Unit.getByName("MQ-9_TGT"):getGroup()
        local SA6 = Group.getByName("SA-6_TINIAN")
        lu.assertIsTrue(HOUND.Utils.Dcs.isGroup(uavgrp))
        lu.assertIsTrue(HOUND.Utils.Dcs.isGroup(SA6))
        SA6:enableEmission(true)

        -- lu.assertIsFalse(uavgrp:isExist())
        uavgrp:activate()
        -- lu.assertIsTrue(uavgrp:isExist())
        local sam_brain = SA6:getUnit(1):getController()
        sam_brain:knowTarget(Unit.getByName("MQ-9_TGT"))
        assert(timer.scheduleFunction(delayTest,string.format("| Sites: %d | Contacts: %d (A:%d ,PB:%d)",
            self.baseUnitCount.sites+2,self.baseUnitCount.contacts+2,self.baseUnitCount.active+3,self.baseUnitCount.preBriefed-1
        ),timer.getTime()+120))
    end
end