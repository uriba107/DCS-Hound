--- Hound Main interface
-- Elint system for DCS
-- @author uri_ba
-- @copyright uri_ba 2020-2021
-- @module HoundElint

do
    --- Controller managment
    -- @section Controller

    --- enable controller in sector
    -- @param[type=?string] sectorName name of sector in which a controller is enabled (default is "default") - "all" enable controller on all sectors
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
    -- @param[type=?string] sectorName Name of sector to act on. default is "default". all will disable all controllers
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
    -- @param[type=?string] sectorName Name of sector to act on. default is "default". all will disable all controllers
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
    -- @param[type=?string] sectorName name of sector to configure
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
    -- @param[type=?string] sectorName name of sector to configure
    -- @return frequncies table for sector's controller
    function HoundElint:getControllerFreq(sectorName)
        sectorName = sectorName or "default"
        if not self.sectors[sectorName] then return {} end
        return self.sectors[sectorName]:getControllerFreq() or {}
    end

    --- get controller state
    -- @param[type=?string] sectorName name of sector to probe
    -- @return[type=Bool] True = enabled. False is disable or not configured
    function HoundElint:getControllerState(sectorName)
        sectorName = sectorName or "default"

        if self.sectors[sectorName] then
            return (self.sectors[sectorName]:isControllerEnabled())
        end
        return false
    end

    --- Transmit custom TTS message on controller freqency
    -- @param[type=string] sectorName name of the sector to transmit on.
    -- @param[type=string] msg message to broadcast
    -- @param[type=?number] priority message priority
    function HoundElint:transmitOnController(sectorName,msg,priority)
        if not sectorName or not msg then return end
        if self.sectors[sectorName] then
            self.sectors[sectorName]:transmitOnController(msg,priority)
            return
        end
        if sectorName:lower() == "all" then
            for _,sector in pairs(self.sectors) do
                sector:transmitOnController(msg,priority)
            end
        end
    end

    --- ATIS managment
    -- @section ATIS

    --- enable ATIS in sector
    -- @param[type=?string] sectorName name of sector in which a controller is enabled (default is "default") - "all" enable ATIS on all sectors
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
    -- @param[type=?string] sectorName Name of sector to act on. default is "default". all will disable all ATIS
    function HoundElint:disableAtis(sectorName)
        if sectorName == nil then
            sectorName = "default"
        end
        if self.sectors[sectorName] ~= nil then
            self.sectors[sectorName]:disableAtis()
            return
        end
        if string.lower(sectorName) == "all" then
            for _,sector in pairs(self.sectors) do
                sector:disableAtis()
            end
        end
    end

    --- remove ATIS in sector
    -- @param[type=?string] sectorName Name of sector to act on. default is "default". all will disable all ATIS
    function HoundElint:removeAtis(sectorName)
        if sectorName == nil then
            sectorName = "default"
        end
        if string.lower(sectorName) == "all" then
            for _,sector in pairs(self.sectors) do
                sector:removeAtis()
            end
        elseif self.sectors[sectorName] ~= nil then
            self.sectors[sectorName]:removeAtis()
        end
    end

    --- configure ATIS in sector
    -- @param[type=?string] sectorName name of sector to configure
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
    -- @param[type=?string] sectorName name of sector to query
    -- @return frequncies table for sector's controller
    function HoundElint:getAtisFreq(sectorName)
        sectorName = sectorName or "default"
        if not self.sectors[sectorName] then return {} end
        return self.sectors[sectorName]:getAtisFreq() or {}
    end

    --- set ATIS EWR report state for sector
    -- @param[type=?string] name sector name. valid inputs are sector name, "all". nothing will default to "default"
    -- @bool state set desired state
    function HoundElint:reportEWR(name,state)
        if type(name) == "boolean" then
            state = name
            name = "default"
        end
        if type(name) ~= "string" or type(state) ~= "boolean" then return end
        if self.sectors[name] then
            self.sectors[name]:reportEWR(state)
            return
        end
        if string.lower(name) == "all" then
            for _,sector in pairs(self.sectors) do
                sector:reportEWR(state)
            end
        end
    end

    --- get ATIS state
    -- @param[type=?string] sectorName name of sector to probe
    -- @return[type=Bool] True = enabled. False is disable or not configured
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
    -- @param[type=?string] sectorName name of sector in which a Notifier is enabled (default is "default")
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
    -- @param[type=?string] sectorName Name of sector to act on. default is "default". all will disable all Notifiers
    function HoundElint:disableNotifier(sectorName)
        if sectorName == nil then
            sectorName = "default"
        end
        if string.lower(sectorName) == "all" then
            for _,sector in pairs(self.sectors) do
                sector:disableNotifier()
            end
            return
        end
        if self.sectors[sectorName] ~= nil then
            self.sectors[sectorName]:disableNotifier()
        end
    end

    --- remove Notifier in sector
    -- @param[type=?string] sectorName Name of sector to act on. default is "default". all will disable all Notifiers
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
    -- @param[type=?string] sectorName name of sector to configure
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
    -- @param[type=?string] sectorName name of sector to query
    -- @return frequncies table for sector's Notifier
    function HoundElint:getNotifierFreq(sectorName)
        sectorName = sectorName or "default"
        return self.sectors[sectorName]:getNotifierFreq() or {}
    end

    --- get Notifier state
    -- @param[type=?string] sectorName name of sector to probe
    -- @return[type=Bool] True = enabled. False is disable or not configured
    function HoundElint:getNotifierState(sectorName)
        sectorName = sectorName or "default"
        if self.sectors[sectorName] then
            return (self.sectors[sectorName]:isNotifierEnabled())
        end
        return false
    end

    --- Transmit custom TTS message on Notifier freqency
    -- @param[type=string] sectorName name of the sector to transmit on.
    -- @param[type=string] msg  message to broadcast
    -- @param[type=?number] priority message priority
    function HoundElint:transmitOnNotifier(sectorName,msg,priority)
        if not sectorName or not msg then return end
        if self.sectors[sectorName] then
            self.sectors[sectorName]:transmitOnNotifier(msg,priority)
            return
        end
        if string.lower(sectorName) == "all" then
            for _,sector in pairs(self.sectors) do
                sector:transmitOnNotifier(msg,priority)
            end
        end
    end
end
