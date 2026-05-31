    --- HOUND.Sector
    -- @module HOUND.Sector
do
    local l_mist = HOUND.Mist
    local l_math = math
    local HoundUtils = HOUND.Utils

    --- HOUND.Sector
    -- @type HOUND.Sector
    -- @within HOUND.Sector
    HOUND.Sector = {}
    HOUND.Sector.__index = HOUND.Sector

    --- Create sectors
    -- @param HoundId Hound Instance ID
    -- @param name Sector name
    -- @param[opt] settings Sector settings table
    -- @param[opt] priority Priority for the sector
    function HOUND.Sector.create(HoundId, name, settings, priority)
        if type(HoundId) ~= "number" or type(name) ~= "string" then
            HOUND.Logger.warn("[Hound] - HOUND.Sector.create() missing params")
            return
        end

        local instance = {}
        setmetatable(instance, HOUND.Sector)
        instance.name = name
        instance._hSettings = HOUND.Config.get(HoundId)
        instance._contacts = HOUND.ContactManager.get(HoundId)
        instance.callsign = "HOUND"
        instance.settings = {
            controller = nil,
            atis = nil,
            notifier = nil,
            transmitter = nil,
            zone = nil,
            hound_menu = nil
        }
        instance.comms = {
            controller = nil,
            atis = nil,
            notifier = nil,
            enrolled = {},
            menu = {
                root = nil ,noData = nil
            }
        }
        instance.childSectors = {}
        instance.priority = priority or 10

        if settings ~= nil and type(settings) == "table" and HOUND.Length(settings) > 0 then
            instance:updateSettings(settings)
        end
        if instance.name ~= "default" then
            instance:setCallsign(instance._hSettings:getUseNATOCallsigns())
        end
        return instance
    end

    --- Update sectore settings
    -- @param settings table of settings for internal services
    -- @usage
    --    local sectorSettings = {
    --         atis = {
    --             freq = 123.45
    --         },
    --         controller = {
    --             freq = 234.56
    --         },
    --         notifier = {
    --             freq = 243.00
    --         }
    --     }
    --     sector:updateSettings(sectorSettings)
    --
    function HOUND.Sector:updateSettings(settings)
        for k, v in pairs(settings) do
            local k0 = tostring(k):lower()
            if type(v) == "table" and
                HOUND.setContainsValue({"controller", "atis", "notifier"}, k0) then
                if not self.settings[k0] then
                    self.settings[k0] = {}
                end
                for k1, v1 in pairs(v) do
                    self.settings[k0][tostring(k1):lower()] = v1
                end
                self.settings[k0]["name"] = self.callsign
            else
                self.settings[k0] = v
            end
        end
        self:updateServices()
    end

    --- Sector "Destructor"
    -- cleans up everyting needed for sector to safly be removed
    -- @return nil is returned
    function HOUND.Sector:destroy()
        self:removeRadioMenu()
        for _,contact in pairs(self._contacts:listAllContacts()) do
            contact:removeSector(self.name)
        end
        return
    end

    --- Update internal services with settings stored in the sector.
    function HOUND.Sector:updateServices()
        if type(self.settings.controller) == "table" then
            if not self.comms.controller then
                self.settings.controller.name = self.callsign
                self.comms.controller = HOUND.Comms.Controller:create(self.name,self._hSettings,self.settings.controller)
            else
                self.settings.controller.name = self.callsign
                self.comms.controller:updateSettings(self.settings.controller)
                self.comms.controller:setCallsign(self.callsign)

            end
        end
        if type(self.settings.atis) == "table" then
            if not self.comms.atis then
                self.settings.atis.name = self.callsign
                self.comms.atis = HOUND.Comms.InformationSystem:create(self.name,self._hSettings,self.settings.atis)
            else
                self.settings.atis.name = self.callsign
                self.comms.atis:updateSettings(self.settings.atis)
                self.comms.atis:setCallsign(self.callsign)
            end
        end
        if type(self.settings.notifier) == "table" then
            if not self.comms.notifier then
                self.settings.notifier.name = self.callsign
                self.comms.notifier = HOUND.Comms.Notifier:create(self.name,self._hSettings,self.settings.notifier)
            else
                self.settings.notifier.name = self.callsign
                self.comms.notifier:updateSettings(self.settings.notifier)
                self.comms.notifier:setCallsign(self.callsign)
            end
        end
        if self.settings.zone and type(self.settings.zone) ~= "table" then
            self:setZone(self.settings.zone)
        end
        if self.settings.transmitter then
            self:updateTransmitter()
        end
    end

    --- getters and setters
    -- @section Getters_Setters

    --- get name
    -- @return string name of sector
    function HOUND.Sector:getName()
        return self.name
    end

    --- get priority
    -- @return[type=int] priority of sector
    function HOUND.Sector:getPriority()
        return self.priority
    end

    --- set callsign for sector
    -- @string callsign Requested Callsign
    -- @bool[opt] NATO Use NATO pool for callsignes
    function HOUND.Sector:setCallsign(callsign, NATO)
        local namePool = "GENERIC"
        if callsign ~= nil and type(callsign) == "boolean" then
            NATO = callsign
            callsign = nil
        end
        if NATO == true then namePool = "NATO" end

        callsign = string.upper(callsign or HoundUtils.getHoundCallsign(namePool))

        while HOUND.setContainsValue(self._hSettings.callsigns, callsign) do
            callsign = HoundUtils.getHoundCallsign(namePool)
        end

        if self.callsign ~= nil or self.callsign ~= "HOUND" then
            for k, v in ipairs(self._hSettings.callsigns) do
                if v == self.callsign then
                    table.remove(self._hSettings.callsigns, k)
                end
            end
        end
        table.insert(self._hSettings.callsigns, callsign)
        self.callsign = callsign
        self:updateServices()
    end

    --- get callsign for sector
    -- @return string Callsign for current sector
    function HOUND.Sector:getCallsign()
        return self.callsign
    end

    --- get zone polygon
    -- @return table of points or nil
    function HOUND.Sector:getZone()
        return self.settings.zone
    end

    --- has zone
    -- @return[type=bool] True if sector has zone
    function HOUND.Sector:hasZone()
        return self:getZone() ~= nil
    end

    --- Set zone in sector
    -- @param zonecandidate (String) DCS group name, or a drawn map freeform Polygon. sector borders will be group waypoints or polygon points
    function HOUND.Sector:setZone(zonecandidate)
        if self.name == "default" then
            HOUND.Logger.warn("[Hound] - cannot set zone to default sector")
            return
        end
        local zone = nil
        if not zonecandidate then
            zone = HoundUtils.Zone.getDrawnZone(self.name .. " Sector")
        end
        if type(zonecandidate) == "string" then
            zone = HoundUtils.Zone.getDrawnZone(zonecandidate) or HoundUtils.Zone.getGroupRoute(zonecandidate)
            -- local zone = HoundUtils.Zone.getDrawnZone(zonecandidate)
            -- if not zone and (Group.getByName(zonecandidate)) then
            --     zone = mist.getGroupPoints(zonecandidate)
            -- end
            -- self.settings.zone = zone
            -- return
        end
        if zone then
            self.settings.zone = zone
            self.zoneCenter = HOUND.Mist.getAvgPoint(zone)
        end
    end

    --- Remove Zone settings from sector
    function HOUND.Sector:removeZone() self.settings.zone = nil end

    --- get Sector zone center
    -- @return DCS point or nil
    function HOUND.Sector:getCenter()
        return self.zoneCenter
    end

    --- Child Sector Functions
    -- @section ChildSectors

    --- Add a child sector to this meta-sector
    -- @string sectorName name of child sector
    function HOUND.Sector:addChildSector(sectorName)
        if self.name == "default" or self.name == "all" then
            HOUND.Logger.warn("[Hound] - cannot add child sectors to reserved sector '" .. self.name .. "'")
            return
        end
        self.childSectors[sectorName] = true
    end

    --- Remove a child sector from this meta-sector
    -- @string sectorName name of child sector
    function HOUND.Sector:removeChildSector(sectorName)
        self.childSectors[sectorName] = nil
    end

    --- Get child sectors table
    -- @return table of child sector names (keys) with true values
    function HOUND.Sector:getChildSectors()
        return self.childSectors
    end

    --- Check if sector has child sectors
    -- @return[type=bool] True if sector has child sectors
    function HOUND.Sector:hasChildSectors()
        return next(self.childSectors) ~= nil
    end

    --- check if sector has specific child sector
    -- @string sectorName name of child sector
    function HOUND.Sector:hasChildSector(sectorName)
        return self.childSectors[sectorName] == true
    end

    --- sets transmitter to sector
    -- @param userTransmitter (String) Name of the Unit that would be transmitting
    function HOUND.Sector:setTransmitter(userTransmitter)
        if not userTransmitter then return end
        self.settings.transmitter = userTransmitter
        self:updateTransmitter()
    end

    --- updates all available comms with transmitter on file
    function HOUND.Sector:updateTransmitter()
        for k, v in pairs(self.comms) do
            if k ~= "menu" and v.setTransmitter then v:setTransmitter(self.settings.transmitter) end
        end
    end

    --- removes transmitter from sector
    function HOUND.Sector:removeTransmitter()
        self.settings.transmitter = nil
        for k, v in pairs(self.comms) do
            if k ~= "menu" then v:removeTransmitter() end
        end
    end

    --- Controller Functions
    -- @section Controller

    --- enable controller
    -- @param[opt] userSettings contoller settings
    function HOUND.Sector:enableController(userSettings)
        if not userSettings then userSettings = {} end
        local settings = { controller = userSettings }
        self:updateSettings(settings)
        self:updateTransmitter()
        self.comms.controller:enable()
        self:populateRadioMenu()
    end

    --- disable controller
    function HOUND.Sector:disableController()
        if self.comms.controller then
            self:removeRadioMenu()
            self.comms.controller:disable()
        end
    end

    --- remove controller completly from sector
    function HOUND.Sector:removeController()
        self.settings.controller = nil
        if self.comms.controller then
            self:disableController()
            self.comms.controller = nil
        end
    end

    --- get controller frequencies
    function HOUND.Sector:getControllerFreq()
        if self.comms.controller then
            return self.comms.controller:getFreqs()
        end
        return {}
    end

    --- checks for controller in sector
    -- @return true if Sector has controller
    function HOUND.Sector:hasController() return self.comms.controller ~= nil end

    --- checks if controller is enabled for the sector
    -- @return true if Sector controller is enabled
    function HOUND.Sector:isControllerEnabled()
        return self.comms.controller ~= nil and self.comms.controller:isEnabled()
    end

    --- If Controller exists on sector, return controller object
    -- @return HOUND.COMMS.Controller
    function HOUND.Sector:getController()
        if self:hasController() then
            return self.comms.controller
        end
        return
    end

    --- Transmit custom TTS message on controller
    -- @param[type=string] msg string to broadcast
    -- @param[type=?number] priority  message priority, default is 1 (high priority)
    function HOUND.Sector:transmitOnController(msg,priority)
        if not self.comms.controller or not self.comms.controller:isEnabled() then return end
        if type(msg) ~= "string" then return end
        if type(priority) ~= "number" then priority = 1 end
        local msgObj = {priority = priority,coalition = self._hSettings:getCoalition()}
        msgObj.tts = msg
        if self.comms.controller:isEnabled() then
            self.comms.controller:addMessageObj(msgObj)
        end
    end

    --- enable controller text for sector
    function HOUND.Sector:enableText()
        if self.comms.controller then self.comms.controller:enableText() end
        -- if self.comms.notifier then self.comms.notifier:enableText() end
    end

    --- disable controller text for sector
    function HOUND.Sector:disableText()
        if self.comms.controller then self.comms.controller:disableText() end
        -- if self.comms.notifier then self.comms.notifier:disableText() end
    end

    --- enable controller Alerts for sector
    function HOUND.Sector:enableAlerts()
        if self.comms.controller then self.comms.controller:enableAlerts() end
    end

    --- disable controller  for sector
    function HOUND.Sector:disableAlerts()
        if self.comms.controller then self.comms.controller:disableAlerts() end
    end

    --- enable Controller tts for sector
    function HOUND.Sector:enableTTS()
        if self.comms.controller then self.comms.controller:enableTTS() end
    end

    --- disable Controller tts for sector
    function HOUND.Sector:disableTTS()
        if self.comms.controller then self.comms.controller:disableTTS() end
    end

    --- ATIS Functions
    -- @section ATIS

    --- enable ATIS in sector
    -- @param userSettings ATIS settings array
    function HOUND.Sector:enableAtis(userSettings)
        if not userSettings then userSettings = {} end
        local settings = { atis = userSettings }
        self:updateSettings(settings)
        self:updateTransmitter()
        self.comms.atis:SetMsgCallback(HOUND.Sector.generateAtis, self)
        self.comms.atis:enable()
    end

    --- disable ATIS in sector
    function HOUND.Sector:disableAtis()
        if self.comms.atis then self.comms.atis:disable() end
    end

    --- remove ATIS from sector
    function HOUND.Sector:removeAtis()
        self.settings.atis = nil
        if self.comms.atis then
            self:disableAtis()
            self.comms.atis = nil
        end
    end

    --- get ATIS frequencies
    function HOUND.Sector:getAtisFreq()
        if self.comms.atis then
            return self.comms.atis:getFreqs()
        end
        return {}
    end

    --- Set ATIS EWR report state
    -- @bool state True will report EWR
    function HOUND.Sector:reportEWR(state)
        if self.comms.atis then self.comms.atis:reportEWR(state) end
    end

    --- checks for atis in sector
    -- @return true if Sector has atis
    function HOUND.Sector:hasAtis() return self.comms.atis ~= nil end

    --- checks if ats is enabled for the sector
    -- @return true if Sector ats is enabled
    function HOUND.Sector:isAtisEnabled()
        return self.comms.atis ~= nil and self.comms.atis:isEnabled()
    end

    --- Notifier Functions
    -- @section Notifier

    --- enable Notifier in sector
    -- @param[opt] userSettings table of settings for Notifier
    function HOUND.Sector:enableNotifier(userSettings)
        if not userSettings then userSettings = {} end
        local settings = { notifier = userSettings }
        self:updateSettings(settings)
        self:updateTransmitter()
        self.comms.notifier:enable()
    end

    --- disable notifier in sector
    function HOUND.Sector:disableNotifier()
        if self.comms.notifier then self.comms.notifier:disable() end
    end

    --- remove notifier in sector
    -- @return true if Sector has notifier
    function HOUND.Sector:removeNotifier()
        self.settings.notifier = nil
        if self.comms.notifier then
            self:disableNotifier()
            self.comms.notifier = nil
        end
    end

    --- get Notifier frequencies
    function HOUND.Sector:getNotifierFreq()
        if self.comms.notifier then
            return self.comms.notifier:getFreqs()
        end
        return {}
    end

    --- checks sector for notifier
    function HOUND.Sector:hasNotifier()
        return self.comms.notifier ~= nil
    end

    --- checks if ats is enabled for the sector
    -- @return true if Sector ats is enabled
    function HOUND.Sector:isNotifierEnabled()
        return self.comms.notifier ~= nil and self.comms.notifier:isEnabled()
    end

    --- If notifier exists on sector, return notifier opject
    -- @return HOUND.COMMS.Notifier
    function HOUND.Sector:getNotifier()
        if self:hasNotifier() then
            return self.comms.notifier
        end
        return
    end

    --- Transmit custom TTS message on Notifier
    -- @param[type=string] msg string to broadcast
    -- @param[type=number] priority message priority, default is 1 (high priority)

    function HOUND.Sector:transmitOnNotifier(msg,priority)
        if not self.comms.notifier or not self.comms.notifier:isEnabled() then return end
        if type(msg) ~= "string" then return end
        if type(priority) ~= "number" then priority = 1 end

        local msgObj = {priority = priority,coalition = self._hSettings:getCoalition()}
        msgObj.tts = msg
        if self.comms.notifier:isEnabled() then
            self.comms.notifier:addMessageObj(msgObj)
        end
    end

    --- Contact Functions
    -- @section contacs

    --- Get effective sector names for querying contacts/sites
    -- @return table list of sector name strings
    function HOUND.Sector:getEffectiveSectorNames()
        if next(self.childSectors) then
            local names = {}
            for name, _ in pairs(self.childSectors) do
                table.insert(names, name)
            end
            return names
        end
        if self:getZone() then
            return {self.name}
        end
        return {"default"}
    end

    --- return a sorted list of all contacts for the sector
    function HOUND.Sector:getContacts()
        local sectorNames = self:getEffectiveSectorNames()
        if #sectorNames == 1 then
            return self._contacts:listAllContactsByRange(sectorNames[1])
        end
        local seen = {}
        local merged = {}
        for _, name in ipairs(sectorNames) do
            for _, contact in ipairs(self._contacts:listAllContacts(name)) do
                local id = contact:getId()
                if not seen[id] then
                    seen[id] = true
                    table.insert(merged, contact)
                end
            end
        end
        table.sort(merged, HoundUtils.Sort.ContactsByRange)
        return merged
    end

    --- count the number of contacts for the sector
    function HOUND.Sector:countContacts()
        local sectorNames = self:getEffectiveSectorNames()
        if #sectorNames == 1 then
            return self._contacts:countContacts(sectorNames[1])
        end
        local seen = {}
        local count = 0
        for _, name in ipairs(sectorNames) do
            for _, contact in ipairs(self._contacts:listAllContacts(name)) do
                local id = contact:getId()
                if not seen[id] then
                    seen[id] = true
                    count = count + 1
                end
            end
        end
        return count
    end

    --- update contact for zone memberships
    -- @param contact HOUND.Contact instance
    function HOUND.Sector:updateSectorMembership(contact)
        local inSector, threatsSector = HoundUtils.Polygon.threatOnSector(self.settings.zone,contact:getPos(),contact:getMaxWeaponsRange())
        contact:updateSector(self.name, inSector, threatsSector)
        self._contacts:getSite(contact):updateSector()
    end

    --- return a sorted list of all sites for the sector
    function HOUND.Sector:getSites()
        local sectorNames = self:getEffectiveSectorNames()
        if #sectorNames == 1 then
            return self._contacts:listAllSitesByRange(sectorNames[1])
        end
        local seen = {}
        local merged = {}
        for _, name in ipairs(sectorNames) do
            for _, site in ipairs(self._contacts:listAllSites(name)) do
                local id = site:getId()
                if not seen[id] then
                    seen[id] = true
                    table.insert(merged, site)
                end
            end
        end
        table.sort(merged, HoundUtils.Sort.ContactsByRange)
        return merged
    end

    --- count the number of sites for the sector
    -- @return[type=int] Number of sites
    function HOUND.Sector:countSites()
        local sectorNames = self:getEffectiveSectorNames()
        if #sectorNames == 1 then
            return self._contacts:countSites(sectorNames[1])
        end
        local seen = {}
        local count = 0
        for _, name in ipairs(sectorNames) do
            for _, site in ipairs(self._contacts:listAllSites(name)) do
                local id = site:getId()
                if not seen[id] then
                    seen[id] = true
                    count = count + 1
                end
            end
        end
        return count
    end

    -------------- Radio Menu stuff -----------------------------

    --- Radio Menu
    -- @section menu

    --- remove all radio menus for
    -- @param self HOUND.Sector
    -- @local
    function HOUND.Sector.removeRadioMenu(self)
        -- for menuName,menu in pairs(self.comms.menu) do
        --     if menu ~= nil and menuName ~= "root" then
        --         missionCommands.removeItem(menu)
        --     end
        -- end
        -- for _,menu in pairs(self.comms.menu.check_in) do
        --     if menu ~= nil then
        --         missionCommands.removeItem(menu)
        --     end
        -- end
        if self.comms.menu.root ~= nil then
            missionCommands.removeItemForCoalition(self._hSettings:getCoalition(),self.comms.menu.root)
        end
        self.comms.menu = {}
        self.comms.menu.root = nil
        self.comms.enrolled = {}
        -- self.comms.menu.data = {}
        -- self.comms.menu.check_in = {}
    end

    --- find group in enrolled
    -- @param grpId GroupId (int)
    -- @param[opt] playersList list of mist.DB units to find all the group members in
    -- @return list of enrolled players in grp
    -- @local
    function HOUND.Sector:findGrpInPlayerList(grpId,playersList)
        if not playersList or type(playersList) ~= "table" then
            playersList = self.comms.enrolled
        end
        local playersInGrp = {}
        for _,player in pairs(playersList) do
            if player.groupId == grpId then
                table.insert(playersInGrp,player)
            end
        end
        return playersInGrp
    end

    --- get subscribed groups
    -- @return list of groupsId
    -- @local
    function HOUND.Sector:getSubscribedGroups()
        local subscribedGid = {}
        for _,player in pairs(self.comms.enrolled) do
            local grpId = player.groupId
            if not HOUND.setContainsValue(subscribedGid,grpId) then
                table.insert(subscribedGid,grpId)
            end
        end
        return subscribedGid
    end

    --- clean non existing users from subscribers
    -- @local
    function HOUND.Sector:validateEnrolled()
        if HOUND.Length(self.comms.enrolled) == 0 then return end
        for playerUnitName, player in pairs(self.comms.enrolled) do
            local playerUnit = Unit.getByName(playerUnitName)
            if not HoundUtils.Dcs.isHuman(playerUnit) then
                self.comms.enrolled[player.unitName] = nil
            end
        end
    end

    --- check in player to controller
    -- @local
    -- @param args table {self=&ltHOUND.Sector&gt,player=&ltplayer&gt}
    -- @param[opt] skipAck Bool if true do not reply with ack to player
    function HOUND.Sector.checkIn(args,skipAck)
        local gSelf = args["self"]
        local player = args["player"]
        for _,PlayerInGrp in pairs(HOUND.Utils.Dcs.getPlayersInGroup(player.groupName)) do
            gSelf.comms.enrolled[PlayerInGrp.unitName] = PlayerInGrp
        end
        gSelf:populateRadioMenu()
        if not skipAck then
            gSelf:TransmitCheckInAck(player)
        end
    end

    --- check out player's group from controller
    -- @local
    -- @param args table {self=&ltHOUND.Sector&gt,player=&ltplayer&gt}
    -- @param[opt] skipAck Bool if true do not reply with ack to player
    -- @param[opt] onlyPlayer Bool. if true, only the player and not his flight (eg. slot change for player)
    function HOUND.Sector.checkOut(args,skipAck,onlyPlayer)
        local gSelf = args["self"]
        local player = args["player"]
        gSelf.comms.enrolled[player.unitName] = nil

        if not onlyPlayer then
            -- for _,otherPlayer in pairs(gSelf:findGrpInPlayerList(player.groupId)) do
            for _,PlayerInGrp in pairs(HOUND.Utils.Dcs.getPlayersInGroup(player.groupName)) do
                if player.unitName ~= PlayerInGrp.unitName then
                    gSelf.comms.enrolled[PlayerInGrp.unitName] = nil
                end
            end
        end
        gSelf:populateRadioMenu()
        if not skipAck then
            gSelf:TransmitCheckOutAck(player)
        end
    end

    ------------------------- Events -----------------------------------
    --- Message generation
    -- @section messages

    --- Determine if this sector should notify for a contact in the given primary sector
    -- @string primarySector the contact's primary sector name
    -- @return bool shouldNotify, string|nil sectorLabel
    function HOUND.Sector:shouldNotifyFor(primarySector)
        if self.name == "default" then
            return true, (primarySector ~= "default") and primarySector or nil
        end
        if self.name == primarySector then
            return true, nil
        end
        if self.childSectors[primarySector] then
            return true, primarySector
        end
        return false, nil
    end

    --- Check if sector can notify
    function HOUND.Sector:isNotifiying()
        local controller = self.comms.controller
        local notifier = self.comms.notifier
        if not controller and not notifier then return false end
        if (not controller or not controller:getSettings("alerts") or not controller:isEnabled()) and (not notifier or not notifier:isEnabled())
             then return false end
        return true
    end
    --- create randome annouce
    -- @param[opt] index of requested announce
    -- @return string Announcement
    function HOUND.Sector:getTransmissionAnnounce(index)
        local messages = {
            "All Stations, " .. self.callsign .. ", ",
            "All Aircraft, " .. self.callsign .. ", ",
            "All Stations, this is " .. self.callsign .. ", ",
            "All Aircraft, this is " .. self.callsign .. ", ",
        }
        local retIndex = l_math.random(1,#messages)
        if type(index) == "number" then
            retIndex = l_math.max(1,l_math.min(#messages,index))
        end
        return messages[retIndex]
    end

    --- Send dead emitter notification
    -- @param contact HounContact instace
    function HOUND.Sector:notifyEmitterDead(contact)
        if not self:isNotifiying() then return end

        local controller = self.comms.controller
        local notifier = self.comms.notifier

        local shouldNotify, sectorLabel = self:shouldNotifyFor(contact:getPrimarySector())
        if not shouldNotify then return end

        local announce = self:getTransmissionAnnounce()
        local enrolledGid = self:getSubscribedGroups()

        local msg = {coalition =  self._hSettings:getCoalition(), priority = 3, gid=enrolledGid}
        msg.contactId = contact:getId()
        -- if (controller and controller:getSettings("enableText")) or (notifier and notifier:getSettings("enableText"))  then
            msg.txt = contact:generateDeathReport(false,sectorLabel)
        -- end
        -- if (controller and controller:getSettings("enableTTS")) or (notifier and notifier:getSettings("enableTTS")) then
            msg.tts = announce .. contact:generateDeathReport(true,sectorLabel)
        -- end
        if controller and controller:isEnabled() and controller:getSettings("alerts") then
            controller:addMessageObj(msg)
        end
        if notifier and notifier:isEnabled() then
            notifier:addMessageObj(msg)
        end
    end

    --- Send new emitter notification
    -- @param contact HounContact instace
    function HOUND.Sector:notifyEmitterNew(contact)
        if not self:isNotifiying() then return end

        local controller = self.comms.controller
        local notifier = self.comms.notifier

        local shouldNotify, sectorLabel = self:shouldNotifyFor(contact:getPrimarySector())
        if not shouldNotify then return end

        local announce = self:getTransmissionAnnounce()
        local enrolledGid = self:getSubscribedGroups()

        local msg = {coalition = self._hSettings:getCoalition(), priority = 2 , gid=enrolledGid}
        msg.contactId = contact:getId()

        -- if (controller and controller:getSettings("enableText")) or (notifier and notifier:getSettings("enableText"))  then
            msg.txt = self.callsign .. " Reports " .. contact:generatePopUpReport(false,sectorLabel)
        -- end
        -- if (controller and controller:getSettings("enableTTS")) or (notifier and notifier:getSettings("enableTTS")) then
            msg.tts = announce .. contact:generatePopUpReport(true,sectorLabel)
        -- end

        if controller and controller:isEnabled() and controller:getSettings("alerts") then
            controller:addMessageObj(msg)
        end

        if notifier and notifier:isEnabled() then
            notifier:addMessageObj(msg)
        end
    end

    --- Notify a site was reclassified
    -- @param site @{HOUND.Contact.Site} instace
    function HOUND.Sector:notifySiteIdentified(site)
        if not self:isNotifiying() then return end

        local controller = self.comms.controller
        local notifier = self.comms.notifier

        local shouldNotify, sectorLabel = self:shouldNotifyFor(site:getPrimarySector())
        if not shouldNotify then return end

        local announce = self:getTransmissionAnnounce()
        local enrolledGid = self:getSubscribedGroups()

        local msg = {coalition = self._hSettings:getCoalition(), priority = 2 , gid=enrolledGid}

        -- if (controller and controller:getSettings("enableText")) or (notifier and notifier:getSettings("enableText"))  then
            msg.txt = self.callsign .. " Reports " .. site:generateIdentReport(false,sectorLabel)
        -- end
        -- if (controller and controller:getSettings("enableTTS")) or (notifier and notifier:getSettings("enableTTS")) then
            msg.tts = announce .. site:generateIdentReport(true,sectorLabel)
        -- end

        if controller and controller:isEnabled() and controller:getSettings("alerts") then
            controller:addMessageObj(msg)
        end

        if notifier and notifier:isEnabled() then
            notifier:addMessageObj(msg)
        end
    end
    --- Notify a site was created
    -- @param site @{HOUND.Contact.Site} instace
    function HOUND.Sector:notifySiteNew(site)
        if not self:isNotifiying() then return end

        local controller = self.comms.controller
        local notifier = self.comms.notifier

        local shouldNotify, sectorLabel = self:shouldNotifyFor(site:getPrimarySector())
        if not shouldNotify then return end

        local announce = self:getTransmissionAnnounce()
        local enrolledGid = self:getSubscribedGroups()

        local msg = {coalition = self._hSettings:getCoalition(), priority = 2 , gid=enrolledGid}
        msg.contactId = site:getId()
        -- if (controller and controller:getSettings("enableText")) or (notifier and notifier:getSettings("enableText"))  then
            msg.txt = self.callsign .. " Reports " .. site:generatePopUpReport(false,sectorLabel)
        -- end
        -- if (controller and controller:getSettings("enableTTS")) or (notifier and notifier:getSettings("enableTTS")) then
            msg.tts = announce .. site:generatePopUpReport(true,sectorLabel)
        -- end
        if controller and controller:isEnabled() and controller:getSettings("alerts") then
            controller:addMessageObj(msg)
        end

        if notifier and notifier:isEnabled() then
            notifier:addMessageObj(msg)
        end

    end
    --- Notify a site was destroyed
    -- @param site @{HOUND.Contact.Site} instace
    -- @param isDead True is site is removed, false if just asleep
    function HOUND.Sector:notifySiteDead(site,isDead)
        if not self:isNotifiying() then return end

        local controller = self.comms.controller
        local notifier = self.comms.notifier

        local shouldNotify, sectorLabel = self:shouldNotifyFor(site:getPrimarySector())
        if not shouldNotify then return end

        local announce = self:getTransmissionAnnounce()
        local enrolledGid = self:getSubscribedGroups()

        local msg = {coalition = self._hSettings:getCoalition(), priority = 3 , gid=enrolledGid}
        msg.contactId = site:getId()
        local body = {}
        if isDead then
            body.txt = site:generateDeathReport(false,sectorLabel)
            body.tts = site:generateDeathReport(true,sectorLabel)
        else
            body.txt = site:generateAsleepReport(false,sectorLabel)
            body.tts = site:generateAsleepReport(true,sectorLabel)
        end
        msg.txt = self.callsign .. " Reports " .. body.txt
        msg.tts = announce .. body.tts
        if controller and controller:isEnabled() and controller:getSettings("alerts") then
            controller:addMessageObj(msg)
        end

        if notifier and notifier:isEnabled() then
            notifier:addMessageObj(msg)
        end
    end


    --- Notify that a site is launching.
    -- This function sends a notification when a site is launching if alerts are enabled.
    -- It checks if the sector is set to notify and if the site belongs to the primary sector.
    -- The notification is sent to both the controller and notifier if they are enabled.
    -- @param site @{HOUND.Contact.Site} The site that is launching.
function HOUND.Sector:notifySiteLaunching(site)
        if not self._hSettings:getAlertOnLaunch() or not self:isNotifiying() then return end
        local controller = self.comms.controller
        local notifier = self.comms.notifier
        local shouldNotify, sectorLabel = self:shouldNotifyFor(site:getPrimarySector())
        if not shouldNotify then return end

        -- local announce = self:getTransmissionAnnounce()
        local enrolledGid = self:getSubscribedGroups()

        local msg = {coalition = self._hSettings:getCoalition(), priority = 1 , gid=enrolledGid}
        msg.contactId = site:getId()
        msg.txt = site:generateLaunchAlert(false,sectorLabel)
        msg.tts = site:generateLaunchAlert(true,sectorLabel)

        if controller and controller:isEnabled() and controller:getSettings("alerts") then
            controller:addMessageObj(msg)
        end

        if notifier and notifier:isEnabled() then
            notifier:addMessageObj(msg)
        end

    end

    --- Generate Atis message for sector
    -- @local
    -- @param loopData HoundInfomationSystem loop table
    -- @param AtisPreferences HoundInfomationSystem settings table
    function HOUND.Sector:generateAtis(loopData,AtisPreferences)
        local body = ""
        local numberEWR = 0
        local siteCount = self:countSites()
        if siteCount > 0 then
            local sortedSites = self:getSites()
            for _, site in pairs(sortedSites) do
                if site:getPos() ~= nil then
                    if not site.isEWR or
                        (AtisPreferences.reportewr and site.isEWR) then
                        body = body ..
                                    site:generateTtsBrief(
                                        self._hSettings:getNATO()) .. " "
                    end
                    if (not AtisPreferences.reportewr and site.isEWR) then
                        numberEWR = numberEWR + 1
                    end
                end
            end
            if numberEWR > 0 then
                body = body .. numberEWR .. " EWRs are tracked. "
            end
        end

        if body == "" then
            if self._hSettings:getNATO() then
                body = ". EMPTY. "
            else
                body = "No threats had been detected "
            end
        end

        if loopData.body == body then return end
        loopData.body = body

        local reportId
        reportId, loopData.reportIdx =
            HoundUtils.getReportId(loopData.reportIdx)

        local header = self.callsign
        local footer = reportId .. "."

        if self._hSettings:getNATO() then
            header = header .. " Lowdown "
            footer = "Lowdown " .. footer
        else
            header = header .. " SAM information "
            footer = "you have " .. footer
        end
        header = header .. reportId .. " " ..
                                    HoundUtils.TTS.getTtsTime() .. ". "

        local msgObj = {
            coalition = self._hSettings:getCoalition(),
            priority = "loop",
            updateTime = timer.getAbsTime(),
            tts = header .. loopData.body .. footer
        }
        loopData.msg = msgObj
    end

    --- transmit SAM report
    -- @local
    -- @param args table {self=&ltHOUND.Sector&gt,contact=&ltHOUND.Contact&gt,requester=&ltplayer&gt}
    function HOUND.Sector.TransmitSamReport(args)
        local gSelf = args["self"]
        local contact = gSelf._contacts:getContact(args["contact"],true)
        local requester = args["requester"]
        local coalitionId = gSelf._hSettings:getCoalition()
        local msgObj = {coalition = coalitionId, priority = 1}
        local useDMM = false
        local preferMGRS = false

        if requester == nil then return end
        if contact.isEWR then msgObj.priority = 2 end

        if requester ~= nil then
            msgObj.gid = requester.groupId
            useDMM =  HoundUtils.useDMM(requester.type)
            preferMGRS = HoundUtils.useMGRS(requester.type)
        end

        if gSelf.comms.controller:isEnabled() then

            msgObj.contactId = contact:getId()
            msgObj.tts = contact:generateTtsReport(useDMM,preferMGRS)
            if requester ~= nil then
                msgObj.tts = HoundUtils.getFormationCallsign(requester,gSelf._hSettings:getCallsignOverride()) .. ", " .. gSelf.callsign .. ", " .. msgObj.tts
            end
            if gSelf.comms.controller:getSettings("enableText") == true then
                msgObj.txt = contact:generateTextReport(useDMM)
            end
            gSelf.comms.controller:addMessageObj(msgObj)
        end
    end

    --- transmit checkin message
    -- @local
    -- @param player Player entity
    function HOUND.Sector:TransmitCheckInAck(player)
        if not player then return end
        local msgObj = {priority = 1,coalition = self._hSettings:getCoalition(), gid = player.groupId}
        local msg = HoundUtils.getFormationCallsign(player,self._hSettings:getCallsignOverride()) .. ", " .. self.callsign .. ", Roger. "
        if self:countContacts() > 0 then
            msg = msg .. "Tasking is available."
        else
            msg = msg .. "No known threats."
        end
        msgObj.tts = msg
        msgObj.txt = msg
        if self.comms.controller:isEnabled() then
            self.comms.controller:addMessageObj(msgObj)
        end
    end

    --- transmit checkout message
    -- @local
    -- @param player Player entity
    function HOUND.Sector:TransmitCheckOutAck(player)
        if not player then return end
        local msgObj = {priority = 1,coalition = self._hSettings:getCoalition(), gid = player.groupId}
        local msg = HoundUtils.getFormationCallsign(player,self._hSettings:getCallsignOverride()) .. ", " .. self.callsign .. ", copy checking out. "
        msgObj.tts = msg .. "Frequency change approved."
        msgObj.txt = msg
        if self.comms.controller:isEnabled() then
            self.comms.controller:addMessageObj(msgObj)
        end
    end
end
