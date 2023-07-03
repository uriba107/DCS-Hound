--- Hound Main interface
-- Elint system for DCS
-- @author uri_ba
-- @copyright uri_ba 2020-2021
-- @script HoundElint
do
    local HoundUtils = HOUND.Utils
    --- Main entry point
    -- @type HoundElint
    HoundElint = {}
    HoundElint.__index = HoundElint

    --- Instance Setup
    -- @section HoundElint

    --- create HoundElint instance.
    -- @param platformName Platform name or coalition enum
    -- @return HoundElint Instance
    function HoundElint:create(platformName)
        if not platformName then
            HOUND.Logger.error("Failed to initialize Hound instace. Please provide coalition")
            return
        end
        local elint = {}
        setmetatable(elint, HoundElint)
        elint.settings = HOUND.Config.get()
        elint.HoundId = elint.settings:getId()
        elint.contacts = HOUND.ContactManager.get(elint.HoundId)
        elint.elintTaskID = nil
        elint.radioAdminMenu = nil
        elint.coalitionId = nil

        elint.timingCounters = {}

        if platformName ~= nil then
            if type(platformName) == "string" then
                elint:addPlatform(platformName)
            else
                elint:setCoalition(platformName)
            end
        end

        elint.sectors = {
            default = HOUND.Sector.create(elint.HoundId,"default",nil,100)
        }
        elint:defaultEventHandler()
        return elint
    end

    --- destructor function
    -- initiates cleanup
    function HoundElint:destroy()
        self:systemOff(false)
        self:defaultEventHandler(false)

        for name,sector in pairs(self.sectors) do
            self.sectors[name] = sector:destroy()
        end
        self:purgeRadioMenu()
        self.contacts = nil
        self.settings = nil
        collectgarbage("collect")
        return nil
    end

    --- get Hound instance ID
    -- @return Int Hound ID
    function HoundElint:getId()
        return self.settings:getId()
    end

    --- get Hound instance Coalition
    -- @return coalition enum of current hound instance
    function HoundElint:getCoalition()
        return self.settings:getCoalition()
    end

    --- set coalition for Hound Instance (Internal)
    -- @param side coalition side enum
    -- @return Bool. True if coalition was set
    function HoundElint:setCoalition(side)
        if side == coalition.side.BLUE or side == coalition.side.RED then
            return self.settings:setCoalition(side)
        end
        return false
    end

    --- set onScreenDebug
    -- @param value Bool
    -- @return (Bool) True if chaned
    function HoundElint:onScreenDebug(value)
        return self.settings:setOnScreenDebug(value)
    end

    --- Platforms managment
    -- @section platforms

    --- add platform from hound instance
    -- @string platformName Unit name for platform to add
    -- @return bool. True if successfuly added
    function HoundElint:addPlatform(platformName)
        return self.contacts:addPlatform(platformName)
    end

    --- Remove platform from hound instance
    -- @string platformName Unit name for platform to remove
    -- @return bool. True if successfuly removed
    function HoundElint:removePlatform(platformName)
        return self.contacts:removePlatform(platformName)
    end

    --- count Platforms
    -- @return Int number of assigned platforms
    function HoundElint:countPlatforms()
        return self.contacts:countPlatforms()
    end

    --- list platforms
    -- @return list of platfoms
    function HoundElint:listPlatforms()
        return self.contacts:listPlatforms()
    end

    --- Contact managment
    -- @section contacts

    --- count contacts
    -- @param[opt] sectorName String name or sector to filter by
    -- @return Int number of contacts currently tracked
    function HoundElint:countContacts(sectorName)
        return self.contacts:countContacts(sectorName)
    end

    --- count Active contacts
    -- @param[opt] sectorName String name or sector to filter by
    -- @return Int number of contacts currently Transmitting
    function HoundElint:countActiveContacts(sectorName)
        local activeContactCount = 0
        local contacts =  self.contacts:getContacts(sectorName)
        for _,contact in pairs(contacts) do
            if contact:isActive() then
                activeContactCount = activeContactCount +1
            end
        end
        return activeContactCount
    end

    --- count preBriefed contacts
    -- @param[opt] sectorName String name or sector to filter by
    -- @return Int number of contacts currently in PB status
    function HoundElint:countPreBriefedContacts(sectorName)
        local pbContactCount = 0
        local contacts =  self.contacts:getContacts(sectorName)
        for _,contact in pairs(contacts) do
            if contact:isAccurate() then
                pbContactCount = pbContactCount +1
            end
        end
        return pbContactCount
    end

    --- set/create a pre Briefed contacts
    -- @param DCS_Object_Name name of DCS Unit or Group to add
    -- @param[opt] codeName Optional name for site created
    function HoundElint:preBriefedContact(DCS_Object_Name,codeName)
        if type(DCS_Object_Name) ~= "string" then return end
        local units = {}
        local obj = Group.getByName(DCS_Object_Name) or Unit.getByName(DCS_Object_Name)
        local grpName = DCS_Object_Name
        if not obj then
            HOUND.Logger.info("Cannot pre-brief " .. DCS_Object_Name .. ": object does not exist.")
            return
        end
        if HoundUtils.Dcs.isGroup(obj) then
            units = obj:getUnits()
        elseif HoundUtils.Dcs.isUnit(obj) then
            table.insert(units,obj)
            grpName = obj:getGroup():getName()
        end

        for _,unit in pairs(units) do
            if unit:getCoalition() ~= self.settings:getCoalition() and unit:isExist() and HOUND.setContains(HOUND.DB.Radars,unit:getTypeName()) then
                self.contacts:setPreBriefedContact(unit)
            end
        end
        if type(codeName) == "string" then
            local site = self.contacts:getSite(grpName,true)
            if site then
                site:setName(codeName)
            end
        end
    end

    --- Mark Radar as dead
    -- @param radarUnit DCS Unit, DCS Group or Unit/Group name to mark as dead
    function HoundElint:markDeadContact(radarUnit)
        local units={}
        local obj = radarUnit
        if type(radarUnit) == "string" then
            obj = Group.getByName(radarUnit) or Unit.getByName(radarUnit)
        end
        if HoundUtils.Dcs.isGroup(obj) then
            units = obj:getUnits()
            for _,unit in pairs(units) do
                unit = unit:getName()
            end
        elseif HoundUtils.Dcs.isUnit(obj) then
            table.insert(units,obj:getName())
        end
        if not obj then
            if type(radarUnit) == "string" then
                table.insert(units,radarUnit)
            else
                HOUND.Logger.info("Cannot mark as dead: object does not exist.")
                return
            end
        end
        for _,unit in pairs(units) do
            if self.contacts:isContact(unit) then
                self.contacts:setDead(unit)
            end
        end

    end

    --- count sites
    -- @param[opt] sectorName String name or sector to filter by
    -- @return Int number of contacts currently tracked
    function HoundElint:countSites(sectorName)
        return self.contacts:countSites(sectorName)
    end

    --- Sector managment
    -- @section sectors

    --- Add named sector
    -- @param sectorName name of sector to add
    -- @param[opt] sectorSettings table of sector settings
    -- @param[opt] priority Sector priority (lower is higher)
    -- @return Bool. True if sector successfully added
    function HoundElint:addSector(sectorName,sectorSettings,priority)
        if type(sectorName) ~= "string" then return false end
        if string.lower(sectorName) == "default" or string.lower(sectorName) == "all" then
            HOUND.Logger.info(sectorName.. " is a reserved sector name")
            return nil
        end
        priority = priority or 50
        if not self.sectors[sectorName] then
            self.sectors[sectorName] = HOUND.Sector.create(self.settings:getId(),sectorName,sectorSettings,priority)
            if self.settings:getOnScreenDebug() then
                HOUND.Logger.onScreenDebug("Sector " .. sectorName  .. " was added to Hound instance ".. self:getId(),10)
            end
            return self.sectors[sectorName]
        end

        return nil
    end

    --- Remove Named sector
    -- @param sectorName name of sector to add
    -- @return Bool. True if sector successfully added
    function HoundElint:removeSector(sectorName)
        if sectorName == nil then return false end
        self.sectors[sectorName] = self.sectors[sectorName]:destroy()
        if self.settings:getOnScreenDebug() then
            HOUND.Logger.onScreenDebug("Sector " .. sectorName .. " was removed from Hound instance ".. self:getId(),10)
        end
        return true
    end

    --- Update named sector settings
    -- @string sectorName name of sector (nil == "default")
    -- @tab sectorSettings sector settings
    -- @string[opt] subSettingName update specific setting ("controller", "atis", "notifier")
    -- @return Bool. False if an error occurred, true otherwise
    function HoundElint:updateSectorSettings(sectorName,sectorSettings,subSettingName)
        if sectorName == nil then sectorName = "default" end
        if not self.sectors[sectorName] then
            env.warn("No sector named ".. sectorName .." was found.")
            return false
        end
        if sectorSettings == nil or type(sectorSettings) ~= "table" then return false end
        local sector = self.sectors[sectorName]
        if subSettingName ~= nil and type(subSettingName) == "string" then
            local subSetting = string.lower(subSettingName)
            if subSetting == "controller" or subSetting == "atis" or subSetting == "notifier" then
                local generatedSettings = {}
                generatedSettings[subSetting] = sectorSettings
                sector:updateSettings(generatedSettings)
                return true
            end
        end
        sector:updateSettings(sectorSettings)
        return true
    end

    --- list all sectors
    -- @string[opt] element list only sectors with specified element. Valid options are "controller", "atis", "notifier" and "zone"
    -- @return list of sector names
    function HoundElint:listSectors(element)
        local sectors = {}
        for name,sector in pairs(self.sectors) do
            local addToList = true
            if element then
                if string.lower(element) == "controller" then
                    addToList=sector:hasController()
                end
                if string.lower(element) == "atis" then
                    addToList=sector:hasAtis()
                end
                if string.lower(element) == "notifier" then
                    addToList=sector:hasNotifier()
                end
                if string.lower(element) == "zone" then
                    addToList=sector:hasZone()
                end
            end

            if addToList then
                table.insert(sectors,name)
            end
        end
        return sectors
    end

    --- get all sectors
    -- @string[opt] element list only sectors with specified element. Valid options are "controller", "atis", "notifier" and "zone"
    -- @return list of HOUND.Sector instances
    function HoundElint:getSectors(element)
        local sectors = {}
        for _,sector in pairs(self.sectors) do
            local addToList = true
            if element then
                if string.lower(element) == "controller" then
                    addToList=sector:hasController()
                end
                if string.lower(element) == "atis" then
                    addToList=sector:hasAtis()
                end
                if string.lower(element) == "notifier" then
                    addToList=sector:hasNotifier()
                end
                if string.lower(element) == "zone" then
                    addToList=sector:hasZone()
                end
            end

            if addToList then
                table.insert(sectors,sector)
            end
        end
        return sectors
    end

    --- return number of sectors
    -- @string[opt] element count only sectors with specified element ("controller"/"atis"/"notifier"/"zone")
    -- @return Int. number of sectors
    function HoundElint:countSectors(element)
        return HOUND.Length(self:listSectors(element))
    end

    --- return HOUND.Sector instance
    -- @string sectorName Name of wanted sector
    -- @return HOUND.Sector
    function HoundElint:getSector(sectorName)
        if HOUND.setContains(self.sectors,sectorName) then
            return self.sectors[sectorName]
        end
    end

    --- Controller managment
    -- @section Controller

    --- enable controller in sector
    -- @string[opt] sectorName name of sector in which a controller is enabled (default is "default") - "all" enable controller on all sectors
    -- @tab[opt] settings controller settings to apply (if "all" is used, setting will be dropped)
    function HoundElint:enableController(sectorName,settings)
        if type(sectorName) == "table" and settings == nil then
            settings  = sectorName
            sectorName = "default"
        end
        if sectorName == nil then sectorName = "default" end
        if self.sectors[sectorName] ~= nil then
            self.sectors[sectorName]:enableController(settings)
            return
        end
        if string.lower(sectorName) == "all" and settings == nil then
            for _,sector in pairs(self.sectors) do
                sector:enableController()
            end
        end

    end

    --- disable controller in sector
    -- @string[opt] sectorName Name of sector to act on. default is "default". all will disable all controllers
    function HoundElint:disableController(sectorName)
        if sectorName == nil then
            sectorName = "default"
        end
        if self.sectors[sectorName] ~= nil then
            self.sectors[sectorName]:disableController()
        end
        if sectorName:lower() == "all" then
            for _,sector in pairs(self.sectors) do
                sector:disableController()
            end
        end
    end

    --- remove controller in sector
    -- @string[opt] sectorName Name of sector to act on. default is "default". all will disable all controllers
    function HoundElint:removeController(sectorName)
        if sectorName == nil then
            sectorName = "default"
        end
        if sectorName:lower() == "all" then
            for _,sector in pairs(self.sectors) do
                sector:removeController()
            end
        elseif self.sectors[sectorName] ~= nil then
            self.sectors[sectorName]:removeController()
        end
    end

    --- configure controller in sector
    -- @string[opt] sectorName name of sector to configure
    -- @tab settings settings for sector controller
    function HoundElint:configureController(sectorName,settings)
        if sectorName == nil and settings == nil then return end
        if sectorName == nil and type(settings) == "table" then
            sectorName = "default"
        end
        if type(sectorName) =="table" and settings == nil then
            settings = sectorName
            sectorName = "default"
        end
        local controllerSettings = { controller = settings}
        if self.sectors[sectorName] == nil then
            self:addSector(sectorName,controllerSettings)
        elseif self.sectors[sectorName] then
            self.sectors[sectorName]:updateSettings(controllerSettings)
        end
    end

    --- get controller freq
    -- @string[opt] sectorName name of sector to configure
    -- @return frequncies table for sector's controller
    function HoundElint:getControllerFreq(sectorName)
        sectorName = sectorName or "default"
        return self.sectors[sectorName]:getControllerFreq() or {}
    end

    --- get controller state
    -- @string[opt] sectorName name of sector to probe
    -- @return (Bool) True = enabled. False is disable or not configured
    function HoundElint:getControllerState(sectorName)
        sectorName = sectorName or "default"

        if self.sectors[sectorName] then
            return (self.sectors[sectorName]:isControllerEnabled())
        end
        return false
    end

    --- Transmit custom TTS message on controller freqency
    -- @param sectorName name of the sector to transmit on.
    -- @param msg String message to broadcast
    function HoundElint:transmitOnController(sectorName,msg)
        if not sectorName or not msg then return end
        if self.sectors[sectorName] then
            self.sectors[sectorName]:transmitOnController(msg)
            return
        end
        if sectorName == "all" then
            for _,sector in pairs(self.sectors) do
                sector:transmitOnController(msg)
            end
        end
    end

    --- ATIS managment
    -- @section ATIS

    --- enable ATIS in sector
    -- @string[opt] sectorName name of sector in which a controller is enabled (default is "default") - "all" enable ATIS on all sectors
    -- @tab[opt] settings controller settings to apply (if "all" is used, setting will be dropped)
    function HoundElint:enableAtis(sectorName,settings)
        if type(sectorName) == "table" and settings == nil then
            settings  = sectorName
            sectorName = "default"
        end
        if sectorName == nil then sectorName = "default" end
        if string.lower(sectorName) == "all" then
            for _,sector in pairs(self.sectors) do
                sector:enableAtis()
            end
            return
        end
        if self.sectors[sectorName] ~= nil then
            self.sectors[sectorName]:enableAtis(settings)
        end
    end

    --- disable ATIS in sector
    -- @string[opt] sectorName Name of sector to act on. default is "default". all will disable all ATIS
    function HoundElint:disableAtis(sectorName)
        if sectorName == nil then
            sectorName = "default"
        end
        if self.sectors[sectorName] ~= nil then
            self.sectors[sectorName]:disableAtis()
            return
        end
        if sectorName == "all" then
            for _,sector in pairs(self.sectors) do
                sector:disableAtis()
            end
        end
    end

    --- remove ATIS in sector
    -- @string[opt] sectorName Name of sector to act on. default is "default". all will disable all ATIS
    function HoundElint:removeAtis(sectorName)
        if sectorName == nil then
            sectorName = "default"
        end
        if sectorName == "all" then
            for _,sector in pairs(self.sectors) do
                sector:removeAtis()
            end
        elseif self.sectors[sectorName] ~= nil then
            self.sectors[sectorName]:removeAtis()
        end
    end

    --- configure ATIS in sector
    -- @string[opt] sectorName name of sector to configure
    -- @tab settings settings for sector ATIS
    function HoundElint:configureAtis(sectorName,settings)
        if sectorName == nil and settings == nil then return end
        if sectorName == nil and type(settings) == "table" then
            sectorName = "default"
        end
        if type(sectorName) =="table" and settings == nil then
            settings = sectorName
            sectorName = "default"
        end
        local userSettings = { atis = settings}
        if self.sectors[sectorName] == nil then
            self:addSector(sectorName,userSettings)
        elseif self.sectors[sectorName] then
            self.sectors[sectorName]:updateSettings(userSettings)
        end
    end

    --- get ATIS freq
    -- @string[opt] sectorName name of sector to query
    -- @return frequncies table for sector's controller
    function HoundElint:getAtisFreq(sectorName)
        sectorName = sectorName or "default"
        return self.sectors[sectorName]:getAtisFreq() or {}
    end

    --- set ATIS EWR report state for sector
    -- @string[opt] name sector name. valid inputs are sector name, "all". nothing will default to "default"
    -- @bool state set desired state
    function HoundElint:reportEWR(name,state)
        if type(name) == "boolean" then
            state = name
            name = "default"
        end
        if self.sectors[name] then
            self.sectors[name]:reportEWR(state)
            return
        end
        if name == "all" then
            for _,sector in pairs(self.sectors) do
                sector:reportEWR(state)
            end
        end
    end

    --- get ATIS state
    -- @string[opt] sectorName name of sector to probe
    -- @return (Bool) True = enabled. False is disable or not configured
    function HoundElint:getAtisState(sectorName)
        sectorName = sectorName or "default"
        if self.sectors[sectorName] then
            return (self.sectors[sectorName]:isAtisEnabled())
        end
        return false
    end

    --- Notifier managment
    -- @section Notifier

    --- enable Notifier in sector
    -- Only one notifier is required as it will broadcast on a global frequency (default is guard)
    -- controller will also handle alerts for per sector notifications
    -- @string[opt] sectorName name of sector in which a Notifier is enabled (default is "default")
    -- @tab[opt] settings controller settings to apply (if "all" is used, setting will be dropped)
    function HoundElint:enableNotifier(sectorName,settings)
        if type(sectorName) == "table" and settings == nil then
            settings  = sectorName
            sectorName = "default"
        end
        if sectorName == nil then sectorName = "default" end
        if self.sectors[sectorName] ~= nil then
            self.sectors[sectorName]:enableNotifier(settings)
        end
    end

    --- disable Notifier in sector
    -- @string[opt] sectorName Name of sector to act on. default is "default". all will disable all Notifiers
    function HoundElint:disableNotifier(sectorName)
        if sectorName == nil then
            sectorName = "default"
        end
        if sectorName == "all" then
            for _,sector in pairs(self.sectors) do
                sector:disableNotifier()
            end
            return
        end
        if self.sectors[sectorName] ~= nil then
            self.sectors[sectorName]:disableNotifier()
        end
    end

    --- remove controller in sector
    -- @string[opt] sectorName Name of sector to act on. default is "default". all will disable all Notifiers
    function HoundElint:removeNotifier(sectorName)
        if sectorName == nil then
            sectorName = "default"
        end
        if sectorName == "all" then
            for _,sector in pairs(self.sectors) do
                sector:removeNotifier()
            end
            return
        end
        if self.sectors[sectorName] ~= nil then
            self.sectors[sectorName]:removeNotifier()
        end
    end

    --- configure Notifier in sector
    -- @string[opt] sectorName name of sector to configure
    -- @tab settings settings for sector Notifier
    function HoundElint:configureNotifier(sectorName,settings)
        if sectorName == nil and settings == nil then return end
        if sectorName == nil and type(settings) == "table" then
            sectorName = "default"
        end
        if type(sectorName) =="table" and settings == nil then
            settings = sectorName
            sectorName = "default"
        end
        local notifierSettings = { notifier = settings}
        if self.sectors[sectorName] == nil then
            self:addSector(sectorName,notifierSettings)
        elseif self.sectors[sectorName] then
            self.sectors[sectorName]:updateSettings(notifierSettings)
        end
    end

    --- get Notifier freq
    -- @string[opt] sectorName name of sector to query
    -- @return frequncies table for sector's Notifier
    function HoundElint:getNotifierFreq(sectorName)
        sectorName = sectorName or "default"
        return self.sectors[sectorName]:getNotifierFreq() or {}
    end

    --- get Notifier state
    -- @string[opt] sectorName name of sector to probe
    -- @return (Bool) True = enabled. False is disable or not configured
    function HoundElint:getNotifierState(sectorName)
        sectorName = sectorName or "default"
        if self.sectors[sectorName] then
            return (self.sectors[sectorName]:isNotifierEnabled())
        end
        return false
    end
    --- Sector managment
    -- @section sectors

    --- enable Text notification for controller
    -- @string[opt] sectorName name of sector to enable (default is "default", "all" will enable on all sectors)
    function HoundElint:enableText(sectorName)
        if sectorName == nil or type(sectorName) ~= "string" then
            sectorName = "default"
        end
        if self.sectors[sectorName] then
            self.sectors[sectorName]:enableText()
            return
        end
        if string.lower(sectorName) == "all" then
            for _,sector in pairs(self.sectors) do
                sector:enableText()
            end
        end

    end

    --- disable Text notification for controller
    -- @string[opt] sectorName name of sector to disable (default is "default", "all" will enable on all sectors)
    function HoundElint:disableText(sectorName)
        if sectorName == nil or type(sectorName) ~= "string" then
            sectorName = "default"
        end
        if self.sectors[sectorName] then
            self.sectors[sectorName]:disableText()
            return
        end
        if string.lower(sectorName) == "all" then
            for _,sector in pairs(self.sectors) do
                sector:disableText()
            end
        end
    end

    --- enable Text-To-Speach notification for controller
    -- @string[opt] sectorName name of sector to enable (default is "default", "all" will enable on all sectors)
    function HoundElint:enableTTS(sectorName)
        if sectorName == nil or type(sectorName) ~= "string" then
            sectorName = "default"
        end
        if self.sectors[sectorName] then
            self.sectors[sectorName]:enableTTS()
            return
        end
        if string.lower(sectorName) == "all" then
            for _,sector in pairs(self.sectors) do
                sector:enableTTS()
            end
        end
    end

    --- disable Text-to-speach notification for controller
    -- @string[opt] sectorName name of sector to disable (default is "default", "all" will enable on all sectors)
    function HoundElint:disableTTS(sectorName)
        if sectorName == nil or type(sectorName) ~= "string" then
            sectorName = "default"
        end
        if self.sectors[sectorName] then
            self.sectors[sectorName]:disableTTS()
            return
        end
        if string.lower(sectorName) == "all" then
            for _,sector in pairs(self.sectors) do
                sector:disableTTS()
            end
        end
    end

    --- enable Alert notification for controller
    -- @string[opt] sectorName name of sector to enable (default is "default", "all" will enable on all sectors)
    function HoundElint:enableAlerts(sectorName)
        if sectorName == nil or type(sectorName) ~= "string" then
            sectorName = "default"
        end
        if self.sectors[sectorName] then
            self.sectors[sectorName]:enableAlerts()
            return
        end
        if string.lower(sectorName) == "all" then
            for _,sector in pairs(self.sectors) do
                sector:enableAlerts()
            end
        end

    end

    --- disable Alert notification for controller
    -- @string[opt] sectorName name of sector to disable (default is "default", "all" will enable on all sectors)
    function HoundElint:disableAlerts(sectorName)
        if sectorName == nil or type(sectorName) ~= "string" then
            sectorName = "default"
        end
        if self.sectors[sectorName] then
            self.sectors[sectorName]:disableAlerts()
            return
        end
        if string.lower(sectorName) == "all" then
            for _,sector in pairs(self.sectors) do
                sector:disableAlerts()
            end
        end
    end

    --- Set sector callsign
    -- @string sectorName sector to change
    -- @string sectorCallsign callsign for sector. if not provided, a random one will be selected from pool. "NATO" will draw from the NATO pool
    -- @return Bool. True if callsign was changes. False otherwise
    function HoundElint:setCallsign(sectorName,sectorCallsign)
        if not sectorName then return false end
        local NATO = self.settings:getUseNATOCallsigns()
        if sectorCallsign == "NATO" then
            sectorCallsign = true
        end
        if type(sectorCallsign) == "boolean" then
            NATO = sectorCallsign
            sectorCallsign = nil
        end
        if self.sectors[sectorName] then
            self.sectors[sectorName]:setCallsign(sectorCallsign,NATO)
            return true
        end
        return false
    end

    --- get sector callsign
    -- @string sectorName sector to change
    -- @return String - callsign for sector. will return empty string if err
    function HoundElint:getCallsign(sectorName)
        if not sectorName then return "" end
        if self.sectors[sectorName] then
            return self.sectors[sectorName]:getCallsign()
        end
        return ""
    end

    --- set transmitter to named sector
    -- @param sectorName name of sector to apply to.
    --- valid values are name of sector, "all" or nil (will change default)
    -- @param transmitter DCS unit name which will be the transmitter
    function HoundElint:setTransmitter(sectorName,transmitter)
        if not sectorName and not transmitter then return end
        if sectorName and not transmitter then
            transmitter = sectorName
            sectorName = "default"
        end
        if sectorName == nil then sectorName = "default" end
        if string.lower(sectorName) == "all" then
            for _,sector in pairs(self.sectors) do
                sector:setTransmitter(transmitter)
            end
        end
        if self.sectors[sectorName] then
            self.sectors[sectorName]:setTransmitter(transmitter)
        end
    end

    --- remove transmitter to named sector
    -- @param sectorName name of sector to apply to.
    --- valid values are name of sector, "all" or nil (will change default)
    function HoundElint:removeTransmitter(sectorName)
        if sectorName == nil then sectorName = "default" end
        if string.lower(sectorName) == "all" then
            for _,sector in pairs(self.sectors) do
                sector:removeTransmitter()
            end
        end
        if self.sectors[sectorName] then
            self.sectors[sectorName]:removeTransmitter()
        end
    end

    --- get zone of sector
    -- @param sectorName to act on
    -- @return table of points or nil if no sector set
    function HoundElint:getZone(sectorName)
        sectorName = sectorName or "default"
        if self.sectors[sectorName] then
            return self.sectors[sectorName]:getZone()
        end
    end

    --- add zone to sector
    -- @param sectorName to act on
    -- @param zoneCandidate DCS Group name. Group's waypoints will be used.
    -- same as MOOSE. use late activation invisible helicopter group is recommended.
    function HoundElint:setZone(sectorName,zoneCandidate)
        if type(sectorName) ~= "string" then return end
        if type(zoneCandidate) ~= "string" and zoneCandidate ~= nil then return end
        if self.sectors[sectorName] then
            self.sectors[sectorName]:setZone(zoneCandidate)
        end
        self:updateSectorMembership()
    end

    --- remove zone from sector
    -- @param sectorName to act on
    function HoundElint:removeZone(sectorName)
        if self.sectors[sectorName] then
            self.sectors[sectorName]:removeZone()
        end
        self:updateSectorMembership()
    end

    --- update sector membership for all contacts
    -- @local
    function HoundElint:updateSectorMembership()
        local sectors = self:getSectors()
        table.sort(sectors,HoundUtils.Sort.sectorsByPriorityLowFirst)
        for _,contact in ipairs(self.contacts:listAllContacts()) do
            for _,sector in pairs(sectors) do
                sector:updateSectorMembership(contact)
            end
        end
        for _,site in ipairs(self.contacts:listAllSites()) do
            site:updateSector()
        end
    end

    --- Instance Setup
    -- @section HoundElint

    --- enable Markers for Hound Instance (default)
    -- @param[opt] markerType change marker type to use
    -- @return (Bool) True if changed
    function HoundElint:enableMarkers(markerType)
        if markerType and HOUND.setContainsValue(HOUND.MARKER,markerType) then
            self:setMarkerType(markerType)
        end
        return self.settings:setUseMarkers(true)
    end

    --- disable Markers for Hound Instance
    -- @return (Bool) True if changed

    function HoundElint:disableMarkers()
        return self.settings:setUseMarkers(false)
    end

    --- enable Site Markers for Hound Instance (default)
    -- @return (Bool) True if changed
    function HoundElint:enableSiteMarkers()
        return self.settings:setMarkSites(true)
    end

    --- disable Site Markers for Hound Instance
    -- @return (Bool) True if changed

    function HoundElint:disableSiteMarkers()
        return self.settings:setMarkSites(false)
    end

    --- Set marker type for Hound instance
    -- @param markerType valid marker type enum
    -- @see HOUND.MARKER
    -- @return (Bool) True if changed
    function HoundElint:setMarkerType(markerType)
        if markerType and HOUND.setContainsValue(HOUND.MARKER,markerType) then
            return self.settings:setMarkerType(markerType)
        end
        return false
    end

    --- set intervals
    -- @param setIntervalName interval name to change (scan,process,menu,markers)
    -- @param setValue interval in seconds to set.
    -- @return (Bool) True if changed
    function HoundElint:setTimerInterval(setIntervalName,setValue)
        if self.settings and HOUND.setContains(self.settings.intervals,string.lower(setIntervalName)) then
            return self.settings:setInterval(setIntervalName,setValue)
        end
        return false
    end

    --- enable platforms INS position errors
    -- @return Bool if settings was updated
    function HoundElint:enablePlatformPosErrors()
        return self.settings:setPosErr(true)
    end

    --- disable platforms INS position errors
    -- @return Bool if settings was updated
    function HoundElint:disablePlatformPosErrors()
        return self.settings:setPosErr(false)
    end

    -- get current callsign override table
    -- @return table current state
    function HoundElint:getCallsignOverride()
        return self.settings:getCallsignOverride()
    end

    -- set callsign override table
    -- @param overrides Table of overrides
    -- @return (Bool) True if setting has been updated
    function HoundElint:setCallsignOverride(overrides)
        return self.settings:setCallsignOverride(overrides)
    end

    --- get current BDA setting state
    -- @return Bool current state
    function HoundElint:getBDA()
        return self.settings:getBDA()
    end

    --- enable BDA for Hound Instance
    -- Hound will notify on radar destruction
    -- @return (Bool) True if setting has been updated
    function HoundElint:enableBDA()
        return self.settings:setBDA(true)
    end

    --- disable BDA for Hound Instance
    -- @return (Bool) True if setting has been updated
    function HoundElint:disableBDA()
        return self.settings:setBDA(false)
    end

    --- Get current state of NATO brevity setting
    -- @return Bool current state
    function HoundElint:getNATO()
        return self.settings:getNATO()
    end

    --- enable NATO brevity for Hound Instance
    -- @return (Bool) True if setting has been updated
    function HoundElint:enableNATO()
        return self.settings:setNATO(true)
    end

    --- disable NATO brevity for Hound Instance
    -- @return (Bool) True if setting has been updated
    function HoundElint:disableNATO()
        return self.settings:setNATO(false)
    end

    --- set flag if callsignes for sectors under Callsignes would be from the NATO pool
    -- @return (Bool) True if setting has been updated
    function HoundElint:useNATOCallsignes(value)
        if type(value) ~= "boolean" then return false end
        return self.settings:setUseNATOCallsigns(value)
    end

    --- set Atis Update interval
    -- @param value desired interval in seconds
    -- @return true if change was made
    function HoundElint:setAtisUpdateInterval(value)
        return self.settings:setAtisUpdateInterval(value)
    end

    --- Set Main parent menu for hound Instace
    -- must be set <b>BEFORE</b> calling <code>enableController()</code>
    -- @param parent desired parent menu (pass nil to clear)
    -- @return (Bool) True if no errors
    function HoundElint:setRadioMenuParent(parent)
        local retval = self.settings:setRadioMenuParent(parent)
        if retval == true and self:isRunning() then
            self:populateRadioMenu()
        end
        return retval or false
    end

    -------------------------------

    --- Instance Internal functions
    -- @section HoundTiming

    --- Scheduled function that runs the main Instance loop
    -- @local
    -- @return time of next run
    function HoundElint.runCycle(self)
        local runTime = timer.getAbsTime()
        local timeCycle = StopWatch:Start("Cycle time " .. timer.getAbsTime())
        local nextRun = timer.getTime() + HOUND.Gaussian(self.settings.intervals.scan,self.settings.intervals.scan/10)
        if self.settings:getCoalition() == nil then return nextRun end
        if not self.contacts then return nextRun end

        self.contacts:platformRefresh()
        self.contacts:Sniff()

        if self.contacts:countContacts() > 0 then
            local doProcess = true
            local doMenus = false
            local doMarkers = false
            if self.timingCounters.lastProcess then
                doProcess = ((HoundUtils.absTimeDelta(self.timingCounters.lastProcess,runTime)/self.settings.intervals.process) > 0.99)
            end
            if self.timingCounters.lastMenus then
                doMenus = ((HoundUtils.absTimeDelta(self.timingCounters.lastMenus,runTime)/self.settings.intervals.menus) > 0.99)
            end
            if self.timingCounters.lastMarkers then
                doMarkers = ((HoundUtils.absTimeDelta(self.timingCounters.lastMarkers,runTime)/self.settings.intervals.markers) > 0.99)
            end

            if doProcess then
                local fastloop = StopWatch:Start("contact processing " .. timer.getAbsTime())
                self.contacts:Process()
                self:updateSectorMembership()
                fastloop:Stop()

                self.timingCounters.lastProcess = runTime
                if not self.timingCounters.lastMarkers then
                    self.timingCounters.lastMarkers = runTime
                end
                if not self.timingCounters.lastMenus then
                    self.timingCounters.lastMenus = runTime
                end
            end

            if doMenus then
                self:populateRadioMenu()
                self.timingCounters.lastMenus = runTime
            end

            if doMarkers then
                local slowLoop = StopWatch:Start("marker update " .. timer.getAbsTime())
                self.contacts:UpdateMarkers()
                self.timingCounters.lastMarkers = runTime
                slowLoop:Stop()
            end
        end
        if self.settings:getOnScreenDebug() then
            HOUND.Logger.onScreenDebug(self:printDebugging(),self.settings.intervals.scan*0.75)
        end
        timeCycle:Stop()
        return nextRun
    end

    --- Purge the root radio menu
    -- @local
    function HoundElint:purgeRadioMenu()
        for _,sector in pairs(self:getSectors()) do
            sector:removeRadioMenu()
        end
        self.settings:removeRadioMenu()
    end

    --- Trigger building of radio menu in all sectors
    -- @local
    function HoundElint:populateRadioMenu()
        if not self:isRunning() or not self.contacts or self.contacts:countContacts() == 0 or self.settings:getCoalition() == nil then
            return
        end
        local menuTimer = StopWatch:Start("Draw Menus " .. timer.getAbsTime())
        local sectors = self:getSectors()
        table.sort(sectors,HoundUtils.Sort.sectorsByPriorityLowLast)
        for _,sector in pairs(sectors) do
            sector:populateRadioMenu()
        end
        menuTimer:Stop()
    end

    --- Update the system state (on/off)
    -- @local
    -- TODO: remove?
    -- @param params table {self=&ltHoundInstance&gt,state=&ltBool&gt}
    function HoundElint.updateSystemState(params)
        local state = params.state
        local self = params.self
        if state == true then
            self:systemOn()
        elseif state == false then
            self:systemOff()
        end
    end

    --- Turn Hound system on
    -- @bool[opt] notify if True a text notification will be printed in 3d world
    function HoundElint:systemOn(notify)
        if self.settings:getCoalition() == nil then
            HOUND.Logger.warn("failed to start. no coalition found.")
            return false
        end
        self:systemOff(false)

        self.elintTaskID = timer.scheduleFunction(self.runCycle, self, timer.getTime() + self.settings.intervals.scan)
        if notify == nil or notify then
            trigger.action.outTextForCoalition(self.settings:getCoalition(),
                                           "Hound ELINT system is now Operating", 10)
        end
        env.info("Hound is now on")
        HOUND.EventHandler.publishEvent({
            id = HOUND.EVENTS.HOUND_ENABLED,
            houndId = self.settings:getId(),
            coalition = self.settings:getCoalition()
        })
        return true
    end

    --- Turn Hound system off
    -- @bool[opt] notify if True a text notification will be printed in 3d world
    function HoundElint:systemOff(notify)
        if self.elintTaskID ~= nil then
            timer.removeFunction(self.elintTaskID)
        end
        self:purgeRadioMenu()
        if notify == nil or notify then
            trigger.action.outTextForCoalition(self.settings:getCoalition(),
                                           "Hound ELINT system is now Offline", 10)
        end
        env.info("Hound is now off")
        HOUND.EventHandler.publishEvent({
            id = HOUND.EVENTS.HOUND_DISABLED,
            houndId = self.settings:getId(),
            coalition = self.settings:getCoalition()
        })
        return true
    end

    --- is Instance on
    -- @return Bool, True if system is running
    function HoundElint:isRunning()
        return (self.elintTaskID ~= nil)
    end

    --- Exports
    -- @section export

    --- get an exported list of all contacts tracked by the instance
    -- @return table of all contact tracked for integration with external tools
    function HoundElint:getContacts()
        local contacts = {
            ewr = { contacts = {} },
            sam = { contacts = {} }
            }
        for _,emitter in pairs(self.contacts:listAllContacts()) do
            local contact = emitter:export()
            if contact ~= nil then
                if emitter.isEWR then
                    table.insert(contacts.ewr.contacts,contact)
                else
                    table.insert(contacts.sam.contacts,contact)
                end
            end
        end
        contacts.ewr.count = #contacts.ewr.contacts or 0
        contacts.sam.count = #contacts.sam.contacts or 0
        return contacts
    end

    --- get an exported list of all sites tracked by the instance
    -- @return table of all contact tracked for integration with external tools
    function HoundElint:getSites()
        local contacts = {
            ewr = { sites = {} },
            sam = { sites = {} }
        }
        for _,site in pairs(self.contacts:listAllSites()) do
            local contact = site:export()
            if contact ~= nil then
                if site.isEWR then
                    table.insert(contacts.ewr.sites,contact)
                else
                    table.insert(contacts.sam.sites,contact)
                end
            end
        end
        contacts.ewr.count = #contacts.ewr.sites or 0
        contacts.sam.count = #contacts.sam.sites or 0
        return contacts
    end

    --- dump Intel Brief to csv
    -- will dump intel summery to CSV in the DCS saved games folder
    -- requires desanitization of lfs and io modules
    -- @param[opt] filename target filename. (default: hound_contacts_%d.csv)
    function HoundElint:dumpIntelBrief(filename)
        if lfs == nil or io == nil then
            HOUND.Logger.info("cannot write CSV. please desanitize lfs and io")
            return
        end
        if not filename then
            filename = string.format("hound_contacts_%d.csv",self:getId())
        end
        local currentGameTime = HoundUtils.Text.getTime()
        local csvFile = io.open(lfs.writedir() .. filename, "w+")
        csvFile:write("SiteId,SiteNatoDesignation,TrackId,RadarType,State,Bullseye,Latitude,Longitude,MGRS,Accuracy,lastSeen,DCStype,DCSunit,DCSgroup,ReportGenerated\n")
        csvFile:flush()
        for _,site in pairs(self.contacts:listAllSitesByRange()) do
            local siteItems = site:generateIntelBrief()
            if #siteItems > 0 then
                for _,item in ipairs(siteItems) do
                    csvFile:write(item .. "," .. currentGameTime .."\n")
                    csvFile:flush()
                end
            end
        end
        csvFile:close()
    end

    --- return Debugging information
    -- @return string
    function HoundElint:printDebugging()
        local debugMsg = "Hound instace " .. self:getId() .. " (".. HoundUtils.getCoalitionString(self:getCoalition()) .. ")\n"
        debugMsg = debugMsg .. "-----------------------------\n"
        debugMsg = debugMsg .. "Platforms: " .. self:countPlatforms() .. " | sectors: " .. self:countSectors()
        debugMsg = debugMsg .. " (Z:"..self:countSectors("zone").." ,C:"..self:countSectors("controller").." ,A: " .. self:countSectors("atis") .. " ,N:"..self:countSectors("notifier") ..") | "
        debugMsg = debugMsg .. "Sites: " .. self:countSites() .. " | Contacts: ".. self:countContacts() .. " (A:" .. self:countActiveContacts() .. " ,PB:" .. self:countPreBriefedContacts() .. ")"
        return debugMsg
    end

    --- EventHandler functions
    -- @section eventHandler

    --- builtin prototype for onHoundEvent function
    -- this function does NOTHING out of the box. put you own code here if needed
    -- @param houndEvent incoming event
    function HoundElint:onHoundEvent(houndEvent)
        return nil
    end

    --- built in onHoundEvent function
    -- @param houndEvent incoming event
    -- @local
    function HoundElint:onHoundInternalEvent(houndEvent)
        if houndEvent.houndId ~= self.settings:getId() then return end
        if houndEvent.id == HOUND.EVENTS.HOUND_DISABLED then return end

        local sectors = self:getSectors()
        table.sort(sectors,HoundUtils.Sort.sectorsByPriorityLowFirst)

        if houndEvent.id == HOUND.EVENTS.RADAR_DETECTED then
            for _,sector in pairs(sectors) do
                sector:updateSectorMembership(houndEvent.initiator)
            end
        end
        if self:isRunning() then
            for _,sector in pairs(sectors) do
                -- if houndEvent.id == HOUND.EVENTS.RADAR_DETECTED then
                --     sector:notifyEmitterNew(houndEvent.initiator)
                -- end
                if houndEvent.id == HOUND.EVENTS.RADAR_DESTROYED then
                    sector:notifyEmitterDead(houndEvent.initiator)
                end
                if houndEvent.id == HOUND.EVENTS.SITE_CREATED then
                    sector:notifySiteNew(houndEvent.initiator)
                end
                if houndEvent.id == HOUND.EVENTS.SITE_CLASSIFIED then
                    sector:notifySiteIdentified(houndEvent.initiator)
                end
                if houndEvent.id == HOUND.EVENTS.SITE_REMOVED or houndEvent.id == HOUND.EVENTS.SITE_ASLEEP then
                    sector:notifySiteDead(houndEvent.initiator,(houndEvent.id == HOUND.EVENTS.SITE_REMOVED))
                end
            end
            if houndEvent.id == HOUND.EVENTS.SITE_CREATED or houndEvent.id == HOUND.EVENTS.SITE_CLASSIFIED then
                self:populateRadioMenu()
                if self.settings:getMarkSites() then
                    houndEvent.initiator:updateMarker(HOUND.MARKER.NONE)
                end
            end
            if houndEvent.id == HOUND.EVENTS.RADAR_DETECTED then
                if self.settings:getUseMarkers() then
                    houndEvent.initiator:updateMarker(HOUND.MARKER.NONE)
                end
            end
        end
    end

    --- built in dcs onEvent
    -- @param DcsEvent incoming dcs event
    -- @local
    function HoundElint:onEvent(DcsEvent)
        if not DcsEvent.initiator or type(DcsEvent.initiator) ~= "table" then return end
        if type(DcsEvent.initiator.getCoalition) ~= "function" then return end

        if DcsEvent.id == world.event.S_EVENT_DEAD
            and DcsEvent.initiator:getCoalition() ~= self.settings:getCoalition()
            and self:getBDA()
            then
                return self:markDeadContact(DcsEvent.initiator)
        end

        if not self:isRunning() then return end

        if DcsEvent.id == world.event.S_EVENT_BIRTH
            and DcsEvent.initiator:getCoalition() == self.settings:getCoalition()
            and DcsEvent.initiator.getPlayerName ~= nil
            and DcsEvent.initiator:getPlayerName() ~= nil
            and HOUND.setContains(mist.DBs.humansByName,DcsEvent.initiator:getName())
            then return self:populateRadioMenu()
        end

        if (DcsEvent.id == world.event.S_EVENT_PLAYER_LEAVE_UNIT
            or DcsEvent.id == world.event.S_EVENT_PILOT_DEAD
            or DcsEvent.id == world.event.S_EVENT_EJECTION)
            and DcsEvent.initiator:getCoalition() == self.settings:getCoalition()
            and type(DcsEvent.initiator.getName) == "function"
            and HOUND.setContains(mist.DBs.humansByName,DcsEvent.initiator:getName())
                then return self:populateRadioMenu()
        end
    end

    --- enable/disable Hound instance internal event handling
    -- @bool[opt] remove if true default event handler will be removed
    -- @local
    function HoundElint:defaultEventHandler(remove)
        if remove == false then
            HOUND.EventHandler.removeInternalEventHandler(self)
            world.removeEventHandler(self)
            return
        end
        HOUND.EventHandler.addInternalEventHandler(self)
        world.addEventHandler(self)
    end
end
