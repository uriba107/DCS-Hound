do
    function TestHoundFunctional:Test_Comms_00_HumanUnitsFunctions()
        local triggerUnit = self.eventTriggerUnit
        local triggerUnitName = triggerUnit:getName()
        lu.assertIsTrue(HOUND.Utils.Dcs.isHuman(triggerUnit))
        HOUND.DB.updateHumanDb(coalition.side.BLUE)
        lu.assertEquals(HOUND.Length(HOUND.DB.HumanUnits.byName[coalition.side.BLUE]),1)
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
        lu.assertTable(saipanComms.enrolled[player])
        HOUND.Logger.debug(HOUND.Mist.utils.tableShow(saipanComms.enrolled[player]))
        lu.assertIsTrue(getmetatable(player) == getmetatable(saipanComms.enrolled[player]))

        local menuItems = saipan:getRadioItemsText()
        local keys = {}
        for k,v in menuItems do
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
        -- TODO: test actual menu structure
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
        lu.assertStrContains(checkin[3],saipan.comms.controller:getCallsign() .. 
                        " (" .. saipan.comms.controller:getFreq() .. ") - Check In")
    end

end