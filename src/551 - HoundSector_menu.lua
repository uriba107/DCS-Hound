--- HOUND.Sector
-- @module HOUND.Sector

do
    local l_mist = HOUND.Mist
    -------------- Radio Menu stuff -----------------------------
    --- Radio Menu
    -- @section menu

    --- generate menu cache
    -- @local
    -- @return #table radio items text
    function HOUND.Sector:getRadioItemsText()
        local menuItems = {
            ['noData'] = "No radars are currently tracked"
        }
        local sites = self:getSites()
        if HOUND.Length(sites) > 0 then
            menuItems.noData = nil
            for _, site in ipairs(sites) do
                -- local typeAssigned = site:getTypeAssigned()
                -- local grpName = site:getDcsName()
                if site:getPos() then
                    table.insert(menuItems,site:getRadioItemsText())
                end
            end
        end
        return menuItems
    end

    --- create check menu items for players
    -- @local
    function HOUND.Sector:createCheckIn()
        -- unsubscribe disconnected users
        for _,player in pairs(self.comms.enrolled) do
            local playerUnit = Unit.getByName(player.unitName)
            if not HOUND.Utils.Dcs.isHuman(playerUnit) then
                    self.comms.enrolled[player.unitName] = nil
            end
        end
        -- now do work
        grpMenuDone = {}
        -- for _,player in pairs(l_mist.DBs.humansByName) do
        for _,player in pairs(HOUND.DB.HumanUnits.byName[self._hSettings:getCoalition()]) do
            local grpId = player.groupId
            local playerUnit = Unit.getByName(player.unitName)
            -- if playerUnit and not grpMenuDone[grpId] and playerUnit:getCoalition() == self._hSettings:getCoalition() then
            if playerUnit and not grpMenuDone[grpId] then
                grpMenuDone[grpId] = true

                if not self.comms.menu[player] then
                    self.comms.menu[player] = self:getMenuObj()
                end

                local grpMenu = self.comms.menu[player]
                local grpPage = self:getMenuPage(grpMenu,grpId,self.comms.menu.root)
                if grpMenu.items.check_in ~= nil then
                    grpMenu.items.check_in = missionCommands.removeItemForGroup(grpId,grpMenu.items.check_in)
                end

                if HOUND.setContainsValue(self.comms.enrolled, player) then
                    grpMenu.items.check_in =
                        missionCommands.addCommandForGroup(grpId,
                                            self.comms.controller:getCallsign() .. " (" ..
                                            self.comms.controller:getFreq() ..") - Check out",
                                            grpPage,HOUND.Sector.checkOut,
                                            {
                                                self = self,
                                                player = player
                                            })
                else
                    grpMenu.items.check_in =
                        missionCommands.addCommandForGroup(grpId,
                                                        self.comms.controller:getCallsign() ..
                                                            " (" ..
                                                            self.comms.controller:getFreq() ..
                                                            ") - Check In",
                                                            grpPage,
                                                        HOUND.Sector.checkIn, {
                            self = self,
                            player = player
                        })
                end
            end
        end
    end

    --- Populate sector radio menu
    function HOUND.Sector:populateRadioMenu()
        if self.comms.menu.root ~= nil then
            self.comms.menu.root =
                missionCommands.removeItemForCoalition(self._hSettings:getCoalition(),self.comms.menu.root)
                self.comms.menu.root = nil
        end

        if not self.comms.controller or not self.comms.controller:isEnabled() then return end
        -- local players = HOUND.DB.HumanUnits.byName[self._hSettings:getCoalition()]

        if HOUND.Length(self.comms.menu) > 0 then
            for player,grpMenu in pairs(self.comms.menu) do
                -- do cleanup for pages
                -- local player = players[playerName]
                self:removeMenuItems(grpMenu,player.groupId)
            end
        end

        if not self.comms.menu.root then
            self.comms.menu.root =
            missionCommands.addSubMenuForCoalition(self._hSettings:getCoalition(),
                                               self.name,
                                               self._hSettings:getRadioMenu())
        end
        self:validateEnrolled()
        self:createCheckIn()
        local sitesData = self:getRadioItemsText()
        local typesSpotted = {}

        if HOUND.setContains(sitesData.noData) and
            not self.comms.menu.noData then
                self.comms.menu.noData = missionCommands.addCommandForCoalition(self._hSettings:getCoalition(),
                            sitesData.noData,
                            self.comms.menu.root, timer.getAbsTime)
        end

        if not HOUND.setContains(sitesData.noData) then
            if self.comms.menu.noData ~= nil then
                self.comms.menu.noData = missionCommands.removeItemForCoalition(self._hSettings:getCoalition(),
                self.comms.menu.noData)
            end
        end

        local grpMenuDone = {}
        if HOUND.Length(self.comms.enrolled) > 0 then
            if HOUND.Length(sitesData) and not HOUND.setContains(sitesData.noData) then
                -- do all the caching needed
                for _,siteData in ipairs(sitesData) do
                    if not HOUND.setContainsValue(typesSpotted,siteData.typeAssigned) then
                        table.insert(typesSpotted,siteData.typeAssigned)
                    end
                end
            end
            -- start building menues
            for _, player in pairs(self.comms.enrolled) do
                local grpId = player.groupId
                local grpMenu = self.comms.menu[player]

                if not grpMenuDone[grpId] and grpMenu ~= nil then
                    grpMenuDone[grpId] = true

                    if not grpMenu.pages then
                        grpMenu.pages = {}
                    end
                    if not grpMenu.items then
                        grpMenu.items = {}
                    end
                    if not grpMenu.objs then
                        grpMenu.objs = {}
                    end

                    -- create submenues for typeAssigned
                    for _,typeAssigned in ipairs(typesSpotted) do
                        local newObj = self:getMenuObj()
                        local grpPage = self:getMenuPage(grpMenu,grpId,self.comms.menu.root)
                        grpMenu.items[typeAssigned] = missionCommands.addSubMenuForGroup(grpId,typeAssigned,grpPage)
                        self:getMenuPage(newObj,grpId,grpMenu.items[typeAssigned])
                        grpMenu.objs[typeAssigned] = newObj
                    end

                    -- local dataMenu = grpMenu.data
                    for _, siteData in ipairs(sitesData) do
                        local typeMenu = grpMenu.objs[siteData.typeAssigned]
                        self:removeSiteRadioItems(typeMenu,player,siteData)
                        self:addSiteRadioItems(typeMenu,player,siteData)
                    end
                end
            end
        end
    end

    --- recursivly clean out a menu
    -- @param menu
    -- @param grpId GroupId to remove from
    function HOUND.Sector:removeMenuItems(menu,grpId)
        if HOUND.Length(menu.objs) > 0 then
            for objName,obj in pairs (menu.objs) do
                menu.objs[objName]=self:removeMenuItems(obj,grpId)
            end
        end
        if HOUND.Length(menu.items) > 0 then
            for itemName,item in pairs(menu.items) do
                menu.items[itemName]=missionCommands.removeItemForGroup(grpId,item)
            end
        end
        if HOUND.Length(menu.pages) > 0 then
            for idx,page in ipairs(menu.pages) do
                if page ~= nil then
                   menu.pages[idx] = missionCommands.removeItemForGroup(grpId,page)
                end
            end
        end
        return nil
    end

    --- Handle menu pagination
    -- @local
    -- @param menu to paginate
    -- @param grpId group Id for menus
    -- @param parent root menu if required
    -- @return reference to the current page to use
    function HOUND.Sector:getMenuPage(menu,grpId,parent)
        if not menu or type(grpId) ~= "number" then return end

        if not menu.pages then
            menu.pages = {}
        end
        if not menu.items then
            menu.items = {}
        end
        if not menu.objs then
            menu.objs = {}
        end
        if HOUND.Length(menu.pages) == 0 and type(parent) == "table" then
            table.insert(menu.pages,parent)
        end

        local totalItems = (HOUND.Length(menu.items) + #menu.pages)-1
        if (totalItems == HOUND.MENU_PAGE_LENGTH) or (totalItems % #menu.pages) == HOUND.MENU_PAGE_LENGTH then
            -- menu.items['page_'..#menu.pages+1] = missionCommands.addSubMenuForGroup(grpId,"More (Page " .. #menu.pages+1 .. ")", menu.pages['page_'..#menu.pages])
            -- table.insert(menu.pages,menu.items['page_'..#menu.pages+1])
            table.insert(menu.pages,missionCommands.addSubMenuForGroup(grpId,"More (Page " .. #menu.pages+1 .. ")", menu.pages[#menu.pages]))
        end
        return menu.pages[#menu.pages]
    end

    --- get new menu object
    -- @local
    -- @return table
    function HOUND.Sector:getMenuObj()
        return {
            objs = {},
            pages = {},
            items = {}
        }
    end

    --- create site menu item
    -- @local
    -- @param typeMenu table containg the assigned type menu
    -- @param requester MIST player object
    -- @param siteData #table of site from menu cache
    function HOUND.Sector:addSiteRadioItems(typeMenu,requester,siteData)
        local playerGid = requester.groupId
        local typePage = self:getMenuPage(typeMenu,playerGid)
        local siteObj = self:getMenuObj()

        typeMenu.items[siteData.dcsName] = missionCommands.addSubMenuForGroup(playerGid, siteData.txt, typePage)
        typeMenu.objs[siteData.dcsName] = siteObj

        for _,emitterData in ipairs(siteData.emitters) do
            local sitePage = self:getMenuPage(typeMenu.objs[siteData.dcsName],playerGid,typeMenu.items[siteData.dcsName])
            siteObj.items[emitterData.dcsName] = missionCommands.addCommandForGroup(playerGid, emitterData.txt, sitePage, self.TransmitSamReport,{self=self,contact=emitterData.dcsName,requester=requester})
        end
    end

    --- remove radar menu items
    -- @local
    -- @param typeMenu table contaning a menu structure for the group
    -- @param requester mist human player object
    -- @param siteData #table of site from menu cache
    function HOUND.Sector:removeSiteRadioItems(typeMenu,requester,siteData)

        if not self.comms.controller or not self.comms.controller:isEnabled() or not typeMenu or not requester then
            return
        end
        local playerGid = requester.groupId

        local siteObj = typeMenu.objs[siteData.dcsName]
        if HOUND.setContains(siteObj,'items') then
            for emitterName,emitter in (siteObj.items) do
                siteObj.items[emitterName] = missionCommands.removeItemForGroup(playerGid,emitter)
            end
        end

        if HOUND.setContains(typeMenu.items[siteData.dcsName]) then
            typeMenu.items[siteData.dcsName] = missionCommands.removeItemForGroup(playerGid,typeMenu.items[siteData.dcsName] )
        end
    end
end