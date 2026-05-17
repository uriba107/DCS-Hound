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
    -- @param[type=int] platformName Platform name or coalition enum
    -- @return[type=tab] HoundElint Instance
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

        HOUND.INSTANCES[elint.HoundId] = elint
        return elint
    end

    --- destructor function
    -- initiates cleanup
    function HoundElint:destroy()
        HOUND.Coroutine.cancelByName("markers-" .. self:getId())
        HOUND.Coroutine.cancelByName("sniff-discover-" .. self:getId())
        HOUND.Coroutine.cancelByName("sector-membership-" .. self:getId())
        self:systemOff(false)
        self:defaultEventHandler(true)

        for name,sector in pairs(self.sectors) do
            self.sectors[name] = sector:destroy()
        end
        self:purgeRadioMenu()
        HOUND.INSTANCES[self.HoundId] = nil
        self.contacts = nil
        self.settings = nil
        return nil
    end

    --- get Hound instance ID
    -- @return[type=Int] Int Hound ID
    function HoundElint:getId()
        return self.settings:getId()
    end

    --- get Hound instance Coalition
    -- @return[type=int] coalition enum of current hound instance
    function HoundElint:getCoalition()
        return self.settings:getCoalition()
    end

    --- set coalition for Hound Instance (Internal)
    -- @param[type=int] side coalition side enum
    -- @return[type=bool] Bool. True if coalition was set
    function HoundElint:setCoalition(side)
        if side == coalition.side.BLUE or side == coalition.side.RED then
            return self.settings:setCoalition(side)
        end
        return false
    end

    --- set onScreenDebug
    -- @param[type=bool] value to set
    -- @return[type=Bool] True if chaned
    function HoundElint:onScreenDebug(value)
        return self.settings:setOnScreenDebug(value)
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
                local processLoop = StopWatch:Start("contact processing " .. timer.getAbsTime())
                self.contacts:Process()
                self:updateSectorMembership()
                processLoop:Stop()

                self.timingCounters.lastProcess = runTime
                if not self.timingCounters.lastMarkers then
                    self.timingCounters.lastMarkers = runTime
                end
                if not self.timingCounters.lastMenus then
                    self.timingCounters.lastMenus = runTime
                end
            end
            local UILoop = StopWatch:Start("UI update " .. timer.getAbsTime())

            if doMenus then
                self:populateRadioMenu()
                self.timingCounters.lastMenus = runTime
            end

            if doMarkers then
                self.contacts:UpdateMarkers()
                self.timingCounters.lastMarkers = runTime
            end
            UILoop:Stop()
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
        if not self:isRunning() or not self.contacts or type(self.contacts:countContacts()) ~= "number" or self.settings:getCoalition() == nil then
            return
        end
        local menuTimer = StopWatch:Start("Draw Menus " .. timer.getAbsTime())
        HOUND.DB.updateHumanDb(self.settings:getCoalition())

        self.settings:resetSectorPages()

        local sectors = self:getSectors()
        table.sort(sectors,HoundUtils.Sort.sectorsByPriorityLowLast)
        for i,sector in pairs(sectors) do
            sector:populateRadioMenu()
        end
        -- HOUND.DB.cleanHumanDb(self.settings:getCoalition())
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
        env.info("Hound instance " .. self.settings:getId() .. " is now on")
        self:populateRadioMenu()
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
        HOUND.Coroutine.cancelByName("markers-" .. self:getId())
        HOUND.Coroutine.cancelByName("sniff-discover-" .. self:getId())
        HOUND.Coroutine.cancelByName("sector-membership-" .. self:getId())
        if self.elintTaskID ~= nil then
            timer.removeFunction(self.elintTaskID)
        end
        self:purgeRadioMenu()
        if notify == nil or notify then
            trigger.action.outTextForCoalition(self.settings:getCoalition(),
                                           "Hound ELINT system is now Offline", 10)
        end
        env.info("Hound instance " ..  self.settings:getId() .. " is now off")
        HOUND.EventHandler.publishEvent({
            id = HOUND.EVENTS.HOUND_DISABLED,
            houndId = self.settings:getId(),
            coalition = self.settings:getCoalition()
        })
        return true
    end

    --- is Instance on
    -- @return[type=bool], True if system is running
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
        csvFile:write("SiteId,SiteNatoDesignation,TrackId,RadarType,State,Bullseye,Latitude,Longitude,MGRS,Accuracy,lastSeen,DcsType,DcsUnit,DcsGroup,ReportGenerated\n")
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
end
