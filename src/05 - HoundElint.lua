-- -------------------------------------------------------------
do
    HoundElint = {}
    HoundElint.__index = HoundElint

    function HoundElint:create(platformName)
        local elint = {}
        setmetatable(elint, HoundElint)
        elint.platform = {}
        elint.emitters = {}
        elint.elintTaskID = nil
        elint.radioMenu = {}
        elint.radioAdminMenu = nil
        elint.coalitionId = nil
        elint.useMarkers = true
        elint.addPositionError = false
        elint.positionErrorRadius = 30

        elint.settings = {
            mainInterval = 15,
            processInterval = 60,
            barkInterval = 120
        }

        if platformName ~= nil then
            elint:addPlatform(platformName)
        end

        elint.controller = HoundCommsManager:create()
        elint.controller.settings.enableText = false
        elint.controller.settings.alerts = true

        elint.atis = HoundCommsManager:create()
        elint.atis.settings.freq = 250.500
        elint.atis.settings.interval = 4
        elint.atis.settings.speed = 1

        elint.atis.reportEWR = false
        return elint
    end

    --[[
        Admin functions
    --]]
    function HoundElint:addPlatform(platformName)

        local canidate = Unit.getByName(platformName)
        if canidate == nil then
            canidate = StaticObject.getByName(platformName)
        end

        if self.coalitionId == nil and canidate ~= nil then
            self.coalitionId = canidate:getCoalition()
        end
        if canidate ~= nil and canidate:getCoalition() == self.coalitionId then
            local mainCategoty = canidate:getCategory()
            local type = canidate:getTypeName()
    
            if setContains(PlatformData,mainCategoty) then
                if setContains(PlatformData[mainCategoty],type) then
                    for k,v in pairs(self.platform) do
                        if v == canidate then
                            return
                        end
                    end
                    table.insert(self.platform, canidate)
                end
            end
        end
    end



    function HoundElint:removePlatform(platformName)
        local canidate = Unit.getByName(platformName)
        if canidate == nil then
            canidate = StaticObject.getByName(platformName)
        end

        if canidate ~= nil then
            for k,v in ipairs(self.platform) do
                if v == canidate then
                    table.remove(self.platform, k)
                    return
                end
            end
        end
    end

    function HoundElint:platformRefresh()
        if length(self.platform) < 1 then return end
        local toRemove = {}
        for i = length(self.platform), 1,-1 do
            if self.platform[i]:isExist() == false or self.platform[i]:getLife() <1 then  
                table.remove(self.platform, i) 
            end
        end
    end

    function HoundElint:removeDeadPlatforms()
        if length(self.platform) < 1 then return end
        for i=table.getn(self.platform),1,-1  do
            if self.platform[i]:isExist() == false or self.platform[i]:getLife() < 1 or (self.platform[i]:getCategory() ~= Object.Category.STATIC and self.platform[i]:isActive() == false) then
                table.remove(self.platform,i)
            end
        end
    end


    function HoundElint:configureController(args)
        self.controller:updateSettings(args)

    end

    function HoundElint:configureAtis(args)
        self.atis:updateSettings(args)
    end


    --[[
        Toggle functions
    --]]


    function HoundElint:toggleController(state,textMode)
        if STTS ~= nil  then
            if state == true and type(state) == "boolean" then
                self.controller:enable()
                return
            end
        end
        self.controller:disable()
     end

     function HoundElint:toggleControllerText(state)
        if type(state) == "boolean" then
            self.controller.settings.enableText = state
        end
     end

     function HoundElint:enableController(textMode)
        self:toggleController(true)
        self.controller:enable()
        if textMode then
            self:toggleControllerText(true)
        end
        self:addRadioMenu()
    end

    function HoundElint:disableController(textMode)
        self.controller:disable()
        if textMode then
            self:toggleControllerText(true)
        end
        self:removeRadioMenu()
    end

    function HoundElint:controllerReportEWR(state)
        if type(state) == "boolean" then
            self.atis.reportEWR = state
        end
    end


    function HoundElint:toggleATIS(state) 
        if STTS ~= nil then
            if state == true and type(state) == "boolean" then
                    self.atis:enable()
            end
            return
        end
        self.atis:disable()
    end

    function HoundElint:enableATIS()
        self.atis:enable()
        self.atis:SetMsgCallback(self.generateATIS,self)
    end

    function HoundElint:disableATIS()
        self.atis:disable()
    end

    function HoundElint:enableMarkers()
        self.useMarkers = true
    end

    function HoundElint:disableMarkers()
        self.useMarkers = false
        
    end
    --[[
        ATIS functions
    --]]

    function HoundElint.generateATIS(gSelf)        
        local body = ""
        local numberEWR = 0

        if length(gSelf.emitters) > 0 then
            if gSelf.atis.loop.last_update ~= nil then
                if timer.getTime() - gSelf.atis.loop.last_update < 120 then return end
            end
            for uid, emitter in pairs(gSelf.emitters) do
                if emitter.pos.p ~= nil then
                    if emitter.isEWR == false or (gSelf.atis.settings.reportEWR and emitter.isEWR) then
                    body = body .. emitter:generateTtsBrief() .. " "
                    end
                    if (gSelf.atis.settings.reportEWR == false and emitter.isEWR) then
                        numberEWR = numberEWR+1
                    end
                end
            end
        end
        if body == "" then body = "No threats had been detected " end
        if numberEWR > 0 then body = body .. ",  " .. numberEWR .. " EWRs are tracked. " end
        if body == gSelf.atis.loop.body then return end
        gSelf.atis.loop.body = body

        local reportId = HoundUtils.TTS.getReportId()
        gSelf.atis.loop.header = gSelf.atis.settings.name .. " SAM information " .. reportId .. " " ..
                               HoundUtils.TTS.getTtsTime() .. ". "
        gSelf.atis.loop.footer = "you have " .. reportId .. "."
        local msg = gSelf.atis.loop.header .. gSelf.atis.loop.body .. gSelf.atis.loop.footer
        local msgObj = {
            coalition = gSelf.coalitionId,
            priority = "loop",
            tts = msg
        }

        gSelf.atis.loop.msg = msgObj
        gSelf.atis.loop.last_update = timer.getTime()

    end


    --[[
        Controller functions
    --]]

    function HoundElint.TransmitSamReport(args)
        local gSelf = args["self"]
        local emitter = args["emitter"]
        local requester = args["requester"]
        local controllerCallsign = args["self"].controller.settings.name
        local coalitionId = args["self"].coalitionId
        local msgObj = {
            coalition = args["self"].coalitionId,
            priority = 1
        }
        if emitter.isEWR then msgObj.priority = 2 end

        if gSelf.controller.enabled then
            msgObj.tts = args["emitter"]:generateTtsReport()
            if requester ~= nil then
                msgObj.tts = requester .. ", " .. controllerCallsign .. ", " .. msgObj.tts
            end
        end
        if gSelf.controller.settings.enableText == true then
            msgObj.txt = emitter:generateTextReport()
        end

        gSelf.controller:addMessageObj(msgObj)

    end


    function HoundElint:notifyDeadEmitter(emitter)
        if self.controller.settings.alerts == false then return end
        local msg = {
            coalition = self.coalitionId,
            priority = 3
        }
        if self.controller.settings.enableText then
            msg.txt = emitter:generateDeathReport(false)
        end
        msg.tts = emitter:generateDeathReport(true)
        self.controller:addMessageObj(msg)
    end

    function HoundElint:notifyNewEmitter(emitter)
        if self.controller.settings.alerts == false then return end
        local msg = {
            coalition = self.coalitionId,
            priority = 2
        }
        if self.controller.settings.enableText then
            msg.txt = emitter:generatePopUpReport(false)
        end
        msg.tts = emitter:generatePopUpReport(true)
        
        self.controller:addMessageObj(msg)
    end

    --[[
        Actual work functions
    --]]

    function HoundElint:getSensorError(platform)
        local mainCategoty = platform:getCategory()
        local type = platform:getTypeName()

        if setContains(PlatformData,mainCategoty) then
            if setContains(PlatformData[mainCategoty],type) then
                return PlatformData[mainCategoty][type].precision
            end
        end
        return 15.0
    end

    function HoundElint:getAzimuth(src, dst, sensorError)
        local dirRad = mist.utils.getDir(mist.vec.sub(dst, src))
        local randomError = gaussian(0, sensorError * 50) / 100
        -- env.info("sensor is: ".. sensorError .. "passing in " .. sensorError*500 / 1000 .. " Error: " .. randomError )
        local AzDeg = mist.utils.round((math.deg(dirRad) + randomError + 360) % 360, 3)
        -- env.info("az: " .. math.deg(dirRad) .. " err: "..  randomError .. " final: " ..AzDeg)
        return math.rad(AzDeg)
    end

    function HoundElint:getActiveRadars()
        local Radars = {}

        -- start logic
        for coalitionId,coalitionName in pairs(coalition.side) do
            if coalitionName ~= self.coalitionId then
                -- env.info("starting coalition ".. coalitionName)
                for cid,CategoryId in pairs({Group.Category.GROUND,Group.Category.SHIP}) do
                    -- env.info("starting categoty ".. CategoryId)
                    for gid, group in pairs(coalition.getGroups(coalitionName, CategoryId)) do
                        -- env.info("starting group ".. group:getName())
                        for uid, unit in pairs(group:getUnits()) do
                            -- env.info("looking at ".. unit:getName())
                            if (unit:isExist() and unit:isActive() and unit:getRadar()) then
                                table.insert(Radars, unit:getName()) -- insert the name
                            end
                        end
                    end
                end

            end
        end
        return Radars
    end

    function HoundElint:Sniff()
        local Recivers = {}
        self:removeDeadPlatforms()

        if length(self.platform) == 0 then
            env.info("no active platform")
            return
        end

        local Radars = self:getActiveRadars()

        if length(Radars) == 0 then
            env.info("No Transmitting Radars")
            return
        end
        env.info("Recivers: " .. table.getn(self.platform) .. " | Radars: " .. table.getn(Radars))

        for i,RadarName in ipairs(Radars) do
            local radar = Unit.getByName(RadarName)
            local RadarUid = radar:getID()
            local RadarType = radar:getTypeName()
            local RadarName = radar:getName()
            local radarPos = radar:getPosition().p
            radarPos.y = radarPos.y + 20 -- assume 10 meters radar antenna

            for j,platform in ipairs(self.platform) do
                local platformPos = platform:getPosition().p
                local platformId = platform:getID()
                local platformIsStatic = false

                if platform:getCategory() == Object.Category.STATIC then
                    platformIsStatic = true
                    platformPos.y = platformPos.y + 60
                else
                    local PlatformUnitCategory = platform:getDesc()["category"]
                    if (self.addPositionError and ( PlatformUnitCategory == Unit.Category.HELICOPTER or PlatformUnitCategory == Unit.Category.AIRPLANE)) then
                        platformPos = mist.getRandPointInCircle( platform:getPosition().p, self.positionErrorRadius)
                    end
                    if PlatformUnitCategory == Unit.Category.GROUND_UNIT then
                        platformPos.y = platformPos.y + 15 
                    end
                end

                if land.isVisible(platformPos, radarPos) then
                    if (self.emitters[RadarUid] == nil) then
                        self.emitters[RadarUid] =
                            HoundContact:New(radar, self.coalitionId)
                    end
                    local az = self:getAzimuth(platformPos, radarPos, self:getSensorError(platform))
                    -- env.info(platform:getName() .. "-->".. RadarName .. " Az: " .. az )
                    local datapoint = HoundElintDatapoint:New(platformId,platformPos, az, timer.getAbsTime(),platformIsStatic)
                    self.emitters[RadarUid]:AddPoint(datapoint)
                end
            end
        end
    end

    function HoundElint:Process()
        local currentTime = timer.getTime() + 0.2
        -- if self.controller.msgTimer < currentTime then
        --     self.controller.msgTimer = currentTime
        -- end
        for uid, emitter in pairs(self.emitters) do
            if emitter ~= nil then
                local isNew = emitter:processData()
                if isNew then
                    self:notifyNewEmitter(emitter)
                    if self.useMarkers then emitter:updateMarker(self.coalitionId) end
                end
                emitter:CleanTimedout()
                if emitter:isAlive() == false and HoundUtils:timeDelta(emitter.last_seen, timer.getAbsTime()) > 60 then
                    self:notifyDeadEmitter(emitter)
                    self:removeRadarRadioItem(emitter)
                    emitter:removeMarker()
                    self.emitters[uid] = nil
                else
                    if HoundUtils:timeDelta(emitter.last_seen,
                                            timer.getAbsTime()) > 1800 then
                        self:removeRadarRadioItem(emitter)
                        emitter:removeMarker()
                        self.emitters[uid] = nil
                    end
                end
            end
        end
    end

    function HoundElint:Bark()
        for uid, emitter in pairs(self.emitters) do
           if self.useMarkers then emitter:updateMarker(self.coalitionId) end
        end
    end

    function HoundElint.runCycle(self)
        if self.coalitionId == nil then return end
        if self.platform then self:platformRefresh() end
        if length(self.platform) > 0 then
            self:Sniff()
        end
        if length(self.emitters) > 0 then
            if timer.getAbsTime() % math.floor(gaussian(self.settings.processInterval,3)) < self.settings.mainInterval+5 then 
                self:Process() 
                self:populateRadioMenu()
            end
            if timer.getAbsTime() % math.floor(gaussian(self.settings.barkInterval,7)) < self.settings.mainInterval+5 then
                self:Bark()
            end
        end
    end

    function HoundElint.updatePlatformState(params)
        local option = params.option
        local self = params.self
        if option == 'systemOn' then
            self:systemOn()
        elseif option == 'systemOff' then
            self:systemOff()
        end
    end

    function HoundElint:systemOn()
        env.info("Hound is now on")

        self:systemOff()

        self.elintTaskID = mist.scheduleFunction(self.runCycle, {self}, 1, self.settings.mainInterval)
       
        trigger.action.outTextForCoalition(self.coalitionId,
                                           "Hound ELINT system is now Operating", 10)
    end

    function HoundElint:systemOff()
        env.info("Hound is now off")
        if self.elintTaskID ~= nil then
            mist.removeFunction(self.elintTaskID)
        end
        
        trigger.action.outTextForCoalition(self.coalitionId,
                                           "Hound ELINT system is now Offline",
                                           10)
    end

    --[[
        Menu functions - Admin Menu
    --]]
    -- TODO: Remove Menu when emitter dies:
    function HoundElint:addAdminRadioMenu()
        self.radioAdminMenu = missionCommands.addSubMenuForCoalition(
                                  self.coalitionId, 'ELINT managment')
        missionCommands.addCommandForCoalition(self.coalitionId, 'Activate',
                                               self.radioAdminMenu,
                                               HoundElint.updatePlatformState, {
            self = self,
            option = 'platformOn'
        })
        missionCommands.addCommandForCoalition(self.coalitionId, 'DeActivate',
                                               self.radioAdminMenu,
                                               HoundElint.updatePlatformState, {
            self = self,
            option = 'platformOff'
        })
    end

    function HoundElint:removeAdminRadioMenu()
        missionCommands.removeItem(self.radioAdminMenu)
    end

    --[[
        Menu functions - Unit Info Menues
    --]]

    function HoundElint:addRadioMenu()
        self.radioMenu.root = missionCommands.addSubMenuForCoalition(
                                  self.coalitionId, 'ELINT Intel')
        self.radioMenu.data = {}
        self.radioMenu.noData = missionCommands.addCommandForCoalition(self.coalitionId,
                                                   "No radars are currently tracked",
                                                   self.radioMenu.root, timer.getAbsTime)

    end

    function HoundElint.sortContacts(a,b)
        if a.isEWR ~= b.isEWR then
          return b.isEWR and not a.isEWR
        end
        if a.maxRange ~= b.maxRange then
            return a.maxRange > b.maxRange
        end
        if a.typeAssigned ~= b.typeAssigned then
            return a.typeAssigned < b.typeAssigned
        end
        if a.typeName ~= b.typeName then
            return a.typeName < b.typeName
        end
        if a.first_seen ~= b.first_seen then
            return a.first_seen > b.first_seen
        end
        return a.uid < b.uid 
    end

    function HoundElint:populateRadioMenu()
        if self.radioMenu.root == nil or length(self.emitters) == 0 or self.coalitionId == nil then
            return
        end
        local sortedContacts = {}

        for uid,emitter in pairs(self.emitters) do
            table.insert(sortedContacts,emitter)
        end

        table.sort(sortedContacts, HoundElint.sortContacts)

        if length(sortedContacts) == 0 then return end
        for k,t in pairs(self.radioMenu.data) do
            if k ~= "placeholder" then
                t.counter = 0
            end
        end

        -- local players = {}
        -- for i, player in ipairs(coalition.getPlayers(self.coalitionId)) do
        --     env.info("player loop " .. i)
        --     local gid = Unit.getGroup(player):getID()
        --     local callsign = Unit.getCallsign(player)
        --     env.info(Unit.getName(player).. " " .. callsign .. " " .. gid)
        -- end

        for id, emitter in ipairs(sortedContacts) do
            local DCStypeName = emitter.DCStypeName
            local assigned = emitter.typeAssigned
            local uid = emitter.uid
            if emitter.pos.p ~= nil then
                if length(self.radioMenu.data[assigned]) == 0 then
                    -- env.info("create " .. assigned)
                    self.radioMenu.data[assigned] = {}
                    self.radioMenu.data[assigned].root =
                        missionCommands.addSubMenuForCoalition(self.coalitionId,
                                                               assigned, self.radioMenu.root)
                    self.radioMenu.data[assigned].data = {}
                    self.radioMenu.data[assigned].menus = {}
                    self.radioMenu.data[assigned].counter = 0
                end

                self:removeRadarRadioItem(emitter)
                self:addRadarRadioItem(emitter)
            end
        end
    end


    function HoundElint:addRadarRadioItem(emitter)
        local DCStypeName = emitter.DCStypeName
        local assigned = emitter.typeAssigned
        local uid = emitter.uid
        local text = emitter:generateRadioItemText()

        self.radioMenu.data[assigned].counter = self.radioMenu.data[assigned].counter + 1

        if self.radioMenu.data[assigned].counter == 1 then
            for k,v in pairs(self.radioMenu.data[assigned].menus) do
                self.radioMenu.data[assigned].menus[k] = missionCommands.removeItemForCoalition(self.coalitionId,v)
            end
        end

        if self.radioMenu.noData ~= nil then
            self.radioMenu.noData = missionCommands.removeItemForCoalition(self.coalitionId, self.radioMenu.noData)
        end

        
        local submenu = 0
        if self.radioMenu.data[assigned].counter > 9 then
            submenu = math.floor((self.radioMenu.data[assigned].counter+1)/10)
        end
        if submenu == 0 then
            self.radioMenu.data[assigned].data[uid] = missionCommands.addCommandForCoalition(self.coalitionId, emitter:generateRadioItemText(), self.radioMenu.data[assigned].root, self.TransmitSamReport,{self=self,emitter=emitter})
        end
        if submenu > 0 then
            if self.radioMenu.data[assigned].menus[submenu] == nil then
                if submenu == 1 then
                    self.radioMenu.data[assigned].menus[submenu] = missionCommands.addSubMenuForCoalition(self.coalitionId, "More (Page " .. submenu+1 .. ")", self.radioMenu.data[assigned].root)
                else
                    self.radioMenu.data[assigned].menus[submenu] = missionCommands.addSubMenuForCoalition(self.coalitionId, "More (Page " .. submenu+1 .. ")", self.radioMenu.data[assigned].menus[submenu-1])
                end
            end
            self.radioMenu.data[assigned].data[uid] = missionCommands.addCommandForCoalition(self.coalitionId, emitter:generateRadioItemText(), self.radioMenu.data[assigned].menus[submenu], self.TransmitSamReport,{self=self,emitter=emitter})
        end

    end

    function HoundElint:removeRadarRadioItem(emitter)
        local DCStypeName = emitter.DCStypeName
        local assigned = emitter.typeAssigned
        local uid = emitter.uid
        -- env.info(length(emitter) .. " uid: " .. uid .. " DCStypeName: " .. DCStypeName)

        if setContains(self.radioMenu.data[assigned].data,uid) then
            self.radioMenu.data[assigned].data[uid] = missionCommands.removeItemForCoalition(self.coalitionId, self.radioMenu.data[assigned].data[uid])
        end
    end


    function HoundElint:removeRadioMenu()
        missionCommands.removeItemForCoalition(self.coalitionId,
                                               self.radioMenu.root)
        self.radioMenu = {}
    end
end
