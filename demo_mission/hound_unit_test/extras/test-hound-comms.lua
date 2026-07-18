do
    function TestHoundFunctional:Test_Comms_00_HumanUnitsFunctions()
        local triggerUnit = self.eventTriggerUnit
        local triggerUnitName = triggerUnit:getName()
        lu.assertIsTrue(HOUND.Utils.Dcs.isHuman(triggerUnit))
        HOUND.DB.updateHumanDb(coalition.side.BLUE)
        lu.assertIsTrue(HOUND.Length(HOUND.DB.HumanUnits.byName[coalition.side.BLUE]) > 0)
        -- local players=HOUND.Utils.Dcs.getPlayers(coalition.side.BLUE)
        -- lu.assertEquals(HOUND.Length(players),1)
        local player = HOUND.DB.HumanUnits.byName[coalition.side.BLUE][triggerUnitName]
        lu.assertIsTable(player)
        lu.assertEquals(player.unitName,triggerUnitName)
        local playersInGrp = HOUND.Utils.Dcs.getPlayersInGroup(player.groupName)
        lu.assertEquals(HOUND.Length(playersInGrp),1)
        HOUND.Logger.debug(HOUND.Mist.utils.tableShow(playersInGrp))
        lu.assertEquals(playersInGrp[triggerUnitName].unitName,player.unitName)
    end

    function TestHoundFunctional:Test_Comms_01_CheckIn()
        -- Verify unit is correct
        local triggerUnit = self.eventTriggerUnit
        local player = HOUND.DB.HumanUnits.byName[coalition.side.BLUE][triggerUnit:getName()]
        lu.assertIsTable(player)

        -- get sector and verify
        local saipan = self.houndBlue:getSector("Saipan")
        lu.assertIsTrue(getmetatable(saipan) == HOUND.Sector)

        -- white box shananigans
        local grpMenu = saipan.comms.menu[player]
        local checkin = grpMenu.items.check_in
        lu.assertIsTable(checkin)
        HOUND.Logger.debug(HOUND.Mist.utils.tableShow(checkin))
        lu.assertEquals(HOUND.Length(checkin),3)
        lu.assertStrContains(checkin[3],saipan.comms.controller:getCallsign() ..
                        " (" .. saipan.comms.controller:getFreq() .. ") - Check In")

        lu.assertEquals(HOUND.Length(saipan.comms.enrolled),0)
        HOUND.Sector.checkIn({self=saipan,player=player})

        lu.assertEquals(HOUND.Length(saipan.comms.enrolled),1)
        grpMenu = saipan.comms.menu[player]
        checkin = grpMenu.items.check_in
        lu.assertStrContains(checkin[3],saipan.comms.controller:getCallsign() ..
                        " (" .. saipan.comms.controller:getFreq() .. ") - Check out")
    end

    function TestHoundFunctional:Test_Comms_02_MenuItems()
        local triggerUnit = self.eventTriggerUnit

        local saipan = self.houndBlue:getSector("Saipan")
        lu.assertIsTrue(getmetatable(saipan) == HOUND.Sector)
        local saipanComms = saipan.comms

        local player = HOUND.DB.HumanUnits.byName[coalition.side.BLUE][triggerUnit:getName()]
        lu.assertIsTable(player)
        lu.assertEquals(HOUND.Length(saipanComms.enrolled),1)
        lu.assertTable(saipanComms.enrolled[player.unitName])
        HOUND.Logger.debug(HOUND.Mist.utils.tableShow(saipanComms.enrolled[player.unitName]))
        lu.assertIsTrue(getmetatable(player) == getmetatable(saipanComms.enrolled[player.unitName]))

        local menuItems = saipan:getRadioItemsText()
        local keys = {}
        for k,v in ipairs(menuItems) do
            table.insert(keys,k)
        end
        lu.assertItemsEquals(keys,{'SA-3','Naval'})
    end

    function TestHoundFunctional:Test_Comms_03_CommsMenu()
        local triggerUnit = self.eventTriggerUnit

        local saipan = self.houndBlue:getSector("Saipan")
        lu.assertIsTrue(getmetatable(saipan) == HOUND.Sector)
        local saipanComms = saipan.comms
        local player = HOUND.DB.HumanUnits.byName[coalition.side.BLUE][triggerUnit:getName()]
        lu.assertIsTable(player)

        local grpMenu = saipanComms.menu[player]
        lu.assertIsTable(grpMenu)
        lu.assertIsTable(grpMenu.items)
        lu.assertIsTable(grpMenu.pages)
        lu.assertIsTable(grpMenu.objs)
        lu.assertIsNumber(grpMenu.itemCount)

        local checkin = grpMenu.items.check_in
        lu.assertIsTable(checkin)
        lu.assertEquals(HOUND.Length(checkin), 3)
        lu.assertStrContains(checkin[3], saipan.comms.controller:getCallsign() ..
            " (" .. saipan.comms.controller:getFreq() .. ") - Check out")

        local menuData = saipan:getRadioItemsText()
        for _, siteData in ipairs(menuData) do
            if type(siteData) == "table" and siteData.typeAssigned then
                local typeName = siteData.typeAssigned
                lu.assertIsTable(grpMenu.items[typeName],
                    "Missing submenu item for " .. typeName)
                lu.assertIsTable(grpMenu.objs[typeName],
                    "Missing submenu obj for " .. typeName)
            end
        end
    end

    function TestHoundFunctional:Test_Comms_04_RequestReport()
        local triggerUnit = self.eventTriggerUnit
        local saipan = self.houndBlue:getSector("Saipan")
        local player = HOUND.DB.HumanUnits.byName[coalition.side.BLUE][triggerUnit:getName()]
        lu.assertIsTable(player)

        local sites = saipan:getSites()
        lu.assertIsTrue(#sites > 0, "Saipan sector should have sites")
        local emitter = nil
        for _, site in ipairs(sites) do
            if site:hasPos() and #site.emitters > 0 then
                emitter = site.emitters[1]
                break
            end
        end
        lu.assertIsTable(emitter, "Could not find valid emitter in Saipan")

        local controller = saipan.comms.controller
        lu.assertIsTrue(controller:isEnabled())

        HOUND.Sector.TransmitSamReport({
            self = saipan,
            contact = emitter:getDcsName(),
            requester = player
        })

        local found = false
        for _, msg in ipairs(controller._queue[1]) do
            if msg.contactId == emitter:getId() and msg.gid and msg.gid[1] == player.groupId then
                found = true
                lu.assertEquals(msg.coalition, coalition.side.BLUE)
                if emitter.isEWR then
                    lu.assertEquals(msg.priority, 2, "EWR reports should have priority 2")
                else
                    lu.assertEquals(msg.priority, 1, "SAM reports should have priority 1")
                end
                lu.assertIsString(msg.tts)
                if controller:getSettings("enableText") then
                    lu.assertIsString(msg.txt)
                end
                break
            end
        end
        lu.assertIsTrue(found, "TransmitSamReport message not found in controller queue")
    end

    function TestHoundFunctional:Test_Comms_05_TinianCheckIn()
        local triggerUnit = self.eventTriggerUnit
        local player = HOUND.DB.HumanUnits.byName[coalition.side.BLUE][triggerUnit:getName()]
        lu.assertIsTable(player)

        -- Verify Tinian sector exists and has a zone
        local tinian = self.houndBlue:getSector("Tinian")
        lu.assertIsTrue(getmetatable(tinian) == HOUND.Sector)
        lu.assertIsTrue(tinian:hasZone(), "Tinian should have a zone")

        -- Enable a controller on Tinian so check-in can build a radio menu
        self.houndBlue:enableController("Tinian", {freq = "260.000", modulation = "AM"})
        lu.assertIsTrue(tinian:hasController())
        lu.assertIsTrue(tinian:isControllerEnabled())

        -- Player not yet enrolled in Tinian
        lu.assertEquals(HOUND.Length(tinian.comms.enrolled), 0)

        HOUND.Sector.checkIn({self = tinian, player = player})
        lu.assertEquals(HOUND.Length(tinian.comms.enrolled), 1)

        -- Player's Tinian menu should exist
        local grpMenu = tinian.comms.menu[player]
        lu.assertIsTable(grpMenu)
        lu.assertIsTable(grpMenu.items)
        lu.assertIsTable(grpMenu.pages)
        lu.assertIsTable(grpMenu.objs)

        local checkin = grpMenu.items.check_in
        lu.assertIsTable(checkin)
        lu.assertEquals(HOUND.Length(checkin), 3)
        lu.assertStrContains(checkin[3], "Check out")

        -- Tinian should have contacts (SA-6 emitting, SA-3 pre-briefed)
        local tinianData = tinian:getRadioItemsText()
        lu.assertIsTrue(HOUND.Length(tinianData) > 0, "Tinian should have contacts")

        for _, siteData in ipairs(tinianData) do
            if type(siteData) == "table" and siteData.typeAssigned then
                lu.assertIsTable(grpMenu.items[siteData.typeAssigned])
                lu.assertIsTable(grpMenu.objs[siteData.typeAssigned])
            end
        end
    end

    function TestHoundFunctional:Test_Comms_06_DefaultSector()
        local defaultSector = self.houndBlue:getSector("default")
        lu.assertIsTrue(getmetatable(defaultSector) == HOUND.Sector)

        -- Default sector has no zone
        lu.assertIsFalse(defaultSector:hasZone(), "Default sector should have no zone")

        -- Default sector holds fallback contacts
        local defaultContacts = defaultSector:getContacts()
        lu.assertIsTrue(#defaultContacts > 0, "Default sector shouldhold fallback contacts")

        -- Check default sector is notifiying state
        local canNotify = defaultSector:isNotifiying()
        lu.assertIsBoolean(canNotify)
    end

    function TestHoundFunctional:Test_Comms_07_TransmitAck()
        local triggerUnit = self.eventTriggerUnit
        local saipan = self.houndBlue:getSector("Saipan")
        local player = HOUND.DB.HumanUnits.byName[coalition.side.BLUE][triggerUnit:getName()]
        lu.assertIsTable(player)

        local controller = saipan.comms.controller
        lu.assertIsTrue(controller:isEnabled())

        -- Capture queue length before check-in ack test
        local queueBefore = 0
        for _ in ipairs(controller._queue[1]) do
            queueBefore = queueBefore + 1
        end

        saipan:TransmitCheckInAck(player)
        lu.assertEquals(#controller._queue[1], queueBefore + 1,
            "TransmitCheckInAck should add one message")

        local ackMsg = controller._queue[1][queueBefore + 1]
        lu.assertIsTable(ackMsg)
        lu.assertEquals(ackMsg.priority, 1)
        lu.assertEquals(ackMsg.coalition, coalition.side.BLUE)
        lu.assertEquals(ackMsg.gid[1], player.groupId)
        lu.assertIsString(ackMsg.tts)
        lu.assertStrContains(ackMsg.tts, "Roger")

        -- Capture queue length before check-out ack test
        local queueBefore2 = 0
        for _ in ipairs(controller._queue[1]) do
            queueBefore2 = queueBefore2 + 1
        end

        saipan:TransmitCheckOutAck(player)
        lu.assertEquals(#controller._queue[1], queueBefore2 + 1,
            "TransmitCheckOutAck should add one message")

        local outMsg = controller._queue[1][queueBefore2 + 1]
        lu.assertIsTable(outMsg)
        lu.assertEquals(outMsg.priority, 1)
        lu.assertEquals(outMsg.coalition, coalition.side.BLUE)
        lu.assertEquals(outMsg.gid[1], player.groupId)
        lu.assertIsString(outMsg.tts)
        lu.assertStrContains(outMsg.tts, "checking out")
    end

    function TestHoundFunctional:Test_Comms_09_CheckOut()
        local triggerUnit = self.eventTriggerUnit

        -- get sector and verify
        local saipan = self.houndBlue:getSector("Saipan")
        lu.assertIsTrue(getmetatable(saipan) == HOUND.Sector)
        local saipanComms = saipan.comms

        lu.assertEquals(HOUND.Length(saipanComms.enrolled),1)
        local player = HOUND.DB.HumanUnits.byName[coalition.side.BLUE][triggerUnit:getName()]
        lu.assertIsTable(player)
        local grpMenu = saipan.comms.menu[player]
        local checkin = grpMenu.items.check_in
        lu.assertIsTable(checkin)
        lu.assertEquals(HOUND.Length(checkin),3)
        lu.assertStrContains(checkin[3],saipan.comms.controller:getCallsign() ..
                        " (" .. saipan.comms.controller:getFreq() .. ") - Check out")
        HOUND.Sector.checkOut({self=saipan,player=player})
        lu.assertEquals(HOUND.Length(saipanComms.enrolled),0)
        grpMenu = saipan.comms.menu[player]
        checkin = grpMenu.items.check_in
        lu.assertStrContains(checkin[3],saipan.comms.controller:getCallsign() ..
                        " (" .. saipan.comms.controller:getFreq() .. ") - Check In")
    end

end