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
        elint.addPositionError = false
        elint.positionErrorRadius = 30
        elint.settings = {
            mainInterval = 15,
            processInterval = 60,
            barkInterval = 120
        }
        elint.controller = {
            enable = false,
            textEnable = false,
            freq = 250.000,
            modulation = "AM",
            volume = "1.0",
            name = "Hound_Controller",
        }
        elint.atis = {
            enable = false,
            taskId = nil,
            interval = 55,
            freq = 250.500,
            modulation = "AM",
            name = "Hound_ATIS",
            body = "",
            header = "",
            footer = "",
            msg = "",
            msgTimeSec = 0,
            reportEWR = false
        }
        if platformName ~= nil then
            elint:addPlatform(platformName)
        end
        return elint
    end

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

    function HoundElint:platformRefresh()
        if length(self.platform) < 1 then return end
        local toRemove = {}
        for i = length(self.platform), 1,-1 do
            if self.platform[i]:isExist() == false or self.platform[i]:getLife() <
                1 then  table.remove(self.platform, i) end
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
        -- STTS.TextToSpeech("Hello DCS WORLD","251","AM","1.0","SRS",2)
        for k,v in pairs(args) do self.controller[k] = v end

        if (self.controller.freq ~= nil and STTS ~= nil) then
            self.controller.enable = true
        end
    end

    function HoundElint:configureAtis(args)
        for k,v in pairs(args) do self.atis[k] = v end
    end

    function HoundElint:toggleController(state,textMode)
        if ( STTS ~= nil ) then
            self.controller.enable = state
            return
        end
        self.controller.enable = false
     end

     function HoundElint:toggleControllerText(state)
        self.controller.textEnable = state
     end

     function HoundElint:enableController(textMode)
        self:toggleController(true)
        if textMode then
            self:toggleControllerText(true)
        end
        self:addRadioMenu()
    end

    function HoundElint:disableController(textMode)
        self:toggleController(false)
        if textMode then
            self:toggleControllerText(true)
        end
        self:removeRadioMenu()

    end


    function HoundElint:toggleATIS(state) 
        if ( STTS ~= nil ) then
            self.atis.enable = state
            return
        end
        self.atis.enable = false
    end

    function HoundElint:enableATIS()
        self:toggleATIS(true)
        -- self.atis.taskId = mist.scheduleFunction(self.TransmitATIS,{self}, 5, self.atis.interval)
        self.atis.taskId = timer.scheduleFunction(self.TransmitATIS,self, timer.getTime() + 15)
    end

    function HoundElint:disableATIS()
        self:toggleATIS(false)
        if self.atis.taskId ~= nil then
            timer.removeFunction(self.atis.taskId)
        end
    end

    function HoundElint:generateATIS()        
        local body = ""
        local numberEWR = 0

        if length(self.emitters) > 0 then
            for uid, emitter in pairs(self.emitters) do
                if emitter.pos.p ~= nil then
                    if emitter.isEWR == false or (self.atis.reportEWR and emitter.isEWR) then
                    body = body .. emitter:generateTtsBrief() .. " "
                    end
                    if (self.atis.reportEWR == false and emitter.isEWR) then
                        numberEWR = numberEWR+1
                    end
                end
            end
        end
        if body == "" then body = "No threats had been detected " end
        if numberEWR > 0 then body = body .. ",  " .. numberEWR .. " EWRs are tracked. " end
        if body == self.atis.body then return end
        self.atis.body = body

        local reportId = HoundUtils.TTS.getReportId()
        self.atis.header = "SAM information " .. reportId .. " " ..
                               HoundUtils.TTS.getTtsTime() .. ". "
        self.atis.footer = "you have information " .. reportId .. "."
        self.atis.msg = self.atis.header .. self.atis.body .. self.atis.footer
        -- Assumptions for time calc: 150 Words per min, avarage of 5 letters for english word
        -- so 5 chars = 750 characters per min = 12.5 chars per second
        -- so lengh of msg / 12.5 = number of seconds needed to read it. rounded down to 10 chars per sec
        self.atis.msgTimeSec = math.ceil(((string.len(self.atis.msg)/10)))
        -- env.info("estimates: " .. self.atis.msgTimeSec .. " seconds for lenght of ".. string.len(self.atis.msg))

    end

    function HoundElint.TransmitATIS(self)
        if self.atis.enable then
            self:generateATIS()
            HoundUtils.TTS.Transmit(self.atis.msg,self.coalitionId,self.atis)

        end
        self.atis.taskId = timer.scheduleFunction(self.TransmitATIS,self, timer.getTime() + self.atis.msgTimeSec + 5)
    end

    function HoundElint.TransmitSamReport(args)
        -- local self = args["self"]
        -- local emitter = args["emitter"]
        local coalitionId = args["self"].coalitionId
        if args["self"].controller.enable then
        HoundUtils.TTS.Transmit(args["emitter"]:generateTtsReport(),coalitionId,args["self"].controller)
        end
        if args["self"].controller.textEnable == true then
            trigger.action.outTextForCoalition(coalitionId,args["emitter"]:generateTextReport(),30)
        end
    end

    function HoundElint:notifyDeadEmitter(emitter)
        if self.controller.textEnable then
            trigger.action.outTextForCoalition(self.coalitionId,emitter:generateDeathReport(false),15)
        end
        if self.controller.enable then
            HoundUtils.TTS.Transmit(emitter:generateDeathReport(true),self.coalitionId,self.controller)
        end

    end

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

            -- env.info("looking at " .. RadarName )
            -- env.info(length(self.platform) .. " type " .. type(self.platform))
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
        -- env.info("end Sniff()")
    end

    function HoundElint:Process()
        for uid, emitter in pairs(self.emitters) do
            if emitter ~= nil then
                emitter:processData()
                emitter:CleanTimedout()
                if emitter:isAlive() == false and HoundUtils:timeDelta(emitter.last_seen, timer.getAbsTime()) > 60 then
                    self:notifyDeadEmitter(emitter)
                    emitter:removeMarker()
                    self.emitters[uid] = nil
                    self:removeRadioItem(self.radioMenu.data[emitter.typeAssigned].data[uid])
                else
                    if HoundUtils:timeDelta(emitter.last_seen,
                                            timer.getAbsTime()) > 1800 then
                        self.emitters[uid] = nil
                        self:removeRadioItem(self.radioMenu.data[emitter.typeAssigned].data[uid])
                    end
                end
            end
        end
    end

    function HoundElint:Bark()
        for uid, emitter in pairs(self.emitters) do
            -- env.info("updating marker for " .. emitter.unit:getName())
            emitter:updateMarker(self.coalitionId)
        end
    end

    function HoundElint.runCycle(self)
        if self.coalitionId == nil then return end
        if self.platform then self:platformRefresh() end
        -- env.info("platforms: " .. length(self.platform) )
        if length(self.platform) > 0 then
            -- env.info("sniff")
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
        if option == 'platformOn' then
            self:platformOn()
        elseif option == 'platformOff' then
            self:platformOff()
        end
    end

    function HoundElint:platformOn()
        env.info("Hound is now on")

        self:platformOff()

        self.elintTaskID = mist.scheduleFunction(self.runCycle, {self}, 1, self.settings.mainInterval)
       
        trigger.action.outTextForCoalition(self.coalitionId,
                                           "Hound ELINT system is now Operating",
                                           10)
    end

    function HoundElint:platformOff()
        env.info("Hound is now off")
        if self.elintTaskID ~= nil then
            mist.removeFunction(self.elintTaskID)
        end
        
        trigger.action.outTextForCoalition(self.coalitionId,
                                           "Hound ELINT system is now Offline",
                                           10)
    end

    -- TODO: Remove Menu when emitter dies:
    function HoundElint:addAdminRadioMenu()
        env.info("addAdminRadioMenu")
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

    function HoundElint:addRadioMenu()
        self.radioMenu.root = missionCommands.addSubMenuForCoalition(
                                  self.coalitionId, 'ELINT Intel')
        self.radioMenu.data = {}
        self.radioMenu.data["placeholder"] =
            missionCommands.addCommandForCoalition(self.coalitionId,
                                                   "No radars are currently tracked",
                                                   self.radioMenu.root,
                                                   timer.getAbsTime)

    end

    function HoundElint:populateRadioMenu()
        if self.radioMenu.root == nil or length(self.emitters) == 0 then
            return
        end
        local sortedContacts = {}

        for uid,emitter in pairs(self.emitters) do
            table.insert(sortedContacts,emitter)
        end

        table.sort(sortedContacts, function(a, b) 
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
        end)

        if length(sortedContacts) == 0 then return end
        for k,t in pairs(self.radioMenu.data) do
            t.counter = 0
        end
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

        if self.radioMenu.data["placeholder"] ~= nil and
            length(self.radioMenu.data) > 1 then
            missionCommands.removeItemForCoalition(self.coalitionId,
                                                   self.radioMenu.data["placeholder"])
            self.radioMenu.data["placeholder"] = nil
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
                missionCommands.removeItemForCoalition(self.coalitionId,v)
                self.radioMenu.data[assigned].menus[k] = nil
            end
        end

        local submenu = math.floor(self.radioMenu.data[assigned].counter/10)
        env.info("Item no." .. self.radioMenu.data[assigned].counter .. " submenu: " ..submenu)
        if submenu == 0 then
            self.radioMenu.data[assigned].data[uid] = missionCommands.addCommandForCoalition(self.coalitionId, emitter:generateRadioItemText(), self.radioMenu.data[assigned].root, self.TransmitSamReport,{self=self,emitter=emitter})
        end
        if submenu > 0 then
            if self.radioMenu.data[assigned].menus[submenu] == nil then
                if submenu == 1 then
                    self.radioMenu.data[assigned].menus[submenu] = missionCommands.addSubMenuForCoalition(self.coalitionId, "More (Page " .. submenu+1 .. ")", self.radioMenu.data[assigned].root)
                else
                    env.info("submenu: " .. submenu .. " chiled of: " .. submenu-1  )
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
            missionCommands.removeItemForCoalition(self.coalitionId, self.radioMenu.data[assigned].data[uid])
        end
    end


    function HoundElint:removeRadioMenu()
        missionCommands.removeItemForCoalition(self.coalitionId,
                                               self.radioMenu.root)
        self.radioMenu = {}
    end
end