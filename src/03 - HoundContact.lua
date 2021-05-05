-- --------------------------------------
do
    HoundElintDatapoint = {}
    HoundElintDatapoint.__index = HoundElintDatapoint

    function HoundElintDatapoint:New(id0, p0, az0, el0, t0,isPlatformStatic)
        local elintDatapoint = {}
        setmetatable(elintDatapoint, HoundElintDatapoint)
        elintDatapoint.platformPos = p0
        elintDatapoint.az = az0
        elintDatapoint.el = el0
        elintDatapoint.t = tonumber(t0)
        elintDatapoint.platformId = id0
        elintDatapoint.platformStatic = isPlatformStatic
        elintDatapoint.estimatedPos = nil
        return elintDatapoint
    end

    function HoundElintDatapoint:estimatePos()
        if self.el == nil then return end
        -- env.info("decl is " .. mist.utils.toDegree(self.el))
        local maxSlant = self.platformPos.y/math.abs(math.sin(self.el))

        local unitVector = {
            x = math.cos(self.el)*math.cos(self.az),
            z = math.cos(self.el)*math.sin(self.az),
            y = math.sin(self.el)
        }
        -- env.info("unit Vector: X " ..unitVector.x .." ,Z "..unitVector.z..", Y:" .. unitVector.y .. " | maxSlant " .. maxSlant)

        self.estimatedPos = land.getIP(self.platformPos, unitVector , maxSlant+100 )
        -- debugging
        -- env.info(mist.utils.tableShow( self.estimatedPos))
        -- local latitude, longitude, altitude = coord.LOtoLL(self.estimatedPos)
        -- env.info("estimated 3d point: Lat " ..latitude.." ,lon "..longitude..", alt:" .. tostring(altitude) )

    end
end

do
    HoundContact = {}
    HoundContact.__index = HoundContact

    function HoundContact:New(DCS_Unit,platformCoalition)
        local elintcontact = {}
        setmetatable(elintcontact, HoundContact)
        elintcontact.unit = DCS_Unit
        elintcontact.uid = DCS_Unit:getID()
        elintcontact.DCStypeName = DCS_Unit:getTypeName()
        elintcontact.typeName = DCS_Unit:getTypeName()
        elintcontact.isEWR = false
        elintcontact.typeAssigned = "Unknown" 
        if setContains(HoundSamDB,DCS_Unit:getTypeName())  then
            elintcontact.typeName =  HoundSamDB[DCS_Unit:getTypeName()].Name
            elintcontact.isEWR = (HoundSamDB[DCS_Unit:getTypeName()].Role == "EWR")
            elintcontact.typeAssigned = HoundSamDB[DCS_Unit:getTypeName()].Assigned
        end
         
        elintcontact.pos = {
            p = nil,
            grid = nil,
            LL = {
                lat = nil, 
                lon = nil,
            },
            be = {
                brg = nil,
                rng = nil
            }
        }
        elintcontact.uncertenty_radius = nil
        elintcontact.last_seen = timer.getAbsTime()
        elintcontact.first_seen = timer.getAbsTime()
        elintcontact.maxRange = HoundUtils.getSamMaxRange(DCS_Unit)
        elintcontact.dataPoints = {}
        elintcontact.markpointID = -1
        elintcontact.platformCoalition = platformCoalition
        return elintcontact
    end

    function HoundContact:CleanTimedout()
        if HoundUtils:timeDelta(timer.getAbsTime(), self.last_seen) > 900 then
            -- if contact wasn't seen for 15 minuts purge all currnent data
            self.dataPoints = {}
        end
    end

    function HoundContact:isAlive()
        if self.unit:isExist() == false or self.unit:getLife() < 1 then return false end
        return true
    end

    function HoundContact:AddPoint(datapoint)

        self.last_seen = datapoint.t
        if length(self.dataPoints[datapoint.platformId]) == 0 then
            self.dataPoints[datapoint.platformId] = {}
        end

        if datapoint.platformStatic then
            -- if Reciver is static, just keep the last Datapoint, as position never changes.
            -- if There is a datapoint, do rolling avarage on AZ to clean errors out.
            if length(self.dataPoints[datapoint.platformId]) > 0 then
                datapoint.az =  HoundUtils.AzimuthAverage({datapoint.az,self.dataPoints[datapoint.platformId][1].az})
            end
            self.dataPoints[datapoint.platformId] = {datapoint}
            return
        end
        if datapoint.el ~=nil then
            datapoint:estimatePos()
        end

        if length(self.dataPoints[datapoint.platformId]) < 2 then
            table.insert(self.dataPoints[datapoint.platformId], datapoint)
        else
            local LastElementIndex = table.getn(self.dataPoints[datapoint.platformId])
            local DeltaT = HoundUtils:timeDelta(self.dataPoints[datapoint.platformId][LastElementIndex - 1].t, datapoint.t)
            if  DeltaT >= 60 then
                table.insert(self.dataPoints[datapoint.platformId], datapoint)
            else
                self.dataPoints[datapoint.platformId][LastElementIndex] = datapoint
            end
            if table.getn(self.dataPoints[datapoint.platformId]) > 11 then
                table.remove(self.dataPoints[datapoint.platformId], 1)
            end
        end
    end

    function HoundContact:triangulatePoints(earlyPoint, latePoint)
        local p1 = earlyPoint.platformPos
        local p2 = latePoint.platformPos

        local m1 = math.tan(earlyPoint.az)
        local m2 = math.tan(latePoint.az)

        local b1 = -m1 * p1.x + p1.z
        local b2 = -m2 * p2.x + p2.z

        local Easting = (b2 - b1) / (m1 - m2)
        local Northing = m1 * Easting + b1

        local pos = {}
        pos.x = Easting
        pos.z = Northing
        pos.y = land.getHeight({pos.x,pos.z})

        return pos
    end

    function HoundContact:calculateAzimuthBias(dataPoints)

        local azimuths = {}
        for k,v in ipairs(dataPoints) do
            table.insert(azimuths,v.az)
        end

        return  HoundUtils.AzimuthAverage(azimuths)
    end

    function HoundContact:calculateEllipse(estimatedPositions,Theta)
        table.sort(estimatedPositions,function(a,b) return tonumber(mist.utils.get2DDist(self.pos.p,a)) < tonumber(mist.utils.get2DDist(self.pos.p,b)) end)

        local percentile = math.floor(length(estimatedPositions)*0.50)
        local RelativeToPos = {}
        local NumToUse = math.max(math.min(2,length(estimatedPositions)),percentile)
        for i = 1, NumToUse  do
            table.insert(RelativeToPos,mist.vec.sub(estimatedPositions[i],self.pos.p))
        end
        local sinTheta = math.sin(Theta)
        local cosTheta = math.cos(Theta)

        for k,v in ipairs(RelativeToPos) do
            local newPos = {}
            newPos.y = v.y
            newPos.x = v.x*cosTheta - v.z*sinTheta
            newPos.z = v.x*sinTheta + v.z*cosTheta
            RelativeToPos[k] = newPos
        end

        local min = {}
        min.x = 99999
        min.y = 99999

        local max = {}
        max.x = -99999
        max.y = -99999

        for k,v in ipairs(RelativeToPos) do
            min.x = math.min(min.x,v.x)
            max.x = math.max(max.x,v.x)
            min.y = math.min(min.y,v.z)
            max.y = math.max(max.y,v.z)
        end

        local x = mist.utils.round(math.abs(min.x)+math.abs(max.x))
        local y = mist.utils.round(math.abs(min.y)+math.abs(max.y))
        self.uncertenty_radius = {}
        self.uncertenty_radius.major = math.max(x,y)
        self.uncertenty_radius.minor = math.min(x,y)
        self.uncertenty_radius.az = mist.utils.round(mist.utils.toDegree(Theta))
        self.uncertenty_radius.r  = (x+y)/4
        
    end

    function HoundContact:calculatePos(estimatedPositions)
        if estimatedPositions == nil then return end
        self.pos.p =  mist.getAvgPoint(estimatedPositions)
        local bullsPos = coalition.getMainRefPoint(self.platformCoalition)
        self.pos.LL.lat, self.pos.LL.lon =  coord.LOtoLL(self.pos.p)
        self.pos.elev = land.getHeight(self.pos.p)
        self.pos.grid  = coord.LLtoMGRS(self.pos.LL.lat, self.pos.LL.lon)
        self.pos.be.brg = mist.utils.round(mist.utils.toDegree(mist.utils.getDir(mist.vec.sub(self.pos.p,bullsPos))))
        self.pos.be.rng =  mist.utils.round(mist.utils.metersToNM(mist.utils.get2DDist(self.pos.p,bullsPos)))
    end

    function HoundContact:removeMarker()
        if self.markpointID ~= nil then
            trigger.action.removeMark(self.markpointID)
        end
    end
    function HoundContact:updateMarker(coalitionID)
        if self.pos.p == nil or self.uncertenty_radius == nil then return end
        self:removeMarker()
        local marker = world.getMarkPanels()
        if length(marker) > 0 then 
            marker = (marker[#marker].idx + 1)
        else 
            marker = math.random(1,500)
        end
        self.markpointID = marker
        trigger.action.markToCoalition(self.markpointID, self.typeName .. " " .. (self.uid%100) .. " (" .. self.uncertenty_radius.major .. "/" .. self.uncertenty_radius.minor .. "@" .. self.uncertenty_radius.az .. "|" .. HoundUtils:timeDelta(self.last_seen) .. "s)",self.pos.p,self.platformCoalition,true)
    end

    function HoundContact:positionDebug()
        if self.pos.p == nil then return end
        env.info("location of " ..self.typeName .. " is " .. self.pos.p.x .. " " ..  self.pos.p.z)
    end


    function HoundContact:getTextData(utmZone,MGRSdigits)
        if self.pos.p == nil then return end
        local GridPos = ""
        if utmZone then
            GridPos = GridPos .. self.pos.grid.UTMZone .. " " 
        end
        GridPos = GridPos .. self.pos.grid.MGRSDigraph
        local BE = string.format("%03d",self.pos.be.brg) .. " for " .. self.pos.be.rng
        if MGRSdigits == nil then
            return GridPos,BE
        end
        local E = math.floor(self.pos.grid.Easting/math.pow(10,math.min(5,math.max(1,5-MGRSdigits))))
        local N = math.floor(self.pos.grid.Northing/math.pow(10,math.min(5,math.max(1,5-MGRSdigits))))
        GridPos = GridPos .. " " .. E .. " " .. N
        
        return GridPos,BE
    end

    function HoundContact:getTtsData(utmZone,MGRSdigits)
        if self.pos.p == nil then return end
        local phoneticGridPos = ""
        if utmZone then
            phoneticGridPos =  phoneticGridPos .. HoundUtils.TTS.toPhonetic(self.pos.grid.UTMZone) .. " "
        end

        phoneticGridPos =  phoneticGridPos ..  HoundUtils.TTS.toPhonetic(self.pos.grid.MGRSDigraph)
        local phoneticBulls = HoundUtils.TTS.toPhonetic(string.format("%03d",self.pos.be.brg)) 
                                .. " for " .. self.pos.be.rng
        if MGRSdigits==nil then
            return phoneticGridPos,phoneticBulls
        end
        local E = math.floor(self.pos.grid.Easting/math.pow(10,math.min(5,math.max(1,5-MGRSdigits))))
        local N = math.floor(self.pos.grid.Northing/math.pow(10,math.min(5,math.max(1,5-MGRSdigits))))
        phoneticGridPos = phoneticGridPos .. " " .. HoundUtils.TTS.toPhonetic(E) .. " " .. HoundUtils.TTS.toPhonetic(N)

        return phoneticGridPos,phoneticBulls
    end

    function HoundContact:generateTtsBrief()
        if self.pos.p == nil or self.uncertenty_radius == nil then return end
        local phoneticGridPos,phoneticBulls = self:getTtsData()
        local str = self.typeName .. " " .. (self.uid % 100) .. ", " .. HoundUtils.TTS.getVerbalContactAge(self.last_seen,true)
        str = str .. " at " .. phoneticGridPos -- .. ", bullz " .. phoneticBulls 
        str = str .. ", accuracy " .. HoundUtils.TTS.getVerbalConfidenceLevel( self.uncertenty_radius.r ) .. "."
        return str
    end

    function HoundContact:generateTtsReport()
        if self.pos.p == nil then return end
        local phoneticGridPos,phoneticBulls = self:getTtsData(true,3)
        local msg =  self.typeName .. " " .. (self.uid % 100) ..", bullz " .. phoneticBulls -- .. ", grid ".. phoneticGridPos
        msg = msg .. ", position " .. HoundUtils.TTS.getVerbalLL(self.pos.LL.lat,self.pos.LL.lon)
        msg = msg .. ", I repeat " .. HoundUtils.TTS.getVerbalLL(self.pos.LL.lat,self.pos.LL.lon)
        msg = msg .. ", MGRS " .. phoneticGridPos
        msg = msg .. ", elevation  " .. HoundUtils.getRoundedElevationFt(self.pos.elev) .. "feet MSL"
        msg = msg .. ", accuracy " .. HoundUtils.TTS.getVerbalConfidenceLevel( self.uncertenty_radius.r )
        msg = msg .. ", ellipse " ..  HoundUtils.TTS.simplfyDistance(self.uncertenty_radius.major) .. " by " ..  HoundUtils.TTS.simplfyDistance(self.uncertenty_radius.minor) .. ", aligned bearing " .. HoundUtils.TTS.toPhonetic(string.format("%03d",self.uncertenty_radius.az))
        msg = msg .. ", first seen " .. HoundUtils.TTS.getTtsTime(self.first_seen) .. ", last seen " .. HoundUtils.TTS.getVerbalContactAge(self.last_seen) .. " ago. " .. HoundUtils:getControllerResponse()
        return msg
    end

    function HoundContact:generateTextReport()
        if self.pos.p == nil then return end
        local GridPos,BePos = self:getTextData(true,3)
        local msg =  self.typeName .. " " .. (self.uid % 100) .."\n"
        msg = msg .. "BE: " .. BePos .. "\n" -- .. " (grid ".. GridPos ..")\n"
        msg = msg .. "LL: " .. HoundUtils.Text.getLL(self.pos.LL.lat,self.pos.LL.lon).."\n"
        msg = msg .. "MGRS: " .. GridPos .. "\n"
        msg = msg .. "Elev: " .. HoundUtils.getRoundedElevationFt(self.pos.elev) .. "ft\n"
        msg = msg .. "Accuracy: " .. HoundUtils.TTS.getVerbalConfidenceLevel( self.uncertenty_radius.r ) .. "\n"
        msg = msg .. "Ellipse: " ..  self.uncertenty_radius.major .. " by " ..  self.uncertenty_radius.minor .. " aligned bearing " .. string.format("%03d",self.uncertenty_radius.az) .. "\n"
        msg = msg .. "First detected: " .. HoundUtils.Text.getTime(self.first_seen) .. " Last Contact: " ..  HoundUtils.TTS.getVerbalContactAge(self.last_seen) .. " ago. " .. HoundUtils:getControllerResponse()
        return msg
    end

    function HoundContact:generateRadioItemText()
        if self.pos.p == nil then return end
        local GridPos,BePos = self:getTextData(true)
        BePos = BePos:gsub(" for ","/")
        return self.typeName .. (self.uid % 100) .. " - BE: " .. BePos .. " (".. GridPos ..")"
    end 


    function HoundContact:generatePopUpReport(isTTS)
        local msg = "BREAK, BREAK! New threat detected! "
        msg = msg .. self.typeName .. " " .. (self.uid % 100)
        local GridPos,BePos 
        if isTTS then
            GridPos,BePos = self:getTtsData(true)
            msg = msg .. ", bullz " .. BePos .. ", grid ".. GridPos
        else
            GridPos,BePos = self:getTextData(true)
            msg = msg .. " BE: " .. BePos .. " (grid ".. GridPos ..")"
        end
        msg = msg .. " is now Alive!"
        return msg
    end

    function HoundContact:generateDeathReport(isTTS)
        local msg = self.typeName .. " " .. (self.uid % 100)
        local GridPos,BePos 
        if isTTS then
            GridPos,BePos = self:getTtsData(true)
            msg = msg .. ", bullz " .. BePos .. ", grid ".. GridPos
        else
            GridPos,BePos = self:getTextData(true)
            msg = msg .. " BE: " .. BePos .. " (grid ".. GridPos ..")"
        end
        msg = msg .. " has been destroyed!"
        return msg
    end

    function HoundContact:processData()
        local newContact = (self.pos.p == nil)
        local mobileDataPoints = {}
        local staticDataPoints = {}
        local estimatePosition = {}

        for k,v in pairs(self.dataPoints) do 
            if length(v) > 0 then
                for k,v in pairs(v) do 
                    if v.isReciverStatic then
                        table.insert(staticDataPoints,v) 
                    else
                        table.insert(mobileDataPoints,v) 
                    end
                    if v.estimatedPos ~= nil then
                        table.insert(estimatePosition,v.estimatedPos)
                    end
                end
            end
        end
        local numMobilepoints = length(mobileDataPoints)
        local numStaticPoints = length(staticDataPoints)

        if numMobilepoints+numStaticPoints < 2 and length(estimatePosition) == 0 then return end
        -- Static against all statics
        if numStaticPoints > 1 then
            for i=1,numStaticPoints-1 do
                for j=i+1,numStaticPoints do
                    table.insert(estimatePosition,self:triangulatePoints(staticDataPoints[i],staticDataPoints[j]))
                end
            end
        end

        -- Statics against all mobiles
        if numStaticPoints > 0  and numMobilepoints > 0 then
            for i,staticDataPoint in ipairs(staticDataPoints) do
                for j,mobileDataPoint in ipairs(mobileDataPoints) do
                    if math.deg(HoundUtils.angleDeltaRad(staticDataPoint.az,mobileDataPoint.az)) > 1.5 then
                        table.insert(estimatePosition,self:triangulatePoints(staticDataPoint,mobileDataPoint))
                    end
                end
            end
         end

        -- mobiles agains mobiles
        if numMobilepoints > 1 then
            for i=1,numMobilepoints-1 do
                for j=i+1,numMobilepoints do
                    if math.deg(HoundUtils.angleDeltaRad(mobileDataPoints[i].az,mobileDataPoints[j].az)) > 2 then
                        table.insert(estimatePosition,self:triangulatePoints(mobileDataPoints[i],mobileDataPoints[j]))
                    end
                end
            end
        end
        
        if length(estimatePosition) > 1 then
            self:calculatePos(estimatePosition)
            local combinedDataPoints = {} 
            if numMobilepoints > 0 then
                for k,v in ipairs(mobileDataPoints) do table.insert(combinedDataPoints,v) end
            end
            if numStaticPoints > 0 then
                for k,v in ipairs(staticDataPoints) do table.insert(combinedDataPoints,v) end
            end
            self:calculateEllipse(estimatePosition,self:calculateAzimuthBias(combinedDataPoints))
        end

        if newContact and self.pos.p ~= nil and self.isEWR == false then
            return true
        end
    end
end
